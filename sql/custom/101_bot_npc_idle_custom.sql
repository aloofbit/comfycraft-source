-- ============================================================================
--  A custom NPC whose whole behaviour is one scene  (tw_char)
-- ============================================================================
--  Applied with:
--
--    Get-Content sql\custom\101_bot_npc_idle_custom.sql | `
--      DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_char
--
--  APPLY BEFORE THE BINARY THAT READS IT, the same rule as 100. A missing
--  column is a failed query inside World::SetInitialWorldSettings, and a failed
--  query on this core asserts and writes a crash dump rather than warning.
--
--  ------------------------------------------------------- A FOURTH TRIGGER
--
--  `custom` is not a trigger at all in the way the other three are, and that is
--  the point of it. The other three fire a timeline on a moment the server
--  decides: a period, an arrival, the end of a conversation. This one hands the
--  whole question to the author.
--
--    while not npc:IsGone() do
--      local here = npc:PlayersNear(20)
--      ...
--      wait(30)
--    end
--
--  So it has no period and no radius. Every timer in it is a `wait()` the
--  author wrote, and every condition is an `if`.
--
--  STARTED ONCE, WHEN THE NPC COMES INTO THE WORLD. Not on a timer and not
--  restarted when it ends -- it is a program that begins with the character,
--  which is the mental model the loop in the editor is written against. What
--  DOES start it again is `reload bot_npc`, so saving on the website or editing
--  the scene lands, and `.npcbot idle <name> custom` by hand.
--
--  ------------------------------------------------- WHY A SECOND COLUMN
--
--  `script_id` is a `generic_scripts` id and `scene_id` is a `dialog_lua` id.
--  Two id spaces, two columns. The alternative was one column meaning either
--  depending on the row's `trigger_kind`, which is the shape this repo already
--  has one of -- a vendor option's `action_menu_id` holding a shop id -- and it
--  is documented there as a trap rather than as a pattern to copy.
--
--  A `custom` row therefore has `script_id` 0 and `scene_id` set; the other
--  three are the other way round. Nothing enforces that beyond the loader,
--  which reads whichever one its trigger means.
--
--  Re-runnable: both changes are guarded, because ALTER TABLE has no
--  IF NOT EXISTS for columns on this MariaDB and MODIFY on an ENUM that is
--  already right is a table rebuild for nothing.
-- ============================================================================

DELIMITER $$

DROP PROCEDURE IF EXISTS `add_bot_npc_idle_custom` $$
CREATE PROCEDURE `add_bot_npc_idle_custom`()
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS
                   WHERE TABLE_SCHEMA = DATABASE()
                     AND TABLE_NAME = 'bot_npc_idle'
                     AND COLUMN_NAME = 'scene_id') THEN
        ALTER TABLE `bot_npc_idle`
            ADD COLUMN `scene_id` SMALLINT(5) UNSIGNED NOT NULL DEFAULT 0
                COMMENT 'dialog_lua.id -- `custom` only. 0 does nothing'
                AFTER `script_id`;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS
                   WHERE TABLE_SCHEMA = DATABASE()
                     AND TABLE_NAME = 'bot_npc_idle'
                     AND COLUMN_NAME = 'trigger_kind'
                     AND COLUMN_TYPE LIKE '%custom%') THEN
        ALTER TABLE `bot_npc_idle`
            MODIFY COLUMN `trigger_kind`
                ENUM('loop','near','after_talk','custom') NOT NULL DEFAULT 'loop'
                COMMENT 'what sets it off. `custom` is a scene that sets itself off';
    END IF;
END $$

DELIMITER ;

CALL `add_bot_npc_idle_custom`();
DROP PROCEDURE `add_bot_npc_idle_custom`;
