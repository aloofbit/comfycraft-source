-- ---------------------------------------------------------------------------
-- 011_henchman_hall.sql -- Hall Steward Corwin (creature 100009), the signboard
-- for the henchman roster created by 010_henchmen.sql.
--
-- WHAT THIS NPC CAN AND CANNOT DO:
--   It cannot invite a bot into your party. None of the core's 94
--   SCRIPT_COMMAND_* opcodes touch groups or invites, so a gossip click can
--   never add a companion. What it does instead is carry the roster: every
--   option shows a companion, their role, and the exact chat line that calls
--   them, and clicking one whispers that line into your chat log so it is
--   still there after the window closes.
--
--   ids: creature 100009 | menus 64018-64022 | npc_text / broadcast_text
--        6400018-6400028 | gossip_scripts 6400200-6400206
--
--   DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_world < sql\custom\011_henchman_hall.sql
--
--   Then, after restarting mangosd:  .npc add 100009
-- ---------------------------------------------------------------------------

DELETE FROM creature_template     WHERE entry   = 100009;
DELETE FROM gossip_menu           WHERE entry   BETWEEN 64018 AND 64022;
DELETE FROM gossip_menu_option    WHERE menu_id BETWEEN 64018 AND 64022;
DELETE FROM npc_text              WHERE ID      BETWEEN 6400018 AND 6400028;
DELETE FROM broadcast_text        WHERE entry   BETWEEN 6400018 AND 6400028;
DELETE FROM gossip_scripts        WHERE id      BETWEEN 6400200 AND 6400206;

-- ---------------------------------------------------------------------------
-- Menu bodies. npc_text carries no inline strings in this core -- every line
-- needs a broadcast_text row and an npc_text row pointing at it.
-- ---------------------------------------------------------------------------
INSERT INTO broadcast_text (entry, male_text, female_text, chat_type, language_id) VALUES
  (6400018,
   'Seven adventurers keep rooms in this hall, and every one of them would rather be underground than here. Say the word and I will send for them.',
   'Seven adventurers keep rooms in this hall, and every one of them would rather be underground than here. Say the word and I will send for them.',
   0, 0),
  (6400019,
   'Here is the register. Speak the line beside a name, anywhere in the world, and they will make their own way to you.',
   'Here is the register. Speak the line beside a name, anywhere in the world, and they will make their own way to you.',
   0, 0),
  (6400020,
   'A companion follows you, fights what you fight, and drinks and heals without being told.$B$B.bot add <name> calls one to your side.$B.bot remove <name> sends them home.$B.bot init <name> re-rolls their gear and talents for level 60.$B.bot gear <name> reports what they are carrying.$B$BOnce one is with you, whisper it orders: follow, stay, attack, flee. Whisper it help for the orders this build understands, or help commands for the whole list.',
   'A companion follows you, fights what you fight, and drinks and heals without being told.$B$B.bot add <name> calls one to your side.$B.bot remove <name> sends them home.$B.bot init <name> re-rolls their gear and talents for level 60.$B.bot gear <name> reports what they are carrying.$B$BOnce one is with you, whisper it orders: follow, stay, attack, flee. Whisper it help for the orders this build understands, or help commands for the whole list.',
   0, 0),
  (6400021,
   'Sooner than speaking seven lines, put them on a button. A macro may hold several lines, and a line that begins with a dot is read by the world as a command rather than as speech. One button for a five-man party:$B$B/s .bot add Stefan$B/s .bot add Alesia$B/s .bot add Aidan$B/s .bot add Thom$B/s .bot add Cynn$B$BMake a second button the same way with .bot remove to send them all home.',
   'Sooner than speaking seven lines, put them on a button. A macro may hold several lines, and a line that begins with a dot is read by the world as a command rather than as speech. One button for a five-man party:$B$B/s .bot add Stefan$B/s .bot add Alesia$B/s .bot add Aidan$B/s .bot add Thom$B/s .bot add Cynn$B$BMake a second button the same way with .bot remove to send them all home.',
   0, 0),
-- Whispered when a register line is clicked, so the command survives closing
-- the window. chat_type here is the broadcast_text default; the whisper is
-- done by the script's datalong (4), not by this field.
  (6400022, 'Stefan holds the line while you work. Speak: .bot add Stefan', 'Stefan holds the line while you work. Speak: .bot add Stefan', 0, 0),
  (6400023, 'Alesia will keep you standing. Speak: .bot add Alesia', 'Alesia will keep you standing. Speak: .bot add Alesia', 0, 0),
  (6400024, 'Mhenlo heals, and can hold if Stefan falls. Speak: .bot add Mhenlo', 'Mhenlo heals, and can hold if Stefan falls. Speak: .bot add Mhenlo', 0, 0),
  (6400025, 'Aidan shoots from the back. Speak: .bot add Aidan', 'Aidan shoots from the back. Speak: .bot add Aidan', 0, 0),
  (6400026, 'Thom works from behind them. Speak: .bot add Thom', 'Thom works from behind them. Speak: .bot add Thom', 0, 0),
  (6400027, 'Cynn burns whatever you point at. Speak: .bot add Cynn', 'Cynn burns whatever you point at. Speak: .bot add Cynn', 0, 0),
  (6400028, 'Eve brings a friend of her own. Speak: .bot add Eve', 'Eve brings a friend of her own. Speak: .bot add Eve', 0, 0);

