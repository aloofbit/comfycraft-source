-- ============================================================================
--  GOLDSHIRE INN: THREE CHAIRS DOWN ON THE FLOOR  (tw_world)
-- ============================================================================
--  Applied with:
--
--    Get-Content sql\custom\221_goldshire_inn_chairs.sql | `
--      DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_world
--
--  then restart mangosd: a spawned object keeps its height until it loads again.
--
--  Three Wooden Chairs upstairs stood 10.8 cm above the floor, in Blizzard's
--  inn and in Reforged's. Measured 2026-10-29 against the inn's floor under each
--  one; the other 13 chairs in the inn stand within 2 cm of it. The heights are
--  absolute, so a second run changes nothing.
-- ============================================================================

UPDATE gameobject SET position_z = 63.8241 WHERE guid = 26243 AND map = 0 AND id = 177502;
UPDATE gameobject SET position_z = 63.8241 WHERE guid = 26252 AND map = 0 AND id = 177503;
UPDATE gameobject SET position_z = 63.8241 WHERE guid = 26792 AND map = 0 AND id = 177504;
