-- ---------------------------------------------------------------------------
-- 015_house_map.sql -- turn map 169 into an instanced map, for player housing.
--
-- PHASE 0 OF PLAYER HOUSING. One job: make the house map instanceable, so two
-- players standing on the same coordinates are in different copies of it.
-- Nothing else about housing depends on this file, and nothing here needs a
-- patched core.
--
--   DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_world < sql\custom\015_house_map.sql
--
-- RESTART REQUIRED. map_template is read once at startup; there is no
-- `reload map_template` among the 103 reload subcommands. Re-runnable.
--
-- ALREADY PROVEN, on map 817 before this file was rewritten: the 1.12 client
-- accepts a map its own Map.dbc calls a world map being served as an instance.
-- That was the one genuine unknown in the whole design, and it is now settled.
--
-- WHY MAP 169 "Emerald Dream". A house map cannot share a map id with live
-- content: spawns in `creature` and `gameobject` are keyed by map, so they
-- appear in EVERY instance of it. That rules out anything Turtle actually uses.
-- Of what is left, 169 is the only one with terrain worth standing on. Measured
-- by reading server/maps/*.map directly -- the share of each map that is dead
-- flat filler rather than sculpted ground:
--
--   map 817  Sunstrider Court   86% flat at z=0        one 300yd plateau
--   map 821  Thorn Gorge        87% (z=1343 and z=0)   ~700yd valley
--   map 169  Emerald Dream      61% flat at z=92       TWO 2600x2600yd regions
--
-- 169's two named regions are real: a transect across The Verdant Fields runs
-- 110 -> 137 -> 114 continuously over 2400 yards. Names come from
-- server/dbc/AreaTable.dbc:
--
--   area  956  areaBit 319   The Verdant Fields   X -3150..-550,  Y -3700..-1100
--   area 1397  areaBit 376   Emerald Forest       X -4200..-1600, Y  1100..3500
--
-- Note a .map tile stores an area BIT, not an area id -- easy to misread, and
-- it was misread once already here.
--
-- WHAT ELSE IS ON THE MAP. Eight objects, all of them somebody's leftovers:
-- a Dryad (creature 40002) at (2991, -3075), and a little scene of dream
-- flowers, blood elf drapery and easter eggs around (2350, -3800). They sit in
-- the unnamed filler east of both named regions, ~4000 yards from the house
-- plot, so no house will ever see them. Left in place.
--
-- KNOWN GAP: map 169 has NO mmaps extracted -- zero tiles, against 256 for
-- terrain and 37 for vmaps. Pathfinding does not exist here. It does not matter
-- for a stationary decorator NPC, and houses have no wandering creatures, but
-- anything that needs to WALK on this map needs the mmap extractor run first.
-- vmaps do cover The Verdant Fields (tiles 33-37 x 34-37), so models there have
-- collision and the ground is solid.
-- ---------------------------------------------------------------------------

-- Undo the map 817 spike. 817 goes back to being an ordinary world map, and the
-- instance it spawned goes with it. Without this, _LoadBoundInstances logs
-- "has bind to nonexistent or not dungeon map 817" on the next login and
-- deletes the bind through its error path -- which works, but noisily, and
-- leaves the orphaned `instance` row for a second restart to collect.
UPDATE map_template
   SET map_type = 0, player_limit = 40, linked_zone = 0,
       ghost_entrance_map = -1, ghost_entrance_x = 0, ghost_entrance_y = 0
 WHERE entry = 817;

DELETE ci FROM tw_char.character_instance ci
  JOIN tw_char.instance i ON i.id = ci.instance
 WHERE i.map = 817;
DELETE FROM tw_char.instance WHERE map = 817;

-- The house map.
-- map_type      0 world -> 1 instance   (2 raid, 3 battleground)
-- player_limit  DungeonMap::CanEnter rejects entry past this. Must not be 0.
-- linked_zone   fallback area lookup -- 956, The Verdant Fields.
-- ghost_entrance_*  where your ghost appears on death, and so which graveyard
--                   you get. Ironforge, beside the other custom NPCs.
UPDATE map_template
   SET map_type           = 1,
       player_limit       = 20,
       reset_delay        = 0,
       linked_zone        = 956,
       ghost_entrance_map = 0,
       ghost_entrance_x   = -4905.4,
       ghost_entrance_y   = -938.1
 WHERE entry = 169;

-- .tele house -- a gentle rise in the middle of The Verdant Fields: level
-- within 3.4 yards over 60x60, with 53 yards of relief within 250 yards, so it
-- has a view rather than sitting on a plain. Three alternates worth flying to
-- before this is settled; moving it later is this one row:
--     -3030 -3100 123     western high ground
--     -2830 -2200 125     northern slope
--     -1330 -3540 129     southeastern rise
DELETE FROM game_tele WHERE id = 950;
INSERT INTO game_tele (id, position_x, position_y, position_z, orientation, map, name) VALUES
(950, -1990.0, -3160.0, 137.0, 0.0, 169, 'house');

-- ---------------------------------------------------------------------------
-- ROLLBACK
--
-- UPDATE map_template SET map_type = 0, player_limit = 40, linked_zone = 0,
--        ghost_entrance_map = -1, ghost_entrance_x = 0, ghost_entrance_y = 0
--  WHERE entry = 169;
-- DELETE FROM game_tele WHERE id = 950;
-- ---------------------------------------------------------------------------
