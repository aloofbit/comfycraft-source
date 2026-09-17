-- ============================================================================
--  The greeting on a critter's menu                                (tw_world)
-- ============================================================================
--  Right-clicking an animal in your own house opens a menu. The menu itself is
--  built entirely in code -- GossipMenu::AddMenuItem plus SendGossipMenu, the
--  same way every housing gear page is -- so there is no gossip_menu row, no
--  gossip_menu_option row, no npc_option_npcflag trap and no ~490-byte ceiling.
--
--  THE GREETING IS THE ONE ROW A CODE-BUILT MENU STILL COSTS, because
--  SendGossipMenu takes an npc_text id rather than a string. And npc_text has
--  no inline text in this core -- only a BroadcastTextID reference -- so it is
--  two rows, not one.
--
--    Get-Content sql\custom\060_critter_menu.sql | DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_world
--
--  IT NEEDS A RESTART, and this is the one ordering fact worth knowing here:
--  broadcast_text has NO reload. `.reload` cannot pick it up, so the title is
--  blank -- or the menu simply does not open -- until mangosd is restarted.
--  Harmless if applied early, and harmless if applied late; only the wording
--  waits.
--
--  6400030-6400038 are taken (the gear pages, claiming, storage, settings);
--  the block runs to 6400050.
-- ============================================================================

DELETE FROM npc_text       WHERE ID    = 6400039;
DELETE FROM broadcast_text WHERE entry = 6400039;

--  Deliberately not "What would you like to do?" like the furniture pages. You
--  are looking at an animal, and the housing voice is warm where it can afford
--  to be -- this is the one menu in the feature that is about something alive.
INSERT INTO broadcast_text (entry, male_text, female_text, chat_type, language_id) VALUES
(6400039, 'It looks up at you.', 'It looks up at you.', 0, 0);

INSERT INTO npc_text (ID, BroadcastTextID0, Probability0) VALUES
(6400039, 6400039, 1);

-- ----------------------------------------------------------------------------
-- ROLLBACK
--
-- DELETE FROM npc_text       WHERE ID    = 6400039;
-- DELETE FROM broadcast_text WHERE entry = 6400039;
-- ----------------------------------------------------------------------------
