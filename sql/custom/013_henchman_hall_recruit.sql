-- ---------------------------------------------------------------------------
-- 013_henchman_hall_recruit.sql -- Hall Steward Corwin, rebuilt around
-- SCRIPT_COMMAND_RECRUIT_BOT (93).
--
-- SUPERSEDES the static roster: 011 made Corwin a signboard listing seven fixed
-- names because no script command could build a group. Command 93 now can, so
-- clicking an option actually hires somebody. 010_henchmen.sql (the seven
-- conscripted characters) and 012_henchman_guild.sql are both obsolete --
-- 014_release_henchmen.sql hands those characters back.
--
-- REQUIRES the patched core: comfy-wow branch comfy-recruit-bot, commit 5b67f28.
-- On a stock binary command 93 does not exist, the script fails validation at
-- load with "unknown command 93", and every option silently does nothing.
--
--   gossip_scripts.command  = 93
--   datalong                = role: 0 tank, 1 healer, 2 dps
--   datalong2               = level tolerance either side of the player,
--                             0 = any level
--
-- The companion is pulled from the live random-bot population -- 300 of them
-- out questing, running dungeons and battlegrounds -- and summoned from
-- wherever they are. Nothing is account-bound and nothing is reserved.
--
--   DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_world < sql\custom\013_henchman_hall_recruit.sql
--
-- Restart mangosd afterwards: gossip menus and creature_template are cached at
-- startup. Corwin is creature 100009; if he is not spawned yet, .npc add 100009
-- ---------------------------------------------------------------------------

DELETE FROM gossip_menu        WHERE entry   BETWEEN 64018 AND 64022;
DELETE FROM gossip_menu_option WHERE menu_id BETWEEN 64018 AND 64022;
DELETE FROM npc_text           WHERE ID      BETWEEN 6400018 AND 6400028;
DELETE FROM broadcast_text     WHERE entry   BETWEEN 6400018 AND 6400028;
DELETE FROM gossip_scripts     WHERE id      BETWEEN 6400200 AND 6400215;

-- ---------------------------------------------------------------------------
-- Menu bodies. npc_text carries no inline strings in this core, so each one
-- needs a broadcast_text row and an npc_text row pointing at it. $B is the
-- newline escape.
-- ---------------------------------------------------------------------------
INSERT INTO broadcast_text (entry, male_text, female_text, chat_type, language_id) VALUES
  (6400018,
   'Adventurers pass through here at all hours, and most of them are between jobs whether they admit it or not. Tell me what you are short of and I will find someone.',
   'Adventurers pass through here at all hours, and most of them are between jobs whether they admit it or not. Tell me what you are short of and I will find someone.',
   0, 0),
  (6400019,
   'Say the word and I will send for them, wherever they have got to.',
   'Say the word and I will send for them, wherever they have got to.',
   0, 0),
  (6400020,
   'I send word to whoever is free and closest to your own standing, and they come to you directly -- from the far side of the world if that is where they happen to be.$B$BThey will follow you, fight what you fight, and look after their own eating and drinking. Whisper one an order if you want it to do something particular: follow, stay, attack, flee. Whisper it help for the rest.$B$BI will not send anyone already travelling with another party. If nobody suitable is free, I will say so -- ask again in a while, or ask for a different sort.',
   'I send word to whoever is free and closest to your own standing, and they come to you directly -- from the far side of the world if that is where they happen to be.$B$BThey will follow you, fight what you fight, and look after their own eating and drinking. Whisper one an order if you want it to do something particular: follow, stay, attack, flee. Whisper it help for the rest.$B$BI will not send anyone already travelling with another party. If nobody suitable is free, I will say so -- ask again in a while, or ask for a different sort.',
   0, 0);

INSERT INTO npc_text (ID, BroadcastTextID0, Probability0) VALUES
  (6400018, 6400018, 1), (6400019, 6400019, 1), (6400020, 6400020, 1);

-- ---------------------------------------------------------------------------
-- Menus. 64022 is a plain copy of the root, used as the Back target: navigating
-- to a creature's own gossip_menu_id is unreliable, because the core re-runs
-- default menu preparation instead of the requested navigation.
-- ---------------------------------------------------------------------------
INSERT INTO gossip_menu (entry, text_id) VALUES
  (64018, 6400018),   -- root (creature default)
  (64019, 6400019),   -- hiring
  (64020, 6400020),   -- how it works
  (64022, 6400018);   -- root copy, Back target

