-- ============================================================================
--  Housing: remember which item a piece of furniture came from  (tw_char)
-- ============================================================================
--  Furniture placed from an inventory item has to be able to turn back into
--  that item when it is picked up, and the gameobject entry alone cannot say
--  which one: two different items are allowed to place the same model (a
--  quest reward and a vendor copy of the same chair), and the mapping is only
--  guaranteed to run one way. So the row carries the item it was made from.
--
--    0  placed by .house object add, or stamped from a template.
--       Picking it up destroys it, exactly as it always did.
--    n  placed from item n. Picking it up hands item n back.
--
--  APPLY THIS BEFORE SWAPPING THE BINARY. The new loader selects the column,
--  and a failing query is a hard crash here, not a warning - see "Known DB
--  gaps in this install" in CLAUDE.md. Same rule 040 carries.
--
--  Re-runnable (ADD COLUMN IF NOT EXISTS). Apply with:
--    Get-Content sql\custom\041_house_object_item_entry.sql | DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_char
-- ============================================================================

ALTER TABLE house_object
    ADD COLUMN IF NOT EXISTS item_entry INT UNSIGNED NOT NULL DEFAULT 0
    COMMENT 'the furniture item this was placed from; 0 = not from an item' AFTER go_entry;
