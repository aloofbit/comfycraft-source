-- ---------------------------------------------------------------------------
-- 017_house_script.sql -- attach the housing instance script to map 169.
--
--   DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_world < sql\custom\017_house_script.sql
--
-- REQUIRES THE PATCHED CORE. `instance_player_house` is registered from
-- src/game/Housing/HouseMgr.cpp via AddSC_player_house(). On a stock binary the
-- script name resolves to nothing and mangosd logs "Script not found:
-- instance_player_house." at startup -- not fatal, but the houses would then be
-- empty, because that script is what registers a house's furniture with its
-- instance before the grids load.
--
-- Kept out of 015_house_map.sql deliberately: 015 works on any binary, this
-- does not. Same split as 013_henchman_hall_recruit.sql.
--
-- RESTART REQUIRED -- map_template is read once at startup.
--
-- The mechanism is the ordinary one, not a special case: map_template.script_name
-- is converted to MapEntry::scriptId by SQLStorage (the 's' -> 'i' column in
-- MapEntrydstfmt, SQLStorages.cpp:32), and Map::CreateInstanceData looks the
-- script up by that id when a copy of the map is created. 34 stock instances in
-- this DB already work this way.
-- ---------------------------------------------------------------------------

UPDATE map_template SET script_name = 'instance_player_house' WHERE entry = 169;

-- ---------------------------------------------------------------------------
-- ROLLBACK -- also do this before putting a pre-housing binary back.
--   UPDATE map_template SET script_name = '' WHERE entry = 169;
-- ---------------------------------------------------------------------------
