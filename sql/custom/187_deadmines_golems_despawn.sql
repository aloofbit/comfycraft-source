-- ============================================================================
--  DEADMINES: REMOTE-CONTROLLED GOLEMS DESPAWN WITH THEIR ENGINEER  (tw_world)
-- ============================================================================
--  Applied with:
--
--    Get-Content sql\custom\187_deadmines_golems_despawn.sql | `
--      DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_world
--
--  then `reload creature_ai_events` in the console (it reloads
--  creature_ai_scripts first). A new instance gets the event.
--
--  A Goblin Engineer (622) casts 3605 Summon Remote-Controlled Golem, a
--  guardian (2520) that lasts 60 s. Pet::Update removes a guardian whose owner
--  is dead only when the guardian is out of combat, so a golem kept fighting
--  after its engineer died. This death event removes the engineer's golems at
--  once, the same way the Blackwing Warlock (12459) removes its guardians.
-- ============================================================================

DELETE FROM creature_ai_scripts WHERE id = 62202;
INSERT INTO creature_ai_scripts (id, delay, command, datalong, comments) VALUES
(62202, 0, 56, 2520, 'Goblin Engineer - Remove Remote-Controlled Golems');

DELETE FROM creature_ai_events WHERE id = 62202;
INSERT INTO creature_ai_events (id, creature_id, condition_id, event_type, event_inverse_phase_mask,
  event_chance, event_flags, event_param1, event_param2, event_param3, event_param4,
  action1_script, action2_script, action3_script, comment) VALUES
(62202, 622, 0, 6, 0, 100, 0, 0, 0, 0, 0, 62202, 0, 0,
  'Goblin Engineer - Remove Remote-Controlled Golems on Death');
