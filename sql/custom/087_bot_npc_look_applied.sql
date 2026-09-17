-- ============================================================================
--  Remember which outfit a bot NPC is already wearing  (tw_char)
-- ============================================================================
--  Applied with:
--
--    Get-Content sql\custom\087_bot_npc_look_applied.sql | `
--      DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_char
--
--  APPLY BEFORE THE BINARY THAT READS IT. BotNpcMgr::Load selects this column
--  during World::SetInitialWorldSettings and a missing column is a failed
--  query, which on this core asserts and writes a crash dump.
--
--  WHY. A bot NPC's outfit is saved on the character like anybody else's, so a
--  restart needs no dressing at all. The one case that DOES is a look changed
--  on the website while the NPC was logged out: nothing was there to dress at
--  the time, and nothing looked afterwards, so it stood back up in last week's
--  coat while the website showed the new one.
--
--  The obvious fix -- dress on every login -- leaked items badly. The bot is
--  reachable before its inventory is populated, so every slot read EMPTY, the
--  whole outfit was re-equipped from scratch, and the previous eight items were
--  left orphaned in `item_instance`. Forty had piled up on one NPC in an
--  afternoon. Worse, "all slots empty" cannot be told apart from "not loaded
--  yet" by looking at the slots, so no amount of inspecting the character
--  answers the question.
--
--  SO STOP ASKING THE CHARACTER AND ASK THE ROW. `look_applied` is the outfit
--  that was last actually put on. Dressing is skipped outright while it equals
--  `look`, which is the normal case on every login and every reload, and runs
--  exactly once when the website changes the design. No inventory inspection,
--  no timing question, no leak.
--
--  Re-runnable: the ADD is guarded, because ALTER TABLE has no IF NOT EXISTS
--  for columns on this MariaDB and a bare re-run is an error that aborts the
--  rest of the file.
-- ============================================================================

DELIMITER $$

DROP PROCEDURE IF EXISTS `add_bot_npc_look_applied` $$
CREATE PROCEDURE `add_bot_npc_look_applied`()
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS
                   WHERE TABLE_SCHEMA = DATABASE()
                     AND TABLE_NAME = 'bot_npc'
                     AND COLUMN_NAME = 'look_applied') THEN
        ALTER TABLE `bot_npc`
            ADD COLUMN `look_applied` VARCHAR(600) NOT NULL DEFAULT ''
                COMMENT 'the outfit actually on the character; dressing is skipped while it equals look'
                AFTER `look`;
    END IF;
END $$

DELIMITER ;

CALL `add_bot_npc_look_applied`();
DROP PROCEDURE `add_bot_npc_look_applied`;

-- Anything already placed is already wearing its look -- that is how it got
-- here. Saying so stops one pointless re-dress per existing NPC on the next
-- startup, which would be one more set of orphans each.
UPDATE `bot_npc` SET `look_applied` = `look`
 WHERE `character_guid` <> 0 AND `look` <> '' AND `look_applied` = '';
