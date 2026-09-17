-- ============================================================================
--  The <bracket> line under a bot NPC's name  (tw_char)
-- ============================================================================
--  Applied with:
--
--    Get-Content sql\custom\088_bot_npc_subname.sql | `
--      DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_char
--
--  APPLY BEFORE THE BINARY THAT READS IT. BotNpcMgr::Load selects this column
--  during World::SetInitialWorldSettings and a missing column is a failed
--  query, which on this core asserts and writes a crash dump.
--
--  A CREATURE'S SUBNAME IS NOT AVAILABLE TO A PLAYER. It arrives in
--  SMSG_CREATURE_QUERY_RESPONSE, and a player guid gets
--  SMSG_NAME_QUERY_RESPONSE, which has no such field. But a GUILD NAME lands in
--  exactly that slot:
--
--      Innkeeper Allison          Innkeeper Allison
--      <Innkeeper>                <Innkeeper>        <- guild name, same line
--      Level 30 Humanoid          Level 30 Human Warrior
--
--  So `subname` is the name of a guild the NPC is put into. Nothing gates
--  reading one: HandleGuildQueryOpcode answers any player's query for any guild
--  id with no membership check, so every viewer sees it.
--
--  ONE GUILD PER SUBNAME, SHARED. Every NPC whose subname is "Innkeeper" joins
--  the same guild, and the first one placed is its leader. Forty-odd guilds
--  would cover the whole classic set.
--
--  THE MEMBERSHIP IS REAL, and it has to be. A guild with no members is
--  disbanded at startup -- Guild::CheckGuildStructure hands the leadership on if
--  it can and gives up when the last member goes, and GuildMgr::LoadGuilds
--  deletes what it gives up on. So the tempting shortcut of label-only guilds
--  with PLAYER_GUILDID faked in the update block does not survive a restart.
--
--  WHICH MEANS /who. Free to fix: MiscHandler.cpp drops anyone whose session
--  security is ABOVE GM.InWhoList.Level (3 in mangosd.conf), so NPC accounts at
--  rank 4 fall out of it entirely -- and rank 4 is the rank CLAUDE.md flags as
--  useless in game, which is exactly right for a character that never types a
--  command. Not done here; noted for when it starts to matter.
--
--  24 is MAX_CHARTER_NAME (ObjectMgr.h:505), the client's own limit on a guild
--  name. "Wind Rider Master" is 17.
--
--  Re-runnable: the ADD is guarded, because ALTER TABLE has no IF NOT EXISTS
--  for columns on this MariaDB and a bare re-run aborts the rest of the file.
-- ============================================================================

DELIMITER $$

DROP PROCEDURE IF EXISTS `add_bot_npc_subname` $$
CREATE PROCEDURE `add_bot_npc_subname`()
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS
                   WHERE TABLE_SCHEMA = DATABASE()
                     AND TABLE_NAME = 'bot_npc'
                     AND COLUMN_NAME = 'subname') THEN
        ALTER TABLE `bot_npc`
            ADD COLUMN `subname` VARCHAR(24) NOT NULL DEFAULT ''
                COMMENT 'the <bracket> line; implemented as a guild of this name. Empty = no bracket'
                AFTER `gender`;
    END IF;
END $$

DELIMITER ;

CALL `add_bot_npc_subname`();
DROP PROCEDURE `add_bot_npc_subname`;
