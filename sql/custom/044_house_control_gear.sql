-- ============================================================================
--  The gear on the way out, and the text its menu greets you with  (tw_world)
-- ============================================================================
--  Every house has an exit portal, and until now it carried nothing: the code
--  said so plainly -- "Only the world-side entrances carry a gear. The way out
--  is placed in the template and is not the resident's to move, so there is
--  nothing for a menu on it to offer." There is now. The exit is the one object
--  every house has and every player walks up to, which makes it the natural
--  place for the house's own control panel.
--
--  ENTRY 100014. The housing gameobjects are 100010 Furniture Handle, 100011
--  Home, 100012 Doorway, 100013 Portal Handle; 100014-100027 are free, and
--  100028 is somebody else's Shaman Shrine. Note this is the GAMEOBJECT block --
--  creature 100014 is Keeper Faelyn, a different table entirely.
--
--  TYPE 10 (GOOBER) IS NOT DECORATION. GameObject::Use raises gossip for
--  QUESTGIVER and GOOBER only, so a GENERIC (5) gear would be unclickable. The
--  script binds through pGOHello -- which fires BEFORE the goober state machine
--  and stops it destroying the object after one click -- and pGOGossipSelect,
--  which is the only route back from CMSG_GOSSIP_SELECT_OPTION for a gameobject
--  guid. pGOGossipHello is the matching-sounding hook and is the wrong one.
--
--  Display 451 and size 0.15 are copied from 100013 exactly: the two gears
--  should read as the same object doing the same job in two places.
--
--  broadcast_text is NOT reloadable, so the two text rows need a restart --
--  which is fine, because they ship with the binary that uses them.
--
--  Re-runnable. Apply with:
--    Get-Content sql\custom\044_house_control_gear.sql | DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_world
-- ============================================================================

DELETE FROM gameobject_template WHERE entry = 100014;

INSERT INTO `gameobject_template`
    (`entry`, `type`, `displayId`, `name`, `size`, `faction`, `flags`, `script_name`) VALUES
(100014, 10, 451, 'House Controls', 0.15, 0, 0, 'go_house_control');

-- ---------------------------------------------------------------------------
--  The panel's greeting, and its confirm page
-- ---------------------------------------------------------------------------
--  6400031 is the entrance gear's greeting and 6400032 its confirm; these are
--  the same two things for the house side. SendGossipMenu takes an npc_text id
--  rather than a string, so a menu built entirely in code still needs these two
--  rows and nothing else -- no gossip_menu entry out of the nearly-full
--  smallint space, no option rows, no ~490-byte ceiling.

DELETE FROM npc_text       WHERE ID    IN (6400033, 6400034);
DELETE FROM broadcast_text WHERE entry IN (6400033, 6400034);

INSERT INTO broadcast_text (entry, male_text, female_text, chat_type, language_id) VALUES
(6400033, 'Your house.', 'Your house.', 0, 0),
(6400034, 'Nothing has been emptied yet.', 'Nothing has been emptied yet.', 0, 0);

INSERT INTO npc_text (ID, BroadcastTextID0, Probability0) VALUES
(6400033, 6400033, 1),
(6400034, 6400034, 1);
