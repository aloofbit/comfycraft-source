-- ============================================================================
--  Where a bot NPC stands  (tw_char)
-- ============================================================================
--  Applied with:
--
--    Get-Content sql\custom\085_bot_npc_position.sql | `
--      DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_char
--
--  APPLY BEFORE THE BINARY THAT READS IT. BotNpcMgr::Load selects these columns
--  during World::SetInitialWorldSettings and a missing column is a failed query,
--  which on this core is an assert and a crash dump rather than a warning.
--
--  WHY A POSITION AT ALL. An NPC stands somewhere; that is most of what makes it
--  an NPC rather than a character. Without this, a bot NPC logged in wherever it
--  last logged out -- which for a character conscripted into the job is an
--  arbitrary spot, usually not where anyone put it. `.npcbot add` was unusable
--  as a result: you ran it, nothing appeared, and the only way to find the thing
--  was `.summon`.
--
--  APPLIED AT LOGIN, NOT BY TELEPORTING. Player::LoadFromDB overrides the saved
--  coordinates with these before the map and instance are resolved, so the bot
--  arrives at its post directly. A teleport after the fact would work too and be
--  worse: the bot would exist at the wrong place first, visibly, and every
--  restart would show it.
--
--  SO THE SAVED POSITION IN `characters` IS NOW IGNORED for a bot NPC, and that
--  is deliberate -- it means one can be nudged about by an admin, log out, and
--  still come back on its mark. `.npcbot move` is how the mark itself changes.
--
--  Re-runnable: each ADD COLUMN is guarded, because ALTER TABLE has no
--  IF NOT EXISTS for columns on this MariaDB and re-running a bare ADD is an
--  error that would abort the rest of the file.
-- ============================================================================

DELIMITER $$

DROP PROCEDURE IF EXISTS `add_bot_npc_position` $$
CREATE PROCEDURE `add_bot_npc_position`()
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS
                   WHERE TABLE_SCHEMA = DATABASE()
                     AND TABLE_NAME = 'bot_npc'
                     AND COLUMN_NAME = 'map') THEN
        ALTER TABLE `bot_npc`
            ADD COLUMN `map`         SMALLINT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'where it stands -- NOT characters.map, which is ignored for a bot NPC' AFTER `gossip_menu_id`,
            ADD COLUMN `position_x`  FLOAT             NOT NULL DEFAULT 0 AFTER `map`,
            ADD COLUMN `position_y`  FLOAT             NOT NULL DEFAULT 0 AFTER `position_x`,
            ADD COLUMN `position_z`  FLOAT             NOT NULL DEFAULT 0 AFTER `position_y`,
            ADD COLUMN `orientation` FLOAT             NOT NULL DEFAULT 0 AFTER `position_z`;
    END IF;
END $$

DELIMITER ;

CALL `add_bot_npc_position`();
DROP PROCEDURE `add_bot_npc_position`;

-- The demo NPC from 084 predates this column and would otherwise stand at
-- 0,0,0 on map 0 -- which is in the sea off Westfall, and a long swim. Put it
-- somewhere a person can walk to. `.npcbot move` overwrites this the moment
-- anybody uses it.
UPDATE `bot_npc` SET `map` = 0, `position_x` = -8451.59, `position_y` = 321.618, `position_z` = 120.886, `orientation` = 0
 WHERE `guid` = 4644 AND `position_x` = 0 AND `position_y` = 0;
