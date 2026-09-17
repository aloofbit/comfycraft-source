-- ============================================================================
--  Bot NPCs become designs  (tw_char  -- NOT tw_world, unlike most of this folder)
-- ============================================================================
--  Applied with:
--
--    Get-Content sql\custom\086_bot_npc_designs.sql | `
--      DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_char
--
--  APPLY BEFORE THE BINARY THAT READS IT. BotNpcMgr::Load selects these columns
--  during World::SetInitialWorldSettings, and a missing column is a failed
--  query, which on this core asserts and writes a crash dump.
--
--  WHAT CHANGED AND WHY. 083 keyed this table on a CHARACTER GUID, because at
--  the time a bot NPC was always made from a character that already existed --
--  `.npcbot add <one of your alts>`. That is a fine way to test an idea and a
--  poor way to build a world: it means you cannot design an NPC at all until
--  you have first gone and made a character by hand, of the right race, with
--  the right name.
--
--  So the row is now the DESIGN, and the character is something the design
--  acquires later:
--
--      id              what the website edits
--      name            the character name to create, or the one created
--      race, gender    FIXED. Chosen here because they cannot be dressed on.
--      look            the dressing room's own query string, as web_fashion
--      gossip_menu_id  what it says
--      character_guid  0 until `.npcbot place` makes one
--      map, position_* where it stands, once placed
--
--  THE TWO-STATE THING IS THE DESIGN, not an unfinished half of it. A character
--  can only safely be created by the server -- guids are reused and this repo
--  has been bitten three times by rows outliving the character they named -- and
--  placing one needs a person standing where it should go. So the website owns
--  the parts that are decisions (name, race, look, words) and the game owns the
--  parts that are allocations (the character, the spot).
--
--  RACE AND GENDER LIVE HERE rather than being read off the character, and that
--  is what makes the dressing room able to open "for this NPC" with the race
--  locked. A look and a character have to have been drawn for each other; fixing
--  the race at design time is what stops that mismatch existing at all.
--
--  RE-RUNNABLE, AND THE FIRST VERSION WAS NOT -- which cost the one row it was
--  written to carry. It did `CREATE TABLE bot_npc_old LIKE bot_npc` and then
--  rebuilt bot_npc; run once that is correct, run twice and bot_npc_old is made
--  from the NEW shape, so the carry-across selects a `guid` column that no
--  longer exists, fails, and leaves an empty table behind. A migration that is
--  destructive on its second run is a migration that will be destructive,
--  because re-running one is how you check it worked.
--
--  So the old shape is detected rather than assumed: `guid` was the old primary
--  key and the new table has no such column, which makes its presence an exact
--  test for "this has not been migrated yet". Second run: nothing matches,
--  nothing is renamed, CREATE TABLE IF NOT EXISTS does nothing, and the data
--  sits untouched.
-- ============================================================================

-- Any leftover from a previous interrupted run. Real data is only ever in here
-- for the few statements between the rename and the carry-across below.
DROP TABLE IF EXISTS `bot_npc_old`;

DELIMITER $$

DROP PROCEDURE IF EXISTS `bot_npc_stash_old` $$
CREATE PROCEDURE `bot_npc_stash_old`()
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.COLUMNS
               WHERE TABLE_SCHEMA = DATABASE()
                 AND TABLE_NAME = 'bot_npc'
                 AND COLUMN_NAME = 'guid') THEN
        RENAME TABLE `bot_npc` TO `bot_npc_old`;
    END IF;
END $$

DELIMITER ;

CALL `bot_npc_stash_old`();
DROP PROCEDURE `bot_npc_stash_old`;

CREATE TABLE IF NOT EXISTS `bot_npc` (
  `id`             INT UNSIGNED       NOT NULL AUTO_INCREMENT,
  -- MAX_PLAYER_NAME is 12 (ObjectMgr.h:502). A longer one could never become a
  -- character, so it is refused at the width rather than at placement time.
  `name`           VARCHAR(12)        NOT NULL DEFAULT '' COMMENT 'the character name to create, or the one created',
  `race`           TINYINT UNSIGNED   NOT NULL DEFAULT 1  COMMENT 'ChrRaces. Fixed at design time -- race cannot be dressed on',
  `gender`         TINYINT UNSIGNED   NOT NULL DEFAULT 0  COMMENT '0 male, 1 female. Fixed for the same reason',
  `look`           VARCHAR(600)       NOT NULL DEFAULT '' COMMENT "the dressing room's query string, same spelling as tw_web.web_fashion.look",
  `gossip_menu_id` MEDIUMINT UNSIGNED NOT NULL DEFAULT 0  COMMENT 'tw_world.gossip_menu.entry. 0 = flagged but says nothing',
  `npc_flags`      INT UNSIGNED       NOT NULL DEFAULT 1  COMMENT 'UNIT_NPC_FLAGS. 1 = gossip',
  -- 0 means DESIGNED BUT NOT PLACED. Not NULL, because every read of it is a
  -- comparison and a NULL would quietly answer false to all of them.
  `character_guid` INT UNSIGNED       NOT NULL DEFAULT 0  COMMENT 'characters.guid once placed; 0 while it is only a design',
  `map`            SMALLINT UNSIGNED  NOT NULL DEFAULT 0,
  `position_x`     FLOAT              NOT NULL DEFAULT 0,
  `position_y`     FLOAT              NOT NULL DEFAULT 0,
  `position_z`     FLOAT              NOT NULL DEFAULT 0,
  `orientation`    FLOAT              NOT NULL DEFAULT 0,
  `comment`        VARCHAR(255)       NOT NULL DEFAULT '',
  `created_at`     DATETIME           NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  -- A PLAIN KEY, NOT UNIQUE, and the reason is the 0. "One design per
  -- character" is the rule, but 0 means "not placed yet" and MyISAM counts 0 as
  -- a value like any other -- so a UNIQUE here would let exactly ONE design be
  -- unplaced at a time, and the second one anybody drew would be refused by the
  -- database with no explanation that made sense. NULL would have allowed
  -- repeats, at the cost of an IS NULL in every read on both sides.
  --
  -- So uniqueness is enforced where placement happens, which is the only place
  -- that can set a real guid, and this index is here for the lookup.
  KEY `character_guid` (`character_guid`),
  -- Names are how a person refers to one, and a duplicate could never be
  -- placed twice anyway: `characters`.name is unique.
  UNIQUE KEY `name` (`name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='Bot NPC designs. The website edits these; the game places them';

