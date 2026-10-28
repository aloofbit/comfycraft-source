-- ============================================================================
--  More Doom Weed in Tirisfal Glades  (tw_world)
-- ============================================================================
--  Applied with:
--
--    Get-Content sql\custom\214_doom_weed_spawns.sql | `
--      DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_world
--
--  then restart the server. Pools and spawn times are read at startup.
--
--  "Doom Weed" (5482) needs 10 Doom Weed (13702). The weed (gameobject
--  176753) has 27 spawn points north of the Brill graveyard, all in pool 1010.
--  The pool allowed 9 weeds at a time, fewer than the quest needs, and a
--  picked weed came back after 5 minutes. This allows 18 at a time and brings
--  a picked weed back after 2 minutes.
-- ============================================================================

UPDATE pool_template SET max_limit = 18 WHERE entry = 1010;

UPDATE gameobject SET spawntimesecsmin = 120, spawntimesecsmax = 120 WHERE id = 176753;
