-- 069: let warriors and rogues value a ranged weapon at all.
--
-- Applies to tw_world.
--
-- THE PROBLEM
--
-- A warrior companion could not pull, because AttackAnythingAction gates the
-- automatic pull on being a druid or paladin OR holding ammo
-- (ChooseTargetActions.cpp:68), PlayerbotFactory::InitAmmo returns immediately
-- unless a ranged weapon is equipped, and warriors below level 30 usually had
-- no ranged weapon at all. Measured against the live random-bot population on
-- 2026-09-06:
--
--     level band   warriors   with no ranged weapon
--       0-9          101              48
--      10-19         104              13
--      20-29          82              35      <- 43%
--      30-59         269               0
--      60           125               4
--
-- and every level 20-29 warrior that DID have one was carrying one of just two
-- items, both RARE bows that happen to have stats on them:
--
--     3021  Ranger Bow        rare, req 20   (32 bots)
--     6696  Nightstalker Bow  rare, req 27   (15 bots)
--
-- THE CAUSE
--
-- Gear is chosen by stat weight, and RandomItemMgr::CalculateStatWeight scores
-- a weapon's dps through the "rgddps" (ranged) or "mledps" (melee) scale entry.
-- Warrior and rogue scales have NO rgddps row -- only the three hunter specs
-- do. So an ordinary gun or bow, which carries dps and no stats, scored exactly
-- zero, and InitEquipment skips anything scoring zero. The only ranged weapons
-- that could ever be picked were the ones carrying agility or stamina, which at
-- low level means those two rare bows.
--
-- This is a data gap, not a code bug, and it had nothing to do with weapon
-- proficiency: InitAllSkills already grants warriors Bows, Guns, Crossbows and
-- Thrown, and it is not gated to random bots.
--
-- THE VALUES
--
-- Deliberately small. Scale magnitudes for comparison: prot warrior has
-- str 7, sta 6, agi 4, mledps 28; combat rogue has agi 4, mledps 10; the three
-- hunter specs use rgddps 14. Weighting is a plain multiply
-- (weight x value), so warrior 7 gives a level 20 gun at ~9 dps a score of 63
-- -- enough to be chosen over nothing, still less than Ranger Bow scores once
-- its stats are counted. The intent is "a warrior should own a gun", not "a
-- warrior should shop for a better gun".
--
-- Rogues are included because they have the same gap and InitAmmo covers the
-- same three classes. Hunters already had it.
--
-- NOT RELOADABLE. ai_playerbot_weightscale_data is read by RandomItemMgr at
-- startup and baked into the item cache, so this needs a restart, and existing
-- bots keep their empty ranged slot until they are re-rolled (.bot init) or,
-- for companions, next hired.

DELETE FROM `ai_playerbot_weightscale_data`
WHERE `id` IN (1, 2, 3, 10, 11, 12) AND `field` = 'rgddps';

INSERT INTO `ai_playerbot_weightscale_data` (`id`, `field`, `val`) VALUES
-- warrior: arms, fury, prot
(1,  'rgddps', 7),
(2,  'rgddps', 7),
(3,  'rgddps', 7),
-- rogue: assassination, combat, subtlety
(10, 'rgddps', 5),
(11, 'rgddps', 5),
(12, 'rgddps', 5);
