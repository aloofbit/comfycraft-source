-- ============================================================================
--  LOOT RATES: THE GEAR RATES IN DUNGEONS  (tw_char)
-- ============================================================================
--  Applied with:
--
--    Get-Content sql\custom\186_loot_rates_dungeon.sql | `
--      DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_char
--
--  Apply after 183_loot_rates.sql. mangosd probes rare_gear_dungeon before it
--  reads the two columns, and without it uses the conf keys
--  Rate.Drop.Item.UncommonGear.Dungeon and .RareGear.Dungeon.
--
--  In a 5 or 10 player dungeon (map_type 1):
--
--    uncommon_gear_dungeon  replaces uncommon_gear for green weapons and armour
--    rare_gear_dungeon      replaces rare_gear for BoE blue world drops below
--                           required level 50
--
--  Raids and the open world keep uncommon_gear and rare_gear.
--  rare_gear_endgame applies everywhere.
--
--  Dungeon trash has more green gear in its tables than open world mobs:
--  Deadmines trash gives about 10% a kill at stock, open world mobs of the
--  same level 3%. At 0.8 a Deadmines clear gives about 20 green gear: 13
--  from trash, 7 from the bosses, whose own groups take no rate.
--  rare_gear_dungeon 2 gives Deadmines about 0.43 BoE blues a clear.
--
--  Re-runnable: adds the columns if they are missing and never touches their
--  values.

ALTER TABLE `loot_rates`
  ADD COLUMN IF NOT EXISTS `uncommon_gear_dungeon` FLOAT NOT NULL DEFAULT 0.8 AFTER `uncommon_gear`,
  ADD COLUMN IF NOT EXISTS `rare_gear_dungeon` FLOAT NOT NULL DEFAULT 2 AFTER `rare_gear`;
