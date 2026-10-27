#include "ArrivalFloor.h"
#include "Map.h"
#include "Player.h"
#include "Creature.h"
#include "CellImpl.h"
#include "GridNotifiers.h"
#include "GridNotifiersImpl.h"
#include "Log.h"
#include "WorldPacket.h"
#include "WorldSession.h"
#include "Opcodes.h"

#include <atomic>
#include <cmath>
#include <list>
#include <mutex>
#include <unordered_map>
#include <vector>

namespace
{
    uint32 const ARRIVAL_WATCH_MS    = 15000;   // how long a player is checked
    uint32 const ARRIVAL_HOLD_MS     = 1000;    // how long the floor z is held
    uint32 const ARRIVAL_HOLD_EVERY  = 250;     // between hold packets
    float  const ARRIVAL_HOLD_MOVED  = 0.5f;    // moved this far from arrival: the hold ends
    uint32 const ARRIVAL_CHECK_MS    = 500;     // between checks
    uint32 const ARRIVAL_BEAT_1_MS   = 3000;    // first creature beat
    uint32 const ARRIVAL_BEAT_2_MS   = 6000;    // second, for a slow load
    uint32 const ARRIVAL_MAX_LIFTS   = 6;       // a client without the model falls forever
    float  const ARRIVAL_RADIUS      = 15.0f;   // a player this far from arrival is left alone
    float  const ARRIVAL_IN_PLACE    = 2.0f;    // this close to arrival, a drop is a fall
    float  const ARRIVAL_BEAT_RADIUS = 60.0f;   // creatures sent again around the player
    float  const ARRIVAL_SUNK        = 0.3f;    // below the floor by more than this is a fall
    float  const ARRIVAL_BEAT_LIFT   = 0.05f;   // the hop: a real delta, invisible

    uint32 const HOUSING_MAP = 28;              // HouseMgr handles arrivals there

    struct Arrival
    {
        uint32 mapId      = 0;
        uint32 instanceId = 0;
        float  x = 0.0f, y = 0.0f, z = 0.0f;
        uint32 elapsed    = 0;
        uint32 sinceCheck = 0;
        uint32 lifts      = 0;
        uint8  beats      = 0;
        bool   lifting    = false;  // our own NearTeleportTo: its ack must not re-arm
        bool   hold       = false;  // arrived on a gameobject floor: hold z for a while
        uint32 sinceHold  = 0;
    };

    enum class Step { Check, Beat, Hold };

    struct Work
    {
        uint32  guid;
        Step    step;
        Arrival a;
    };

    std::mutex                          g_lock;
    std::unordered_map<uint32, Arrival> g_arrivals;
    std::atomic<uint32>                 g_count{0};

    bool HasHeight(float h) { return h > INVALID_HEIGHT; }

    // A gameobject floor at z, with no terrain or static WMO at that height.
    bool OnGameObjectFloor(Map const* map, float x, float y, float z)
    {
        float const floor = map->GetDynamicTreeHeight(x, y, z + 0.5f, 1.0f);
        if (!HasHeight(floor) || std::fabs(floor - z) > 0.5f)
            return false;

        float const ground = map->GetTerrain()->GetHeightStatic(x, y, z, true, 2.0f);
        return !(HasHeight(ground) && ground > z - 0.5f);
    }

    // The hold: a heartbeat to the player's own client with its current x, y
    // and facing, and the arrival floor's z. A client obeys a server position
    // for its own mover, so it does not fall while the building loads. The x
    // and y are the client's own, so a player who has moved is not pulled back.
    // False when the player has started to walk or jump: the hold ends there.
    //
    // THE PACKET IS BUILT FROM A COPY. The first version wrote the floor z into
    // m_movementInfo. Each client packet is read on top of that copy and checked
    // by the anticheat against it, so the client's packets could be refused:
    // the server then never saw the player move, held for the full 3 s and sent
    // an old x and y. That was the jank.
    bool HoldPlayer(Player* p, Arrival const& a)
    {
        if (p->IsTaxiFlying() || p->GetTransport() || p->IsBeingTeleported())
            return false;

        if (p->m_movementInfo.HasMovementFlag(MOVEFLAG_MASK_XZ | MOVEFLAG_JUMPING))
            return false;

        if (!p->IsWithinDist2d(a.x, a.y, ARRIVAL_HOLD_MOVED))
            return false;

        MovementInfo mi = p->m_movementInfo;
        mi.ChangePosition(p->GetPositionX(), p->GetPositionY(), a.z, p->GetOrientation());
        mi.RemoveMovementFlag(MOVEFLAG_MASK_MOVING);
        mi.UpdateTime(WorldTimer::getMSTime());

        WorldPacket data(MSG_MOVE_HEARTBEAT);
        data << p->GetPackGUID();
        data << mi;
        p->GetSession()->SendPacket(&data);
        return true;
    }

