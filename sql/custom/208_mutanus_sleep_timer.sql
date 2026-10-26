-- ============================================================================
--  MUTANUS CASTS NARALEX'S NIGHTMARE LESS OFTEN  (tw_world)
-- ============================================================================
--  Applied with:
--
--    Get-Content sql\custom\208_mutanus_sleep_timer.sql | `
--      DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_world
--
--  then `reload creature_spells` in the console.
--
--  Mutanus the Devourer (3654) casts Naralex's Nightmare (7967), a 15 s sleep
--  on a random member who is not the tank. Stock repeat is 18-25 s, so with
--  Terrify and Thundercrack the healer is out of the fight for most of it.
--  The repeat goes to 35-45 s. The first cast (8-12 s) does not change.
--
--  Re-runnable. To undo: set the repeat back to 18 and 25.

UPDATE creature_spells SET delayRepeatMin_1 = 35, delayRepeatMax_1 = 45
WHERE entry = 36540 AND spellId_1 = 7967;
