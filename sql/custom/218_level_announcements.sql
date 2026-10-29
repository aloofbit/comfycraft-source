-- ============================================================================
--  LEVEL ANNOUNCEMENTS  (tw_char)
-- ============================================================================
--  Applied with:
--
--    Get-Content sql\custom\218_level_announcements.sql | `
--      DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_char
--
--  When a character reaches a level by XP, and that level has a row in
--  level_announce, every player gets one chat line. {name} becomes a link to
--  the character in its class colour, {level} the level. With more than one
--  row for a level, one is picked at random. A level with no row sends
--  nothing.
--
--  level_announce_setting   id 1: the on/off switch.
--  level_announce           a level and its message.
--
--  The Level announcements page on the website (/admin/levelannounce) writes
--  both. mangosd reads them when it sends, so a save needs no console
--  command. Bots, a GM in GM mode, .setlevel and .levelup are never announced.
--
--  In tw_char beside the new character welcome (217), for the same reason.
--  mangosd probes information_schema before it reads, so a binary that meets
--  a database without these tables announces nothing.
--
--  Re-runnable: creates if missing, and seeds the switch and the levels 5 to
--  60 only when absent.

CREATE TABLE IF NOT EXISTS `level_announce_setting` (
  `id`         TINYINT UNSIGNED NOT NULL,
  `enabled`    TINYINT UNSIGNED NOT NULL DEFAULT 1,
  `changed_at` DATETIME NULL,
  `changed_by` VARCHAR(32) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT IGNORE INTO `level_announce_setting` (`id`, `enabled`) VALUES (1, 1);

CREATE TABLE IF NOT EXISTS `level_announce` (
  `id`    INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `level` TINYINT UNSIGNED NOT NULL,
  `text`  VARCHAR(200) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `level` (`level`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `level_announce` (`level`, `text`)
SELECT l.`level`, '{name} has reached level {level}!'
  FROM (SELECT 5 AS `level` UNION SELECT 10 UNION SELECT 15 UNION SELECT 20
        UNION SELECT 25 UNION SELECT 30 UNION SELECT 35 UNION SELECT 40
        UNION SELECT 45 UNION SELECT 50 UNION SELECT 55 UNION SELECT 60) l
 WHERE NOT EXISTS (SELECT 1 FROM `level_announce`);
