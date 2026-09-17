-- ---------------------------------------------------------------------------
-- SUPERSEDED by sql/custom/022. The handle is a GAMEOBJECT now, not this
-- creature: the wisp model carries an ambient sound loop through
-- CreatureModelData -> CreatureSoundData that nothing on this side can switch
-- off, because the client reads its own copy out of the MPQ. A gameobject goes
-- through neither table. 019, 020 and 021 are the four model changes that took
-- to work out, and 023-025 land it on a small gnome gear.
--
-- creature_template 100010 is left in place, unspawned and harmless, so this is
-- revertible. The npc_text and broadcast_text rows below are STILL LIVE --
-- SendGossipMenu takes an npc_text id whatever the handle is made of.
--
-- 018_house_handles.sql -- the clickable handle for player housing edit mode.
--
--   DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_world < sql\custom\018_house_handles.sql
--
-- NEEDS THE PATCHED CORE. The menu is built entirely in C++
-- (source/src/game/Housing/HouseHandle.cpp); this file only supplies the
-- creature the player clicks and the one line of greeting text a gossip
-- window insists on. Applying it against an unpatched binary is harmless --
-- the creature simply never gets summoned, because nothing summons it.
--
-- RESTART REQUIRED, for the broadcast_text row. `reload creature_template`
-- picks the creature up on its own, but broadcast_text is one of the two
-- tables with no reload subcommand. Re-runnable.
--
-- WHY THIS IS A CREATURE AND NOT THE FURNITURE ITSELF. Two dead ends, both
-- checked rather than assumed:
--
--   * Furniture cannot BE an NPC. CreatureModelData.dbc holds 788 models and
--     every one is a .mdx -- there is not a single .wmo among them, so no
--     creature can ever wear a table's model without a client patch.
--   * Furniture cannot open a menu of its own either. GameObject::Use raises
--     gossip for exactly two types, QUESTGIVER and GOOBER, and only when the
--     template carries a gossipID. Housing furniture is GENERIC, CHAIR and
--     MAP_OBJECT; the 1.12 client will not even give you a cursor for them.
--
-- WHY A WISP. A handle has to be CLICKED, so the invisible stalker model that
-- every other marker NPC in this database uses is precisely the wrong choice.
-- Display 1824 is the small hovering Teldrassil wisp: bright enough to find in
-- a dark room, small enough not to hide the thing it is marking, and it floats
-- rather than standing, which reads as "control" rather than "resident".
--
-- WHY IT NEEDS NO SPAWN. Handles are TEMPORARY SUMMONS created by
-- `.house edit` and despawned when you turn it off, when you leave the map, or
-- after 30 minutes, whichever comes first. That is not just tidiness: creature
-- low guids are 24 bits here exactly like gameobject ones, tw_world.creature
-- already reaches 2,902,666, and GuidReserveSize.Creature is still 1000 -- a
-- persistent handle would have needed its own carved-out guid block the way
-- house furniture did. A temporary summon needs none of it.
-- ---------------------------------------------------------------------------

-- The handle itself.
--   faction 35     friendly to everyone, so nobody can turn a wisp hostile
--   npc_flags 1    UNIT_NPC_FLAG_GOSSIP -- without this the client never sends
--                  CMSG_GOSSIP_HELLO and right-clicking does nothing at all
--   unit_flags 768 IMMUNE_TO_PLAYER | IMMUNE_TO_NPC. NOT_SELECTABLE (0x2000000)
--                  would have been the reflex here and is wrong -- it also
--                  stops the click that the whole thing depends on.
--   inhabit_type 4 air only, so it holds the height it is summoned at instead
--                  of being dropped onto the ground
--   scale 1        full size. Deliberately not shrunk: a handle that is hard
--                  to click is worse than one that is a little bulky, and this
--                  is the one dimension that is cheap to retune -- change it
--                  and `reload creature_template` from the mangosd console.
--   script_name    binds pGossipHello / pGossipSelect from HouseHandle.cpp
DELETE FROM creature_template WHERE entry = 100010;
INSERT INTO creature_template
    (entry, display_id1, name, subname, gossip_menu_id,
     level_min, level_max, health_min, health_max, faction, npc_flags,
     scale, unit_class, unit_flags, type, type_flags,
     movement_type, inhabit_type, regeneration, script_name)
VALUES
    (100010, 1824, 'Furniture Handle', 'Right-click to arrange', 0,
     60, 60, 100, 100, 35, 1,
     1, 1, 768, 7, 0,
     0, 4, 0, 'npc_house_handle');

-- The greeting line. gossip_menu / gossip_menu_option rows are deliberately
-- absent: the options are built in code, so none of the limits recorded in
-- CLAUDE.md apply -- not the nearly-full gossip_menu.entry space, not the
-- ~490-byte menu ceiling, not the npc_option_npcflag silent-filter trap.
-- SendGossipMenu still takes an npc_text ID rather than a string, though, so
-- one row is unavoidable. Same 6400xxx custom block as 003 and 004.
--
-- npc_text has no inline strings in this core -- it only points at
-- broadcast_text -- so both rows are needed.
DELETE FROM npc_text       WHERE ID    = 6400030;
DELETE FROM broadcast_text WHERE entry = 6400030;

INSERT INTO broadcast_text (entry, male_text, female_text, chat_type, language_id) VALUES
(6400030, 'Which way shall it go?', 'Which way shall it go?', 0, 0);

INSERT INTO npc_text (ID, BroadcastTextID0, Probability0) VALUES
(6400030, 6400030, 1);

-- ---------------------------------------------------------------------------
-- ROLLBACK
--
-- DELETE FROM creature_template WHERE entry = 100010;
-- DELETE FROM npc_text          WHERE ID    = 6400030;
-- DELETE FROM broadcast_text    WHERE entry = 6400030;
-- ---------------------------------------------------------------------------
