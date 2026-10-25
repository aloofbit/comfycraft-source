-- ============================================================================
--  PURGE HALF-DELETED CHARACTERS  (tw_char)
-- ============================================================================
--  Applied with mangosd STOPPED:
--
--    Get-Content sql\custom\199_purge_half_deleted_characters.sql | `
--      DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_char
--
--  Player::DeleteFromDB is one transaction. Until 2026-10-24 a deadlock in it
--  stopped it at the failing statement: the MyISAM deletes before it (the
--  `characters` row, the action bar) stayed done, and nothing after it ran.
--  Two companions dismissed together did this 15 times in a week. The rows
--  left behind (skills, spells, items, reputation, bot strategies) belong to
--  no character, and the next character on that guid inherits them. On
--  2026-10-24 a new priest companion got a deleted hunter's skills, gear and
--  strategies, and did not heal.
--
--  An orphan guid has rows in a per-character table and no `characters` row.
--  A soft-deleted character keeps its `characters` row (account 0, no name),
--  so it is not an orphan. The statements below are those of
--  Player::DeleteFromDB, against every orphan guid at once.
--
--  An item is kept if anything still points at it: a living character's
--  inventory, an auction or a mail.
--
--  Re-runnable: a second run finds no orphans and deletes nothing.

DROP TEMPORARY TABLE IF EXISTS `orphan_guid`;
CREATE TEMPORARY TABLE `orphan_guid` (`guid` INT UNSIGNED NOT NULL PRIMARY KEY);

INSERT IGNORE INTO `orphan_guid` SELECT `guid` FROM `character_skills`;
INSERT IGNORE INTO `orphan_guid` SELECT `guid` FROM `character_spell`;
INSERT IGNORE INTO `orphan_guid` SELECT `guid` FROM `character_inventory`;
INSERT IGNORE INTO `orphan_guid` SELECT `guid` FROM `character_reputation`;
INSERT IGNORE INTO `orphan_guid` SELECT `guid` FROM `character_queststatus`;
INSERT IGNORE INTO `orphan_guid` SELECT `guid` FROM `character_homebind`;
INSERT IGNORE INTO `orphan_guid` SELECT `guid` FROM `character_aura`;
INSERT IGNORE INTO `orphan_guid` SELECT `guid` FROM `character_transmogs`;
INSERT IGNORE INTO `orphan_guid` SELECT `guid` FROM `character_inventory_copy`;
INSERT IGNORE INTO `orphan_guid` SELECT `guid` FROM `ai_playerbot_db_store`;
INSERT IGNORE INTO `orphan_guid` SELECT `owner_guid` FROM `item_instance`;
DELETE o FROM `orphan_guid` o JOIN `characters` c ON c.`guid` = o.`guid`;
DELETE FROM `orphan_guid` WHERE `guid` = 0;

SELECT COUNT(*) AS `orphan guids` FROM `orphan_guid`;

DELETE t FROM `character_action` t JOIN `orphan_guid` o ON o.`guid` = t.`guid`;
DELETE t FROM `character_aura` t JOIN `orphan_guid` o ON o.`guid` = t.`guid`;
DELETE t FROM `character_battleground_data` t JOIN `orphan_guid` o ON o.`guid` = t.`guid`;
DELETE t FROM `character_deleted_items` t JOIN `orphan_guid` o ON o.`guid` = t.`player_guid`;
DELETE t FROM `character_gifts` t JOIN `orphan_guid` o ON o.`guid` = t.`guid`;
DELETE t FROM `character_homebind` t JOIN `orphan_guid` o ON o.`guid` = t.`guid`;
DELETE t FROM `character_instance` t JOIN `orphan_guid` o ON o.`guid` = t.`guid`;
DELETE t FROM `group_instance` t JOIN `orphan_guid` o ON o.`guid` = t.`leaderGuid`;
DELETE t FROM `character_inventory` t JOIN `orphan_guid` o ON o.`guid` = t.`guid`;
DELETE t FROM `character_queststatus` t JOIN `orphan_guid` o ON o.`guid` = t.`guid`;
DELETE t FROM `character_reputation` t JOIN `orphan_guid` o ON o.`guid` = t.`guid`;
DELETE t FROM `character_skills` t JOIN `orphan_guid` o ON o.`guid` = t.`guid`;
DELETE t FROM `character_forgotten_skills` t JOIN `orphan_guid` o ON o.`guid` = t.`guid`;
DELETE t FROM `character_spell` t JOIN `orphan_guid` o ON o.`guid` = t.`guid`;
DELETE t FROM `character_spell_cooldown` t JOIN `orphan_guid` o ON o.`guid` = t.`guid`;
DELETE t FROM `character_ticket` t JOIN `orphan_guid` o ON o.`guid` = t.`guid`;
DELETE t FROM `item_instance` t JOIN `orphan_guid` o ON o.`guid` = t.`owner_guid`
  WHERE t.`guid` NOT IN (SELECT `item` FROM `character_inventory`)
    AND t.`guid` NOT IN (SELECT `itemguid` FROM `auction`)
    AND t.`guid` NOT IN (SELECT `item_guid` FROM `mail_items`);
DELETE t FROM `character_transmogs` t JOIN `orphan_guid` o ON o.`guid` = t.`guid`;
DELETE t FROM `character_social` t JOIN `orphan_guid` o ON o.`guid` = t.`guid`;
DELETE t FROM `character_social` t JOIN `orphan_guid` o ON o.`guid` = t.`friend`;
DELETE t FROM `mail_items` t JOIN `orphan_guid` o ON o.`guid` = t.`receiver`;
DELETE t FROM `mail` t JOIN `orphan_guid` o ON o.`guid` = t.`receiver`;
DELETE t FROM `pet_aura` t JOIN `character_pet` p ON p.`id` = t.`guid` JOIN `orphan_guid` o ON o.`guid` = p.`owner`;
DELETE t FROM `pet_spell` t JOIN `character_pet` p ON p.`id` = t.`guid` JOIN `orphan_guid` o ON o.`guid` = p.`owner`;
DELETE t FROM `pet_spell_cooldown` t JOIN `character_pet` p ON p.`id` = t.`guid` JOIN `orphan_guid` o ON o.`guid` = p.`owner`;
DELETE t FROM `character_pet` t JOIN `orphan_guid` o ON o.`guid` = t.`owner`;
DELETE t FROM `guild_eventlog` t JOIN `orphan_guid` o ON o.`guid` = t.`PlayerGuid1`;
DELETE t FROM `guild_eventlog` t JOIN `orphan_guid` o ON o.`guid` = t.`PlayerGuid2`;
DELETE t FROM `character_account_data` t JOIN `orphan_guid` o ON o.`guid` = t.`guid`;
DELETE t FROM `character_armory_stats` t JOIN `orphan_guid` o ON o.`guid` = t.`guid`;
DELETE t FROM `character_aura_suspended` t JOIN `orphan_guid` o ON o.`guid` = t.`guid`;
DELETE t FROM `character_pvp_currency` t JOIN `orphan_guid` o ON o.`guid` = t.`guid`;
DELETE t FROM `character_spell_dual_spec` t JOIN `orphan_guid` o ON o.`guid` = t.`guid`;
DELETE t FROM `character_stats` t JOIN `orphan_guid` o ON o.`guid` = t.`guid`;
DELETE t FROM `character_titles` t JOIN `orphan_guid` o ON o.`guid` = t.`guid`;
DELETE t FROM `character_xp_from_log` t JOIN `orphan_guid` o ON o.`guid` = t.`guid`;
DELETE t FROM `character_honor_cp` t JOIN `orphan_guid` o ON o.`guid` = t.`guid`;
DELETE t FROM `character_inventory_copy` t JOIN `orphan_guid` o ON o.`guid` = t.`guid`;
DELETE t FROM `character_story_flag` t JOIN `orphan_guid` o ON o.`guid` = t.`guid`;
DELETE t FROM `character_critter_pet` t JOIN `orphan_guid` o ON o.`guid` = t.`guid`;
DELETE t FROM `character_fish_catch` t JOIN `orphan_guid` o ON o.`guid` = t.`guid`;
DELETE t FROM `character_jumps` t JOIN `orphan_guid` o ON o.`guid` = t.`guid`;
UPDATE `character_invasion_match` t JOIN `orphan_guid` o ON o.`guid` = t.`invader` SET t.`invader` = 0;
UPDATE `character_invasion_match` t JOIN `orphan_guid` o ON o.`guid` = t.`defender` SET t.`defender` = 0;
UPDATE `character_invasion_match` t JOIN `orphan_guid` o ON o.`guid` = t.`winner` SET t.`winner` = 0;
UPDATE `dungeon_run_member` t JOIN `orphan_guid` o ON o.`guid` = t.`guid` SET t.`guid` = 0;
DELETE t FROM `ai_playerbot_db_store` t JOIN `orphan_guid` o ON o.`guid` = t.`guid`;
DELETE t FROM `ai_playerbot_random_bots` t JOIN `orphan_guid` o ON o.`guid` = t.`bot`;
DELETE t FROM `bot_npc_spawn` t JOIN `orphan_guid` o ON o.`guid` = t.`character_guid`;

DROP TEMPORARY TABLE `orphan_guid`;
