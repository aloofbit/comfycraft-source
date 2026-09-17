-- ============================================================================
--  A bot NPC can hand out quests  (tw_char)
-- ============================================================================
--  Applied with:
--
--    Get-Content sql\custom\099_bot_npc_quests.sql | `
--      DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_char
--
--  APPLY BEFORE THE BINARY THAT READS IT. Once BotNpcMgr::Load names this
--  column, a missing one is a failed query inside World::SetInitialWorldSettings,
--  and a failed query on this core asserts and writes a crash dump rather than
--  warning. 087 and 093 record the same rule; it has not stopped being true.
--
--  Safe to apply early either way: Load selects its columns by name, so a binary
--  that does not know about this one reads straight past it.
--
--  ------------------------------------------- WHAT THE NUMBER POINTS AT
--
--  An id in `creature_questrelation` and `creature_involvedrelation`, in the
--  block 210000-210999. NOT a creature entry -- a bot NPC has none, which is the
--  same reason its shop is an `npc_vendor_template` id rather than an
--  `npc_vendor` row.
--
--  REUSING THE TWO CREATURE TABLES IS THE POINT, and it was the alternative to
--  a bot-shaped pair of tables with a second set of maps in ObjectMgr. One
--  storage, one pair of reload commands, and one editor that does not care which
--  kind of thing it is linking. The cost is that the two relation loaders would
--  otherwise warn "data for nonexistent creature entry" once per row, so they
--  now skip the warning for ids inside the block and still warn for everything
--  outside it. That is what a reserved block buys: a typo'd creature entry is
--  still a typo, and a bot id is still deliberate.
--
--  0 hands out nothing, which is every bot NPC today. Several designs may share
--  one id, which is how two guards come to offer the same quest.
--
--  ---------------------------------------------------------------- RELOADS
--
--  `reload bot_npc` re-reads this table. The QUESTS themselves are world data
--  and reload separately, and the order is the one `npc_vendor` already taught
--  us -- `reload quest_template` FIRST, because LoadQuestRelationsHelper
--  validates every row against the cached quest map and drops the ones it does
--  not recognise, silently, one log line each:
--
--    reload quest_template
--    reload creature_questrelation
--    reload creature_involvedrelation
--    reload bot_npc
--
--  --------------------------------------------------------------- THE FLAG
--
--  A design also needs UNIT_NPC_FLAG_QUESTGIVER (bit 2) in `npc_flags`, exactly
--  as a creature does. Player::PrepareGossipMenu asks for the bit AND for a
--  non-zero quest_giver_id before it will build a quest list, so a half-linked
--  design shows nothing rather than an empty list.
--
--  Re-runnable: the ADD is guarded, because ALTER TABLE has no IF NOT EXISTS for
--  columns on this MariaDB and a bare re-run aborts the rest of the file.
-- ============================================================================

DELIMITER $$

DROP PROCEDURE IF EXISTS `add_bot_npc_quest_giver_id` $$
CREATE PROCEDURE `add_bot_npc_quest_giver_id`()
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS
                   WHERE TABLE_SCHEMA = DATABASE()
                     AND TABLE_NAME = 'bot_npc'
                     AND COLUMN_NAME = 'quest_giver_id') THEN
        ALTER TABLE `bot_npc`
            ADD COLUMN `quest_giver_id` MEDIUMINT(8) UNSIGNED NOT NULL DEFAULT 0
                COMMENT 'creature_questrelation.id in 210000-210999 -- the quests this NPC gives; 0 gives none'
                AFTER `vendor_template_id`;
    END IF;
END $$

DELIMITER ;

CALL `add_bot_npc_quest_giver_id`();
DROP PROCEDURE `add_bot_npc_quest_giver_id`;
