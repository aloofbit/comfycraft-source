-- ============================================================================
--  FRIGID CLOAK GETS ITS ARMOR  (tw_world)
-- ============================================================================
--  Applied with:
--
--    Get-Content sql\custom\173_frigid_cloak_armor.sql | `
--      DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_world
--
--  then `reload item_template` in the console.
--
--  Frigid Cloak (162, green, item level 18) drops from Tan'sha the Sleek
--  (63133) in Frostmane Hollow. Upstream gave it 0 armor. The other green
--  item level 18 cloaks have 16 (eight of them) or 17 (one).
-- ============================================================================

UPDATE item_template SET armor = 16 WHERE entry = 162;
