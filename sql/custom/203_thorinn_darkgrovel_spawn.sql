-- ============================================================================
--  ANVILMAR: THORINN DARKGROVEL, WHERE TAINTED RUNE ENDS  (tw_world)
-- ============================================================================
--  Applied with:
--
--    Get-Content sql\custom\203_thorinn_darkgrovel_spawn.sql | `
--      DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_world
--
--  A spawn loads at start-up only: restart the server, or `.npc add 63196`
--  at the same place for the running session.
--
--  Sten Stoutarm (658) gives dwarf warlocks Tainted Rune (42045), which ends at
--  Thorinn Darkgrovel (63196). Upstream ships the quest and the template but no
--  spawn, so the quest could not be finished. The place is the one the owner
--  chose with `.npc add` on production on 2026-10-25 (guid 2950139 there).
--  This script moves that spawn to the quest-fix guid range.
-- ============================================================================

DELETE FROM creature WHERE id = 63196;
DELETE FROM creature WHERE guid = 2949000;

INSERT INTO creature (guid, id, map, position_x, position_y, position_z, orientation,
                      spawntimesecsmin, spawntimesecsmax, wander_distance, movement_type)
VALUES (2949000, 63196, 0, -6052, 393.538, 398.872, 5.37007, 120, 120, 0, 0);
