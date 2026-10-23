-- ============================================================================
--  DUNGEON TUNING  (tw_char)
-- ============================================================================
--  Applied with:
--
--    Get-Content sql\custom\190_dungeon_tuning.sql | `
--      DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_char
--
--  A health percentage and a damage percentage for the creatures of 5 and 10
--  player dungeons (map_type 1). 100 is stock. dungeon_tuning holds the pair
--  for every dungeon; dungeon_tuning_map holds a dungeon's own pair.
--  Raids, battlegrounds, the open world and the housing map (28) are left
--  alone, and so are pets, totems and anything a player owns. It does not
--  follow the group size: every group meets the same values.
--
--  Health and melee damage are set when a creature spawns, so a change reaches
--  a dungeon at its next reset or respawn. Spell damage is read at each cast.
--  The values multiply with each creature's own (creature_template.dmg_multiplier
--  and the Rate.Creature.* conf keys).
--
--  mangosd reads both tables at startup and on the console command
--  `dungeontuning`. The Dungeon tuning page on the website
--  (/admin/dungeontuning) writes them and sends that command.
--  `dungeontuning <health> <damage>` in the console writes the pair for every
--  dungeon.
--
--  In tw_char and not tw_world: it is a setting of this realm, and content
--  moved between local and prod must not carry it.
--
--  mangosd probes information_schema before it reads, so a binary that meets
--  a database without this table runs at stock.
--
--  Re-runnable: creates if missing and never touches the row.

CREATE TABLE IF NOT EXISTS `dungeon_tuning` (
  `id`         TINYINT UNSIGNED NOT NULL,
  `health_pct` SMALLINT UNSIGNED NOT NULL DEFAULT 100,
  `damage_pct` SMALLINT UNSIGNED NOT NULL DEFAULT 100,
  `changed_at` DATETIME NULL,
  `changed_by` VARCHAR(32) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT IGNORE INTO `dungeon_tuning` (`id`, `health_pct`, `damage_pct`) VALUES (1, 100, 100);

-- A dungeon's own pair, in place of the one above. No row: the dungeon takes
-- the pair for every dungeon. map_id is map_template.entry (36 is Deadmines).
CREATE TABLE IF NOT EXISTS `dungeon_tuning_map` (
  `map_id`     SMALLINT UNSIGNED NOT NULL,
  `health_pct` SMALLINT UNSIGNED NOT NULL DEFAULT 100,
  `damage_pct` SMALLINT UNSIGNED NOT NULL DEFAULT 100,
  `changed_at` DATETIME NULL,
  `changed_by` VARCHAR(32) NOT NULL DEFAULT '',
  PRIMARY KEY (`map_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
