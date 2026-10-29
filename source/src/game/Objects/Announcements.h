#pragma once

// Chat lines every player gets about another player. Defined in
// MiscHandler.cpp, beside HandleCompleteCinematic.
//
// The new character welcome: when the first character of an account ends its
// race intro (sql/custom/217_new_character_welcome.sql). The client sends
// CMSG_COMPLETE_CINEMATIC at the end of every cinematic, and a camera
// gameobject plays one too, so the intro is marked when the login starts it.
//
// Level announcements: when a character reaches, by XP, a level that has a
// row in tw_char.level_announce (sql/custom/218_level_announcements.sql).
// .setlevel and .levelup do not announce.
//
// Dungeon records: a ranked time that beats every ranked time before it for
// that dungeon or wing, by the rules of the /charts board. Housewarming: a
// player claims a house at a door. Both are in announce_setting and
// announce_message (sql/custom/219_record_and_house_announcements.sql).
//
// Bots are never announced. The welcome leaves out GM accounts (they get no
// intro), and a dungeon record leaves them out of the group as the board
// does; levels and housewarming leave out only a GM in GM mode. The switches
// and messages are in tw_char, read when the line is sent.

#include "Common.h"

#include <string>
#include <vector>

class Player;

struct AnnounceRecordPlayer
{
    std::string name;
    uint8 cls;
};

// A dungeon run that just killed its last boss or finished its full run.
struct AnnounceDungeonClear
{
    uint32 runId = 0;            // dungeon_run.id; this run is left out of the compare
    uint32 mapId = 0;
    uint8 wing = 0;
    std::string dungeon;         // with the wing, "Scarlet Monastery (Library)"
    uint32 lastMs = 0;           // 0: no ranked last-boss time at this kill
    uint32 fullMs = 0;           // 0: no ranked full-run time at this kill
    std::string lastClock;       // the times as the run timer writes them
    std::string fullClock;
    std::vector<AnnounceRecordPlayer> players;   // no bots, no GM accounts
};

namespace Announce
{
    // The race intro started for this character, on its first login.
    void IntroStarted(Player* player);

    // A cinematic ended. When it is the intro, queues the welcome.
    void CinematicEnded(Player* player);

    // The character reached a new level by XP. Queues the announcement for
    // that level, if it has one.
    void LevelReached(Player* player);

    // A run killed its last boss or finished. Queues the record check.
    void DungeonCleared(AnnounceDungeonClear clear);

    // The player claimed a house.
    void HouseClaimed(Player* player);
}