-- The old rows, if there were any. A design's name, race and gender come off
-- the character it was bound to, because in the old shape that WAS the design:
-- there was no way to say a bot NPC was a female orc except by pointing at one.
DELIMITER $$

DROP PROCEDURE IF EXISTS `bot_npc_carry_old` $$
CREATE PROCEDURE `bot_npc_carry_old`()
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.TABLES
               WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'bot_npc_old') THEN

        INSERT INTO `bot_npc`
          (`name`, `race`, `gender`, `gossip_menu_id`, `npc_flags`, `character_guid`,
           `map`, `position_x`, `position_y`, `position_z`, `orientation`, `comment`)
        SELECT COALESCE(c.`name`, CONCAT('guid', o.`guid`)),
               COALESCE(c.`race`, 1), COALESCE(c.`gender`, 0),
               o.`gossip_menu_id`, o.`npc_flags`, o.`guid`,
               o.`map`, o.`position_x`, o.`position_y`, o.`position_z`, o.`orientation`, o.`comment`
          FROM `bot_npc_old` o
          LEFT JOIN `characters` c ON c.`guid` = o.`guid`;

        DROP TABLE `bot_npc_old`;
    END IF;
END $$

DELIMITER ;

CALL `bot_npc_carry_old`();
DROP PROCEDURE `bot_npc_carry_old`;
