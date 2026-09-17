-- ---------------------------------------------------------------------------
-- 010_henchmen.sql -- Guild Wars style henchmen for the AI playerbot module.
--
-- WHY THIS IS A tw_char SCRIPT AND NOT A VENDOR:
--   Nothing in `gossip_scripts` can put a bot in your party. The core's 94
--   SCRIPT_COMMAND_* opcodes cover items, spells, teleports, summons and talk,
--   but there is no group/invite command, so a "click the NPC and they join"
--   henchman is impossible without C++ changes. What IS supported is the
--   module's own alt-bot path, which our aiplayerbot.conf already calls the
--   recommended one:
--
--       .bot add <name>      log an offline character on YOUR account in as a
--                            bot under your control
--       .bot remove <name>   dismiss it again
--
--   So instead of an NPC that invites bots, we give the player a permanent,
--   fixed-name roster of companions on their own account. One chat line each,
--   or one macro for the whole party. NPC 100009 (011_henchman_hall.sql) is
--   the signboard that lists them.
--
-- HOW THE ROSTER IS BUILT:
--   Rather than hand-building `characters` rows (30+ columns, plus spells,
--   skills, talents and gear -- and a malformed row is a login crash), we
--   conscript seven existing level-60 random bots: move them off their RNDBOT
--   accounts onto the player's account, rename them, and park them in
--   Ironforge. Moving them off the RNDBOT prefix is what makes them permanent
--   -- the random bot manager selects its pool by account prefix, so once
--   they leave it they are never again recycled, relocated or re-randomised.
--   They keep the gear and talents they already had.
--
-- !! RUN THIS WITH mangosd STOPPED. !!
--   These seven characters are offline right now, but the random bot manager
--   logs bots in and out continuously; editing a row underneath it risks the
--   world server writing the old name back on logout.
--
--   DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_char < sql\custom\010_henchmen.sql
--
-- Re-runnable: every statement keys off the fixed guid, so re-applying is a
-- no-op. Editing @ACCOUNT and re-running moves the whole roster to another
-- account.
-- ---------------------------------------------------------------------------

-- ALOOFBIT (holds Luf). 2 characters used, 10 is the client cap, 7 henchmen
-- brings it to 9. Change this to move the roster to a different account.
SET @ACCOUNT := 510;

-- The Hall of Companions, Ironforge -- beside the custom vendor block.
SET @MAP  := 0;
SET @ZONE := 1537;
SET @X    := -4905.4;
SET @Y    := -938.1;
SET @Z    := 501.5;

-- ---------------------------------------------------------------------------
-- The roster. Names are the Guild Wars 1 henchmen; `characters`.name is
-- varchar(12), so all of them fit. Verified free of collisions at write time
-- (note: this DB does NOT enforce unique character names -- the random bot
-- name pool already contains duplicates -- so a collision would be silent).
--
--   guid  was          ->  becomes   race        class      role
--   1160  Toraggs          Stefan    Dwarf       Warrior    Tank
--   4516  Nolantan         Alesia    Human       Priest     Healer
--   3622  Claranca         Mhenlo    Human       Paladin    Healer / off-tank
--   3827  Ilydreath        Aidan     Night Elf   Hunter     Ranged DPS
--   2047  Evenian          Thom      Night Elf   Rogue      Melee DPS
--   4395  Penkiflee        Cynn      Gnome       Mage       Caster DPS
--   2117  Jikiklul         Eve       Gnome       Warlock    Caster DPS
--
-- All Alliance, to match Luf (Dwarf Warrior). For a Horde roster, pick bots
-- with race IN (2,5,6,8) instead and rerun -- the rest of the script is
-- faction-agnostic.
-- ---------------------------------------------------------------------------

UPDATE characters SET account = @ACCOUNT, name = 'Stefan',
       map = @MAP, zone = @ZONE, position_x = @X + 4, position_y = @Y - 2, position_z = @Z,
       orientation = 3.14, taxi_path = '', transguid = 0, trans_x = 0, trans_y = 0, trans_z = 0, trans_o = 0
 WHERE guid = 1160 AND class = 1;

