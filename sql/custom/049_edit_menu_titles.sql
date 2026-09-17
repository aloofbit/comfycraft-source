-- ============================================================================
--  A title on every page of the edit menu  (tw_world)
-- ============================================================================
--  The four pages of the furniture menu all greeted you with npc_text 6400030,
--  "Which way shall it go?" -- written when there was only a move page, and
--  wrong on three of the four ever since. A menu whose header says the same
--  thing everywhere is a menu with no header.
--
--  SendGossipMenu TAKES AN ID, NOT A STRING, which is why this is SQL at all.
--  The whole rest of the menu is built in code -- GossipMenu::AddMenuItem, no
--  gossip_menu or gossip_menu_option rows anywhere -- and the greeting is the
--  one unavoidable row. Four pages, four ids.
--
--  npc_text has no inline strings in this core; it only points at
--  broadcast_text. So each title needs a row in both.
--
--  NOT RELOADABLE. `reload npc_text` exists, broadcast_text has no reload, so
--  the titles appear only after a restart. Harmless if applied early: until the
--  binary knows the new ids it keeps asking for 6400030, which still exists and
--  now reads "What would you like to do?" -- correct for the main page, which
--  is the page it was always sent from.
--
--  Ids: 6400030 is retitled in place; 6400035-6400037 are new. 6400031-6400034
--  are the portal, claim and storage menus; the block is free from 6400038 to
--  6400050.
-- ----------------------------------------------------------------------------

DELETE FROM npc_text       WHERE ID    IN (6400035, 6400036, 6400037);
DELETE FROM broadcast_text WHERE entry IN (6400035, 6400036, 6400037);

-- The main page. Retitled rather than renumbered: the binary has always sent
-- 6400030 for this page, so the old id keeps its old job and only its wording
-- changes.
UPDATE broadcast_text
   SET male_text   = 'What would you like to do?',
       female_text = 'What would you like to do?'
 WHERE entry = 6400030;

INSERT INTO broadcast_text (entry, male_text, female_text, chat_type, language_id) VALUES
(6400035, 'Move the object',   'Move the object',   0, 0),
(6400036, 'Turn the object',   'Turn the object',   0, 0),
(6400037, 'Resize the object', 'Resize the object', 0, 0);

INSERT INTO npc_text (ID, BroadcastTextID0, Probability0) VALUES
(6400035, 6400035, 1),
(6400036, 6400036, 1),
(6400037, 6400037, 1);

-- ----------------------------------------------------------------------------
-- ROLLBACK
--
-- DELETE FROM npc_text       WHERE ID    IN (6400035, 6400036, 6400037);
-- DELETE FROM broadcast_text WHERE entry IN (6400035, 6400036, 6400037);
-- UPDATE broadcast_text
--    SET male_text = 'Which way shall it go?', female_text = 'Which way shall it go?'
--  WHERE entry = 6400030;
-- ----------------------------------------------------------------------------
