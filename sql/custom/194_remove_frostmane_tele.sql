-- ============================================================================
--  Remove the .tele place "frostmane"                                (tw_world)
-- ============================================================================
--  Applied with:
--
--    Get-Content sql\custom\194_remove_frostmane_tele.sql | `
--      DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_world
--
--  then, in the mangosd console: reload game_tele
--
--  Turtle ships game_tele 811 "frostmane" on map 806, a Turtle map our client
--  does not have. It is not Frostmane Hollow, and `.tele frostmane` gives an
--  error. Frostmane Hollow is "frostmanehollow" (946, map 0) and stays.
--  No dialog teleport names 811.
--
--  RE-RUNNABLE.
-- ============================================================================

DELETE FROM game_tele WHERE id = 811 AND name = 'frostmane';