UPDATE characters SET account = @ACCOUNT, name = 'Alesia',
       map = @MAP, zone = @ZONE, position_x = @X + 2, position_y = @Y - 4, position_z = @Z,
       orientation = 3.14, taxi_path = '', transguid = 0, trans_x = 0, trans_y = 0, trans_z = 0, trans_o = 0
 WHERE guid = 4516 AND class = 5;

UPDATE characters SET account = @ACCOUNT, name = 'Mhenlo',
       map = @MAP, zone = @ZONE, position_x = @X, position_y = @Y - 5, position_z = @Z,
       orientation = 3.14, taxi_path = '', transguid = 0, trans_x = 0, trans_y = 0, trans_z = 0, trans_o = 0
 WHERE guid = 3622 AND class = 2;

UPDATE characters SET account = @ACCOUNT, name = 'Aidan',
       map = @MAP, zone = @ZONE, position_x = @X - 2, position_y = @Y - 4, position_z = @Z,
       orientation = 3.14, taxi_path = '', transguid = 0, trans_x = 0, trans_y = 0, trans_z = 0, trans_o = 0
 WHERE guid = 3827 AND class = 3;

UPDATE characters SET account = @ACCOUNT, name = 'Thom',
       map = @MAP, zone = @ZONE, position_x = @X - 4, position_y = @Y - 2, position_z = @Z,
       orientation = 3.14, taxi_path = '', transguid = 0, trans_x = 0, trans_y = 0, trans_z = 0, trans_o = 0
 WHERE guid = 2047 AND class = 4;

UPDATE characters SET account = @ACCOUNT, name = 'Cynn',
       map = @MAP, zone = @ZONE, position_x = @X + 5, position_y = @Y, position_z = @Z,
       orientation = 3.14, taxi_path = '', transguid = 0, trans_x = 0, trans_y = 0, trans_z = 0, trans_o = 0
 WHERE guid = 4395 AND class = 8;

-- Eve was sitting in an Arathi Basin instance (map 529); the relocation above
-- plus the battleground row cleanup below is what gets her out of it.
UPDATE characters SET account = @ACCOUNT, name = 'Eve',
       map = @MAP, zone = @ZONE, position_x = @X - 5, position_y = @Y, position_z = @Z,
       orientation = 3.14, taxi_path = '', transguid = 0, trans_x = 0, trans_y = 0, trans_z = 0, trans_o = 0
 WHERE guid = 2117 AND class = 9;

-- ---------------------------------------------------------------------------
-- Detach them from everything the random bot manager owns.
-- ---------------------------------------------------------------------------

-- Per-bot scheduler state: randomise timers, teleport timers, revive timers.
-- Left behind, these would keep firing against characters that are no longer
-- in the pool.
DELETE FROM ai_playerbot_random_bots WHERE bot   IN (1160,4516,3622,3827,2047,4395,2117);
DELETE FROM ai_playerbot_random_bots WHERE owner IN (1160,4516,3622,3827,2047,4395,2117);

-- Bot guilds and bot groups are rebuilt from scratch every start.
DELETE FROM guild_member  WHERE guid       IN (1160,4516,3622,3827,2047,4395,2117);
DELETE FROM group_member  WHERE memberGuid IN (1160,4516,3622,3827,2047,4395,2117);
DELETE FROM character_battleground_data WHERE guid IN (1160,4516,3622,3827,2047,4395,2117);

-- Hearthstone to the hall, so a companion that dies and releases comes back
-- to where you hired them.
REPLACE INTO character_homebind (guid, map, zone, position_x, position_y, position_z)
SELECT guid, @MAP, @ZONE, @X, @Y, @Z
  FROM characters WHERE guid IN (1160,4516,3622,3827,2047,4395,2117);

-- ---------------------------------------------------------------------------
SELECT guid, name, race, class, level, account, map, zone
  FROM characters WHERE guid IN (1160,4516,3622,3827,2047,4395,2117) ORDER BY class;
