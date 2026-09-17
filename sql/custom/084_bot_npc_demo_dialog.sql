-- ============================================================================
--  A bot NPC's dialog  (tw_world)
-- ============================================================================
--  Applied with:
--
--    Get-Content sql\custom\084_bot_npc_demo_dialog.sql | `
--      DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_world
--
--  NO RESTART NEEDED, since 2026-09-14. Everything this file writes reloads:
--
--    .\Reload-Server.ps1 broadcast_text, npc_text, gossip_menu, gossip_menu_option
--
--  This header used to say a restart was required "and only because of
--  `broadcast_text`", which was true when it was written: that table was one of
--  two with no reload command. It has one now -- the loader had always cleared
--  its map "for reload case" and nobody had wired it up -- so the greeting (the
--  paragraph at the top of the window) is as cheap to edit as the OPTION LABELS
--  below, which are inline in `gossip_menu_option.option_text` and always were.
--
--  ORDER MATTERS if you ever add an `action_script_id` here: `gossip_scripts`
--  must reload BEFORE `gossip_menu_option`, which validates against the cached
--  copy and drops the whole option when it misses.
--
--  WHAT THIS IS. Proof that a bot NPC's dialog is ordinary data. Nothing in the
--  core knows these rows exist: a character bound in tw_char.bot_npc answers
--  Player::GetDefaultGossipMenuId with its menu id, and the stock gossip
--  pipeline -- PrepareGossipMenu, SendPreparedGossip, OnGossipSelect, all of
--  which already took a WorldObject* -- does the rest. See
--  docs/ai/content/playerbot-npcs.md.
--
--  ID RANGES, both of which are tighter than the usual custom block:
--
--    gossip_menu.entry is SMALLINT. The 100000-109999 range this folder uses
--    for creatures and items DOES NOT FIT -- it silently truncates. 64031-64997
--    is empty in this database (64030 is housing's), so 64100-64199 is reserved
--    here for bot NPCs.
--
--    broadcast_text / npc_text: 6400050-6400099 reserved for bot NPCs, beside
--    the housing critters at 6400039. Note 100600-100699 belongs to the mount
--    stables; do not drift into it.
--
--    gossip_scripts: 6430000-6430099 reserved for HAND-WRITTEN bot NPC dialogs,
--    which is this file and files like it. Deliberately clear of 6420000-6429999,
--    which sql/custom/090 reserves for scripts the website's dialog editor will
--    allocate: two writers on one id space, one of them automatic, is a
--    collision waiting for the day nobody remembers this comment.
--
--  WHAT THIS FILE IS FOR, NOW THAT THERE IS AN EDITOR. /admin/dialogs writes
--  pages and buttons far more comfortably than SQL does, and anything it can
--  express belongs there rather than here. What is left to this file is the
--  part the editor does not reach yet: a button that DOES something. Menu 64100
--  is kept as the worked example of that, and the way to look at it is
--
--      .npcbot menu <name> 64100
--
--  ...which points an NPC at a raw menu id, editor or no editor.
--
--  RE-RUNNING THIS NOW REVERTS EDITS MADE ON THE WEBSITE. Menu 64100 has been
--  adopted into the dialog editor (/admin/dialogs, "Orcy the old way"), which
--  means the database and this file are two sources of truth for the same rows:
--  the editor writes the paragraphs, the buttons, and -- since it can edit any
--  single CREATE_ITEM script -- the reward at 6430000 as well. Nothing detects
--  the divergence. Decide which one owns this menu before running it again.
--
--  Re-runnable: DELETE by id, then INSERT.
-- ============================================================================

-- ---------------------------------------------------------------- the words

DELETE FROM `broadcast_text` WHERE `entry` IN (6400050, 6400051, 6400052);
INSERT INTO `broadcast_text` (`entry`, `male_text`, `female_text`, `chat_type`, `sound_id`) VALUES
(6400050, 'Aye?', 'Aye?', 0, 0),
(6400051, 'Nobody worth the telling. I stand here, and that is the whole of it.', 'Nobody worth the telling. I stand here, and that is the whole of it.', 0, 0),
(6400052, 'Here. It is not much, but it is yours.', 'Here. It is not much, but it is yours.', 0, 0);

DELETE FROM `npc_text` WHERE `ID` IN (6400050, 6400051, 6400052);
INSERT INTO `npc_text` (`ID`, `BroadcastTextID0`, `Probability0`) VALUES
(6400050, 6400050, 1),
(6400051, 6400051, 1),
(6400052, 6400052, 1);

-- ---------------------------------------------------------------- the menus

DELETE FROM `gossip_menu` WHERE `entry` IN (64100, 64101, 64102);
INSERT INTO `gossip_menu` (`entry`, `text_id`) VALUES
(64100, 6400050),   -- the greeting
(64101, 6400051),   -- the answer
(64102, 6400052);   -- the handover

-- --------------------------------------------------------------- the action
--
-- SCRIPT_COMMAND_CREATE_ITEM (17). datalong is the item, datalong2 the count,
-- and datalong3 -- unused here -- is a COPPER COST, which is worth knowing:
-- docs/ai/content/vendors-and-gossip.md says gossip cannot charge, and that is
-- true only of `box_money`. A gossip button CAN take money, through this.
--
-- 2589 is Linen Cloth: worthless, stackable, not unique, and unmistakable when
-- it lands in your bag, which is the whole job of a demo.
--
-- THIS RUNS ON A BOT NPC ONLY SINCE 2026-09-14. Player::OnGossipSelect
-- dispatched gossip scripts for gameobjects and for creatures, and a player
-- source fell out of the bottom of both tests -- so action_script_id was read,
-- stored, and never run, with nothing logged. The commit is bc2a6c4.
--
-- The item arrives on the PLAYER and not on the NPC because that arm passes
-- (source = the NPC, target = the viewer), copying the creature convention.
-- Every command in ScriptCommands.cpp that wants a player resolves it
-- target-first, and a bot NPC is a Player too, so the other order would satisfy
-- that test with the NPC and quietly hand it its own reward.
DELETE FROM `gossip_scripts` WHERE `id` = 6430000;
INSERT INTO `gossip_scripts` (`id`, `delay`, `command`, `datalong`, `datalong2`, `comments`) VALUES
(6430000, 0, 17, 2589, 1, 'Bot NPC demo: hand over one Linen Cloth');

-- ---------------------------------------------------------------- the buttons

DELETE FROM `gossip_menu_option` WHERE `menu_id` IN (64100, 64101, 64102);
--
-- npc_option_npcflag MUST be 1 here. Player::PrepareGossipMenu applies the same
-- flag gate to a bot NPC that it applies to a creature, deliberately: without
-- it a bot would be the one NPC in the world that shows every option of every
-- menu it is pointed at. A row with 0 here is a row that never appears, and
-- nothing is logged when it doesn't.
--
-- option_id must be 1 (GOSSIP_OPTION_GOSSIP), and this file said 0 until
-- 2026-09-14, which meant the three rows below never rendered: Orcy greeted
-- you with "Aye?" and showed no options at all. 0 is GOSSIP_OPTION_NONE, and
-- Player::PrepareGossipMenu drops any option that is not GOSSIP_OPTION_GOSSIP
-- on a player source. It is NOT silent -- ObjectMgr::LoadGossipMenuItems logs
-- "use option id GOSSIP_OPTION_NONE. Option will never be used" once per row
-- at startup -- but nothing says so in game, and an empty menu looks exactly
-- like the npc_option_npcflag trap it is not.
--
-- Anything ABOVE 1 -- vendor, trainer, questgiver -- is refused for a player
-- source too, because the creature path for those reaches GetVendorItems and
-- IsTrainerOf, which a Player does not have. Those are not half-built, they
-- are unbuilt.
--
-- action_menu_id: positive opens that menu, negative closes the window, 0 stays.
INSERT INTO `gossip_menu_option`
  (`menu_id`, `id`, `option_icon`, `option_text`, `option_id`, `npc_option_npcflag`, `action_menu_id`, `action_script_id`) VALUES
(64100, 0, 0, 'Who are you?',              1, 1,  64101, 0),
(64100, 1, 0, 'Have you anything for me?', 1, 1,  64102, 6430000),
(64100, 2, 0, 'Nothing, sorry.',           1, 1, -1,     0),
(64101, 0, 0, 'I see.',                    1, 1, -1,     0),
(64102, 0, 0, 'Thank you.',                1, 1, -1,     0);
--
-- THE ITEM BUTTON SETS BOTH action_menu_id AND action_script_id, and the first
-- is not decoration. An option that runs only a script ENDS THE GOSSIP SESSION:
-- the window lingers client-side but the server has no menu prepared, so every
-- later click is silently ignored. The symptom is a menu where Back works right
-- up until you press the one button that does something, and then never again.
-- 30 stock options in this database set both fields for the same reason.
