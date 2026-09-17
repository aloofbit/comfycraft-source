-- ============================================================================
--  Furniture storage: forty slots  (tw_char)
-- ============================================================================
--  A house's worth of furniture is a bag's worth of crates. This is where they
--  go: an account-wide furniture bank of 40 slots, reachable only from inside
--  your own house, holding ITEMS rather than placed objects.
--
--  WHY NOT THE PLAYER'S OWN BANK. The bank is per CHARACTER. A house belongs to
--  an ACCOUNT -- every alt on it shares one house -- so furniture bought on one
--  character has to be reachable from another, and the stock bank cannot do
--  that. (The control panel offers the real bank as a separate option, for
--  everything that is not furniture.)
--
--  WHY NOT house_object.stowed. sql/custom/035 shipped a `stowed` column for
--  the furniture chest that docs/features/housing.md specced as M4: a placed
--  object stops spawning but keeps its row, scale and rotation. That design
--  predates furniture items. Now that picking something up already hands back
--  an item, storage that holds items is one mechanism instead of two, and it
--  can hold a crate that was never placed. `stowed` stays in the schema
--  unused rather than being dropped -- see the M4 section of the writeup.
--
--  ONE CRATE PER SLOT, and the slot is the point. Storage began as a count per
--  KIND -- "Wooden Chair x3" on one row -- which is tidier data and the wrong
--  shape: it cannot say WHERE a crate sits, so a window over it can only ever
--  be a list that reorders itself. Forty numbered slots is an inventory, and an
--  inventory is what a person can drag something into. Furniture items are
--  stackable = 1, so nothing is lost by refusing to stack them here either.
--
--  Re-runnable, and non-destructive: it only ever creates. Nothing migrates the
--  count-per-kind shape because nothing ever ran on it.
--
--  Apply with:
--    Get-Content sql\custom\043_house_storage.sql | DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_char
-- ============================================================================

CREATE TABLE IF NOT EXISTS `house_storage` (
  `account`    INT UNSIGNED     NOT NULL  COMMENT 'tw_logon.account.id, matching house.account',
  `slot`       TINYINT UNSIGNED NOT NULL  COMMENT '1-40, the square it sits in',
  `item_entry` INT UNSIGNED     NOT NULL  COMMENT 'item_template.entry; must be in tw_world.house_furniture_item',
  PRIMARY KEY (`account`, `slot`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
