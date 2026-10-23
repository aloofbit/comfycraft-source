-- ============================================================================
--  DEADMINES: VANCLEEF'S BLACKGUARDS DESPAWN WHEN HE DIES  (tw_world)
-- ============================================================================
--  Applied with:
--
--    Get-Content sql\custom\189_vancleef_guards_despawn.sql | `
--      DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_world
--
--  then `reload creature_ai_events` in the console (it reloads
--  creature_ai_scripts first). A new instance gets the event.
--
--  Edwin VanCleef (639) has two Defias Blackguards (636) beside him, spawns
--  79368 and 79383, and summons two more at 50% with VanCleef's Allies (5200),
--  which are guardians. A group that killed him still had to finish
--  the guards. His death event now despawns the two spawns by guid (target
--  type 9, flags 2 + 16: the guard is the source, and a guard already gone is
--  skipped without an error line) and removes his summoned guardians, the
--  way 187 removes the Goblin Engineer's golems. The spawns respawn on their
--  normal timer (a week), as if killed.
-- ============================================================================

DELETE FROM creature_ai_scripts WHERE id = 63908;
INSERT INTO creature_ai_scripts (id, delay, command, datalong, target_param1, target_type, data_flags, comments) VALUES
(63908, 0, 18, 0, 79368, 9, 18, 'Edwin VanCleef - Despawn Defias Blackguard 79368'),
(63908, 0, 18, 0, 79383, 9, 18, 'Edwin VanCleef - Despawn Defias Blackguard 79383'),
(63908, 0, 56, 636, 0, 0, 0, 'Edwin VanCleef - Remove summoned Defias Blackguards');

DELETE FROM creature_ai_events WHERE id = 63908;
INSERT INTO creature_ai_events (id, creature_id, condition_id, event_type, event_inverse_phase_mask,
  event_chance, event_flags, event_param1, event_param2, event_param3, event_param4,
  action1_script, action2_script, action3_script, comment) VALUES
(63908, 639, 0, 6, 0, 100, 0, 0, 0, 0, 0, 63908, 0, 0,
  'Edwin VanCleef - Despawn his Blackguards on Death');