INSERT INTO gossip_menu_option (menu_id, id, option_icon, option_text, option_id, npc_option_npcflag, action_menu_id) VALUES
  (64018, 0, 0, 'I am looking for company.', 1, 1, 64019),
  (64018, 1, 0, 'How does this work?',       1, 1, 64020),
  (64022, 0, 0, 'I am looking for company.', 1, 1, 64019),
  (64022, 1, 0, 'How does this work?',       1, 1, 64020),
  (64020, 0, 0, 'Back',                      1, 1, 64022);

-- The hiring page. Every option sets action_menu_id to its OWN menu as well as
-- a script: an option that runs only a script ends the gossip session, and every
-- later click -- Back included -- is then silently ignored. That is what makes
-- this page repeatable, so you can hire four companions with four clicks.
--
-- Packet budget: SUM(CHAR_LENGTH(option_text) + 7) = 300, against a ceiling of
-- roughly 490. Past ~512 the client stops parsing options and renders the
-- remainder as quest entries above the menu.
INSERT INTO gossip_menu_option (menu_id, id, option_icon, option_text, option_id, npc_option_npcflag, action_menu_id, action_script_id) VALUES
  (64019, 0, 0, 'Back',                              1, 1, 64022, 0),
  (64019, 1, 0, 'I need someone to hold the line.',  1, 1, 64019, 6400210),
  (64019, 2, 0, 'I need a healer.',                  1, 1, 64019, 6400211),
  (64019, 3, 0, 'I need someone who hits hard.',     1, 1, 64019, 6400212),
  (64019, 4, 0, 'Fill out my party.',                1, 1, 64019, 6400213),
  (64019, 5, 0, 'A tank, any level.',                1, 1, 64019, 6400214),
  (64019, 6, 0, 'A healer, any level.',              1, 1, 64019, 6400215);

-- ---------------------------------------------------------------------------
-- The recruitment scripts. Tolerance 5 keeps a level 20 from being handed a
-- level 60 who trivialises everything; the two "any level" options pass 0.
--
-- 6400213 is four rows under one id -- gossip_scripts has no primary key and
-- the core runs every row for the id, which is how one click fills a party.
-- The delays stagger the arrivals so four people do not land on your head at
-- once; they are seconds.
-- ---------------------------------------------------------------------------
INSERT INTO gossip_scripts (id, delay, command, datalong, datalong2, comments) VALUES
  (6400210, 0, 93, 0, 5, 'Hall Steward Corwin - recruit tank near player level'),
  (6400211, 0, 93, 1, 5, 'Hall Steward Corwin - recruit healer near player level'),
  (6400212, 0, 93, 2, 5, 'Hall Steward Corwin - recruit dps near player level'),

  (6400213, 0, 93, 0, 5, 'Hall Steward Corwin - fill party: tank'),
  (6400213, 1, 93, 1, 5, 'Hall Steward Corwin - fill party: healer'),
  (6400213, 2, 93, 2, 5, 'Hall Steward Corwin - fill party: first dps'),
  (6400213, 3, 93, 2, 5, 'Hall Steward Corwin - fill party: second dps'),

  (6400214, 0, 93, 0, 0, 'Hall Steward Corwin - recruit tank, any level'),
  (6400215, 0, 93, 1, 0, 'Hall Steward Corwin - recruit healer, any level');

-- ---------------------------------------------------------------------------
-- Corwin himself. npc_flags 1 = gossip only (1.12 enum: gossip 1, questgiver 2,
-- vendor 4, trainer 16, repair 16384) -- he sells nothing.
-- ---------------------------------------------------------------------------
DELETE FROM creature_template WHERE entry = 100009;
INSERT INTO creature_template
  (entry, name, subname, display_id1, faction, npc_flags, gossip_menu_id,
   level_min, level_max, health_min, health_max, armor, unit_class, type,
   speed_walk, speed_run, scale, base_attack_time, ranged_attack_time,
   dmg_min, dmg_max, movement_type, inhabit_type, regeneration, ai_name)
VALUES
  (100009, 'Hall Steward Corwin', 'Hall of Companions', 1985, 35, 1, 64018,
   60, 60, 4007, 4007, 3272, 1, 7,
   1, 1.14286, 1, 2000, 2000,
   103.4, 129.8, 0, 3, 3, '');

-- ---------------------------------------------------------------------------
SELECT menu_id, COUNT(*) AS options, SUM(CHAR_LENGTH(option_text) + 7) AS packet_bytes
  FROM gossip_menu_option WHERE menu_id BETWEEN 64018 AND 64022 GROUP BY menu_id;
SELECT id, COUNT(*) AS steps FROM gossip_scripts WHERE id BETWEEN 6400210 AND 6400215 GROUP BY id;
