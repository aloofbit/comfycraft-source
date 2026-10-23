-- ============================================================================
--  LOOT RATES: WORN GEAR  (tw_char)
-- ============================================================================
--  Applied with:
--
--    Get-Content sql\custom\192_loot_rates_worn_gear.sql | `
--      DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_char
--
--  Apply after 183_loot_rates.sql. mangosd probes worn_gear before it reads
--  it, and without it uses the conf key Rate.Drop.Item.WornGear (default 5).
--
--    worn_gear  the chance in percent, for each item, that a mob drops the
--               armour it wears: the rows of loot group 40
--               (191_worn_gear_drops.sql, LootRates::WornGearGroup)
--
--  It is a chance and not a multiplier: each group 40 row rolls at it in
--  place of its table chance. A kill gives one group 40 item at most.
--
--  Re-runnable: adds the column if it is missing and never touches its value.

ALTER TABLE `loot_rates`
  ADD COLUMN IF NOT EXISTS `worn_gear` FLOAT NOT NULL DEFAULT 5 AFTER `rare_gear_endgame`;
