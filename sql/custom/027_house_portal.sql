-- Housing entrance and exit portals (tw_world).
--
-- 100011 is the swirl you walk into out in the world; 100012 is the one inside
-- the house that takes you back to it. Both are GENERIC (5): visible, and
-- nothing happens if you click them. They are walk-THROUGH, not click-through.
--
-- WHY NOT AN AREATRIGGER, which is what a real dungeon entrance uses: the
-- client only sends CMSG_AREATRIGGER for triggers listed in its OWN
-- AreaTrigger.dbc, so a new one cannot be created from the server at all --
-- existing ones are stuck where Blizzard put them, which is nowhere useful.
-- What makes walk-through work instead is GameObjectAI::UpdateAI, called for
-- every gameobject in a loaded grid (GameObject.cpp:338). The script polls for
-- somebody standing in the portal. `script_name` is what binds it.
--
-- displayId 21585 is Creature_SpellPortal_Purple, the same model as
-- gameobject 2000721 -- chosen by placing one in a house and looking at it,
-- which is the cheap way to shop for a model. It is carried at the template's
-- own size (1.0) rather than the 1.5 the mage-portal swirl needed. The city
-- swirls remain 4396 Stormwind, 4393 Darnassus, 4394 Ironforge,
-- 4395 Orgrimmar, 4397 Thunder Bluff, 4398 Undercity.
-- Try others with
--   .house portal model <displayId> [scale]
-- rather than editing this file: gameobject_template has NO reload command
-- (`reload gameobject` reloads the SPAWN table, which is a different thing), so
-- every change here costs a ~2 minute restart. Same trap as the edit handle in
-- sql/custom/025.

-- TYPE 10 (GOOBER) ON THE ENTRANCE, and it is load-bearing rather than
-- decorative: it is what makes the portal right-clickable, so it can carry its
-- own menu. The 1.12 client only sends CMSG_GAMEOBJ_USE for types it considers
-- usable, and GENERIC (5) is not one of them. The edit handle (sql/custom/022)
-- is the same trick and has been proving it works since the day it landed.
--
-- The menu is raised on pGOHello, which fires BEFORE the type switch in
-- GameObject::Use; returning true there is what stops the goober state machine
-- deleting the portal after one click. See CLAUDE.md.
--
-- The exit portal stays GENERIC (5). It is walk-through only, and a menu on the
-- way out has nothing to offer yet.
DELETE FROM `gameobject_template` WHERE `entry` IN (100011, 100012);
INSERT INTO `gameobject_template`
    (`entry`, `type`, `displayId`, `name`, `size`, `faction`, `flags`, `script_name`) VALUES
(100011, 10, 21585, 'Home',    1.0, 0, 0, 'go_house_portal'),
(100012,  5, 21585, 'Doorway', 1.0, 0, 0, 'go_house_exit');
