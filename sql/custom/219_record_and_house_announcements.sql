-- ============================================================================
--  DUNGEON RECORD AND HOUSEWARMING ANNOUNCEMENTS  (tw_char)
-- ============================================================================
--  Applied with:
--
--    Get-Content sql\custom\219_record_and_house_announcements.sql | `
--      DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_char
--
--  Two more chat lines every player gets, beside the welcome (217) and the
--  level announcements (218):
--
--  dungeon_record   A ranked dungeon time beats every ranked time before it,
--                   by the rules of the board on /charts. Messages of kind
--                   dungeon_last are for the last boss, dungeon_full for the
--                   full run. A kill that sets both sends dungeon_full.
--                   {group} is the players (no bots, no GM accounts) as
--                   links, {dungeon} the dungeon, {time} the time.
--  housewarming     A player claims a house at a door. {name} is the
--                   player as a link, {zone} the zone of the door.
--
--  announce_setting   one row for each feature: the on/off switch.
--  announce_message   the messages, by kind. One is picked at random.
--
--  The Dungeon records page (/admin/dungeonrecords) and the Housewarming page
--  (/admin/housewarming) on the website write both. mangosd reads them when
--  it sends, so a save needs no console command.
--
--  mangosd probes information_schema before it reads, so a binary that meets
--  a database without these tables announces nothing.
--
--  Re-runnable: creates if missing, and seeds a switch and a message for each
--  kind only when absent.

CREATE TABLE IF NOT EXISTS `announce_setting` (
  `kind`       VARCHAR(32) NOT NULL,
  `enabled`    TINYINT UNSIGNED NOT NULL DEFAULT 1,
  `changed_at` DATETIME NULL,
  `changed_by` VARCHAR(32) NOT NULL DEFAULT '',
  PRIMARY KEY (`kind`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT IGNORE INTO `announce_setting` (`kind`, `enabled`) VALUES
  ('dungeon_record', 1),
  ('housewarming', 1);

CREATE TABLE IF NOT EXISTS `announce_message` (
  `id`   INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `kind` VARCHAR(32) NOT NULL,
  `text` VARCHAR(200) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `kind` (`kind`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `announce_message` (`kind`, `text`)
SELECT 'dungeon_last', 'New record! {group} killed the last boss of {dungeon} in {time}.' FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM `announce_message` WHERE `kind` = 'dungeon_last');

INSERT INTO `announce_message` (`kind`, `text`)
SELECT 'dungeon_full', 'New record! {group} cleared all of {dungeon} in {time}.' FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM `announce_message` WHERE `kind` = 'dungeon_full');

INSERT INTO `announce_message` (`kind`, `text`)
SELECT 'housewarming', '{name} has moved into their new home!' FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM `announce_message` WHERE `kind` = 'housewarming');
