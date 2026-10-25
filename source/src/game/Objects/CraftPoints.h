#pragma once

// Craft points: the skill points one craft gives. Stock is 1 for each
// successful craft (SkillGain.Crafting). A recipe with a row in
// tw_char.craft_points gives its `points` in place of that 1, and its
// `green_points` while the recipe is green. The recipe colour still sets the
// chance of a gain. The table is sql/custom/200_craft_points.sql.
//
// The website's Craft points page applies one rule for each profession and
// writes the result, so the core only looks up a spell.
//
// Defined in Player.cpp, beside UpdateCraftSkill.

#include "Common.h"

namespace CraftPoints
{
    // The points for this recipe, 1 when it has no row. green: the recipe is
    // green for the crafter.
    uint32 Points(uint32 spellId, bool green);

    // How many recipes have a row.
    uint32 Count();

    // Re-reads craft_points. False when the table is missing.
    bool Load();

    // The most points the core gives from one craft, whatever the table says.
    uint32 const MaxPoints = 10;
}
