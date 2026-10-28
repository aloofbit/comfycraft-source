-- ============================================================================
--  Nightlash appears more often  (tw_world)
-- ============================================================================
--  Applied with:
--
--    Get-Content sql\custom\213_nightlash_summon_chance.sql | `
--      DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_world
--
--  then, in the mangosd console:  reload creature_ai_events
--
--  "The Dead Fields" (437) needs the Essence of Nightlash. Nightlash (1983)
--  has no spawn: a Rot Hide Gladerunner (1772) or Rot Hide Mystic (1773) that
--  dies summons her, at a fixed point in the Dead Fields. The chance was 20%
--  for each death. This sets it to 40%.
-- ============================================================================

UPDATE creature_ai_events SET event_chance = 40 WHERE id IN (177202, 177301);
