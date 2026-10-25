-- ============================================================================
--  DEADMINES: VANCLEEF AND HIS BLACKGUARDS HIT 10% SOFTER  (tw_world)
-- ============================================================================
--  Applied with:
--
--    Get-Content sql\custom\201_vancleef_damage.sql | `
--      DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_world
--
--  then `reload creature_template` in the console. A spawned creature takes
--  the new damage after a reset or a respawn.
--
--  Edwin VanCleef (639) and the Defias Blackguard (636). The Blackguard entry
--  is used in Deadmines only: four spawns, and the two VanCleef summons.
--  The multiplier stacks with Dungeon tuning: at Deadmines 90/90 their melee
--  is 0.9 x 0.9 = 81% of stock. On 2026-10-22 hand cuts to 0.8 and 0.65 under
--  the same tuning made him too weak.
-- ============================================================================

UPDATE creature_template SET dmg_multiplier = 0.9 WHERE entry IN (639, 636);
