-- ============================================================================
--  Sweep bot value-store rows whose character no longer exists  (tw_char)
-- ============================================================================
--    Get-Content sql\custom\070_orphan_bot_value_store.sql | `
--      DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_char
--
--  WHY. The companion of 067, for the one table it did not cover.
--  `ai_playerbot_random_bots` is the playerbot module's per-bot value store,
--  keyed by character low guid -- and guids are REUSED, so a dismissed
--  companion's rows are inherited by the next hire handed the same number.
--
--  This one does not crash; it lies, which took longer to notice. The row that
--  matters is `specNo`:
--
--      ChangeTalentsAction::AutoSelectTalents
--          uint32 specNo = GetValue(guid, "specNo");
--          if (specNo > 0)   // continue the current spec
--              ...applies it, and never looks at the requested role...
--
--  So a companion hired AS A TANK came back fury, because the guid's previous
--  occupant was fury. Measured 2026-09-07 on guid 4645: the character was
--  created at 00:42 and the value store still held login/update/randomize rows
--  stamped 17:43 the day before, plus specNo = 1 -- which is
--  AiPlayerbot.PremadeSpecName.1.0 = fury, where protection is 1.1.
--
--  Two things kept it alive. specNo and specLink are exempt from expiry on
--  purpose (RandomPlayerbotMgr::SetEventValue), so they never age out; and the
--  only sweep, in RandomPlayerbotFactory, runs at STARTUP, so anything dismissed
--  mid-session survives until the next restart. 233 rows across 59 dead guids
--  had accumulated when this was written, 36 of them specNo.
--
--  PlayerbotMgr::DeleteBot now purges the store as part of deleting a character,
--  so this file is for the debris already there.
--
--  SAFE TO RE-RUN, and safe with the server up: it deletes only rows with no
--  matching `characters` row. A live bot's own rows cannot be touched.
--
--  `bot = 0` IS EXCLUDED ON PURPOSE. That guid is not a character - it is where
--  the module keeps its global values (`bot_count` is the one here), and it
--  matches "no such character" trivially. The core's own startup sweep does not
--  exclude it and deletes it every restart; there is no need to copy that.
-- ============================================================================

SELECT COUNT(*) AS `rows_before`, COUNT(DISTINCT bot) AS `dead_guids_before`
FROM `ai_playerbot_random_bots`
WHERE `bot` <> 0 AND `bot` NOT IN (SELECT `guid` FROM `characters`);

DELETE FROM `ai_playerbot_random_bots`
WHERE `bot` <> 0 AND `bot` NOT IN (SELECT `guid` FROM `characters`);

SELECT COUNT(*) AS `rows_after`
FROM `ai_playerbot_random_bots`
WHERE `bot` <> 0 AND `bot` NOT IN (SELECT `guid` FROM `characters`);
