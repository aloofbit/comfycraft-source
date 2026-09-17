-- ============================================================================
--  The settings page on the exit gear: its title  (tw_world)
-- ============================================================================
--  The housing menus are built entirely in code -- no gossip_menu row out of
--  the nearly-full smallint space, no option rows, no ~490-byte ceiling. The
--  one thing that route still cannot do is name a page: SendGossipMenu takes an
--  npc_text id rather than a string, so every page title is a row here.
--
--  6400038 is the settings page under the control panel on the way out.
--  6400033/6400034 are that panel and its confirm; 6400030 and 6400035-6400037
--  are the furniture edit menu (sql/custom/049). The block is free from 6400039
--  to 6400050.
--
--  NEEDS A RESTART, not a reload: broadcast_text is one of the two tables with
--  no `.reload` subcommand. Apply it before swapping the binary in and the
--  restart the swap needs anyway covers both.
--
--  Re-runnable.
--
--  Apply with:
--    Get-Content sql\custom\051_house_settings_text.sql | DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_world
-- ============================================================================

DELETE FROM npc_text       WHERE ID    = 6400038;
DELETE FROM broadcast_text WHERE entry = 6400038;

INSERT INTO broadcast_text (entry, male_text, female_text, chat_type, language_id) VALUES
(6400038, 'How would you like this to work?', 'How would you like this to work?', 0, 0);

INSERT INTO npc_text (ID, BroadcastTextID0, Probability0) VALUES
(6400038, 6400038, 1);

-- ----------------------------------------------------------------------------
-- ROLLBACK
--
-- DELETE FROM npc_text       WHERE ID    = 6400038;
-- DELETE FROM broadcast_text WHERE entry = 6400038;
-- ----------------------------------------------------------------------------
