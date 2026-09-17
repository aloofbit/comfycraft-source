-- ============================================================================
--  What a vendor row costs: a price of our own, and things as well as coin
-- ============================================================================
--  Applied with:
--
--    Get-Content sql\custom\094_vendor_cost.sql | `
--      DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_world
--
--  APPLY BEFORE THE BINARY THAT READS IT. ObjectMgr::LoadVendorCosts selects
--  these columns during startup, and a missing table or column is a failed
--  query, which on this core asserts and writes a crash dump rather than
--  warning. CLAUDE.md has the standing rule.
--
--  ---------------------------------------------------------------- WHY AT ALL
--
--  1.12 HAS NO ExtendedCost. A vendor row is `entry, slot, item, maxcount,
--  incrtime, itemflags, condition_id` and nothing else, and the price a player
--  pays is `item_template.buy_price` -- the ITEM's price, everywhere it is sold.
--  So a shop could not say "this costs 1 silver here", and could not say "this
--  costs three planks" at all. TBC added both; this is that, built.
--
--  A COST ROW IS THE WHOLE PRICE. cost_id = 0 is every row that exists today and
--  means "whatever the item costs". A cost row REPLACES that outright, so:
--
--      money 100, no items          1 silver, whatever the item is worth
--      money 0, 3 of item 2589      three Linen Cloth and no coin
--      money 100, 3 of item 2589    one silver AND three Linen Cloth
--
--  money 0 with no items is free, and is a thing you can now say on purpose
--  rather than a thing that happens to an item priced at 0.
--
--  ------------------------------------- THE PART THE CLIENT CANNOT BE TOLD
--
--  SMSG_LIST_INVENTORY IN 1.12 CARRIES SEVEN uint32 PER ROW: index, item,
--  display id, stock, PRICE, durability and buy count (ItemHandler.cpp). There
--  is no field for an item cost and no way to add one -- the client parses a
--  fixed shape. So the vendor window shows the MONEY and cannot show the rest.
--
--  What the server can do, and does: refuse the purchase and say exactly what is
--  missing, by name and count. What would do it properly is an addon drawing the
--  requirement into the vendor frame, the way addon/ComfyNPC already repaints a
--  tooltip the server cannot reach. That is not built.
--
--  KNOW THIS BEFORE PRICING ANYTHING IN GOODS: a player sees "1s", clicks, and
--  is told they also need three planks. That is a worse experience than a plain
--  price, and it is the honest state of it until the addon exists.
--
--  ------------------------------------------------------------------ RELOADS
--
--  `reload npc_vendor` re-reads the costs too -- LoadVendorCosts runs first in
--  the same handler, because a cost_id the cache does not know would otherwise
--  read as 0 and the row would quietly sell at the item's own price.
--
--  Re-runnable: CREATE TABLE IF NOT EXISTS, and the ADDs are guarded because
--  ALTER TABLE has no IF NOT EXISTS for columns on this MariaDB.
-- ============================================================================

CREATE TABLE IF NOT EXISTS `vendor_cost` (
  `id`      mediumint(8) unsigned NOT NULL AUTO_INCREMENT,
  -- Copper. 0 is free, not "unset" -- a row that wanted the item's own price
  -- would not have a cost row at all.
  `money`   int(10) unsigned      NOT NULL DEFAULT 0,
  -- Three is the shape TBC settled on after five, and three is more than
  -- anything here has wanted. Adding a fourth is a column and one loop bound.
  `item1`   mediumint(8) unsigned NOT NULL DEFAULT 0,
  `count1`  smallint(5) unsigned  NOT NULL DEFAULT 0,
  `item2`   mediumint(8) unsigned NOT NULL DEFAULT 0,
  `count2`  smallint(5) unsigned  NOT NULL DEFAULT 0,
  `item3`   mediumint(8) unsigned NOT NULL DEFAULT 0,
  `count3`  smallint(5) unsigned  NOT NULL DEFAULT 0,
  `comment` varchar(255)          NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

DELIMITER $$

DROP PROCEDURE IF EXISTS `add_vendor_cost_columns` $$
CREATE PROCEDURE `add_vendor_cost_columns`()
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS
                   WHERE TABLE_SCHEMA = DATABASE()
                     AND TABLE_NAME = 'npc_vendor' AND COLUMN_NAME = 'cost_id') THEN
        ALTER TABLE `npc_vendor`
            ADD COLUMN `cost_id` MEDIUMINT(8) UNSIGNED NOT NULL DEFAULT 0
                COMMENT 'vendor_cost.id -- the whole price. 0 uses item_template.buy_price'
                AFTER `condition_id`;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS
                   WHERE TABLE_SCHEMA = DATABASE()
                     AND TABLE_NAME = 'npc_vendor_template' AND COLUMN_NAME = 'cost_id') THEN
        ALTER TABLE `npc_vendor_template`
            ADD COLUMN `cost_id` MEDIUMINT(8) UNSIGNED NOT NULL DEFAULT 0
                COMMENT 'vendor_cost.id -- the whole price. 0 uses item_template.buy_price'
                AFTER `condition_id`;
    END IF;
END $$

DELIMITER ;

CALL `add_vendor_cost_columns`();
DROP PROCEDURE `add_vendor_cost_columns`;
