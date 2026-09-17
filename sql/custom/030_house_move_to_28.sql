-- ---------------------------------------------------------------------------
-- 030_house_move_to_28.sql -- migrate existing houses from map 169 to 28 (tw_char).
--
--   Get-Content sql\custom\030_house_move_to_28.sql | DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_char
--
-- Run with 029_house_map_28.sql (tw_world) and a core rebuild -- HOUSE_MAP_ID
-- and HOUSE_ENTRY_* are compiled into HouseMgr.h.
--
-- RUN THIS WITH MANGOSD STOPPED. HouseMgr holds every house and object in
-- memory from startup and writes back on each edit, so a migration applied
-- underneath a running world would be overwritten by the first .house command.
--
-- RE-RUNNABLE, and the ordering is what makes it so. The coordinate shift is
-- NOT idempotent -- running it twice would move everything twice -- so objects
-- are translated while their house still says map 169, and the house row is
-- flipped last. On a second run nothing still says 169 and every statement
-- matches zero rows.
--
-- THE Z COLUMN IS NOT TRANSLATED, IT IS FLATTENED, and that is the one
-- interesting thing in this file. Furniture on 169 was placed against terrain
-- with 81 yards of relief, so an object's z says nothing except "where the
-- ground happened to be there". Map 28 is a single flat plane at z=0. Shifting
-- z by the difference between the two entry points would bury anything that sat
-- on lower ground -- the one object being moved here is 45.7 yards below its
-- own house entrance, so it would have ended up 45.7 yards underground.
--
-- So everything lands ON the new ground and anything meant to float needs one
-- `.house move 0 0 <n>`, or `.house drag` to re-seat it. With a single object
-- that is a five second job; if this ever runs against a decorated house, expect
-- to re-set heights, and know that the alternative -- sampling 169's terrain
-- height per object to recover each one's height above ground -- is possible but
-- was not worth building for one chair.
--
-- The x/y delta is entry-to-entry, so relative layout is preserved exactly:
--   old HOUSE_ENTRY (-1990, -3160, 137)  ->  new (16000, 16000, 0)
--   dx = +17990   dy = +19160
--
-- The permanent bind needs nothing: character_instance references an instance
-- id, and the map lives on the instance row, so moving the instance carries
-- every bind with it.

-- 1. Furniture, while the house still says 169.
UPDATE `house_object` o
    JOIN `house` h ON h.`id` = o.`house_id`
SET o.`x` = o.`x` + 17990,
    o.`y` = o.`y` + 19160,
    o.`z` = 0
WHERE h.`map` = 169;

-- 2. The instances themselves, so existing binds keep resolving.
UPDATE `instance`
SET `map` = 28
WHERE `map` = 169
  AND `id` IN (SELECT `instance_id` FROM `house` WHERE `map` = 169);

-- 3. The houses last -- this is what makes a second run a no-op.
UPDATE `house` SET `map` = 28 WHERE `map` = 169;
