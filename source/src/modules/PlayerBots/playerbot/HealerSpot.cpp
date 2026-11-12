#include "playerbot.h"
#include "HealerSpot.h"
#include "FleeManager.h"
#include "playerbot/PlayerbotAIConfig.h"
#include "playerbot/ServerFacade.h"
#include "Group/Group.h"
#include "Maps/PathFinder.h"
#include "strategy/actions/ChatShortcutActions.h"
#include "strategy/actions/GenericSpellActions.h"
#include "strategy/actions/MovementActions.h"
#include "strategy/generic/UseFoodStrategy.h"
#include "strategy/values/LastMovementValue.h"
#include "strategy/values/PartyMemberToHeal.h"
#include <algorithm>
#include <iomanip>
#include <map>
#include <sstream>

using namespace ai;

const char* ai::HealerFaultName(HealerFault fault)
{
    switch (fault)
    {
        case HealerFault::Area:  return "area damage";
        case HealerFault::Fight: return "fight near";
        case HealerFault::Idle:  return "idle mob near";
        case HealerFault::Range: return "out of range";
        case HealerFault::Sight: return "no sight";
        default:                 return "none";
    }
}

bool ai::LedHealer(PlayerbotAI* ai)
{
    // The master first. IsHeal scans the talents of a bot with no heal strategy, and
    // this runs on every tick of every bot.
    Player* bot = ai->GetBot();
    if (!ai->HasRealPlayerMaster())
        return false;

    Player* master = ai->GetMaster();
    return master && master != bot && master->IsInWorld() && master->GetMapId() == bot->GetMapId() && PlayerbotAI::IsHeal(bot);
}

// The patient, when it is another unit on this map and alive.
static Unit* Patient(PlayerbotAI* ai)
{
    Player* bot = ai->GetBot();
    Unit* patient = ai->GetAiObjectContext()->GetValue<Unit*>("party member to heal")->Get();
    if (!patient || patient == bot || !patient->IsInWorld() || patient->GetMapId() != bot->GetMapId() || !sServerFacade.IsAlive(patient))
        return nullptr;

    return patient;
}

bool ai::MobFleeing(Unit* unit)
{
    if (unit->HasUnitState(UNIT_STAT_FLEEING))
        return true;

    const MovementGeneratorType type = unit->GetMotionMaster()->GetCurrentMovementGeneratorType();
    return type == ASSISTANCE_MOTION_TYPE || type == ASSISTANCE_DISTRACT_MOTION_TYPE;
}

Unit* ai::MobOnHealer(Player* bot)
{
    for (Unit* unit : bot->getAttackers())
        if (!MobFleeing(unit))
            return unit;

    return nullptr;
}

// What is around the healer. Mobs on the healer are not in `fight`: they come with it.
// Fleeing mobs are in neither `fight` nor `idle`. They are kept for the log.
struct Scene
{
    Player* bot = nullptr;
    Player* master = nullptr;
    Unit* patient = nullptr;
    std::list<Unit*> fight;
    std::list<Unit*> fleeing;
    std::list<Unit*> idle;
    std::list<DynamicObject*> areas;
    std::list<Player*> others;
};