    // Fallen through a gameobject floor: put back on it, with the client's own x,
    // y and facing. True when a teleport went out.
    bool CheckPlayer(Map* map, Player* p, Arrival const& a)
    {
        if (p->IsTaxiFlying() || p->GetTransport() || p->IsBeingTeleported())
            return false;

        if (!p->IsWithinDist2d(a.x, a.y, ARRIVAL_RADIUS))
            return false;                       // walked away

        float const x = p->GetPositionX();
        float const y = p->GetPositionY();
        float const z = p->GetPositionZ();

        if (z > a.z - ARRIVAL_SUNK)
            return false;                       // not below where they came in

        // The gameobject floor under this x and y, searched from arrival height
        // down to the player.
        float const top   = a.z + 0.5f;
        float const floor = map->GetDynamicTreeHeight(x, y, top, top - z);
        if (!HasHeight(floor) || floor < z + ARRIVAL_SUNK)
            return false;                       // no gameobject floor above them

        // Still on the arrival point: they fell, whatever they landed on. A fall
        // from upstairs lands on the downstairs floor, which is a gameobject too.
        //
        // Walked away from it and standing on a gameobject surface at their own
        // height: a cellar or a lower storey, so leave them. The ray starts just
        // above the feet, so a floor they are sunk into is above it and not found.
        if (!p->IsWithinDist2d(a.x, a.y, ARRIVAL_IN_PLACE))
        {
            float const under = map->GetDynamicTreeHeight(x, y, z + 0.1f, 0.6f);
            if (HasHeight(under))
                return false;
        }

        sLog.outString("ArrivalFloor: %s was %.2f yd under a gameobject floor at (%.1f, %.1f, %.2f) on map %u, put back",
                       p->GetName(), floor - z, x, y, floor, map->GetId());

        p->NearTeleportTo(x, y, floor, p->GetOrientation());
        return true;
    }

    // Each creature near the player that stands on a gameobject floor, lifted a
    // hair and put back, so the client draws it at the server's z.
    void BeatCreatures(Map* map, Player* p)
    {
        std::list<Creature*> creatures;
        MaNGOS::AllCreaturesInRange check(p, ARRIVAL_BEAT_RADIUS);
        MaNGOS::CreatureListSearcher<MaNGOS::AllCreaturesInRange> searcher(creatures, check);
        Cell::VisitGridObjects(p, searcher, ARRIVAL_BEAT_RADIUS);

        uint32 count = 0;
        for (Creature* c : creatures)
        {
            if (!c->IsInWorld() || !c->IsAlive() || c->IsPet() || c->IsInCombat() || c->GetTransport())
                continue;

            float const x = c->GetPositionX();
            float const y = c->GetPositionY();
            float const z = c->GetPositionZ();
            float const o = c->GetOrientation();

            if (!OnGameObjectFloor(map, x, y, z))
                continue;

            c->NearTeleportTo(x, y, z + ARRIVAL_BEAT_LIFT, o);
            c->NearTeleportTo(x, y, z, o);
            ++count;
        }

        if (count)
            sLog.outString("ArrivalFloor: sent %u creature(s) on a gameobject floor again for %s on map %u",
                           count, p->GetName(), map->GetId());
    }
}

