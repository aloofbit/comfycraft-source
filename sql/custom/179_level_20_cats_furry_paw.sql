-- ============================================================================
--  SMALL FURRY PAW FROM THE LEVEL 20-29 CATS  (tw_world)
-- ============================================================================
--  Applied with:
--
--    Get-Content sql\custom\179_level_20_cats_furry_paw.sql | `
--      DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_world
--
--  then `reload creature_loot_template` in the console.
--
--  Fashion Demands Sacrifices (60031, level 20) asks for 3 Small Furry Paw
--  (5134). Stock, the paw drops only from level 10-20 cats in Darkshore,
--  The Barrens and Frostmane Hollow, at 4-60%. These five cats now give it
--  at 50%: two in Eastern Kingdoms and three in Kalimdor.
--
--  Each loot table is used only by its own creature.
--
--  Re-runnable. To undo: the DELETE alone.

DELETE FROM creature_loot_template WHERE item = 5134 AND entry IN (
  2384,     -- Starving Mountain Lion  Hillsbrad Foothills, level 23-24
  2385,     -- Feral Mountain Lion     Hillsbrad Foothills, level 27-28
  4067,     -- Twilight Runner         Stonetalon Mountains, level 23-24
  4126,     -- Crag Stalker            Thousand Needles, level 25-26
  4124      -- Needles Cougar          Thousand Needles, level 27-28
);

INSERT INTO creature_loot_template (entry, item, ChanceOrQuestChance, groupid, mincountOrRef, maxcount, condition_id) VALUES
  (2384,    5134, 50, 0, 1, 1, 0),
  (2385,    5134, 50, 0, 1, 1, 0),
  (4067,    5134, 50, 0, 1, 1, 0),
  (4126,    5134, 50, 0, 1, 1, 0),
  (4124,    5134, 50, 0, 1, 1, 0);