static Scene BuildScene(PlayerbotAI* ai)
{
    Scene scene;
    scene.bot = ai->GetBot();
    scene.master = ai->GetMaster();
    scene.patient = Patient(ai);
    scene.idle = IdleHostiles(ai);

    Player* bot = scene.bot;
    AiObjectContext* context = ai->GetAiObjectContext();

    // Not "attackers" alone: with a skull in the fight that list holds only the skull
    // for a bot that is not a tank (AttackersValue). The other mobs in the fight were in
    // neither list here. A mob in combat near the healer counts, whoever it fights.
    auto addFight = [&](Unit* unit)
    {
        if (!unit || !sServerFacade.IsAlive(unit))
            return;

        // A fleeing mob counts again the moment it stops.
        const bool fleeing = MobFleeing(unit);
        if (!fleeing && bot->getAttackers().count(unit))
            return;

        std::list<Unit*>& list = fleeing ? scene.fleeing : scene.fight;
        if (std::find(list.begin(), list.end(), unit) == list.end())
            list.push_back(unit);
    };

    for (ObjectGuid const& guid : context->GetValue<std::list<ObjectGuid>>("attackers")->Get())
        addFight(ai->GetUnit(guid));

    for (ObjectGuid const& guid : context->GetValue<std::list<ObjectGuid>>("possible targets no los")->Get())
    {
        Unit* unit = ai->GetUnit(guid);
        if (unit && unit->GetTypeId() == TYPEID_UNIT && sServerFacade.IsInCombat(unit) && unit->IsHostileTo(bot))
            addFight(unit);
    }

    for (ObjectGuid const& guid : context->GetValue<std::list<ObjectGuid>>("nearest dynamic objects")->Get())
    {
        DynamicObject* area = bot->GetMap()->GetDynamicObject(guid);
        if (!area)
            continue;

        SpellEntry const* spell = sSpellTemplate.LookupEntry<SpellEntry>(area->GetSpellId());
        if (spell && !IsPositiveEffect(spell, area->GetEffIndex()) && area->IsHostileTo(bot))
            scene.areas.push_back(area);
    }

    if (Group* group = bot->GetGroup())
    {
        for (GroupReference* ref = group->GetFirstMember(); ref; ref = ref->next())
        {
            Player* member = ref->getSource();
            if (member && member != scene.master && member != bot && member->IsInWorld() && member->GetMapId() == bot->GetMapId())
                scene.others.push_back(member);
        }
    }

    return scene;
}

static bool InArea(Scene const& scene, float x, float y, float margin)
{
    for (DynamicObject* area : scene.areas)
        if (std::hypot(area->GetPositionX() - x, area->GetPositionY() - y) < area->GetRadius() + margin)
            return true;

    return false;
}

// A mob not in the fight that would notice the healer at this place. A mob more than
// 10 yd above or below is on another floor. A walking mob gets the wider margin: it may
// be a patrol coming this way. trustWalls: a mob with no sight of the place does not
// count. Used for the place the healer stands and for the last pass of the chooser. A
// healer took a spot 13 yd from a Goblin Woodcarver on this test and pulled it.
static Unit* IdleThreat(Scene const& scene, float x, float y, float z, float standing, float walking, bool trustWalls)
{
    for (Unit* unit : scene.idle)
    {
        if (std::fabs(unit->GetPositionZ() - z) > 10.0f)
            continue;

        const float margin = sServerFacade.isMoving(unit) ? walking : standing;
        if (sServerFacade.GetDistance2d(unit, x, y) >= unit->GetAttackDistance(scene.bot) + margin)
            continue;

        if (!trustWalls || unit->IsWithinLOS(x, y, z, true))
            return unit;
    }

    return nullptr;
}

// The ray a cast uses (Spell::CheckCast, IsWithinLOSInMap), from a place the bot is not
// at yet. The ring used a higher ray and took spots a heal could not reach.
static bool SeesFrom(Player* bot, float x, float y, float z, Unit* target)
{
    float ox, oy, oz;
    target->GetLosCheckPosition(ox, oy, oz);
    return bot->IsWithinLOSAtPosition(x, y, z, ox, oy, oz, true, 0.0f);
}

