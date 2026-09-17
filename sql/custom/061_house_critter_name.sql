-- ============================================================================
--  house_critter.custom_name -- giving an animal a name             (tw_char)
-- ============================================================================
--  A creature's name comes from creature_template and the 1.12 client caches it
--  BY ENTRY in creaturecache.wdb, so naming one rabbit would name every rabbit
--  in the world. The mechanism that IS per-instance is the pet name query: the
--  client caches those by PET NUMBER, and UNIT_FIELD_PET_NAME_TIMESTAMP exists
--  precisely so a renamed hunter pet invalidates that cache.
--
--  PROVEN BY PROBE 2026-09-04, because whether the client would ask at all for
--  an OWNERLESS unit could not be read out of the core:
--
--    [critter-probe] CMSG_PET_NAME_QUERY petnumber=8000000 guid=Creature (Entry: 1933 Guid: 8000000)
--
--  It asks. No owner, no CREATEDBY, no charm, no pet frame -- just
--  UNIT_FIELD_PETNUMBER set to the critter's guid. See HouseMgr::DressCritter.
--
--    Get-Content sql\custom\061_house_critter_name.sql | DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_char
--
--  APPLY THIS BEFORE THE BINARY. The loader selects the column, and a missing
--  column is a hard crash here rather than a warning.
--
--  THE NAME DIES WITH THE ROW, and that is the design rather than a shortfall.
--  Picking an animal up deletes its house_critter row and hands back a crate,
--  and a crate is an ordinary stackable item with nowhere to carry a name --
--  vanilla items have no per-instance data. Letting it out again gives you the
--  species back, ready to be named afresh.
--
--  varchar(24): long enough for anything anybody types at a rabbit, short
--  enough that a name cannot crowd out the rest of a chat line.
-- ============================================================================

ALTER TABLE `house_critter`
  ADD COLUMN `custom_name` VARCHAR(24) NOT NULL DEFAULT ''
  COMMENT 'what the owner called it; empty = the species name'
  AFTER `item_entry`;
