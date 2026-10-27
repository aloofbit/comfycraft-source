#pragma once

// A faction saved for one creature spawn. Defined in CreatureSpawnFaction.cpp.
//
// `.npc factionid` writes the template, so it changes every creature of that
// entry, and `.modify faction` is lost at the next respawn. `.npc savefaction`
// keeps a faction for one spawn in tw_world.creature_spawn_faction
// (sql/custom/211), keyed by the spawn guid alone, so a change of entry keeps it.
//
// Every place that puts a creature back on its template's faction asks
// GetFaction instead: Creature::UpdateEntry (create and respawn),
// Creature::ClearTemporaryFaction, and the escort and follower AIs.

#include "Common.h"

#include <shared_mutex>
#include <unordered_map>

class Creature;

class CreatureSpawnFaction
{
    public:
        // Called once at startup.
        void LoadFromDB();

        // The saved faction of this creature's spawn, else its template's.
        uint32 GetFaction(Creature const* creature) const;

        // 0 when the spawn has none.
        uint32 GetSaved(uint32 spawnGuid) const;

        void Save(uint32 spawnGuid, uint32 faction);
        void Remove(uint32 spawnGuid);

        // The spawn was deleted. Its row goes in Creature::DeleteFromDB's own
        // transaction; this drops the cached copy, so a new spawn on a reused
        // guid does not take it.
        void Forget(uint32 spawnGuid);

    private:
        mutable std::shared_mutex m_lock;
        std::unordered_map<uint32, uint32> m_factions;
};

extern CreatureSpawnFaction sCreatureSpawnFaction;