void ArrivalFloor::Arm(Player* player)
{
    if (!player || !player->IsInWorld())
        return;

    Map* map = player->GetMap();
    if (!map || map->GetId() == HOUSING_MAP)
        return;

    bool const hold = OnGameObjectFloor(map, player->GetPositionX(), player->GetPositionY(), player->GetPositionZ());

    Arrival a;
    {
        std::lock_guard<std::mutex> guard(g_lock);

        auto itr = g_arrivals.find(player->GetGUIDLow());
        if (itr != g_arrivals.end() && itr->second.lifting)
        {
            itr->second.lifting = false;            // the ack of our own lift
            return;
        }

        a.mapId      = map->GetId();
        a.instanceId = map->GetInstanceId();
        a.x          = player->GetPositionX();
        a.y          = player->GetPositionY();
        a.z          = player->GetPositionZ();
        a.hold       = hold;

        if (hold)
            sLog.outString("ArrivalFloor: holding %s on a gameobject floor at z %.2f on map %u",
                           player->GetName(), a.z, map->GetId());

        g_arrivals[player->GetGUIDLow()] = a;
        g_count = uint32(g_arrivals.size());
    }

    // The first packet now, not on the next tick.
    if (hold)
        HoldPlayer(player, a);
}

void ArrivalFloor::Update(Map* map, uint32 diff)
{
    if (!g_count.load(std::memory_order_relaxed))
        return;

    // Collect under the lock, act outside it: a lift's ack comes back to Arm.
    std::vector<Work> work;
    {
        std::lock_guard<std::mutex> guard(g_lock);

        for (auto itr = g_arrivals.begin(); itr != g_arrivals.end();)
        {
            Arrival& a = itr->second;
            if (a.mapId != map->GetId() || a.instanceId != map->GetInstanceId())
            {
                ++itr;
                continue;
            }

            Player* p = map->GetPlayer(ObjectGuid(HIGHGUID_PLAYER, itr->first));
            if (!p)
            {
                itr = g_arrivals.erase(itr);    // logged out or left the map
                continue;
            }

            if (a.lifting && !p->IsBeingTeleportedNear())
                a.lifting = false;              // the lift ended without an ack

            a.elapsed    += diff;
            a.sinceCheck += diff;
            a.sinceHold  += diff;

            if (a.hold && a.elapsed >= ARRIVAL_HOLD_MS)
                a.hold = false;

            if (a.hold && a.sinceHold >= ARRIVAL_HOLD_EVERY)
            {
                a.sinceHold = 0;
                work.push_back({ itr->first, Step::Hold, a });
            }

            if ((a.beats == 0 && a.elapsed >= ARRIVAL_BEAT_1_MS) ||
                (a.beats == 1 && a.elapsed >= ARRIVAL_BEAT_2_MS))
            {
                ++a.beats;
                work.push_back({ itr->first, Step::Beat, a });
            }

            if (!a.hold && a.sinceCheck >= ARRIVAL_CHECK_MS && a.lifts < ARRIVAL_MAX_LIFTS)
            {
                a.sinceCheck = 0;
                work.push_back({ itr->first, Step::Check, a });
            }

            if (a.elapsed >= ARRIVAL_WATCH_MS && a.beats >= 2)
                itr = g_arrivals.erase(itr);
            else
                ++itr;
        }

        g_count = uint32(g_arrivals.size());
    }

    for (Work const& w : work)
    {
        Player* p = map->GetPlayer(ObjectGuid(HIGHGUID_PLAYER, w.guid));
        if (!p || !p->IsInWorld())
            continue;

        if (w.step == Step::Beat)
        {
            BeatCreatures(map, p);
            continue;
        }

        if (w.step == Step::Hold)
        {
            if (!HoldPlayer(p, w.a))
            {
                std::lock_guard<std::mutex> guard(g_lock);
                auto itr = g_arrivals.find(w.guid);
                if (itr != g_arrivals.end())
                    itr->second.hold = false;
            }
            continue;
        }

        // Mark the lift before sending it: the ack can arrive on this thread
        // before Update runs again.
        {
            std::lock_guard<std::mutex> guard(g_lock);
            auto itr = g_arrivals.find(w.guid);
            if (itr == g_arrivals.end())
                continue;
            itr->second.lifting = true;
        }

        bool const lifted = CheckPlayer(map, p, w.a);

        std::lock_guard<std::mutex> guard(g_lock);
        auto itr = g_arrivals.find(w.guid);
        if (itr == g_arrivals.end())
            continue;
        if (lifted)
            ++itr->second.lifts;
        else
            itr->second.lifting = false;
    }
}
