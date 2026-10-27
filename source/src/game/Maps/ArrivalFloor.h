#pragma once

// Arrival on a gameobject floor. Defined in ArrivalFloor.cpp.
//
// A building placed as a gameobject (a MAP_OBJECT WMO) is solid on the server
// from the moment its grid loads, because its model is in the map's dynamic
// tree. The client is slower. After a loading screen it applies gravity before
// it has loaded the building, so the player and the creatures inside drop: some
// a yard into the floor, some to the terrain under it. Seen in the Darnassus zoo
// (map 1), 2026-10-27.
//
// Three steps, all started when the client is in the world:
//
// - THE PLAYER IS HELD FIRST. When the arrival point is a gameobject floor, the
//   server sends the player's own client a heartbeat every ARRIVAL_HOLD_EVERY ms
//   for ARRIVAL_HOLD_MS: the client's current x, y and facing, with the arrival
//   floor's z. The hold ends early when the player walks or jumps. Because the
//   x and y are the client's own, a moving player is not pulled back.
//
// - THEN CORRECTED. For the rest of ARRIVAL_WATCH_MS the server checks
//   the player's reported position. If the player is below a gameobject floor
//   that was under them at arrival height, and does not stand on another
//   gameobject surface, they are put on that floor. The packet keeps the x, y
//   and facing the client reported, so only z changes. A load slower than the
//   hold, or a walk before the building loaded, ends here.
//
// - THE CREATURES ARE SENT AGAIN. At ARRIVAL_BEAT_*_MS each creature near the
//   player whose floor is a gameobject (and not terrain or a static WMO) is
//   lifted a hair and put back with NearTeleportTo. The client then draws it at
//   the server's z. Same method as HouseMgr::BeatCritters.
//
// Map 28 is skipped: HouseMgr has its own arrival handling there.

#include "Common.h"

class Map;
class Player;

namespace ArrivalFloor
{
    // The client has left a loading screen (CMSG_SET_ACTIVE_MOVER, the
    // worldport ack) or acked a near teleport.
    void Arm(Player* player);

    // Called from Map::Update.
    void Update(Map* map, uint32 diff);
}
