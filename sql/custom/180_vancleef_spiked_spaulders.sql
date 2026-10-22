-- ============================================================================
--  SPIKED DEFIAS SPAULDERS FROM VANCLEEF AT 15%  (tw_world)
-- ============================================================================
--  Applied with:
--
--    Get-Content sql\custom\180_vancleef_spiked_spaulders.sql | `
--      DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_world
--
--  then `reload creature_loot_template` in the console.
--
--  Stock, Edwin VanCleef (639) drops the Spiked Defias Spaulders (81005) at 8%.
--  The item is alone in loot group 4, so the chance is the drop rate.
--
--  Loot table 639 is used only by VanCleef.
--
--  Re-runnable. To undo: set the chance back to 8.

UPDATE creature_loot_template SET ChanceOrQuestChance = 15
WHERE entry = 639 AND item = 81005 AND groupid = 4;
