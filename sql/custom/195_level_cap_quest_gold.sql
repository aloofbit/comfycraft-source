-- ============================================================================
--  LEVEL CAP: QUEST GOLD  (tw_char)
-- ============================================================================
--  Applied with:
--
--    Get-Content sql\custom\195_level_cap_quest_gold.sql | `
--      DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_char
--
--  Apply it BEFORE the binary that reads it. Needs 134_level_cap.sql.
--
--  A quest at the level cap pays no XP. It pays gold in its place: the quest's
--  max-level gold (RewMoneyMaxLevel) times (quest level / 60) squared, times
--  quest_gold / 100. 0 pays nothing. At 60 a quest pays the full max-level
--  gold, and this column does not change it.
--
--  At 100, averages per quest in copper (own gold / added gold):
--  level 1-9: 51 / 14, 10-19: 172 / 92, 20-29: 592 / 580, 30-39: 1003 / 2020,
--  40-49: 2324 / 4102.
--
--  A quest of level 0 takes the character's level. A quest above 60 counts
--  as 60.
--
--  The Workshop page on the website (/admin) writes the column and sends
--  `levelcap`. `levelcap gold <percent>` in the console writes it too.
--
--  Re-runnable: adds the column if missing and never touches its value.

ALTER TABLE `level_cap`
  ADD COLUMN IF NOT EXISTS `quest_gold` SMALLINT UNSIGNED NOT NULL DEFAULT 100 AFTER `level`;
