-- ============================================================================
--  FANG SET FROM THE WAILING CAVERNS BOSSES AT 33%  (tw_world)
-- ============================================================================
--  Applied with:
--
--    Get-Content sql\custom\182_fang_set_boss_chance.sql | `
--      DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_world
--
--  then `reload creature_loot_template` in the console.
--
--  The Fang set (set 162) pieces from bosses go from 25% to 33.33%, the
--  chance Armor of the Fang (Pythas) and Leggings of the Fang (Cobrahn)
--  already have:
--
--    Cowl of the Fang (81006)     Mutanus the Devourer (3654)
--    Belt of the Fang (10412)     Lady Anacondra (3671)
--    Footpads of the Fang (10411) Lord Serpentis (3673)
--
--  A dungeon boss rolls each item of a group on its own (LootMgr.cpp), so the
--  raise takes nothing from the other items. The three groups now add up to
--  108%, and the loader logs "has total chance > 100%" for each at startup.
--
--  Re-runnable. To undo: set the three chances back to 25.

UPDATE creature_loot_template SET ChanceOrQuestChance = 33.33
WHERE groupid = 1 AND (entry, item) IN ((3654, 81006), (3671, 10412), (3673, 10411));
