-- ---------------------------------------------------------------------------
-- 068_companion_recruiter.sql -- Hall Steward Corwin, rebuilt for companions
-- that are MADE rather than FOUND.
--
-- SUPERSEDES the hiring half of 013_henchman_hall_recruit.sql, and reuses its
-- ids so it replaces rather than duplicates: menus 64018-64022, npc_text and
-- broadcast_text 6400018-6400020, gossip_scripts 6400210-6400216.
--
-- WHAT CHANGED, AND WHY THE WORDS HAD TO. 013 searched the live 300-bot random
-- population for somebody free, of the right role, near your level, and its
-- text promised exactly that -- "I send word to whoever is free and closest to
-- your own standing", "I will not send anyone already travelling with another
-- party", "if nobody suitable is free, I will say so". Every one of those
-- sentences is now false. Companions are created to order at your exact level
-- and deleted when you dismiss them, so nobody is ever unavailable, nobody is
-- poached from another party, and the level is always yours.
--
-- Leaving the old wording would have been worse than no wording: it described
-- a failure mode that can no longer happen and a level gap that no longer
-- exists.
--
--   gossip_scripts.command  = 93   (SCRIPT_COMMAND_RECRUIT_BOT)
--   datalong                = 0 tank, 1 healer, 2 dps, 3 DISMISS ALL
--   datalong2               = class id, 0 = whoever fits the role
--                             (1 warrior, 2 paladin, 3 hunter, 4 rogue, 5 priest,
--                              7 shaman, 8 mage, 9 warlock, 11 druid)
--
-- REQUIRES the patched core. datalong 3 is SO_RECRUIT_DISMISS, added the same
-- day; on an older binary the script fails validation at load with "invalid
-- role datalong = 3" and that one option silently does nothing. datalong2 as a
-- class is 2026-09-08; an older binary reads it as the ignored level window
-- and hands out a random class for the role, which is wrong but harmless.
--
-- 2026-09-08: each role now opens a second page -- "Anyone available" or a
-- class. Paladin and shaman are offered to their own faction only, through the
-- stock conditions rows 3 (Alliance) and 2 (Horde). The click is checked again
-- in the module, which also refuses a class that has no premade build for the
-- role ("A mage is not someone to hold the line").
--
--   Get-Content sql\custom\068_companion_recruiter.sql | `
--     DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_world
--
-- RESTART afterwards, do not reload: broadcast_text is not reloadable and it is
-- where every line of this menu's prose lives. Corwin is creature 100009; if he
-- is not spawned, `.npc add 100009`.
-- ---------------------------------------------------------------------------

DELETE FROM gossip_menu        WHERE entry   BETWEEN 64018 AND 64025;
DELETE FROM gossip_menu_option WHERE menu_id BETWEEN 64018 AND 64025;
DELETE FROM npc_text           WHERE ID      BETWEEN 6400018 AND 6400028;
DELETE FROM broadcast_text     WHERE entry   BETWEEN 6400018 AND 6400028;
DELETE FROM gossip_scripts     WHERE id      BETWEEN 6400210 AND 6400232;

-- ---------------------------------------------------------------------------
-- Menu bodies. npc_text carries no inline strings in this core, so each one
-- needs a broadcast_text row and an npc_text row pointing at it. $B is newline.
-- ---------------------------------------------------------------------------
INSERT INTO broadcast_text (entry, male_text, female_text, chat_type, language_id) VALUES
  (6400018,
   'The hall keeps a roster of hands willing to travel. Tell me what you are short of and I will have someone ready before you reach the door.',
   'The hall keeps a roster of hands willing to travel. Tell me what you are short of and I will have someone ready before you reach the door.',
   0, 0),
  (6400019,
   'Say the word and I will have them meet you outside.',
   'Say the word and I will have them meet you outside.',
   0, 0),
  (6400020,
   'Whoever you ask for is found, equipped and sent out to meet you at your own standing -- never above it, never below. There is no waiting list and nobody is ever spoken for.$B$BThey will follow you, fight what you fight, and see to their own eating and drinking. Whisper one an order if you want something particular: follow, stay, attack, flee. Whisper it help for the rest.$B$BTwo at a time is the most I will spare you, and a full party of five leaves no room for any. Send them home when you are done and I will find them other work.',
   'Whoever you ask for is found, equipped and sent out to meet you at your own standing -- never above it, never below. There is no waiting list and nobody is ever spoken for.$B$BThey will follow you, fight what you fight, and see to their own eating and drinking. Whisper one an order if you want something particular: follow, stay, attack, flee. Whisper it help for the rest.$B$BTwo at a time is the most I will spare you, and a full party of five leaves no room for any. Send them home when you are done and I will find them other work.',
   0, 0),
  (6400021,
   'Anyone in particular, or whoever is nearest to hand?',
   'Anyone in particular, or whoever is nearest to hand?',
   0, 0);

INSERT INTO npc_text (ID, BroadcastTextID0, Probability0) VALUES
  (6400018, 6400018, 1), (6400019, 6400019, 1), (6400020, 6400020, 1),
  (6400021, 6400021, 1);

-- ---------------------------------------------------------------------------
-- Menus. 64022 is a plain copy of the root, used as the Back target: navigating
-- to a creature's own gossip_menu_id is unreliable, because the core re-runs
-- default menu preparation instead of the requested navigation.
-- ---------------------------------------------------------------------------
INSERT INTO gossip_menu (entry, text_id) VALUES
  (64018, 6400018),   -- root (creature default)
  (64019, 6400019),   -- hiring
  (64020, 6400020),   -- how it works
  (64022, 6400018),   -- root copy, Back target
  (64023, 6400021),   -- tank: anyone, or a class
  (64024, 6400021),   -- healer: anyone, or a class
  (64025, 6400021);   -- dps: anyone, or a class

INSERT INTO gossip_menu_option (menu_id, id, option_icon, option_text, option_id, npc_option_npcflag, action_menu_id) VALUES
  (64018, 0, 0, 'I am looking for company.', 1, 1, 64019),
  (64018, 1, 0, 'How does this work?',       1, 1, 64020),
  (64022, 0, 0, 'I am looking for company.', 1, 1, 64019),
  (64022, 1, 0, 'How does this work?',       1, 1, 64020),
  (64020, 0, 0, 'Back',                      1, 1, 64022);

-- Dismiss on the ROOT as well as the hiring page. Sending everyone home is the
-- other thing you come to Corwin for, and burying it one click inside "I am
-- looking for company" put it behind the opposite intention.
--
-- action_menu_id is 64022 (the root COPY), never 64018: navigating to a
-- creature's own gossip_menu_id is unreliable, because the core re-runs default
-- menu preparation instead of the requested navigation. 64022 renders the same
-- page and comes back cleanly, which is why it exists at all.
--
-- Root packet budget after this: 89 bytes against a ceiling of roughly 490.
INSERT INTO gossip_menu_option (menu_id, id, option_icon, option_text, option_id, npc_option_npcflag, action_menu_id, action_script_id) VALUES
  (64018, 2, 0, 'Send my companions home.', 1, 1, 64022, 6400216),
  (64022, 2, 0, 'Send my companions home.', 1, 1, 64022, 6400216);

-- The hiring page. Every option sets action_menu_id to its OWN menu as well as
-- a script: an option that runs only a script ends the gossip session, and every
-- later click -- Back included -- is then silently ignored. That is what makes
-- this page repeatable, so hire, hire and dismiss are three clicks without
-- re-opening him.
--
-- The three single-role options open a class page (64023-64025) instead of
-- hiring on the spot; the pair and the dismissal still act here.
--
-- Packet budget: SUM(CHAR_LENGTH(option_text) + 7) = 165, against a ceiling of
-- roughly 490. Past ~512 the client stops parsing options and renders the
-- remainder as quest entries above the menu.
INSERT INTO gossip_menu_option (menu_id, id, option_icon, option_text, option_id, npc_option_npcflag, action_menu_id, action_script_id) VALUES
  (64019, 0, 0, 'Back',                              1, 1, 64022, 0),
  (64019, 1, 0, 'I need someone to hold the line.',  1, 1, 64023, 0),
  (64019, 2, 0, 'I need a healer.',                  1, 1, 64024, 0),
  (64019, 3, 0, 'I need someone who hits hard.',     1, 1, 64025, 0),
  (64019, 4, 0, 'A tank and a healer, both.',        1, 1, 64019, 6400213),
  (64019, 5, 0, 'Send my companions home.',          1, 1, 64019, 6400216);

-- The class pages. Only classes with a premade build for the role are listed,
-- read off aiplayerbot.conf's PremadeSpecName rows and AiFactory::GetPlayerRoles:
-- tank = warrior, paladin, druid (feral); healer = priest, paladin, druid,
-- shaman; dps = everyone but the pure healers' healing trees. Paladin carries
-- condition 3 (Alliance) and shaman condition 2 (Horde), the stock team rows,
-- so the other side never sees them.
--
-- Every hire sends you back to the hiring page (action_menu_id 64019), which is
-- where the next thing you want is.
--
-- Packet budgets: 64023 = 84, 64024 = 101, 64025 = 189.
INSERT INTO gossip_menu_option (menu_id, id, option_icon, option_text, option_id, npc_option_npcflag, action_menu_id, action_script_id, condition_id) VALUES
  (64023, 0, 0, 'Back',              1, 1, 64019, 0,       0),
  (64023, 1, 0, 'Anyone available.', 1, 1, 64019, 6400210, 0),
  (64023, 2, 0, 'A warrior.',        1, 1, 64019, 6400217, 0),
  (64023, 3, 0, 'A paladin.',        1, 1, 64019, 6400218, 3),
  (64023, 4, 0, 'A druid.',          1, 1, 64019, 6400219, 0),

  (64024, 0, 0, 'Back',              1, 1, 64019, 0,       0),
  (64024, 1, 0, 'Anyone available.', 1, 1, 64019, 6400211, 0),
  (64024, 2, 0, 'A priest.',         1, 1, 64019, 6400220, 0),
  (64024, 3, 0, 'A paladin.',        1, 1, 64019, 6400221, 3),
  (64024, 4, 0, 'A druid.',          1, 1, 64019, 6400222, 0),
  (64024, 5, 0, 'A shaman.',         1, 1, 64019, 6400223, 2),

  (64025, 0, 0, 'Back',              1, 1, 64019, 0,       0),
  (64025, 1, 0, 'Anyone available.', 1, 1, 64019, 6400212, 0),
  (64025, 2, 0, 'A warrior.',        1, 1, 64019, 6400224, 0),
  (64025, 3, 0, 'A rogue.',          1, 1, 64019, 6400225, 0),
  (64025, 4, 0, 'A hunter.',         1, 1, 64019, 6400226, 0),
  (64025, 5, 0, 'A mage.',           1, 1, 64019, 6400227, 0),
  (64025, 6, 0, 'A warlock.',        1, 1, 64019, 6400228, 0),
  (64025, 7, 0, 'A priest.',         1, 1, 64019, 6400229, 0),
  (64025, 8, 0, 'A druid.',          1, 1, 64019, 6400230, 0),
  (64025, 9, 0, 'A paladin.',        1, 1, 64019, 6400231, 3),
  (64025, 10, 0, 'A shaman.',        1, 1, 64019, 6400232, 2);

-- ---------------------------------------------------------------------------
-- The scripts. datalong2 is 0 everywhere now: it was the level-search window
-- and there is no search left to bound.
--
-- 6400213 is two rows under one id -- gossip_scripts has no primary key and the
-- core runs every row for the id, which is how one click hires a pair. Two, not
-- four as 013 did, because the per-player cap is two; a third would be refused
-- in chat and read as a bug.
--
-- The delay staggers the second arrival. It is in SECONDS, and one is enough:
-- each hire is a character creation on the world thread (~143 ms measured), so
-- back-to-back is a visible hitch rather than a problem.
-- ---------------------------------------------------------------------------
INSERT INTO gossip_scripts (id, delay, command, datalong, datalong2, comments) VALUES
  (6400210, 0, 93, 0, 0, 'Corwin - hire a tank at the player level'),
  (6400211, 0, 93, 1, 0, 'Corwin - hire a healer at the player level'),
  (6400212, 0, 93, 2, 0, 'Corwin - hire a dps at the player level'),

  (6400213, 0, 93, 0, 0, 'Corwin - hire a pair: tank'),
  (6400213, 1, 93, 1, 0, 'Corwin - hire a pair: healer'),

  (6400216, 0, 93, 3, 0, 'Corwin - dismiss every companion (SO_RECRUIT_DISMISS)'),

  -- A named class: datalong2 is the class id.
  (6400217, 0, 93, 0, 1,  'Elowen - tank: warrior'),
  (6400218, 0, 93, 0, 2,  'Elowen - tank: paladin'),
  (6400219, 0, 93, 0, 11, 'Elowen - tank: druid'),

  (6400220, 0, 93, 1, 5,  'Elowen - healer: priest'),
  (6400221, 0, 93, 1, 2,  'Elowen - healer: paladin'),
  (6400222, 0, 93, 1, 11, 'Elowen - healer: druid'),
  (6400223, 0, 93, 1, 7,  'Elowen - healer: shaman'),

  (6400224, 0, 93, 2, 1,  'Elowen - dps: warrior'),
  (6400225, 0, 93, 2, 4,  'Elowen - dps: rogue'),
  (6400226, 0, 93, 2, 3,  'Elowen - dps: hunter'),
  (6400227, 0, 93, 2, 8,  'Elowen - dps: mage'),
  (6400228, 0, 93, 2, 9,  'Elowen - dps: warlock'),
  (6400229, 0, 93, 2, 5,  'Elowen - dps: priest'),
  (6400230, 0, 93, 2, 11, 'Elowen - dps: druid'),
  (6400231, 0, 93, 2, 2,  'Elowen - dps: paladin'),
  (6400232, 0, 93, 2, 7,  'Elowen - dps: shaman');

-- ---------------------------------------------------------------------------
-- Corwin is re-stated here so this file stands alone. npc_flags 1 = gossip only.
-- 2026-09-08: Deliana's model (15965) and Runeblade of Baron Rivendare (13505)
-- in hand, through creature_equip_template row 100009. Equipment templates are
-- read once at startup, so the weapon needs a restart; the rest reloads.
-- ---------------------------------------------------------------------------
DELETE FROM creature_template WHERE entry = 100009;
INSERT INTO creature_template
  (entry, name, subname, display_id1, faction, npc_flags, gossip_menu_id,
   level_min, level_max, health_min, health_max, armor, unit_class, type,
   speed_walk, speed_run, scale, base_attack_time, ranged_attack_time,
   dmg_min, dmg_max, movement_type, inhabit_type, regeneration, ai_name,
   equipment_id)
VALUES
  (100009, 'Helper Elowen', 'Helping Hands', 15965, 35, 1, 64018,
   60, 60, 4007, 4007, 3272, 1, 7,
   1, 1.14286, 1, 2000, 2000,
   103.4, 129.8, 0, 3, 3, '',
   100009);

DELETE FROM creature_equip_template WHERE entry = 100009;
INSERT INTO creature_equip_template (entry, equipentry1, equipentry2, equipentry3)
VALUES (100009, 13505, 0, 0);

-- The blade stays on her back: sheath_state 0 in creature_addon, which is keyed by
-- spawn guid rather than entry. Her spawns were placed by hand with .npc add and
-- are not in any file, so this takes whatever spawns exist. Read once at startup.
DELETE FROM creature_addon WHERE guid IN (SELECT guid FROM creature WHERE id = 100009);
INSERT INTO creature_addon (guid, sheath_state)
  SELECT guid, 0 FROM creature WHERE id = 100009;

-- ---------------------------------------------------------------------------
SELECT menu_id, COUNT(*) AS options, SUM(CHAR_LENGTH(option_text) + 7) AS packet_bytes
  FROM gossip_menu_option WHERE menu_id BETWEEN 64018 AND 64025 GROUP BY menu_id;
SELECT id, COUNT(*) AS steps FROM gossip_scripts WHERE id BETWEEN 6400210 AND 6400232 GROUP BY id;
