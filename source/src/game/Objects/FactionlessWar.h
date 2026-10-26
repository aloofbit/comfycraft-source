#pragma once

// Factionless war: quest mobs that stay at war. Factionless.PeaceFactions
// lifts every race to Friendly with the other side's factions, and that made
// the other side's quest mobs friendly too (the Hillsbrad militia, Kul Tiras
// at Tiragarde, Kalman Azureborn). A creature in
// tw_world.factionless_war_creature is hostile to a player who has a quest
// against it in the log, and friendly to everyone else. The table is
// sql/custom/205_factionless_war_creatures.sql.
//
// The war follows the quest, not the race, so every race can take every
// quest: a Horde player can still hand in to Deckmaster Darkhollow, and an
// Alliance player who takes Cutting Ranks can kill him.
//
// Defined in Object.cpp, beside GetReactionTo.

#include "Common.h"

class Creature;
class Player;
class WorldObject;

namespace FactionlessWar
{
    // The template a viewer at war is sent in place of the creature's own:
    // Monster. The client resolves its reaction from the template alone, so
    // it draws the creature red and allows the attack.
    uint32 const ViewerFactionTemplate = 14;

    // Reads factionless_war_creature and finds the quests against those
    // creatures. Run after the quests, creature templates and factions load.
    // False when the table is missing.
    bool Load();

    // True when target is a listed creature and player has a quest against
    // it in the log, not yet handed in. A companion counts its owner's log.
    // False while Factionless.Enable is off.
    bool AtWar(Player const* player, WorldObject const* target);

    // True when the creature is listed, or was summoned by a listed creature.
    // Player::UpdateForQuestWorldObjects resends the faction field of these
    // when the quest log changes.
    bool IsWarCreature(Creature const* creature);

    uint32 CreatureCount();
    uint32 QuestCount();
    uint32 CampCount();
}