// The log only. A fleeing mob causes no walk, so no other line shows it. One line for each
// mob the healer would have walked from.
static void NoteIgnoredMob(PlayerbotAI* ai, Scene const& scene)
{
    if (!ai->HasStrategy("debug", BotState::BOT_STATE_NON_COMBAT))
        return;

    Player* bot = scene.bot;
    Unit* nearest = nullptr;
    for (Unit* unit : scene.fleeing)
    {
        const float distance = sServerFacade.GetDistance2d(bot, unit);
        if (distance < 10.0f && (!nearest || distance < sServerFacade.GetDistance2d(bot, nearest)))
            nearest = unit;
    }

    LastMovement& lm = ai->GetAiObjectContext()->GetValue<LastMovement&>("last movement")->Get();
    if (!nearest)
    {
        lm.healerIgnoredMob = ObjectGuid();
        return;
    }

    if (lm.healerIgnoredMob == nearest->GetObjectGuid())
        return;

    lm.healerIgnoredMob = nearest->GetObjectGuid();

    std::ostringstream out;
    out << std::fixed << std::setprecision(1) << "spot: ignored " << nearest->GetName() << ", fleeing, "
        << sServerFacade.GetDistance2d(bot, nearest) << " yd, health " << nearest->GetHealthPercent() << "%, "
        << (bot->getAttackers().count(nearest) ? "on me" : "not on me");
    ai->TellPlayerNoFacing(scene.master, out.str(), PlayerbotSecurityLevel::PLAYERBOT_SECURITY_ALLOW_ALL, true, false);
}

// The fault test. A spot must beat these, or the healer arrives and walks again.
static const float IDLE_STANDING_MARGIN = 1.0f;
static const float IDLE_WALKING_MARGIN = 5.0f;

HealerFault ai::HealerSpotFault(PlayerbotAI* ai)
{
    if (!LedHealer(ai))
        return HealerFault::None;

    Player* bot = ai->GetBot();

    const bool holds = MobOnHealer(bot) || PartyMemberToHeal::HealerHealsFirst(ai) || HealerKeepsDrinking(ai) ||
        ai->HasStrategy("follow", BotState::BOT_STATE_COMBAT) ||
        ai->HasStrategy("guard", BotState::BOT_STATE_COMBAT) ||
        ai->HasStrategy("wander", BotState::BOT_STATE_COMBAT);

    if (ai->IsStateActive(BotState::BOT_STATE_COMBAT) && !holds)
    {
        Scene const scene = BuildScene(ai);
        const float x = bot->GetPositionX();
        const float y = bot->GetPositionY();

        NoteIgnoredMob(ai, scene);

        if (ai->GetAiObjectContext()->GetValue<bool>("has area debuff", "self target")->Get() || InArea(scene, x, y, 0.0f))
            return HealerFault::Area;

        for (Unit* unit : scene.fight)
            if (sServerFacade.GetDistance2d(bot, unit) < 10.0f)
                return HealerFault::Fight;

        if (IdleThreat(scene, x, y, bot->GetPositionZ(), IDLE_STANDING_MARGIN, IDLE_WALKING_MARGIN, true))
            return HealerFault::Idle;
    }

    Unit* patient = Patient(ai);
    if (!patient || !PartyMemberToHeal::WorthWalkingTo(ai, patient))
        return HealerFault::None;

    if (bot->GetDistance(patient, true, DIST_CALC_COMBAT_REACH) > PartyMemberToHeal::HealSpellRange() - sPlayerbotAIConfig.contactDistance)
        return HealerFault::Range;

    return bot->IsWithinLOSInMap(patient, true) ? HealerFault::None : HealerFault::Sight;
}

bool ai::HealerWantsToMove(PlayerbotAI* ai)
{
    if (!LedHealer(ai) || HealerWalkingOut(ai))
        return false;

    LastMovement& lm = ai->GetAiObjectContext()->GetValue<LastMovement&>("last movement")->Get();
    const time_t now = time(nullptr);

    if (lm.lastHealerNoSpot && now - lm.lastHealerNoSpot < 3)
        return false;

    if (lm.healerWalks >= 2 && now - lm.lastHealerWalk <= (time_t)(sPlayerbotAIConfig.returnDelay / 1000))
        return false;

    return HealerSpotFault(ai) != HealerFault::None;
}

