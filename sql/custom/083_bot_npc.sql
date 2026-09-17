-- ============================================================================
--  Bot NPCs  (tw_char  -- NOT tw_world, unlike most of this folder)
-- ============================================================================
--  Applied with:
--
--    Get-Content sql\custom\083_bot_npc.sql | `
--      DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_char
--
--  APPLY THIS BEFORE THE BINARY THAT READS IT. BotNpcMgr::Load runs during
--  World::SetInitialWorldSettings and a missing table is not a warning here --
--  any failing query trips the assert in MySQLConnection::HandleMySQLError and
--  mangosd writes a crash dump and dies. Same rule as every other new table in
--  this folder; see CLAUDE.md, "Known DB gaps in this install".
--
--  WHAT THIS IS FOR. A playerbot can be an NPC: measured 2026-09-13, the 1.12
--  client draws the talk cursor on a PLAYER unit carrying UNIT_NPC_FLAGS, sends
--  CMSG_GOSSIP_HELLO with the player's guid, and renders whatever menu comes
--  back keyed to that guid. The whole reasoning is docs/ai/content/playerbot-npcs.md.
--
--  That is worth doing because a creature's worn armour lives in the CLIENT --
--  the core says so itself at DBCStructure.h:205, "client show its by self" --
--  so a custom-dressed creature means shipping a patched
--  CreatureDisplayInfoExtra.dbc to everybody. A bot is a real Player and wears
--  what is in its inventory with nothing shipped at all, cape included, which a
--  creature can never have: 1.12 has ten NPC item slots and the last is tabard.
--
--  THIS TABLE IS ONLY THE BINDING, and that is the point of its shape. It says
--  "character N is an NPC, with these flags, showing menu M". The DIALOG itself
--  is ordinary world data in `gossip_menu` and `gossip_menu_option`, which
--  means editing what a bot NPC says needs nothing new at all:
--
--      .\Reload-Server.ps1 gossip_menu, gossip_menu_option
--
--  already covers it. Only adding or retargeting an NPC touches this table, and
--  that is rare enough to live behind `reload bot_npc`.
--
--  WHY tw_char AND NOT tw_world. It keys on `characters.guid`. Putting it in
--  the world database would mean a cross-database join on every load and a
--  world table whose rows are meaningless against a different character set --
--  the same reasoning that put `companion_owner` here in 066.
--
--  THE GUID REUSE TRAP, WHICH IS WHY 067 EXISTS AND WHY THIS ONE IS DANGEROUS.
--  Character guids are REUSED. A row here outliving its character collides with
--  whoever gets that guid next, and on this core a PRIMARY key violation is not
--  a warning -- it asserts and kills the process. Player::DeleteFromDB deletes
--  this table's row in the same change that adds the table; if you are reading
--  this because you are adding another per-character table, do the same thing
--  and do it in the same commit. CLAUDE.md says this under "Player housing" and
--  it has already cost three crashes.
-- ============================================================================

DROP TABLE IF EXISTS `bot_npc`;

CREATE TABLE `bot_npc` (
  `guid`           INT UNSIGNED       NOT NULL DEFAULT 0 COMMENT 'characters.guid -- the bot being dressed as an NPC',
  `npc_flags`      INT UNSIGNED       NOT NULL DEFAULT 1 COMMENT 'UNIT_NPC_FLAGS. 1 = gossip. Applied on login and on reload',
  `gossip_menu_id` MEDIUMINT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'tw_world.gossip_menu.entry. 0 = no menu, which is a bot that is flagged but says nothing',
  `comment`        VARCHAR(255)       NOT NULL DEFAULT '' COMMENT 'for whoever reads this table by hand',
  PRIMARY KEY (`guid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='Characters that act as NPCs. Binding only -- the dialog is in tw_world.gossip_menu';

-- No seed rows. A bot NPC is created by the website (or by hand) against a
-- character that already exists, and seeding a guid here that does not exist in
-- `characters` would be a row pointing at nothing -- or worse, at whoever is
-- handed that guid next. See the reuse note above.
