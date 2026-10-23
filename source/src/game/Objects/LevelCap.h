#pragma once

// The server's level cap: the highest level XP can take a character to, read
// from tw_char.level_cap (sql/custom/134_level_cap.sql). It sits under
// MaxPlayerLevel, which sizes the level stat tables at startup and so cannot
// change while the server runs. The cap can.
//
// It stops XP. A character above the cap keeps its level. A quest at the cap
// pays gold in place of XP (QuestMoney). Defined in Player.cpp, beside GiveXP.

#include "Common.h"

class Quest;

namespace LevelCap
{
    // The highest quest gold percent the setting takes.
    uint32 const QUEST_GOLD_MAX = 1000;

    // The cap, or MaxPlayerLevel when there is none.
    uint32 Get();

    // Re-reads the row. Returns the stored cap, 0 for none.
    uint32 Load();

    // Writes the row and applies it at once. 0 is no cap. False when the
    // table is missing.
    bool Set(uint32 level, char const* changedBy);

    // The quest gold percent (sql/custom/195_level_cap_quest_gold.sql).
    uint32 QuestGold();

    // Writes the percent and applies it at once. False when the column is
    // missing.
    bool SetQuestGold(uint32 percent, char const* changedBy);

    // The gold a quest pays in place of XP to a character at the cap. At
    // MaxPlayerLevel it is the full max-level gold. Below, it is that gold
    // times (quest level / MaxPlayerLevel) squared, times QuestGold() / 100.
    int32 QuestMoney(Quest const* quest, uint32 playerLevel);
}
