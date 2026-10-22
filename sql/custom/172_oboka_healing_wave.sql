-- ============================================================================
--  HANDLER OBOKA HEALS WITH A RANK FOR HIS LEVEL  (tw_world)
-- ============================================================================
--  Applied with:
--
--    Get-Content sql\custom\172_oboka_healing_wave.sql | `
--      DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_world
--
--  then `reload creature_spells` in the console.
--
--  Handler Oboka (63132, level 16 elite, Frostmane Hollow) casts Healing Wave
--  every 15-16 s on the friend within 40 yards missing the most health, once
--  it is below 50%. Upstream gave him Rank 7 (8005, level 40, heals 740-855).
--  He has 816 HP and Tan'sha the Sleek has 1599, so each cast put either one
--  back to full or near full.
--
--  Now he casts Rank 4 (913, level 18, heals 268-316). The cast flag stays 2
--  (triggered: instant, cannot be interrupted).
-- ============================================================================

UPDATE creature_spells
   SET spellId_1 = 913
 WHERE entry = 63132;
