-- ============================================================================
--  house_critter.item_entry -- remembering which crate an animal came out of
--                                                                   (tw_char)
-- ============================================================================
--  The exact counterpart of house_object.item_entry, and it exists for the
--  same reason: picking a critter up has to hand back the ITEM, and the
--  creature entry cannot answer which one that was. Two crates are allowed to
--  release the same animal -- a vendor's rabbit and a quest reward's rabbit --
--  so the row remembers where it came from rather than the mapping being asked
--  to run backwards.
--
--  0 means "not from an item": placed with `.house critter add`. Those are
--  destroyed on pick-up exactly as they always were, because there is nothing
--  to give back.
--
--    Get-Content sql\custom\058_house_critter_item.sql | DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_char
--
--  APPLY THIS BEFORE THE BINARY. The loader selects the column, and a missing
--  column is a hard crash on this server rather than a warning -- the same
--  rule sql/custom/040 carries.
--
--  NOT FOLDED INTO 057. That file creates the table and people have already
--  run it; an ALTER of its own is how 040 did the same job, and it keeps
--  "what a fresh install runs" identical to "what an existing install runs".
--
--  Re-running this is harmless but not silent: MariaDB has no
--  ADD COLUMN IF NOT EXISTS worth relying on here, so a second run reports
--  "Duplicate column name 'item_entry'" and changes nothing.
-- ============================================================================

ALTER TABLE `house_critter`
  ADD COLUMN `item_entry` INT(10) UNSIGNED NOT NULL DEFAULT 0
  COMMENT 'the crate this came out of; 0 = placed with .house critter add'
  AFTER `entry`;
