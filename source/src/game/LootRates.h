#pragma once

// The drop rates for gear: multipliers on the table chance. Defined in
// LootMgr.cpp, which has the rules (IsGreenGear, IsRareWorldGear).
//
// - Green: green weapons and armour.
// - Green in dungeons: the same in a 5 or 10 player dungeon, where trash
//   tables hold about three times the open world's green gear.
// - Rare: blue weapons and armour that bind on equip, from a row under 5%,
//   below required level 50.
// - Rare in dungeons: the same in a 5 or 10 player dungeon.
// - Rare endgame: the same from required level 50, everywhere.
//
// The rates are tw_char.loot_rates, id 1 (sql/custom/183_loot_rates.sql),
// read at startup and on the console command `lootrates`. Without the table
// they come from mangosd.conf (Rate.Drop.Item.UncommonGear, .UncommonGear.Dungeon,
// .RareGear, .RareGear.Dungeon and .RareGear.Endgame), re-read at each Load.

#include "Common.h"

namespace LootRates
{
    // The loot group of the worn gear drops (tools/gen-worn-gear-sql.js): the
    // armour a mob wears. Each of its rows rolls at WornGear() in place of its
    // table chance, and no other rate touches it.
    constexpr uint8 WornGearGroup = 40;

    // Re-reads the row, or the conf keys when the table is missing. Returns
    // true when the row was read.
    bool Load();

    float Green(bool dungeon);
    float Rare(bool endgame, bool dungeon);

    // A chance in percent, not a multiplier: loot_rates.worn_gear
    // (sql/custom/192), or Rate.Drop.Item.WornGear without the column.
    float WornGear();
}