INSERT INTO npc_text (ID, BroadcastTextID0, Probability0) VALUES
  (6400018, 6400018, 1), (6400019, 6400019, 1),
  (6400020, 6400020, 1), (6400021, 6400021, 1);

-- ---------------------------------------------------------------------------
-- Menus. 64022 is a plain copy of the root used as the Back target: navigating
-- to a creature's own gossip_menu_id is unreliable, because the core re-runs
-- default menu preparation instead of the requested navigation.
-- ---------------------------------------------------------------------------
INSERT INTO gossip_menu (entry, text_id) VALUES
  (64018, 6400018),   -- root (creature default)
  (64019, 6400019),   -- the register
  (64020, 6400020),   -- how to command them
  (64021, 6400021),   -- macros
  (64022, 6400018);   -- root copy, Back target

-- Root, and its copy. Same options, same text.
INSERT INTO gossip_menu_option (menu_id, id, option_icon, option_text, option_id, npc_option_npcflag, action_menu_id) VALUES
  (64018, 0, 0, 'Show me the register.',         1, 1, 64019),
  (64018, 1, 0, 'How do I command a companion?', 1, 1, 64020),
  (64018, 2, 0, 'Can I call them all at once?',  1, 1, 64021),
  (64022, 0, 0, 'Show me the register.',         1, 1, 64019),
  (64022, 1, 0, 'How do I command a companion?', 1, 1, 64020),
  (64022, 2, 0, 'Can I call them all at once?',  1, 1, 64021);

-- The register. Every line sets action_menu_id to its OWN menu as well as a
-- script: an option that runs only a script ends the gossip session, and every
-- later click -- Back included -- is then silently ignored.
--
-- Packet budget: SUM(CHAR_LENGTH(option_text) + 7) = 328, against a ceiling of
-- roughly 490. Past ~512 the client stops parsing options and renders the
-- remainder as quest entries above the menu.
INSERT INTO gossip_menu_option (menu_id, id, option_icon, option_text, option_id, npc_option_npcflag, action_menu_id, action_script_id) VALUES
  (64019, 0, 0, 'Back',                                       1, 1, 64022, 0),
  (64019, 1, 0, 'Tank: Stefan (Warrior) - .bot add Stefan',   1, 1, 64019, 6400200),
  (64019, 2, 0, 'Healer: Alesia (Priest) - .bot add Alesia',  1, 1, 64019, 6400201),
  (64019, 3, 0, 'Healer: Mhenlo (Paladin) - .bot add Mhenlo', 1, 1, 64019, 6400202),
  (64019, 4, 0, 'Ranged: Aidan (Hunter) - .bot add Aidan',    1, 1, 64019, 6400203),
  (64019, 5, 0, 'Melee: Thom (Rogue) - .bot add Thom',        1, 1, 64019, 6400204),
  (64019, 6, 0, 'Caster: Cynn (Mage) - .bot add Cynn',        1, 1, 64019, 6400205),
  (64019, 7, 0, 'Caster: Eve (Warlock) - .bot add Eve',       1, 1, 64019, 6400206);

INSERT INTO gossip_menu_option (menu_id, id, option_icon, option_text, option_id, npc_option_npcflag, action_menu_id) VALUES
  (64020, 0, 0, 'Back', 1, 1, 64022),
  (64021, 0, 0, 'Back', 1, 1, 64022);

-- ---------------------------------------------------------------------------
-- Whisper scripts. command 0 = SCRIPT_COMMAND_TALK, datalong = chat type
-- (0 say, 1 yell, 2 text emote, 4 whisper, 6 zone yell), dataint = the
-- broadcast_text entry. In gossip_scripts the source is the creature and the
-- target is the player, which is what makes a whisper land.
-- ---------------------------------------------------------------------------
INSERT INTO gossip_scripts (id, delay, command, datalong, dataint, comments) VALUES
  (6400200, 0, 0, 4, 6400022, 'Hall Steward Corwin - whisper Stefan call line'),
  (6400201, 0, 0, 4, 6400023, 'Hall Steward Corwin - whisper Alesia call line'),
  (6400202, 0, 0, 4, 6400024, 'Hall Steward Corwin - whisper Mhenlo call line'),
  (6400203, 0, 0, 4, 6400025, 'Hall Steward Corwin - whisper Aidan call line'),
  (6400204, 0, 0, 4, 6400026, 'Hall Steward Corwin - whisper Thom call line'),
  (6400205, 0, 0, 4, 6400027, 'Hall Steward Corwin - whisper Cynn call line'),
  (6400206, 0, 0, 4, 6400028, 'Hall Steward Corwin - whisper Eve call line');

-- ---------------------------------------------------------------------------
-- The steward. npc_flags 1 = gossip only (the 1.12 enum: gossip 1, questgiver
-- 2, vendor 4, trainer 16, repair 16384) -- he sells nothing.
-- ---------------------------------------------------------------------------
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
