-- ============================================================================
--  A bot NPC can point at a shop  (tw_char)
-- ============================================================================
--  Applied with:
--
--    Get-Content sql\custom\093_bot_npc_vendor.sql | `
--      DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_char
--
--  APPLY BEFORE THE BINARY THAT READS IT, the same rule 087 records: once
--  BotNpcMgr::Load names this column, a missing one is a failed query during
--  World::SetInitialWorldSettings, and a failed query on this core asserts and
--  writes a crash dump rather than warning.
--
--  SAFE TO APPLY EARLY, AND THAT IS WHY IT IS HERE AHEAD OF THE CORE WORK.
--  BotNpcMgr::Load selects its columns BY NAME, so today's binary reads straight
--  past this one. The website can therefore show "sold by" for bot NPCs before
--  a single line of the core has changed, and the number it shows is the number
--  the core will later read.
--
--  WHAT IT POINTS AT is npc_vendor_template.entry -- a shop, in the 200000-200999
--  block sql/custom/092 reserves. NOT a creature entry: a bot NPC has none, and
--  that is the whole reason shops are built on the template table instead of on
--  npc_vendor.
--
--  0 means it sells nothing, which is every bot NPC today.
--
--  ------------------------------------- THERE IS NO SUCH THING AS A BOT SHOP
--
--  A SHOP SOLD BY A BOT NPC IS THE SAME OBJECT AS A SHOP SOLD BY A CREATURE, in
--  every respect including limited stock. This file said otherwise when it was
--  written, on the grounds that stock is counted in memory by
--  Creature::GetVendorItemCurrentCount off m_vendorItemCounts, which a bot NPC
--  had no equivalent for.
--
--  That was a fact about where a vector happened to live, mistaken for a fact
--  about the world. Both count methods touch m_vendorItemCounts, sObjectMgr,
--  sWorld and urand and nothing else on a Creature, and Creature.h already
--  includes Unit.h -- so the struct, the vector and the two methods moved down
--  to Unit with their bodies unchanged, and a bot NPC counts stock the way
--  anything else does.
--
--  Worth keeping as a warning: a difference that exists only because of where
--  you put the storage is not a design, and writing a rule to defend it makes
--  it permanent.
--
--  ---------------------------------------------------------------- RELOADS
--
--  `reload bot_npc` re-reads this table and re-applies flags to everyone already
--  in world, so linking a shop lands without a restart. The STOCK is the world
--  DB's business and reloads separately with `reload npc_vendor`.
--
--  Re-runnable: the ADD is guarded, because ALTER TABLE has no IF NOT EXISTS for
--  columns on this MariaDB and a bare re-run aborts the rest of the file.
-- ============================================================================

DELIMITER $$

DROP PROCEDURE IF EXISTS `add_bot_npc_vendor_template_id` $$
CREATE PROCEDURE `add_bot_npc_vendor_template_id`()
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS
                   WHERE TABLE_SCHEMA = DATABASE()
                     AND TABLE_NAME = 'bot_npc'
                     AND COLUMN_NAME = 'vendor_template_id') THEN
        ALTER TABLE `bot_npc`
            ADD COLUMN `vendor_template_id` MEDIUMINT(8) UNSIGNED NOT NULL DEFAULT 0
                COMMENT 'npc_vendor_template.entry -- the shop this NPC sells; 0 sells nothing'
                AFTER `gossip_menu_id`;
    END IF;
END $$

DELIMITER ;

CALL `add_bot_npc_vendor_template_id`();
DROP PROCEDURE `add_bot_npc_vendor_template_id`;
