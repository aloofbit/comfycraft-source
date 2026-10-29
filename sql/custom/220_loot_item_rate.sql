-- ============================================================================
--  LOOT ITEM RATE: THE DROP RATE OF ONE ITEM  (tw_char)
-- ============================================================================
--  Applied with:
--
--    Get-Content sql\custom\220_loot_item_rate.sql | `
--      DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_char
--
--  then, in the mangosd console:  lootrates
--
--  A multiplier on one item's table chance, for crafting materials that a
--  small realm without a busy auction house cannot get. It applies in every
--  loot table that takes rates (kills, skinning, objects, fishing,
--  pickpocket, containers), grouped or not, and in a dungeon boss's groups.
--  It replaces the quality and gear rates for that item. Quest drops keep
--  their chance. In a loot group the other entries are scaled back so the
--  group does not pass 100% (LootGroup::Roll in source/src/game/LootMgr.cpp).
--
--  mangosd reads the table at startup and on `lootrates`, after loot_rates.
--  The Drop rates page on the website (/admin/droprates) writes the rows and
--  sends that command. It also lists the materials worth a rate.
--
--  In tw_char and not tw_world, as loot_rates is: a setting of this realm.
--  mangosd probes information_schema before it reads, so a binary that meets
--  a database without this table runs without item rates.
--
--  Re-runnable: creates if missing, and adds the first row only when it is
--  not there.

CREATE TABLE IF NOT EXISTS `loot_item_rate` (
  `item`       INT UNSIGNED NOT NULL,
  `rate`       FLOAT NOT NULL DEFAULT 1,
  `changed_at` DATETIME NULL,
  `changed_by` VARCHAR(32) NOT NULL DEFAULT '',
  PRIMARY KEY (`item`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Perfect Deviate Scale (Wailing Caverns): 1% to 2% a kill, about 4% a skin.
INSERT IGNORE INTO `loot_item_rate` (`item`, `rate`, `changed_at`) VALUES (6471, 5, NOW());
