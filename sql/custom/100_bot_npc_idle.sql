-- ============================================================================
--  What a bot NPC does when nobody has told it to do anything  (tw_char)
-- ============================================================================
--  Applied with:
--
--    Get-Content sql\custom\100_bot_npc_idle.sql | `
--      DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_char
--
--  APPLY BEFORE THE BINARY THAT READS IT. BotNpcMgr::Load selects from this
--  table inside World::SetInitialWorldSettings, and a failed query on this core
--  asserts and writes a crash dump rather than warning. 087, 093 and 099 record
--  the same rule.
--
--  ------------------------------------------------------- WHY THIS EXISTS
--
--  A bot NPC stands there and does nothing, deliberately: PlayerbotAI's update
--  returns before DoNextAction for anything IsBotNpc(), because the first one
--  placed in the world re-rolled its gear on a loop and then wandered off to
--  attack something. Switching the AI off was right. This table is the other
--  half -- what it should do INSTEAD, written by a person rather than decided
--  by an engine.
--
--  ------------------------------------------------- A ROW IS ONE TRIGGER
--
--  Three kinds, one row each, and a design may have any of them or none:
--
--    loop         every `period` seconds, while nobody is talking to it
--    near         a real player crosses into `radius` yards, once per visit
--    after_talk   a conversation with it ends
--
--  UNIQUE on (bot_npc_id, trigger_kind), so a section is ABSENT rather than
--  zeroed when it is not being used. A side table rather than five more columns
--  on `bot_npc`: vendor_template_id and quest_giver_id each cost a migration,
--  and a fourth trigger should not cost a fifth.
--
--  `trigger_kind`, not `trigger`. TRIGGER is reserved, and a column that has to
--  be backticked in every hand-typed query is a column that will eventually be
--  typed without them.
--
--  ------------------------------------------ WHAT THE NUMBER POINTS AT
--
--  `script_id` is a `generic_scripts` id in 6450000-6459999 -- ours, a block of
--  its own so a number says which kind of thing it is, the way shop ids
--  200000-200999 and bot quest ids 210000-210999 do. Verified empty on
--  2026-09-16; generic_scripts holds 1975 upstream rows, none of them near it.
--
--  The steps are ORDINARY SCRIPT ROWS, with the same delay-and-priority timeline
--  a gossip button already has, and Map::ScriptsStart runs them with the NPC as
--  source and the player who set it off as target. That is the whole reason this
--  column is a script id rather than a shape of its own: no third executor, and
--  every command handler already works.
--
--  0 does nothing, which is what an empty section saves as.
--
--  ---------------------------------------------------------------- RELOADS
--
--  Two of them, in this order, and the order is load-bearing:
--
--    reload generic_scripts
--    reload bot_npc
--
--  A rule NAMES a script id, so the script has to be in memory before a rule can
--  start one. Same shape as gossip_scripts before gossip_menu_option.
--
--  `reload generic_scripts` also had to be taught to DRAIN the pending script
--  schedule first, the way `reload gossip_scripts` was: an idle loop is by
--  definition a script that is scheduled more or less continuously, so the old
--  "DB scripts used currently, please attempt reload later." guard would have
--  refused it every single time.
--
--  Re-runnable: CREATE TABLE IF NOT EXISTS, and nothing here is seeded.
-- ============================================================================

CREATE TABLE IF NOT EXISTS `bot_npc_idle` (
    `id`           INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
    `bot_npc_id`   INT(10) UNSIGNED NOT NULL DEFAULT 0
                   COMMENT 'bot_npc.id -- the design this belongs to',
    `trigger_kind` ENUM('loop','near','after_talk') NOT NULL DEFAULT 'loop'
                   COMMENT 'what sets it off',
    `enabled`      TINYINT(3) UNSIGNED NOT NULL DEFAULT 1
                   COMMENT '0 keeps the section written down without running it',
    `period`       MEDIUMINT(8) UNSIGNED NOT NULL DEFAULT 60
                   COMMENT 'loop: seconds between runs. near/after_talk: the cooldown before it may fire again',
    `radius`       FLOAT NOT NULL DEFAULT 15
                   COMMENT 'near only: yards. Ignored by the other two',
    `script_id`    INT(10) UNSIGNED NOT NULL DEFAULT 0
                   COMMENT 'generic_scripts.id in 6450000-6459999. 0 does nothing',
    PRIMARY KEY (`id`),
    UNIQUE KEY `one_per_trigger` (`bot_npc_id`, `trigger_kind`),
    KEY `script_id` (`script_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci
  COMMENT='What a bot NPC does unprompted. The website writes these; the map runs them';
