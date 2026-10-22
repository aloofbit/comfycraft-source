-- ============================================================================
--  SMALL LEATHER COLLAR FROM THE WESTFALL COYOTES  (tw_world)
-- ============================================================================
--  Applied with:
--
--    Get-Content sql\custom\175_westfall_coyote_collar.sql | `
--      DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_world
--
--  then `reload creature_loot_template` in the console.
--
--  Stock, the Small Leather Collar (4813) drops only from cats and a few
--  bears, at 5-25%. Westfall had no source. The two coyote loot tables now
--  give it at 45%. The rate is above the cats' rate because the coyotes are
--  spread out and a farm kills fewer of them each hour.
--
--  Loot tables 833 and 834 are used only by these two creatures.
--
--  Re-runnable. To undo: the DELETE alone.

DELETE FROM creature_loot_template WHERE item = 4813 AND entry IN (
  833,      -- Coyote Packleader       Westfall, level 11-12
  834       -- Coyote                  Westfall, level 10-11
);

INSERT INTO creature_loot_template (entry, item, ChanceOrQuestChance, groupid, mincountOrRef, maxcount, condition_id) VALUES
  (833,     4813, 45, 0, 1, 1, 0),
  (834,     4813, 45, 0, 1, 1, 0);
