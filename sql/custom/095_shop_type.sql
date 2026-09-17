-- ============================================================================
--  A shop is paid in gold or paid in goods, and it has to say which
-- ============================================================================
--  Applied with:
--
--    Get-Content sql\custom\095_shop_type.sql | `
--      DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_world
--
--  SAFE AHEAD OF THE BINARY. Nothing in the core reads this column -- see the
--  last section -- so the order against a build does not matter here. It is the
--  website that reads it, and `echo go > .restart-website` is the whole cost.
--
--  ------------------------------------------------------- WHY THERE IS A TYPE
--
--  THE CLIENT HAS TWO MERCHANT WINDOWS AND THEY CANNOT BE MIXED. Measured in
--  game 2026-09-14, twice each, because reasoning about it got it wrong twice:
--
--      ordinary vendor window     shows COIN, cannot show an item cost
--      Turtle's merchant frame    shows up to 5 ITEM COSTS plus honour and
--                                 arena, and cannot show coin
--
--  The second one ignores the `cost` field in its own addon protocol. A row
--  sent at 10000 drew no coin; a row sent at 12345678 drew no coin. So charging
--  gold in that frame would be an INVISIBLE PRICE -- money leaving the player
--  with nothing on screen having asked for it -- which is worse than not having
--  the feature, and the experiment was reverted to the byte.
--
--  So "gold or goods" is not a preference we invented to keep the editor tidy.
--  It is which window can draw the thing, and the editor has to make you pick
--  because the client already has.
--
--      shop_type = 0   GOLD.  Rows live in `npc_vendor_template`, prices and
--                      item requirements in `vendor_cost`. Item requirements
--                      are ENFORCED but never drawn, so the editor does not
--                      offer them here.
--      shop_type = 1   GOODS. Rows live in `custom_merchant`, costs in
--                      `itemextendedcost`. Up to five items, honour and arena.
--                      No coin, at all.
--
--  ------------------------------------------------ EVERY SHOP TODAY IS GOLD
--
--  DEFAULT 0 is right for every existing row and is not merely convenient: the
--  shops that exist were all written against `npc_vendor_template`, which is
--  the gold path by definition. Nothing is reinterpreted by this migration.
--
--  ------------------------------------------------ THE CORE DOES NOT READ IT
--
--  Deliberately. The core decides which window to open by asking where the rows
--  actually are -- `CustomMerchantMgr::HasShop(id)` -- rather than by trusting a
--  flag that could disagree with them. A shop cannot then be typed "goods" and
--  open an empty coin window, which is exactly the silent failure this whole
--  area specialises in.
--
--  The column is what the EDITOR remembers so that a brand new shop with no
--  rows in either table still knows which one it is filling. The two can only
--  disagree while a shop is empty, and an empty shop opens nothing either way.
--
--  Re-runnable: the ALTER is guarded, so this can be applied twice.
-- ============================================================================

SET @col := (
    SELECT COUNT(*) FROM information_schema.COLUMNS
     WHERE TABLE_SCHEMA = DATABASE()
       AND TABLE_NAME   = 'shop'
       AND COLUMN_NAME  = 'shop_type'
);

SET @ddl := IF(@col = 0,
    'ALTER TABLE `shop` ADD COLUMN `shop_type` TINYINT UNSIGNED NOT NULL DEFAULT 0 AFTER `name`',
    'DO 0'
);

PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ---------------------------------------------------------------------------
--  The goods side needs id blocks of its own, and they are derived rather than
--  allocated so that nothing has to keep a counter.
--
--      custom_merchant.id      shop id * 10000 + slot
--      itemextendedcost.id     the same number
--
--  Turtle already numbers its own rows this way (910250042 is entry 91025 slot
--  42), so the scheme is theirs, not ours. Shop ids run 200000-200999, giving
--  2000000000-2009999999 -- inside uint32, and nowhere near the 58247 that
--  `itemextendedcost` reaches today or the 910250042 that `custom_merchant`
--  does. A cost row belongs to exactly one merchant row and shares its number,
--  so deleting the row deletes its price and there is no orphan to sweep.
-- ---------------------------------------------------------------------------
