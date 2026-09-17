-- ============================================================================
--  Mordrin the Marked -- hands out Invader's Sigils  (tw_world)
-- ============================================================================
--  Answers the one question invasions shipped without: how anybody gets a
--  sigil. Until now it was `.additem 100035`, which is not a way for a player
--  to get anything.
--
--  HE GIVES IT AWAY FREE, and that is a decision rather than a placeholder.
--  The sigil is not loot or a reward -- it is the button the whole feature
--  hangs off, and a price on it would only mean the feature does not exist for
--  anyone below the price. It is soulbound and max_count = 1, so one is all
--  anybody can hold. If a cost is ever wanted, it is datalong3 on the script
--  row below, in copper, and nothing else changes.
--
--  NO C++. SCRIPT_COMMAND_CREATE_ITEM (17) does the handing over, driven from
--  gossip_menu_option.action_script_id -> gossip_scripts. datalong is the item,
--  datalong2 the count, datalong3 an optional cost.
--
--  THE OPTION HIDES ITSELF once you have one, rather than failing when you
--  click it. conditions type 2 is "player has this item", and flags = 1 is
--  CONDITION_FLAG_REVERSE_RESULT -- so the row reads "has no sigil". Without it
--  a second click hits max_count and refuses with an inventory error, which
--  tells the player nothing about why.
--
--  FACTION 35, friendly to everyone, so both sides can talk to him. On a server
--  where Alliance and Horde are not at war, a faction-locked quartermaster for
--  the cross-faction PvP feature would be a joke at its own expense.
--
--  WHAT RELOADS AND WHAT DOES NOT:
--    reload creature_template, gossip_menu, gossip_menu_option,
--    gossip_scripts, conditions, npc_text   -- all live.
--    broadcast_text                         -- NOT reloadable. The greeting
--    below needs a restart to appear; everything else works before it.
--    Reload creature_template FIRST if he is new to the running server.
--
--  HE IS NOT SPAWNED HERE. Place him where you want him with
--  `.npc add 100031` -- the same way Helper Elowen (100009) and the rest were
--  placed. Spawns live in the `creature` table keyed by guid, not in this file.
--
--  ENTRY 100031 IS THE NEXT FREE ONE. CLAUDE.md says 100029; that was true
--  before Sister Wren (100029) and Wren's Apprentice (100030) took it.
-- ============================================================================

-- ---------------------------------------------------------------------------
--  What he says. npc_text carries no inline strings in this core, so each body
--  needs a broadcast_text row and an npc_text row pointing at it. $B is newline.
-- ---------------------------------------------------------------------------
DELETE FROM broadcast_text WHERE entry = 6400041;
INSERT INTO broadcast_text (entry, male_text, female_text, chat_type, language_id) VALUES
  (6400041,
   'You have the look of someone who is owed a fight.$B$BTake a sigil. Burn it when you are ready and it will find you somebody near your own strength -- flagged, willing, and somewhere far from here. It puts you at their back. Not them at yours.$B$BWhat happens after that is between the two of you.',
   '', 0, 0);

DELETE FROM npc_text WHERE ID = 6400041;
INSERT INTO npc_text (ID, BroadcastTextID0, Probability0) VALUES (6400041, 6400041, 1);

-- ---------------------------------------------------------------------------
--  The menu, and the one option on it.
-- ---------------------------------------------------------------------------
DELETE FROM gossip_menu        WHERE entry   = 64030;
DELETE FROM gossip_menu_option WHERE menu_id = 64030;

INSERT INTO gossip_menu (entry, text_id) VALUES (64030, 6400041);

INSERT INTO gossip_menu_option
  (menu_id, id, option_icon, option_text, option_id, npc_option_npcflag,
   action_script_id, condition_id)
VALUES
  (64030, 0, 0, 'Give me a sigil.', 1, 1, 6400241, 6400041);

-- ---------------------------------------------------------------------------
--  "Has no Invader's Sigil". Type 2 is the has-item check; flags = 1 is
--  CONDITION_FLAG_REVERSE_RESULT, which turns it into has-NOT.
-- ---------------------------------------------------------------------------
DELETE FROM conditions WHERE condition_entry = 6400041;
INSERT INTO conditions (condition_entry, type, value1, value2, value3, value4, flags)
VALUES (6400041, 2, 100035, 1, 0, 0, 1);

-- ---------------------------------------------------------------------------
--  The hand-over. datalong3 = 0 is free; put copper there for a price.
-- ---------------------------------------------------------------------------
DELETE FROM gossip_scripts WHERE id = 6400241;
INSERT INTO gossip_scripts (id, delay, command, datalong, datalong2, datalong3, comments)
VALUES (6400241, 0, 17, 100035, 1, 0, 'Invasions: give one Invader''s Sigil');

-- ---------------------------------------------------------------------------
--  The man himself. Display 2873 is the Twilight Disciple -- hooded, robed,
--  and nobody's idea of a quartermaster. unit_class/type/speed and the rest are
--  copied from Helper Elowen (sql/custom/068) because they are the values a
--  standing, non-combat gossip NPC wants and there is no reason to differ.
-- ---------------------------------------------------------------------------
DELETE FROM creature_template WHERE entry = 100031;
INSERT INTO creature_template
  (entry, name, subname, display_id1, faction, npc_flags, gossip_menu_id,
   level_min, level_max, health_min, health_max, armor, unit_class, type,
   speed_walk, speed_run, scale, base_attack_time, ranged_attack_time,
   dmg_min, dmg_max, movement_type, inhabit_type, regeneration, ai_name)
VALUES
  (100031, 'Mordrin the Marked', 'Invasions', 2873, 35, 1, 64030,
   60, 60, 4007, 4007, 3272, 1, 7,
   1, 1.14286, 1, 2000, 2000,
   103.4, 129.8, 0, 3, 3, '');
