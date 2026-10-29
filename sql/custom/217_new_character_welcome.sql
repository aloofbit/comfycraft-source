-- ============================================================================
--  NEW CHARACTER WELCOME  (tw_char)
-- ============================================================================
--  Applied with:
--
--    Get-Content sql\custom\217_new_character_welcome.sql | `
--      DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_char
--
--  When the first character of an account ends its race intro, every player
--  gets one chat line: a message picked at random from welcome_message, with
--  {name} replaced by a clickable link to the character.
--
--  welcome_setting   id 1: the on/off switch.
--  welcome_message   the messages. Each one holds {name}.
--  welcome_account   one row for each account that had its first character.
--                    An account in here is never announced again. guid 0 is
--                    an account that already had characters when this file
--                    was applied.
--
--  The Broadcasts page on the website (/admin/broadcasts) writes the switch
--  and the messages. mangosd reads them when it sends, so a save needs no
--  console command. Bots and GM accounts never see the intro, so they are
--  never announced.
--
--  In tw_char and not tw_world: it is a setting of this realm, and content
--  moved between local and prod must not carry it.
--
--  mangosd probes information_schema before it reads, so a binary that meets
--  a database without these tables announces nothing.
--
--  Re-runnable: creates if missing, seeds the switch and the first message
--  only when absent, and adds every account that has characters now.

CREATE TABLE IF NOT EXISTS `welcome_setting` (
  `id`         TINYINT UNSIGNED NOT NULL,
  `enabled`    TINYINT UNSIGNED NOT NULL DEFAULT 1,
  `changed_at` DATETIME NULL,
  `changed_by` VARCHAR(32) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT IGNORE INTO `welcome_setting` (`id`, `enabled`) VALUES (1, 1);

CREATE TABLE IF NOT EXISTS `welcome_message` (
  `id`   INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `text` VARCHAR(200) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `welcome_message` (`text`)
SELECT 'New character {name} has begun their journey!' FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM `welcome_message`);

CREATE TABLE IF NOT EXISTS `welcome_account` (
  `account`     INT UNSIGNED NOT NULL,
  `guid`        INT UNSIGNED NOT NULL DEFAULT 0,
  `name`        VARCHAR(12) NOT NULL DEFAULT '',
  `welcomed_at` DATETIME NULL,
  PRIMARY KEY (`account`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- A deleted character keeps its account in deleteInfos_Account
-- (docs/ai/content/character-deletion.md), so both columns count.
INSERT IGNORE INTO `welcome_account` (`account`)
SELECT `account` FROM `characters` WHERE `account` > 0
UNION
SELECT `deleteInfos_Account` FROM `characters` WHERE `deleteInfos_Account` > 0;
