-- ============================================================================
--  LOOT RATES: THE GEAR DROP MULTIPLIERS  (tw_char)
-- ============================================================================
--  Applied with:
--
--    Get-Content sql\custom\183_loot_rates.sql | `
--      DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_char
--
--  The drop rates for gear, as multipliers on the table chance:
--
--    uncommon_gear      green weapons and armour
--    rare_gear          blue weapons and armour that bind on equip, from a row
--                       under 5% (the world drops), below required level 50
--    rare_gear_endgame  the same from required level 50
--
--  source/src/game/LootMgr.cpp has the rules. A dungeon boss's own loot groups
--  take none of them.
--
--  mangosd reads the row at startup and on the console command `lootrates`.
--  The Drop rates page on the website (/admin/droprates) writes the row and
--  sends that command. With the table missing, mangosd uses the keys
--  Rate.Drop.Item.UncommonGear, .RareGear and .RareGear.Endgame in
--  mangosd.conf.
--
--  In tw_char and not tw_world: it is a setting of this realm, and content
--  moved between local and prod must not carry it.
--
--  mangosd probes information_schema before it reads, so a binary that meets
--  a database without this table runs on the conf keys.
--
--  Re-runnable: creates if missing and never touches the row.

CREATE TABLE IF NOT EXISTS `loot_rates` (
  `id`                TINYINT UNSIGNED NOT NULL,
  `uncommon_gear`     FLOAT NOT NULL DEFAULT 3,
  `rare_gear`         FLOAT NOT NULL DEFAULT 5,
  `rare_gear_endgame` FLOAT NOT NULL DEFAULT 1,
  `changed_at`        DATETIME NULL,
  `changed_by`        VARCHAR(32) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT IGNORE INTO `loot_rates` (`id`, `uncommon_gear`, `rare_gear`, `rare_gear_endgame`) VALUES (1, 3, 5, 1);