float ai::WalkGap(Player* bot, PathFinder const& path, float toX, float toY, float toZ, float x, float y, float* nearest)
{
    float ax = bot->GetPositionX();
    float ay = bot->GetPositionY();
    float az = bot->GetPositionZ();
    float best = std::hypot(ax - x, ay - y);

    if (nearest)
    {
        nearest[0] = ax;
        nearest[1] = ay;
        nearest[2] = az;
    }

    auto leg = [&](float bx, float by, float bz)
    {
        const float dx = bx - ax;
        const float dy = by - ay;
        const float length = dx * dx + dy * dy;
        float t = length > 0.0f ? ((x - ax) * dx + (y - ay) * dy) / length : 0.0f;
        t = std::max(0.0f, std::min(1.0f, t));

        const float px = ax + t * dx;
        const float py = ay + t * dy;
        const float gap = std::hypot(px - x, py - y);
        if (gap < best)
        {
            best = gap;
            if (nearest)
            {
                nearest[0] = px;
                nearest[1] = py;
                nearest[2] = az + t * (bz - az);
            }
        }

        ax = bx;
        ay = by;
        az = bz;
    };

    for (auto const& point : path.getPath())
        leg(point.x, point.y, point.z);
    leg(toX, toY, toZ);

    return best;
}

namespace
{
    // The rules for a spot, strict first. A spot beats the 10 yd test by 3 yd when it
    // can, so a mob that shifts a yard does not start the next walk. Each pass has a
    // walk limit. Without one a healer 9.9 yd from a mob ran 15 yd to a strict spot, and
    // pulled the next pack, when two steps would have done.
    struct Pass
    {
        float fightGap;     // spot to each mob in the fight
        float idleMargin;   // spot past each idle mob's aggro range
        float walkMargin;   // walk past each idle mob's aggro range
        float ownerClear;   // walk to the owner
        float maxWalk;      // spot from the healer
        bool seesBoth;      // the spot also sees the owner, when the patient is another unit
        bool spaced;        // 5 yd from other group members
        bool trustWalls;    // an idle mob with no sight of the place does not count
    };

    const Pass PASSES[] =
    {
        { 13.0f, 5.0f, 3.0f, WALK_CLEAR, 12.0f, true,  true,  false },
        { 10.5f, 3.0f, 1.5f, WALK_CLEAR, 20.0f, false, true,  false },
        { 10.5f, 3.0f, 1.5f, 3.0f,       30.0f, false, false, true  },
    };

    struct Spot
    {
        float x;
        float y;
        float z;
        float homeZ;        // a ring spot stays near this height
        float away;         // from the bot
        bool isRing;
        bool groundFound;   // z is the ground here
        std::string name;
    };

    const float ROUTE_STEP = 2.0f;
    const float ROUTE_MAX = 60.0f;
    const float RING_HEIGHT = 5.0f;
    const uint32 PATH_BUDGET = 16;      // paths in one pass
}

