#pragma once

// .soundlog: one chat line for each sound the server sends you, with its source.
// WorldSession::SendPacket hands every packet to OnSend, which returns at once
// while nobody has the log on. Only server-sent sounds show: a sound the client
// plays by itself (doodads, ambience, spell visuals, footsteps) never passes here.

#include "Common.h"
#include <atomic>

class WorldSession;
class WorldPacket;

namespace SoundLog
{
    extern std::atomic<uint32> sWatchers;

    inline bool Active() { return sWatchers.load(std::memory_order_relaxed) != 0; }
    void OnSend(WorldSession* session, WorldPacket const& packet);
}
