-- ============================================================================
--  VIOLET FERAL RAPTOR FROM LADY ANACONDRA AT 3%  (tw_world)
-- ============================================================================
--  Applied with:
--
--    Get-Content sql\custom\181_anacondra_violet_raptor.sql | `
--      DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_world
--
--  then `reload creature_loot_template` in the console.
--
--  Stock, Lady Anacondra (3671) drops the Violet Feral Raptor mount (23800) at
--  0.2%. The item is alone in loot group 3, so the chance is the drop rate.
--  No other loot table has it.
--
--  Re-runnable. To undo: set the chance back to 0.2.

UPDATE creature_loot_template SET ChanceOrQuestChance = 3
WHERE entry = 3671 AND item = 23800 AND groupid = 3;
