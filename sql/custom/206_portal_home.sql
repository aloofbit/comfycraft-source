-- Portal Home: the house owner's spell and the portal it opens (tw_world).
-- docs/ai/housing/home-portal.md.
--
-- Spell 63000 is made in code (AddComfyHomePortalSpell, SpellMgr.cpp) as a copy
-- of Portal: Stormwind (10059). This row exists only so that
-- SpellMgr::LoadSpellScriptNames binds the script: the Spell.dbc loader reads
-- nothing else from spell_template. The client row is COMFY in
-- patches/build-patch-v.js.
--
-- Gameobject 100015 is the portal. Type 10 (GOOBER) so the client sends a use,
-- created GO_STATE_READY by Map::SummonGameObject so it can be clicked. Display
-- 4396 is the mage portal model, which has a hit volume. The house door swirl
-- (21585) has none and cannot be clicked: see 034.
--
-- Re-runnable. Neither table has a reload: apply this, then restart the server
-- with the binary that has the script, or the spell's script name is unknown.

DELETE FROM `gameobject_template` WHERE `entry` = 100015;
INSERT INTO `gameobject_template`
    (`entry`, `type`, `displayId`, `name`, `size`, `faction`, `flags`, `script_name`) VALUES
(100015, 10, 4396, 'House Portal', 1, 0, 0, 'go_house_home_portal');

DELETE FROM `spell_template` WHERE `entry` = 63000;
CREATE TEMPORARY TABLE comfy_portal_home AS SELECT * FROM `spell_template` WHERE `entry` = 10059;
UPDATE comfy_portal_home SET
  `entry` = 63000,
  `name` = 'Portal Home',
  `description` = 'Opens a portal to your house for 5 min. You and your party can use it.',
  `script_name` = 'spell_house_portal_home';
INSERT INTO `spell_template` SELECT * FROM comfy_portal_home;
DROP TEMPORARY TABLE comfy_portal_home;
