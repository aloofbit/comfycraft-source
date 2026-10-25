-- ============================================================================
--  Official Tortoise-WoW world updates, 2026-09-17 to 2026-10-19  (tw_world)
-- ============================================================================
--  Applied with:
--
--    Get-Content sql\custom\196_upstream_world_4a9b6d5.sql | `
--      DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_world
--
--  The 2 files under source/sql/database_updates/world/ added between
--  4f4fcaa and 4a9b6d5, in filename order, each followed by its `migrations`
--  row. docs/ai/server/upstream.md.
--
--  Re-runnable, unlike 103: the gameobject rows are deleted by guid before
--  they are inserted. The playercreateinfo_item update was already true here
--  (amount 1) and changes nothing.
-- ============================================================================

-- ############################################################ 20261007161727_world

-- Dagran, Ironforge: Moss Agate limited to 3, restocked every 4 hours.
UPDATE `npc_vendor_template`
SET `maxcount` = 3,
    `incrtime` = 14400
WHERE `entry` = 1500149
AND `item` = 1206;

-- Deprecated NPCs near Redwall, Redridge: Bernard Brubaker, Clyde Ranthal,
-- Wilma Ranthal and two horses.
DELETE FROM `creature`
WHERE `guid` IN (
    6163, 6167, 6168, 6169, 6170
    );

-- Florette DeMure, Ambershire: Kingsblood and Wild Steelbloom limited to 2.
UPDATE `npc_vendor`
SET `maxcount` = 2,
    `incrtime` = 14400
WHERE `entry` = 62150
AND `item` IN (
    3355, 3356
    );

-- Starter throwing weapons: 1, not 100.
UPDATE `playercreateinfo_item`
SET `amount` = 1
WHERE `itemid` IN (
    2947, 3111
    );

INSERT INTO `migrations` (`Name`, `Hash`, `AppliedAt`)
SELECT '20261007161727_world', 'manual', NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `migrations` WHERE `Name` = '20261007161727_world');

-- ############################################################ 20261008075941_world

-- Dark Iron Aggression: 11 Stolen Crates in the Dun Morogh camps.
DELETE FROM `gameobject` WHERE `guid` BETWEEN 5027068 AND 5027078;
INSERT INTO `gameobject`
(
    `guid`,
    `id`,
    `map`,
    `position_x`,
    `position_y`,
    `position_z`,
    `orientation`,
    `rotation0`,
    `rotation1`,
    `rotation2`,
    `rotation3`,
    `spawntimesecsmin`,
    `spawntimesecsmax`,
    `animprogress`,
    `state`,
    `spawn_flags`,
    `visibility_mod`
)
VALUES
(5027068, 2020263, 0, -5848.75, -4148.7900390625, 388.54901123046875, 3.9846301078796387, 0, 0, 0.912468611, -0.409146715, 300, 300, 100, 1, 0, 0),
(5027069, 2020263, 0, -5857.0, -4112.6298828125, 389.8349914550781, 2.9479100704193115, 0, 0, 0.995314546, 0.0966899958, 300, 300, 100, 1, 0, 0),
(5027070, 2020263, 0, -5878.830078125, -4113.81982421875, 388.22698974609375, 3.453700065612793, 0, 0, 0.987848311, -0.155421087, 300, 300, 100, 1, 0, 0),
(5027071, 2020263, 0, -5887.830078125, -4129.93994140625, 389.02099609375, 3.330399990081787, 0, 0, 0.995547282, -0.094263509, 300, 300, 100, 1, 0, 0),
(5027072, 2020263, 0, -5903.06982421875, -4137.509765625, 393.6449890136719, 4.869770050048828, 0, 0, 0.649333434, -0.760503841, 300, 300, 100, 1, 0, 0),
(5027073, 2020263, 0, -5897.58984375, -4157.1201171875, 393.9389953613281, 4.791240215301514, 0, 0, 0.678686396, -0.734428196, 300, 300, 100, 1, 0, 0),
(5027074, 2020263, 0, -5890.759765625, -4157.259765625, 393.4129943847656, 5.161940097808838, 0, 0, 0.5317136, -0.846924228, 300, 300, 100, 1, 0, 0),
(5027075, 2020263, 0, -5872.43994140625, -4150.31982421875, 389.37799072265625, 0.0285801999270916, 0, 0, 0.0142896136, 0.999897898, 300, 300, 100, 1, 0, 0),
(5027076, 2020263, 0, -5874.56982421875, -4142.0400390625, 387.6080017089844, 6.013319969177246, 0, 0, 0.134523592, -0.990910391, 300, 300, 100, 1, 0, 0),
(5027077, 2020263, 0, -5873.93994140625, -4091.469970703125, 389.27099609375, 1.4273799657821655, 0, 0, 0.654627669, 0.755951463, 300, 300, 100, 1, 0, 0),
(5027078, 2020263, 0, -5852.85009765625, -4088.489990234375, 386.7449951171875, 5.686590194702148, 0, 0, 0.293893373, -0.955838211, 300, 300, 100, 1, 0, 0);

UPDATE `gameobject_template`
SET `flags` = 4
WHERE `entry` = 2020263;

INSERT INTO `migrations` (`Name`, `Hash`, `AppliedAt`)
SELECT '20261008075941_world', 'manual', NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `migrations` WHERE `Name` = '20261008075941_world');
