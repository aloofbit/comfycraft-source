-- ============================================================================
--  Dialogs: a name and a page order over the stock gossip tables  (tw_world)
-- ============================================================================
--  Applied with:
--
--    Get-Content sql\custom\090_dialogs.sql | `
--      DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_world
--
--  APPLY BEFORE THE WEBSITE THAT READS IT. Nothing in the CORE reads these two
--  tables at all -- that is the whole idea, see below -- so mangosd is
--  indifferent to when this lands. `node website\server.js` is not: /admin/dialogs
--  queries them on every render.
--
--  WHAT THIS IS, AND WHAT IT DELIBERATELY IS NOT.
--
--  A dialog in this server is not a new kind of object. It is the two stock
--  tables it always was:
--
--      gossip_menu          one row = one PAGE (its entry is the page id,
--                           its text_id points at the paragraph)
--      gossip_menu_option   one row = one BUTTON on that page
--                           action_menu_id > 0 opens that page
--                           action_menu_id < 0 closes the window
--                           action_menu_id = 0 stays put
--
--  ...plus npc_text and broadcast_text behind text_id, because npc_text carries
--  no inline strings in this build. A dialog is a directed graph of flat pages
--  and nothing more: no state, no memory of which button was pressed, no
--  branching except `condition_id`, which reads the PLAYER (quest state,
--  reputation, level, items) and never the conversation.
--
--  So THE CORE NEEDS NO CHANGE FOR ANY OF THIS, and these two tables exist only
--  because the stock ones have nowhere to write down two things a person needs
--  and the server does not:
--
--      a NAME          gossip_menu.entry is a number. "64203" is not something
--                      anybody should have to recognise.
--      WHICH PAGES     nothing in gossip_menu says that pages 64200 and 64203
--      BELONG TOGETHER are two halves of one conversation. Only the links say
--                      it, and only in one direction.
--
--  Drop both tables and every dialog keeps working in game, permanently. You
--  would lose the editor, not the content. That is the property to preserve if
--  this is ever reworked.
--
--  ---------------------------------------------------------------- ID BLOCKS
--
--  gossip_menu.entry is SMALLINT and the space is nearly full -- 5,185 menus
--  exist and the maximum is 65535, so the 100000-109999 block this folder uses
--  for creatures and items DOES NOT FIT and truncates silently.
--
--      64200-64997     PAGES created by the website. 798 of them. Verified
--                      empty 2026-09-14. (64000-64030 is the enchanter,
--                      64100-64199 is reserved by 084 for hand-written bot NPC
--                      dialogs, 64998-65000 and 65535 are Turtle's.)
--
--  A page's paragraph needs a row in BOTH npc_text and broadcast_text, and both
--  ids are DERIVED from the menu id rather than allocated:
--
--      npc_text.ID = broadcast_text.entry = 6410000 + (menu_id - 64200)
--
--  so the reserved text block is 6410000-6410797, and a page's three ids can
--  each be worked out from any of the others with a subtraction. That is worth
--  more than it sounds: it makes deleting and recreating a page idempotent
--  (the same ids come back, so no orphan text accumulates), and it means a
--  stray row found in any of the three tables can be traced to its page
--  without a lookup.
--
--      6420000-6429999 reserved for gossip_scripts ids the editor writes when
--                      buttons grow actions. Nothing uses it yet.
--
--  ------------------------------------------------------------------ RELOADS
--
--  Everything the editor writes reloads, since 2026-09-14 -- broadcast_text was
--  the last holdout and now has a command. The website sends them itself, in
--  this order, and the order is load-bearing:
--
--      reload gossip_scripts        (first: gossip_menu_option validates
--                                   action_script_id against the CACHED copy
--                                   and drops the whole option when it misses)
--      reload broadcast_text        (also reloads locales_broadcast_text)
--      reload npc_text
--      reload gossip_menu
--      reload gossip_menu_option
--
--  Re-runnable: CREATE TABLE IF NOT EXISTS, and no seed data.
-- ============================================================================

-- A conversation. `root_menu_id` is the page a player lands on, and it is what
-- bot_npc.gossip_menu_id (or creature_template.gossip_menu_id) is pointed at.
CREATE TABLE IF NOT EXISTS `dialog` (
  `id`            smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `name`          varchar(64)          NOT NULL DEFAULT '',
  `root_menu_id`  smallint(5) unsigned NOT NULL DEFAULT 0,
  `comment`       varchar(255)         NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- One page. `menu_id` IS the gossip_menu.entry -- this table does not allocate
-- a second identity for a page, it annotates the one the game already uses.
--
-- `title` is for the author and reaches no player: it is what the page is called
-- in the editor's sidebar ("Greeting", "About the inn"), so that wiring a button
-- to page 4 can be a sentence instead of a number.
CREATE TABLE IF NOT EXISTS `dialog_page` (
  `menu_id`   smallint(5) unsigned NOT NULL DEFAULT 0,
  `dialog_id` smallint(5) unsigned NOT NULL DEFAULT 0,
  `title`     varchar(64)          NOT NULL DEFAULT '',
  `sort`      smallint(5) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`menu_id`),
  KEY `dialog` (`dialog_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
