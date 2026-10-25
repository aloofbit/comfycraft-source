#pragma once

// Factionless war: quest mobs that stay at war. Factionless.PeaceFactions
// lifts every race to Friendly with the other side's factions, and that made
// the other side's quest mobs friendly too (the Hillsbrad militia, Kul Tiras
// at Tiragarde, Kalman Azureborn). A creature in
// tw_world.factionless_war_creature keeps the stock war: it is hostile to a
// race born at war with its faction, and friendly to the rest. The table is
// sql/custom/205_factionless_war_creatures.sql.
//
// A quest with a race gate against one of these creatures keeps its stock
// gate (Quest::SatisfiesRaceRequirements), so the other side is not offered
// a quest it cannot finish.
//
// Defined in Object.cpp, beside GetReactionTo.

#include "Common.h"

class Player;
class WorldObject;

namespace FactionlessWar
{
    // The template a viewer at war is sent in place of the creature's own:
    // Monster. The client resolves its reaction from the template alone, so
    // it draws the creature red and allows the attack.
    uint32 const ViewerFactionTemplate = 14;

    // Reads factionless_war_creature and marks the quests against those
    // creatures. Run after the quests, creature templates and factions load.
    // False when the table is missing.
    bool Load();

    // True when target is a listed creature and player's race is born at war
    // with the creature's current faction. False while Factionless.Enable is off.
    bool AtWar(Player const* player, WorldObject const* target);

    // True when the quest keeps its stock race gate.
    bool IsGatedQuest(uint32 questId);

    uint32 CreatureCount();
    uint32 QuestCount();
}