bool ai::FindHealerSpot(PlayerbotAI* ai, HealerFault fault, float& rx, float& ry, float& rz, std::string& note)
{
    Scene const scene = BuildScene(ai);
    Player* bot = scene.bot;
    Player* master = scene.master;
    Unit* anchor = scene.patient ? scene.patient : master;
    Unit* secondSight = (scene.patient && scene.patient != master) ? master : nullptr;
    const float reach = PartyMemberToHeal::HealSpellRange() - PartyMemberToHeal::HealChaseMargin();

    const bool probe = ai->HasStrategy("debug", BotState::BOT_STATE_NON_COMBAT);
    auto tell = [&](std::string const& text)
    {
        ai->TellPlayerNoFacing(master, text, PlayerbotSecurityLevel::PLAYERBOT_SECURITY_ALLOW_ALL, true, false);
    };

    if (probe)
    {
        std::ostringstream out;
        out << std::fixed << std::setprecision(1) << "spot: " << HealerFaultName(fault)
            << ", me " << bot->GetPositionX() << " " << bot->GetPositionY() << " " << bot->GetPositionZ()
            << ", " << master->GetName() << " " << master->GetPositionX() << " " << master->GetPositionY() << " " << master->GetPositionZ();
        if (scene.patient)
            out << ", patient " << scene.patient->GetName() << " " << sServerFacade.GetDistance2d(bot, scene.patient) << " yd";
        for (Unit* unit : scene.fight)
            out << ", fight " << unit->GetName() << " " << unit->GetPositionX() << " " << unit->GetPositionY() << " " << sServerFacade.GetDistance2d(bot, unit) << " yd";
        for (Unit* unit : scene.fleeing)
            out << ", fleeing " << unit->GetName() << " " << unit->GetPositionX() << " " << unit->GetPositionY() << " " << sServerFacade.GetDistance2d(bot, unit) << " yd";
        for (Unit* unit : scene.idle)
            if (sServerFacade.GetDistance2d(bot, unit) < 40.0f)
                out << ", idle " << unit->GetName() << " " << unit->GetPositionX() << " " << unit->GetPositionY() << " " << sServerFacade.GetDistance2d(bot, unit)
                    << " yd aggro " << unit->GetAttackDistance(bot) << (sServerFacade.isMoving(unit) ? " walking" : " standing");
        tell(out.str());
    }

    // The path to the patient, cut into steps. The first step that passes is the
    // smallest walk that fixes the sight.
    std::vector<Spot> route;
    if (fault == HealerFault::Sight || fault == HealerFault::Range)
    {
        PathFinder path(bot);
        path.calculate(anchor->GetPositionX(), anchor->GetPositionY(), anchor->GetPositionZ(), false);
        if (!(path.getPathType() & (PATHFIND_NOPATH | PATHFIND_INCOMPLETE)))
        {
            float ax = bot->GetPositionX();
            float ay = bot->GetPositionY();
            float az = bot->GetPositionZ();
            float walked = 0.0f;
            float nextStep = ROUTE_STEP;

            for (auto const& point : path.getPath())
            {
                const float length = std::hypot(point.x - ax, point.y - ay);
                while (length > 0.0f && walked + length >= nextStep && nextStep <= ROUTE_MAX)
                {
                    const float t = (nextStep - walked) / length;
                    Spot spot;
                    spot.x = ax + t * (point.x - ax);
                    spot.y = ay + t * (point.y - ay);
                    spot.z = az + t * (point.z - az);
                    spot.homeZ = spot.z;
                    spot.away = nextStep;
                    spot.isRing = false;
                    spot.groundFound = false;
                    spot.name = "route";
                    route.push_back(spot);
                    nextStep += ROUTE_STEP;
                }

                walked += length;
                ax = point.x;
                ay = point.y;
                az = point.z;
            }
        }
    }

    // Short steps from where the healer stands, then rings around the owner and a
    // player patient. Near the bot first: the smallest move that fixes the fault.
    std::vector<Spot> rings;
    auto addRing = [&](WorldObject* center, std::vector<float> const& radii)
    {
        for (float radius : radii)
        {
            for (int i = 0; i < 24; ++i)
            {
                const float angle = i * M_PI_F / 12;
                Spot spot;
                spot.x = center->GetPositionX() + cos(angle) * radius;
                spot.y = center->GetPositionY() + sin(angle) * radius;
                spot.z = center->GetPositionZ() + CONTACT_DISTANCE;
                spot.homeZ = center->GetPositionZ();
                spot.away = sServerFacade.GetDistance2d(bot, spot.x, spot.y);
                spot.isRing = true;
                spot.groundFound = false;
                std::ostringstream name;
                if (center == bot)
                    name << "step";
                else
                    name << std::fixed << std::setprecision(0) << radius << " yd from " << center->GetName();
                spot.name = name.str();
                rings.push_back(spot);
            }
        }
    };

    addRing(bot, { 3.0f, 6.0f, 9.0f });
    addRing(master, { 12.0f, 18.0f, 24.0f });
    if (scene.patient && scene.patient != master && scene.patient->IsPlayer())
        addRing(scene.patient, { 12.0f, 18.0f, 24.0f });
    std::stable_sort(rings.begin(), rings.end(), [](Spot const& a, Spot const& b) { return a.away < b.away; });

    uint32 budget = PATH_BUDGET;
    std::map<std::string, uint32> counts;
    auto refuse = [&](const char* check, Unit* unit = nullptr)
    {
        if (probe)
            ++counts[unit ? std::string(check) + " " + unit->GetName() : std::string(check)];
    };

    // True when the spot takes the search. crossed: the walk there is what failed.
    auto trySpot = [&](Spot& spot, Pass const& pass, bool& crossed) -> bool
    {
        crossed = false;
        const float x = spot.x;
        const float y = spot.y;

        if (spot.away < 1.5f)
            return false;

        if (spot.away > pass.maxWalk)
        {
            refuse("far");
            return false;
        }

        if (pass.spaced)
            for (Player* other : scene.others)
                if (sServerFacade.GetDistance2d(other, x, y) < 5.0f)
                {
                    refuse("member", other);
                    return false;
                }

        for (Unit* unit : scene.fight)
            if (sServerFacade.GetDistance2d(unit, x, y) < pass.fightGap)
            {
                refuse("fight", unit);
                return false;
            }

        if (InArea(scene, x, y, 2.0f))
        {
            refuse("area");
            return false;
        }

        if (sServerFacade.GetDistance2d(anchor, x, y) > reach)
        {
            refuse("range");
            return false;
        }

        if (!spot.groundFound)
        {
            bot->UpdateAllowedPositionZ(spot.x, spot.y, spot.z);
            spot.groundFound = true;
        }

        const float z = spot.z;
        if (spot.isRing && std::fabs(z - spot.homeZ) > RING_HEIGHT)
        {
            refuse("height");
            return false;
        }

        if (Unit* unit = IdleThreat(scene, x, y, z, std::max(pass.idleMargin, IDLE_STANDING_MARGIN + 0.5f),
            std::max(pass.idleMargin, IDLE_WALKING_MARGIN + 0.5f), pass.trustWalls))
        {
            refuse("idle", unit);
            return false;
        }

        if (!SeesFrom(bot, x, y, z, anchor))
        {
            refuse("sight");
            return false;
        }

        if (pass.seesBoth && secondSight && !SeesFrom(bot, x, y, z, secondSight))
        {
            refuse("ownersight");
            return false;
        }

        if (!budget)
        {
            refuse("budget");
            return false;
        }
        --budget;

        PathFinder path(bot);
        path.calculate(x, y, z, false);
        if (path.getPathType() & (PATHFIND_NOPATH | PATHFIND_INCOMPLETE))
        {
            refuse("nopath");
            return false;
        }

        if ((path.getPathType() & PATHFIND_NORMAL) && path.Length() > 1.5f * bot->GetDistance(x, y, z) + 5.0f)
        {
            refuse("longpath");
            return false;
        }

        const auto end = path.getActualEndPosition();
        if (std::hypot(end.x - x, end.y - y) > 2.0f)
        {
            refuse("pathshort");
            return false;
        }

        auto clearOf = [&](Unit* unit, float limit)
        {
            const float gap = WalkGap(bot, path, x, y, z, unit->GetPositionX(), unit->GetPositionY());
            return gap >= std::min(sServerFacade.GetDistance2d(bot, unit) - 0.5f, limit);
        };

        // An idle mob must also see the nearest point of the walk. In a mine most mobs
        // near a walk stand behind a wall.
        auto clearOfIdle = [&](Unit* unit, float limit)
        {
            float nearest[3];
            const float gap = WalkGap(bot, path, x, y, z, unit->GetPositionX(), unit->GetPositionY(), nearest);
            if (gap >= std::min(sServerFacade.GetDistance2d(bot, unit) - 0.5f, limit))
                return true;

            return pass.trustWalls && !unit->IsWithinLOS(nearest[0], nearest[1], nearest[2], true);
        };

        if (!clearOf(master, pass.ownerClear))
        {
            crossed = true;
            refuse("walk", master);
            return false;
        }

        for (Unit* unit : scene.fight)
            if (!clearOf(unit, WALK_CLEAR))
            {
                crossed = true;
                refuse("walk", unit);
                return false;
            }

        for (Unit* unit : scene.idle)
            if (std::fabs(unit->GetPositionZ() - z) <= 10.0f && !clearOfIdle(unit, unit->GetAttackDistance(bot) + pass.walkMargin))
            {
                crossed = true;
                refuse("walk", unit);
                return false;
            }

        std::ostringstream out;
        out << std::fixed << std::setprecision(0) << spot.name << ", " << spot.away << " yd from here, "
            << sServerFacade.GetDistance2d(anchor, x, y) << " yd from " << anchor->GetName()
            << std::setprecision(1) << ", at " << x << " " << y;
        note = out.str();
        rx = x;
        ry = y;
        rz = z;
        return true;
    };

    auto report = [&](int number, bool found)
    {
        if (!probe)
            return;

        std::ostringstream out;
        out << "spot: pass " << number << " " << (found ? "found " + note : std::string("no spot")) << ", refused";
        for (auto const& count : counts)
            out << " | " << count.first << " " << count.second;
        tell(out.str());
        counts.clear();
    };

    int number = 0;
    for (Pass const& pass : PASSES)
    {
        ++number;
        budget = PATH_BUDGET;

        for (Spot& spot : route)
        {
            bool crossed = false;
            if (trySpot(spot, pass, crossed))
            {
                report(number, true);
                return true;
            }

            // Every later step walks the same path.
            if (crossed)
                break;
        }

        for (Spot& spot : rings)
        {
            bool crossed = false;
            if (trySpot(spot, pass, crossed))
            {
                report(number, true);
                return true;
            }
        }

        report(number, false);
    }

    return false;
}

