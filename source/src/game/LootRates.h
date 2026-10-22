#pragma once

// The drop rates for gear: multipliers on the table chance. Defined in
// LootMgr.cpp, which has the rules (IsGreenGear, IsRareWorldGear).
//
// - Green: green weapons and armour.
// - Rare: blue weapons and armour that bind on equip, from a row under 5%,
//   below required level 50.
// - Rare endgame: the same from required level 50.
//
// The rates are tw_char.loot_rates, id 1 (sql/custom/183_loot_rates.sql),
// read at startup and on the console command `lootrates`. Without the table
// they come from mangosd.conf (Rate.Drop.Item.UncommonGear, .RareGear and
// .RareGear.Endgame), re-read at each Load.

#include "Common.h"

namespace LootRates
{
    // Re-reads the row, or the conf keys when the table is missing. Returns
    // true when the row was read.
    bool Load();

    float Green();
    float Rare(bool endgame);
}
