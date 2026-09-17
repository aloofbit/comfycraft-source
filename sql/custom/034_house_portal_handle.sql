-- The clickable gear that sits in the middle of an entrance portal (tw_world).
--
-- WHY THIS EXISTS AT ALL: the purple swirl cannot be moused over. Its model,
-- Creature_Spellportal_Purple.m2, carries no hit volume, so the 1.12 client
-- never sends CMSG_GAMEOBJ_USE for it and no server-side work can help. Proven
-- by swapping the SAME object to displayId 451 (the edit handle gear), which is
-- immediately clickable, and by an interact-keybind addon driving the portal
-- successfully -- the server side was correct the whole time.
--
-- WHAT DOES NOT ANSWER THIS QUESTION: vmaps/temp_gameobject_models lists 21585
-- as HAVING a collision model. Server-side collision and client-side mouse
-- picking are unrelated. Like which WMOs render their portals, this is a tested
-- whitelist and nothing on disk predicts it.
--
-- Type 10 (GOOBER) is what makes it usable, and it must be CREATED
-- GO_STATE_READY -- Map::SummonGameObject hardcodes that, which is why summoned
-- handles have always worked. See CLAUDE.md.

DELETE FROM `gameobject_template` WHERE `entry` = 100013;
INSERT INTO `gameobject_template`
    (`entry`, `type`, `displayId`, `name`, `size`, `faction`, `flags`, `script_name`) VALUES
(100013, 10, 451, 'Portal Handle', 0.15, 0, 0, 'go_house_portal_mark');
