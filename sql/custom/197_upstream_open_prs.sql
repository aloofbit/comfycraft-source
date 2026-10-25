-- ============================================================================
--  SQL from open Tortoise-WoW pull requests, taken 2026-10-24  (tw_world)
-- ============================================================================
--  Applied with:
--
--    Get-Content sql\custom\197_upstream_open_prs.sql | `
--      DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_world
--
--  Re-runnable. Upstream has not merged these yet. When it does, they come
--  back under sql/database_updates/ and must be skipped:
--  docs/ai/server/upstream.md, "What we took from open PRs".
-- ============================================================================

-- #625: the Tower of Karazhan (map 814) entrance and exit. Both triggers are in
-- areatrigger_template but had no teleport rows, so the door did nothing. The
-- entrance needs level 60 and the Upper Karazhan Tower Key (condition 61234).
DELETE FROM `areatrigger_teleport` WHERE `id` IN (5340, 5341);
INSERT INTO `areatrigger_teleport` (`id`, `name`, `message`, `required_level`, `required_condition`, `required_phase`, `target_map`, `target_position_x`, `target_position_y`, `target_position_z`, `target_orientation`) VALUES
(5340, 'Tower of Karazhan - Entrance', 'You must be part of a Raid group, at least level 60 and have the Upper Karazhan Tower Key to enter.', 60, 61234, 0, 814, -11048.2, -1985.84, 101.574, 2.1964),
(5341, 'Tower of Karazhan - Exit', '', 0, 0, 0, 0, -11033.6, -2005.54, 93.417, 5.4835);

-- Holding the Upper Karazhan Tower Key (item 61234). The key goes on the
-- keyring, which CONDITION_ITEM counts.
DELETE FROM `conditions` WHERE `condition_entry` = 61234;
INSERT INTO `conditions` (`condition_entry`, `type`, `value1`, `value2`, `value3`, `value4`, `flags`) VALUES
(61234, 2, 61234, 1, 0, 0, 0);

-- #621: Cho'Rush the Observer (14324) holds the weapon of the class variant he
-- rolled. boss_gordok_king.cpp loads equipment 12070 (priest), 12071 (shaman)
-- and 12072 (mage), and none of the three rows existed.
REPLACE INTO `creature_equip_template` (`entry`, `equipentry1`, `equipentry2`, `equipentry3`) VALUES
(12070, 2176, 0, 0),
(12071, 17113, 0, 0),
(12072, 14618, 0, 0);

-- #632: broadcast_text 92031 names emote 55, which Emotes.dbc does not have.
-- The core already sets it to 0 in memory at startup; this stops the warning.
UPDATE `broadcast_text` SET `emote_id1` = 0
WHERE `entry` = 92031 AND `emote_id1` = 55;

-- #632: Duke Dreadmoore (61972) speaks without a voice. Sounds 60443 and 60444
-- are in the client's SoundEntries.dbc but not in sound_entries, so the core
-- drops them and plays the lines silently.
INSERT IGNORE INTO `sound_entries` (`id`, `name`) VALUES
(60443, 'Dukedread1'),
(60444, 'Dukedread2');
