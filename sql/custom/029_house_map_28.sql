-- ---------------------------------------------------------------------------
-- 029_house_map_28.sql -- move player housing from map 169 to map 28 (tw_world).
--
-- SUPERSEDES the map choice in 015_house_map.sql. That file's reasoning still
-- reads correctly; it just optimised for the wrong thing. It picked 169 because
-- it had "terrain worth standing on" -- but a house plot wants the opposite of
-- interesting terrain, and 169 turned out to be the most expensive map on the
-- server to carry.
--
--   Get-Content sql\custom\029_house_map_28.sql | DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_world
--
-- RESTART REQUIRED. map_template is read once at startup and there is no
-- `reload map_template`. Re-runnable.
--
-- Run 030_house_move_to_28.sql (tw_char) with it, and rebuild the core --
-- HOUSE_MAP_ID and HOUSE_ENTRY_* in HouseMgr.h are compiled in.
--
-- WHY 28, measured rather than guessed. Every map was read out of
-- server/maps/*.map for how much of it is dead-flat filler, cross-checked
-- against spawn counts in tw_world.creature / tw_world.gameobject:
--
--   map        tiles  flat@z=0  relief  spawns              on disk
--   169 Emerald Dream  256     0       81yd    1 cre /   7 obj   33.4 MB, NO mmaps
--   189 Scarlet Mon.    36    36        0yd  440 cre / 123 obj    1.3 MB
--   129 Razorfen Dn.    24    17        1yd  297 cre /  74 obj    4.3 MB
--   026 Blood Ring      16    12        0yd    0 cre /   4 obj    1.4 MB
--   028 (this one)      16    12        0yd    0 cre /   0 obj    1.4 MB
--   817 Tamotest2       10     4       10yd    0 cre /   0 obj    2.4 MB
--
-- The two PERFECTLY flat maps are traps. 189 and 129 are flat because their
-- real content is a WMO building sitting on filler terrain -- and they are live
-- dungeons. Spawns are keyed by map, so they appear in EVERY instance of it: a
-- house on 189 would share its instance with 440 Scarlet Crusade. 189 also has
-- 280 areatrigger_teleport rows pointing at it.
--
-- 28 is the only candidate with NOTHING on it -- no creatures, no gameobjects,
-- no areatriggers -- and its 12 clear tiles are all flat at exactly z=0, one
-- continuous plane with no steps, about 2100 yards square. Map 26 is its twin
-- and equally good bar four Arena Doors in a corner tile.
--
-- It also ships with mmaps, which 169 does NOT (0 files against 598 for map 0).
-- Nothing could pathfind inside a house on 169, so companions could not properly
-- follow you around the thing you were decorating. That is fixed by moving.
--
-- MAP 28 HAD NO map_template ROW AT ALL, so mangosd did not know the map
-- existed. This creates it. The client knows it -- Map.dbc calls it a
-- battleground -- and the client tolerating a map type it disagrees with is
-- already proven twice here (817, and 169 itself).
--
-- linked_zone MATTERS HERE and did not on 169. Every tile of map 28 reports
-- area bit 65535, the "no area" sentinel with no AreaTable row, so the server
-- would otherwise have no area for a player standing in a house.
-- GetAreaEntryByAreaFlagAndMap (Map.h:177) falls back to linked_zone exactly for
-- this. 956 "The Verdant Fields" is reused so houses keep reporting the area
-- they always did -- it is server-side only and is not what the client displays.
--
-- 169's row is deliberately LEFT INSTANCEABLE by this file, so rolling back is
-- only a core rebuild rather than re-running 015 as well. Once 28 is proven,
-- revert it with:
--   UPDATE map_template SET map_type = 0, script_name = '', linked_zone = 0 WHERE entry = 169;

DELETE FROM `map_template` WHERE `entry` = 28;
INSERT INTO `map_template`
    (`entry`, `parent`, `map_type`, `linked_zone`, `player_limit`, `reset_delay`,
     `time_offset`, `ghost_entrance_map`, `ghost_entrance_x`, `ghost_entrance_y`,
     `map_name`, `script_name`)
VALUES
    (28, 0, 1, 956, 20, 0, 0, 0, -4905.4, -938.1, 'Home', 'instance_player_house');
