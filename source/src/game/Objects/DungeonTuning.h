#pragma once

// Dungeon tuning: a health percentage and a damage percentage for the
// creatures of 5 and 10 player dungeons. 100 is stock. One pair applies to
// every dungeon (tw_char.dungeon_tuning), and a dungeon can have its own pair
// in its place (tw_char.dungeon_tuning_map, by map id). Both tables are
// sql/custom/190_dungeon_tuning.sql.
//
// Raids, battlegrounds, the open world and the housing map are left alone,
// and so are pets, totems and anything a player owns.
//
// Health and melee damage are set when a creature spawns (SelectLevel), so a
// change reaches a dungeon at its next reset or respawn. Spell damage is read
// at each cast (SpellDamageBonusDone), so it applies at once.
//
// Defined in Creature.cpp, beside SelectLevel.

#include "Common.h"

class Creature;

namespace DungeonTuning
{
    // The pair for every dungeon, 100 for stock.
    uint32 HealthPct();
    uint32 DamagePct();

    // How many dungeons have their own pair.
    uint32 MapCount();

    // The multiplier for this creature: its dungeon's own pair, else the pair
    // for every dungeon, and 1 where tuning does not reach it.
    float HealthMod(Creature const* creature);
    float DamageMod(Creature const* creature);

    // Re-reads both tables. False when the tables are missing.
    bool Load();

    // Writes the pair for every dungeon and applies it. False when the table
    // is missing.
    bool Set(uint32 healthPct, uint32 damagePct, char const* changedBy);

    // The range the console and the website accept.
    uint32 const MinPct = 10;
    uint32 const MaxPct = 300;
}