bool ai::HealerWalkingOut(PlayerbotAI* ai)
{
    Player* bot = ai->GetBot();
    if (!ai->HasRealPlayerMaster() || !PlayerbotAI::IsHeal(bot))
        return false;

    LastMovement& lm = ai->GetAiObjectContext()->GetValue<LastMovement&>("last movement")->Get();
    if (!lm.fleeWalkUntil)
        return false;

    if (WorldTimer::getMSTime() >= lm.fleeWalkUntil || !sServerFacade.isMoving(bot) ||
        bot->GetHealthPercent() <= (float)sPlayerbotAIConfig.criticalHealth)
    {
        lm.fleeWalkUntil = 0;
        return false;
    }

    // The owner's rule: stop once it can see. The patient or the fight may have moved
    // since the spot was picked.
    if (lm.walkForSight && HealerSpotFault(ai) == HealerFault::None)
    {
        lm.fleeWalkUntil = 0;
        ai->StopMoving();
        return false;
    }

    return true;
}

// A deny list, as AllowedWhileHealerDrinks: spells and moves are what stop the walk.
// Orders pass, and a flee in the reaction engine does not come here. PlayerbotAI::
// CastSpell stops a walk even for an instant spell, so only a heal that comes first
// may cut one short.
bool ai::AllowedWhileHealerWalksOut(PlayerbotAI* ai, Action* action)
{
    if (!action)
        return true;

    if (dynamic_cast<FollowChatShortcutAction*>(action))
        return true;

    if (dynamic_cast<CastHealingSpellAction*>(action))
        return PartyMemberToHeal::HealerHealsFirst(ai);

    return !dynamic_cast<CastSpellAction*>(action) && !dynamic_cast<MovementAction*>(action);
}
