-- ============================================================================
--  Official Tortoise-WoW world updates, 2026-08-21 to 2026-09-16  (tw_world)
-- ============================================================================
--  Applied with:
--
--    Get-Content sql\custom\103_upstream_world_4f4fcaa.sql | `
--      DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_world
--
--  then a restart on a binary built from 0615438 or later. That binary reads
--  skill_race_class_info_mod at startup, and a missing table is a hard crash,
--  so this file must land BEFORE it starts.
--
--  The 30 files under source/sql/database_updates/world/ that this install
--  had never applied, concatenated in filename order, each followed by its
--  `migrations` row. Locally they went in one by one on 2026-09-17; this is
--  how the VPS gets them, since the deploy applies sql/custom and nothing
--  under source/. docs/ai/server/upstream.md.
--
--  NOT RE-RUNNABLE, unlike the rest of sql/custom: upstream's files INSERT
--  without deleting first. It was dry-run against a copy of the touched
--  tables before it was applied. 20260903063722 carries one DELETE of ours
--  (spell_proc_event 44070, which the fork had already inserted).
-- ============================================================================

-- ############################################################ 20260821154713_world

-- ==============================================
-- FILE: a_trainer_cleanup.sql
-- GENERATED: 20260821154713
-- ==============================================
DELETE from`creature`
WHERE `guid` IN (
    2583705, 2583704, 2594011, 2594012, 2583713, 2583714, 2583710, 2583711, 2583715, 2583708,
    2583709, 2583701, 2583712
    );

-- ==============================================
-- FILE: broadcast_text_survival_trailers.sql
-- GENERATED: 20260821154713
-- ==============================================
INSERT INTO `broadcast_text`
(
    `entry`,
    `male_text`,
    `female_text`,
    `chat_type`,
    `sound_id`,
    `language_id`,
    `emote_id1`,
    `emote_id2`,
    `emote_id3`,
    `emote_delay1`,
    `emote_delay2`,
    `emote_delay3`
)
VALUES
(6295001, 'The Kaldorei have lived in the woods of Kalimdor for countless years, and tamed its ruthlessness. It is not an easy path, but fending and providing for yourself in the great outdoors is crucial if you wish to see the moonlight of the next night.', 'The Kaldorei have lived in the woods of Kalimdor for countless years, and tamed its ruthlessness. It is not an easy path, but fending and providing for yourself in the great outdoors is crucial if you wish to see the moonlight of the next night.', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(6295501, 'You should always be well prepared when venturing into the wilds. Don''t underestimate the importance of thorough planning.', 'You should always be well prepared when venturing into the wilds. Don''t underestimate the importance of thorough planning.', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(6295301, 'I met Eissinn when I was wandering the high ridges during a heavy snowstorm. Certain my end was near, I cowered behind a stone, trying to stay warm. I soon lost consciousness and when I came back to me, this absolute beast of a lass had hauled me from my hiding spot to her mountain shelter. That''s when I knew: This woman will be my wife, even if I have to move mountains to make it happen.', 'I met Eissinn when I was wandering the high ridges during a heavy snowstorm. Certain my end was near, I cowered behind a stone, trying to stay warm. I soon lost consciousness and when I came back to me, this absolute beast of a lass had hauled me from my hiding spot to her mountain shelter. That''s when I knew: This woman will be my wife, even if I have to move mountains to make it happen.', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(6295401, 'Eager to go out into the wild, eh? A warm hearth and a foamy ale is wonderful and all, but the thrill of a good mountain hike is something irreplaceable. Come closer, and I''ll tell you the dwarven ways of surviving in the icy cold of Dun Morogh.', 'Eager to go out into the wild, eh? A warm hearth and a foamy ale is wonderful and all, but the thrill of a good mountain hike is something irreplaceable. Come closer, and I''ll tell you the dwarven ways of surviving in the icy cold of Dun Morogh.', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(6307201, 'The rest of Desolace used to be more akin to the greenery you see here at Nijel''s Point. But eventually, all life got drained from its soil and only barren death remained. If you are willing to listen and pay, I can tutor you in more advanced survival techniques that may save your life out there.', 'The rest of Desolace used to be more akin to the greenery you see here at Nijel''s Point. But eventually, all life got drained from its soil and only barren death remained. If you are willing to listen and pay, I can tutor you in more advanced survival techniques that may save your life out there.', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(6295701, 'There are many ways in which you can utilize nature to your advantage. With a little bit of creativity and expertise, you can turn even the most mundane things into something useful.', 'There are many ways in which you can utilize nature to your advantage. With a little bit of creativity and expertise, you can turn even the most mundane things into something useful.', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(6295601, 'We have not survived the deadly heat of Durotar by sheer luck. Our people are resilient, but moreso, they are resourceful. You ought to hone your instincts and skill, otherwise you''ll not make it for long out there.', 'We have not survived the deadly heat of Durotar by sheer luck. Our people are resilient, but moreso, they are resourceful. You ought to hone your instincts and skill, otherwise you''ll not make it for long out there.', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(6295901, 'For many years we have traveled across the lands of Kalimdor, persecuted by the centaur marauders. During that time, we learned much from the land, its dangers and its intransigence. If you wish to survive, you have to fight tooth and nail for it, as there is no mercy for you out there.', 'For many years we have traveled across the lands of Kalimdor, persecuted by the centaur marauders. During that time, we learned much from the land, its dangers and its intransigence. If you wish to survive, you have to fight tooth and nail for it, as there is no mercy for you out there.', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(6295801, 'The plains offer plentiful bounties, enough to benefit from the Earthmother''s blessing without depriving her off her natural beauty.', 'The plains offer plentiful bounties, enough to benefit from the Earthmother''s blessing without depriving her off her natural beauty.', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(6307101, 'The swamp is without remorse. One small misstep, a breaking twig or even the fumes of the bog can be enough to bring even the most battlehardened warrior to their knees. If you are willing to listen and pay, I can train you in more advanced survival techniques that may save your life out there.', 'The swamp is without remorse. One small misstep, a breaking twig or even the fumes of the bog can be enough to bring even the most battlehardened warrior to their knees. If you are willing to listen and pay, I can train you in more advanced survival techniques that may save your life out there.', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(6296601, 'I remember hiding in the forest from the despicable monster calling itself my mother, back when I was not a slave to this curse. Hours at a time, sometimes even days. The skills I had back then I still possess, and I can share my knowledge from that wretched time with you, for a price.', 'I remember hiding in the forest from the despicable monster calling itself my mother, back when I was not a slave to this curse. Hours at a time, sometimes even days. The skills I had back then I still possess, and I can share my knowledge from that wretched time with you, for a price.', 0, 0, 0, 0, 0, 0, 0, 0, 0);

-- ==============================================
-- FILE: creature_addon_survival_trainers.sql
-- GENERATED: 20260821154713
-- ==============================================
INSERT INTO `creature_addon`
(
    `guid`,
    `display_id`,
    `mount_display_id`,
    `equipment_id`,
    `stand_state`,
    `sheath_state`,
    `emote_state`,
    `auras`
)
VALUES
(2594024, 0, 0, -1, 8, 1, 0, NULL);

-- ==============================================
-- FILE: creature_equip_template_survival_trailers.sql
-- GENERATED: 20260821154713
-- ==============================================
INSERT INTO `creature_equip_template`
(
    `entry`,
    `equipentry1`,
    `equipentry2`,
    `equipentry3`
)
VALUES
(62951, 13721, 0, 0),
(62952, 0, 0, 0),
(62957, 0, 12859, 0),
(62959, 0, 2715, 0),
(62962, 51768, 0, 0);

-- ==============================================
-- FILE: creature_survival_trainers.sql
-- GENERATED: 20260821154713
-- ==============================================
INSERT INTO `creature`
(
    `guid`,
    `id`,
    `id2`,
    `id3`,
    `id4`,
    `map`,
    `position_x`,
    `position_y`,
    `position_z`,
    `orientation`,
    `spawntimesecsmin`,
    `spawntimesecsmax`,
    `wander_distance`,
    `health_percent`,
    `mana_percent`,
    `movement_type`,
    `spawn_flags`,
    `visibility_mod`
)
VALUES
(2594006, 62951, 0, 0, 0, 0, -9075.900391, 338.161011, 93.039001, 2.2482662200927734, 300, 300, 0, 100, 100, 0, 0, 0),
(2594008, 62952, 0, 0, 0, 0, -9079.009766, 345.983002, 92.836998, 3.7081000804901123, 300, 300, 0, 100, 100, 0, 0, 0),
(2594011, 62953, 0, 0, 0, 0, -4906.22998, -1171.040039, 503.820007, 5.023709774017334, 300, 300, 0, 100, 100, 0, 0, 0),
(2594012, 62954, 0, 0, 0, 0, -4908.459961, -1181.599976, 503.820007, 1.2761906385421753, 300, 300, 0, 100, 100, 0, 0, 0),
(2594025, 62962, 0, 0, 0, 0, 4418.410156, -3001.77002, 10.654, 2.173328161239624, 300, 300, 0, 100, 100, 0, 0, 0),
(2595984, 63071, 0, 0, 0, 0, -10429.299805, -3292.040039, 20.558701, 1.6020750999450684, 300, 300, 0, 100, 100, 0, 0, 0),
(2594013, 62955, 0, 0, 0, 1, 10058.400391, 2390.030029, 1324.209961, 0.3502260148525238, 300, 300, 0, 100, 100, 0, 0, 0),
(2594015, 62950, 0, 0, 0, 1, 10060.099609, 2399.139893, 1324.189941, 5.221033096313477, 300, 300, 0, 100, 100, 0, 0, 0),
(2595980, 63072, 0, 0, 0, 1, 221.001007, 1336.380005, 193.692993, 5.224803447723389, 300, 300, 0, 100, 100, 0, 0, 0),
(2594017, 62956, 0, 0, 0, 1, 2015.040039, -4636.819824, 28.881701, 3.259718894958496, 300, 300, 0, 100, 100, 0, 0, 0),
(2594018, 62957, 0, 0, 0, 1, 2015.160034, -4629.879883, 29.3866, 4.246870040893555, 300, 300, 0, 100, 100, 0, 0, 0),
(2594023, 62959, 0, 0, 0, 1, -2284.590088, -254.237, -9.42481, 3.477530002593994, 300, 300, 0, 100, 100, 0, 0, 0),
(2594024, 62958, 0, 0, 0, 1, -2281.449951, -247.662994, -9.42481, 5.765170097351074, 300, 300, 0, 100, 100, 0, 0, 0),
(2594047, 62966, 0, 0, 0, 0, 2286.969971, 301.011993, 35.188099, 2.3612568378448486, 300, 300, 0, 100, 100, 0, 0, 0),
(2594792, 5202, 0, 0, 0, 0, 2224.159912, 292.074005, 35.1894, 5.602610111236572, 300, 300, 0, 100, 100, 0, 0, 0);

-- ==============================================
-- FILE: creature_template_update_survivial_trainers.sql
-- GENERATED: 20260821154713
-- ==============================================
UPDATE `creature_template`
SET `gossip_menu_id` = `entry`,
    `speed_walk` = 1,
    `speed_run` = 1.14286,
    `scale` = 1,
    `dmg_min` = 0,
    `dmg_max` = 0,
    `attack_power` = 136,
    `ranged_dmg_min` = 0,
    `ranged_dmg_max` = 0,
    `ranged_attack_power` = 112
WHERE `entry` = 62950;

UPDATE `creature_template`
SET `gossip_menu_id` = `entry`,
    `speed_walk` = 1,
    `speed_run` = 1.14286,
    `scale` = 1,
    `dmg_min` = 43.927868,
    `dmg_max` = 55.432785,
    `attack_power` = 102,
    `ranged_dmg_min` = 42.977089,
    `ranged_dmg_max` = 59.093498,
    `ranged_attack_power` = 84,
    `equipment_id` = `entry`
WHERE `entry` = 62951;

UPDATE `creature_template`
SET `gossip_menu_id` = `entry`,
    `speed_walk` = 1,
    `speed_run` = 1.14286,
    `scale` = 1,
    `dmg_min` = 38.984402,
    `dmg_max` = 49.303848,
    `attack_power` = 90,
    `ranged_dmg_min` = 36.67664,
    `ranged_dmg_max` = 50.430382,
    `ranged_attack_power` = 72,
    `equipment_id` = `entry`
WHERE `entry` = 62952;

UPDATE `creature_template`
SET `gossip_menu_id` = `entry`,
    `speed_walk` = 1,
    `speed_run` = 1.14286,
    `scale` = 1,
    `dmg_min` = 52.9375,
    `dmg_max` = 67.375,
    `attack_power` = 84,
    `ranged_dmg_min` = 47.951763,
    `ranged_dmg_max` = 65.93367,
    `ranged_attack_power` = 66
WHERE `entry` = 62953;

UPDATE `creature_template`
SET `gossip_menu_id` = `entry`,
    `speed_walk` = 1,
    `speed_run` = 1.14286,
    `scale` = 1,
    `dmg_min` = 24.639999,
    `dmg_max` = 31.826666,
    `attack_power` = 70,
    `ranged_dmg_min` = 27.842146,
    `ranged_dmg_max` = 38.282948,
    `ranged_attack_power` = 58
WHERE `entry` = 62954;

UPDATE `creature_template`
SET `gossip_menu_id` = `entry`,
    `speed_walk` = 1,
    `speed_run` = 1.14286,
    `scale` = 1,
    `dmg_min` = 46.131252,
    `dmg_max` = 59.760937,
    `attack_power` = 108,
    `ranged_dmg_min` = 45.877144,
    `ranged_dmg_max` = 63.081074,
    `ranged_attack_power` = 88
WHERE `entry` = 62955;

UPDATE `creature_template`
SET `gossip_menu_id` = `entry`,
    `speed_walk` = 1,
    `speed_run` = 1.14286,
    `scale` = 1,
    `dmg_min` = 39.637932,
    `dmg_max` = 50.068966,
    `attack_power` = 96,
    `ranged_dmg_min` = 39.813805,
    `ranged_dmg_max` = 54.743984,
    `ranged_attack_power` = 78
WHERE `entry` = 62956;

UPDATE `creature_template`
SET `gossip_menu_id` = `entry`,
    `speed_walk` = 1,
    `speed_run` = 1.14286,
    `scale` = 1,
    `dmg_min` = 48.299999,
    `dmg_max` = 60.900002,
    `attack_power` = 112,
    `ranged_dmg_min` = 47.616306,
    `ranged_dmg_max` = 65.47242,
    `ranged_attack_power` = 92,
    `equipment_id` = `entry`
WHERE `entry` = 62957;

UPDATE `creature_template`
SET `gossip_menu_id` = `entry`,
    `speed_walk` = 1,
    `speed_run` = 1.14286,
    `scale` = 1,
    `dmg_min` = 60.225002,
    `dmg_max` = 78.186844,
    `attack_power` = 132,
    `ranged_dmg_min` = 56.932758,
    `ranged_dmg_max` = 78.282539,
    `ranged_attack_power` = 108
WHERE `entry` = 62958;

UPDATE `creature_template`
SET `gossip_menu_id` = `entry`,
    `speed_walk` = 1,
    `speed_run` = 1.14286,
    `scale` = 1,
    `dmg_min` = 91.0177,
    `dmg_max` = 116.716812,
    `attack_power` = 206,
    `ranged_dmg_min` = 75.210083,
    `ranged_dmg_max` = 103.413864,
    `ranged_attack_power` = 144,
    `equipment_id` = `entry`
WHERE `entry` = 62959;

UPDATE `creature_template`
SET `gossip_menu_id` = `entry`,
    `speed_walk` = 1,
    `speed_run` = 1.14286,
    `scale` = 1,
    `dmg_min` = 91.0177,
    `dmg_max` = 116.716812,
    `attack_power` = 206,
    `ranged_dmg_min` = 75.210083,
    `ranged_dmg_max` = 103.413864,
    `ranged_attack_power` = 144,
    `equipment_id` = `entry`
WHERE `entry` = 62962;

UPDATE `creature_template`
SET `gossip_menu_id` = `entry`,
    `speed_walk` = 1,
    `speed_run` = 1.14286,
    `scale` = 1,
    `dmg_min` = 64.519226,
    `dmg_max` = 82.5,
    `attack_power` = 136,
    `ranged_dmg_min` = 58.712193,
    `ranged_dmg_max` = 80.729271,
    `ranged_attack_power` = 112
WHERE `entry` = 63071;

UPDATE `creature_template`
SET `gossip_menu_id` = `entry`,
    `speed_walk` = 1,
    `speed_run` = 1.14286,
    `scale` = 1,
    `dmg_min` = 64.519226,
    `dmg_max` = 82.5,
    `attack_power` = 136,
    `ranged_dmg_min` = 58.712193,
    `ranged_dmg_max` = 80.729271,
    `ranged_attack_power` = 112
WHERE `entry` = 63072;

UPDATE `creature_template`
SET `gossip_menu_id` = `entry`,
    `speed_walk` = 1,
    `speed_run` = 1.14286,
    `scale` = 1,
    `dmg_min` = 91.0177,
    `dmg_max` = 116.716812,
    `attack_power` = 206,
    `ranged_dmg_min` = 75.210083,
    `ranged_dmg_max` = 103.413864,
    `ranged_attack_power` = 144
WHERE `entry` = 62966;


-- ==============================================
-- FILE: gameobect_template_update_survival_trainers.sql
-- GENERATED: 20260821154713
-- ==============================================
update `gameobject_template`
SET `size` = 2
WHERE `entry` = 2020411;

-- ==============================================
-- FILE: gameobject_survival_trainers.sql
-- GENERATED: 20260821154713
-- ==============================================
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
(5026158, 2002764, 0, -9069.2998046875, 344.89599609375, 92.9636001586914, 3.415260076522827, 0, 0, 0.990652866, -0.136407111, 300, 300, 100, 1, 0, 0),
(5026159, 2003527, 0, -9073.26953125, 338.7959899902344, 92.94979858398438, 0.006633040029555559, 0, 0, 0.00331651393, 0.9999945, 300, 300, 100, 1, 0, 0),
(5026163, 2000116, 0, -9073.6103515625, 339.0830078125, 94.22540283203125, 1.2938200235366821, 0, 0, 0.602723631, 0.797950014, 300, 300, 100, 1, 0, 0),
(5026164, 2003544, 0, -9073.4697265625, 337.4840087890625, 93.94020080566406, 2.6996800899505615, 0, 0, 0.975688314, 0.219162756, 300, 300, 100, 1, 0, 0),
(5026165, 2003544, 0, -9073.8603515625, 337.7279968261719, 93.94020080566406, 3.838510036468506, 0, 0, 0.939900108, -0.341449538, 300, 300, 100, 1, 0, 0),
(5026166, 2003377, 0, -9072.599609375, 338.3080139160156, 93.95369720458984, 3.2078299522399902, 0, 0, 0.999451628, -0.0331125953, 300, 300, 100, 1, 0, 0),
(5026167, 61101, 0, -9080.150390625, 346.7340087890625, 92.85459899902344, 4.552430152893066, 0, 0, 0.761340121, -0.648352697, 300, 300, 100, 1, 0, 0),
(5026168, 61101, 0, -9083.759765625, 345.281005859375, 92.95709991455078, 5.849899768829346, 0, 0, 0.214952086, -0.976624596, 300, 300, 100, 1, 0, 0),
(5026169, 2002232, 0, -9067.5703125, 343.8489990234375, 93.15039825439453, 3.425379991531372, 0, 0, 0.989949972, -0.141418005, 300, 300, 100, 1, 0, 0),
(5026170, 2003528, 0, -9068.25, 346.9630126953125, 93.02970123291016, 3.4183099269866943, 0, 0, 0.990443703, -0.137917623, 300, 300, 100, 1, 0, 0),
(5026171, 2000072, 0, -9068.4501953125, 346.4469909667969, 94.15799713134766, 4.144800186157227, 0, 0, 0.876812547, -0.480832359, 300, 300, 100, 1, 0, 0),
(5026172, 2003196, 0, -9067.6201171875, 346.7340087890625, 94.15799713134766, 3.49685001373291, 0, 0, 0.984265463, -0.176696064, 300, 300, 100, 1, 0, 0),
(5026173, 2003195, 0, -9067.8603515625, 347.4410095214844, 94.15779876708984, 6.155409812927246, 0, 0, 0.0638442948, -0.997959872, 300, 300, 100, 1, 0, 0),
(5026174, 2004235, 0, -9068.8095703125, 347.20098876953125, 94.15809631347656, 4.352139949798584, 0, 0, 0.822346426, -0.568987131, 300, 300, 100, 1, 0, 0),
(5026175, 2004203, 0, -9072.150390625, 346.51800537109375, 92.96170043945312, 5.7846999168396, 0, 0, 0.246670126, -0.969099504, 300, 300, 100, 1, 0, 0),
(5026176, 2004203, 0, -9071.3203125, 346.7040100097656, 93.00440216064453, 5.00793981552124, 0, 0, 0.59528697, -0.803513175, 300, 300, 100, 1, 0, 0),
(5026177, 2001881, 0, -9080.9697265625, 346.5780029296875, 92.86830139160156, 4.579100131988525, 0, 0, 0.75262691, -0.658447214, 300, 300, 100, 1, 0, 0),
(5026178, 2001882, 0, -9072.099609375, 346.59100341796875, 93.92160034179688, 2.170289993286133, 0, 0, 0.884371106, 0.466784476, 300, 300, 100, 1, 0, 0),
(5026179, 2003230, 0, -9072.5498046875, 348.6889953613281, 93.02259826660156, 3.765439987182617, 0, 0, 0.951744977, -0.306890043, 300, 300, 100, 1, 0, 0),
(5026180, 2003230, 0, -9070.849609375, 348.8210144042969, 93.19730377197266, 1.1029399633407593, 0, 0, 0.523939859, 0.851755261, 300, 300, 100, 1, 0, 0),
(5026181, 2003229, 0, -9072.5400390625, 348.5780029296875, 94.2666015625, 1.8655699491500854, 0, 0, 0.803281782, 0.595599176, 300, 300, 100, 1, 0, 0),
(5026182, 2002392, 0, -9069.240234375, 349.12701416015625, 93.1552963256836, 2.472949981689453, 0, 0, 0.944633216, 0.328128157, 300, 300, 100, 1, 0, 0),
(5026184, 2003227, 0, -9070.6904296875, 341.52398681640625, 93.10320281982422, 1.9663599729537964, 0, 0, 0.832264493, 0.554378764, 300, 300, 100, 1, 0, 0),
(5026185, 2003258, 0, -9071.1103515625, 342.3330078125, 93.0696029663086, 1.1534700393676758, 0, 0, 0.545289987, 0.838247476, 300, 300, 100, 1, 0, 0),
(5026186, 2002655, 0, -9072.5400390625, 346.86199951171875, 92.84310150146484, 2.9535999298095703, 0, 0, 0.995585594, 0.0938580084, 300, 300, 100, 1, 0, 0),
(5026190, 2003829, 1, 2008.280029296875, -4633.080078125, 28.46619987487793, 5.465390205383301, 0, 0, 0.397598007, -0.917559712, 300, 300, 100, 1, 0, 0),
(5026191, 2003813, 1, 2018.6400146484375, -4630.33984375, 29.780099868774414, 3.8278400897979736, 0, 0, 0.941708348, -0.33643036, 300, 300, 100, 1, 0, 0),
(5026192, 2003813, 1, 2019.0, -4628.3701171875, 30.214799880981445, 3.5293900966644287, 0, 0, 0.981260466, -0.192686011, 300, 300, 100, 1, 0, 0),
(5026193, 2003825, 1, 2017.510009765625, -4629.22998046875, 29.77199935913086, 3.212090015411377, 0, 0, 0.99937883, -0.0352413821, 300, 300, 100, 1, 0, 0),
(5026196, 2002764, 1, -2276.3798828125, -254.177001953125, -9.424079895019531, 2.749500036239624, 0, 0, 0.980844393, 0.194792907, 300, 300, 100, 1, 0, 0),
(5026197, 2004695, 1, -2271.820068359375, -257.8370056152344, -9.424799919128418, 4.860630035400391, 0, 0, 0.652802149, -0.757528451, 300, 300, 100, 1, 0, 0),
(5026199, 2003812, 1, -2276.7099609375, -259.18701171875, -9.424850463867188, 3.0432000160217285, 0, 0, 0.998790105, 0.0491764764, 300, 300, 100, 1, 0, 0),
(5026200, 2003812, 1, -2278.489990234375, -258.1549987792969, -9.424850463867188, 3.9699699878692627, 0, 0, 0.915443141, -0.402447334, 300, 300, 100, 1, 0, 0),
(5026201, 2003812, 1, -2278.31005859375, -259.6809997558594, -9.424850463867188, 3.4319798946380615, 0, 0, 0.989477911, -0.144684016, 300, 300, 100, 1, 0, 0),
(5026202, 2003815, 1, -2280.030029296875, -258.3500061035156, -9.424750328063965, 3.3958499431610107, 0, 0, 0.991930031, -0.126786486, 300, 300, 100, 1, 0, 0),
(5026203, 2003829, 1, -2280.080078125, -258.1919860839844, -9.424839973449707, 5.375050067901611, 0, 0, 0.438624602, -0.898670384, 300, 300, 100, 1, 0, 0),
(5026204, 2003968, 1, -2273.989990234375, -253.125, -9.42490005493164, 3.333019971847534, 0, 0, 0.995422944, -0.0955675856, 300, 300, 100, 1, 0, 0),
(5026205, 2004703, 1, -2277.27001953125, -255.76199340820312, -9.424949645996094, 5.843929767608643, 0, 0, 0.217866349, -0.975978613, 300, 300, 100, 1, 0, 0),
(5026206, 2004599, 1, -2275.75, -256.8320007324219, -9.424949645996094, 1.996269941329956, 0, 0, 0.840461842, 0.541870733, 300, 300, 100, 1, 0, 0),
(5026208, 2004600, 1, -2277.389892578125, -256.2590026855469, -9.424819946289062, 2.1085801124572754, 0, 0, 0.869549845, 0.493845186, 300, 300, 100, 1, 0, 0),
(5026209, 1000018, 1, -2274.010009765625, -253.10400390625, -8.7122802734375, 3.4186201095581055, 0, 0, 0.990422301, -0.138071231, 300, 300, 100, 1, 0, 0),
(5026210, 2003825, 1, -2277.550048828125, -250.9810028076172, -9.424909591674805, 4.965060234069824, 0, 0, 0.612375994, -0.790566659, 300, 300, 100, 1, 0, 0),
(5026213, 2003580, 1, -2278.780029296875, -249.8719940185547, -9.424850463867188, 2.919110059738159, 0, 0, 0.993819065, 0.111012011, 300, 300, 100, 1, 0, 0),
(5026214, 2003580, 1, -2278.7900390625, -247.92799377441406, -9.42488956451416, 3.834089994430542, 0, 0, 0.940652423, -0.339371506, 300, 300, 100, 1, 0, 0),
(5026215, 2003580, 1, -2280.449951171875, -248.60800170898438, -9.424839973449707, 6.127449989318848, 0, 0, 0.0777889927, -0.996969845, 300, 300, 100, 1, 0, 0),
(5026216, 2003580, 1, -2279.27001953125, -248.61099243164062, -9.424830436706543, 4.231510162353516, 0, 0, 0.855148673, -0.51838282, 300, 300, 100, 1, 0, 0),
(5026217, 2010645, 0, 4422.97021484375, -3001.43994140625, 10.536999702453613, 3.328779935836792, 0, 0, 0.995623311, -0.0934570578, 300, 300, 100, 1, 0, 0),
(5026218, 2003230, 0, 4420.93017578125, -2998.080078125, 10.604700088500977, 2.2518699169158936, 0, 0, 0.902670332, 0.430332746, 300, 300, 100, 1, 0, 0),
(5026219, 2003230, 0, 4422.72021484375, -2997.570068359375, 10.548100471496582, 1.7924200296401978, 0, 0, 0.780965397, 0.624574294, 300, 300, 100, 1, 0, 0),
(5026220, 2003228, 0, 4421.89013671875, -2996.719970703125, 10.595999717712402, 2.0028998851776123, 0, 0, 0.842253507, 0.539081654, 300, 300, 100, 1, 0, 0),
(5026221, 2004203, 0, 4424.58984375, -3002.47998046875, 10.55049991607666, 2.456860065460205, 0, 0, 0.941962898, 0.335716991, 300, 300, 100, 1, 0, 0),
(5026222, 2004203, 0, 4425.0498046875, -3001.52001953125, 10.512999534606934, 3.0985300540924072, 0, 0, 0.999768211, 0.0215296361, 300, 300, 100, 1, 0, 0),
(5026223, 2002655, 0, 4422.43017578125, -3003.22998046875, 10.537099838256836, 4.282909870147705, 0, 0, 0.841545386, -0.540186415, 300, 300, 100, 1, 0, 0),
(5026224, 2003580, 0, 4424.8798828125, -3004.60009765625, 10.743599891662598, 3.362420082092285, 0, 0, 0.993910596, -0.110189505, 300, 300, 100, 1, 0, 0),
(5026225, 2003580, 0, 4426.14990234375, -3004.5400390625, 10.770999908447266, 4.46589994430542, 0, 0, 0.788669964, -0.614816792, 300, 300, 100, 1, 0, 0),
(5026226, 2003580, 0, 4425.10009765625, -3005.969970703125, 10.904399871826172, 1.3832099437713623, 0, 0, 0.63777419, 0.770223398, 300, 300, 100, 1, 0, 0),
(5026227, 2004247, 0, 4419.8701171875, -2999.360107421875, 10.62600040435791, 3.229870080947876, 0, 0, 0.999026045, -0.044124383, 300, 300, 100, 1, 0, 0),
(5026228, 2004247, 0, 4419.52001953125, -2998.9599609375, 10.640399932861328, 3.1631100177764893, 0, 0, 0.999942126, -0.0107584745, 300, 300, 100, 1, 0, 0),
(5026229, 2003377, 0, 4422.85009765625, -2997.610107421875, 11.791299819946289, 2.2261300086975098, 0, 0, 0.897057366, 0.441914112, 300, 300, 100, 1, 0, 0),
(5026248, 2003580, 0, -9073.2998046875, 340.1610107421875, 93.94779968261719, 4.612209796905518, 0, 0, 0.741623794, -0.670816032, 300, 300, 100, 1, 0, 0),
(5026249, 2003580, 0, -9072.83984375, 339.45001220703125, 93.95210266113281, 6.1201701164245605, 0, 0, 0.0814173762, -0.996680095, 300, 300, 100, 1, 0, 0),
(5030424, 2020412, 1, 2013.93994140625, -4647.6298828125, 26.64859962463379, 4.034589767456055, 0, 0, 0.901964587, -0.43181001, 300, 300, 100, 1, 0, 0),
(5030425, 2020411, 1, 10072.2001953125, 2388.9599609375, 1327.06005859375, 4.270899772644043, 0, 0, 0.844774039, -0.535123184, 300, 300, 100, 1, 0, 0),
(5030908, 1859, 0, -9081.0595703125, 344.68701171875, 92.88140106201172, 0.0689568966627121, 0, 0, 0.0344716176, 0.999405677, 300, 300, 100, 1, 0, 0),
(5030910, 1859, 1, 2009.56005859375, -4633.85009765625, 28.541500091552734, 4.467450141906738, 0, 0, 0.788193184, -0.615427904, 300, 300, 100, 1, 0, 0),
(5041169, 181987, 0, -9095.83984375, 411.1789855957031, 92.24449920654297, 2.3038299083709717, 0, 0, 0.913544501, 0.406738792, 300, 300, 100, 1, 0, 0),
(5041245, 181987, 0, -9095.83984375, 411.1789855957031, 92.24449920654297, 2.3038299083709717, 0, 0, 0.913544501, 0.406738792, 300, 300, 100, 1, 0, 0),
(5041305, 181987, 0, -9095.83984375, 411.1789855957031, 92.24449920654297, 2.3038299083709717, 0, 0, 0.913544501, 0.406738792, 300, 300, 100, 1, 0, 0),
(5041484, 181987, 0, -9095.83984375, 411.1789855957031, 92.24449920654297, 2.3038299083709717, 0, 0, 0.913544501, 0.406738792, 300, 300, 100, 1, 0, 0),
(5041650, 181987, 0, -9095.83984375, 411.1789855957031, 92.24449920654297, 2.3038299083709717, 0, 0, 0.913544501, 0.406738792, 300, 300, 100, 1, 0, 0),
(5041830, 181987, 0, -9095.83984375, 411.1789855957031, 92.24449920654297, 2.3038299083709717, 0, 0, 0.913544501, 0.406738792, 300, 300, 100, 1, 0, 0),
(5041960, 181987, 0, -9095.83984375, 411.1789855957031, 92.24449920654297, 2.3038299083709717, 0, 0, 0.913544501, 0.406738792, 300, 300, 100, 1, 0, 0),
(5042061, 181987, 0, -9095.83984375, 411.1789855957031, 92.24449920654297, 2.3038299083709717, 0, 0, 0.913544501, 0.406738792, 300, 300, 100, 1, 0, 0),
(5026001, 177044, 0, 2238.56005859375, 254.5030059814453, 34.005401611328125, 2.9741599559783936, 0, 0, 0.996497833, 0.0836185964, 300, 300, 100, 1, 0, 0),
(5026241, 2002767, 0, 2290.909912109375, 299.5840148925781, 35.18349838256836, 2.781830072402954, 0, 0, 0.983864938, 0.178912781, 300, 300, 100, 1, 0, 0),
(5026242, 2002208, 0, 2290.780029296875, 303.3800048828125, 35.187801361083984, 1.9995800256729126, 0, 0, 0.84135751, 0.540478992, 300, 300, 100, 1, 0, 0),
(5026243, 2002208, 0, 2291.68994140625, 302.7900085449219, 35.186500549316406, 1.964229941368103, 0, 0, 0.831673599, 0.555264825, 300, 300, 100, 1, 0, 0),
(5026244, 2003580, 0, 2292.949951171875, 302.6369934082031, 35.18539810180664, 2.0584800243377686, 0, 0, 0.856907486, 0.515470233, 300, 300, 100, 1, 0, 0),
(5026246, 2003437, 0, 2291.929931640625, 304.27398681640625, 35.18899917602539, 1.8605600595474243, 0, 0, 0.801787321, 0.597609481, 300, 300, 100, 1, 0, 0),
(5026247, 2003147, 0, 2290.820068359375, 304.3110046386719, 35.189300537109375, 1.995650053024292, 0, 0, 0.840293852, 0.542131204, 300, 300, 100, 1, 0, 0),
(5030909, 1859, 0, 2284.550048828125, 299.6570129394531, 35.18730163574219, 2.8341400623321533, 0, 0, 0.988207364, 0.15312154, 300, 300, 100, 1, 0, 0);

-- ==============================================
-- FILE: gossip_menu_survival_trainers.sql
-- GENERATED: 20260821154713
-- ==============================================
INSERT INTO `gossip_menu`
(
    `entry`,
    `text_id`,
    `script_id`,
    `condition_id`
)
VALUES
(62950, 6295001, 0, 0),
(62955, 6295501, 0, 0),
(62953, 6295301, 0, 0),
(62954, 6295401, 0, 0),
(63072, 6307201, 0, 0),
(62956, 6295601, 0, 0),
(62957, 6295701, 0, 0),
(62958, 6295801, 0, 0),
(62959, 6295901, 0, 0),
(63071, 6307101, 0, 0),
(62966, 6296601, 0, 0);

-- ==============================================
-- FILE: npc_text_survival_trainers.sql
-- GENERATED: 20260821154713
-- ==============================================
INSERT INTO `npc_text`
(
    `ID`,
    `BroadcastTextID0`,
    `Probability0`,
    `BroadcastTextID1`,
    `Probability1`,
    `BroadcastTextID2`,
    `Probability2`,
    `BroadcastTextID3`,
    `Probability3`,
    `BroadcastTextID4`,
    `Probability4`,
    `BroadcastTextID5`,
    `Probability5`,
    `BroadcastTextID6`,
    `Probability6`,
    `BroadcastTextID7`,
    `Probability7`
)
VALUES
(6295001, 6295001, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0),
(6295501, 6295501, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0),
(6295301, 6295301, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0),
(6295401, 6295401, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0),
(6307201, 6307201, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0),
(6295601, 6295601, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0),
(6295701, 6295701, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0),
(6295801, 6295801, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0),
(6295901, 6295901, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0),
(6307101, 6307101, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0),
(6296601, 6296601, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0);

INSERT INTO `migrations` (`Name`, `Hash`, `AppliedAt`)
SELECT '20260821154713_world', 'manual', NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `migrations` WHERE `Name` = '20260821154713_world');

-- ############################################################ 20260821203635_world

-- ==============================================
-- FILE: update_taxi_path_transitions.sql
-- GENERATED: 20260821203635
-- ==============================================
DELETE FROM `taxi_path_transitions`;

INSERT INTO `taxi_path_transitions`
(
    `in_path`,
    `out_path`,
    `in_node`,
    `out_node`,
    `comment`
)
VALUES
(292,284,20,1,'Everlook, Winterspring -> Valormok, Azshara -> Splintertree Post, Ashenvale'),
(293,178,17,2,'Valormok, Azshara -> Everlook, Winterspring -> Moonglade'),
(292,115,20,3,'Everlook, Winterspring -> Valormok, Azshara -> Thunder Bluff, Mulgore'),
(292,109,20,3,'Everlook, Winterspring -> Valormok, Azshara -> Crossroads, The Barrens'),
(288,253,24,2,'Freewind Post, Thousand Needles -> Camp Mojache, Feralas -> Cenarion Hold, Silithus'),
(288,189,24,2,'Freewind Post, Thousand Needles -> Camp Mojache, Feralas -> Shadowprey Village, Desolace'),
(287,231,27,1,'Camp Mojache, Feralas -> Freewind Post, Thousand Needles -> Camp Taurajo, The Barrens'),
(286,139,11,4,'Revantusk Village, The Hinterlands -> Hammerfall, Arathi -> Kargath, Badlands'),
(285,275,19,2,'Hammerfall, Arathi -> Revantusk Village, The Hinterlands -> Light''s Hope Chapel, Eastern Plaguelands'),
(284,166,22,3,'Valormok, Azshara -> Splintertree Post, Ashenvale -> Zoram''gar Outpost, Ashenvale'),
(283,293,26,2,'Splintertree Post, Ashenvale -> Valormok, Azshara -> Everlook, Winterspring'),
(283,212,27,2,'Splintertree Post, Ashenvale -> Valormok, Azshara -> Bloodvenom Post, Felwood'),
(280,187,20,6,'Stonetalon Peak, Stonetalon Mountains -> Nijel''s Point, Desolace -> Feathermoon, Feralas'),
(280,56,20,7,'Stonetalon Peak, Stonetalon Mountains -> Nijel''s Point, Desolace -> Theramore, Dustwallow Marsh'),
(279,247,25,2,'Nijel''s Point, Desolace -> Stonetalon Peak, Stonetalon Mountains -> Astranaar, Ashenvale'),
(278,103,8,7,'Chillwind Camp, Western Plaguelands -> Aerie Peak, The Hinterlands -> Refuge Pointe, Arathi'),
(276,286,14,1,'Light''s Hope Chapel, Eastern Plaguelands -> Revantusk Village, The Hinterlands -> Hammerfall, Arathi'),
(276,222,14,2,'Light''s Hope Chapel, Eastern Plaguelands -> Revantusk Village, The Hinterlands -> Tarren Mill, Hillsbrad'),
(273,260,22,3,'Feathermoon, Feralas -> Cenarion Hold, Silithus -> Marshal''s Refuge, Un''Goro Crater'),
(272,84,13,4,'Morgan''s Vigil, Burning Steppes -> Lakeshire, Redridge -> Darkshire, Duskwood'),
(271,220,9,4,'Lakeshire, Redridge -> Morgan''s Vigil, Burning Steppes -> Thorium Point, Searing Gorge'),
(272,81,13,4,'Morgan''s Vigil, Burning Steppes -> Lakeshire, Redridge -> Sentinel Hill, Westfall'),
(269,267,32,1,'Astranaar, Ashenvale -> Talrendis Point, Azshara -> Ratchet, The Barrens'),
(270,246,32,1,'Talrendis Point, Azshara -> Astranaar, Ashenvale -> Stonetalon Peak, Stonetalon Mountains'),
(269,250,32,1,'Astranaar, Ashenvale -> Talrendis Point, Azshara -> Everlook, Winterspring'),
(269,249,32,1,'Astranaar, Ashenvale -> Talrendis Point, Azshara -> Theramore, Dustwallow Marsh'),
(268,270,14,1,'Ratchet, The Barrens -> Talrendis Point, Azshara -> Astranaar, Ashenvale'),
(268,150,14,2,'Ratchet, The Barrens -> Talrendis Point, Azshara -> Talonbranch Glade, Felwood'),
(268,250,14,2,'Ratchet, The Barrens -> Talrendis Point, Azshara -> Everlook, Winterspring'),
(268,148,14,1,'Ratchet, The Barrens -> Talrendis Point, Azshara -> Auberdine, Darkshore'),
(264,227,12,2,'Ratchet, The Barrens -> Crossroads, The Barrens -> Camp Taurajo, The Barrens'),
(264,175,12,1,'Ratchet, The Barrens -> Crossroads, The Barrens -> Brackenwall Village, Dustwallow Marsh'),
(264,170,12,1,'Ratchet, The Barrens -> Crossroads, The Barrens -> Camp Mojache, Feralas'),
(264,152,12,2,'Ratchet, The Barrens -> Crossroads, The Barrens -> Splintertree Post, Ashenvale'),
(264,169,12,1,'Ratchet, The Barrens -> Crossroads, The Barrens -> Zoram''gar Outpost, Ashenvale'),
(264,112,12,2,'Ratchet, The Barrens -> Crossroads, The Barrens -> Bloodvenom Post, Felwood'),
(264,108,12,1,'Ratchet, The Barrens -> Crossroads, The Barrens -> Valormok, Azshara'),
(264,106,12,1,'Ratchet, The Barrens -> Crossroads, The Barrens -> Freewind Post, Thousand Needles'),
(264,33,12,1,'Ratchet, The Barrens -> Crossroads, The Barrens -> Orgrimmar, Durotar'),
(264,104,12,2,'Ratchet, The Barrens -> Crossroads, The Barrens -> Sun Rock Retreat, Stonetalon Mountains'),
(264,32,12,1,'Ratchet, The Barrens -> Crossroads, The Barrens -> Thunder Bluff, Mulgore'),
(263,63,11,2,'Ratchet, The Barrens -> Theramore, Dustwallow Marsh -> Gadgetzan, Tanaris'),
(263,59,11,1,'Ratchet, The Barrens -> Theramore, Dustwallow Marsh -> Nijel''s Point, Desolace'),
(263,42,11,2,'Ratchet, The Barrens -> Theramore, Dustwallow Marsh -> Thalanaar, Feralas'),
(149,249,52,2,'Auberdine, Darkshore -> Talrendis Point, Azshara -> Theramore, Dustwallow Marsh'),
(248,148,21,1,'Theramore, Dustwallow Marsh -> Talrendis Point, Azshara -> Auberdine, Darkshore'),
(258,254,14,4,'Marshal''s Refuge, Un''Goro Crater -> Cenarion Hold, Silithus -> Feathermoon, Feralas'),
(257,252,14,5,'Marshal''s Refuge, Un''Goro Crater -> Cenarion Hold, Silithus -> Camp Mojache, Feralas'),
(256,202,13,5,'Marshal''s Refuge, Un''Goro Crater -> Gadgetzan, Tanaris -> Brackenwall Village, Dustwallow Marsh'),
(256,130,15,2,'Marshal''s Refuge, Un''Goro Crater -> Gadgetzan, Tanaris -> Thunder Bluff, Mulgore'),
(255,142,14,3,'Marshal''s Refuge, Un''Goro Crater -> Gadgetzan, Tanaris -> Thalanaar, Feralas'),
(256,64,13,4,'Marshal''s Refuge, Un''Goro Crater -> Gadgetzan, Tanaris -> Orgrimmar, Durotar'),
(255,62,14,3,'Marshal''s Refuge, Un''Goro Crater -> Gadgetzan, Tanaris -> Theramore, Dustwallow Marsh'),
(254,188,27,1,'Cenarion Hold, Silithus -> Feathermoon, Feralas -> Nijel''s Point, Desolace'),
(254,145,27,1,'Cenarion Hold, Silithus -> Feathermoon, Feralas -> Thalanaar, Feralas'),
(254,66,27,1,'Cenarion Hold, Silithus -> Feathermoon, Feralas -> Auberdine, Darkshore'),
(253,259,25,2,'Camp Mojache, Feralas -> Cenarion Hold, Silithus -> Marshal''s Refuge, Un''Goro Crater'),
(252,287,27,2,'Cenarion Hold, Silithus -> Camp Mojache, Feralas -> Freewind Post, Thousand Needles'),
(252,189,21,10,'Cenarion Hold, Silithus -> Camp Mojache, Feralas -> Shadowprey Village, Desolace'),
(252,168,27,3,'Cenarion Hold, Silithus -> Camp Mojache, Feralas -> Crossroads, The Barrens'),
(252,68,27,3,'Cenarion Hold, Silithus -> Camp Mojache, Feralas -> Thunder Bluff, Mulgore'),
(251,270,17,1,'Everlook, Winterspring -> Talrendis Point, Azshara -> Astranaar, Ashenvale'),
(251,267,17,2,'Everlook, Winterspring -> Talrendis Point, Azshara -> Ratchet, The Barrens'),
(251,249,17,2,'Everlook, Winterspring -> Talrendis Point, Azshara -> Theramore, Dustwallow Marsh'),
(60,63,113,3,'Auberdine, Darkshore -> Theramore, Dustwallow Marsh -> Gadgetzan, Tanaris'),
(250,119,19,3,'Talrendis Point, Azshara -> Everlook, Winterspring -> Moonglade'),
(62,61,18,3,'Gadgetzan, Tanaris -> Theramore, Dustwallow Marsh -> Auberdine, Darkshore'),
(249,42,19,2,'Talrendis Point, Azshara -> Theramore, Dustwallow Marsh -> Thalanaar, Feralas'),
(247,269,21,1,'Stonetalon Peak, Stonetalon Mountains -> Astranaar, Ashenvale -> Talrendis Point, Azshara'),
(246,280,23,2,'Astranaar, Ashenvale -> Stonetalon Peak, Stonetalon Mountains -> Nijel''s Point, Desolace'),
(244,223,12,2,'The Sepulcher, Silverpine Forest -> Tarren Mill, Hillsbrad -> Revantusk Village, The Hinterlands'),
(244,141,12,3,'The Sepulcher, Silverpine Forest -> Tarren Mill, Hillsbrad -> Hammerfall, Arathi'),
(241,215,35,9,'Light''s Hope Chapel, Eastern Plaguelands -> Ironforge, Dun Morogh -> Thorium Point, Searing Gorge'),
(239,161,12,4,'Light''s Hope Chapel, Eastern Plaguelands -> Chillwind Camp, Western Plaguelands -> Southshore, Hillsbrad'),
(241,5,35,16,'Light''s Hope Chapel, Eastern Plaguelands -> Ironforge, Dun Morogh -> Stormwind, Elwynn'),
(237,215,24,9,'Chillwind Camp, Western Plaguelands -> Ironforge, Dun Morogh -> Thorium Point, Searing Gorge'),
(237,5,24,16,'Chillwind Camp, Western Plaguelands -> Ironforge, Dun Morogh -> Stormwind, Elwynn'),
(235,220,23,4,'Stormwind, Elwynn -> Morgan''s Vigil, Burning Steppes -> Thorium Point, Searing Gorge'),
(233,62,21,3,'Cenarion Hold, Silithus -> Gadgetzan, Tanaris -> Theramore, Dustwallow Marsh'),
(230,288,19,2,'Camp Taurajo, The Barrens -> Freewind Post, Thousand Needles -> Camp Mojache, Feralas'),
(230,127,19,2,'Camp Taurajo, The Barrens -> Freewind Post, Thousand Needles -> Gadgetzan, Tanaris'),
(229,58,12,2,'Camp Taurajo, The Barrens -> Thunder Bluff, Mulgore -> Shadowprey Village, Desolace'),
(226,265,10,1,'Camp Taurajo, The Barrens -> Crossroads, The Barrens -> Ratchet, The Barrens'),
(226,175,10,1,'Camp Taurajo, The Barrens -> Crossroads, The Barrens -> Brackenwall Village, Dustwallow Marsh'),
(226,169,10,1,'Camp Taurajo, The Barrens -> Crossroads, The Barrens -> Zoram''gar Outpost, Ashenvale'),
(226,152,10,2,'Camp Taurajo, The Barrens -> Crossroads, The Barrens -> Splintertree Post, Ashenvale'),
(226,112,10,1,'Camp Taurajo, The Barrens -> Crossroads, The Barrens -> Bloodvenom Post, Felwood'),
(226,108,10,2,'Camp Taurajo, The Barrens -> Crossroads, The Barrens -> Valormok, Azshara'),
(226,33,10,1,'Camp Taurajo, The Barrens -> Crossroads, The Barrens -> Orgrimmar, Durotar'),
(226,104,10,2,'Camp Taurajo, The Barrens -> Crossroads, The Barrens -> Sun Rock Retreat, Stonetalon Mountains'),
(222,245,16,2,'Revantusk Village, The Hinterlands -> Tarren Mill, Hillsbrad -> The Sepulcher, Silverpine Forest'),
(223,275,13,5,'Tarren Mill, Hillsbrad -> Revantusk Village, The Hinterlands -> Light''s Hope Chapel, Eastern Plaguelands'),
(221,272,9,7,'Thorium Point, Searing Gorge -> Morgan''s Vigil, Burning Steppes -> Lakeshire, Redridge'),
(221,234,9,5,'Thorium Point, Searing Gorge -> Morgan''s Vigil, Burning Steppes -> Stormwind, Elwynn'),
(220,214,10,5,'Morgan''s Vigil, Burning Steppes -> Thorium Point, Searing Gorge -> Ironforge, Dun Morogh'),
(221,195,9,6,'Thorium Point, Searing Gorge -> Morgan''s Vigil, Burning Steppes -> Nethergarde Keep, Blasted Lands'),
(217,177,11,2,'Thorium Point, Searing Gorge -> Kargath, Badlands -> Grom''gol, Stranglethorn'),
(217,138,7,3,'Thorium Point, Searing Gorge -> Kargath, Badlands -> Hammerfall, Arathi'),
(217,27,7,5,'Thorium Point, Searing Gorge -> Kargath, Badlands -> Undercity, Tirisfal'),
(217,26,11,2,'Thorium Point, Searing Gorge -> Kargath, Badlands -> Booty Bay, Stranglethorn'),
(215,221,17,3,'Ironforge, Dun Morogh -> Thorium Point, Searing Gorge -> Morgan''s Vigil, Burning Steppes'),
(214,242,12,11,'Thorium Point, Searing Gorge -> Ironforge, Dun Morogh -> Light''s Hope Chapel, Eastern Plaguelands'),
(214,236,12,14,'Thorium Point, Searing Gorge -> Ironforge, Dun Morogh -> Chillwind Camp, Western Plaguelands'),
(214,90,12,18,'Thorium Point, Searing Gorge -> Ironforge, Dun Morogh -> Aerie Peak, The Hinterlands'),
(214,10,12,15,'Thorium Point, Searing Gorge -> Ironforge, Dun Morogh -> Menethil Harbor, Wetlands'),
(214,8,12,16,'Thorium Point, Searing Gorge -> Ironforge, Dun Morogh -> Thelsamar, Loch Modan'),
(213,284,45,1,'Bloodvenom Post, Felwood -> Valormok, Azshara -> Splintertree Post, Ashenvale'),
(210,153,47,3,'Everlook, Winterspring -> Orgrimmar, Durotar -> Brackenwall Village, Dustwallow Marsh'),
(210,65,47,3,'Everlook, Winterspring -> Orgrimmar, Durotar -> Gadgetzan, Tanaris'),
(204,262,13,2,'Brackenwall Village, Dustwallow Marsh -> Gadgetzan, Tanaris -> Marshal''s Refuge, Un''Goro Crater'),
(204,129,13,2,'Brackenwall Village, Dustwallow Marsh -> Gadgetzan, Tanaris -> Freewind Post, Thousand Needles'),
(201,147,10,9,'Thunder Bluff, Mulgore -> Orgrimmar, Durotar -> Splintertree Post, Ashenvale'),
(198,200,28,7,'Nijel''s Point, Desolace -> Auberdine, Darkshore -> Talonbranch Glade, Felwood'),
(198,113,32,3,'Nijel''s Point, Desolace -> Auberdine, Darkshore -> Moonglade'),
(198,53,32,3,'Nijel''s Point, Desolace -> Auberdine, Darkshore -> Rut''theran Village, Teldrassil'),
(196,220,19,4,'Nethergarde Keep, Blasted Lands -> Morgan''s Vigil, Burning Steppes -> Thorium Point, Searing Gorge'),
(194,218,36,3,'Stonard, Swamp of Sorrows -> Flame Crest, Burning Steppes -> Thorium Point, Searing Gorge'),
(193,158,35,3,'Flame Crest, Burning Steppes -> Stonard, Swamp of Sorrows -> Grom''gol, Stranglethorn'),
(193,55,35,4,'Flame Crest, Burning Steppes -> Stonard, Swamp of Sorrows -> Booty Bay, Stranglethorn'),
(191,138,16,3,'Flame Crest, Burning Steppes -> Kargath, Badlands -> Hammerfall, Arathi'),
(191,27,16,5,'Flame Crest, Burning Steppes -> Kargath, Badlands -> Undercity, Tirisfal'),
(190,287,32,2,'Shadowprey Village, Desolace -> Camp Mojache, Feralas -> Freewind Post, Thousand Needles'),
(190,253,23,12,'Shadowprey Village, Desolace -> Camp Mojache, Feralas -> Cenarion Hold, Silithus'),
(190,205,32,1,'Shadowprey Village, Desolace -> Camp Mojache, Feralas -> Gadgetzan, Tanaris'),
(188,279,30,2,'Feathermoon, Feralas -> Nijel''s Point, Desolace -> Stonetalon Peak, Stonetalon Mountains'),
(189,171,30,8,'Camp Mojache, Feralas -> Shadowprey Village, Desolace -> Sun Rock Retreat, Stonetalon Mountains'),
(187,273,29,2,'Nijel''s Point, Desolace -> Feathermoon, Feralas -> Cenarion Hold, Silithus'),
(187,145,30,1,'Nijel''s Point, Desolace -> Feathermoon, Feralas -> Thalanaar, Feralas'),
(186,267,50,2,'Talonbranch Glade, Felwood -> Talrendis Point, Azshara -> Ratchet, The Barrens'),
(186,249,50,2,'Talonbranch Glade, Felwood -> Talrendis Point, Azshara -> Theramore, Dustwallow Marsh'),
(184,199,34,5,'Talonbranch Glade, Felwood -> Auberdine, Darkshore -> Nijel''s Point, Desolace'),
(184,67,34,4,'Talonbranch Glade, Felwood -> Auberdine, Darkshore -> Feathermoon, Feralas'),
(184,53,37,3,'Talonbranch Glade, Felwood -> Auberdine, Darkshore -> Rut''theran Village, Teldrassil'),
(184,37,37,1,'Talonbranch Glade, Felwood -> Auberdine, Darkshore -> Astranaar, Ashenvale'),
(184,45,37,1,'Talonbranch Glade, Felwood -> Auberdine, Darkshore -> Stonetalon Peak, Stonetalon Mountains'),
(183,199,18,1,'Moonglade -> Auberdine, Darkshore -> Nijel''s Point, Desolace'),
(183,67,18,1,'Moonglade -> Auberdine, Darkshore -> Feathermoon, Feralas'),
(183,53,18,2,'Moonglade -> Auberdine, Darkshore -> Rut''theran Village, Teldrassil'),
(183,45,18,1,'Moonglade -> Auberdine, Darkshore -> Stonetalon Peak, Stonetalon Mountains'),
(183,37,18,1,'Moonglade -> Auberdine, Darkshore -> Astranaar, Ashenvale'),
(181,292,23,1,'Moonglade -> Everlook, Winterspring -> Valormok, Azshara'),
(182,251,20,5,'Moonglade -> Everlook, Winterspring -> Talrendis Point, Azshara'),
(179,111,32,8,'Moonglade -> Bloodvenom Post, Felwood -> Crossroads, The Barrens'),
(176,216,68,2,'Grom''gol, Stranglethorn -> Kargath, Badlands -> Thorium Point, Searing Gorge'),
(176,138,64,3,'Grom''gol, Stranglethorn -> Kargath, Badlands -> Hammerfall, Arathi'),
(176,27,64,5,'Grom''gol, Stranglethorn -> Kargath, Badlands -> Undercity, Tirisfal'),
(174,11,20,25,'Light''s Hope Chapel, Eastern Plaguelands -> Undercity, Tirisfal -> The Sepulcher, Silverpine Forest'),
(173,190,27,2,'Sun Rock Retreat, Stonetalon Mountains -> Shadowprey Village, Desolace -> Camp Mojache, Feralas'),
(170,253,34,2,'Crossroads, The Barrens -> Camp Mojache, Feralas -> Cenarion Hold, Silithus'),
(171,105,38,2,'Shadowprey Village, Desolace -> Sun Rock Retreat, Stonetalon Mountains -> Crossroads, The Barrens'),
(168,265,41,1,'Camp Mojache, Feralas -> Crossroads, The Barrens -> Ratchet, The Barrens'),
(168,175,38,4,'Camp Mojache, Feralas -> Crossroads, The Barrens -> Brackenwall Village, Dustwallow Marsh'),
(168,169,41,1,'Camp Mojache, Feralas -> Crossroads, The Barrens -> Zoram''gar Outpost, Ashenvale'),
(168,112,41,1,'Camp Mojache, Feralas -> Crossroads, The Barrens -> Bloodvenom Post, Felwood'),
(168,152,41,2,'Camp Mojache, Feralas -> Crossroads, The Barrens -> Splintertree Post, Ashenvale'),
(168,108,41,2,'Camp Mojache, Feralas -> Crossroads, The Barrens -> Valormok, Azshara'),
(168,33,41,2,'Camp Mojache, Feralas -> Crossroads, The Barrens -> Orgrimmar, Durotar'),
(167,103,23,4,'Light''s Hope Chapel, Eastern Plaguelands -> Aerie Peak, The Hinterlands -> Refuge Pointe, Arathi'),
(165,283,46,4,'Zoram''gar Outpost, Ashenvale -> Splintertree Post, Ashenvale -> Valormok, Azshara'),
(165,146,46,3,'Zoram''gar Outpost, Ashenvale -> Splintertree Post, Ashenvale -> Orgrimmar, Durotar'),
(163,58,26,2,'Brackenwall Village, Dustwallow Marsh -> Thunder Bluff, Mulgore -> Shadowprey Village, Desolace'),
(161,99,23,3,'Chillwind Camp, Western Plaguelands -> Southshore, Hillsbrad -> Menethil Harbor, Wetlands'),
(159,194,48,3,'Grom''gol, Stranglethorn -> Stonard, Swamp of Sorrows -> Flame Crest, Burning Steppes'),
(151,265,31,1,'Splintertree Post, Ashenvale -> Crossroads, The Barrens -> Ratchet, The Barrens'),
(151,227,31,2,'Splintertree Post, Ashenvale -> Crossroads, The Barrens -> Camp Taurajo, The Barrens'),
(151,170,31,1,'Splintertree Post, Ashenvale -> Crossroads, The Barrens -> Camp Mojache, Feralas'),
(151,106,31,1,'Splintertree Post, Ashenvale -> Crossroads, The Barrens -> Freewind Post, Thousand Needles'),
(151,104,31,2,'Splintertree Post, Ashenvale -> Crossroads, The Barrens -> Sun Rock Retreat, Stonetalon Mountains'),
(148,53,51,3,'Talrendis Point, Azshara -> Auberdine, Darkshore -> Rut''theran Village, Teldrassil'),
(147,166,19,3,'Orgrimmar, Durotar -> Splintertree Post, Ashenvale -> Zoram''gar Outpost, Ashenvale'),
(146,153,13,10,'Splintertree Post, Ashenvale -> Orgrimmar, Durotar -> Brackenwall Village, Dustwallow Marsh'),
(146,31,13,10,'Splintertree Post, Ashenvale -> Orgrimmar, Durotar -> Thunder Bluff, Mulgore'),
(146,65,19,4,'Splintertree Post, Ashenvale -> Orgrimmar, Durotar -> Gadgetzan, Tanaris'),
(145,143,26,3,'Feathermoon, Feralas -> Thalanaar, Feralas -> Gadgetzan, Tanaris'),
(145,43,26,2,'Feathermoon, Feralas -> Thalanaar, Feralas -> Theramore, Dustwallow Marsh'),
(144,188,28,1,'Thalanaar, Feralas -> Feathermoon, Feralas -> Nijel''s Point, Desolace'),
(144,273,26,2,'Thalanaar, Feralas -> Feathermoon, Feralas -> Cenarion Hold, Silithus'),
(144,66,28,2,'Thalanaar, Feralas -> Feathermoon, Feralas -> Auberdine, Darkshore'),
(143,261,29,1,'Thalanaar, Feralas -> Gadgetzan, Tanaris -> Marshal''s Refuge, Un''Goro Crater'),
(142,144,31,1,'Gadgetzan, Tanaris -> Thalanaar, Feralas -> Feathermoon, Feralas'),
(141,139,18,3,'Tarren Mill, Hillsbrad -> Hammerfall, Arathi -> Kargath, Badlands'),
(140,245,18,2,'Hammerfall, Arathi -> Tarren Mill, Hillsbrad -> The Sepulcher, Silverpine Forest'),
(139,192,39,2,'Hammerfall, Arathi -> Kargath, Badlands -> Flame Crest, Burning Steppes'),
(139,216,39,2,'Hammerfall, Arathi -> Kargath, Badlands -> Thorium Point, Searing Gorge'),
(139,177,39,2,'Hammerfall, Arathi -> Kargath, Badlands -> Grom''gol, Stranglethorn'),
(139,136,39,2,'Hammerfall, Arathi -> Kargath, Badlands -> Stonard, Swamp of Sorrows'),
(139,26,39,2,'Hammerfall, Arathi -> Kargath, Badlands -> Booty Bay, Stranglethorn'),
(138,140,37,3,'Kargath, Badlands -> Hammerfall, Arathi -> Tarren Mill, Hillsbrad'),
(138,285,37,2,'Kargath, Badlands -> Hammerfall, Arathi -> Revantusk Village, The Hinterlands'),
(137,27,44,6,'Stonard, Swamp of Sorrows -> Kargath, Badlands -> Undercity, Tirisfal'),
(137,138,45,4,'Stonard, Swamp of Sorrows -> Kargath, Badlands -> Hammerfall, Arathi'),
(129,231,16,2,'Gadgetzan, Tanaris -> Freewind Post, Thousand Needles -> Camp Taurajo, The Barrens'),
(128,262,48,3,'Thunder Bluff, Mulgore -> Gadgetzan, Tanaris -> Marshal''s Refuge, Un''Goro Crater'),
(127,262,18,3,'Freewind Post, Thousand Needles -> Gadgetzan, Tanaris -> Marshal''s Refuge, Un''Goro Crater'),
(127,202,19,2,'Freewind Post, Thousand Needles -> Gadgetzan, Tanaris -> Brackenwall Village, Dustwallow Marsh'),
(124,265,57,1,'Zoram''gar Outpost, Ashenvale -> Crossroads, The Barrens -> Ratchet, The Barrens'),
(124,227,57,2,'Zoram''gar Outpost, Ashenvale -> Crossroads, The Barrens -> Camp Taurajo, The Barrens'),
(124,175,57,1,'Zoram''gar Outpost, Ashenvale -> Crossroads, The Barrens -> Brackenwall Village, Dustwallow Marsh'),
(124,170,57,1,'Zoram''gar Outpost, Ashenvale -> Crossroads, The Barrens -> Camp Mojache, Feralas'),
(124,112,55,4,'Zoram''gar Outpost, Ashenvale -> Crossroads, The Barrens -> Bloodvenom Post, Felwood'),
(124,106,57,1,'Zoram''gar Outpost, Ashenvale -> Crossroads, The Barrens -> Freewind Post, Thousand Needles'),
(124,104,57,2,'Zoram''gar Outpost, Ashenvale -> Crossroads, The Barrens -> Sun Rock Retreat, Stonetalon Mountains'),
(124,32,57,1,'Zoram''gar Outpost, Ashenvale -> Crossroads, The Barrens -> Thunder Bluff, Mulgore'),
(123,265,26,1,'Brackenwall Village, Dustwallow Marsh -> Crossroads, The Barrens -> Ratchet, The Barrens'),
(123,227,26,2,'Brackenwall Village, Dustwallow Marsh -> Crossroads, The Barrens -> Camp Taurajo, The Barrens'),
(123,169,26,1,'Brackenwall Village, Dustwallow Marsh -> Crossroads, The Barrens -> Zoram''gar Outpost, Ashenvale'),
(123,152,26,2,'Brackenwall Village, Dustwallow Marsh -> Crossroads, The Barrens -> Splintertree Post, Ashenvale'),
(123,108,26,1,'Brackenwall Village, Dustwallow Marsh -> Crossroads, The Barrens -> Valormok, Azshara'),
(123,112,26,1,'Brackenwall Village, Dustwallow Marsh -> Crossroads, The Barrens -> Bloodvenom Post, Felwood'),
(123,104,26,2,'Brackenwall Village, Dustwallow Marsh -> Crossroads, The Barrens -> Sun Rock Retreat, Stonetalon Mountains'),
(119,183,21,2,'Everlook, Winterspring -> Moonglade -> Auberdine, Darkshore'),
(115,58,28,2,'Valormok, Azshara -> Thunder Bluff, Mulgore -> Shadowprey Village, Desolace'),
(114,293,32,2,'Thunder Bluff, Mulgore -> Valormok, Azshara -> Everlook, Winterspring'),
(113,182,18,7,'Auberdine, Darkshore -> Moonglade -> Everlook, Winterspring'),
(112,180,42,10,'Crossroads, The Barrens -> Bloodvenom Post, Felwood -> Moonglade'),
(111,265,48,1,'Bloodvenom Post, Felwood -> Crossroads, The Barrens -> Ratchet, The Barrens'),
(111,227,48,2,'Bloodvenom Post, Felwood -> Crossroads, The Barrens -> Camp Taurajo, The Barrens'),
(111,175,48,1,'Bloodvenom Post, Felwood -> Crossroads, The Barrens -> Brackenwall Village, Dustwallow Marsh'),
(111,170,48,1,'Bloodvenom Post, Felwood -> Crossroads, The Barrens -> Camp Mojache, Feralas'),
(111,169,48,1,'Bloodvenom Post, Felwood -> Crossroads, The Barrens -> Zoram''gar Outpost, Ashenvale'),
(111,104,48,2,'Bloodvenom Post, Felwood -> Crossroads, The Barrens -> Sun Rock Retreat, Stonetalon Mountains'),
(111,106,48,1,'Bloodvenom Post, Felwood -> Crossroads, The Barrens -> Freewind Post, Thousand Needles'),
(111,32,48,1,'Bloodvenom Post, Felwood -> Crossroads, The Barrens -> Thunder Bluff, Mulgore'),
(109,227,23,2,'Valormok, Azshara -> Crossroads, The Barrens -> Camp Taurajo, The Barrens'),
(109,265,23,1,'Valormok, Azshara -> Crossroads, The Barrens -> Ratchet, The Barrens'),
(109,170,23,1,'Valormok, Azshara -> Crossroads, The Barrens -> Camp Mojache, Feralas'),
(109,106,23,1,'Valormok, Azshara -> Crossroads, The Barrens -> Freewind Post, Thousand Needles'),
(109,104,22,6,'Valormok, Azshara -> Crossroads, The Barrens -> Sun Rock Retreat, Stonetalon Mountains'),
(108,293,21,2,'Crossroads, The Barrens -> Valormok, Azshara -> Everlook, Winterspring'),
(107,265,20,1,'Freewind Post, Thousand Needles -> Crossroads, The Barrens -> Ratchet, The Barrens'),
(107,169,20,1,'Freewind Post, Thousand Needles -> Crossroads, The Barrens -> Zoram''gar Outpost, Ashenvale'),
(107,152,20,2,'Freewind Post, Thousand Needles -> Crossroads, The Barrens -> Splintertree Post, Ashenvale'),
(107,112,20,1,'Freewind Post, Thousand Needles -> Crossroads, The Barrens -> Bloodvenom Post, Felwood'),
(107,108,20,2,'Freewind Post, Thousand Needles -> Crossroads, The Barrens -> Valormok, Azshara'),
(107,104,20,2,'Freewind Post, Thousand Needles -> Crossroads, The Barrens -> Sun Rock Retreat, Stonetalon Mountains'),
(107,33,20,1,'Freewind Post, Thousand Needles -> Crossroads, The Barrens -> Orgrimmar, Durotar'),
(105,265,27,1,'Sun Rock Retreat, Stonetalon Mountains -> Crossroads, The Barrens -> Ratchet, The Barrens'),
(105,227,27,2,'Sun Rock Retreat, Stonetalon Mountains -> Crossroads, The Barrens -> Camp Taurajo, The Barrens'),
(105,175,27,1,'Sun Rock Retreat, Stonetalon Mountains -> Crossroads, The Barrens -> Brackenwall Village, Dustwallow Marsh'),
(105,152,27,2,'Sun Rock Retreat, Stonetalon Mountains -> Crossroads, The Barrens -> Splintertree Post, Ashenvale'),
(105,169,27,1,'Sun Rock Retreat, Stonetalon Mountains -> Crossroads, The Barrens -> Zoram''gar Outpost, Ashenvale'),
(105,108,27,1,'Sun Rock Retreat, Stonetalon Mountains -> Crossroads, The Barrens -> Valormok, Azshara'),
(105,112,27,1,'Sun Rock Retreat, Stonetalon Mountains -> Crossroads, The Barrens -> Bloodvenom Post, Felwood'),
(105,33,27,1,'Sun Rock Retreat, Stonetalon Mountains -> Crossroads, The Barrens -> Orgrimmar, Durotar'),
(105,106,27,1,'Sun Rock Retreat, Stonetalon Mountains -> Crossroads, The Barrens -> Freewind Post, Thousand Needles'),
(103,95,12,3,'Aerie Peak, The Hinterlands -> Refuge Pointe, Arathi -> Thelsamar, Loch Modan'),
(102,277,11,7,'Refuge Pointe, Arathi -> Aerie Peak, The Hinterlands -> Chillwind Camp, Western Plaguelands'),
(102,164,14,3,'Refuge Pointe, Arathi -> Aerie Peak, The Hinterlands -> Light''s Hope Chapel, Eastern Plaguelands'),
(101,95,11,3,'Southshore, Hillsbrad -> Refuge Pointe, Arathi -> Thelsamar, Loch Modan'),
(98,162,10,2,'Menethil Harbor, Wetlands -> Southshore, Hillsbrad -> Chillwind Camp, Western Plaguelands'),
(98,71,10,3,'Menethil Harbor, Wetlands -> Southshore, Hillsbrad -> Aerie Peak, The Hinterlands'),
(94,102,27,3,'Thelsamar, Loch Modan -> Refuge Pointe, Arathi -> Aerie Peak, The Hinterlands'),
(94,100,27,3,'Thelsamar, Loch Modan -> Refuge Pointe, Arathi -> Southshore, Hillsbrad'),
(91,215,30,9,'Aerie Peak, The Hinterlands -> Ironforge, Dun Morogh -> Thorium Point, Searing Gorge'),
(91,5,30,16,'Aerie Peak, The Hinterlands -> Ironforge, Dun Morogh -> Stormwind, Elwynn'),
(89,79,15,4,'Nethergarde Keep, Blasted Lands -> Darkshire, Duskwood -> Sentinel Hill, Westfall'),
(89,85,17,3,'Nethergarde Keep, Blasted Lands -> Darkshire, Duskwood -> Lakeshire, Redridge'),
(89,86,17,3,'Nethergarde Keep, Blasted Lands -> Darkshire, Duskwood -> Booty Bay, Stranglethorn'),
(87,88,22,4,'Booty Bay, Stranglethorn -> Darkshire, Duskwood -> Nethergarde Keep, Blasted Lands'),
(87,85,22,4,'Booty Bay, Stranglethorn -> Darkshire, Duskwood -> Lakeshire, Redridge'),
(85,271,14,1,'Darkshire, Duskwood -> Lakeshire, Redridge -> Morgan''s Vigil, Burning Steppes'),
(84,88,14,5,'Lakeshire, Redridge -> Darkshire, Duskwood -> Nethergarde Keep, Blasted Lands'),
(84,86,15,4,'Lakeshire, Redridge -> Darkshire, Duskwood -> Booty Bay, Stranglethorn'),
(78,88,15,6,'Sentinel Hill, Westfall -> Darkshire, Duskwood -> Nethergarde Keep, Blasted Lands'),
(77,271,30,1,'Sentinel Hill, Westfall -> Lakeshire, Redridge -> Morgan''s Vigil, Burning Steppes'),
(75,6,43,5,'Nethergarde Keep, Blasted Lands -> Stormwind, Elwynn -> Ironforge, Dun Morogh'),
(73,153,31,3,'Valormok, Azshara -> Orgrimmar, Durotar -> Brackenwall Village, Dustwallow Marsh'),
(73,65,31,3,'Valormok, Azshara -> Orgrimmar, Durotar -> Gadgetzan, Tanaris'),
(71,164,20,3,'Southshore, Hillsbrad -> Aerie Peak, The Hinterlands -> Light''s Hope Chapel, Eastern Plaguelands'),
(70,99,11,2,'Aerie Peak, The Hinterlands -> Southshore, Hillsbrad -> Menethil Harbor, Wetlands'),
(69,253,43,2,'Thunder Bluff, Mulgore -> Camp Mojache, Feralas -> Cenarion Hold, Silithus'),
(67,273,65,2,'Auberdine, Darkshore -> Feathermoon, Feralas -> Cenarion Hold, Silithus'),
(66,200,73,6,'Feathermoon, Feralas -> Auberdine, Darkshore -> Talonbranch Glade, Felwood'),
(67,145,65,1,'Auberdine, Darkshore -> Feathermoon, Feralas -> Thalanaar, Feralas'),
(66,113,78,3,'Feathermoon, Feralas -> Auberdine, Darkshore -> Moonglade'),
(66,53,78,3,'Feathermoon, Feralas -> Auberdine, Darkshore -> Rut''theran Village, Teldrassil'),
(65,262,89,3,'Orgrimmar, Durotar -> Gadgetzan, Tanaris -> Marshal''s Refuge, Un''Goro Crater'),
(63,261,22,1,'Theramore, Dustwallow Marsh -> Gadgetzan, Tanaris -> Marshal''s Refuge, Un''Goro Crater'),
(63,208,22,2,'Theramore, Dustwallow Marsh -> Gadgetzan, Tanaris -> Cenarion Hold, Silithus'),
(62,266,17,3,'Gadgetzan, Tanaris -> Theramore, Dustwallow Marsh -> Ratchet, The Barrens'),
(62,59,18,4,'Gadgetzan, Tanaris -> Theramore, Dustwallow Marsh -> Nijel''s Point, Desolace'),
(59,279,55,2,'Theramore, Dustwallow Marsh -> Nijel''s Point, Desolace -> Stonetalon Peak, Stonetalon Mountains'),
(57,228,38,2,'Shadowprey Village, Desolace -> Thunder Bluff, Mulgore -> Camp Taurajo, The Barrens'),
(57,201,38,1,'Shadowprey Village, Desolace -> Thunder Bluff, Mulgore -> Orgrimmar, Durotar'),
(57,160,38,2,'Shadowprey Village, Desolace -> Thunder Bluff, Mulgore -> Brackenwall Village, Dustwallow Marsh'),
(57,114,38,2,'Shadowprey Village, Desolace -> Thunder Bluff, Mulgore -> Valormok, Azshara'),
(56,266,66,1,'Nijel''s Point, Desolace -> Theramore, Dustwallow Marsh -> Ratchet, The Barrens'),
(56,63,66,2,'Nijel''s Point, Desolace -> Theramore, Dustwallow Marsh -> Gadgetzan, Tanaris'),
(54,200,8,3,'Rut''theran Village, Teldrassil -> Auberdine, Darkshore -> Talonbranch Glade, Felwood'),
(54,199,8,3,'Rut''theran Village, Teldrassil -> Auberdine, Darkshore -> Nijel''s Point, Desolace'),
(54,67,8,3,'Rut''theran Village, Teldrassil -> Auberdine, Darkshore -> Feathermoon, Feralas'),
(54,113,12,2,'Rut''theran Village, Teldrassil -> Auberdine, Darkshore -> Moonglade'),
(54,45,8,3,'Rut''theran Village, Teldrassil -> Auberdine, Darkshore -> Stonetalon Peak, Stonetalon Mountains'),
(46,194,86,2,'Booty Bay, Stranglethorn -> Stonard, Swamp of Sorrows -> Flame Crest, Burning Steppes'),
(54,37,8,3,'Rut''theran Village, Teldrassil -> Auberdine, Darkshore -> Astranaar, Ashenvale'),
(44,200,19,6,'Stonetalon Peak, Stonetalon Mountains -> Auberdine, Darkshore -> Talonbranch Glade, Felwood'),
(44,113,21,3,'Stonetalon Peak, Stonetalon Mountains -> Auberdine, Darkshore -> Moonglade'),
(43,266,25,1,'Thalanaar, Feralas -> Theramore, Dustwallow Marsh -> Ratchet, The Barrens'),
(44,53,21,3,'Stonetalon Peak, Stonetalon Mountains -> Auberdine, Darkshore -> Rut''theran Village, Teldrassil'),
(42,144,25,1,'Theramore, Dustwallow Marsh -> Thalanaar, Feralas -> Feathermoon, Feralas'),
(36,200,24,8,'Astranaar, Ashenvale -> Auberdine, Darkshore -> Talonbranch Glade, Felwood'),
(36,113,32,3,'Astranaar, Ashenvale -> Auberdine, Darkshore -> Moonglade'),
(36,53,33,3,'Astranaar, Ashenvale -> Auberdine, Darkshore -> Rut''theran Village, Teldrassil'),
(35,265,25,1,'Orgrimmar, Durotar -> Crossroads, The Barrens -> Ratchet, The Barrens'),
(35,227,25,2,'Orgrimmar, Durotar -> Crossroads, The Barrens -> Camp Taurajo, The Barrens'),
(35,170,25,1,'Orgrimmar, Durotar -> Crossroads, The Barrens -> Camp Mojache, Feralas'),
(35,106,25,1,'Orgrimmar, Durotar -> Crossroads, The Barrens -> Freewind Post, Thousand Needles'),
(35,104,25,2,'Orgrimmar, Durotar -> Crossroads, The Barrens -> Sun Rock Retreat, Stonetalon Mountains'),
(34,265,24,2,'Thunder Bluff, Mulgore -> Crossroads, The Barrens -> Ratchet, The Barrens'),
(34,169,24,2,'Thunder Bluff, Mulgore -> Crossroads, The Barrens -> Zoram''gar Outpost, Ashenvale'),
(34,112,24,2,'Thunder Bluff, Mulgore -> Crossroads, The Barrens -> Bloodvenom Post, Felwood'),
(32,58,30,2,'Crossroads, The Barrens -> Thunder Bluff, Mulgore -> Shadowprey Village, Desolace'),
(31,58,42,2,'Orgrimmar, Durotar -> Thunder Bluff, Mulgore -> Shadowprey Village, Desolace'),
(30,6,47,7,'Booty Bay, Stranglethorn -> Stormwind, Elwynn -> Ironforge, Dun Morogh'),
(28,216,143,2,'Undercity, Tirisfal -> Kargath, Badlands -> Thorium Point, Searing Gorge'),
(28,192,143,2,'Undercity, Tirisfal -> Kargath, Badlands -> Flame Crest, Burning Steppes'),
(28,177,143,2,'Undercity, Tirisfal -> Kargath, Badlands -> Grom''gol, Stranglethorn'),
(28,136,143,2,'Undercity, Tirisfal -> Kargath, Badlands -> Stonard, Swamp of Sorrows'),
(28,26,143,2,'Undercity, Tirisfal -> Kargath, Badlands -> Booty Bay, Stranglethorn'),
(25,216,39,2,'Booty Bay, Stranglethorn -> Kargath, Badlands -> Thorium Point, Searing Gorge'),
(25,138,35,3,'Booty Bay, Stranglethorn -> Kargath, Badlands -> Hammerfall, Arathi'),
(25,27,35,5,'Booty Bay, Stranglethorn -> Kargath, Badlands -> Undercity, Tirisfal'),
(17,215,27,9,'Southshore, Hillsbrad -> Ironforge, Dun Morogh -> Thorium Point, Searing Gorge'),
(17,5,27,16,'Southshore, Hillsbrad -> Ironforge, Dun Morogh -> Stormwind, Elwynn'),
(12,172,22,20,'The Sepulcher, Silverpine Forest -> Undercity, Tirisfal -> Light''s Hope Chapel, Eastern Plaguelands'),
(9,215,19,9,'Menethil Harbor, Wetlands -> Ironforge, Dun Morogh -> Thorium Point, Searing Gorge'),
(9,5,19,16,'Menethil Harbor, Wetlands -> Ironforge, Dun Morogh -> Stormwind, Elwynn'),
(7,215,22,9,'Thelsamar, Loch Modan -> Ironforge, Dun Morogh -> Thorium Point, Searing Gorge'),
(7,5,22,16,'Thelsamar, Loch Modan -> Ironforge, Dun Morogh -> Stormwind, Elwynn'),
(6,242,45,11,'Stormwind, Elwynn -> Ironforge, Dun Morogh -> Light''s Hope Chapel, Eastern Plaguelands'),
(6,236,45,15,'Stormwind, Elwynn -> Ironforge, Dun Morogh -> Chillwind Camp, Western Plaguelands'),
(6,90,45,18,'Stormwind, Elwynn -> Ironforge, Dun Morogh -> Aerie Peak, The Hinterlands'),
(6,10,45,16,'Stormwind, Elwynn -> Ironforge, Dun Morogh -> Menethil Harbor, Wetlands'),
(6,8,45,15,'Stormwind, Elwynn -> Ironforge, Dun Morogh -> Thelsamar, Loch Modan'),
(5,29,65,5,'Ironforge, Dun Morogh -> Stormwind, Elwynn -> Booty Bay, Stranglethorn'),
(5,1,65,5,'Ironforge, Dun Morogh -> Stormwind, Elwynn -> Sentinel Hill, Westfall'),
(2,6,24,5,'Sentinel Hill, Westfall -> Stormwind, Elwynn -> Ironforge, Dun Morogh'),
(99,9,11,6,'Southshore, Hillsbrad -> Menethil Harbor, Wetlands -> Ironforge, Dun Morogh'),
(10,98,34,3,'Ironforge, Dun Morogh -> Menethil Harbor, Wetlands -> Southshore, Hillsbrad'),
(24,176,19,7,'Booty Bay, Stranglethorn -> Grom''gol, Stranglethorn -> Kargath, Badlands'),
(10,96,34,4,'Ironforge, Dun Morogh -> Menethil Harbor, Wetlands -> Refuge Pointe, Arathi'),
(97,9,18,3,'Refuge Pointe, Arathi -> Menethil Harbor, Wetlands -> Ironforge, Dun Morogh'),
(33,211,12,6,'Crossroads, The Barrens -> Orgrimmar, Durotar -> Everlook, Winterspring'),
(210,35,38,9,'Everlook, Winterspring -> Orgrimmar, Durotar -> Crossroads, The Barrens'),
(292,73,19,5,'Everlook, Winterspring -> Valormok, Azshara -> Orgrimmar, Durotar'),
(256,203,15,1,'Marshal''s Refuge, Un''Goro Crater -> Gadgetzan, Tanaris -> Camp Mojache, Feralas'),
(203,189,35,2,'Gadgetzan, Tanaris -> Camp Mojache, Feralas -> Shadowprey Village, Desolace'),
(205,262,24,3,'Camp Mojache, Feralas -> Gadgetzan, Tanaris -> Marshal''s Refuge, Un''Goro Crater'),
(259,256,14,4,'Cenarion Hold, Silithus -> Marshal''s Refuge, Un''Goro Crater -> Gadgetzan, Tanaris'),
(262,257,12,3,'Gadgetzan, Tanaris -> Marshal''s Refuge, Un''Goro Crater -> Cenarion Hold, Silithus'),
(106,127,21,2,'Crossroads, The Barrens -> Freewind Post, Thousand Needles -> Gadgetzan, Tanaris'),
(129,107,16,2,'Gadgetzan, Tanaris -> Freewind Post, Thousand Needles -> Crossroads, The Barrens'),
(266,268,10,2,'Theramore, Dustwallow Marsh -> Ratchet, The Barrens -> Talrendis Point, Azshara'),
(37,269,29,2,'Auberdine, Darkshore -> Astranaar, Ashenvale -> Talrendis Point, Azshara'),
(256,129,14,3,'Marshal''s Refuge, Un''Goro Crater -> Gadgetzan, Tanaris -> Freewind Post, Thousand Needles'),
(92,50,25,3,'Thelsamar, Loch Modan -> Menethil Harbor, Wetlands -> Dun Agrath, Wetlands'),
(52,48,26,1,'Ironforge, Dun Morogh -> Ironforge Airfields, Dun Morogh -> Dun Agrath, Wetlands'),
(51,8,7,18,'Ironforge Airfields, Dun Morogh -> Ironforge, Dun Morogh -> Thelsamar, Loch Modan'),
(51,5,11,17,'Ironforge Airfields, Dun Morogh -> Ironforge, Dun Morogh -> Stormwind, Elwynn'),
(51,215,11,9,'Ironforge Airfields, Dun Morogh -> Ironforge, Dun Morogh -> Thorium Point, Searing Gorge'),
(50,47,3,2,'Menethil Harbor, Wetlands -> Dun Agrath, Wetlands -> Ironforge Airfields, Dun Morogh'),
(49,93,1,6,'Dun Agrath, Wetlands -> Menethil Harbor, Wetlands -> Thelsamar, Loch Modan'),
(49,96,1,6,'Dun Agrath, Wetlands -> Menethil Harbor, Wetlands -> Refuge Point, Arathi'),
(49,98,1,4,'Dun Agrath, Wetlands -> Menethil Harbor, Wetlands -> Southshore, Hillsbrad'),
(48,49,6,1,'Ironforge Airfields, Dun Morogh -> Dun Agrath, Wetlands -> Menethil Harbor, Wetlands'),
(47,51,5,1,'Dun Agrath, Wetlands -> Ironforge Airfields, Dun Morogh -> Ironforge, Dun Morogh'),
(10,50,30,4,'Ironforge, Dun Morogh -> Menethil Harbor, Wetlands -> Dun Agrath, Wetlands'),
(7,52,18,19,'Thelsamar, Loch Modan -> Ironforge, Dun Morogh -> Ironforge Airfields, Dun Morogh'),
(6,52,46,15,'Stormwind, Elwynn -> Ironforge, Dun Morogh -> Ironforge Airfields, Dun Morogh'),
(97,50,18,1,'Refuge Pointe, Arathi -> Menethil Harbor, Wetlands -> Dun Agrath, Wetlands'),
(99,50,11,1,'Southshore, Hillsbrad -> Menethil Harbor, Wetlands -> Dun Agrath, Wetlands'),
(214,52,13,14,'Thorium Point, Searing Gorge -> Ironforge, Dun Morogh -> Ironforge Airfields, Dun Morogh');

INSERT INTO `migrations` (`Name`, `Hash`, `AppliedAt`)
SELECT '20260821203635_world', 'manual', NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `migrations` WHERE `Name` = '20260821203635_world');

-- ############################################################ 20260825052735_world

-- ==============================================
-- FILE: aftermath.sql
-- GENERATED: 20260825052735
-- ==============================================
UPDATE `spell_proc_event`
SET
    `SpellFamilyMask0` = 997,
    `SpellFamilyMask1` = 997,
    `SpellFamilyMask2` = 997
WHERE `entry` = 18119;

-- ==============================================
-- FILE: curse_of_doom.sql
-- GENERATED: 20260825052735
-- ==============================================
UPDATE `spell_template`
SET `script_name` = 'spell_warlock_curse_of_doom'
WHERE `entry` = 603;

-- ==============================================
-- FILE: dark_harvest.sql
-- GENERATED: 20260825052735
-- ==============================================
UPDATE `spell_template`
SET `effectBonusCoefficient1` = 0.03125,
    `effectBonusCoefficient2` = 0,
    `effectBonusCoefficient3` = 0,
    `script_name` = 'spell_warlock_dark_harvest'
WHERE `entry` IN (
    52550, 52551, 52552
    );

INSERT INTO `spell_chain`
(
    `spell_id`,
    `prev_spell`,
    `first_spell`,
    `rank`,
    `req_spell`
)
VALUES
(52550, 0, 52550, 1, 0),
(52551, 52550, 52550, 2, 0),
(52552, 52551, 52550, 3, 0);

-- ==============================================
-- FILE: demon_gate.sql
-- GENERATED: 20260825052735
-- ==============================================
UPDATE `spell_template`
SET `script_name` = 'spell_warlock_demon_gate'
WHERE `entry` = 45908;

UPDATE `gameobject_template`
SET `script_name` = 'go_warlock_demon_gate'
WHERE `entry` = 1000512;

-- ==============================================
-- FILE: demonic_precision.sql
-- GENERATED: 20260825052735
-- ==============================================
INSERT INTO `spell_learn_spell`
(
    `entry`,
    `SpellID`,
    `Active`
)
VALUES
(51715, 49554, 1),
(51716, 49555, 1),
(51717, 49556, 1);

-- ==============================================
-- FILE: demonic_sacrifice.sql
-- GENERATED: 20260825052735
-- ==============================================
UPDATE `spell_template`
SET `script_name` = 'spell_warlock_demonic_sacrifice'
WHERE `entry` IN (
    18788, 18789, 18790, 18791, 18792
    );

-- ==============================================
-- FILE: drain_life.sql
-- GENERATED: 20260825052735
-- ==============================================
UPDATE `spell_template`
SET `script_name` = 'spell_warlock_drain_life'
WHERE `entry` IN (
    689, 699, 709, 7651, 11699, 11700
    );

-- ==============================================
-- FILE: drain_soul.sql
-- GENERATED: 20260825052735
-- ==============================================
UPDATE `spell_template`
SET `effectBonusCoefficient1` = 0,
    `effectBonusCoefficient2` = 0.1,
    `effectBonusCoefficient3` = 1,
    `customFlags` = `customFlags` | 128
WHERE `entry` = 51687;

UPDATE `spell_template`
SET `script_name` = 'spell_warlock_drain_soul'
WHERE `entry` IN (
    1120, 8288, 8289, 11675, 51687
    );

DELETE FROM `spell_mod`
WHERE `Id` IN (
    1120, 8288, 8289, 11675
    );

INSERT INTO `spell_chain`
(
    `spell_id`,
    `prev_spell`,
    `first_spell`,
    `rank`,
    `req_spell`
)
VALUES
(51687, 11675, 1120, 5, 0);


-- ==============================================
-- FILE: emberstorm.sql
-- GENERATED: 20260825052735
-- ==============================================
DELETE FROM `spell_affect`
WHERE `entry` IN (
  17954, 17955, 17956, 17957, 17958
  )
  AND `effectId` = 1;

-- ==============================================
-- FILE: enslave_demon.sql
-- GENERATED: 20260825052735
-- ==============================================
UPDATE `spell_template`
SET `script_name` = 'spell_warlock_enslave_demon'
WHERE `entry` IN (
    1098, 11725, 11726, 20882, 51689, 51703, 53222
    );

UPDATE `spell_template`
SET `script_name` = 'spell_warlock_enslave_demon_break_early'
WHERE `entry` = 52377;

-- ==============================================
-- FILE: felguard_spells.sql
-- GENERATED: 20260825052735
-- ==============================================
UPDATE `spell_template`
SET `effectBonusCoefficient1` = 0.6
WHERE `entry` = 47350;

UPDATE `spell_template`
SET `effectBonusCoefficient1` = 0.25
WHERE `entry` = 52664;

-- ==============================================
-- FILE: fel_stamina.sql
-- GENERATED: 20260825052735
-- ==============================================
DELETE FROM `spell_disabled`
WHERE `entry` IN (
    18751, 18752
    );

-- ==============================================
-- FILE: felstone.sql
-- GENERATED: 20260825052735
-- ==============================================
UPDATE `spell_template`
SET `script_name` = 'spell_warlock_felstone'
WHERE `entry` = 51697;

-- ==============================================
-- FILE: funnels.sql
-- GENERATED: 20260825052735
-- ==============================================
UPDATE `spell_template`
SET `script_name` = 'spell_warlock_funnels'
WHERE `entry` IN (
    755, 3698, 3699, 3700, 11693, 11694, 11695, 1941, 45910, 45911
    );

-- ==============================================
-- FILE: hellfire.sql
-- GENERATED: 20260825052735
-- ==============================================
UPDATE `spell_template`
SET `effectBonusCoefficient2` = 0.04125
WHERE `entry` IN (
    1949, 11683, 11684
    );

UPDATE `spell_template`
SET `script_name` = 'spell_warlock_hellfire'
WHERE `entry` IN (
    1949, 11683, 11684
    );

UPDATE `spell_template`
SET `effectBonusCoefficient1` = 0.04125
WHERE `entry` IN (
    5857, 11681, 11682
    );

-- ==============================================
-- FILE: imp_firebolt.sql
-- GENERATED: 20260825052735
-- ==============================================
UPDATE `spell_template`
SET `effectBonusCoefficient1` = 0.1
WHERE `entry` = 3110;

UPDATE `spell_template`
SET `effectBonusCoefficient1` = 0.15
WHERE `entry` = 7799;

UPDATE `spell_template`
SET `effectBonusCoefficient1` = 0.2
WHERE `entry` = 7800;

UPDATE `spell_template`
SET `effectBonusCoefficient1` = 0.25
WHERE `entry` = 7801;

UPDATE `spell_template`
SET `effectBonusCoefficient1` = 0.3
WHERE `entry` = 7802;

UPDATE `spell_template`
SET `effectBonusCoefficient1` = 0.35
WHERE `entry` = 11762;

UPDATE `spell_template`
SET `effectBonusCoefficient1` = 0.4
WHERE `entry` = 11763;

-- ==============================================
-- FILE: infernal_immolation.sql
-- GENERATED: 20260825052735
-- ==============================================
UPDATE `spell_template`
SET `effectBonusCoefficient1` = 0.25
WHERE `entry` IN (
    19483, 20153
    );

-- ==============================================
-- FILE: lash_of_pain.sql
-- GENERATED: 20260825052735
-- ==============================================
UPDATE `spell_template`
SET `effectBonusCoefficient1` = 0.4
WHERE `entry` IN (
    7814, 7815, 7816, 11778
    );

UPDATE `spell_template`
SET `effectBonusCoefficient1` = 0.5
WHERE `entry` = 11779;

UPDATE `spell_template`
SET `effectBonusCoefficient1` = 0.6
WHERE `entry` = 11780;

-- ==============================================
-- FILE: malediction.sql
-- GENERATED: 20260825052735
-- ==============================================
UPDATE `spell_template`
SET `customFlags` = `customFlags` | 16384,
    `script_name` = 'spell_warlock_curse_of_agony'
WHERE `entry` IN (
    980, 1014, 6217, 11711, 11712, 11713
    );

UPDATE `spell_template`
SET `script_name` = 'spell_warlock_malediction_trigger'
WHERE `entry` = 52670;

UPDATE `spell_template`
SET `script_name` = 'spell_warlock_malediction_curse'
WHERE `entry` IN (
    702, 1108, 6205, 7646, 11707, 11708, 704, 7658, 7659, 11717,
    1490, 11721, 11722, 1714, 11719, 17862, 17937, 18223
    );

UPDATE `spell_template`
SET `script_name` = 'spell_warlock_curse_of_idiocy'
WHERE `entry` = 1010;

-- ==============================================
-- FILE: master_demonologist.sql
-- GENERATED: 20260825052735
-- ==============================================
UPDATE `spell_template`
SET `script_name` = 'spell_warlock_inferno'
WHERE `entry` IN (
    1122, 24670
    );

UPDATE `spell_template`
SET `script_name` = 'spell_warlock_summon_felguard'
WHERE `entry` = 30146;

UPDATE `spell_template`
SET `script_name` = 'spell_warlock_summon_doomguard'
WHERE `entry` IN (
    18541, 18662
    );

INSERT INTO `spell_pet_auras`
(
    `spell`,
    `pet`,
    `aura`
)
VALUES
(23785, 11859, 51725),
(23822, 11859, 51726),
(23823, 11859, 51727),
(23824, 11859, 51728),
(23825, 11859, 51729);

-- ==============================================
-- FILE: nether_studies.sql
-- GENERATED: 20260825052735
-- ==============================================
INSERT INTO `spell_affect`
(
    `entry`,
    `effectId`,
    `SpellFamilyMask`
)
VALUES
(51709, 0, 34401681408),
(51710, 0, 34401681408),
(51711, 0, 34401681408);

-- ==============================================
-- FILE: nightfall.sql
-- GENERATED: 20260825052735
-- ==============================================
DELETE FROM `spell_proc_event`
WHERE `entry` = 18094;

-- ==============================================
-- FILE: power_overwhelming.sql
-- GENERATED: 20260825052735
-- ==============================================
UPDATE `spell_template`
SET `script_name` = 'spell_warlock_power_overwhelming'
WHERE `entry` = 51714;

-- ==============================================
-- FILE: rapid_deterioration.sql
-- GENERATED: 20260825052735
-- ==============================================
UPDATE `spell_template`
SET `script_name` = 'spell_warlock_rapid_deterioration'
WHERE `entry` IN (
    52555, 52556
    );

INSERT INTO `spell_learn_spell`
(
    `entry`,
    `SpellID`,
    `Active`
)
VALUES
(52555, 52557, 1),
(52556, 52557, 1);

-- ==============================================
-- FILE: sacrifice.sql
-- GENERATED: 20260825052735
-- ==============================================
UPDATE `spell_template`
SET `effectBonusCoefficient1` = 1
WHERE `entry` IN (
    7812, 19438, 19440, 19441
    );

UPDATE `spell_template`
SET `effectBonusCoefficient1` = 1.1
WHERE `entry` = 19442;

UPDATE `spell_template`
SET `effectBonusCoefficient1` = 1.2
WHERE `entry` = 19443;

-- ==============================================
-- FILE: searing_pain.sql
-- GENERATED: 20260825052735
-- ==============================================
DELETE FROM `spell_threat`
WHERE `entry` = 5676;

-- ==============================================
-- FILE: shadow_vulnerability.sql
-- GENERATED: 20260825052735
-- ==============================================
DELETE FROM `spell_proc_event`
WHERE `entry` = 17793;

UPDATE `spell_template`
SET `script_name` = 'spell_warlock_shadow_vulnerability'
WHERE `entry` IN (
    17793, 17796, 17801, 17802, 17803
    );

-- ==============================================
-- FILE: siphon_life.sql
-- GENERATED: 20260825052735
-- ==============================================
UPDATE `spell_template`
SET `effectBonusCoefficient1` = 0.1
WHERE `entry` IN (
    18265, 18879, 18880, 18881
    );

-- ==============================================
-- FILE: soothing_kiss.sql
-- GENERATED: 20260825052735
-- ==============================================
UPDATE `spell_template`
SET `script_name` = 'spell_warlock_soothing_kiss'
WHERE `entry` IN (
    6360, 7813, 11784, 11785
    );

-- ==============================================
-- FILE: soul_entrapment.sql
-- GENERATED: 20260825052735
-- ==============================================
UPDATE `spell_template`
SET `script_name` = 'spell_warlock_soul_entrapment'
WHERE `entry` IN (
    51706, 51707, 51708
    );

-- ==============================================
-- FILE: soul_fire.sql
-- GENERATED: 20260825052735
-- ==============================================
UPDATE `spell_template`
SET `effectBonusCoefficient1` = 1.14
WHERE `entry` IN (
    6353, 17924, 51683, 51684
    );

INSERT INTO `spell_proc_event`
(
    `entry`,
    `SpellFamilyName`,
    `SpellFamilyMask0`,
    `SpellFamilyMask1`,
    `SpellFamilyMask2`,
    `procFlags`,
    `procEx`
)
VALUES
(51736, 5, 64, 64, 64, 65536, 524288);

-- ==============================================
-- FILE: soul_siphon.sql
-- GENERATED: 20260825052735
-- ==============================================
UPDATE `spell_template`
SET `script_name` = 'spell_warlock_soul_siphon'
WHERE `entry` IN (
    52558, 52559, 52560
    );

UPDATE `spell_template`
SET `script_name` = 'spell_warlock_death_coil'
WHERE `entry` IN (
    6789, 17925, 17926
    );

-- ==============================================
-- FILE: spell_chain.sql
-- GENERATED: 20260825052735
-- ==============================================
INSERT INTO `spell_chain`
(
    `spell_id`,
    `prev_spell`,
    `first_spell`,
    `rank`,
    `req_spell`
)
VALUES
(51683, 17924, 6353, 3, 0),
(51684, 51683, 6353, 4, 0);

-- ==============================================
-- FILE: the_binding_succubus.sql
-- GENERATED: 20260825052735
-- ==============================================
UPDATE `creature_template`
SET `faction` = 14
WHERE `entry` = 5677;

-- ==============================================
-- FILE: trainer_updates.sql
-- GENERATED: 20260825052735
-- ==============================================
UPDATE `npc_trainer`
SET `spellcost` = 6000
WHERE `spell` = 1571;

UPDATE `npc_trainer`
SET `spellcost` = 10000
WHERE `spell` = 18160;

UPDATE `npc_trainer`
SET `spellcost` = 13000
WHERE `spell` = 51685;

UPDATE `npc_trainer`
SET `spellcost` = 20000
WHERE `spell` = 51686;

UPDATE `npc_trainer`
SET `spellcost` = 26000
WHERE `spell` = 51688;

UPDATE `npc_trainer`
SET `spellcost` = 2500
WHERE `spell` = 51693;

UPDATE `npc_trainer`
SET `spellcost` = 9000
WHERE `spell` = 51696;

UPDATE `npc_trainer`
SET `spellcost` = 7000
WHERE `spell` = 51699;

UPDATE `npc_trainer`
SET `spellcost` = 11000
WHERE `spell` = 51702;

UPDATE `npc_trainer`
SET `spellcost` = 750
WHERE `spell` = 52553;

UPDATE `npc_trainer`
SET `spellcost` = 1300
WHERE `spell` = 52554;

UPDATE `npc_trainer`
SET `spellcost` = 18000
WHERE `spell` = 52753;

UPDATE `npc_trainer`
SET `reqlevel` = 36
WHERE `spell` = 51696;
-- ==============================================
-- FILE: unleashed_potential.sql
-- GENERATED: 20260825052735
-- ==============================================
UPDATE `spell_template`
SET `script_name` = 'spell_warlock_unleashed_potential_effect'
WHERE `entry` IN (
    51718, 51719, 51720
    );

UPDATE `spell_template`
SET `script_name` = 'spell_warlock_unleashed_potential'
WHERE `entry` IN (
    51721, 51722, 51723
    );

INSERT INTO `migrations` (`Name`, `Hash`, `AppliedAt`)
SELECT '20260825052735_world', 'manual', NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `migrations` WHERE `Name` = '20260825052735_world');

-- ############################################################ 20260826183610_world

-- ==============================================
-- FILE: level_10_warrior_dual_wield.sql
-- GENERATED: 20260826183610
-- ==============================================
UPDATE `npc_trainer`
SET `reqlevel` = 10,
    `spellcost` = 1100
WHERE `entry` IN (
    911, 912, 913, 914, 985, 1229, 1901, 2119, 2131, 3041,
    3042, 3043, 3059, 3063, 3153, 3169, 3353, 3354, 3408, 3593,
    3598, 4087, 4089, 4593, 4594, 4595, 5113, 5114, 5479, 5480,
    7315, 8141, 62428, 80104, 80217, 80247, 92198
    )
AND `spell` = 1424;

INSERT INTO `migrations` (`Name`, `Hash`, `AppliedAt`)
SELECT '20260826183610_world', 'manual', NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `migrations` WHERE `Name` = '20260826183610_world');

-- ############################################################ 20260829145107_world

-- ==============================================
-- FILE: broadcast_text_ralthas.sql
-- GENERATED: 20260829145107
-- ==============================================
INSERT INTO `broadcast_text`
(
    `entry`,
    `male_text`,
    `female_text`,
    `chat_type`,
    `sound_id`,
    `language_id`,
    `emote_id1`,
    `emote_id2`,
    `emote_id3`,
    `emote_delay1`,
    `emote_delay2`,
    `emote_delay3`
)
VALUES
(6263501, 'The Brotherhood Stands for Justice!', 'The Brotherhood Stands for Justice!', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(6263502, 'The lies of Stormwind, must be told!', 'The lies of Stormwind, must be told!', 0, 0, 0, 0, 0, 0, 0, 0, 0);

-- ==============================================
-- FILE: creature_ai_events_ralthas.sql
-- GENERATED: 20260829145107
-- ==============================================
INSERT INTO `creature_ai_events`
(
    `id`,
    `creature_id`,
    `condition_id`,
    `event_type`,
    `event_inverse_phase_mask`,
    `event_chance`,
    `event_flags`,
    `event_param1`,
    `event_param2`,
    `event_param3`,
    `event_param4`,
    `action1_script`,
    `action2_script`,
    `action3_script`,
    `comment`
)
VALUES
(6263501, 62635, 0, 4, 0, 100, 0, 0, 0, 0, 0, 6263501, 0, 0, 'Ralthas - Aggro text'),
(6263502, 62635, 0, 6, 0, 100, 0, 0, 0, 0, 0, 6263502, 0, 0, 'Ralthas - Death text');

-- ==============================================
-- FILE: creature_ai_scripts_ralthas.sql
-- GENERATED: 20260829145107
-- ==============================================
INSERT INTO `creature_ai_scripts`
(
    `id`,
    `delay`,
    `priority`,
    `command`,
    `datalong`,
    `datalong2`,
    `datalong3`,
    `datalong4`,
    `target_param1`,
    `target_param2`,
    `target_type`,
    `data_flags`,
    `dataint`,
    `dataint2`,
    `dataint3`,
    `dataint4`,
    `x`,
    `y`,
    `z`,
    `o`,
    `condition_id`,
    `comments`
)
VALUES
(6263501, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6263501, 0, 0, 0, 0, 0, 0, 0, 0, 'Ralthas - Aggro text'),
(6263502, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6263502, 0, 0, 0, 0, 0, 0, 0, 0, 'Ralthas - Death text');

-- ==============================================
-- FILE: creature_equip_template_ralthas.sql
-- GENERATED: 20260829145107
-- ==============================================
INSERT INTO `creature_equip_template`
(
    `entry`,
    `equipentry1`,
    `equipentry2`,
    `equipentry3`
)
VALUES
(62635, 5276, 0, 0);

-- ==============================================
-- FILE: creature_movement_ralthas.sql
-- GENERATED: 20260829145107
-- ==============================================
INSERT INTO `creature_movement`
(
    `id`,
    `point`,
    `position_x`,
    `position_y`,
    `position_z`,
    `orientation`,
    `waittime`,
    `wander_distance`,
    `script_id`
)
VALUES
(2590698, 1, -9129.660156, -1098.790039, 73.660652, 0, 0, 0, 0),
(2590698, 2, -9135.660156, -1099.790039, 73.410652, 0, 0, 0, 0),
(2590698, 3, -9144.240234, -1096.189941, 73.585564, 0, 0, 0, 0),
(2590698, 4, -9151.490234, -1092.939941, 72.835564, 0, 0, 0, 0),
(2590698, 5, -9158.740234, -1089.439941, 72.335564, 0, 0, 0, 0),
(2590698, 6, -9164.929688, -1081.800049, 72.297607, 0, 0, 0, 0),
(2590698, 7, -9169.429688, -1075.300049, 72.797607, 0, 0, 0, 0),
(2590698, 8, -9173.929688, -1068.550049, 72.047607, 0, 0, 0, 0),
(2590698, 9, -9181.980469, -1061.069946, 71.954147, 0, 0, 0, 0),
(2590698, 10, -9188.230469, -1056.319946, 71.954147, 0, 0, 0, 0),
(2590698, 11, -9194.730469, -1051.319946, 71.454147, 0, 0, 0, 0),
(2590698, 12, -9199.480469, -1047.819946, 71.454147, 0, 0, 0, 0),
(2590698, 13, -9197.419922, -1040.030029, 71.666786, 0, 0, 0, 0),
(2590698, 14, -9195.919922, -1034.280029, 71.916786, 0, 0, 0, 0),
(2590698, 15, -9188.179688, -1031.390015, 72.076439, 0, 0, 0, 0),
(2590698, 16, -9180.679688, -1028.640015, 72.076439, 0, 0, 0, 0),
(2590698, 17, -9170.209961, -1021.630005, 71.009239, 0, 0, 0, 0),
(2590698, 18, -9164.209961, -1016.130005, 71.009239, 0, 0, 0, 0),
(2590698, 19, -9158.459961, -1010.630005, 71.509239, 0, 0, 0, 0),
(2590698, 20, -9152.459961, -1005.380005, 71.759239, 0, 0, 0, 0),
(2590698, 21, -9148.209961, -1001.130005, 71.759239, 0, 0, 0, 0),
(2590698, 22, -9139.080078, -998.104004, 71.753952, 0, 0, 0, 0),
(2590698, 23, -9131.330078, -996.104004, 72.253952, 0, 0, 0, 0),
(2590698, 24, -9123.580078, -994.104004, 72.503952, 0, 0, 0, 0),
(2590698, 25, -9114.839844, -995.919983, 72.168175, 0, 0, 0, 0),
(2590698, 26, -9107.089844, -998.169983, 72.168175, 0, 0, 0, 0),
(2590698, 27, -9099.339844, -1000.169983, 72.168175, 0, 0, 0, 0),
(2590698, 28, -9088.480469, -1006.049988, 73.142548, 0, 0, 0, 0),
(2590698, 29, -9081.980469, -1010.549988, 73.642548, 0, 0, 0, 0),
(2590698, 30, -9076.980469, -1014.049988, 73.642548, 0, 0, 0, 0),
(2590698, 31, -9073.139648, -1021.97998, 72.93187, 0, 0, 0, 0),
(2590698, 32, -9072.719727, -1027.060059, 72.91523, 0, 0, 0, 0),
(2590698, 33, -9074.790039, -1037.569946, 72.936935, 0, 0, 0, 0),
(2590698, 34, -9078.719727, -1049.339966, 73.017052, 0, 0, 0, 0),
(2590698, 35, -9082.219727, -1056.589966, 73.017052, 0, 0, 0, 0),
(2590698, 36, -9087.570312, -1065.849976, 73.801331, 0, 0, 0, 0),
(2590698, 37, -9093.570312, -1073.599976, 74.801331, 0, 0, 0, 0),
(2590698, 38, -9098.570312, -1079.849976, 74.301331, 0, 0, 0, 0),
(2590698, 39, -9105.959961, -1088.189941, 73.502892, 0, 0, 0, 0),
(2590698, 40, -9111.459961, -1093.939941, 73.752892, 0, 0, 0, 0),
(2590698, 41, -9121.660156, -1097.790039, 74.410652, 0, 0, 0, 0),
(2590698, 42, -9129.660156, -1098.790039, 73.660652, 0, 0, 0, 0);

-- ==============================================
-- FILE: creature_ralthas.sql
-- GENERATED: 20260829145107
-- ==============================================
INSERT INTO `creature`
(
    `guid`,
    `id`,
    `id2`,
    `id3`,
    `id4`,
    `map`,
    `position_x`,
    `position_y`,
    `position_z`,
    `orientation`,
    `spawntimesecsmin`,
    `spawntimesecsmax`,
    `wander_distance`,
    `health_percent`,
    `mana_percent`,
    `movement_type`,
    `spawn_flags`,
    `visibility_mod`
)
VALUES
(2590698, 62635, 0, 0, 0, 0, -9129.660156, -1098.790039, 73.660652, -2.321688652038574, 300, 300, 0, 100, 100, 2, 0, 0);

-- ==============================================
-- FILE: creature_spells_ralthas.sql
-- GENERATED: 20260829145107
-- ==============================================
INSERT INTO `creature_spells`
(
    `entry`,
    `name`,
    `spellId_1`,
    `probability_1`,
    `castTarget_1`,
    `targetParam1_1`,
    `targetParam2_1`,
    `castFlags_1`,
    `delayInitialMin_1`,
    `delayInitialMax_1`,
    `delayRepeatMin_1`,
    `delayRepeatMax_1`,
    `scriptId_1`,
    `spellId_2`,
    `probability_2`,
    `castTarget_2`,
    `targetParam1_2`,
    `targetParam2_2`,
    `castFlags_2`,
    `delayInitialMin_2`,
    `delayInitialMax_2`,
    `delayRepeatMin_2`,
    `delayRepeatMax_2`,
    `scriptId_2`,
    `spellId_3`,
    `probability_3`,
    `castTarget_3`,
    `targetParam1_3`,
    `targetParam2_3`,
    `castFlags_3`,
    `delayInitialMin_3`,
    `delayInitialMax_3`,
    `delayRepeatMin_3`,
    `delayRepeatMax_3`,
    `scriptId_3`,
    `spellId_4`,
    `probability_4`,
    `castTarget_4`,
    `targetParam1_4`,
    `targetParam2_4`,
    `castFlags_4`,
    `delayInitialMin_4`,
    `delayInitialMax_4`,
    `delayRepeatMin_4`,
    `delayRepeatMax_4`,
    `scriptId_4`,
    `spellId_5`,
    `probability_5`,
    `castTarget_5`,
    `targetParam1_5`,
    `targetParam2_5`,
    `castFlags_5`,
    `delayInitialMin_5`,
    `delayInitialMax_5`,
    `delayRepeatMin_5`,
    `delayRepeatMax_5`,
    `scriptId_5`,
    `spellId_6`,
    `probability_6`,
    `castTarget_6`,
    `targetParam1_6`,
    `targetParam2_6`,
    `castFlags_6`,
    `delayInitialMin_6`,
    `delayInitialMax_6`,
    `delayRepeatMin_6`,
    `delayRepeatMax_6`,
    `scriptId_6`,
    `spellId_7`,
    `probability_7`,
    `castTarget_7`,
    `targetParam1_7`,
    `targetParam2_7`,
    `castFlags_7`,
    `delayInitialMin_7`,
    `delayInitialMax_7`,
    `delayRepeatMin_7`,
    `delayRepeatMax_7`,
    `scriptId_7`,
    `spellId_8`,
    `probability_8`,
    `castTarget_8`,
    `targetParam1_8`,
    `targetParam2_8`,
    `castFlags_8`,
    `delayInitialMin_8`,
    `delayInitialMax_8`,
    `delayRepeatMin_8`,
    `delayRepeatMax_8`,
    `scriptId_8`
)
VALUES
(62635, 'Ralthas', 1449, 100, 1, 0, 0, 0, 0, 0, 12, 17, 0, 0, 100, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 1, 0, 0, 0, 0, 0, 0, 0, 0);

-- ==============================================
-- FILE: creature_template_update_ralthas.sql
-- GENERATED: 20260829145107
-- ==============================================
UPDATE `creature_template`
SET `scale` = 1,
    `dmg_min` = 20.211887,
    `dmg_max` = 24.467083,
    `attack_power` = 44,
    `unit_class` = 2,
    `ranged_dmg_min` = 17.192947,
    `ranged_dmg_max` = 23.640301,
    `ranged_attack_power` = 36,
    `spell_list_id` = `entry`
WHERE `entry` = 62635;

INSERT INTO `migrations` (`Name`, `Hash`, `AppliedAt`)
SELECT '20260829145107_world', 'manual', NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `migrations` WHERE `Name` = '20260829145107_world');

-- ############################################################ 20260829172251_world

-- ==============================================
-- FILE: broadcast_text_missing.sql
-- GENERATED: 20260829172251
-- ==============================================
INSERT INTO `broadcast_text`
(
    `entry`,
    `male_text`,
    `female_text`,
    `chat_type`,
    `sound_id`,
    `language_id`,
    `emote_id1`,
    `emote_id2`,
    `emote_id3`,
    `emote_delay1`,
    `emote_delay2`,
    `emote_delay3`
)
VALUES
(6241601, 'There are still many mysteries to uncover on this world. We shall not stop until ever rock is overturned.', 'There are still many mysteries to uncover on this world. We shall not stop until ever rock is overturned.', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(6263601, 'Gowlfang no leader of the Mosshide! Never was!', 'Gowlfang no leader of the Mosshide! Never was!', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(6272701, 'The beauty of nature must be protected, and upheld at all costs.', 'The beauty of nature must be protected, and upheld at all costs.', 0, 0, 0, 0, 0, 0, 0, 0, 0);

-- ==============================================
-- FILE: creature_missing.sql
-- GENERATED: 20260829172251
-- ==============================================
INSERT INTO `creature`
(
    `guid`,
    `id`,
    `id2`,
    `id3`,
    `id4`,
    `map`,
    `position_x`,
    `position_y`,
    `position_z`,
    `orientation`,
    `spawntimesecsmin`,
    `spawntimesecsmax`,
    `wander_distance`,
    `health_percent`,
    `mana_percent`,
    `movement_type`,
    `spawn_flags`,
    `visibility_mod`
)
VALUES
(2586978, 62416, 0, 0, 0, 0, -4661.589844, -1286.119995, 503.381989, 5.341770172119141, 300, 300, 0, 100, 100, 0, 0, 0),
(2590696, 62636, 0, 0, 0, 0, -3117.860107, -2674.26001, 10.3006, 1.938670039176941, 300, 300, 0, 100, 100, 0, 0, 0),
(2591767, 62727, 0, 0, 0, 1, 3674.790039, 704.505005, 8.36297, 4.7469000816345215, 300, 300, 0, 100, 100, 0, 0, 0);

-- ==============================================
-- FILE: creature_template_update_missing.sql
-- GENERATED: 20260829172251
-- ==============================================
UPDATE `creature_template`
SET `scale` = 1,
    `dmg_min` = 43.927868,
    `dmg_max` = 55.432785,
    `attack_power` = 102,
    `ranged_dmg_min` = 42.977089,
    `ranged_dmg_max` = 59.093498,
    `ranged_attack_power` = 84,
    `type` = 7,
    `type_flags` = 0,
    `gossip_menu_id` = `entry`
WHERE `entry` = 62416;

UPDATE `creature_template`
SET `scale` = 1,
    `dmg_min` = 64.519226,
    `dmg_max` = 82.5,
    `attack_power` = 136,
    `ranged_dmg_min` = 58.712193,
    `ranged_dmg_max` = 80.729271,
    `ranged_attack_power` = 112,
    `type` = 7,
    `type_flags` = 0,
    `gossip_menu_id` = `entry`
WHERE `entry` = 62636;

UPDATE `creature_template`
SET `scale` = 1,
    `dmg_min` = 66.559998,
    `dmg_max` = 78,
    `attack_power` = 90,
    `ranged_dmg_min` = 38.595112,
    `ranged_dmg_max` = 53.068275,
    `ranged_attack_power` = 72,
    `type` = 7,
    `type_flags` = 0,
    `gossip_menu_id` = `entry`
WHERE `entry` = 62727;


-- ==============================================
-- FILE: gameobject_missing.sql
-- GENERATED: 20260829172251
-- ==============================================
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
(5020838, 2003678, 1, 3674.679931640625, 708.39501953125, 7.9239501953125, 4.74753999710083, 0, 0, 0.694570451, -0.719424693, 300, 300, 100, 1, 0, 0),
(5020839, 2003622, 1, 3663.169921875, 701.677978515625, 8.34430980682373, 4.312429904937744, 0, 0, 0.833480848, -0.552548347, 300, 300, 100, 1, 0, 0),
(5020840, 2003621, 1, 3647.47998046875, 697.3250122070312, 8.344090461730957, 3.4422099590301514, 0, 0, 0.988724906, -0.149743312, 300, 300, 100, 1, 0, 0),
(5020841, 2008756, 1, 3689.8798828125, 695.7109985351562, 9.373479843139648, 2.2044200897216797, 0, 0, 0.892207651, 0.451625407, 300, 300, 100, 1, 0, 0),
(5020842, 2003621, 1, 3689.489990234375, 694.364990234375, 9.373539924621582, 2.632460117340088, 0, 0, 0.967772612, 0.251825679, 300, 300, 100, 1, 0, 0);

-- ==============================================
-- FILE: gossip_menu_missing.sql
-- GENERATED: 20260829172251
-- ==============================================
INSERT INTO `gossip_menu`
(
    `entry`,
    `text_id`,
    `script_id`,
    `condition_id`
)
VALUES
(62416, 6241601, 0, 0),
(62636, 6263601, 0, 0),
(62727, 6272701, 0, 0);

-- ==============================================
-- FILE: gowlfang_removal.sql
-- GENERATED: 20260829172251
-- ==============================================
DELETE FROM `creature`
WHERE `guid` = 2572308;

-- ==============================================
-- FILE: npc_text_missing.sql
-- GENERATED: 20260829172251
-- ==============================================
INSERT INTO `npc_text`
(
    `ID`,
    `BroadcastTextID0`,
    `Probability0`,
    `BroadcastTextID1`,
    `Probability1`,
    `BroadcastTextID2`,
    `Probability2`,
    `BroadcastTextID3`,
    `Probability3`,
    `BroadcastTextID4`,
    `Probability4`,
    `BroadcastTextID5`,
    `Probability5`,
    `BroadcastTextID6`,
    `Probability6`,
    `BroadcastTextID7`,
    `Probability7`
)
VALUES
(6241601, 6241601, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0),
(6263601, 6263601, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0),
(6272701, 6272701, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0);

-- ==============================================
-- FILE: object_scaling_missing.sql
-- GENERATED: 20260829172251
-- ==============================================
INSERT INTO `object_scaling`
(
    `fullGuid`,
    `scale`
)
VALUES
(17370417378911624358, 1.6);

INSERT INTO `migrations` (`Name`, `Hash`, `AppliedAt`)
SELECT '20260829172251_world', 'manual', NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `migrations` WHERE `Name` = '20260829172251_world');

-- ############################################################ 20260829175114_world

-- ==============================================
-- FILE: kul-tiras-pickpockting.sql
-- GENERATED: 20260829175114
-- ==============================================
DELETE FROM `pickpocketing_loot_template`
WHERE `entry` IN (
    3128, 3129
    );

INSERT INTO `pickpocketing_loot_template`
(
    `entry`,
    `item`,
    `ChanceOrQuestChance`,
    `groupid`,
    `mincountOrRef`,
    `maxcount`,
    `condition_id`
)
VALUES
(3128,118,3.0457,0,1,1,0),
(3128,774,3.0457,0,1,1,0),
(3128,2070,3.0457,0,1,1,0),
(3128,4536,3.0457,0,1,1,0),
(3128,4540,3.0457,0,1,1,0),
(3128,5363,6.0914,0,1,1,0),
(3128,6150,5.5838,0,1,1,0),
(3129,118,2.4,0,1,1,0),
(3129,774,1.6,0,1,1,0),
(3129,2070,4.0,0,1,1,0),
(3129,4536,5.6,0,1,1,0),
(3129,4540,1.6,0,1,1,0),
(3129,5363,6.4,0,1,1,0),
(3129,6150,2.4,0,1,1,0);

INSERT INTO `migrations` (`Name`, `Hash`, `AppliedAt`)
SELECT '20260829175114_world', 'manual', NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `migrations` WHERE `Name` = '20260829175114_world');

-- ############################################################ 20260830134658_world

-- ==============================================
-- FILE: skill_race_class_info_mod_dual_wield.sql
-- GENERATED: 20260830134658
-- ==============================================
CREATE TABLE IF NOT EXISTS `skill_race_class_info_mod` (
  `Id` int(10) unsigned NOT NULL DEFAULT 0,
  `SkillLineDbcRecord` int(11) NOT NULL DEFAULT -1,
  `RaceMask` int(11) NOT NULL DEFAULT -1,
  `ClassMask` int(11) NOT NULL DEFAULT -1,
  `Flags` int(11) NOT NULL DEFAULT -1,
  `MinLevel` int(11) NOT NULL DEFAULT -1,
  `SkillTierId` int(11) NOT NULL DEFAULT -1,
  `SkillCostIndex` int(11) NOT NULL DEFAULT -1,
  `Comment` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=COMPRESSED KEY_BLOCK_SIZE=8;

INSERT INTO `skill_race_class_info_mod`
(
    `Id`,
    `SkillLineDbcRecord`,
    `RaceMask`,
    `ClassMask`,
    `Flags`,
    `MinLevel`,
    `SkillTierId`,
    `SkillCostIndex`,
    `Comment`
)
VALUES
(132, -1, -1, -1, -1, 1, -1, -1, 'Show Dual Wield on trainers at all levels');

INSERT INTO `migrations` (`Name`, `Hash`, `AppliedAt`)
SELECT '20260830134658_world', 'manual', NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `migrations` WHERE `Name` = '20260830134658_world');

-- ############################################################ 20260901101113_world

-- ==============================================
-- FILE: book_of_prayer.sql
-- GENERATED: 20260901101113
-- ==============================================
UPDATE `spell_template`
SET `script_name` = 'spell_priest_book_of_prayer'
WHERE `entry` IN (
    52943, 52944
    );

-- ==============================================
-- FILE: chastise.sql
-- GENERATED: 20260901101113
-- ==============================================
UPDATE `spell_template`
SET `effectBonusCoefficient1` = 0.65
WHERE `entry` IN (
    51478, 51479, 51480
    );

UPDATE `spell_template`
SET `script_name` = 'spell_priest_chastise'
WHERE `entry` IN (
    51478, 51479, 51480
    );

-- ==============================================
-- FILE: desperate_prayer.sql
-- GENERATED: 20260901101113
-- ==============================================
UPDATE `spell_template`
SET `effectBonusCoefficient1` = 0.2278
WHERE `entry` = 13908;

UPDATE `spell_template`
SET `effectBonusCoefficient1` = 0.3366
WHERE `entry` = 19236;

UPDATE `spell_template`
SET `effectBonusCoefficient1` = 0.36465
WHERE `entry` IN (
    19238, 19240, 19241, 19242, 19243
    );

-- ==============================================
-- FILE: enlighten.sql
-- GENERATED: 20260901101113
-- ==============================================
UPDATE `spell_template`
SET `script_name` = 'spell_priest_enlighten'
WHERE `entry` = 51475;

UPDATE `spell_template`
SET `script_name` = 'spell_priest_enlighten_link'
WHERE `entry` = 51476;

DELETE FROM `spell_proc_event`
WHERE `entry` = 51475;

-- ==============================================
-- FILE: flash_heal.sql
-- GENERATED: 20260901101113
-- ==============================================
UPDATE `spell_template`
SET `effectBonusCoefficient1` = 0.36465
WHERE `entry` IN (
    2061, 9472, 9473, 9474, 10915, 10916, 10917
    );

-- ==============================================
-- FILE: force_of_will.sql
-- GENERATED: 20260901101113
-- ==============================================
INSERT INTO `spell_learn_spell`
(
    `entry`,
    `SpellID`,
    `Active`
)
VALUES
(18544, 52650, 1),
(18547, 52651, 1),
(18548, 52652, 1),
(18549, 52653, 1),
(18550, 52654, 1);

-- ==============================================
-- FILE: greater_heal.sql
-- GENERATED: 20260901101113
-- ==============================================
UPDATE `spell_template`
SET `effectBonusCoefficient1` = 0.72845
WHERE `entry` IN (
    2060, 10963, 10964, 10965, 25314
    );

-- ==============================================
-- FILE: heal.sql
-- GENERATED: 20260901101113
-- ==============================================
UPDATE `spell_template`
SET `effectBonusCoefficient1` = 0.61965
WHERE `entry` = 2054;

UPDATE `spell_template`
SET `effectBonusCoefficient1` = 0.72845
WHERE `entry` IN (
    2055, 6063, 6064
    );

-- ==============================================
-- FILE: holy_fire.sql
-- GENERATED: 20260901101113
-- ==============================================
UPDATE `spell_template`
SET `effectBonusCoefficient1` = 1
WHERE `entry` IN (
    14914, 15262, 15263, 15264, 15265, 15266, 15267, 15261
    );

-- ==============================================
-- FILE: holy_nova.sql
-- GENERATED: 20260901101113
-- ==============================================
UPDATE `spell_template`
SET `effectBonusCoefficient1` = 0.15
WHERE `entry` IN (
    15237, 15430, 15431, 27799, 27800, 27801
    );

UPDATE `spell_threat`
SET `multiplier` = 0.75
WHERE `entry` = 15237;

UPDATE `spell_template`
SET `script_name` = 'spell_priest_holy_nova'
WHERE `entry` IN (
    23455, 23458, 23459, 27803, 27804, 27805
    );

-- ==============================================
-- FILE: holy_reach.sql
-- GENERATED: 20260901101113
-- ==============================================
INSERT INTO `spell_affect`
(
    `entry`,
    `effectId`,
    `SpellFamilyMask`
)
VALUES
(27789, 0, 10738466944),
(27790, 0, 10738466944);


-- ==============================================
-- FILE: lesser_heal.sql
-- GENERATED: 20260901101113
-- ==============================================
UPDATE `spell_template`
SET `effectBonusCoefficient1` = 0.10455
WHERE `entry` = 2050;

UPDATE `spell_template`
SET `effectBonusCoefficient1` = 0.19465
WHERE `entry` = 2052;

UPDATE `spell_template`
SET `effectBonusCoefficient1` = 0.3791
WHERE `entry` = 2053;

-- ==============================================
-- FILE: lightwell.sql
-- GENERATED: 20260901101113
-- ==============================================
UPDATE `spell_template`
SET `effectBonusCoefficient1` = 0.17
WHERE `entry` = 7001;

UPDATE `spell_template`
SET `script_name` = 'spell_priest_lightwell'
WHERE `entry` = 724;

-- ==============================================
-- FILE: mind_blast.sql
-- GENERATED: 20260901101113
-- ==============================================
UPDATE `spell_template`
SET `effectBonusCoefficient1` = 0.6
WHERE `entry` IN (
    8103, 8104, 8105, 8106, 10945, 10946, 10947
    );

UPDATE `spell_threat`
SET `multiplier` = 1.7
WHERE `entry` = 8092;

-- ==============================================
-- FILE: mind_flay.sql
-- GENERATED: 20260901101113
-- ==============================================
UPDATE `spell_template`
SET `effectBonusCoefficient1` = 0.3
WHERE `entry` IN (
    15407, 17311, 17312, 17313, 17314, 18807
    );

-- ==============================================
-- FILE: night_elf_racial_quest.sql
-- GENERATED: 20260901101113
-- ==============================================
UPDATE `quest_template`
SET `RewSpell` = 52648
WHERE `entry` IN (
    5672, 5673, 5674, 5675
    );

-- ==============================================
-- FILE: pain_spike.sql
-- GENERATED: 20260901101113
-- ==============================================
UPDATE `spell_template`
SET `effectBonusCoefficient1` = 0.43
WHERE `entry` IN (
    45555, 57701, 57704, 57707
    );

UPDATE `spell_template`
SET `script_name` = 'spell_priest_pain_spike'
WHERE `entry` IN (
    57701, 57704, 57707
    );

DELETE FROM `spell_chain`
WHERE `spell_id` = 45556;

UPDATE `spell_chain`
SET `prev_spell` = 0,
    `first_spell` = 45555,
    `rank` = 1,
    `req_spell` = 0
WHERE `spell_id` = 45555;

INSERT INTO `spell_chain`
(
    `spell_id`,
    `prev_spell`,
    `first_spell`,
    `rank`,
    `req_spell`
)
VALUES
(57701,45555,45555,2,0),
(57704,57701,45555,3,0),
(57707,57704,45555,4,0);

-- ==============================================
-- FILE: power_word_shield.sql
-- GENERATED: 20260901101113
-- ==============================================
UPDATE `spell_template`
SET `effectBonusCoefficient1` = 0.35
WHERE `entry` IN (
    3747, 6065, 6066, 10898, 10899, 10900, 10901
    );

-- ==============================================
-- FILE: prayer_of_healing.sql
-- GENERATED: 20260901101113
-- ==============================================
UPDATE `spell_template`
SET `effectBonusCoefficient1` = 0.2431
WHERE `entry` IN (
    596, 996, 10960, 10961, 25316
    );

-- ==============================================
-- FILE: renew.sql
-- GENERATED: 20260901101113
-- ==============================================
UPDATE `spell_template`
SET `effectBonusCoefficient1` = 0.09350
WHERE `entry` = 139;

UPDATE `spell_template`
SET `effectBonusCoefficient1` = 0.13175
WHERE `entry` = 6074;

UPDATE `spell_template`
SET `effectBonusCoefficient1` = 0.17
WHERE `entry` IN (
    6075, 6076, 6077, 6078, 10927, 10928, 10929, 25315
    );

-- ==============================================
-- FILE: searing_shot.sql
-- GENERATED: 20260901101113
-- ==============================================
UPDATE `spell_template`
SET `effectBonusCoefficient1` = 0.33
WHERE `entry` IN (
    52638, 52640, 52642, 52644, 52646
    );

-- ==============================================
-- FILE: shadow_mend.sql
-- GENERATED: 20260901101113
-- ==============================================
UPDATE `spell_template`
SET `effectBonusCoefficient1` = 0.5
WHERE `entry` = 45554;

UPDATE `spell_template`
SET `script_name` = 'spell_priest_shadow_mend'
WHERE `entry` = 45554;

-- ==============================================
-- FILE: smite.sql
-- GENERATED: 20260901101113
-- ==============================================
UPDATE `spell_template`
SET `effectBonusCoefficient1` = 0.12915
WHERE `entry` = 585;

UPDATE `spell_template`
SET `effectBonusCoefficient1` = 0.28455
WHERE `entry` = 591;

UPDATE `spell_template`
SET `effectBonusCoefficient1` = 0.5817
WHERE `entry` = 598;

UPDATE `spell_template`
SET `effectBonusCoefficient1` = 0.7497
WHERE `entry` IN (
    984, 1004, 6060, 10933, 10934, 45968
    );

-- ==============================================
-- FILE: spirit_tap.sql
-- GENERATED: 20260901101113
-- ==============================================
INSERT INTO `spell_proc_event`
(
    `entry`,
    `SchoolMask`,
    `SpellFamilyName`,
    `SpellFamilyMask0`,
    `SpellFamilyMask1`,
    `SpellFamilyMask2`,
    `procFlags`,
    `procEx`,
    `ppmRate`,
    `CustomChance`,
    `Cooldown`
)
VALUES
(15270, 0, 6, 8192, 0, 0, 65538, 2, 0, 0, 0),
(15335, 0, 6, 8192, 0, 0, 65538, 2, 0, 0, 0),
(15336, 0, 6, 8192, 0, 0, 65538, 2, 0, 0, 0),
(15337, 0, 6, 8192, 0, 0, 65538, 2, 0, 0, 0),
(15338, 0, 6, 8192, 0, 0, 65538, 2, 0, 0, 0);

-- ==============================================
-- FILE: starshards.sql
-- GENERATED: 20260901101113
-- ==============================================
UPDATE `spell_template`
SET `effectBonusCoefficient1` = 0.2
WHERE `entry` = 10797;

UPDATE `spell_template`
SET `effectBonusCoefficient1` = 0.35
WHERE `entry` = 19296;

UPDATE `spell_template`
SET `effectBonusCoefficient1` = 0.4
WHERE `entry` IN (
    19299, 19302, 19303, 19304, 19305
    );

-- ==============================================
-- FILE: vampiric_embrace.sql
-- GENERATED: 20260901101113
-- ==============================================
INSERT INTO `spell_threat`
(
    `entry`,
    `Threat`,
    `multiplier`,
    `ap_bonus`
)
VALUES
(45966, 0, 0, 0);

INSERT INTO `migrations` (`Name`, `Hash`, `AppliedAt`)
SELECT '20260901101113_world', 'manual', NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `migrations` WHERE `Name` = '20260901101113_world');

-- ############################################################ 20260901174017_world

-- ==============================================
-- FILE: remove_deprecated_npcs.sql
-- GENERATED: 20260901174017
-- ==============================================
-- Mysterious Stranger NPCs.
DELETE FROM `creature`
WHERE `guid` IN (
    2581911, 2561537, 2561538, 2561539, 2561542, 2561543, 2561544, 2582199
    );

-- Glyph Master NPCs.
DELETE FROM `creature`
WHERE `guid` IN (
    2569062, 2582354, 2569280, 2569281, 2569282, 2569283, 2569284, 2579235
    );

-- temporary flying mount NPCs.
DELETE FROM `creature`
WHERE `guid` IN (
    2569823, 2568873
    );

-- postworker NPCs.
DELETE FROM `creature`
WHERE `guid` IN (
    2578341, 2578340
    );

INSERT INTO `migrations` (`Name`, `Hash`, `AppliedAt`)
SELECT '20260901174017_world', 'manual', NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `migrations` WHERE `Name` = '20260901174017_world');

-- ############################################################ 20260901202213_world

-- ==============================================
-- FILE: spell_coeff_update.sql
-- GENERATED: 20260901202213
-- ==============================================
-- Hurricane
UPDATE `spell_template`
SET `effectBonusCoefficient1` = 0.096
WHERE `entry` IN (
    16914, 17401, 17402
    );

-- Arcane Missiles Rank 3+
UPDATE `spell_template`
SET `effectBonusCoefficient1` = 0.328
WHERE `entry` IN (
    7270, 8419, 8418, 10273, 10274, 25346
    );

-- Holy Light Rank 1
UPDATE `spell_template`
SET `effectBonusCoefficient1` = 0.33
WHERE `entry` = 635;

-- Holy Shield
UPDATE `spell_template`
SET `effectBonusCoefficient2` = 0.15
WHERE `entry` IN (
    20169, 20925, 20927, 20928
    );

-- Swipe
UPDATE `spell_template`
SET `effectBonusCoefficient1` = 0.04
WHERE `entry` IN (
    779, 780, 769, 9754, 9908
    );

INSERT INTO `migrations` (`Name`, `Hash`, `AppliedAt`)
SELECT '20260901202213_world', 'manual', NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `migrations` WHERE `Name` = '20260901202213_world');

-- ############################################################ 20260902074750_world

-- ==============================================
-- FILE: lulu_quest.sql
-- GENERATED: 20260902074750
-- ==============================================
UPDATE `quest_template`
SET `PrevQuestId` = 0
WHERE `entry` = 60007;

INSERT INTO `migrations` (`Name`, `Hash`, `AppliedAt`)
SELECT '20260902074750_world', 'manual', NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `migrations` WHERE `Name` = '20260902074750_world');

-- ############################################################ 20260903063722_world

-- ==============================================
-- FILE: arms_of_thaurissan_unrelenting_strikes.sql
-- GENERATED: 20260903063722
-- ==============================================
UPDATE `spell_template`
SET `script_name` = 'spell_item_unrelenting_strikes'
WHERE `entry` = 49368;

-- ==============================================
-- FILE: avengers_judgement_righteous_command.sql
-- GENERATED: 20260903063722
-- ==============================================
INSERT INTO `spell_affect`
(
    `entry`,
    `effectId`,
    `SpellFamilyMask`
)
VALUES
(51818, 0, 17179870208),
(51819, 0, 17179870208);

-- ==============================================
-- FILE: bonescythe_reduced_threat.sql
-- GENERATED: 20260903063722
-- ==============================================
INSERT INTO `spell_affect`
(
    `entry`,
    `effectId`,
    `SpellFamilyMask`
)
VALUES
(28811, 0, 549764202496);

-- ==============================================
-- FILE: brotherhood_reduced_ability_costs.sql
-- GENERATED: 20260903063722
-- ==============================================
INSERT INTO `spell_affect`
(
    `entry`,
    `effectId`,
    `SpellFamilyMask`
)
VALUES
(41361, 0, 34359754816);

-- ==============================================
-- FILE: brotherhood_warrior_5p.sql
-- GENERATED: 20260903063722
-- ==============================================
INSERT INTO `spell_proc_event`
(
    `entry`,
    `SchoolMask`,
    `SpellFamilyName`,
    `SpellFamilyMask0`,
    `SpellFamilyMask1`,
    `SpellFamilyMask2`,
    `procFlags`,
    `procEx`,
    `ppmRate`,
    `CustomChance`,
    `Cooldown`
)
VALUES
(41363, 0, 4, 8192, 16, 1048576, 16, 524288, 0, 0, 0);

-- ==============================================
-- FILE: cenarion_blessing.sql
-- GENERATED: 20260903063722
-- ==============================================
UPDATE `spell_template`
SET `script_name` = 'spell_druid_cenarion_blessing'
WHERE `entry` = 52325;

-- ==============================================
-- FILE: defias_leather_opportunistic_strike.sql
-- GENERATED: 20260903063722
-- ==============================================
UPDATE `spell_template`
SET `script_name` = 'spell_item_opportunistic_strike'
WHERE `entry` = 44072;

-- ==============================================
-- FILE: embrace_of_the_viper_wild_regeneration.sql
-- GENERATED: 20260903063722
-- ==============================================
UPDATE `spell_template`
SET `script_name` = 'spell_item_wild_regeneration'
WHERE `entry` = 44070;

-- comfy-wow: the fork's 20260731120000 already inserted 44070; upstream's row supersedes it.
DELETE FROM `spell_proc_event` WHERE `entry` = 44070;

INSERT INTO `spell_proc_event`
(
    `entry`,
    `SchoolMask`,
    `SpellFamilyName`,
    `SpellFamilyMask0`,
    `SpellFamilyMask1`,
    `SpellFamilyMask2`,
    `procFlags`,
    `procEx`,
    `ppmRate`,
    `CustomChance`,
    `Cooldown`
)
VALUES
(44070, 0, 0, 0, 0, 0, 664232, 0, 0, 0, 180);

-- ==============================================
-- FILE: enigma_nether_overcharge.sql
-- GENERATED: 20260903063722
-- ==============================================
UPDATE `spell_template`
SET `script_name` = 'spell_mage_evocation'
WHERE `entry` = 12051;

-- ==============================================
-- FILE: frostfire_erupting_shield.sql
-- GENERATED: 20260903063722
-- ==============================================
UPDATE `spell_template`
SET `script_name` = 'spell_mage_mana_shield'
WHERE `entry` IN (
    1463, 8494, 8495, 10191, 10192, 10193, 17740, 17741
    );

-- ==============================================
-- FILE: giantstalker_improved_volley_multishot.sql
-- GENERATED: 20260903063722
-- ==============================================
INSERT INTO `spell_affect`
(
    `entry`,
    `effectId`,
    `SpellFamilyMask`
)
VALUES
(23566, 0, 8589938688);

-- ==============================================
-- FILE: nemesis_corruption_siphon_life_duration.sql
-- GENERATED: 20260903063722
-- ==============================================
INSERT INTO `spell_affect`
(
    `entry`,
    `effectId`,
    `SpellFamilyMask`
)
VALUES
(52601, 0, 4294967298);

-- ==============================================
-- FILE: pursuit_multishot_carve_damage.sql
-- GENERATED: 20260903063722
-- ==============================================
INSERT INTO `spell_affect`
(
    `entry`,
    `effectId`,
    `SpellFamilyMask`
)
VALUES
(28539, 0, 8589938688);

-- ==============================================
-- FILE: ravenstalker_multishot_carve_cooldown.sql
-- GENERATED: 20260903063722
-- ==============================================
INSERT INTO `spell_affect`
(
    `entry`,
    `effectId`,
    `SpellFamilyMask`
)
VALUES
(52602, 0, 8589938688);

-- ==============================================
-- FILE: redemption_holy_power.sql
-- GENERATED: 20260903063722
-- ==============================================
UPDATE `spell_template`
SET `script_name` = 'spell_item_holy_power'
WHERE `entry` = 51821;

INSERT INTO `spell_proc_event`
(
    `entry`,
    `SchoolMask`,
    `SpellFamilyName`,
    `SpellFamilyMask0`,
    `SpellFamilyMask1`,
    `SpellFamilyMask2`,
    `procFlags`,
    `procEx`,
    `ppmRate`,
    `CustomChance`,
    `Cooldown`
)
VALUES
(51821, 0, 10, 3223347200, 0, 0, 0, 0, 0, 0, 0);

-- ==============================================
-- FILE: scarlet_crusade_purging_flames.sql
-- GENERATED: 20260903063722
-- ==============================================
UPDATE `spell_template`
SET `script_name` = 'spell_item_purging_flames'
WHERE `entry` = 44074;

-- ==============================================
-- FILE: stormcaller_elemental_shell.sql
-- GENERATED: 20260903063722
-- ==============================================
UPDATE `spell_template`
SET `script_name` = 'spell_shaman_earth_shield'
WHERE `entry` IN (
    45525, 51525, 51526
    );

-- ==============================================
-- FILE: stormhowl_3p_bonus.sql
-- GENERATED: 20260903063722
-- ==============================================
UPDATE `spell_template` SET
    `script_name` = 'spell_shaman_stormhowl_trigger_elemental_shield'
WHERE `entry` = 52680;
-- ==============================================
-- FILE: stormhowl_improved_clearcasting.sql
-- GENERATED: 20260903063722
-- ==============================================
UPDATE `spell_template`
SET `script_name` = 'spell_shaman_elemental_focus'
WHERE `entry` = 16164;

INSERT INTO `spell_affect`
(
    `entry`,
    `effectId`,
    `SpellFamilyMask`
)
VALUES
(46761, 0, 6599486734339);

-- ==============================================
-- FILE: stormreaver_impending_doom.sql
-- GENERATED: 20260903063722
-- ==============================================
UPDATE `spell_template`
SET `script_name` = 'spell_item_impending_doom'
WHERE `entry` = 44080;

INSERT INTO `spell_proc_event`
(
    `entry`,
    `SchoolMask`,
    `SpellFamilyName`,
    `SpellFamilyMask0`,
    `SpellFamilyMask1`,
    `SpellFamilyMask2`,
    `procFlags`,
    `procEx`,
    `ppmRate`,
    `CustomChance`,
    `Cooldown`
)
VALUES
(44080, 32, 0, 0, 0, 0, 655360, 0, 0, 0, 0),
(44081, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0);

-- ==============================================
-- FILE: unseen_path_steady_raptor_mongoose_crit.sql
-- GENERATED: 20260903063722
-- ==============================================
INSERT INTO `spell_affect`
(
    `entry`,
    `effectId`,
    `SpellFamilyMask`
)
VALUES
(52684, 0, 68719476738);

-- ==============================================
-- FILE: warrior_intercept_intervene_bonuses.sql
-- GENERATED: 20260903063722
-- ==============================================
INSERT INTO `spell_affect`
(
    `entry`,
    `effectId`,
    `SpellFamilyMask`
)
VALUES
(22738, 0, 9663676416),
(26111, 0, 9663676416);

INSERT INTO `migrations` (`Name`, `Hash`, `AppliedAt`)
SELECT '20260903063722_world', 'manual', NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `migrations` WHERE `Name` = '20260903063722_world');

-- ############################################################ 20260903115534_world

-- ==============================================
-- FILE: broadcast_text_northwindfixes.sql
-- GENERATED: 20260903115534
-- ==============================================
INSERT INTO `broadcast_text`
(
    `entry`,
    `male_text`,
    `female_text`,
    `chat_type`,
    `sound_id`,
    `language_id`,
    `emote_id1`,
    `emote_id2`,
    `emote_id3`,
    `emote_delay1`,
    `emote_delay2`,
    `emote_delay3`
)
VALUES
(6230601, 'My wife Lena has her final resting place here. She was taken from us far too early, and my duties to my Lord don''t give me enough time to spend with my children Estelle and Joshua. Once these lands have returned to normalcy and peace returns, I will resign my position and fully embrace my role as father. It''s the least they deserve.', 'My wife Lena has her final resting place here. She was taken from us far too early, and my duties to my Lord don''t give me enough time to spend with my children Estelle and Joshua. Once these lands have returned to normalcy and peace returns, I will resign my position and fully embrace my role as father. It''s the least they deserve.', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(6238001, 'My father used to fish in this small pond, but he would never take the fish home. I think he felt a certain sadness for them—raised, essentially, in captivity, in a small, limited place to roam. I wonder if that''s how he felt about our home when he decided to join the Defias. Mh, I suppose he got the opposite of what he wanted in the Stockades.', 'My father used to fish in this small pond, but he would never take the fish home. I think he felt a certain sadness for them—raised, essentially, in captivity, in a small, limited place to roam. I wonder if that''s how he felt about our home when he decided to join the Defias. Mh, I suppose he got the opposite of what he wanted in the Stockades.', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(6248001, 'The Admiralty had a heated debate about us Kul Tirans participating in this tournament, from what I''ve heard. Seems they stand pretty divided about our relations with Stormwind. I can''t really blame them for thinking like that, given Stormwind''s direction in diplomacy with the Horde.', 'The Admiralty had a heated debate about us Kul Tirans participating in this tournament, from what I''ve heard. Seems they stand pretty divided about our relations with Stormwind. I can''t really blame them for thinking like that, given Stormwind''s direction in diplomacy with the Horde.', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(6247901, 'You must forgive Malleville''s attitude. He lost many good friends and comrades in the Second War, and experienced many of its horrors personally. I will make sure he stays civil and doesn''t hurt anyone, I''ll give you my word.', 'You must forgive Malleville''s attitude. He lost many good friends and comrades in the Second War, and experienced many of its horrors personally. I will make sure he stays civil and doesn''t hurt anyone, I''ll give you my word.', 0, 0, 0, 0, 0, 0, 0, 0, 0);

-- ==============================================
-- FILE: creature_template_update_northwindfixes.sql
-- GENERATED: 20260903115534
-- ==============================================
UPDATE `creature_template`
SET `gossip_menu_id` = `entry`
WHERE `entry` IN (
    62306, 62380, 62480, 62479
    );

-- ==============================================
-- FILE: gossip_menu_northwindfixes.sql
-- GENERATED: 20260903115534
-- ==============================================
INSERT INTO `gossip_menu`
(
    `entry`,
    `text_id`,
    `script_id`,
    `condition_id`
)
VALUES
(62306, 6230601, 0, 0),
(62380, 6238001, 0, 0),
(62479, 6247901, 0, 0),
(62480, 6248001, 0, 0);

-- ==============================================
-- FILE: npc_text_northwindfixes.sql
-- GENERATED: 20260903115534
-- ==============================================
INSERT INTO `npc_text`
(
    `ID`,
    `BroadcastTextID0`,
    `Probability0`,
    `BroadcastTextID1`,
    `Probability1`,
    `BroadcastTextID2`,
    `Probability2`,
    `BroadcastTextID3`,
    `Probability3`,
    `BroadcastTextID4`,
    `Probability4`,
    `BroadcastTextID5`,
    `Probability5`,
    `BroadcastTextID6`,
    `Probability6`,
    `BroadcastTextID7`,
    `Probability7`
)
VALUES
(6230601, 6230601, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0),
(6238001, 6238001, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0),
(6247901, 6247901, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0),
(6248001, 6248001, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0);

INSERT INTO `migrations` (`Name`, `Hash`, `AppliedAt`)
SELECT '20260903115534_world', 'manual', NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `migrations` WHERE `Name` = '20260903115534_world');

-- ############################################################ 20260903141940_world

-- ==============================================
-- FILE: clearcasting_affect.sql
-- GENERATED: 20260903141940
-- ==============================================
INSERT INTO `spell_affect`
(
    `entry`,
    `effectId`,
    `SpellFamilyMask`
)
VALUES
(45542, 0, 6599486734339);

-- ==============================================
-- FILE: earthshatterer_garb_seismic_strength.sql
-- GENERATED: 20260903141940
-- ==============================================
INSERT INTO `spell_proc_event`
(
    `entry`,
    `SchoolMask`,
    `SpellFamilyName`,
    `SpellFamilyMask0`,
    `SpellFamilyMask1`,
    `SpellFamilyMask2`,
    `procFlags`,
    `procEx`,
    `ppmRate`,
    `CustomChance`,
    `Cooldown`
)
VALUES
(46112, 0, 11, 1125899906842624, 0, 0, 65536, 524288, 0, 0, 0);

INSERT INTO `migrations` (`Name`, `Hash`, `AppliedAt`)
SELECT '20260903141940_world', 'manual', NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `migrations` WHERE `Name` = '20260903141940_world');

-- ############################################################ 20260903191647_world

-- ==============================================
-- FILE: shaman_racial_quest_reward_spells.sql
-- GENERATED: 20260903191647
-- ==============================================
UPDATE `quest_template`
SET `RewSpellCast` = 51669
WHERE `entry` = 40348;

UPDATE `quest_template`
SET `RewSpellCast` = 47263
WHERE `entry` = 40353;

INSERT INTO `migrations` (`Name`, `Hash`, `AppliedAt`)
SELECT '20260903191647_world', 'manual', NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `migrations` WHERE `Name` = '20260903191647_world');

-- ############################################################ 20260905075842_world

-- ==============================================
-- FILE: claw_of_reckless_abandon.sql
-- GENERATED: 20260905075842
-- ==============================================
UPDATE `spell_template`
SET `script_name` = 'spell_item_wild_thrash'
WHERE `entry` = 58137;

-- ==============================================
-- FILE: droplet_of_nordrassil.sql
-- GENERATED: 20260905075842
-- ==============================================
INSERT INTO `spell_proc_event`
(
    `entry`,
    `SchoolMask`,
    `SpellFamilyName`,
    `SpellFamilyMask0`,
    `SpellFamilyMask1`,
    `SpellFamilyMask2`,
    `procFlags`,
    `procEx`,
    `ppmRate`,
    `CustomChance`,
    `Cooldown`
)
VALUES (58226, 0, 0, 0, 0, 0, 0, 1048584, 0, 0, 4);

-- ==============================================
-- FILE: elementium_reaper.sql
-- GENERATED: 20260905075842
-- ==============================================
INSERT INTO `spell_proc_event`
(
    `entry`,
    `SchoolMask`,
    `SpellFamilyName`,
    `SpellFamilyMask0`,
    `SpellFamilyMask1`,
    `SpellFamilyMask2`,
    `procFlags`,
    `procEx`,
    `ppmRate`,
    `CustomChance`,
    `Cooldown`
)
VALUES (52910, 0, 0, 0, 0, 0, 0, 0, 0, 0, 20);

-- ==============================================
-- FILE: fetish_of_the_endless_bond.sql
-- GENERATED: 20260905075842
-- ==============================================
UPDATE `spell_template`
SET `script_name` = 'spell_item_endless_bond'
WHERE `entry` = 58124;

UPDATE `spell_template`
SET `script_name` = 'spell_item_endless_bond_target'
WHERE `entry` = 58126;

-- ==============================================
-- FILE: heart_of_windhorn.sql
-- GENERATED: 20260905075842
-- ==============================================
INSERT INTO `spell_proc_event`
(
    `entry`,
    `SchoolMask`,
    `SpellFamilyName`,
    `SpellFamilyMask0`,
    `SpellFamilyMask1`,
    `SpellFamilyMask2`,
    `procFlags`,
    `procEx`,
    `ppmRate`,
    `CustomChance`,
    `Cooldown`
)
VALUES (52829, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2);

-- ==============================================
-- FILE: idol_of_brambleskin.sql
-- GENERATED: 20260905075842
-- ==============================================
INSERT INTO `spell_affect`
(
    `entry`,
    `effectId`,
    `SpellFamilyMask`
)
VALUES
(52868, 0, 274877906944);

-- ==============================================
-- FILE: idol_of_equilibrium.sql
-- GENERATED: 20260905075842
-- ==============================================
INSERT INTO `spell_affect`
(
    `entry`,
    `effectId`,
    `SpellFamilyMask`
)
VALUES
(52845, 0, 1),
(52845, 1, 4);

UPDATE `spell_template`
SET `script_name` = 'spell_druid_idol_of_equilibrium'
WHERE `entry` IN (52924, 52925);

-- ==============================================
-- FILE: idol_of_the_thorned_grove.sql
-- GENERATED: 20260905075842
-- ==============================================
INSERT INTO `spell_proc_event`
(
    `entry`,
    `SchoolMask`,
    `SpellFamilyName`,
    `SpellFamilyMask0`,
    `SpellFamilyMask1`,
    `SpellFamilyMask2`,
    `procFlags`,
    `procEx`,
    `ppmRate`,
    `CustomChance`,
    `Cooldown`
)
VALUES
(52427, 0, 7, 512, 0, 0, 0, 0, 0, 0, 0);

-- ==============================================
-- FILE: libram_of_hallowed_ground.sql
-- GENERATED: 20260905075842
-- ==============================================
INSERT INTO `spell_proc_event`
(
    `entry`,
    `SchoolMask`,
    `SpellFamilyName`,
    `SpellFamilyMask0`,
    `SpellFamilyMask1`,
    `SpellFamilyMask2`,
    `procFlags`,
    `procEx`,
    `ppmRate`,
    `CustomChance`,
    `Cooldown`
)
VALUES (52900, 0, 10, 32, 0, 0, 0, 524288, 0, 0, 0);

-- ==============================================
-- FILE: libram_of_the_exorciser.sql
-- GENERATED: 20260905075842
-- ==============================================
INSERT INTO `spell_mod`
(
    `Id`,
    `SpellFamilyName`,
    `SpellFamilyFlags`,
    `Comment`
)
VALUES
(2812, 10, 4398046511104, 'Holy Wrath family mask'),
(10318, 10, 4398046511104, 'Holy Wrath family mask');

INSERT INTO `spell_affect`
(
    `entry`,
    `effectId`,
    `SpellFamilyMask`
)
VALUES (52936, 0, 5497558138880);

-- ==============================================
-- FILE: pysans_new_greatsword.sql
-- GENERATED: 20260905075842
-- ==============================================
UPDATE `spell_template`
SET `script_name` = 'spell_item_pysans_wrath'
WHERE `entry` = 58135;

-- ==============================================
-- FILE: shieldrender_talisman.sql
-- GENERATED: 20260905075842
-- ==============================================
INSERT INTO `spell_proc_event`
(
    `entry`,
    `SchoolMask`,
    `SpellFamilyName`,
    `SpellFamilyMask0`,
    `SpellFamilyMask1`,
    `SpellFamilyMask2`,
    `procFlags`,
    `procEx`,
    `ppmRate`,
    `CustomChance`,
    `Cooldown`
)
VALUES (51146, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0);

-- ==============================================
-- FILE: totem_of_ancient_rites.sql
-- GENERATED: 20260905075842
-- ==============================================
UPDATE `spell_template`
SET `script_name` = 'spell_shaman_totemic_slam'
WHERE `entry` = 45500;

UPDATE `spell_template`
SET `script_name` = 'spell_shaman_hex'
WHERE `entry` = 45504;

UPDATE `spell_template`
SET `script_name` = 'spell_shaman_feral_spirit'
WHERE `entry` = 45505;

-- ==============================================
-- FILE: totem_of_calm_cascades.sql
-- GENERATED: 20260905075842
-- ==============================================
INSERT INTO `spell_proc_event`
(
    `entry`,
    `SchoolMask`,
    `SpellFamilyName`,
    `SpellFamilyMask0`,
    `SpellFamilyMask1`,
    `SpellFamilyMask2`,
    `procFlags`,
    `procEx`,
    `ppmRate`,
    `CustomChance`,
    `Cooldown`
)
VALUES
(52834, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0);

UPDATE `spell_template`
SET `effectBonusCoefficient1` = 0.15
WHERE `entry` = 52836;

-- ==============================================
-- FILE: totem_of_thundercall.sql
-- GENERATED: 20260905075842
-- ==============================================
INSERT INTO `spell_affect`
(
    `entry`,
    `effectId`,
    `SpellFamilyMask`
)
VALUES
(52871, 0, 2199023255552);

UPDATE `spell_template`
SET `script_name` = 'spell_shaman_thundercall'
WHERE `entry` = 52872;

-- ==============================================
-- FILE: trifang_shredders.sql
-- GENERATED: 20260905075842
-- ==============================================
UPDATE `spell_template`
SET `script_name` = 'spell_item_trifang_shredders'
WHERE `entry` = 58185;

INSERT INTO `spell_proc_event`
(
    `entry`,
    `SchoolMask`,
    `SpellFamilyName`,
    `SpellFamilyMask0`,
    `SpellFamilyMask1`,
    `SpellFamilyMask2`,
    `procFlags`,
    `procEx`,
    `ppmRate`,
    `CustomChance`,
    `Cooldown`
)
VALUES (58185, 0, 0, 0, 0, 0, 20, 0, 0, 6, 0);

-- ==============================================
-- FILE: whispering_fragment_of_aln.sql
-- GENERATED: 20260905075842
-- ==============================================
UPDATE `spell_template`
SET `script_name` = 'spell_item_whispers_of_aln'
WHERE `entry` = 58231;

UPDATE `spell_template`
SET `script_name` = 'spell_item_cacophony_of_knowledge'
WHERE `entry` = 58232;

-- ==============================================
-- FILE: will_of_the_chieftain.sql
-- GENERATED: 20260905075842
-- ==============================================
UPDATE `spell_template`
SET `script_name` = 'spell_item_will_of_the_chieftain'
WHERE `entry` = 58131;

INSERT INTO `migrations` (`Name`, `Hash`, `AppliedAt`)
SELECT '20260905075842_world', 'manual', NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `migrations` WHERE `Name` = '20260905075842_world');

-- ############################################################ 20260905103856_world

-- ==============================================
-- FILE: satyr_updates.sql
-- GENERATED: 20260905103856
-- ==============================================

INSERT INTO `creature_display_info_addon`
(
    `display_id`,
    `bounding_radius`,
    `combat_reach`,
    `gender`,
    `display_id_other_gender`
)
VALUES
(21511, 1.5, 1.5, 1, 2010),
(21512, 1.5, 1.5, 1, 2011),
(21514, 1.5, 1.5, 1, 11346),
(21516, 1.5, 1.5, 1, 2007),
(21518, 1.5, 1.5, 1, 2875),
(21519, 1.5, 1.5, 1, 11344),
(21572, 1.5, 1.5, 1, 2012),
(21575, 1.5, 1.5, 1, 6741),
(21576, 1.5, 1.5, 1, 2018),
(21577, 1.5, 1.5, 1, 2017),
(21580, 1.5, 1.5, 1, 11332),
(21582, 1.5, 1.5, 1, 11331),
(21583, 1.5, 1.5, 1, 11337),
(21584, 1.5, 1.5, 1, 11333),
(21585, 1.5, 1.5, 1, 11334),
(21586, 1.5, 1.5, 1, 11335),
(21587, 1.5, 1.5, 1, 8575),
(21588, 1.5, 1.5, 1, 2019),
(21589, 1.5, 1.5, 1, 11336),
(21592, 1.5, 1.5, 1, 10032),
(21593, 1.5, 1.5, 1, 7649),
(21594, 1.5, 1.5, 1, 11340);

UPDATE `creature_display_info_addon`
SET `display_id_other_gender` = 21516
WHERE `display_id` = 2007;

UPDATE `creature_display_info_addon`
SET `display_id_other_gender` = 21511
WHERE `display_id` = 2010;

UPDATE `creature_display_info_addon`
SET `display_id_other_gender` = 21512
WHERE `display_id` = 2011;

UPDATE `creature_display_info_addon`
SET `display_id_other_gender` = 21572
WHERE `display_id` = 2012;

UPDATE `creature_display_info_addon`
SET `display_id_other_gender` = 21513
WHERE `display_id` = 2013;

UPDATE `creature_display_info_addon`
SET `display_id_other_gender` = 21573
WHERE `display_id` = 2014;

UPDATE `creature_display_info_addon`
SET `display_id_other_gender` = 21577
WHERE `display_id` = 2017;

UPDATE `creature_display_info_addon`
SET `display_id_other_gender` = 21576
WHERE `display_id` = 2018;

UPDATE `creature_display_info_addon`
SET `display_id_other_gender` = 21588
WHERE `display_id` = 2019;

UPDATE `creature_display_info_addon`
SET `display_id_other_gender` = 21581
WHERE `display_id` = 2020;

UPDATE `creature_display_info_addon`
SET `display_id_other_gender` = 21574
WHERE `display_id` = 2021;

UPDATE `creature_display_info_addon`
SET `display_id_other_gender` = 21595
WHERE `display_id` = 2687;

UPDATE `creature_display_info_addon`
SET `display_id_other_gender` = 21518
WHERE `display_id` = 2875;

UPDATE `creature_display_info_addon`
SET `display_id_other_gender` = 21590
WHERE `display_id` = 2878;

UPDATE `creature_display_info_addon`
SET `display_id_other_gender` = 21575
WHERE `display_id` = 6741;

UPDATE `creature_display_info_addon`
SET `display_id_other_gender` = 21591
WHERE `display_id` = 6743;

UPDATE `creature_display_info_addon`
SET `display_id_other_gender` = 21593
WHERE `display_id` = 7649;

UPDATE `creature_display_info_addon`
SET `display_id_other_gender` = 21587
WHERE `display_id` = 8575;

UPDATE `creature_display_info_addon`
SET `display_id_other_gender` = 21592
WHERE `display_id` = 10032;

UPDATE `creature_display_info_addon`
SET `display_id_other_gender` = 21582
WHERE `display_id` = 11331;

UPDATE `creature_display_info_addon`
SET `display_id_other_gender` = 21580
WHERE `display_id` = 11332;

UPDATE `creature_display_info_addon`
SET `display_id_other_gender` = 21584
WHERE `display_id` = 11333;

UPDATE `creature_display_info_addon`
SET `display_id_other_gender` = 21585
WHERE `display_id` = 11334;

UPDATE `creature_display_info_addon`
SET `display_id_other_gender` = 21586
WHERE `display_id` = 11335;

UPDATE `creature_display_info_addon`
SET `display_id_other_gender` = 21589
WHERE `display_id` = 11336;

UPDATE `creature_display_info_addon`
SET `display_id_other_gender` = 21583
WHERE `display_id` = 11337;

UPDATE `creature_display_info_addon`
SET `display_id_other_gender` = 21578
WHERE `display_id` = 11338;

UPDATE `creature_display_info_addon`
SET `display_id_other_gender` = 21594
WHERE `display_id` = 11340;

UPDATE `creature_display_info_addon`
SET `display_id_other_gender` = 21519
WHERE `display_id` = 11344;

UPDATE `creature_display_info_addon`
SET `display_id_other_gender` = 21579
WHERE `display_id` = 11345;

UPDATE `creature_display_info_addon`
SET `display_id_other_gender` = 21514
WHERE `display_id` = 11346;

UPDATE `creature_display_info_addon`
SET `gender` = 1,
    `display_id_other_gender` = 0
WHERE `display_id` = 21513;

UPDATE `creature_display_info_addon`
SET `gender` = 1,
    `display_id_other_gender` = 2014
WHERE `display_id` = 21573;

UPDATE `creature_display_info_addon`
SET `gender` = 1,
    `display_id_other_gender` = 2021
WHERE `display_id` = 21574;

UPDATE `creature_display_info_addon`
SET `gender` = 1,
    `display_id_other_gender` = 11338
WHERE `display_id` = 21578;

UPDATE `creature_display_info_addon`
SET `gender` = 1,
    `display_id_other_gender` = 11345
WHERE `display_id` = 21579;

UPDATE `creature_display_info_addon`
SET `gender` = 1,
    `display_id_other_gender` = 2020
WHERE `display_id` = 21581;

UPDATE `creature_display_info_addon`
SET `gender` = 1,
    `display_id_other_gender` = 2878
WHERE `display_id` = 21590;

UPDATE `creature_display_info_addon`
SET `gender` = 1,
    `display_id_other_gender` = 6743
WHERE `display_id` = 21591;

UPDATE `creature_display_info_addon`
SET `gender` = 1,
    `display_id_other_gender` = 2687
WHERE `display_id` = 21595;

UPDATE `creature_template`
SET `display_id2` = 21590
WHERE `entry` IN (
    3752, 6200
    );

UPDATE `creature_template`
SET `display_id2` = 21519
WHERE `entry` = 3754;

UPDATE `creature_template`
SET `display_id2` = 21514
WHERE `entry` = 3755;

UPDATE `creature_template`
SET `display_id2` = 21579
WHERE `entry` = 3757;

UPDATE `creature_template`
SET `display_id2` = 21511
WHERE `entry` = 3758;

UPDATE `creature_template`
SET `display_id2` = 21518
WHERE `entry` = 3759;

UPDATE `creature_template`
SET `display_id2` = 21512
WHERE `entry` = 3762;

UPDATE `creature_template`
SET `display_id2` = 21575
WHERE `entry` IN (
    3763, 4670
    );

UPDATE `creature_template`
SET `display_id2` = 21516
WHERE `entry` = 3765;

UPDATE `creature_template`
SET `display_id2` = 21576
WHERE `entry` = 3767;

UPDATE `creature_template`
SET `display_id2` = 21577
WHERE `entry` IN (
    3770, 92123, 92126
    );

UPDATE `creature_template`
SET `display_id2` = 21513
WHERE `entry` = 3771;

UPDATE `creature_template`
SET `display_id2` = 21574
WHERE `entry` IN (
    4671, 4799, 11452, 11792, 62528
    );

UPDATE `creature_template`
SET `display_id2` = 21573
WHERE `entry` IN (
    4672, 4675, 4798, 11456
    );

UPDATE `creature_template`
SET `display_id2` = 21582
WHERE `entry` IN (
    4673, 6125
    );

UPDATE `creature_template`
SET `display_id2` = 21580
WHERE `entry` IN (
    4674, 6126
    );

UPDATE `creature_template`
SET `display_id2` = 21572
WHERE `entry` = 4788;

UPDATE `creature_template`
SET `display_id2` = 21512
WHERE `entry` IN (
    4789, 60426
    );

UPDATE `creature_template`
SET `display_id2` = 21581
WHERE `entry` IN (
    6127, 11453
    );

UPDATE `creature_template`
SET `display_id2` = 21591
WHERE `entry` IN (
    6201, 62811
    );

UPDATE `creature_template`
SET `display_id2` = 21578
WHERE `entry` IN (
    6202, 11791, 62812, 62881, 62883, 62944
    );

UPDATE `creature_template`
SET `display_id2` = 21588
WHERE `entry` = 7105;

UPDATE `creature_template`
SET `display_id2` = 21587
WHERE `entry` = 7106;

UPDATE `creature_template`
SET `display_id2` = 21583
WHERE `entry` = 7107;

UPDATE `creature_template`
SET `display_id2` = 21584
WHERE `entry` = 7108;

UPDATE `creature_template`
SET `display_id2` = 21585
WHERE `entry` IN (
    7109, 92124, 92125
    );

UPDATE `creature_template`
SET `display_id2` = 21589
WHERE `entry` = 7110;

UPDATE `creature_template`
SET `display_id2` = 21586
WHERE `entry` = 7111;

UPDATE `creature_template`
SET `display_id2` = 21579
WHERE `entry` IN (
    11451, 11790
    );

UPDATE `creature_template`
SET `display_id2` = 21592
WHERE `entry` = 11454;

UPDATE `creature_template`
SET `display_id2` = 21593
WHERE `entry` = 11455;

UPDATE `creature_template`
SET `display_id2` = 21594
WHERE `entry` = 11457;

UPDATE `creature_template`
SET `display_id2` = 21592
WHERE `entry` IN (
    61338, 61339, 61340, 61341
    );

UPDATE `creature_template`
SET `display_id2` = 21595
WHERE `entry` IN (
    62810, 62882, 62884
    );

INSERT INTO `migrations` (`Name`, `Hash`, `AppliedAt`)
SELECT '20260905103856_world', 'manual', NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `migrations` WHERE `Name` = '20260905103856_world');

-- ############################################################ 20260905183441_world

-- ==============================================
-- FILE: elemental_invasion_disable.sql
-- GENERATED: 20260905183441
-- ==============================================
UPDATE `game_event`
SET `disabled` = 1
WHERE `entry` = 13;

INSERT INTO `migrations` (`Name`, `Hash`, `AppliedAt`)
SELECT '20260905183441_world', 'manual', NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `migrations` WHERE `Name` = '20260905183441_world');

-- ############################################################ 20260905205619_world

-- ==============================================
-- FILE: alter_gossip_menu_ids_mediumint.sql
-- GENERATED: 20260905205619
-- ==============================================
ALTER TABLE `gossip_menu`
MODIFY `entry` mediumint(8) unsigned NOT NULL DEFAULT 0;

ALTER TABLE `gossip_menu_option`
MODIFY `menu_id` mediumint(8) unsigned NOT NULL DEFAULT 0;

ALTER TABLE `locales_gossip_menu_option`
MODIFY `menu_id` mediumint(8) unsigned NOT NULL DEFAULT 0;

-- ==============================================
-- FILE: broadcast_text_balor_fp_ally.sql
-- GENERATED: 20260905205619
-- ==============================================
INSERT INTO `broadcast_text`
(
    `entry`,
    `male_text`,
    `female_text`,
    `chat_type`,
    `sound_id`,
    `language_id`,
    `emote_id1`,
    `emote_id2`,
    `emote_id3`,
    `emote_delay1`,
    `emote_delay2`,
    `emote_delay3`
)
VALUES
(8016301, '<Seems like Gryphon''s got something on his mind...>', '<Seems like Gryphon''s got something on his mind...>', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(8016302, 'Take me to Balor!', 'Take me to Balor!', 0, 0, 0, 0, 0, 0, 0, 0, 0);

-- ==============================================
-- FILE: creature_template_update_balor_fp_ally.sql
-- GENERATED: 20260905205619
-- ==============================================
UPDATE `creature_template`
SET `gossip_menu_id` = `entry`
WHERE `entry` = 80163;

-- ==============================================
-- FILE: gossip_menu_balor_fp_ally.sql
-- GENERATED: 20260905205619
-- ==============================================
INSERT INTO `gossip_menu`
(
    `entry`,
    `text_id`,
    `script_id`,
    `condition_id`
)
VALUES
(80163, 8016301, 0, 0);

-- ==============================================
-- FILE: gossip_menu_option_balor_fp_ally.sql
-- GENERATED: 20260905205619
-- ==============================================
INSERT INTO `gossip_menu_option`
(
    `menu_id`,
    `id`,
    `option_icon`,
    `option_text`,
    `option_broadcast_text`,
    `option_id`,
    `npc_option_npcflag`,
    `action_menu_id`,
    `action_poi_id`,
    `action_script_id`,
    `box_coded`,
    `box_money`,
    `box_text`,
    `box_broadcast_text`,
    `condition_id`
)
VALUES
(80163, 0, 0, 'Take me to Balor!', 8016302, 1, 1, -1, 0, 8016301, 0, 0, '', 0, 0);

-- ==============================================
-- FILE: gossip_scripts_balor_fp_ally.sql
-- GENERATED: 20260905205619
-- ==============================================
INSERT INTO `gossip_scripts`
(
    `id`,
    `delay`,
    `priority`,
    `command`,
    `datalong`,
    `datalong2`,
    `datalong3`,
    `datalong4`,
    `target_param1`,
    `target_param2`,
    `target_type`,
    `data_flags`,
    `dataint`,
    `dataint2`,
    `dataint3`,
    `dataint4`,
    `x`,
    `y`,
    `z`,
    `o`,
    `condition_id`,
    `comments`
)
VALUES
(8016301, 0, 0, 30, 298, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.0, 0.0, 0.0, 0.0, 0, 'Steelwing - Start Taxi Path to Stormbreaker Point');

-- ==============================================
-- FILE: npc_text_balor_fp_ally.sql
-- GENERATED: 20260905205619
-- ==============================================
INSERT INTO `npc_text`
(
    `ID`,
    `BroadcastTextID0`,
    `Probability0`,
    `BroadcastTextID1`,
    `Probability1`,
    `BroadcastTextID2`,
    `Probability2`,
    `BroadcastTextID3`,
    `Probability3`,
    `BroadcastTextID4`,
    `Probability4`,
    `BroadcastTextID5`,
    `Probability5`,
    `BroadcastTextID6`,
    `Probability6`,
    `BroadcastTextID7`,
    `Probability7`
)
VALUES
(8016301, 8016301, 1.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0);

INSERT INTO `migrations` (`Name`, `Hash`, `AppliedAt`)
SELECT '20260905205619_world', 'manual', NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `migrations` WHERE `Name` = '20260905205619_world');

-- ############################################################ 20260906081248_world

-- ==============================================
-- FILE: a_dark_knight_rises.sql
-- GENERATED: 20260906081248
-- ==============================================
INSERT INTO `event_scripts`
(
    `id`,
    `delay`,
    `priority`,
    `command`,
    `datalong`,
    `datalong2`,
    `datalong3`,
    `datalong4`,
    `target_param1`,
    `target_param2`,
    `target_type`,
    `data_flags`,
    `dataint`,
    `dataint2`,
    `dataint3`,
    `dataint4`,
    `x`,
    `y`,
    `z`,
    `o`,
    `condition_id`,
    `comments`
)
VALUES
(2020170, 0, 0, 22, 14, 3, 0, 0, 2589264, 0, 9, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'Black Sealed Chest - The Dark Knight - Set temporary hostile faction'),
(2020170, 0, 1, 26, 0, 0, 0, 0, 2589264, 0, 9, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'Black Sealed Chest - The Dark Knight - Attack player');

UPDATE `quest_template`
SET `NextQuestId` = 41665
WHERE `entry` = 41664;
-- ==============================================
-- FILE: among_the_jousters.sql
-- GENERATED: 20260906081248
-- ==============================================
UPDATE `quest_template`
SET `NextQuestId` = 41664
WHERE `entry` = 41663;

-- ==============================================
-- FILE: darker_than_iron.sql
-- GENERATED: 20260906081248
-- ==============================================
DELETE FROM `creature`
WHERE `guid` IN (
    2599290, 2599291, 2599292, 2599293, 2599294, 2599295, 2599296, 2599330, 2599331, 2599332,
    2599333, 2599334, 2599335, 2599336, 2599349, 2599378, 2599379, 2599380, 2599381, 2599382,
    2599383, 2599384, 2600047, 2600048, 2600049, 2600050, 2600051, 2600052, 2600053, 2600054,
    2600055, 2600056, 2600057, 2600058, 2600059, 2600060, 2600061
    );

DELETE FROM `gameobject`
WHERE `id` = 2000838;

-- ==============================================
-- FILE: deathcap_and_widows_frill.sql
-- GENERATED: 20260906081248
-- ==============================================
INSERT INTO `conditions`
(
    `condition_entry`,
    `type`,
    `value1`,
    `value2`,
    `value3`,
    `value4`,
    `flags`
)
VALUES
(41648, 9, 41648, 1, 0, 0, 0);

INSERT INTO `broadcast_text`
(
    `entry`,
    `male_text`,
    `female_text`,
    `chat_type`,
    `sound_id`,
    `language_id`,
    `emote_id1`,
    `emote_id2`,
    `emote_id3`,
    `emote_delay1`,
    `emote_delay2`,
    `emote_delay3`
)
VALUES
(6248904, 'Greetings Judith. I am sorry to bother you again, but do you have something personal from one of your children? It may help me locate them', 'Greetings Judith. I am sorry to bother you again, but do you have something personal from one of your children? It may help me locate them', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(6248905, 'What? Something Personal? Excuse me, this comes as a bit of a surprise. What on Azeroth would you use it for...? I am sorry, I should not interfere with your work. If you need it, I have this comb of my dear Sara. I brushed her hair just before I left for... Please, bring back my sweet darlings, the thought of Sara and Timothy all frightened breaks my heart!', 'What? Something Personal? Excuse me, this comes as a bit of a surprise. What on Azeroth would you use it for...? I am sorry, I should not interfere with your work. If you need it, I have this comb of my dear Sara. I brushed her hair just before I left for... Please, bring back my sweet darlings, the thought of Sara and Timothy all frightened breaks my heart!', 0, 0, 0, 0, 0, 0, 0, 0, 0);

INSERT INTO `npc_text`
(
    `ID`,
    `BroadcastTextID0`,
    `Probability0`,
    `BroadcastTextID1`,
    `Probability1`,
    `BroadcastTextID2`,
    `Probability2`,
    `BroadcastTextID3`,
    `Probability3`,
    `BroadcastTextID4`,
    `Probability4`,
    `BroadcastTextID5`,
    `Probability5`,
    `BroadcastTextID6`,
    `Probability6`,
    `BroadcastTextID7`,
    `Probability7`
)
VALUES
(6248905, 6248905, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);

INSERT INTO `gossip_menu`
(
    `entry`,
    `text_id`,
    `script_id`,
    `condition_id`
)
VALUES
(6248905, 6248905, 0, 0);

INSERT INTO `gossip_menu_option`
(
    `menu_id`,
    `id`,
    `option_icon`,
    `option_text`,
    `option_broadcast_text`,
    `option_id`,
    `npc_option_npcflag`,
    `action_menu_id`,
    `action_poi_id`,
    `action_script_id`,
    `box_coded`,
    `box_money`,
    `box_text`,
    `box_broadcast_text`,
    `condition_id`
)
VALUES
(62489, 1, 0, 'Greetings Judith. I am sorry to bother you again, but do you have something personal from one of your children? It may help me locate them', 6248904, 1, 1, 6248905, 0, 6248904, 0, 0, '', 0, 41648);

INSERT INTO `gossip_scripts`
(
    `id`,
    `delay`,
    `priority`,
    `command`,
    `datalong`,
    `datalong2`,
    `datalong3`,
    `datalong4`,
    `target_param1`,
    `target_param2`,
    `target_type`,
    `data_flags`,
    `dataint`,
    `dataint2`,
    `dataint3`,
    `dataint4`,
    `x`,
    `y`,
    `z`,
    `o`,
    `condition_id`,
    `comments`
)
VALUES
(6248904, 0, 0, 17, 41695, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 41648, 'Deathcap And Widow''s Frill - Judith Flenning - Give Sara''s Comb');

-- ==============================================
-- FILE: empty_houses.sql
-- GENERATED: 20260906081248
-- ==============================================
INSERT INTO `conditions`
(
    `condition_entry`,
    `type`,
    `value1`,
    `value2`,
    `value3`,
    `value4`,
    `flags`
)
VALUES
(41643, 9, 41643, 1, 0, 0, 0);

UPDATE `gossip_menu_option`
SET `action_script_id` = 6248901,
    `condition_id` = 41643
WHERE `menu_id` = 62489
  AND `id` = 0;

UPDATE `gossip_menu_option`
SET `action_script_id` = 6215301,
    `condition_id` = 41643
WHERE `menu_id` = 62153
  AND `id` = 0;

UPDATE `gossip_menu_option`
SET `action_script_id` = 6215401,
    `condition_id` = 41643
WHERE `menu_id` = 62154
  AND `id` = 0;

INSERT INTO `gossip_scripts`
(
    `id`,
    `delay`,
    `priority`,
    `command`,
    `datalong`,
    `datalong2`,
    `datalong3`,
    `datalong4`,
    `target_param1`,
    `target_param2`,
    `target_type`,
    `data_flags`,
    `dataint`,
    `dataint2`,
    `dataint3`,
    `dataint4`,
    `x`,
    `y`,
    `z`,
    `o`,
    `condition_id`,
    `comments`
)
VALUES
(6248901, 0, 0, 8, 60068, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 41643, 'Empty Houses - Judith Flenning - Quest Credit'),
(6215301, 0, 0, 8, 60067, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 41643, 'Empty Houses - Bailiff Lancaster - Quest Credit'),
(6215401, 0, 0, 8, 60066, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 41643, 'Empty Houses - Ignatz - Quest Credit');

-- ==============================================
-- FILE: goody_bag.sql
-- GENERATED: 20260906081248
-- ==============================================
INSERT INTO `conditions`
(
    `condition_entry`,
    `type`,
    `value1`,
    `value2`,
    `value3`,
    `value4`,
    `flags`
)
VALUES
(41668, 9, 41668, 1, 0, 0, 0);

UPDATE `gossip_menu_option`
SET `action_menu_id` = 0,
    `action_script_id` = 62146,
    `condition_id` = 41668
WHERE `menu_id` = 62146;

INSERT INTO `gossip_scripts`
(
    `id`,
    `delay`,
    `priority`,
    `command`,
    `datalong`,
    `datalong2`,
    `datalong3`,
    `datalong4`,
    `target_param1`,
    `target_param2`,
    `target_type`,
    `data_flags`,
    `dataint`,
    `dataint2`,
    `dataint3`,
    `dataint4`,
    `x`,
    `y`,
    `z`,
    `o`,
    `condition_id`,
    `comments`
)
VALUES
(62146, 0, 0, 17, 41737, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 41668, 'Goody Bag - Marisa Arello - Give Bundle of Apples');

UPDATE `quest_template`
SET `NextQuestId` = 41669
WHERE `entry` = 41668;
-- ==============================================
-- FILE: in_need_of_shoes.sql
-- GENERATED: 20260906081248
-- ==============================================
INSERT INTO `conditions`
(
    `condition_entry`,
    `type`,
    `value1`,
    `value2`,
    `value3`,
    `value4`,
    `flags`
)
VALUES
(41667, 9, 41667, 1, 0, 0, 0);

INSERT INTO `broadcast_text`
(
    `entry`,
    `male_text`,
    `female_text`,
    `chat_type`,
    `sound_id`,
    `language_id`,
    `emote_id1`,
    `emote_id2`,
    `emote_id3`,
    `emote_delay1`,
    `emote_delay2`,
    `emote_delay3`
)
VALUES
(8045202, 'I am here to collect the enchanted horseshoes', 'I am here to collect the enchanted horseshoes', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(8045203, 'Indeed. I have already received word and payment, they are yours to carry back to where they now belong.', 'Indeed. I have already received word and payment, they are yours to carry back to where they now belong.', 0, 0, 0, 0, 0, 0, 0, 0, 0);

INSERT INTO `npc_text`
(
    `ID`,
    `BroadcastTextID0`,
    `Probability0`,
    `BroadcastTextID1`,
    `Probability1`,
    `BroadcastTextID2`,
    `Probability2`,
    `BroadcastTextID3`,
    `Probability3`,
    `BroadcastTextID4`,
    `Probability4`,
    `BroadcastTextID5`,
    `Probability5`,
    `BroadcastTextID6`,
    `Probability6`,
    `BroadcastTextID7`,
    `Probability7`
)
VALUES
(8045202, 8045203, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);

INSERT INTO `gossip_menu`
(
    `entry`,
    `text_id`,
    `script_id`,
    `condition_id`
)
VALUES
(8045202, 8045202, 0, 0);

INSERT INTO `gossip_menu_option`
(
    `menu_id`,
    `id`,
    `option_icon`,
    `option_text`,
    `option_broadcast_text`,
    `option_id`,
    `npc_option_npcflag`,
    `action_menu_id`,
    `action_poi_id`,
    `action_script_id`,
    `box_coded`,
    `box_money`,
    `box_text`,
    `box_broadcast_text`,
    `condition_id`
)
VALUES
(59138, 0, 0, 'I am here to collect the enchanted horseshoes', 8045202, 1, 1, 8045202, 0, 8045202, 0, 0, NULL, 0, 41667);

INSERT INTO `gossip_scripts`
(
    `id`,
    `delay`,
    `priority`,
    `command`,
    `datalong`,
    `datalong2`,
    `datalong3`,
    `datalong4`,
    `target_param1`,
    `target_param2`,
    `target_type`,
    `data_flags`,
    `dataint`,
    `dataint2`,
    `dataint3`,
    `dataint4`,
    `x`,
    `y`,
    `z`,
    `o`,
    `condition_id`,
    `comments`
)
VALUES
(8045202, 0, 0, 17, 41735, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 41667, 'In Need of Shoes - Give Enchanted Horse Shoes');

-- ==============================================
-- FILE: lonesome_arnold.sql
-- GENERATED: 20260906081248
-- ==============================================
INSERT INTO `conditions`
(
    `condition_entry`,
    `type`,
    `value1`,
    `value2`,
    `value3`,
    `value4`,
    `flags`
)
VALUES
(41642, 9, 41642, 1, 0, 0, 0);

UPDATE `gossip_menu_option`
SET `action_menu_id` = -1,
    `action_script_id` = 62492,
    `condition_id` = 41642
WHERE `menu_id` = 62492
  AND `id` = 0;

INSERT INTO `gossip_scripts`
(
    `id`,
    `delay`,
    `priority`,
    `command`,
    `datalong`,
    `datalong2`,
    `datalong3`,
    `datalong4`,
    `target_param1`,
    `target_param2`,
    `target_type`,
    `data_flags`,
    `dataint`,
    `dataint2`,
    `dataint3`,
    `dataint4`,
    `x`,
    `y`,
    `z`,
    `o`,
    `condition_id`,
    `comments`
)
VALUES
(62492, 0, 0, 17, 41687, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 41642, 'Lonesome Arnold - Give Broken Locket');

-- ==============================================
-- FILE: school_assistance.sql
-- GENERATED: 20260906081248
-- ==============================================
INSERT INTO `conditions`
(
    `condition_entry`,
    `type`,
    `value1`,
    `value2`,
    `value3`,
    `value4`,
    `flags`
)
VALUES
(41637, 9, 41637, 1, 0, 0, 0);

DELETE FROM `gossip_menu`
WHERE `entry` IN (
    62300,62301,62302,62303, 30357, 30360, 30367, 30355
    );

DELETE FROM `gossip_menu_option`
WHERE `menu_id` IN (
    62300, 62301, 62302, 62303, 30357, 30360, 30367, 30355
    );

DELETE FROM `npc_text`
WHERE `ID` IN (
    6230203, 6230204, 6230302, 6230303, 6230002, 6230102, 6230202, 6230001, 6230101, 6230201,
    6230301
    );

DELETE FROM `broadcast_text`
WHERE `entry` IN (
    6230001, 6230002, 6230003, 6230004, 6230005, 6230101, 6230102, 6230103, 6230104, 6230105,
    6230201, 6230202, 6230203, 6230204, 6230205, 6230206, 6230301, 6230302, 6230303, 6230304,
    6230305
    );

INSERT INTO `broadcast_text`
(
    `entry`,
    `male_text`,
    `female_text`,
    `chat_type`,
    `sound_id`,
    `language_id`,
    `emote_id1`,
    `emote_id2`,
    `emote_id3`,
    `emote_delay1`,
    `emote_delay2`,
    `emote_delay3`
)
VALUES
(6230001, 'When I am all grown up, I''ll be a guard; protecting people, just like my big brother!', 'When I am all grown up, I''ll be a guard; protecting people, just like my big brother!', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(6230002, 'I can''t remember who fought against the pirates... I hope Sister Argent is not mad at me...', 'I can''t remember who fought against the pirates... I hope Sister Argent is not mad at me...', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(6230003, 'Florien Balor.', 'Florien Balor.', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(6230004, 'Priscilla Balor.', 'Priscilla Balor.', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(6230005, 'Daria Balor.', 'Daria Balor.', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(6230006, 'Yes, it was Duke Balor''s daughter! Thank you very much!', 'Yes, it was Duke Balor''s daughter! Thank you very much!', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(6230101, 'My grandfather used to be mayor, you know. I love him very much, I visit him every Wednesday with my mother!', 'My grandfather used to be mayor, you know. I love him very much, I visit him every Wednesday with my mother!', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(6230102, 'Excuse me, do you know what they found on that island with the... uhm, what was it? Beelor?', 'Excuse me, do you know what they found on that island with the... uhm, what was it? Beelor?', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(6230103, 'Gold veins.', 'Gold veins.', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(6230104, 'Treasures.', 'Treasures.', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(6230105, 'Heaps of candy.', 'Heaps of candy.', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(6230106, 'Oh! The shiny yellow stones, I saw one of those at the blacksmith once!', 'Oh! The shiny yellow stones, I saw one of those at the blacksmith once!', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(6230107, 'Hehe, you''re funny!', 'Hehe, you''re funny!', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(6230201, 'School is so boring. I''d rather throw some punches with Brick, atleast he knows how to have fun!', 'School is so boring. I''d rather throw some punches with Brick, atleast he knows how to have fun!', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(6230202, 'The others always laugh at me for forgetting the name of Stormwind''s second king. It''s getting embarrassing...', 'The others always laugh at me for forgetting the name of Stormwind''s second king. It''s getting embarrassing...', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(6230203, 'Theoden Wrynn.', 'Theoden Wrynn.', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(6230204, 'Barathen Wrynn.', 'Barathen Wrynn.', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(6230205, 'Llane Wrynn.', 'Llane Wrynn.', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(6230206, 'Of course! I should really memorize his name. Thank you!', 'Of course! I should really memorize his name. Thank you!', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(6230301, 'Father said I should speak more with the others here at the church, but I am a bit shy...', 'Father said I should speak more with the others here at the church, but I am a bit shy...', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(6230302, 'I took a small nap during last week''s school and missed who was very close to Duke Balor and Stormwind - can you remind me? I don''t want to disappoint Sister Argent.', 'I took a small nap during last week''s school and missed who was very close to Duke Balor and Stormwind - can you remind me? I don''t want to disappoint Sister Argent.', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(6230303, 'Arnor family.', 'Arnor family.', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(6230304, 'Grahan family.', 'Grahan family.', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(6230305, 'Prestor family.', 'Prestor family.', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(6230306, 'Thank you! Sister Argent is a very nice woman, so I want to do my best to make her smile!', 'Thank you! Sister Argent is a very nice woman, so I want to do my best to make her smile!', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(6244701, 'I am the altar boy! Brother Graham said that is a huge responsibility.', 'I am the altar boy! Brother Graham said that is a huge responsibility.', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(6230099, 'Hm, I''m not sure that''s what it was...', 'Hm, I''m not sure that''s what it was...', 0, 0, 0, 0, 0, 0, 0, 0, 0);

INSERT INTO `gossip_menu`
(
    `entry`,
    `text_id`,
    `script_id`,
    `condition_id`
)
VALUES
(6230001, 6230001, 0, 0),
(6230001, 6230002, 0, 41637),
(6230003, 6230006, 0, 0),
(6230101, 6230101, 0, 0),
(6230101, 6230102, 0, 41637),
(6230103, 6230107, 0, 0),
(6230104, 6230106, 0, 0),
(6230201, 6230201, 0, 0),
(6230201, 6230202, 0, 41637),
(6230203, 6230206, 0, 0),
(6230301, 6230301, 0, 0),
(6230301, 6230302, 0, 41637),
(6230303, 6230306, 0, 0),
(62447, 6244701, 0, 0),
(6230099, 6230099, 0, 0);

INSERT INTO `npc_text`
(
    `ID`,
    `BroadcastTextID0`,
    `Probability0`,
    `BroadcastTextID1`,
    `Probability1`,
    `BroadcastTextID2`,
    `Probability2`,
    `BroadcastTextID3`,
    `Probability3`,
    `BroadcastTextID4`,
    `Probability4`,
    `BroadcastTextID5`,
    `Probability5`,
    `BroadcastTextID6`,
    `Probability6`,
    `BroadcastTextID7`,
    `Probability7`
)
VALUES
(6230001, 6230001, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0),
(6230002, 6230002, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0),
(6230006, 6230006, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0),
(6230101, 6230101, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0),
(6230102, 6230102, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0),
(6230106, 6230106, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0),
(6230107, 6230107, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0),
(6230201, 6230201, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0),
(6230202, 6230202, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0),
(6230206, 6230206, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0),
(6230301, 6230301, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0),
(6230302, 6230302, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0),
(6230306, 6230306, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0),
(6244701, 6244701, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0),
(6230099, 6230099, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0);

INSERT INTO `gossip_menu_option`
(
    `menu_id`,
    `id`,
    `option_icon`,
    `option_text`,
    `option_broadcast_text`,
    `option_id`,
    `npc_option_npcflag`,
    `action_menu_id`,
    `action_poi_id`,
    `action_script_id`,
    `box_coded`,
    `box_money`,
    `box_text`,
    `box_broadcast_text`,
    `condition_id`
)
VALUES
(6230001, 0, 7, 'Florien Balor.', 6230003, 1, 1, 6230099, 0, 0, 0, 0, '', 0, 41637),
(6230001, 1, 7, 'Priscilla Balor.', 6230004, 1, 1, 6230099, 0, 0, 0, 0, '', 0, 41637),
(6230001, 2, 7, 'Daria Balor.', 6230005, 1, 1, 6230003, 0, 6230005, 0, 0, '', 0, 41637),
(6230101, 0, 7, 'Gold veins.', 6230103, 1, 1, 6230104, 0, 6230103, 0, 0, '', 0, 41637),
(6230101, 1, 7, 'Treasures.', 6230104, 1, 1, 6230099, 0, 0, 0, 0, '', 0, 41637),
(6230101, 2, 7, 'Heaps of candy.', 6230105, 1, 1, 6230103, 0, 0, 0, 0, '', 0, 41637),
(6230201, 0, 7, 'Theoden Wrynn.', 6230203, 1, 1, 6230099, 0, 0, 0, 0, '', 0, 41637),
(6230201, 1, 7, 'Barathen Wrynn.', 6230204, 1, 1, 6230203, 0, 6230204, 0, 0, '', 0, 41637),
(6230201, 2, 7, 'Llane Wrynn.', 6230205, 1, 1, 6230099, 0, 0, 0, 0, '', 0, 41637),
(6230301, 0, 7, 'Arnor family.', 6230303, 1, 1, 6230099, 0, 0, 0, 0, '', 0, 41637),
(6230301, 1, 7, 'Grahan family.', 6230304, 1, 1, 6230303, 0, 6230304, 0, 0, '', 0, 41637),
(6230301, 2, 7, 'Prestor family.', 6230305, 1, 1, 6230099, 0, 0, 0, 0, '', 0, 41637);

INSERT INTO `gossip_scripts`
(
    `id`,
    `delay`,
    `priority`,
    `command`,
    `datalong`,
    `datalong2`,
    `datalong3`,
    `datalong4`,
    `target_param1`,
    `target_param2`,
    `target_type`,
    `data_flags`,
    `dataint`,
    `dataint2`,
    `dataint3`,
    `dataint4`,
    `x`,
    `y`,
    `z`,
    `o`,
    `condition_id`,
    `comments`
)
VALUES
(6230005, 0, 0, 8, 60078, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 41637, 'School Assistance - Lloyd - Quest Credit'),
(6230103, 0, 0, 8, 60063, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 41637, 'School Assistance - Ellie - Quest Credit'),
(6230204, 0, 0, 8, 60064, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 41637, 'School Assistance - Randolph - Quest Credit'),
(6230304, 0, 0, 8, 60065, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 41637, 'School Assistance - Tio - Quest Credit');

UPDATE `creature_template`
SET `gossip_menu_id` = 6230001
WHERE `entry` = 62300;

UPDATE `creature_template`
SET `gossip_menu_id` = 6230101
WHERE `entry` = 62301;

UPDATE `creature_template`
SET `gossip_menu_id` = 6230201
WHERE `entry` = 62302;

UPDATE `creature_template`
SET `gossip_menu_id` = 6230301
WHERE `entry` = 62303;

UPDATE `creature_template`
SET `gossip_menu_id` = `entry`
WHERE `entry` = 62447;

-- ==============================================
-- FILE: shadows_vision.sql
-- GENERATED: 20260906081248
-- ==============================================
INSERT INTO `conditions`
(
    `condition_entry`,
    `type`,
    `value1`,
    `value2`,
    `value3`,
    `value4`,
    `flags`
)
VALUES
(41684, 9, 41684, 1, 0, 0, 0);

INSERT INTO `broadcast_text`
(
    `entry`,
    `male_text`,
    `female_text`,
    `chat_type`,
    `sound_id`,
    `language_id`,
    `emote_id1`,
    `emote_id2`,
    `emote_id3`,
    `emote_delay1`,
    `emote_delay2`,
    `emote_delay3`
)
VALUES
(6249002, '<Inspect the body.>', '<Inspect the body.>', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(6249003, '<You turn her body to the side, making her face the cavern ceiling. An expression of dread and terror is carved into her young features. Grey and withered eyes complete the traumatic image.>', '<You turn her body to the side, making her face the cavern ceiling. An expression of dread and terror is carved into her young features. Grey and withered eyes complete the traumatic image.>', 0, 0, 0, 0, 0, 0, 0, 0, 0);

INSERT INTO `npc_text`
(
    `ID`,
    `BroadcastTextID0`,
    `Probability0`,
    `BroadcastTextID1`,
    `Probability1`,
    `BroadcastTextID2`,
    `Probability2`,
    `BroadcastTextID3`,
    `Probability3`,
    `BroadcastTextID4`,
    `Probability4`,
    `BroadcastTextID5`,
    `Probability5`,
    `BroadcastTextID6`,
    `Probability6`,
    `BroadcastTextID7`,
    `Probability7`
)
VALUES
(6249003, 6249003, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);

INSERT INTO `gossip_menu`
(
    `entry`,
    `text_id`,
    `script_id`,
    `condition_id`
)
VALUES
(6249002, 6249003, 0, 0);

INSERT INTO `gossip_menu_option`
(
    `menu_id`,
    `id`,
    `option_icon`,
    `option_text`,
    `option_broadcast_text`,
    `option_id`,
    `npc_option_npcflag`,
    `action_menu_id`,
    `action_poi_id`,
    `action_script_id`,
    `box_coded`,
    `box_money`,
    `box_text`,
    `box_broadcast_text`,
    `condition_id`
)
VALUES
(62490, 0, 0, '<Inspect the body.>', 6249002, 1, 1, 6249002, 0, 6249002, 0, 0, '', 0, 41684);

INSERT INTO `gossip_scripts`
(
    `id`,
    `delay`,
    `priority`,
    `command`,
    `datalong`,
    `datalong2`,
    `datalong3`,
    `datalong4`,
    `target_param1`,
    `target_param2`,
    `target_type`,
    `data_flags`,
    `dataint`,
    `dataint2`,
    `dataint3`,
    `dataint4`,
    `x`,
    `y`,
    `z`,
    `o`,
    `condition_id`,
    `comments`
)
VALUES
(6249002, 0, 0, 8, 60071, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 41684, 'Shadow''s Vision - Quest Credit');

-- ==============================================
-- FILE: the_messenger_of_northwind.sql
-- GENERATED: 20260906081248
-- ==============================================
INSERT INTO `conditions`
(
    `condition_entry`,
    `type`,
    `value1`,
    `value2`,
    `value3`,
    `value4`,
    `flags`
)
VALUES
(41768, 9, 41768, 1, 0, 0, 0);

UPDATE `gossip_menu_option`
SET `action_script_id` = 62164,
    `condition_id` = 41768
WHERE `menu_id` = 62164
  AND `id` = 0;

INSERT INTO `gossip_scripts`
(
    `id`,
    `delay`,
    `priority`,
    `command`,
    `datalong`,
    `datalong2`,
    `datalong3`,
    `datalong4`,
    `target_param1`,
    `target_param2`,
    `target_type`,
    `data_flags`,
    `dataint`,
    `dataint2`,
    `dataint3`,
    `dataint4`,
    `x`,
    `y`,
    `z`,
    `o`,
    `condition_id`,
    `comments`
)
VALUES
(62164, 0, 0, 17, 41865, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 41768, 'The Messenger Of Northwind - Sir Amberwood - Give Sir Amberwood''s Report');

UPDATE `gossip_menu_option`
SET `action_menu_id` = 6215302,
    `condition_id` = 41768
WHERE `menu_id` = 62153
  AND `id` = 1;

INSERT INTO `broadcast_text`
(
    `entry`,
    `male_text`,
    `female_text`,
    `chat_type`,
    `sound_id`,
    `language_id`,
    `emote_id1`,
    `emote_id2`,
    `emote_id3`,
    `emote_delay1`,
    `emote_delay2`,
    `emote_delay3`
)
VALUES
(6215305, 'As much as it pains me to disappoint our oh so esteemed Lord, I do not have it on me. Anymore atleast. You see, I was at the Plump Pumpkin conversing with Colonel Driscol of Stormwind about the invasion from the Blackrock Orcs. I gained valuable new insight from his investigation, with which I finalized my report. On my way back to Ambershire however, those fiendish Blackrocks ambushed me and killed my bodyguard. The report is now in their hands; it could be on any one of them, I''m afraid. If you wish to bring Lady Prestor that scroll, you have to tear it from their dead hands first.', 'As much as it pains me to disappoint our oh so esteemed Lord, I do not have it on me. Anymore atleast. You see, I was at the Plump Pumpkin conversing with Colonel Driscol of Stormwind about the invasion from the Blackrock Orcs. I gained valuable new insight from his investigation, with which I finalized my report. On my way back to Ambershire however, those fiendish Blackrocks ambushed me and killed my bodyguard. The report is now in their hands; it could be on any one of them, I''m afraid. If you wish to bring Lady Prestor that scroll, you have to tear it from their dead hands first.', 0, 0, 0, 0, 0, 0, 0, 0, 0);

INSERT INTO `npc_text`
(
    `ID`,
    `BroadcastTextID0`,
    `Probability0`,
    `BroadcastTextID1`,
    `Probability1`,
    `BroadcastTextID2`,
    `Probability2`,
    `BroadcastTextID3`,
    `Probability3`,
    `BroadcastTextID4`,
    `Probability4`,
    `BroadcastTextID5`,
    `Probability5`,
    `BroadcastTextID6`,
    `Probability6`,
    `BroadcastTextID7`,
    `Probability7`
)
VALUES
(6215305, 6215305, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);

INSERT INTO `gossip_menu`
(
    `entry`,
    `text_id`,
    `script_id`,
    `condition_id`
)
VALUES
(6215302, 6215305, 0, 0);

-- ==============================================
-- FILE: who_will_think_of_the_children.sql
-- GENERATED: 20260906081248
-- ==============================================
INSERT INTO `conditions`
(
    `condition_entry`,
    `type`,
    `value1`,
    `value2`,
    `value3`,
    `value4`,
    `flags`
)
VALUES
(41636, 9, 41636, 1, 0, 0, 0);

INSERT INTO `broadcast_text`
(
    `entry`,
    `male_text`,
    `female_text`,
    `chat_type`,
    `sound_id`,
    `language_id`,
    `emote_id1`,
    `emote_id2`,
    `emote_id3`,
    `emote_delay1`,
    `emote_delay2`,
    `emote_delay3`
)
VALUES
(6229805, 'Take it and get out of Northwind! <Pay 20 Silver.>', 'Take it and get out of Northwind! <Pay 20 Silver.>', 0, 0, 0, 0, 0, 0, 0, 0, 0);

INSERT INTO `gossip_menu`
(
    `entry`,
    `text_id`,
    `script_id`,
    `condition_id`
)
VALUES
(6229802, 6229802, 0, 0);

UPDATE `gossip_menu_option`
SET `action_menu_id` = 6229802,
    `condition_id` = 41636
WHERE `menu_id` = 62298
  AND `id` = 0;

UPDATE `gossip_menu_option`
SET `menu_id` = 6229802,
    `action_script_id` = 6229803,
    `condition_id` = 41636
WHERE `menu_id` = 62298
  AND `id` = 1;

INSERT INTO `gossip_menu_option`
(
    `menu_id`,
    `id`,
    `option_icon`,
    `option_text`,
    `option_broadcast_text`,
    `option_id`,
    `npc_option_npcflag`,
    `action_menu_id`,
    `action_poi_id`,
    `action_script_id`,
    `box_coded`,
    `box_money`,
    `box_text`,
    `box_broadcast_text`,
    `condition_id`
)
VALUES
(6229802, 0, 0, 'Take it and get out of Northwind! <Pay 20 Silver.>', 6229805, 1, 1, 0, 0, 6229802, 0, 2000, '', 0, 41636);

INSERT INTO `gossip_scripts`
(
    `id`,
    `delay`,
    `priority`,
    `command`,
    `datalong`,
    `datalong2`,
    `datalong3`,
    `datalong4`,
    `target_param1`,
    `target_param2`,
    `target_type`,
    `data_flags`,
    `dataint`,
    `dataint2`,
    `dataint3`,
    `dataint4`,
    `x`,
    `y`,
    `z`,
    `o`,
    `condition_id`,
    `comments`
)
VALUES
(6229802, 0, 0, 93, 2000, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 41636, 'Who Will Think Of The Children - Cutpurse Warren - Take 20 Silver'),
(6229802, 0, 1, 17, 41606, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 41636, 'Who Will Think Of The Children - Cutpurse Warren - Give Crate of Donated Books'),
(6229803, 0, 0, 22, 14, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 41636, 'Who Will Think Of The Children - Cutpurse Warren - Set temporary hostile faction'),
(6229803, 0, 1, 26, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 41636, 'Who Will Think Of The Children - Cutpurse Warren - Attack player');

-- ==============================================
-- FILE: horde_gossip.sql
-- GENERATED: 20260906081248
-- ==============================================

INSERT INTO `broadcast_text`
(
    `entry`,
    `male_text`,
    `female_text`,
    `chat_type`,
    `sound_id`,
    `language_id`,
    `emote_id1`,
    `emote_id2`,
    `emote_id3`,
    `emote_delay1`,
    `emote_delay2`,
    `emote_delay3`
)
VALUES
(6251701, 'Nobody ever visits the Master and your presence here is already both disturbing and annoying. Please, I beg of you, whatever you need, make it quick.', 'Nobody ever visits the Master and your presence here is already both disturbing and annoying. Please, I beg of you, whatever you need, make it quick.', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(6227301, 'Hm? You are not Wiggles - damn ghoul ran off when I needed him most. Wiggles, come back, boy!', 'Hm? You are not Wiggles - damn ghoul ran off when I needed him most. Wiggles, come back, boy!', 0, 0, 0, 0, 0, 0, 0, 0, 0);

INSERT INTO `gossip_menu`
(
    `entry`,
    `text_id`,
    `script_id`,
    `condition_id`
)
VALUES
(62273, 6227301, 0, 0),
(62517, 6251701, 0, 0);

INSERT INTO `npc_text`
(
    `ID`,
    `BroadcastTextID0`,
    `Probability0`,
    `BroadcastTextID1`,
    `Probability1`,
    `BroadcastTextID2`,
    `Probability2`,
    `BroadcastTextID3`,
    `Probability3`,
    `BroadcastTextID4`,
    `Probability4`,
    `BroadcastTextID5`,
    `Probability5`,
    `BroadcastTextID6`,
    `Probability6`,
    `BroadcastTextID7`,
    `Probability7`
)
VALUES
(6227301, 6227301, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0),
(6251701, 6251701, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0);

UPDATE `creature_template`
SET `gossip_menu_id` = `entry`
WHERE `entry` = 62273;

UPDATE `creature_template`
SET `gossip_menu_id` = `entry`
WHERE `entry` = 62517;

INSERT INTO `migrations` (`Name`, `Hash`, `AppliedAt`)
SELECT '20260906081248_world', 'manual', NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `migrations` WHERE `Name` = '20260906081248_world');

-- ############################################################ 20260906104515_world

-- ==============================================
-- FILE: balor_missing_ally_gossips.sql
-- GENERATED: 20260906104515
-- ==============================================
DELETE FROM `gossip_menu`
WHERE `entry` IN (
    62462, 62456, 62460, 62464, 62459
    );

INSERT INTO `gossip_menu`
(
    `entry`,
    `text_id`,
    `script_id`,
    `condition_id`
)
VALUES
(62462, 6246201, 0, 0),
(62456, 6245601, 0, 0),
(62460, 6246001, 0, 0),
(62464, 6246401, 0, 0),
(62459, 6245901, 0, 0);

UPDATE `creature_template`
SET `gossip_menu_id` = `entry`
WHERE `entry` IN (
    62462, 62456, 62460, 62464, 62459
    );

INSERT INTO `migrations` (`Name`, `Hash`, `AppliedAt`)
SELECT '20260906104515_world', 'manual', NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `migrations` WHERE `Name` = '20260906104515_world');

-- ############################################################ 20260906113303_world

-- ==============================================
-- FILE: custom_skin_mappings.sql
-- GENERATED: 20260906113303
-- ==============================================

INSERT INTO `custom_character_skins`
(
    `token_id`,
    `skin_male`,
    `skin_female`
)
VALUES
(61111, 19, 18),
(61112, 1, 15),
(81256, 21, 13);

INSERT INTO `migrations` (`Name`, `Hash`, `AppliedAt`)
SELECT '20260906113303_world', 'manual', NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `migrations` WHERE `Name` = '20260906113303_world');

-- ############################################################ 20260907013549_world

-- ==============================================
-- FILE: a_hydromancers_curiosity.sql
-- GENERATED: 20260907013549
-- ==============================================
INSERT INTO `creature_questrelation`
(
    `id`,
    `quest`
)
VALUES
(60936, 41799);

INSERT INTO `creature_involvedrelation`
(
    `id`,
    `quest`
)
VALUES
(62460, 41799);

-- ==============================================
-- FILE: assessing_the_situation.sql
-- GENERATED: 20260907013549
-- ==============================================
UPDATE `quest_template`
SET `NextQuestId` = 41693
WHERE `entry` = 41692;

-- ==============================================
-- FILE: calming_the_tempest.sql
-- GENERATED: 20260907013549
-- ==============================================
INSERT INTO `creature_questrelation`
(
    `id`,
    `quest`
)
VALUES
(62460, 41711);

INSERT INTO `creature_involvedrelation`
(
    `id`,
    `quest`
)
VALUES
(62460, 41711);

INSERT INTO `conditions`
(
    `condition_entry`,
    `type`,
    `value1`,
    `value2`,
    `value3`,
    `value4`,
    `flags`
)
VALUES
(41711, 9, 41711, 1, 0, 0, 0);

INSERT INTO `broadcast_text`
(
    `entry`,
    `male_text`,
    `female_text`,
    `chat_type`,
    `sound_id`,
    `language_id`,
    `emote_id1`,
    `emote_id2`,
    `emote_id3`,
    `emote_delay1`,
    `emote_delay2`,
    `emote_delay3`
)
VALUES
(4188104, '<Place the humming crystal next to the pearl.>', '<Place the humming crystal next to the pearl.>', 0, 0, 0, 0, 0, 0, 0, 0, 0);

INSERT INTO `gossip_menu_option`
(
    `menu_id`,
    `id`,
    `option_icon`,
    `option_text`,
    `option_broadcast_text`,
    `option_id`,
    `npc_option_npcflag`,
    `action_menu_id`,
    `action_poi_id`,
    `action_script_id`,
    `box_coded`,
    `box_money`,
    `box_text`,
    `box_broadcast_text`,
    `condition_id`
)
VALUES
(41881, 1, 0, '<Place the humming crystal next to the pearl.>', 4188104, 1, 1, -1, 0, 4188104, 0, 0, '', 0, 41711);

INSERT INTO `gossip_scripts`
(
    `id`,
    `delay`,
    `priority`,
    `command`,
    `datalong`,
    `datalong2`,
    `datalong3`,
    `datalong4`,
    `target_param1`,
    `target_param2`,
    `target_type`,
    `data_flags`,
    `dataint`,
    `dataint2`,
    `dataint3`,
    `dataint4`,
    `x`,
    `y`,
    `z`,
    `o`,
    `condition_id`,
    `comments`
)
VALUES
(4188104, 0, 0, 10, 62355, 60000, 1, 100, 0, 0, 0, 0, 8, 0, 6, 1, -8304.06, 3318.95, 9.69, 2.84, 0, 'Calming the Tempest - Summon Abysstide Siren');

-- ==============================================
-- FILE: ceaseless_storms.sql
-- GENERATED: 20260907013549
-- ==============================================
INSERT INTO `conditions`
(
    `condition_entry`,
    `type`,
    `value1`,
    `value2`,
    `value3`,
    `value4`,
    `flags`
)
VALUES
(41709, 9, 41709, 1, 0, 0, 0);

DELETE FROM `creature`
WHERE `guid` = 2599165;

INSERT INTO `creature_questrelation`
(
    `id`,
    `quest`
)
VALUES
(62460, 41709);

INSERT INTO `creature_involvedrelation`
(
    `id`,
    `quest`
)
VALUES
(62460, 41709);

INSERT INTO `broadcast_text`
(
    `entry`,
    `male_text`,
    `female_text`,
    `chat_type`,
    `sound_id`,
    `language_id`,
    `emote_id1`,
    `emote_id2`,
    `emote_id3`,
    `emote_delay1`,
    `emote_delay2`,
    `emote_delay3`
)
VALUES
(4188102, '<Inspect the altar further.>', '<Inspect the altar further.>', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(4188103, '<Examining the altar, you notice that many tiny shards have been put into the open crater on the top of the pearl. Almost like a puzzle, it seems the murlocs are trying to reassemble it. You decide to pick one of the shards and bring it to Hydromancer Finnigan.>', '<Examining the altar, you notice that many tiny shards have been put into the open crater on the top of the pearl. Almost like a puzzle, it seems the murlocs are trying to reassemble it. You decide to pick one of the shards and bring it to Hydromancer Finnigan.>', 0, 0, 0, 0, 0, 0, 0, 0, 0);

INSERT INTO `gossip_menu`
(
    `entry`,
    `text_id`,
    `script_id`,
    `condition_id`
)
VALUES
(4188102, 4188102, 0, 0);

INSERT INTO `gossip_menu_option`
(
    `menu_id`,
    `id`,
    `option_icon`,
    `option_text`,
    `option_broadcast_text`,
    `option_id`,
    `npc_option_npcflag`,
    `action_menu_id`,
    `action_poi_id`,
    `action_script_id`,
    `box_coded`,
    `box_money`,
    `box_text`,
    `box_broadcast_text`,
    `condition_id`
)
VALUES
(41881, 0, 0, '<Inspect the altar further.>', 4188102, 1, 1, 4188102, 0, 4188102, 0, 0, '', 0, 41709);

INSERT INTO `gossip_scripts`
(
    `id`,
    `delay`,
    `priority`,
    `command`,
    `datalong`,
    `datalong2`,
    `datalong3`,
    `datalong4`,
    `target_param1`,
    `target_param2`,
    `target_type`,
    `data_flags`,
    `dataint`,
    `dataint2`,
    `dataint3`,
    `dataint4`,
    `x`,
    `y`,
    `z`,
    `o`,
    `condition_id`,
    `comments`
)
VALUES
(4188102, 0, 0, 17, 41773, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'Ceaseless Storms - Give Pearlescent Shard');

INSERT INTO `npc_text`
(
    `ID`,
    `BroadcastTextID0`,
    `Probability0`,
    `BroadcastTextID1`,
    `Probability1`,
    `BroadcastTextID2`,
    `Probability2`,
    `BroadcastTextID3`,
    `Probability3`,
    `BroadcastTextID4`,
    `Probability4`,
    `BroadcastTextID5`,
    `Probability5`,
    `BroadcastTextID6`,
    `Probability6`,
    `BroadcastTextID7`,
    `Probability7`
)
VALUES
(4188101, 4188101, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0),
(4188102, 4188103, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0);

-- ==============================================
-- FILE: favor_for_spare_parts.sql
-- GENERATED: 20260907013549
-- ==============================================
INSERT INTO `conditions`
(
    `condition_entry`,
    `type`,
    `value1`,
    `value2`,
    `value3`,
    `value4`,
    `flags`
)
VALUES
(41703, 9, 41703, 1, 0, 0, 0);

INSERT INTO `broadcast_text`
(
    `entry`,
    `male_text`,
    `female_text`,
    `chat_type`,
    `sound_id`,
    `language_id`,
    `emote_id1`,
    `emote_id2`,
    `emote_id3`,
    `emote_delay1`,
    `emote_delay2`,
    `emote_delay3`
)
VALUES
(249901, 'Where are these goblins?! One would think they''d cherish their precious gold above all else.', 'Where are these goblins?! One would think they''d cherish their precious gold above all else.', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(249902, 'Are you Markel Smythe? The goblins you are looking for have been stranded on the island of Balor. I''m here to get a spare zeppelin motor from you.', 'Are you Markel Smythe? The goblins you are looking for have been stranded on the island of Balor. I''m here to get a spare zeppelin motor from you.', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(249903, 'BALOR?! How did they even manage to fly over there? This is the first time I''ve ever heard of any zeppelin routing over that accursed island. Completely dumbfoundere, that''s what I am! They are lucky that I am in desparate need of their cargo. Here, take the motor and make sure they come back here in one piece - with their wares!', 'BALOR?! How did they even manage to fly over there? This is the first time I''ve ever heard of any zeppelin routing over that accursed island. Completely dumbfoundere, that''s what I am! They are lucky that I am in desparate need of their cargo. Here, take the motor and make sure they come back here in one piece - with their wares!', 0, 0, 0, 0, 0, 0, 0, 0, 0);

INSERT INTO `npc_text`
(
    `ID`,
    `BroadcastTextID0`,
    `Probability0`,
    `BroadcastTextID1`,
    `Probability1`,
    `BroadcastTextID2`,
    `Probability2`,
    `BroadcastTextID3`,
    `Probability3`,
    `BroadcastTextID4`,
    `Probability4`,
    `BroadcastTextID5`,
    `Probability5`,
    `BroadcastTextID6`,
    `Probability6`,
    `BroadcastTextID7`,
    `Probability7`
)
VALUES
(249901, 249901, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(249903, 249903, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);

INSERT INTO `gossip_menu`
(
    `entry`,
    `text_id`,
    `script_id`,
    `condition_id`
)
VALUES
(249901, 249901, 0, 0),
(249902, 249903, 0, 0);

UPDATE `creature_template`
SET `gossip_menu_id` = 249901
WHERE `entry` = 2499;

INSERT INTO `gossip_menu_option`
(
    `menu_id`,
    `id`,
    `option_icon`,
    `option_text`,
    `option_broadcast_text`,
    `option_id`,
    `npc_option_npcflag`,
    `action_menu_id`,
    `action_poi_id`,
    `action_script_id`,
    `box_coded`,
    `box_money`,
    `box_text`,
    `box_broadcast_text`,
    `condition_id`
)
VALUES
(249901, 0, 0, 'Are you Markel Smythe? The goblins you are looking for have been stranded on the island of Balor. I''m here to get a spare zeppelin motor from you.', 249902, 1, 1, 249902, 0, 249902, 0, 0, '', 0, 41703);

INSERT INTO `gossip_scripts`
(
    `id`,
    `delay`,
    `priority`,
    `command`,
    `datalong`,
    `datalong2`,
    `datalong3`,
    `datalong4`,
    `target_param1`,
    `target_param2`,
    `target_type`,
    `data_flags`,
    `dataint`,
    `dataint2`,
    `dataint3`,
    `dataint4`,
    `x`,
    `y`,
    `z`,
    `o`,
    `condition_id`,
    `comments`
)
VALUES
(249902, 0, 0, 17, 41765, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 41703, 'Favor For Spare Parts - Give Zeppelin Motor');

-- ==============================================
-- FILE: piece_of_a_bigger_picture.sql
-- GENERATED: 20260907013549
-- ==============================================
INSERT INTO `creature_questrelation`
(
    `id`,
    `quest`
)
VALUES
(62460, 41710);

INSERT INTO `creature_involvedrelation`
(
    `id`,
    `quest`
)
VALUES
(62460, 41710);

INSERT INTO `creature`
(
    `guid`,
    `id`,
    `id2`,
    `id3`,
    `id4`,
    `map`,
    `position_x`,
    `position_y`,
    `position_z`,
    `orientation`,
    `spawntimesecsmin`,
    `spawntimesecsmax`,
    `wander_distance`,
    `health_percent`,
    `mana_percent`,
    `movement_type`,
    `spawn_flags`,
    `visibility_mod`
)
VALUES
(2590174, 62562, 0, 0, 0, 0, -11433.692383, 58.15662, 42.895042, 1.5338329076766968, 300, 300, 10, 100, 100, 1, 0, 0);

INSERT INTO `creature_spells`
(
    `entry`,
    `name`,
    `spellId_1`,
    `probability_1`,
    `castTarget_1`,
    `targetParam1_1`,
    `targetParam2_1`,
    `castFlags_1`,
    `delayInitialMin_1`,
    `delayInitialMax_1`,
    `delayRepeatMin_1`,
    `delayRepeatMax_1`,
    `scriptId_1`,
    `spellId_2`,
    `probability_2`,
    `castTarget_2`,
    `targetParam1_2`,
    `targetParam2_2`,
    `castFlags_2`,
    `delayInitialMin_2`,
    `delayInitialMax_2`,
    `delayRepeatMin_2`,
    `delayRepeatMax_2`,
    `scriptId_2`,
    `spellId_3`,
    `probability_3`,
    `castTarget_3`,
    `targetParam1_3`,
    `targetParam2_3`,
    `castFlags_3`,
    `delayInitialMin_3`,
    `delayInitialMax_3`,
    `delayRepeatMin_3`,
    `delayRepeatMax_3`,
    `scriptId_3`,
    `spellId_4`,
    `probability_4`,
    `castTarget_4`,
    `targetParam1_4`,
    `targetParam2_4`,
    `castFlags_4`,
    `delayInitialMin_4`,
    `delayInitialMax_4`,
    `delayRepeatMin_4`,
    `delayRepeatMax_4`,
    `scriptId_4`,
    `spellId_5`,
    `probability_5`,
    `castTarget_5`,
    `targetParam1_5`,
    `targetParam2_5`,
    `castFlags_5`,
    `delayInitialMin_5`,
    `delayInitialMax_5`,
    `delayRepeatMin_5`,
    `delayRepeatMax_5`,
    `scriptId_5`,
    `spellId_6`,
    `probability_6`,
    `castTarget_6`,
    `targetParam1_6`,
    `targetParam2_6`,
    `castFlags_6`,
    `delayInitialMin_6`,
    `delayInitialMax_6`,
    `delayRepeatMin_6`,
    `delayRepeatMax_6`,
    `scriptId_6`,
    `spellId_7`,
    `probability_7`,
    `castTarget_7`,
    `targetParam1_7`,
    `targetParam2_7`,
    `castFlags_7`,
    `delayInitialMin_7`,
    `delayInitialMax_7`,
    `delayRepeatMin_7`,
    `delayRepeatMax_7`,
    `scriptId_7`,
    `spellId_8`,
    `probability_8`,
    `castTarget_8`,
    `targetParam1_8`,
    `targetParam2_8`,
    `castFlags_8`,
    `delayInitialMin_8`,
    `delayInitialMax_8`,
    `delayRepeatMin_8`,
    `delayRepeatMax_8`,
    `scriptId_8`
)
VALUES
(62562, 'Crystalmaw', 3635, 100, 1, 0, 0, 0, 10, 15, 18, 20, 0, 0, 100, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 1, 0, 0, 0, 0, 0, 0, 0, 0);

UPDATE `creature_template`
SET `scale` = 1.4,
    `dmg_min` = 46.131252,
    `dmg_max` = 59.760937,
    `attack_power` = 108,
    `ranged_dmg_min` = 45.877144,
    `ranged_dmg_max` = 63.081074,
    `ranged_attack_power` = 88,
    `spell_list_id` = `entry`
WHERE `entry` = 62562;


-- ==============================================
-- FILE: storm_twilight_and_hammer.sql
-- GENERATED: 20260907013549
-- ==============================================
INSERT INTO `creature_involvedrelation`
(
    `id`,
    `quest`
)
VALUES
(62466, 41837);

-- ==============================================
-- FILE: to_the_darkest_places.sql
-- GENERATED: 20260907013549
-- ==============================================
INSERT INTO `conditions`
(
    `condition_entry`,
    `type`,
    `value1`,
    `value2`,
    `value3`,
    `value4`,
    `flags`
)
VALUES
(41694, 9, 41694, 1, 0, 0, 0);

INSERT INTO `broadcast_text`
(
    `entry`,
    `male_text`,
    `female_text`,
    `chat_type`,
    `sound_id`,
    `language_id`,
    `emote_id1`,
    `emote_id2`,
    `emote_id3`,
    `emote_delay1`,
    `emote_delay2`,
    `emote_delay3`
)
VALUES
(6255703, '<His skin is dried and flaky, almost brittling away under your touch. A torn and agonized expression is carved onto his face, and his eyeless sockets send a shiver down your spine.>', '<His skin is dried and flaky, almost brittling away under your touch. A torn and agonized expression is carved onto his face, and his eyeless sockets send a shiver down your spine.>', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(6255803, '<The skin of this corpse feels slimy, almost fluid, as if it is about to dissolve on its own. She has been beyond saving for a long time.>', '<The skin of this corpse feels slimy, almost fluid, as if it is about to dissolve on its own. She has been beyond saving for a long time.>', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(6255903, '<You are not sure what exactly it is that you''re facing, but judging from the monsters you en encountered so far, it must be something horrifying. Wading through the goop with your hand, your suspicion proves to be correct: in your hand an SI:7 badge. Name: Elroy.>', '<You are not sure what exactly it is that you''re facing, but judging from the monsters you en encountered so far, it must be something horrifying. Wading through the goop with your hand, your suspicion proves to be correct: in your hand an SI:7 badge. Name: Elroy.>', 0, 0, 0, 0, 0, 0, 0, 0, 0);

INSERT INTO `npc_text`
(
    `ID`,
    `BroadcastTextID0`,
    `Probability0`,
    `BroadcastTextID1`,
    `Probability1`,
    `BroadcastTextID2`,
    `Probability2`,
    `BroadcastTextID3`,
    `Probability3`,
    `BroadcastTextID4`,
    `Probability4`,
    `BroadcastTextID5`,
    `Probability5`,
    `BroadcastTextID6`,
    `Probability6`,
    `BroadcastTextID7`,
    `Probability7`
)
VALUES
(6255703, 6255703, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(6255803, 6255803, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(6255903, 6255903, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);

INSERT INTO `gossip_menu`
(
    `entry`,
    `text_id`,
    `script_id`,
    `condition_id`
)
VALUES
(6255702, 6255703, 0, 0),
(6255802, 6255803, 0, 0),
(6255902, 6255903, 0, 0);

UPDATE `gossip_menu_option`
SET `action_menu_id` = 6255702,
    `action_script_id` = 6255702,
    `condition_id` = 41694
WHERE `menu_id` = 62557
AND `id` = 0;

UPDATE `gossip_menu_option`
SET `action_menu_id` = 6255802,
    `action_script_id` = 6255802,
    `condition_id` = 41694
WHERE `menu_id` = 62558
AND `id` = 0;

UPDATE `gossip_menu_option`
SET `action_menu_id` = 6255902,
    `action_script_id` = 6255902,
    `condition_id` = 41694
WHERE `menu_id` = 62559
AND `id` = 0;

INSERT INTO `gossip_scripts`
(
    `id`,
    `delay`,
    `priority`,
    `command`,
    `datalong`,
    `datalong2`,
    `datalong3`,
    `datalong4`,
    `target_param1`,
    `target_param2`,
    `target_type`,
    `data_flags`,
    `dataint`,
    `dataint2`,
    `dataint3`,
    `dataint4`,
    `x`,
    `y`,
    `z`,
    `o`,
    `condition_id`,
    `comments`
)
VALUES
(6255702, 0, 0, 8, 60072, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'To The Darkest Places - Agent Flynn found'),
(6255802, 0, 0, 8, 60073, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'To The Darkest Places - Agent Cherys found'),
(6255902, 0, 0, 8, 60074, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'To The Darkest Places - Agent Elroy found');

INSERT INTO `migrations` (`Name`, `Hash`, `AppliedAt`)
SELECT '20260907013549_world', 'manual', NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `migrations` WHERE `Name` = '20260907013549_world');

-- ############################################################ 20260907165343_world

-- ==============================================
-- FILE: spell_chain.sql
-- GENERATED: 20260907165343
-- ==============================================

DELETE FROM `spell_chain` WHERE `spell_id` IN (
    13165, 14318, 14319, 14320, 14321, 14322, 25296, 20043, 20190, 51346,
    51565, 51566, 51433, 51434, 51435, 52714, 52715, 52716, 52717, 24858,
    45734, 45599, 45560, 45960, 45910, 45911
    );

UPDATE `spell_chain`
SET `first_spell` = 3035
WHERE `spell_id` = 3035
AND `first_spell` = 0;

UPDATE `spell_chain`
SET `req_spell` = 0
WHERE `spell_id` = 16689
AND `req_spell` = 339;

-- ==============================================
-- FILE: spell_proc_event.sql
-- GENERATED: 20260907165343
-- ==============================================
DELETE FROM `spell_proc_event`
WHERE `entry` IN (
    15335, 15336, 15337, 15338
    );

INSERT INTO `migrations` (`Name`, `Hash`, `AppliedAt`)
SELECT '20260907165343_world', 'manual', NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `migrations` WHERE `Name` = '20260907165343_world');

-- ############################################################ 20260908193409_world

-- ==============================================
-- FILE: dragonfire_bombs.sql
-- GENERATED: 20260908193409
-- ==============================================
UPDATE `quest_template`
SET `SrcItemCount` = 3
WHERE `entry` = 41806;

-- ==============================================
-- FILE: expelling_evil.sql
-- GENERATED: 20260908193409
-- ==============================================
UPDATE `creature_template`
SET `scale` = 2.5,
    `spell_list_id` = `entry`
WHERE `entry` = 62585;

INSERT INTO `conditions`
(
    `condition_entry`,
    `type`,
    `value1`,
    `value2`,
    `value3`,
    `value4`,
    `flags`
)
VALUES
(41742, 9, 41742, 1, 0, 0, 0);

INSERT INTO `broadcast_text`
(
    `entry`,
    `male_text`,
    `female_text`,
    `chat_type`,
    `sound_id`,
    `language_id`,
    `emote_id1`,
    `emote_id2`,
    `emote_id3`,
    `emote_delay1`,
    `emote_delay2`,
    `emote_delay3`
)
VALUES
(4190401, '<The fire burns ominously.>', '<The fire burns ominously.>', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(4190402, 'Throw the Dust of Conjuration on the fire.', 'Throw the Dust of Conjuration on the fire.', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(4190403, 'The Flame of Dagoth swirls with magic.', 'The Flame of Dagoth swirls with magic.', 2, 0, 0, 0, 0, 0, 0, 0, 0);

INSERT INTO `npc_text`
(
    `ID`,
    `BroadcastTextID0`,
    `Probability0`,
    `BroadcastTextID1`,
    `Probability1`,
    `BroadcastTextID2`,
    `Probability2`,
    `BroadcastTextID3`,
    `Probability3`,
    `BroadcastTextID4`,
    `Probability4`,
    `BroadcastTextID5`,
    `Probability5`,
    `BroadcastTextID6`,
    `Probability6`,
    `BroadcastTextID7`,
    `Probability7`
)
VALUES
(4190401, 4190401, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0);

INSERT INTO `gossip_menu`
(
    `entry`,
    `text_id`,
    `script_id`,
    `condition_id`
)
VALUES
(41904, 4190401, 0, 0);

INSERT INTO `gossip_menu_option`
(
    `menu_id`,
    `id`,
    `option_icon`,
    `option_text`,
    `option_broadcast_text`,
    `option_id`,
    `npc_option_npcflag`,
    `action_menu_id`,
    `action_poi_id`,
    `action_script_id`,
    `box_coded`,
    `box_money`,
    `box_text`,
    `box_broadcast_text`,
    `condition_id`
)
VALUES
(41904, 0, 0, 'Throw the Dust of Conjuration on the fire.', 4190402, 1, 1, -1, 0, 4190402, 0, 0, '', 0, 41742);

INSERT INTO `gossip_scripts`
(
    `id`,
    `delay`,
    `priority`,
    `command`,
    `datalong`,
    `datalong2`,
    `datalong3`,
    `datalong4`,
    `target_param1`,
    `target_param2`,
    `target_type`,
    `data_flags`,
    `dataint`,
    `dataint2`,
    `dataint3`,
    `dataint4`,
    `x`,
    `y`,
    `z`,
    `o`,
    `condition_id`,
    `comments`
)
VALUES
(4190402, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4190403, 0, 0, 0, 0, 0, 0, 0, 0, 'Expelling Evil - Flame of Dagnoth Emote'),
(4190402, 3, 0, 10, 62585, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7, -5902.099121, -4878.276367, 228.351318, 0, 0, 'Expelling Evil - Summon Flame of Dagnoth');

INSERT INTO `creature_spells`
(
    `entry`,
    `name`,
    `spellId_1`,
    `probability_1`,
    `castTarget_1`,
    `targetParam1_1`,
    `targetParam2_1`,
    `castFlags_1`,
    `delayInitialMin_1`,
    `delayInitialMax_1`,
    `delayRepeatMin_1`,
    `delayRepeatMax_1`,
    `scriptId_1`,
    `spellId_2`,
    `probability_2`,
    `castTarget_2`,
    `targetParam1_2`,
    `targetParam2_2`,
    `castFlags_2`,
    `delayInitialMin_2`,
    `delayInitialMax_2`,
    `delayRepeatMin_2`,
    `delayRepeatMax_2`,
    `scriptId_2`
)
VALUES
(62585, 'Flame of Dagnoth', 14145, 100, 1, 0, 0, 0, 0, 0, 10, 12, 0, 16046, 100, 1, 0, 0, 0, 3, 3, 15, 15, 0);

-- ==============================================
-- FILE: i_am_become_death.sql
-- GENERATED: 20260908193409
-- ==============================================
UPDATE `gameobject_template`
SET `flags` = 4
WHERE `entry` = 2020229;

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
(5025863, 2020229, 0, -14616.900390625, 339.44000244140625, 2.6649699211120605, 0.08519410341978073, 0, 0, 0.0425841708, 0.999092883, 300, 300, 100, 1, 0, 0);
-- ==============================================
-- FILE: rebuilding_the_relic.sql
-- GENERATED: 20260908193409
-- ==============================================
INSERT INTO `creature_loot_template`
(
    entry,
    item,
    ChanceOrQuestChance,
    groupid,
    mincountOrRef,
    maxcount,
    condition_id
)
VALUES
(4857, 41800, -100, 0, 1, 1, 0);


-- ==============================================
-- FILE: the_chromatic_servo_motor.sql
-- GENERATED: 20260908193409
-- ==============================================
UPDATE `creature_template`
SET `gossip_menu_id` = 6256901
WHERE `entry` = 62569;

INSERT INTO `creature_questrelation`
(
    `id`,
    `quest`
)
VALUES
(62569, 41894);

INSERT INTO `broadcast_text`
(
    `entry`,
    `male_text`,
    `female_text`,
    `chat_type`,
    `sound_id`,
    `language_id`,
    `emote_id1`,
    `emote_id2`,
    `emote_id3`,
    `emote_delay1`,
    `emote_delay2`,
    `emote_delay3`
)
VALUES
(6256901, 'Complicated schematics often require complicated materials. Sometimes more progress can be made by sticking to more reliable, and less complex construction. Unless you''re trying to make something truly groundbreaking I wouldn''t waste time over-engineering a gizmo.', 'Complicated schematics often require complicated materials. Sometimes more progress can be made by sticking to more reliable, and less complex construction. Unless you''re trying to make something truly groundbreaking I wouldn''t waste time over-engineering a gizmo.', 0, 0, 0, 0, 0, 0, 0, 0, 0);

INSERT INTO `npc_text`
(
    `ID`,
    `BroadcastTextID0`,
    `Probability0`,
    `BroadcastTextID1`,
    `Probability1`,
    `BroadcastTextID2`,
    `Probability2`,
    `BroadcastTextID3`,
    `Probability3`,
    `BroadcastTextID4`,
    `Probability4`,
    `BroadcastTextID5`,
    `Probability5`,
    `BroadcastTextID6`,
    `Probability6`,
    `BroadcastTextID7`,
    `Probability7`
)
VALUES
(6256901, 6256901, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0);

INSERT INTO `gossip_menu`
(
    `entry`,
    `text_id`,
    `script_id`,
    `condition_id`
)
VALUES
(6256901, 6256901, 0, 0);

INSERT INTO `creature_involvedrelation`
(
    `id`,
    `quest`
)
VALUES
(62569, 41894);

-- ==============================================
-- FILE: the_ritual_of_uthokk.sql
-- GENERATED: 20260908193409
-- ==============================================
UPDATE `quest_template`
SET `StartScript` = 41731
WHERE `entry` = 41731;

UPDATE `creature_template`
SET `gossip_menu_id` = 6243201
WHERE `entry` = 62432;

INSERT INTO `broadcast_text`
(
    `entry`,
    `male_text`,
    `female_text`,
    `chat_type`,
    `sound_id`,
    `language_id`,
    `emote_id1`,
    `emote_id2`,
    `emote_id3`,
    `emote_delay1`,
    `emote_delay2`,
    `emote_delay3`
)
VALUES
(6243201, 'Can you feel the power here, it drifts upon the air, waiting to be seized.', 'Can you feel the power here, it drifts upon the air, waiting to be seized.', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(6243202, 'Far Seer Mothand begins the ritual', 'Far Seer Mothand begins the ritual', 2, 0, 0, 0, 0, 0, 0, 0, 0),
(6243203, 'I can feel the power flowing through my veins!', 'I can feel the power flowing through my veins!', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(6243204, 'It is complete! The power of the Uth''okk is mine! Behold the energy flowing through my veins!', 'It is complete! The power of the Uth''okk is mine! Behold the energy flowing through my veins!', 0, 0, 0, 0, 0, 0, 0, 0, 0);

INSERT INTO `npc_text`
(
    `ID`,
    `BroadcastTextID0`,
    `Probability0`,
    `BroadcastTextID1`,
    `Probability1`,
    `BroadcastTextID2`,
    `Probability2`,
    `BroadcastTextID3`,
    `Probability3`,
    `BroadcastTextID4`,
    `Probability4`,
    `BroadcastTextID5`,
    `Probability5`,
    `BroadcastTextID6`,
    `Probability6`,
    `BroadcastTextID7`,
    `Probability7`
)
VALUES
(6243201, 6243201, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0);

INSERT INTO `gossip_menu`
(
    `entry`,
    `text_id`,
    `script_id`,
    `condition_id`
)
VALUES
(6243201, 6243201, 0, 0);

INSERT INTO `quest_start_scripts`
(
    `id`,
    `delay`,
    `priority`,
    `command`,
    `datalong`,
    `datalong2`,
    `datalong3`,
    `datalong4`,
    `target_param1`,
    `target_param2`,
    `target_type`,
    `data_flags`,
    `dataint`,
    `dataint2`,
    `dataint3`,
    `dataint4`,
    `x`,
    `y`,
    `z`,
    `o`,
    `condition_id`,
    `comments`
)
VALUES
(41731, 0, 2, 4, 147, 3, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'The Ritual of Uth''okk - Far Seer Mothang - Remove NPC Flags'),
(41731, 0, 1, 15, 13236, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'The Ritual of Uth''okk - Far Seer Mothang - Cast Nature Channeling'),
(41731, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6243202, 0, 0, 0, 0, 0, 0, 0, 0, 'The Ritual of Uth''okk - Far Seer Mothang - Begins Ritual Emote'),
(41731, 8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6243203, 0, 0, 0, 0, 0, 0, 0, 0, 'The Ritual of Uth''okk - Far Seer Mothang - Say Power Flowing'),
(41731, 18, 0, 5, 0, 13236, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'The Ritual of Uth''okk - Far Seer Mothang - Stop Nature Channeling'),
(41731, 18, 1, 15, 51206, 0, 0, 0, 0, 0, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'The Ritual of Uth''okk - Far Seer Mothang - Cast Enrage'),
(41731, 18, 2, 1, 15, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'The Ritual of Uth''okk - Far Seer Mothang - Emote Roar'),
(41731, 19, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6243204, 0, 0, 0, 0, 0, 0, 0, 0, 'The Ritual of Uth''okk - Far Seer Mothang - Say Ritual Complete'),
(41731, 19, 0, 8, 60079, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'The Ritual of Uth''okk - Give Kill Credit'),
(41731, 20, 1, 1, 11, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'The Ritual of Uth''okk - Far Seer Mothang - Emote Laugh'),
(41731, 20, 0, 4, 147, 3, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'The Ritual of Uth''okk - Far Seer Mothang - Add NPC Flags');

-- ==============================================
-- FILE: the_skardyn.sql
-- GENERATED: 20260908193409
-- ==============================================
UPDATE `creature_template`
SET `gossip_menu_id` = 6242101
WHERE `entry` = 62421;

DELETE FROM `conditions`
WHERE `condition_entry` = 41803;

DELETE FROM `gossip_scripts`
WHERE `id` = 6242104;

DELETE FROM `gossip_menu_option`
WHERE `menu_id` IN (6242101, 6242102, 6242103, 6242104);

DELETE FROM `gossip_menu`
WHERE `entry` IN (6242101, 6242102, 6242103, 6242104, 6242105);

DELETE FROM `npc_text`
WHERE `ID` IN (6242101, 6242103, 6242104, 6242105, 6242106);

DELETE FROM `broadcast_text`
WHERE `entry` IN (6242101, 6242102, 6242103, 6242104, 6242105, 6242106, 6242109);

INSERT INTO `conditions`
(
    `condition_entry`,
    `type`,
    `value1`,
    `value2`,
    `value3`,
    `value4`,
    `flags`
)
VALUES
(41803, 9, 41803, 1, 0, 0, 0);

INSERT INTO `broadcast_text`
(
    `entry`,
    `male_text`,
    `female_text`,
    `chat_type`,
    `sound_id`,
    `language_id`,
    `emote_id1`,
    `emote_id2`,
    `emote_id3`,
    `emote_delay1`,
    `emote_delay2`,
    `emote_delay3`
)
VALUES
(6242101, 'A mortal? Here, in Grim Hollow?', 'A mortal? Here, in Grim Hollow?', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(6242102, 'Tell me about the Skardyn.', 'Tell me about the Skardyn.', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(6242103, 'After the civil war between the Bronzebeards, Dark Irons and Wildhammer clan, Thane Khardros of the Wildhammers led his people northward, passing through the barrier gates of Dun Algaz to forge a new kingdom within the mighty mountain of Grim Batol.$B$BBitterness from the war festered like a wound. From his city of Thaurissan in the Redridge Mountains, Sorcerer-Thane Thaurissan of the Dark Irons plotted his vengeance. He unleashed a two-pronged assault against the Bronzebeards and the Wildhammers, seeking to claim all of Khaz Modan. While he marched against Ironforge, his sorceress wife, Modgud, led a separate force to assail the Wildhammers at Grim Batol.', 'After the civil war between the Bronzebeards, Dark Irons and Wildhammer clan, Thane Khardros of the Wildhammers led his people northward, passing through the barrier gates of Dun Algaz to forge a new kingdom within the mighty mountain of Grim Batol.$B$BBitterness from the war festered like a wound. From his city of Thaurissan in the Redridge Mountains, Sorcerer-Thane Thaurissan of the Dark Irons plotted his vengeance. He unleashed a two-pronged assault against the Bronzebeards and the Wildhammers, seeking to claim all of Khaz Modan. While he marched against Ironforge, his sorceress wife, Modgud, led a separate force to assail the Wildhammers at Grim Batol.', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(6242104, 'Thaurissan''s assault on Ironforge failed, and his forces were driven back. Yet, Modgud, wielding dark sorcery, had greater success. Her war golems battered the gates of Grim Batol, and she summoned living shadows from the depths of the earth to terrorize the dwarves within. The Wildhammers fought valiantly, their spirits unbroken despite the horrors they faced. Thane Khardros, with unyielding resolve, led his warriors into the heart of the battle. It was there, amidst the chaos, that he confronted Modgud herself. With one mighty swing of his hammer, Khardros struck her down, ending her dark reign.', 'Thaurissan''s assault on Ironforge failed, and his forces were driven back. Yet, Modgud, wielding dark sorcery, had greater success. Her war golems battered the gates of Grim Batol, and she summoned living shadows from the depths of the earth to terrorize the dwarves within. The Wildhammers fought valiantly, their spirits unbroken despite the horrors they faced. Thane Khardros, with unyielding resolve, led his warriors into the heart of the battle. It was there, amidst the chaos, that he confronted Modgud herself. With one mighty swing of his hammer, Khardros struck her down, ending her dark reign.', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(6242105, 'The Wildhammers drove the retreating Dark Irons from their halls, but not all the invaders escaped. Those who delved too deep into Grim Batol''s cursed depths were twisted by Modgud''s vile magic, their bodies and minds corrupted until they became the skardyn - creatures of shadow and malice, far removed from their former selves.$B$BThe curse that befell Grim Batol rendered it uninhabitable, its halls steeped in a darkness so profound that even the Wildhammers could not reclaim their home. The skardyn, however, thrived within this taint, claiming the deepest, darkest reaches of the fortress as their domain. Few knew of their existence, for the Red Dragonflight sealed Grim Batol after Modgud''s fall. For centuries, its darkness was contained - until the Second War, when the Dragonmaw clan made the fortress their stronghold. Even then, the orcs dared only to occupy the upper levels, unwilling to venture into the depths where shadows held dominion.', 'The Wildhammers drove the retreating Dark Irons from their halls, but not all the invaders escaped. Those who delved too deep into Grim Batol''s cursed depths were twisted by Modgud''s vile magic, their bodies and minds corrupted until they became the skardyn - creatures of shadow and malice, far removed from their former selves.$B$BThe curse that befell Grim Batol rendered it uninhabitable, its halls steeped in a darkness so profound that even the Wildhammers could not reclaim their home. The skardyn, however, thrived within this taint, claiming the deepest, darkest reaches of the fortress as their domain. Few knew of their existence, for the Red Dragonflight sealed Grim Batol after Modgud''s fall. For centuries, its darkness was contained - until the Second War, when the Dragonmaw clan made the fortress their stronghold. Even then, the orcs dared only to occupy the upper levels, unwilling to venture into the depths where shadows held dominion.', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(6242106, 'Now, I fear the darkness has at last seeped into the hearts of the Red Dragonflight defenders who stood watch over Grim Batol. The corruption festering there may have broken their resolve, making it possible for the skardyn to emerge from their realm and spread their malevolence into the world once more.$B$BAs for the powers that cursed Grim Batol and twisted the skardyn into what they have become - this knowledge is lost, even to me. Whatever forces are at work here are older and far mightier than we can comprehend. Take caution, mortal. The darkness within Grim Batol is no ordinary shadow - it is ancient, insidious, and ever hungry.', 'Now, I fear the darkness has at last seeped into the hearts of the Red Dragonflight defenders who stood watch over Grim Batol. The corruption festering there may have broken their resolve, making it possible for the skardyn to emerge from their realm and spread their malevolence into the world once more.$B$BAs for the powers that cursed Grim Batol and twisted the skardyn into what they have become - this knowledge is lost, even to me. Whatever forces are at work here are older and far mightier than we can comprehend. Take caution, mortal. The darkness within Grim Batol is no ordinary shadow - it is ancient, insidious, and ever hungry.', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(6242109, '<Continue>', '<Continue>', 0, 0, 0, 0, 0, 0, 0, 0, 0);

INSERT INTO `npc_text`
(
    `ID`,
    `BroadcastTextID0`,
    `Probability0`,
    `BroadcastTextID1`,
    `Probability1`,
    `BroadcastTextID2`,
    `Probability2`,
    `BroadcastTextID3`,
    `Probability3`,
    `BroadcastTextID4`,
    `Probability4`,
    `BroadcastTextID5`,
    `Probability5`,
    `BroadcastTextID6`,
    `Probability6`,
    `BroadcastTextID7`,
    `Probability7`
)
VALUES
(6242101, 6242101, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0),
(6242103, 6242103, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0),
(6242104, 6242104, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0),
(6242105, 6242105, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0),
(6242106, 6242106, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0);

INSERT INTO `gossip_menu`
(
    `entry`,
    `text_id`,
    `script_id`,
    `condition_id`
)
VALUES
(6242101, 6242101, 0, 0),
(6242102, 6242103, 0, 0),
(6242103, 6242104, 0, 0),
(6242104, 6242105, 0, 0),
(6242105, 6242106, 0, 0);

INSERT INTO `gossip_menu_option`
(
    `menu_id`,
    `id`,
    `option_icon`,
    `option_text`,
    `option_broadcast_text`,
    `option_id`,
    `npc_option_npcflag`,
    `action_menu_id`,
    `action_poi_id`,
    `action_script_id`,
    `box_coded`,
    `box_money`,
    `box_text`,
    `box_broadcast_text`,
    `condition_id`
)
VALUES
(6242101, 0, 0, 'Tell me about the Skardyn.', 6242102, 1, 1, 6242102, 0, 0, 0, 0, '', 0, 41803),
(6242102, 0, 0, '<Continue>', 6242109, 1, 1, 6242103, 0, 0, 0, 0, '', 0, 0),
(6242103, 0, 0, '<Continue>', 6242109, 1, 1, 6242104, 0, 0, 0, 0, '', 0, 0),
(6242104, 0, 0, '<Continue>', 6242109, 1, 1, 6242105, 0, 6242104, 0, 0, '', 0, 0);

INSERT INTO `gossip_scripts`
(
    `id`,
    `delay`,
    `priority`,
    `command`,
    `datalong`,
    `datalong2`,
    `datalong3`,
    `datalong4`,
    `target_param1`,
    `target_param2`,
    `target_type`,
    `data_flags`,
    `dataint`,
    `dataint2`,
    `dataint3`,
    `dataint4`,
    `x`,
    `y`,
    `z`,
    `o`,
    `condition_id`,
    `comments`
)
VALUES
(6242104, 0, 0, 8, 60081, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 41803, 'The Skardyn - Listen to Sarthyss');

-- ==============================================
-- FILE: to_cure_the_whithered.sql
-- GENERATED: 20260908193409
-- ==============================================
UPDATE `quest_template`
SET `SpecialFlags` = `SpecialFlags` | 2
WHERE `entry` = 41848;

INSERT INTO `areatrigger_involvedrelation`
(
    `id`,
    `quest`
)
VALUES
(5601, 41848);
-- ==============================================
-- FILE: tomb_of_ancestors.sql
-- GENERATED: 20260908193409
-- ==============================================
UPDATE quest_template
SET SpecialFlags = SpecialFlags | 2
WHERE entry = 41802;

INSERT INTO areatrigger_involvedrelation
(
    id,
    quest
)
VALUES
(700, 41802);

INSERT INTO `migrations` (`Name`, `Hash`, `AppliedAt`)
SELECT '20260908193409_world', 'manual', NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `migrations` WHERE `Name` = '20260908193409_world');

-- ############################################################ 20260910042434_world

-- ==============================================
-- FILE: creature_template_update_hateforge.sql
-- GENERATED: 20260910042434
-- ==============================================
UPDATE `creature_template`
SET `dmg_min` = 1.9,
    `dmg_max` = 1.9,
    `attack_power` = 24,
    `ranged_dmg_min` = 1.3376,
    `ranged_dmg_max` = 1.8392,
    `ranged_attack_power` = 20
WHERE `entry` = 10116;

UPDATE `creature_template`
SET `dmg_min` = 104.542084,
    `dmg_max` = 134.581802,
    `attack_power` = 196,
    `ranged_dmg_min` = 72.05352,
    `ranged_dmg_max` = 99.073586,
    `ranged_attack_power` = 138
WHERE `entry` = 60712;

UPDATE `creature_template`
SET `scale` = 1,
    `dmg_min` = 315.013855,
    `dmg_max` = 406.234253,
    `attack_power` = 214,
    `ranged_dmg_min` = 62.796436,
    `ranged_dmg_max` = 86.345108,
    `ranged_attack_power` = 150
WHERE `entry` = 60715;

UPDATE `creature_template`
SET `scale` = 1,
    `dmg_min` = 548.538818,
    `dmg_max` = 609.352356,
    `attack_power` = 214,
    `ranged_dmg_min` = 62.796436,
    `ranged_dmg_max` = 86.345108,
    `ranged_attack_power` = 150
WHERE `entry` = 60717;

UPDATE `creature_template`
SET `scale` = 1,
    `dmg_min` = 350.815399,
    `dmg_max` = 364.122589,
    `attack_power` = 210,
    `ranged_dmg_min` = 62.468807,
    `ranged_dmg_max` = 85.894615,
    `ranged_attack_power` = 148
WHERE `entry` = 60718;

UPDATE `creature_template`
SET `scale` = 1,
    `dmg_min` = 423.398346,
    `dmg_max` = 454.85083,
    `attack_power` = 210,
    `ranged_dmg_min` = 62.468807,
    `ranged_dmg_max` = 85.894615,
    `ranged_attack_power` = 148
WHERE `entry` = 60719;

UPDATE `creature_template`
SET `scale` = 1,
    `dmg_min` = 391.208221,
    `dmg_max` = 421.301147,
    `attack_power` = 210,
    `ranged_dmg_min` = 77.014084,
    `ranged_dmg_max` = 105.894371,
    `ranged_attack_power` = 148
WHERE `entry` = 60720;

UPDATE `creature_template`
SET `scale` = 1,
    `dmg_min` = 434.361877,
    `dmg_max` = 467.774475,
    `attack_power` = 200,
    `ranged_dmg_min` = 61.158272,
    `ranged_dmg_max` = 84.092628,
    `ranged_attack_power` = 140
WHERE `entry` = 60721;

UPDATE `creature_template`
SET `scale` = 1,
    `dmg_min` = 492.936798,
    `dmg_max` = 636.511536,
    `attack_power` = 218,
    `ranged_dmg_min` = 80.986748,
    `ranged_dmg_max` = 111.356781,
    `ranged_attack_power` = 154
WHERE `entry` = 60722;

UPDATE `creature_template`
SET `scale` = 1,
    `dmg_min` = 397.421326,
    `dmg_max` = 427.992157,
    `attack_power` = 218,
    `ranged_dmg_min` = 63.451702,
    `ranged_dmg_max` = 87.246094,
    `ranged_attack_power` = 154
WHERE `entry` = 60723;

UPDATE `creature_template`
SET `health_max` = 8705,
    `scale` = 1,
    `dmg_min` = 397.421326,
    `dmg_max` = 427.992157,
    `attack_power` = 218,
    `ranged_dmg_min` = 80.986748,
    `ranged_dmg_max` = 111.356781,
    `ranged_attack_power` = 154
WHERE `entry` = 60724;

UPDATE `creature_template`
SET `scale` = 1,
    `dmg_min` = 339.241943,
    `dmg_max` = 365.338501,
    `attack_power` = 224,
    `ranged_dmg_min` = 81.823105,
    `ranged_dmg_max` = 112.506775,
    `ranged_attack_power` = 158
WHERE `entry` = 60725;

UPDATE `creature_template`
SET `scale` = 1,
    `dmg_min` = 393.453156,
    `dmg_max` = 423.718384,
    `attack_power` = 210,
    `ranged_dmg_min` = 76.38681,
    `ranged_dmg_max` = 105.031868,
    `ranged_attack_power` = 132
WHERE `entry` = 60726;

UPDATE `creature_template`
SET `dmg_min` = 795.089294,
    `dmg_max` = 1021.914185,
    `attack_power` = 228,
    `ranged_dmg_min` = 84.475464,
    `ranged_dmg_max` = 116.153755,
    `ranged_attack_power` = 162
WHERE `entry` = 60734;

UPDATE `creature_template`
SET `scale` = 1,
    `dmg_min` = 614.052979,
    `dmg_max` = 795.151367,
    `attack_power` = 224,
    `ranged_dmg_min` = 83.620735,
    `ranged_dmg_max` = 114.978508,
    `ranged_attack_power` = 158
WHERE `entry` = 60735;

UPDATE `creature_template`
SET `scale` = 1,
    `dmg_min` = 610.456055,
    `dmg_max` = 790.354553,
    `attack_power` = 224,
    `ranged_dmg_min` = 83.620735,
    `ranged_dmg_max` = 114.978508,
    `ranged_attack_power` = 158
WHERE `entry` = 60736;

UPDATE `creature_template`
SET `scale` = 1,
    `dmg_min` = 997.057312,
    `dmg_max` = 1363.170898,
    `attack_power` = 224,
    `unit_class` = 2,
    `ranged_dmg_min` = 331.967987,
    `ranged_dmg_max` = 456.455994,
    `ranged_attack_power` = 140
WHERE `entry` = 60737;

UPDATE `creature_template`
SET `dmg_min` = 668.949707,
    `dmg_max` = 790.576904,
    `attack_power` = 214,
    `ranged_dmg_min` = 62.796436,
    `ranged_dmg_max` = 86.345108,
    `ranged_attack_power` = 150
WHERE `entry` = 60829;

INSERT INTO `migrations` (`Name`, `Hash`, `AppliedAt`)
SELECT '20260910042434_world', 'manual', NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `migrations` WHERE `Name` = '20260910042434_world');

-- ############################################################ 20260910103417_world

-- ==============================================
-- FILE: creature_kara10.sql
-- GENERATED: 20260910103417
-- ==============================================
DELETE FROM `creature`
WHERE `guid` = 2574705;

INSERT INTO `creature`
(
    `guid`,
    `id`,
    `id2`,
    `id3`,
    `id4`,
    `map`,
    `position_x`,
    `position_y`,
    `position_z`,
    `orientation`,
    `spawntimesecsmin`,
    `spawntimesecsmax`,
    `wander_distance`,
    `health_percent`,
    `mana_percent`,
    `movement_type`,
    `spawn_flags`,
    `visibility_mod`
)
VALUES
(2574705, 61225, 0, 0, 0, 532, -10891.299805, -1751.089966, 90.476898, 4.595970153808594, 86400, 86400, 0, 100, 100, 0, 0, 0);

-- ==============================================
-- FILE: creature_template_update_kara10.sql
-- GENERATED: 20260910103417
-- ==============================================
UPDATE `creature_template`
SET `dmg_min` = 1127.3706,
    `dmg_max` = 1447.9397,
    `attack_power` = 252,
    `ranged_dmg_min` = 152.2899,
    `ranged_dmg_max` = 209.3985,
    `ranged_attack_power` = 180
WHERE `entry` = 14261;

UPDATE `creature_template`
SET `scale` = 0.25,
    `dmg_min` = 10.45,
    `dmg_max` = 10.45,
    `attack_power` = 24,
    `ranged_attack_time` = 2200,
    `ranged_dmg_min` = 0.76,
    `ranged_dmg_max` = 0.76,
    `ranged_attack_power` = 20
WHERE `entry` = 40026;

UPDATE `creature_template`
SET `dmg_min` = 1158.0902,
    `dmg_max` = 1511.0226,
    `attack_power` = 268,
    `base_attack_time` = 1428,
    `ranged_dmg_min` = 259.3992,
    `ranged_dmg_max` = 368.9918,
    `ranged_attack_power` = 191
WHERE `entry` = 61191;

UPDATE `creature_template`
SET `dmg_min` = 776.5261,
    `dmg_max` = 1027.0493,
    `attack_power` = 246,
    `ranged_dmg_min` = 236.7807,
    `ranged_dmg_max` = 336.8173,
    `ranged_attack_power` = 154
WHERE `entry` = 61192;

UPDATE `creature_template`
SET `dmg_min` = 549.9162,
    `dmg_max` = 752.1057,
    `attack_power` = 262,
    `ranged_dmg_min` = 256.3427,
    `ranged_dmg_max` = 364.6439,
    `ranged_attack_power` = 186
WHERE `entry` = 61193;

UPDATE `creature_template`
SET `dmg_min` = 783.3620,
    `dmg_max` = 1020.7148,
    `attack_power` = 262,
    `ranged_dmg_min` = 256.3427,
    `ranged_dmg_max` = 364.6439,
    `ranged_attack_power` = 186
WHERE `entry` = 61194;

UPDATE `creature_template`
SET `dmg_min` = 750.2253,
    `dmg_max` = 992.8829,
    `attack_power` = 244,
    `ranged_dmg_min` = 198.9476,
    `ranged_dmg_max` = 277.5209,
    `ranged_attack_power` = 152
WHERE `entry` = 61195;

UPDATE `creature_template`
SET `dmg_min` = 750.2253,
    `dmg_max` = 992.8829,
    `attack_power` = 244,
    `ranged_dmg_min` = 198.9476,
    `ranged_dmg_max` = 277.5209,
    `ranged_attack_power` = 152
WHERE `entry` = 61196;

UPDATE `creature_template`
SET `dmg_min` = 750.2253,
    `dmg_max` = 992.8829,
    `attack_power` = 244,
    `ranged_dmg_min` = 198.9476,
    `ranged_dmg_max` = 277.5209,
    `ranged_attack_power` = 152
WHERE `entry` = 61197;

UPDATE `creature_template`
SET `dmg_min` = 870.6935,
    `dmg_max` = 1151.5972,
    `attack_power` = 258,
    `ranged_attack_power` = 182
WHERE `entry` = 61198;

UPDATE `creature_template`
SET `dmg_min` = 813.8892,
    `dmg_max` = 1076.4965,
    `attack_power` = 246,
    `ranged_attack_power` = 154
WHERE `entry` = 61199;

UPDATE `creature_template`
SET `dmg_min` = 515.5281,
    `dmg_max` = 552.1209,
    `attack_power` = 258,
    `ranged_attack_power` = 182
WHERE `entry` = 61200;

UPDATE `creature_template`
SET `scale` = 1,
    `dmg_min` = 418.6647,
    `dmg_max` = 551.0446,
    `attack_power` = 258,
    `ranged_attack_power` = 182
WHERE `entry` = 61201;

UPDATE `creature_template`
SET `scale` = 1,
    `dmg_min` = 418.6647,
    `dmg_max` = 551.0446,
    `attack_power` = 258,
    `ranged_attack_power` = 182
WHERE `entry` = 61202;

UPDATE `creature_template`
SET `dmg_min` = 769.807,
    `dmg_max` = 1003.0528,
    `attack_power` = 246,
    `ranged_dmg_min` = 236.7807,
    `ranged_dmg_max` = 336.8173,
    `ranged_attack_power` = 154
WHERE `entry` = 61203;

UPDATE `creature_template`
SET `dmg_min` = 1138.1803,
    `dmg_max` = 1484.0789,
    `attack_power` = 252,
    `ranged_dmg_min` = 239.226,
    `ranged_dmg_max` = 340.2956,
    `ranged_attack_power` = 158
WHERE `entry` = 61204;

UPDATE `creature_template`
SET `scale` = 1,
    `dmg_min` = 489.6646,
    `dmg_max` = 1048.823,
    `attack_power` = 252,
    `ranged_attack_power` = 180
WHERE `entry` = 61205;

UPDATE `creature_template`
SET `dmg_min` = 723.9698,
    `dmg_max` = 874.5728,
    `attack_power` = 252,
    `ranged_dmg_min` = 86.423,
    `ranged_dmg_max` = 118.8317,
    `ranged_attack_power` = 180
WHERE `entry` = 61206;

UPDATE `creature_template`
SET `dmg_min` = 896.0074,
    `dmg_max` = 1168.9633,
    `attack_power` = 262,
    `ranged_dmg_min` = 87.6776,
    `ranged_dmg_max` = 120.5567,
    `ranged_attack_power` = 186
WHERE `entry` = 61208;

UPDATE `creature_template`
SET `dmg_min` = 762.4424,
    `dmg_max` = 920.5625,
    `attack_power` = 258,
    `ranged_dmg_min` = 86.8412,
    `ranged_dmg_max` = 119.4067,
    `ranged_attack_power` = 182
WHERE `entry` = 61209;

UPDATE `creature_template`
SET `scale` = 1,
    `dmg_min` = 489.6646,
    `dmg_max` = 524.9461,
    `attack_power` = 252,
    `ranged_attack_power` = 180
WHERE `entry` = 61210;

UPDATE `creature_template`
SET `dmg_min` = 576.6161,
    `dmg_max` = 789.504,
    `attack_power` = 258,
    `ranged_dmg_min` = 253.8974,
    `ranged_dmg_max` = 361.1656,
    `ranged_attack_power` = 182
WHERE `entry` = 61211;

UPDATE `creature_template`
SET `dmg_min` = 2121.769,
    `dmg_max` = 2643.5156,
    `attack_power` = 252,
    `ranged_dmg_min` = 239.226,
    `ranged_dmg_max` = 340.2956,
    `ranged_attack_power` = 158
WHERE `entry` = 61221;

UPDATE `creature_template`
SET `dmg_min` = 2349.9988,
    `dmg_max` = 2844.3008,
    `attack_power` = 268,
    `ranged_dmg_min` = 259.3992,
    `ranged_dmg_max` = 368.9918,
    `ranged_attack_power` = 191
WHERE `entry` = 61223;

UPDATE `creature_template`
SET `dmg_min` = 2228.437,
    `dmg_max` = 2692.2117,
    `attack_power` = 252,
    `ranged_dmg_min` = 239.226,
    `ranged_dmg_max` = 340.2956,
    `ranged_attack_power` = 158
WHERE `entry` = 61224;

UPDATE `creature_template`
SET `dmg_min` = 2636.4622,
    `dmg_max` = 3558.4075,
    `attack_power` = 252,
    `ranged_dmg_min` = 239.226,
    `ranged_dmg_max` = 340.2956,
    `ranged_attack_power` = 158
WHERE `entry` = 61225;

UPDATE `creature_template`
SET `scale` = 1,
    `dmg_min` = 978.2601,
    `dmg_max` = 1048.823,
    `attack_power` = 252,
    `ranged_attack_power` = 180
WHERE `entry` = 61254;

UPDATE `creature_template`
SET `scale` = 1,
    `dmg_min` = 519.0732,
    `dmg_max` = 635.3625,
    `attack_power` = 228,
    `ranged_attack_power` = 162
WHERE `entry` = 61255;

UPDATE `creature_template`
SET `scale` = 1,
    `dmg_min` = 90.95,
    `dmg_max` = 111.28,
    `attack_power` = 200,
    `ranged_dmg_min` = 70.4113,
    `ranged_dmg_max` = 96.8155,
    `ranged_attack_power` = 140
WHERE `entry` = 61256;

UPDATE `creature_template`
SET `scale` = 1,
    `dmg_min` = 1474.9084,
    `dmg_max` = 1957.4282,
    `attack_power` = 262,
    `ranged_dmg_min` = 256.3427,
    `ranged_dmg_max` = 364.6439,
    `ranged_attack_power` = 186
WHERE `entry` = 61319;

UPDATE `creature_template`
SET `scale` = 1,
    `dmg_min` = 91.1429,
    `dmg_max` = 111.516,
    `attack_power` = 218,
    `ranged_dmg_min` = 81.8866,
    `ranged_dmg_max` = 112.5941,
    `ranged_attack_power` = 154
WHERE `entry` = 61320;

UPDATE `creature_template`
SET `scale` = 1,
    `dmg_min` = 286.7484,
    `dmg_max` = 368.8289,
    `attack_power` = 174,
    `ranged_dmg_min` = 56.9721,
    `ranged_dmg_max` = 78.3366,
    `ranged_attack_power` = 124
WHERE `entry` = 61321;

UPDATE `creature_template`
SET `scale` = 1,
    `dmg_min` = 113.9298,
    `dmg_max` = 146.1741,
    `attack_power` = 242,
    `ranged_dmg_min` = 88.7524,
    `ranged_dmg_max` = 122.0341,
    `ranged_attack_power` = 172
WHERE `entry` = 61322;

UPDATE `creature_template`
SET `scale` = 1,
    `dmg_min` = 93.2035,
    `dmg_max` = 114.6296,
    `attack_power` = 210,
    `ranged_dmg_min` = 77.0141,
    `ranged_dmg_max` = 105.8944,
    `ranged_attack_power` = 148
WHERE `entry` = 61323;

UPDATE `creature_template`
SET `scale` = 1,
    `dmg_min` = 100.2348,
    `dmg_max` = 130.5141,
    `attack_power` = 206,
    `ranged_dmg_min` = 79.9916,
    `ranged_dmg_max` = 109.9885,
    `ranged_attack_power` = 144
WHERE `entry` = 61324;

UPDATE `creature_template`
SET `scale` = 1,
    `dmg_min` = 113.7328,
    `dmg_max` = 145.9213,
    `attack_power` = 224,
    `ranged_dmg_min` = 82.7322,
    `ranged_dmg_max` = 113.7568,
    `ranged_attack_power` = 158
WHERE `entry` = 61328;

UPDATE `creature_template`
SET `dmg_min` = 113.9298,
    `dmg_max` = 146.1741,
    `attack_power` = 242,
    `ranged_dmg_min` = 88.7524,
    `ranged_dmg_max` = 122.0341,
    `ranged_attack_power` = 172
WHERE `entry` = 61571;

INSERT INTO `migrations` (`Name`, `Hash`, `AppliedAt`)
SELECT '20260910103417_world', 'manual', NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `migrations` WHERE `Name` = '20260910103417_world');

-- ############################################################ 20260915075403_world

-- ==============================================
-- FILE: an_ill_omen.sql
-- GENERATED: 20260915075403
-- ==============================================
INSERT INTO `conditions`
(
    `condition_entry`,
    `type`,
    `value1`,
    `value2`,
    `value3`,
    `value4`,
    `flags`
)
VALUES
(41912, 9, 41912, 1, 0, 0, 0);

INSERT INTO `broadcast_text`
(
    `entry`,
    `male_text`,
    `female_text`,
    `chat_type`,
    `sound_id`,
    `language_id`,
    `emote_id1`,
    `emote_id2`,
    `emote_id3`,
    `emote_delay1`,
    `emote_delay2`,
    `emote_delay3`
)
VALUES
(4292003, 'What does the chieftan''s son have to do with a Parash''ka? These are truly dire times. Still, I will not deny my student''s request, he would not disturb his master for trivialities.', 'What does the chieftan''s son have to do with a Parash''ka? These are truly dire times. Still, I will not deny my student''s request, he would not disturb his master for trivialities.', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(4292004, 'Riftmaster Ral''pekta inspects the red crystal.', 'Riftmaster Ral''pekta inspects the red crystal.', 2, 0, 0, 0, 0, 0, 0, 0, 0),
(4292005, 'This crystal is...! No, it couldn''t... I have to make sure I am wrong!', 'This crystal is...! No, it couldn''t... I have to make sure I am wrong!', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(4292006, 'Riftmaster Ral''pekta channels arcane energy into the crystal.', 'Riftmaster Ral''pekta channels arcane energy into the crystal.', 2, 0, 0, 0, 0, 0, 0, 0, 0),
(4292007, 'Gah!', 'Gah!', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(4292008, 'Impossible, slay this fiend!', 'Impossible, slay this fiend!', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(6298901, 'He hungers...', 'He hungers...', 0, 0, 0, 0, 0, 0, 0, 0, 0);

UPDATE `gossip_menu_option`
SET `action_menu_id` = -1,
    `action_script_id` = 6292002,
    `condition_id` = 41912
WHERE `menu_id` = 62920
AND `id` = 0;

INSERT INTO `gossip_scripts`
(
    `id`,
    `delay`,
    `priority`,
    `command`,
    `datalong`,
    `datalong2`,
    `datalong3`,
    `datalong4`,
    `target_param1`,
    `target_param2`,
    `target_type`,
    `data_flags`,
    `dataint`,
    `dataint2`,
    `dataint3`,
    `dataint4`,
    `x`,
    `y`,
    `z`,
    `o`,
    `condition_id`,
    `comments`
)
VALUES
(6292002, 0, 0, 4, 147, 3, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'An Ill Omen - Riftmaster Ral''pekta Becomes Uninteractible'),
(6292002, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4292003, 0, 0, 0, 0, 0, 0, 0, 0, 'An Ill Omen - Riftmaster Ral''pekta Say 1'),
(6292002, 14, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4292004, 0, 0, 0, 0, 0, 0, 0, 0, 'An Ill Omen - Riftmaster Ral''pekta Inspects Crystal'),
(6292002, 20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4292005, 0, 0, 0, 0, 0, 0, 0, 0, 'An Ill Omen - Riftmaster Ral''pekta Say 2'),
(6292002, 30, 0, 15, 23017, 0, 0, 0, 0, 0, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'An Ill Omen - Riftmaster Ral''pekta Cast Arcane Channel'),
(6292002, 30, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4292006, 0, 0, 0, 0, 0, 0, 0, 0, 'An Ill Omen - Riftmaster Ral''pekta Channels Crystal'),
(6292002, 37, 0, 5, 0, 23017, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'An Ill Omen - Riftmaster Ral''pekta Stop Casting'),
(6292002, 37, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4292007, 0, 0, 0, 0, 0, 0, 0, 0, 'An Ill Omen - Riftmaster Ral''pekta Say 3'),
(6292002, 37, 2, 10, 62989, 120000, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 6749.655762, -6160.727051, 32.459267, 2.704545, 0, 'An Ill Omen - Summon Crystal Entity'),
(6292002, 40, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4292008, 0, 0, 0, 0, 0, 0, 0, 0, 'An Ill Omen - Riftmaster Ral''pekta Say 4'),
(6292002, 40, 1, 4, 147, 3, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'An Ill Omen - Riftmaster Ral''pekta Becomes Interactible');

INSERT INTO `creature_ai_events`
(
    `id`,
    `creature_id`,
    `condition_id`,
    `event_type`,
    `event_inverse_phase_mask`,
    `event_chance`,
    `event_flags`,
    `event_param1`,
    `event_param2`,
    `event_param3`,
    `event_param4`,
    `action1_script`,
    `action2_script`,
    `action3_script`,
    `comment`
)
VALUES
(6298901, 62989, 0, 11, 0, 100, 0, 0, 0, 0, 0, 6298901, 0, 0, 'Crystal Entity - Say line on spawn');

INSERT INTO `creature_ai_scripts`
(
    `id`,
    `delay`,
    `priority`,
    `command`,
    `datalong`,
    `datalong2`,
    `datalong3`,
    `datalong4`,
    `target_param1`,
    `target_param2`,
    `target_type`,
    `data_flags`,
    `dataint`,
    `dataint2`,
    `dataint3`,
    `dataint4`,
    `x`,
    `y`,
    `z`,
    `o`,
    `condition_id`,
    `comments`
)
VALUES
(6298901, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6298901, 0, 0, 0, 0, 0, 0, 0, 0, 'An Ill Omen - Crystal Entity Say');

-- ==============================================
-- FILE: answers_from_father.sql
-- GENERATED: 20260915075403
-- ==============================================
INSERT INTO `conditions`
(
    `condition_entry`,
    `type`,
    `value1`,
    `value2`,
    `value3`,
    `value4`,
    `flags`
)
VALUES
(41915, 9, 41915, 1, 0, 0, 0);

INSERT INTO `broadcast_text`
(
    `entry`,
    `male_text`,
    `female_text`,
    `chat_type`,
    `sound_id`,
    `language_id`,
    `emote_id1`,
    `emote_id2`,
    `emote_id3`,
    `emote_delay1`,
    `emote_delay2`,
    `emote_delay3`
)
VALUES
(6285003, 'My son? What is the meaning of this?', 'My son? What is the meaning of this?', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(6285004, 'Ar''lia, just what are you talking about? What are you accusing me of?', 'Ar''lia, just what are you talking about? What are you accusing me of?', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(6285005, 'Son, your words are bold and unruly towards me, your father. They cut deep, but can only do so because they are the truth. Yes, I hid things from you, out of shame and in fear of my own weakness.', 'Son, your words are bold and unruly towards me, your father. They cut deep, but can only do so because they are the truth. Yes, I hid things from you, out of shame and in fear of my own weakness.', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(6285006, 'Bhu''robi had always been critical of out ways, especially after our escape to this world. Our inaction towards the advances of the demonic orcs, while posessing the power of the Draenethyst, is a flaw that he was deeply revolted by.', 'Bhu''robi had always been critical of out ways, especially after our escape to this world. Our inaction towards the advances of the demonic orcs, while posessing the power of the Draenethyst, is a flaw that he was deeply revolted by.', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(6285007, 'My son, tell me: if you were in mortal danger, would you not do everything you can to survive? In such situations, rationality often subsides in favor of our instincts. Bhu''robi knew this all too well. I still remember his last words to me as if they were uttered mere moments ago.', 'My son, tell me: if you were in mortal danger, would you not do everything you can to survive? In such situations, rationality often subsides in favor of our instincts. Bhu''robi knew this all too well. I still remember his last words to me as if they were uttered mere moments ago.', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(6285008, 'You are shackled by your traditions, stuck in the mire of your self-inflicted lethargy. If you wish to rot dwelling on the past, so be it. But I will usher in a new dawn for our people. And then you will see the truth yourself.', 'You are shackled by your traditions, stuck in the mire of your self-inflicted lethargy. If you wish to rot dwelling on the past, so be it. But I will usher in a new dawn for our people. And then you will see the truth yourself.', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(6285009, 'Ar''lia...', 'Ar''lia...', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(57101, 'Father, you haven''t told me the truth, have you?', 'Father, you haven''t told me the truth, have you?', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(57102, 'Don''t deny it, Father. We have discovered Bhu''robi''s true goal. It was never merely a simple dispute about out traditions and beliefs, was it? Tell us what really happened that night you talked.', 'Don''t deny it, Father. We have discovered Bhu''robi''s true goal. It was never merely a simple dispute about out traditions and beliefs, was it? Tell us what really happened that night you talked.', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(57103, 'But the Draenethyst are sacred relics to the draenei. Out of all people, he should''ve known this ths the most as an Elder.', 'But the Draenethyst are sacred relics to the draenei. Out of all people, he should''ve known this ths the most as an Elder.', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(57104, 'Bhu''robi...', 'Bhu''robi...', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(57105, 'I have much to comtemplate, father. Before I leave, let me say this: The father I knew would have taken action in the face of danger. Just like he braved the horrors of Draenor. With resolve and determination.', 'I have much to comtemplate, father. Before I leave, let me say this: The father I knew would have taken action in the face of danger. Just like he braved the horrors of Draenor. With resolve and determination.', 0, 0, 0, 0, 0, 0, 0, 0, 0);

UPDATE `gossip_menu_option`
SET `action_menu_id` = -1,
    `action_script_id` = 6285002,
    `condition_id` = 41915
WHERE `menu_id` = 62850
AND `id` = 0;

INSERT INTO `gossip_scripts`
(
    `id`,
    `delay`,
    `priority`,
    `command`,
    `datalong`,
    `datalong2`,
    `datalong3`,
    `datalong4`,
    `target_param1`,
    `target_param2`,
    `target_type`,
    `data_flags`,
    `dataint`,
    `dataint2`,
    `dataint3`,
    `dataint4`,
    `x`,
    `y`,
    `z`,
    `o`,
    `condition_id`,
    `comments`
)
VALUES
(6285002, 0, 0, 4, 147, 3, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'Answers from Father - Moro''gai K''la Becomes Uninteractible'),
(6285002, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6285003, 0, 0, 0, 0, 0, 0, 0, 0, 'Answers from Father - Moro''gai K''la Say 1'),
(6285002, 0, 2, 10, 571, 0, 0, 0, 0, 0, 0, 0, 2, 57100, -1, 8, 6776.019043, -6146.787109, 68.918442, 0.612012, 0, 'Answers from Father - Summon Ar''lia'),
(6285002, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6285004, 0, 0, 0, 0, 0, 0, 0, 0, 'Answers from Father - Moro''gai K''la Say 2'),
(6285002, 21, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6285005, 0, 0, 0, 0, 0, 0, 0, 0, 'Answers from Father - Moro''gai K''la Say 3'),
(6285002, 36, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6285006, 0, 0, 0, 0, 0, 0, 0, 0, 'Answers from Father - Moro''gai K''la Say 4'),
(6285002, 54, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6285007, 0, 0, 0, 0, 0, 0, 0, 0, 'Answers from Father - Moro''gai K''la Say 5'),
(6285002, 69, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6285008, 0, 0, 0, 0, 0, 0, 0, 0, 'Answers from Father - Moro''gai K''la Say 6'),
(6285002, 102, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6285009, 0, 0, 0, 0, 0, 0, 0, 0, 'Answers from Father - Moro''gai K''la Say 7'),
(6285002, 105, 0, 8, 60083, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 41915, 'Answers from Father - Confronted Moro''gai K''la Credit'),
(6285002, 105, 1, 4, 147, 3, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'Answers from Father - Moro''gai K''la Becomes Interactible');

INSERT INTO `generic_scripts`
(
    `id`,
    `delay`,
    `priority`,
    `command`,
    `datalong`,
    `datalong2`,
    `datalong3`,
    `datalong4`,
    `target_param1`,
    `target_param2`,
    `target_type`,
    `data_flags`,
    `dataint`,
    `dataint2`,
    `dataint3`,
    `dataint4`,
    `x`,
    `y`,
    `z`,
    `o`,
    `condition_id`,
    `comments`
)
VALUES
(57100, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 57101, 0, 0, 0, 0, 0, 0, 0, 0, 'Answers from Father - Ar''lia Say 1'),
(57100, 4, 1, 3, 0, 3000, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6781.931152, -6143.032227, 68.918442, 0, 0, 'Answers from Father - Ar''lia Move Forward'),
(57100, 12, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 57102, 0, 0, 0, 0, 0, 0, 0, 0, 'Answers from Father - Ar''lia Say 2'),
(57100, 46, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 57103, 0, 0, 0, 0, 0, 0, 0, 0, 'Answers from Father - Ar''lia Say 3'),
(57100, 89, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 57104, 0, 0, 0, 0, 0, 0, 0, 0, 'Answers from Father - Ar''lia Say 4'),
(57100, 92, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 57105, 0, 0, 0, 0, 0, 0, 0, 0, 'Answers from Father - Ar''lia Say 5'),
(57100, 102, 0, 3, 0, 3000, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6776.019043, -6146.787109, 68.918442, 0.612012, 0, 'Answers from Father - Ar''lia Move Back'),
(57100, 110, 0, 18, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'Answers from Father - Ar''lia Despawn');

-- ==============================================
-- FILE: arlia_quests.sql
-- GENERATED: 20260915075403
-- ==============================================
INSERT INTO `creature_questrelation`
(
    `id`,
    `quest`
)
VALUES
(62986, 41912),
(62986, 41915),
(62986, 41911);

INSERT INTO `creature_involvedrelation`
(
    `id`,
    `quest`
)
VALUES
(62986, 41917),
(62986, 41910),
(62986, 41914),
(62986, 41911);

-- ==============================================
-- FILE: blackroot_totems.sql
-- GENERATED: 20260915075403
-- ==============================================
UPDATE `quest_template`
SET `SpecialFlags` = `SpecialFlags` | 1
WHERE `entry` = 41899;

-- ==============================================
-- FILE: bound_in_stone.sql
-- GENERATED: 20260915075403
-- ==============================================
INSERT INTO `creature_questrelation`
(
    `id`,
    `quest`
)
VALUES
(62981, 42051);

INSERT INTO `creature_involvedrelation`
(
    `id`,
    `quest`
)
VALUES
(62981, 42051);

UPDATE `spell_template`
SET `script_name` = 'spell_moonwhisper_bundle_of_beads'
WHERE `entry` = 37098;

-- ==============================================
-- FILE: cook_remsai_quests.sql
-- GENERATED: 20260915075403
-- ==============================================
INSERT INTO `creature_involvedrelation`
(
    `id`,
    `quest`
)
VALUES
(62861, 41944);

-- ==============================================
-- FILE: delivery_from_talendris.sql
-- GENERATED: 20260915075403
-- ==============================================
UPDATE `creature_template`
SET `scale` = 1,
    `dmg_min` = 102.267876,
    `dmg_max` = 131.14238,
    `attack_power` = 206,
    `ranged_dmg_min` = 75.210083,
    `ranged_dmg_max` = 103.413864,
    `ranged_attack_power` = 144
WHERE `entry` = 63160;

INSERT INTO `creature`
(
    `guid`,
    `id`,
    `id2`,
    `id3`,
    `id4`,
    `map`,
    `position_x`,
    `position_y`,
    `position_z`,
    `orientation`,
    `spawntimesecsmin`,
    `spawntimesecsmax`,
    `wander_distance`,
    `health_percent`,
    `mana_percent`,
    `movement_type`,
    `spawn_flags`,
    `visibility_mod`
)
VALUES
(2596626, 63160, 0, 0, 0, 1, 2694, -3888.459961, 109.014999, 1.2837400436401367, 300, 300, 0, 100, 100, 0, 0, 0);

-- ==============================================
-- FILE: elder_krasheen_quests.sql
-- GENERATED: 20260915075403
-- ==============================================
INSERT INTO `creature_questrelation`
(
    `id`,
    `quest`
)
VALUES
(62863, 41922);

INSERT INTO `creature_involvedrelation`
(
    `id`,
    `quest`
)
VALUES
(62863, 41921);

-- ==============================================
-- FILE: elder.sql
-- GENERATED: 20260915075403
-- ==============================================
INSERT INTO `creature_addon`
(
    `guid`,
    `display_id`,
    `mount_display_id`,
    `equipment_id`,
    `stand_state`,
    `sheath_state`,
    `emote_state`,
    `auras`
)
VALUES
(2597153, 0, 0, -1, 7, 1, 0, NULL);

INSERT INTO `creature`
(
    `guid`,
    `id`,
    `id2`,
    `id3`,
    `id4`,
    `map`,
    `position_x`,
    `position_y`,
    `position_z`,
    `orientation`,
    `spawntimesecsmin`,
    `spawntimesecsmax`,
    `wander_distance`,
    `health_percent`,
    `mana_percent`,
    `movement_type`,
    `spawn_flags`,
    `visibility_mod`
)
VALUES
(2593826, 62923, 0, 0, 0, 1, 6783.370117, -6139.529785, 43.655399, 5.8744401931762695, 300, 300, 0, 100, 100, 0, 0, 0),
(2597153, 63177, 0, 0, 0, 1, 6786.189941, -6142.830078, 44.298901, 4.1876702308654785, 300, 300, 0, 100, 100, 0, 0, 0);

INSERT INTO `creature_equip_template`
(
    `entry`,
    `equipentry1`,
    `equipentry2`,
    `equipentry3`
)
VALUES
(62923, 19570, 0, 0);

INSERT INTO `creature_template`
(
    `entry`,
    `display_id1`,
    `display_id2`,
    `display_id3`,
    `display_id4`,
    `mount_display_id`,
    `name`,
    `subname`,
    `gossip_menu_id`,
    `level_min`,
    `level_max`,
    `health_min`,
    `health_max`,
    `mana_min`,
    `mana_max`,
    `armor`,
    `faction`,
    `npc_flags`,
    `speed_walk`,
    `speed_run`,
    `scale`,
    `detection_range`,
    `call_for_help_range`,
    `leash_range`,
    `rank`,
    `xp_multiplier`,
    `dmg_min`,
    `dmg_max`,
    `dmg_school`,
    `attack_power`,
    `dmg_multiplier`,
    `base_attack_time`,
    `ranged_attack_time`,
    `unit_class`,
    `unit_flags`,
    `dynamic_flags`,
    `beast_family`,
    `trainer_type`,
    `trainer_spell`,
    `trainer_class`,
    `trainer_race`,
    `ranged_dmg_min`,
    `ranged_dmg_max`,
    `ranged_attack_power`,
    `type`,
    `type_flags`,
    `loot_id`,
    `pickpocket_loot_id`,
    `skinning_loot_id`,
    `holy_res`,
    `fire_res`,
    `nature_res`,
    `frost_res`,
    `shadow_res`,
    `arcane_res`,
    `spell_id1`,
    `spell_id2`,
    `spell_id3`,
    `spell_id4`,
    `spell_list_id`,
    `pet_spell_list_id`,
    `spawn_spell_id`,
    `auras`,
    `gold_min`,
    `gold_max`,
    `ai_name`,
    `movement_type`,
    `inhabit_type`,
    `civilian`,
    `racial_leader`,
    `regeneration`,
    `equipment_id`,
    `trainer_id`,
    `vendor_id`,
    `mechanic_immune_mask`,
    `school_immune_mask`,
    `immunity_flags`,
    `flags_extra`,
    `phase_quest_id`,
    `script_name`
)
VALUES
(62923, 18575, 0, 0, 0, 0, 'Elder Sage Azh''okar', 'Reagents', 62923, 58, 58, 4263, 4263, 0, 0, 1754, 160, 7, 1, 1.14286, 1, 18, 5, 30, 0, 1, 108.555725, 134.351151, 0, 242, 1, 2000, 2000, 1, 32768, 0, 0, 0, 0, 0, 0, 88.388618, 121.53434, 172, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, 0, 0, 'EventAI', 0, 3, 0, 0, 3, 62923, 0, 0, 0, 0, 0, 0, 0, '');

INSERT INTO `creature_questrelation`
(
    `id`,
    `quest`
)
VALUES
(62993, 41918),
(62923, 41919);

INSERT INTO `creature_involvedrelation`
(
    `id`,
    `quest`
)
VALUES
(62923, 41918),
(62923, 41919);

UPDATE `quest_template`
SET `SpecialFlags` = `SpecialFlags` | 1
WHERE `entry` = 41919;

INSERT INTO `npc_vendor`
(
    `entry`,
    `slot`,
    `item`,
    `maxcount`,
    `incrtime`,
    `itemflags`,
    `condition_id`
)
VALUES
(62923, 1, 17019, 0, 0, 0, 0),
(62923, 2, 17034, 0, 0, 0, 0),
(62923, 3, 17035, 0, 0, 0, 0),
(62923, 4, 17036, 0, 0, 0, 0),
(62923, 5, 17037, 0, 0, 0, 0),
(62923, 6, 17038, 0, 0, 0, 0),
(62923, 7, 17031, 0, 0, 0, 0),
(62923, 8, 17032, 0, 0, 0, 0),
(62923, 9, 17020, 0, 0, 0, 0),
(62923, 10, 17030, 0, 0, 0, 0),
(62923, 11, 17033, 0, 0, 0, 0),
(62923, 12, 17028, 0, 0, 0, 0),
(62923, 13, 17029, 0, 0, 0, 0),
(62923, 14, 17021, 0, 0, 0, 0),
(62923, 15, 17026, 0, 0, 0, 0),
(62923, 16, 5565, 0, 0, 0, 0),
(62923, 17, 16583, 0, 0, 0, 0),
(62923, 18, 21177, 0, 0, 0, 0);

-- ==============================================
-- FILE: expedition_gone_wrong.sql
-- GENERATED: 20260915075403
-- ==============================================
-- Expedition Gone Wrong (42068)

UPDATE `creature_template`
SET `gossip_menu_id` = 6311901
WHERE `entry` = 63119;

DELETE FROM `gossip_menu_option`
WHERE `menu_id` = 63119;

DELETE FROM `gossip_menu`
WHERE `entry` = 63119;

DELETE FROM `npc_text`
WHERE `ID` = 6311901;

DELETE FROM `broadcast_text`
WHERE `entry` IN (
    6311901, 6311902, 6311903
    );

INSERT INTO `broadcast_text`
(
    `entry`,
    `male_text`,
    `female_text`,
    `chat_type`,
    `sound_id`,
    `language_id`,
    `emote_id1`,
    `emote_id2`,
    `emote_id3`,
    `emote_delay1`,
    `emote_delay2`,
    `emote_delay3`
)
VALUES
(6311901, 'Truly a disaster, to be sent here by that fool of a cousin of mine. Of all the places one might be assigned, it had to be this - so distant, so very odd.$B$BThese lands are strange, yes, but do not mistake my displeasure for weakness. I did not come all this way to fail. Whatever trials await, I will endure them, and I will see my mission done..', 'Truly a disaster, to be sent here by that fool of a cousin of mine. Of all the places one might be assigned, it had to be this - so distant, so very odd.$B$BThese lands are strange, yes, but do not mistake my displeasure for weakness. I did not come all this way to fail. Whatever trials await, I will endure them, and I will see my mission done..', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(6311902, 'Tell me your story, Andanil', 'Tell me your story, Andanil', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(6311903, 'My venerable cousin, in what he no doubt considers unmatched wisdom, sent us to this forsaken place chasing draenethyst. Promises of abundance. Of answers. Of being remembered as saviors.$B$BYes, the crystals are impressive. Potent, refined, useful. They keep our people standing a little longer. They quiet the hunger. But that is all they do. Sustenance. Not salvation. I did not cross half the world to return to Alah’thalas carrying crates of arcane crystals.$B$BSo I pushed further. Against advice. Against caution. Against that quiet voice that suggests restraint.', 'My venerable cousin, in what he no doubt considers unmatched wisdom, sent us to this forsaken place chasing draenethyst. Promises of abundance. Of answers. Of being remembered as saviors.$B$BYes, the crystals are impressive. Potent, refined, useful. They keep our people standing a little longer. They quiet the hunger. But that is all they do. Sustenance. Not salvation. I did not cross half the world to return to Alah’thalas carrying crates of arcane crystals.$B$BSo I pushed further. Against advice. Against caution. Against that quiet voice that suggests restraint.', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(6311904, '<continue>', '<continue>', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(6311905, 'North of here lies an old Barrow Den. Forgotten. Abandoned. Or so it appeared. The place bled magic. Not wild, not crude, but dense. Ancient. The sort that makes your skin prickle even before a spell is cast.$B$BMaelion took a sizeable force and went inside. Capable soldiers. Trained arcanists. People I trusted. Then we heard it. An explosion. Not sound alone. A pressure in the air, like the world itself flinched.$B$BWhen we reached the den, there was nothing left of them. Not truly. Their bodies remained, but the mana was gone. Drained clean. Empty shells, withered beyond recognition. Worse than the withered back home. Those at least remember who they were. These ones do not remember anything. Not their names. Not their purpose. Not even fear.', 'North of here lies an old Barrow Den. Forgotten. Abandoned. Or so it appeared. The place bled magic. Not wild, not crude, but dense. Ancient. The sort that makes your skin prickle even before a spell is cast.$B$BMaelion took a sizeable force and went inside. Capable soldiers. Trained arcanists. People I trusted. Then we heard it. An explosion. Not sound alone. A pressure in the air, like the world itself flinched.$B$BWhen we reached the den, there was nothing left of them. Not truly. Their bodies remained, but the mana was gone. Drained clean. Empty shells, withered beyond recognition. Worse than the withered back home. Those at least remember who they were. These ones do not remember anything. Not their names. Not their purpose. Not even fear.', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(6311906, '<continue>', '<continue>', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(6311907, 'They did not leave the den. They still roam it. Searching. Or guarding. I cannot tell which is more unsettling.$B$BWhatever happened there involved power far beyond draenethyst. Power that can wither a mage in moments. And that is precisely why it matters. If something can do this, so completely and so quickly, then it stands to reason that it might do the opposite as well.$B$BYes, I know. Theory. Speculation. Desperation, if you prefer honesty. But desperation is where breakthroughs are born.$B$BI will not return to Alah’thalas empty handed. Not with excuses. Not with crystals anyone could have gathered. Whatever lies within that Barrow Den is the reason we are here. I can feel it.$B$BAnd I intend to claim it, whatever the cost.', 'They did not leave the den. They still roam it. Searching. Or guarding. I cannot tell which is more unsettling.$B$BWhatever happened there involved power far beyond draenethyst. Power that can wither a mage in moments. And that is precisely why it matters. If something can do this, so completely and so quickly, then it stands to reason that it might do the opposite as well.$B$BYes, I know. Theory. Speculation. Desperation, if you prefer honesty. But desperation is where breakthroughs are born.$B$BI will not return to Alah’thalas empty handed. Not with excuses. Not with crystals anyone could have gathered. Whatever lies within that Barrow Den is the reason we are here. I can feel it.$B$BAnd I intend to claim it, whatever the cost.', 0, 0, 0, 0, 0, 0, 0, 0, 0);

INSERT INTO `npc_text`
(
    `ID`,
    `BroadcastTextID0`,
    `Probability0`,
    `BroadcastTextID1`,
    `Probability1`,
    `BroadcastTextID2`,
    `Probability2`,
    `BroadcastTextID3`,
    `Probability3`,
    `BroadcastTextID4`,
    `Probability4`,
    `BroadcastTextID5`,
    `Probability5`,
    `BroadcastTextID6`,
    `Probability6`,
    `BroadcastTextID7`,
    `Probability7`
)
VALUES
(6311901, 6311901, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0),
(6311903, 6311903, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0),
(6311905, 6311905, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0),
(6311907, 6311907, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0);

INSERT INTO `gossip_menu`
(
    `entry`,
    `text_id`,
    `script_id`,
    `condition_id`
)
VALUES
(6311901, 6311901, 0, 0),
(6311902, 6311903, 0, 0),
(6311903, 6311905, 0, 0),
(6311904, 6311907, 0, 0);

INSERT INTO `gossip_menu_option`
(
    `menu_id`,
    `id`,
    `option_icon`,
    `option_text`,
    `option_broadcast_text`,
    `option_id`,
    `npc_option_npcflag`,
    `action_menu_id`,
    `action_poi_id`,
    `action_script_id`,
    `box_coded`,
    `box_money`,
    `box_text`,
    `box_broadcast_text`,
    `condition_id`
)
VALUES
(6311901, 0, 0, 'Tell me your story, Andanil', 6311902, 1, 1, 6311902, 0, 0, 0, 0, '', 0, 0),
(6311902, 0, 0, '<continue>', 6311904, 1, 1, 6311903, 0, 0, 0, 0, '', 0, 0),
(6311903, 0, 0, '<continue>', 6311906, 1, 1, 6311904, 0, 6311906, 0, 0, '', 0, 0);

INSERT INTO `gossip_scripts`
(
    `id`,
    `delay`,
    `priority`,
    `command`,
    `datalong`,
    `datalong2`,
    `datalong3`,
    `datalong4`,
    `target_param1`,
    `target_param2`,
    `target_type`,
    `data_flags`,
    `dataint`,
    `dataint2`,
    `dataint3`,
    `dataint4`,
    `x`,
    `y`,
    `z`,
    `o`,
    `condition_id`,
    `comments`
)
VALUES
(6311906, 0, 0, 8, 60089, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'Expedition Gone Wrong - Andanil Sunsworn story heard');

-- ==============================================
-- FILE: facing_the_elder.sql
-- GENERATED: 20260915075403
-- ==============================================
INSERT INTO `conditions`
(
    `condition_entry`,
    `type`,
    `value1`,
    `value2`,
    `value3`,
    `value4`,
    `flags`
)
VALUES
(42073, 9, 42073, 1, 0, 0, 0);

INSERT INTO `broadcast_text`
(
    `entry`,
    `male_text`,
    `female_text`,
    `chat_type`,
    `sound_id`,
    `language_id`,
    `emote_id1`,
    `emote_id2`,
    `emote_id3`,
    `emote_delay1`,
    `emote_delay2`,
    `emote_delay3`
)
VALUES
(2947902, 'Elder, we must speak.', 'Elder, we must speak.', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(2947903, 'Must we? You have become rather familiar with both I and my tribe, hordeling. Do not mistake my patience for acceptance. Yours was a required aid, no matter how dreadful it was to take this decision. In truth we have forsaken our alliance with the Children of the Moon in favor of your barbaric allies.$B$BA decision I did not take lightly. And one I might end up regretting. I have seen you plot with those that’d see me dictatorial, somehow you have even tamed my son in your delusions.', 'Must we? You have become rather familiar with both I and my tribe, hordeling. Do not mistake my patience for acceptance. Yours was a required aid, no matter how dreadful it was to take this decision. In truth we have forsaken our alliance with the Children of the Moon in favor of your barbaric allies.$B$BA decision I did not take lightly. And one I might end up regretting. I have seen you plot with those that’d see me dictatorial, somehow you have even tamed my son in your delusions.', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(2947904, 'Then perhaps your sight is growing dim.', 'Then perhaps your sight is growing dim.', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(2947905, 'How bold. Your arrogance knows no end, you dare mock me in my own home? You have no idea how much our tribe has sacrificed to leave our hoofsteps on these plains. We were nomads before yet never without a home, for our home was the entire Kalimdor under the guise of the Earthmother and the light of both An’she and Mu’sha.$B$BAs testament to our connection to the Mother of Night, youngbloods of our tribe began to be born with a crescent moon under their hoof, treading marks upon this land its mud and everything there was, is and will be with our bond. How could you even begin to understand? My people were chosen.', 'How bold. Your arrogance knows no end, you dare mock me in my own home? You have no idea how much our tribe has sacrificed to leave our hoofsteps on these plains. We were nomads before yet never without a home, for our home was the entire Kalimdor under the guise of the Earthmother and the light of both An’she and Mu’sha.$B$BAs testament to our connection to the Mother of Night, youngbloods of our tribe began to be born with a crescent moon under their hoof, treading marks upon this land its mud and everything there was, is and will be with our bond. How could you even begin to understand? My people were chosen.', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(2947906, 'By An’she and Mu’sha, yet what of Lo’sho?', 'By An’she and Mu’sha, yet what of Lo’sho?', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(2947907, 'Do not attempt to quote our culture to me, hordeling. You can’t even try to understand our connections to the Celestial Siblings. As of Lo’sho. A rebellious child, one that speaks to you, some of my tribesmen and even my son. Is it he who sold you this information?', 'Do not attempt to quote our culture to me, hordeling. You can’t even try to understand our connections to the Celestial Siblings. As of Lo’sho. A rebellious child, one that speaks to you, some of my tribesmen and even my son. Is it he who sold you this information?', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(2947908, 'So to follow Lo’sho is to be granted death by the Moonhoofs.', 'So to follow Lo’sho is to be granted death by the Moonhoofs.', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(2947909, 'Ah, you blame me. For something you did. Indeed I set you on the path to slay the Shade Mother and her minions. Indeed they were followers of Lo’sho, but they were just pawns in a much grander scheme. And after you so eagerly shed blood for me, I found out what his true intentions were.', 'Ah, you blame me. For something you did. Indeed I set you on the path to slay the Shade Mother and her minions. Indeed they were followers of Lo’sho, but they were just pawns in a much grander scheme. And after you so eagerly shed blood for me, I found out what his true intentions were.', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(2947910, 'Speak then. Seek my aid once more.', 'Speak then. Seek my aid once more.', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(2947911, 'Arrogant whelp. Yet you have proven yourself time and time again. All right.$BBefore the Riverhorn Village was burnt to ash by the Draenei, the Grove of the Moon was led by Archdruid Mothshroud and his apprentice Ireth Moondancer. That grove, much like the Grove the Sun on the isle of Tyrandas, was a place of study and friendship between us and the night elves. Mothshroud was a benevolent and kind leader, and a friend to me. He would worship both moons side by side in this grove, both Mu’sha and the youngest, Lo’sho.', 'Arrogant whelp. Yet you have proven yourself time and time again. All right.$BBefore the Riverhorn Village was burnt to ash by the Draenei, the Grove of the Moon was led by Archdruid Mothshroud and his apprentice Ireth Moondancer. That grove, much like the Grove the Sun on the isle of Tyrandas, was a place of study and friendship between us and the night elves. Mothshroud was a benevolent and kind leader, and a friend to me. He would worship both moons side by side in this grove, both Mu’sha and the youngest, Lo’sho.', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(2947912, 'Go on.', 'Go on.', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(2947913, 'In that time of peace Mothshroud spoke of Lo’sho as a symbol of hope, born out of hardship and suffering. You should know, Lo’sho is the tear of Mu’sha, and he was born when the Earthmother felt such sorrow that through Mu’sha she wept for us. I did not see it coming, truly. Not the attack on Riverhorn, nor my friend’s spiral into anger and loss of his own mind.$B$BOnce Riverhorn turned to ash I did not seek to take vengeance on the Draenei. I thought about the flow of nature and prayed to my patron. And when I received signs that He too was of the same mind, I refused to allow those who felt a thirst for blood to sate it.', 'In that time of peace Mothshroud spoke of Lo’sho as a symbol of hope, born out of hardship and suffering. You should know, Lo’sho is the tear of Mu’sha, and he was born when the Earthmother felt such sorrow that through Mu’sha she wept for us. I did not see it coming, truly. Not the attack on Riverhorn, nor my friend’s spiral into anger and loss of his own mind.$B$BOnce Riverhorn turned to ash I did not seek to take vengeance on the Draenei. I thought about the flow of nature and prayed to my patron. And when I received signs that He too was of the same mind, I refused to allow those who felt a thirst for blood to sate it.', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(2947914, 'Continue.', 'Continue.', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(2947915, 'Mothshroud had lost his spark. What makes man lose all that he valued in the blink of an eye? The death of a lover, a parent, a sibling, a child? Who knows which was the last straw. He had lost it all. Once he knew of my stance, he grew distant and bitter. I do not blame him for that, but for what he did afterwards.', 'Mothshroud had lost his spark. What makes man lose all that he valued in the blink of an eye? The death of a lover, a parent, a sibling, a child? Who knows which was the last straw. He had lost it all. Once he knew of my stance, he grew distant and bitter. I do not blame him for that, but for what he did afterwards.', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(2947916, 'What was it?', 'What was it?', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(2947917, 'He took the survivors of Riverhorn and others who were willing and told them to foster a new name, the Shadewalkers. And he named a common and valued friend of ours as their leader. They were meant to summon our ancestors and use them as means of vengeance.$B$BAfter, he returned to the Grove of the Moon. An ultimatum was made, the Druids there would abandon Mu’sha and swear fealty to Lo’sho, to a Lo’sho that would not turn a blind eye to their need of vengeance. He named the night elves Druids of the Moth while the tauren Disciples of Lo’sho.', 'He took the survivors of Riverhorn and others who were willing and told them to foster a new name, the Shadewalkers. And he named a common and valued friend of ours as their leader. They were meant to summon our ancestors and use them as means of vengeance.$B$BAfter, he returned to the Grove of the Moon. An ultimatum was made, the Druids there would abandon Mu’sha and swear fealty to Lo’sho, to a Lo’sho that would not turn a blind eye to their need of vengeance. He named the night elves Druids of the Moth while the tauren Disciples of Lo’sho.', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(2947918, 'Go on.', 'Go on.', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(2947919, 'Mothshroud had lost his spark. What makes man lose all that he valued in the blink of an eye? The death of a lover, a parent, a sibling, a child? Who knows which was the last straw. He had lost it all.$B$BOnce he knew of my stance, he grew distant and bitter. I do not blame him for that.$B$BI do blame him for what he did. He took the survivors of Riverhorn and others who were willing and told them to foster a new name, the Shadewalkers you have dealt with before. And he named a common and valued friend of ours as their leader. They were meant to summon our ancestors and use them as means of vengeance.$B$BAfter, he returned to the Grove of the Moon. An ultimatum was made, the Druids there would abandon Mu’sha and swear fealty to Lo’sho, to a Lo’sho that would not turn a blind eye to their need of vengeance. He named the night elves Druids of the Moth while the tauren Disciples of Lo’sho.', 'Mothshroud had lost his spark. What makes man lose all that he valued in the blink of an eye? The death of a lover, a parent, a sibling, a child? Who knows which was the last straw. He had lost it all.$B$BOnce he knew of my stance, he grew distant and bitter. I do not blame him for that.$B$BI do blame him for what he did. He took the survivors of Riverhorn and others who were willing and told them to foster a new name, the Shadewalkers you have dealt with before. And he named a common and valued friend of ours as their leader. They were meant to summon our ancestors and use them as means of vengeance.$B$BAfter, he returned to the Grove of the Moon. An ultimatum was made, the Druids there would abandon Mu’sha and swear fealty to Lo’sho, to a Lo’sho that would not turn a blind eye to their need of vengeance. He named the night elves Druids of the Moth while the tauren Disciples of Lo’sho.', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(2947920, 'It can’t end there.', 'It can’t end there.', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(2947921, 'It does not. The Druids of the grove that didn’t willingly commit to his rule were forced into it. Mothshroud fell for the words of a satyr, one who claimed was, like him, a follower of Lo’sho. And so with the aid of the satyr you have found in the depths of the Barrows, he bent the minds of those that were unwilling to follow.$B$BAnd so he left, with his agents ready to brew chaos that would keep us unfocused. His hoofsteps were last seen in the ruins of Maras’ethil, seeking an artifact he had heard of from the satyr. Whether his task was a succes or not, it is something that you must find out.', 'It does not. The Druids of the grove that didn’t willingly commit to his rule were forced into it. Mothshroud fell for the words of a satyr, one who claimed was, like him, a follower of Lo’sho. And so with the aid of the satyr you have found in the depths of the Barrows, he bent the minds of those that were unwilling to follow.$B$BAnd so he left, with his agents ready to brew chaos that would keep us unfocused. His hoofsteps were last seen in the ruins of Maras’ethil, seeking an artifact he had heard of from the satyr. Whether his task was a succes or not, it is something that you must find out.', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(2947922, 'This barely changes what you did.', 'This barely changes what you did.', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(2947923, 'To think you so judgemental, as if you are in any position to question me. Alas, I could not care less about your feelings on the matter. I hid from responsibility in the face of death, my choice led to a brewing hatred. And ever since I have tried to dismantle that hatred by making it go away. At the end of the day, what do I have?$B$BA conscience burdened that I had another spill blood for me and the displeasement I feel from my tribe, from my own family. I know what I did, hordeling. I know what happens after this all ends. I know how I must pay.', 'To think you so judgemental, as if you are in any position to question me. Alas, I could not care less about your feelings on the matter. I hid from responsibility in the face of death, my choice led to a brewing hatred. And ever since I have tried to dismantle that hatred by making it go away. At the end of the day, what do I have?$B$BA conscience burdened that I had another spill blood for me and the displeasement I feel from my tribe, from my own family. I know what I did, hordeling. I know what happens after this all ends. I know how I must pay.', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(2947924, 'And how will you be paying, Elder?', 'And how will you be paying, Elder?', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(2947925, 'With my own death.', 'With my own death.', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(2947926, 'We will see if that is for you to decide.', 'We will see if that is for you to decide.', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(2947927, 'I have told you all I know, and the future has yet to happen. You asked me to seek your aid, and now I am.', 'I have told you all I know, and the future has yet to happen. You asked me to seek your aid, and now I am.', 0, 0, 0, 0, 0, 0, 0, 0, 0);

INSERT INTO `npc_text`
(
    `ID`,
    `BroadcastTextID0`,
    `Probability0`,
    `BroadcastTextID1`,
    `Probability1`,
    `BroadcastTextID2`,
    `Probability2`,
    `BroadcastTextID3`,
    `Probability3`,
    `BroadcastTextID4`,
    `Probability4`,
    `BroadcastTextID5`,
    `Probability5`,
    `BroadcastTextID6`,
    `Probability6`,
    `BroadcastTextID7`,
    `Probability7`
)
VALUES
(2947903, 2947903, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0),
(2947905, 2947905, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0),
(2947907, 2947907, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0),
(2947909, 2947909, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0),
(2947911, 2947911, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0),
(2947913, 2947913, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0),
(2947915, 2947915, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0),
(2947917, 2947917, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0),
(2947919, 2947919, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0),
(2947921, 2947921, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0),
(2947923, 2947923, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0),
(2947925, 2947925, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0),
(2947927, 2947927, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0);

INSERT INTO `gossip_menu`
(
    `entry`,
    `text_id`,
    `script_id`,
    `condition_id`
)
VALUES
(2947902, 2947903, 0, 0),
(2947903, 2947905, 0, 0),
(2947904, 2947907, 0, 0),
(2947905, 2947909, 0, 0),
(2947906, 2947911, 0, 0),
(2947907, 2947913, 0, 0),
(2947908, 2947915, 0, 0),
(2947909, 2947917, 0, 0),
(2947910, 2947919, 0, 0),
(2947911, 2947921, 0, 0),
(2947912, 2947923, 0, 0),
(2947913, 2947925, 0, 0),
(2947914, 2947927, 0, 0);

INSERT INTO `gossip_menu_option`
(
    `menu_id`,
    `id`,
    `option_icon`,
    `option_text`,
    `option_broadcast_text`,
    `option_id`,
    `npc_option_npcflag`,
    `action_menu_id`,
    `action_poi_id`,
    `action_script_id`,
    `box_coded`,
    `box_money`,
    `box_text`,
    `box_broadcast_text`,
    `condition_id`
)
VALUES
(29479, 0, 0, 'Elder, we must speak.', 2947902, 1, 1, 2947902, 0, 0, 0, 0, '', 0, 42073),
(2947902, 0, 0, 'Then perhaps your sight is growing dim.', 2947904, 1, 1, 2947903, 0, 0, 0, 0, '', 0, 0),
(2947903, 0, 0, 'By An’she and Mu’sha, yet what of Lo’sho?', 2947906, 1, 1, 2947904, 0, 0, 0, 0, '', 0, 0),
(2947904, 0, 0, 'So to follow Lo’sho is to be granted death by the Moonhoofs.', 2947908, 1, 1, 2947905, 0, 0, 0, 0, '', 0, 0),
(2947905, 0, 0, 'Speak then. Seek my aid once more.', 2947910, 1, 1, 2947906, 0, 0, 0, 0, '', 0, 0),
(2947906, 0, 0, 'Go on.', 2947912, 1, 1, 2947907, 0, 0, 0, 0, '', 0, 0),
(2947907, 0, 0, 'Continue.', 2947914, 1, 1, 2947908, 0, 0, 0, 0, '', 0, 0),
(2947908, 0, 0, 'What was it?', 2947916, 1, 1, 2947909, 0, 0, 0, 0, '', 0, 0),
(2947909, 0, 0, 'Go on.', 2947918, 1, 1, 2947910, 0, 0, 0, 0, '', 0, 0),
(2947910, 0, 0, 'It can’t end there.', 2947920, 1, 1, 2947911, 0, 0, 0, 0, '', 0, 0),
(2947911, 0, 0, 'This barely changes what you did.', 2947922, 1, 1, 2947912, 0, 0, 0, 0, '', 0, 0),
(2947912, 0, 0, 'And how will you be paying, Elder?', 2947924, 1, 1, 2947913, 0, 0, 0, 0, '', 0, 0),
(2947913, 0, 0, 'We will see if that is for you to decide.', 2947926, 1, 1, 2947914, 0, 2947926, 0, 0, '', 0, 0);

INSERT INTO `gossip_scripts`
(
    `id`,
    `delay`,
    `priority`,
    `command`,
    `datalong`,
    `datalong2`,
    `datalong3`,
    `datalong4`,
    `target_param1`,
    `target_param2`,
    `target_type`,
    `data_flags`,
    `dataint`,
    `dataint2`,
    `dataint3`,
    `dataint4`,
    `x`,
    `y`,
    `z`,
    `o`,
    `condition_id`,
    `comments`
)
VALUES
(2947926, 0, 0, 8, 60090, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 42073, 'Facing the Elder - Elder Moonhoof listened');

-- ==============================================
-- FILE: farmer_denphar_quests.sql
-- GENERATED: 20260915075403
-- ==============================================
INSERT INTO `creature_questrelation`
(
    `id`,
    `quest`
)
VALUES
(62922, 41946);

INSERT INTO `creature_involvedrelation`
(
    `id`,
    `quest`
)
VALUES
(62922, 41946);

-- ==============================================
-- FILE: farm_raiders.sql
-- GENERATED: 20260915075403
-- ==============================================
UPDATE `quest_template`
SET `StartScript` = 41946
WHERE `entry` = 41946;

INSERT INTO `creature_template`
(
    `entry`,
    `display_id1`,
    `display_id2`,
    `display_id3`,
    `display_id4`,
    `mount_display_id`,
    `name`,
    `subname`,
    `gossip_menu_id`,
    `level_min`,
    `level_max`,
    `health_min`,
    `health_max`,
    `mana_min`,
    `mana_max`,
    `armor`,
    `faction`,
    `npc_flags`,
    `speed_walk`,
    `speed_run`,
    `scale`,
    `detection_range`,
    `call_for_help_range`,
    `leash_range`,
    `rank`,
    `xp_multiplier`,
    `dmg_min`,
    `dmg_max`,
    `dmg_school`,
    `attack_power`,
    `dmg_multiplier`,
    `base_attack_time`,
    `ranged_attack_time`,
    `unit_class`,
    `unit_flags`,
    `dynamic_flags`,
    `beast_family`,
    `trainer_type`,
    `trainer_spell`,
    `trainer_class`,
    `trainer_race`,
    `ranged_dmg_min`,
    `ranged_dmg_max`,
    `ranged_attack_power`,
    `type`,
    `type_flags`,
    `loot_id`,
    `pickpocket_loot_id`,
    `skinning_loot_id`,
    `holy_res`,
    `fire_res`,
    `nature_res`,
    `frost_res`,
    `shadow_res`,
    `arcane_res`,
    `spell_id1`,
    `spell_id2`,
    `spell_id3`,
    `spell_id4`,
    `spell_list_id`,
    `pet_spell_list_id`,
    `spawn_spell_id`,
    `auras`,
    `gold_min`,
    `gold_max`,
    `ai_name`,
    `movement_type`,
    `inhabit_type`,
    `civilian`,
    `racial_leader`,
    `regeneration`,
    `equipment_id`,
    `trainer_id`,
    `vendor_id`,
    `mechanic_immune_mask`,
    `school_immune_mask`,
    `immunity_flags`,
    `flags_extra`,
    `phase_quest_id`,
    `script_name`
)
VALUES
(63089, 20685, 0, 0, 0, 0, 'Ghin''taru', '', 0, 53, 53, 3507, 3507, 0, 0, 3136, 51, 0, 1, 1.14286, 1.399999976158142, 18, 5, 40, 0, 1, 261.243683, 364.571442, 0, 218, 1, 2000, 2000, 1, 32768, 12, 0, 0, 0, 0, 0, 80.209602, 110.2882, 154, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, 0, 0, 'EventAI', 0, 3, 0, 0, 3, 63089, 0, 0, 0, 0, 0, 0, 0, '');

INSERT INTO `creature_equip_template`
(
    `entry`,
    `equipentry1`,
    `equipentry2`,
    `equipentry3`
)
VALUES
(63089, 12983, 0, 0);

INSERT INTO `broadcast_text`
(
    `entry`,
    `male_text`,
    `female_text`,
    `chat_type`,
    `sound_id`,
    `language_id`,
    `emote_id1`,
    `emote_id2`,
    `emote_id3`,
    `emote_delay1`,
    `emote_delay2`,
    `emote_delay3`
)
VALUES
(6292202, 'They''re coming!', 'They''re coming!', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(6292203, 'Another group, brace yourself!', 'Another group, brace yourself!', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(6292204, 'Look at that brute! This must be their leader!', 'Look at that brute! This must be their leader!', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(6292205, 'We did it! Parash''ka, you are my savior!', 'We did it! Parash''ka, you are my savior!', 0, 0, 0, 0, 0, 0, 0, 0, 0);

INSERT INTO `quest_start_scripts`
(
    `id`,
    `delay`,
    `priority`,
    `command`,
    `datalong`,
    `datalong2`,
    `datalong3`,
    `datalong4`,
    `target_param1`,
    `target_param2`,
    `target_type`,
    `data_flags`,
    `dataint`,
    `dataint2`,
    `dataint3`,
    `dataint4`,
    `x`,
    `y`,
    `z`,
    `o`,
    `condition_id`,
    `comments`
)
VALUES
(41946, 0, 0, 4, 147, 3, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'Farm Raiders - Farmer Denphar Becomes Uninteractible'),
(41946, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6292202, 0, 0, 0, 0, 0, 0, 0, 0, 'Farm Raiders - Farmer Denphar Say 1'),
(41946, 0, 2, 10, 63082, 180000, 0, 0, 0, 0, 0, 0, 2, 0, 6, 10, 6515.681641, -6431.706055, 29.636063, 0.8989319801330566, 0, 'Farm Raiders - Wave 1 Fallen One Raider 1'),
(41946, 0, 3, 10, 63082, 180000, 0, 0, 0, 0, 0, 0, 2, 0, 6, 10, 6511.609863, -6427.594238, 29.776131, 0.7457789778709412, 0, 'Farm Raiders - Wave 1 Fallen One Raider 2'),
(41946, 60, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6292203, 0, 0, 0, 0, 0, 0, 0, 0, 'Farm Raiders - Farmer Denphar Say 2'),
(41946, 60, 1, 10, 63082, 180000, 0, 0, 0, 0, 0, 0, 2, 0, 6, 10, 6515.681641, -6431.706055, 29.636063, 0.8989319801330566, 0, 'Farm Raiders - Wave 2 Fallen One Raider 1'),
(41946, 60, 2, 10, 63082, 180000, 0, 0, 0, 0, 0, 0, 2, 0, 6, 10, 6511.609863, -6427.594238, 29.776131, 0.7457789778709412, 0, 'Farm Raiders - Wave 2 Fallen One Raider 2'),
(41946, 60, 3, 10, 63082, 180000, 0, 0, 0, 0, 0, 0, 2, 0, 6, 10, 6516.873047, -6426.465332, 29.302973, 0.8596619963645935, 0, 'Farm Raiders - Wave 2 Fallen One Raider 3'),
(41946, 120, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6292204, 0, 0, 0, 0, 0, 0, 0, 0, 'Farm Raiders - Farmer Denphar Say 3'),
(41946, 120, 1, 10, 63082, 180000, 0, 0, 0, 0, 0, 0, 2, 0, 6, 10, 6515.681641, -6431.706055, 29.636063, 0.8989319801330566, 0, 'Farm Raiders - Wave 3 Fallen One Raider 1'),
(41946, 120, 2, 10, 63082, 180000, 0, 0, 0, 0, 0, 0, 2, 0, 6, 10, 6511.609863, -6427.594238, 29.776131, 0.7457789778709412, 0, 'Farm Raiders - Wave 3 Fallen One Raider 2'),
(41946, 120, 3, 10, 63089, 180000, 0, 0, 0, 0, 0, 0, 2, 0, 6, 10, 6516.873047, -6426.465332, 29.302973, 0.8596619963645935, 0, 'Farm Raiders - Wave 3 Ghin''taru');

INSERT INTO `creature_ai_events`
(
    `id`,
    `creature_id`,
    `condition_id`,
    `event_type`,
    `event_inverse_phase_mask`,
    `event_chance`,
    `event_flags`,
    `event_param1`,
    `event_param2`,
    `event_param3`,
    `event_param4`,
    `action1_script`,
    `action2_script`,
    `action3_script`,
    `comment`
)
VALUES
(6308901, 63089, 0, 6, 0, 100, 0, 0, 0, 0, 0, 6308901, 0, 0, 'Farm Raiders - Ghin''taru Dies');

INSERT INTO `creature_ai_scripts`
(
    `id`,
    `delay`,
    `priority`,
    `command`,
    `datalong`,
    `datalong2`,
    `datalong3`,
    `datalong4`,
    `target_param1`,
    `target_param2`,
    `target_type`,
    `data_flags`,
    `dataint`,
    `dataint2`,
    `dataint3`,
    `dataint4`,
    `x`,
    `y`,
    `z`,
    `o`,
    `condition_id`,
    `comments`
)
VALUES
(6308901, 0, 0, 0, 0, 0, 0, 0, 62922, 100, 8, 2, 6292205, 0, 0, 0, 0, 0, 0, 0, 0, 'Farm Raiders - Farmer Denphar Victory Say'),
(6308901, 0, 1, 4, 147, 3, 1, 0, 62922, 100, 8, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'Farm Raiders - Farmer Denphar Becomes Interactible');

-- ==============================================
-- FILE: fena_madar_quests.sql
-- GENERATED: 20260915075403
-- ==============================================
INSERT INTO `creature_questrelation`
(
    `id`,
    `quest`
)
VALUES
(62852, 41945);

INSERT INTO `creature_involvedrelation`
(
    `id`,
    `quest`
)
VALUES
(62852, 41945);

-- ==============================================
-- FILE: hamaam_quests.sql
-- GENERATED: 20260915075403
-- ==============================================
INSERT INTO `creature_questrelation`
(
    `id`,
    `quest`
)
VALUES
(63047, 41949);

INSERT INTO `creature_involvedrelation`
(
    `id`,
    `quest`
)
VALUES
(63047, 41947),
(63047, 41948),
(63047, 41949);

-- ==============================================
-- FILE: helhala_quests.sql
-- GENERATED: 20260915075403
-- ==============================================
INSERT INTO `creature_questrelation`
(
    `id`,
    `quest`
)
VALUES
(62851, 41908),
(62851, 41909);

INSERT INTO `creature_involvedrelation`
(
    `id`,
    `quest`
)
VALUES
(62851, 41908),
(62851, 41909),
(62851, 42012);

UPDATE `quest_template`
SET `SpecialFlags` = `SpecialFlags` | 1
WHERE `entry` IN (41908, 41909);

-- ==============================================
-- FILE: homecoming.sql
-- GENERATED: 20260915075403
-- ==============================================
INSERT INTO `creature_involvedrelation`
(
    `id`,
    `quest`
)
VALUES
(91781, 41922);

-- ==============================================
-- FILE: huntmaster_fan_dhera_quests.sql
-- GENERATED: 20260915075403
-- ==============================================
INSERT INTO `creature_questrelation`
(
    `id`,
    `quest`
)
VALUES
(63046, 41944);

-- ==============================================
-- FILE: maghan_quests.sql
-- GENERATED: 20260915075403
-- ==============================================
INSERT INTO `creature_questrelation`
(
    `id`,
    `quest`
)
VALUES
(62994, 41920),
(62994, 41952);

INSERT INTO `creature_involvedrelation`
(
    `id`,
    `quest`
)
VALUES
(62994, 41951);

-- ==============================================
-- FILE: missing_gossips.sql
-- GENERATED: 20260915075403
-- ==============================================
INSERT INTO `broadcast_text`
(
    `entry`,
    `male_text`,
    `female_text`,
    `chat_type`,
    `sound_id`,
    `language_id`,
    `emote_id1`,
    `emote_id2`,
    `emote_id3`,
    `emote_delay1`,
    `emote_delay2`,
    `emote_delay3`
)
VALUES
(62994, 'These brutes are everywhere. I really wish the chieftain would finally do something about it.', 'These brutes are everywhere. I really wish the chieftain would finally do something about it.', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(6305701, 'Alert: Challenger approaches.$B$BProcessing.$B$BTarget has been acknowledged as harmless. Proceed.', 'Alert: Challenger approaches.$B$BProcessing.$B$BTarget has been acknowledged as harmless. Proceed.', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(6306001, 'I have travelled all the way from Sparkwater Port to offer my help to this tribe, and yet they refused to allow me entry into their village. Thankfully, this elder allowed me to rest in his hut. Perhaps he took pity on me, since he too feels like an outsider among them.', 'I have travelled all the way from Sparkwater Port to offer my help to this tribe, and yet they refused to allow me entry into their village. Thankfully, this elder allowed me to rest in his hut. Perhaps he took pity on me, since he too feels like an outsider among them.', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(6305901, 'Another outsider. Come, rest under my roof. I hope you do not mind company. This goblin and his odd companion were refused entry, and so they too were in need of rest.', 'Another outsider. Come, rest under my roof. I hope you do not mind company. This goblin and his odd companion were refused entry, and so they too were in need of rest.', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(6284001, 'Such beauty can be found in this land, but also danger. You must keep your wits about you these days, even when traveling the roads.', 'Such beauty can be found in this land, but also danger. You must keep your wits about you these days, even when traveling the roads.', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(6284601, 'It has been a while since we have seen outsiders venture into Moonwhisper Coast. What brings you to these lands?', 'It has been a while since we have seen outsiders venture into Moonwhisper Coast. What brings you to these lands?', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(6319801, 'Lok''tar. A fine day to spill dragon blood, is it not? You seem uncertain and un eager. Fret not. While I am of the Dragonmaw, I fly my colors with the Horde, under the Scalereaver Warband. Mischief and mayhem may seem to live at our core, but I tell you, wanderer, we are those who raise arms against the stronger inhabitants of Azeroth when the time for action comes.', 'Lok''tar. A fine day to spill dragon blood, is it not? You seem uncertain and un eager. Fret not. While I am of the Dragonmaw, I fly my colors with the Horde, under the Scalereaver Warband. Mischief and mayhem may seem to live at our core, but I tell you, wanderer, we are those who raise arms against the stronger inhabitants of Azeroth when the time for action comes.', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(6298401, 'I can still smell the smoke emanating from Riverhorn Village. It clings to the air, reminding me of that terrible tragedy.', 'I can still smell the smoke emanating from Riverhorn Village. It clings to the air, reminding me of that terrible tragedy.', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(6290201, 'An unexpected visitor. I have not much to offer, but please, let me be as hospitable as I can be. My name is Zarazar Sagewind, from the esteemed capital of magic Dalaran. I know that title may be far-fetched, but our architects are making good strides in restoring our great city to its former glory.$B$BThulio and I journeyed to this coast alongside the Sentinel expedition. Regrettably, they are a bit apprehensive when it comes to those mastering the arcane practices. While they allowed me to accompany them here, they forbade me from resting with them in their base camp. A bit shortsighted, if you ask me, but I am more than capable of fending more myself.$B$BNow then, how may I assist you?','An unexpected visitor. I have not much to offer, but please, let me be as hospitable as I can be. My name is Zarazar Sagewind, from the esteemed capital of magic Dalaran. I know that title may be far-fetched, but our architects are making good strides in restoring our great city to its former glory.$B$BThulio and I journeyed to this coast alongside the Sentinel expedition. Regrettably, they are a bit apprehensive when it comes to those mastering the arcane practices. While they allowed me to accompany them here, they forbade me from resting with them in their base camp. A bit shortsighted, if you ask me, but I am more than capable of fending more myself.$B$BNow then, how may I assist you?', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(6316301, 'Our ancestors have been disturbed. The grounds are no longer a safe place to mourn those who have left us behind.', 'Our ancestors have been disturbed. The grounds are no longer a safe place to mourn those who have left us behind.', 0, 0, 0, 0, 0, 0, 0, 0, 0);

INSERT INTO `gossip_menu`
(
    `entry`,
    `text_id`,
    `script_id`,
    `condition_id`
)
VALUES
(63057, 6305701, 0, 0),
(63059, 6305901, 0, 0),
(63060, 6306001, 0, 0),
(62840, 6284001, 0, 0),
(62846, 6284601, 0, 0),
(63163, 6316301, 0, 0),
(62984, 6298401, 0, 0),
(62902, 6290201, 0, 0),
(63198, 6319801, 0, 0);

INSERT INTO `npc_text`
(
    `ID`,
    `BroadcastTextID0`,
    `Probability0`,
    `BroadcastTextID1`,
    `Probability1`,
    `BroadcastTextID2`,
    `Probability2`,
    `BroadcastTextID3`,
    `Probability3`,
    `BroadcastTextID4`,
    `Probability4`,
    `BroadcastTextID5`,
    `Probability5`,
    `BroadcastTextID6`,
    `Probability6`,
    `BroadcastTextID7`,
    `Probability7`
)
VALUES
(62994, 62994, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0),
(6305701, 6305701, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0),
(6305901, 6305901, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0),
(6306001, 6306001, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0),
(6284001, 6284001, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0),
(6284601, 6284601, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0),
(6316301, 6316301, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0),
(6298401, 6298401, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0),
(6290201, 6290201, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0),
(6319801, 6319801, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0);

UPDATE `creature_template`
SET `gossip_menu_id` = `entry`
WHERE `entry` IN (
    63057, 63059, 63060, 62840, 62846, 63163, 63198, 62984, 62902
    );

-- ==============================================
-- FILE: morogai_kla_quests.sql
-- GENERATED: 20260915075403
-- ==============================================
INSERT INTO `creature_questrelation`
(
    `id`,
    `quest`
)
VALUES
(62850, 41917),
(62850, 41910),
(62850, 41916);

INSERT INTO `creature_involvedrelation`
(
    `id`,
    `quest`
)
VALUES
(62850, 41915),
(62850, 41916);

-- ==============================================
-- FILE: pli_quests.sql
-- GENERATED: 20260915075403
-- ==============================================
INSERT INTO `creature_involvedrelation`
(
    `id`,
    `quest`
)
VALUES
(62854, 41920);

-- ==============================================
-- FILE: powerless_runestones.sql
-- GENERATED: 20260915075403
-- ==============================================
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
(5030836, 2020334, 1, 5719.1298828125, -4828.60986328125, 776.9110107421875, 4.389999866485596, 0, 0, 0.81142883, -0.584451242, 300, 300, 100, 1, 0, 0),
(5030837, 2020334, 1, 5689.93994140625, -4889.1298828125, 798.2659912109375, 3.5213499069213867, 0, 0, 0.98202715, -0.188739704, 300, 300, 100, 1, 0, 0),
(5030838, 2020334, 1, 5708.72021484375, -4943.4501953125, 803.6099853515625, 5.0395097732543945, 0, 0, 0.582529897, -0.812809276, 300, 300, 100, 1, 0, 0),
(5030839, 2020334, 1, 5673.68994140625, -5012.5498046875, 807.1309814453125, 4.206200122833252, 0, 0, 0.861640167, -0.507519676, 300, 300, 100, 1, 0, 0),
(5030840, 2020334, 1, 5664.759765625, -4968.830078125, 806.7069702148438, 1.797379970550537, 0, 0, 0.78251192, 0.622635604, 300, 300, 100, 1, 0, 0),
(5030841, 2020334, 1, 5591.5400390625, -4947.93017578125, 823.2670288085938, 4.064620018005371, 0, 0, 0.895379475, -0.445303937, 300, 300, 100, 1, 0, 0),
(5030842, 2020334, 1, 5536.93017578125, -4977.60009765625, 844.6069946289062, 0.9842849969863892, 0, 0, 0.472515203, 0.881322519, 300, 300, 100, 1, 0, 0),
(5030843, 2020334, 1, 5496.35009765625, -4945.08984375, 849.8359985351562, 2.8303399085998535, 0, 0, 0.987914638, 0.154998932, 300, 300, 100, 1, 0, 0),
(5030844, 2020334, 1, 5570.18017578125, -4883.3798828125, 847.9349975585938, 0.17647600173950195, 0, 0, 0.0881235427, 0.996109553, 300, 300, 100, 1, 0, 0),
(5030845, 2020334, 1, 5478.85986328125, -4926.08984375, 862.9130249023438, 5.825850009918213, 0, 0, 0.226680056, -0.973969277, 300, 300, 100, 1, 0, 0),
(5030846, 2020334, 1, 5721.31982421875, -4993.18017578125, 808.2100219726562, 5.586289882659912, 0, 0, 0.341439218, -0.939903857, 300, 300, 100, 1, 0, 0);

UPDATE `gameobject_template`
SET `flags` = 4,
    `size` = 1.4
WHERE `entry` = 2020334;


-- ==============================================
-- FILE: riftmaster_ralpekta_quests.sql
-- GENERATED: 20260915075403
-- ==============================================
INSERT INTO `creature_questrelation`
(
    `id`,
    `quest`
)
VALUES
(62920, 41913),
(62920, 41953),
(62920, 41914),
(62920, 41951);

INSERT INTO `creature_involvedrelation`
(
    `id`,
    `quest`
)
VALUES
(62920, 41912),
(62920, 41913),
(62920, 41953),
(62920, 41952),
(62920, 41950);

-- ==============================================
-- FILE: the_missing_caravans.sql
-- GENERATED: 20260915075403
-- ==============================================
-- The Missing Caravans (41970)

INSERT INTO `scripted_areatrigger` (`entry`, `script_name`) VALUES
(5660, 'at_moonwhisper_missing_caravans'),
(5661, 'at_moonwhisper_missing_caravans');

-- ==============================================
-- FILE: uztuk_quests.sql
-- GENERATED: 20260915075403
-- ==============================================
INSERT INTO `creature_questrelation`
(
    `id`,
    `quest`
)
VALUES
(62980, 42049),
(62980, 42001);

INSERT INTO `creature_involvedrelation`
(
    `id`,
    `quest`
)
VALUES
(62980, 42050),
(62980, 42001);

-- ==============================================
-- FILE: wolf_in_sheeps_clothing.sql
-- GENERATED: 20260915075403
-- ==============================================
UPDATE `creature_template`
SET `gossip_menu_id` = 6298701
WHERE `entry` = 62987;

INSERT INTO `conditions`
(
    `condition_entry`,
    `type`,
    `value1`,
    `value2`,
    `value3`,
    `value4`,
    `flags`
)
VALUES
(41911, 9, 41911, 1, 0, 0, 0);

UPDATE `broadcast_text`
SET `male_text` = '<The draenei has been beaten and lies motionless on the ground.>',
    `female_text` = '<The draenei has been beaten and lies motionless on the ground.>',
    `chat_type` = 0,
    `sound_id` = 0,
    `language_id` = 0,
    `emote_id1` = 0,
    `emote_id2` = 0,
    `emote_id3` = 0,
    `emote_delay1` = 0,
    `emote_delay2` = 0,
    `emote_delay3` = 0
WHERE `entry` = 6298701;

INSERT INTO `broadcast_text`
(
    `entry`,
    `male_text`,
    `female_text`,
    `chat_type`,
    `sound_id`,
    `language_id`,
    `emote_id1`,
    `emote_id2`,
    `emote_id3`,
    `emote_delay1`,
    `emote_delay2`,
    `emote_delay3`
)
VALUES
(6298702, '<Inspect the hunter''s body>', '<Inspect the hunter''s body>', 0, 0, 0, 0, 0, 0, 0, 0, 0),
(6298703, '<Countless lesions and cuts are strewn about the draenei''s body. His left arm is contorted into an unnatural shape. You can''t discern whether the red trails under his eyes were caused by tears or blood. He fought to the very end.>', '<Countless lesions and cuts are strewn about the draenei''s body. His left arm is contorted into an unnatural shape. You can''t discern whether the red trails under his eyes were caused by tears or blood. He fought to the very end.>', 0, 0, 0, 0, 0, 0, 0, 0, 0);

INSERT INTO `npc_text`
(
    `ID`,
    `BroadcastTextID0`,
    `Probability0`,
    `BroadcastTextID1`,
    `Probability1`,
    `BroadcastTextID2`,
    `Probability2`,
    `BroadcastTextID3`,
    `Probability3`,
    `BroadcastTextID4`,
    `Probability4`,
    `BroadcastTextID5`,
    `Probability5`,
    `BroadcastTextID6`,
    `Probability6`,
    `BroadcastTextID7`,
    `Probability7`
)
VALUES
(6298701, 6298701, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0),
(6298703, 6298703, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0, 0, 0.0);

INSERT INTO `gossip_menu`
(
    `entry`,
    `text_id`,
    `script_id`,
    `condition_id`
)
VALUES
(6298701, 6298701, 0, 0),
(6298702, 6298703, 0, 0);

INSERT INTO `gossip_menu_option`
(
    `menu_id`,
    `id`,
    `option_icon`,
    `option_text`,
    `option_broadcast_text`,
    `option_id`,
    `npc_option_npcflag`,
    `action_menu_id`,
    `action_poi_id`,
    `action_script_id`,
    `box_coded`,
    `box_money`,
    `box_text`,
    `box_broadcast_text`,
    `condition_id`
)
VALUES
(6298701, 0, 0, '<Inspect the hunter''s body>', 6298702, 1, 1, 6298702, 0, 6298702, 0, 0, '', 0, 41911);

INSERT INTO `gossip_scripts`
(
    `id`,
    `delay`,
    `priority`,
    `command`,
    `datalong`,
    `datalong2`,
    `datalong3`,
    `datalong4`,
    `target_param1`,
    `target_param2`,
    `target_type`,
    `data_flags`,
    `dataint`,
    `dataint2`,
    `dataint3`,
    `dataint4`,
    `x`,
    `y`,
    `z`,
    `o`,
    `condition_id`,
    `comments`
)
VALUES
(6298702, 0, 0, 8, 60082, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 41911, 'Wolf in Sheep''s Clothing - Nar''lan found');

INSERT INTO `migrations` (`Name`, `Hash`, `AppliedAt`)
SELECT '20260915075403_world', 'manual', NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `migrations` WHERE `Name` = '20260915075403_world');

-- ############################################################ 20260916091628_world

-- ==============================================
-- FILE: mending_light.sql
-- GENERATED: 20260916091628
-- ==============================================
UPDATE `spell_template`
SET `script_name` = 'spell_paladin_mending_light',
    `effectBonusCoefficient2` = 0.05
WHERE `entry` IN (
    51324, 51875, 51876, 51877, 51878, 51879, 51880, 51881
    );

UPDATE `spell_affect`
SET `SpellFamilyMask` = 137438953472
WHERE `entry` IN (
    51317, 51318, 51319, 51320, 51321
    );
-- ==============================================
-- FILE: zeljeb_text_fix.sql
-- GENERATED: 20260916091628
-- ==============================================
UPDATE `broadcast_text` SET `chat_type` = 1
WHERE `entry` IN (6249501, 6249502, 6249503) AND `chat_type` = 12;

UPDATE `broadcast_text` SET `chat_type` = 0
WHERE `entry` IN (6271501, 6271502) AND `chat_type` = 11;

INSERT INTO `migrations` (`Name`, `Hash`, `AppliedAt`)
SELECT '20260916091628_world', 'manual', NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `migrations` WHERE `Name` = '20260916091628_world');
