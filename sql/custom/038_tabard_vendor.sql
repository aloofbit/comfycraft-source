-- ============================================================================
--  Custom NPC: Tabard vendor  (tw_world)
-- ============================================================================
--  Herald Aveline (creature 100015) sells 75 tabards - every one in the DB
--  worth wearing, in a single vendor window.
--
--  THIS FILE EDITS STOCK ITEMS, which none of the other custom vendors do.
--  Only 27 of the 88 tabards here ship with a buy_price, and a vendor CANNOT
--  sell an item priced 0 - so all of the interesting ones (Ashbringer, Sons of
--  Lothar, Argent Dawn, Scarlet Crusade, every city tabard) were unreachable.
--  Step 1 below gives the unpriced ones a price. Consequences to know:
--
--    * A future Turtle world-DB update would revert these prices, and the
--      vendor would silently lose those rows again. Re-run this file to fix.
--    * The prices are ours, not Blizzard's or Turtle's: 5g common, 10g
--      uncommon, 50g epic. 5g is the price Turtle already puts on its own
--      faction tabards, so the common tier matches its neighbours exactly.
--    * `sell_price` is deliberately left at 0. These cannot be sold back, so
--      there is no buy-low/sell-high loop, and no stock sell price is touched.
--    * Step 1 is idempotent - it names entries explicitly rather than keying
--      off `buy_price = 0`, so re-running produces the same prices.
--
--  A REVERT block is at the bottom of the file, commented out.
--
--  EXCLUDED, 13 of the 88:
--    746 'Lord Brandon's Tabard (Test)', 3557 'Unused Tabard of Chow',
--    80315 '[REUSE ME] Grim Batol Tabard'   - test/placeholder junk
--    5976 + 1245747 + 1814423 + 1927291 + 1963148 'Guild Tabard' - guild
--      machinery rather than a collectible, and already sold by the stock
--      Guild Tabard Designers
--    80302, 18733, 1956206, 23192, 81077 - second copies of a tabard already
--      in the list under the SAME name; the lower/class-4 entry is kept
--
--  Three tabards (80316 Steamwheedle, 80318 Warden) are `class = 0` rather
--  than 4 (armour) in this DB. They are included and they DO equip:
--  `Player::FindEquipSlot` switches on `InventoryType` alone and never looks
--  at the class, so INVTYPE_TABARD reaches EQUIPMENT_SLOT_TABARD regardless.
--
--  75 rows is comfortably inside MAX_VENDOR_ITEMS = 128
--  (`source/src/game/Objects/Creature.h:486` - the limit is the item count
--  field in SMSG_LIST_INVENTORY), though it is the largest vendor here by far.
--
--  Re-runnable: the DELETEs and the explicit-entry UPDATEs make this safe to
--  apply repeatedly.
--
--  Apply with (PowerShell - '<' is a reserved operator there, so pipe):
--    Get-Content sql\custom\038_tabard_vendor.sql | DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_world
--  then, in the mangosd console (no leading dot), no restart needed, and IN
--  THIS ORDER - npc_vendor validates its rows against the CACHED item and
--  creature templates, so reloading it first drops every row with a log-only
--  error and leaves the vendor window empty in game:
--    reload item_template
--    reload creature_template
--    reload npc_vendor
--
--  Spawn it in-game as GM, standing where you want it:
--    .npc add 100015
-- ============================================================================

SET @VENDOR := 100015;

-- ---------------------------------------------------------------------------
--  1. Give the unpriced tabards a price  (STOCK ITEM EDIT - see header)
-- ---------------------------------------------------------------------------
--  Epics: 50g
UPDATE item_template SET buy_price = 500000
 WHERE entry IN (55578, 82002, 92076, 93100, 93116);

--  Uncommon: 10g
UPDATE item_template SET buy_price = 100000
 WHERE entry IN (61368);

--  Common: 5g - the price Turtle already uses for its own faction tabards
UPDATE item_template SET buy_price = 50000
 WHERE entry IN (
   7725, 11364, 15196, 15197, 18732, 19160, 22999, 23705, 23709, 23710,
   50038, 50044, 50086, 50087, 50088, 50089, 50090, 50091, 50092, 50093,
   50376, 61369, 80187, 80303, 80306, 80307, 80309, 80310, 80311, 80314,
   80317, 80318, 81079, 81081, 81082, 81083, 81084, 81085, 81086, 81087,
   81088, 81098, 81201, 81202, 81203, 81204, 81205, 93098, 93099);

-- ---------------------------------------------------------------------------
--  2. The NPC
-- ---------------------------------------------------------------------------
DELETE FROM npc_vendor        WHERE entry = @VENDOR;
DELETE FROM creature_template WHERE entry = @VENDOR;

--  npc_flags = 4 is UNIT_NPC_FLAG_VENDOR in the 1.12 enum this server uses.
--  faction 35 = friendly to everyone.  display 3128 is Garyl's, the Ironforge
--  tabard vendor.
INSERT INTO creature_template
  (entry, name, subname, display_id1, faction, npc_flags,
   level_min, level_max, health_min, health_max, armor, unit_class, type,
   speed_walk, speed_run, scale, base_attack_time, ranged_attack_time,
   dmg_min, dmg_max, movement_type, inhabit_type, regeneration, ai_name)
VALUES
  (@VENDOR, 'Herald Aveline', 'Tabards', 3128, 35, 4,
   60, 60, 4007, 4007, 3272, 1, 7,
   1, 1.14286, 1, 2000, 2000,
   103.4, 129.8, 0, 3, 3, '');

-- ---------------------------------------------------------------------------
--  3. Stock list - epics first, then alphabetical
-- ---------------------------------------------------------------------------
--  maxcount = 0 -> unlimited stock (no restock timer, so incrtime = 0)
INSERT INTO npc_vendor (entry, slot, item, maxcount, incrtime) VALUES
  (@VENDOR, 1, 92076, 0, 0), -- [epic] Adventurer's Lucky Tabard (50.0g)
  (@VENDOR, 2, 93116, 0, 0), -- [epic] Sons of Lothar Tabard (50.0g)
  (@VENDOR, 3, 82002, 0, 0), -- [epic] Tabard of the Ashbringer (50.0g)
  (@VENDOR, 4, 93100, 0, 0), -- [epic] Tabard of the Sunsworn (50.0g)
  (@VENDOR, 5, 55578, 0, 0), -- [epic] Turalyon's Lost Sash (50.0g)
  (@VENDOR, 6, 61368, 0, 0), -- [uncommon] Greymane Tabard (10.0g)
  (@VENDOR, 7, 20132, 0, 0), -- Arathor Battle Tabard (5.0g)
  (@VENDOR, 8, 20131, 0, 0), -- Battle Tabard of the Defilers (5.0g)
  (@VENDOR, 9, 93098, 0, 0), -- Bel'dorei Tabard (5.0g)
  (@VENDOR, 10, 50091, 0, 0), -- Black Mageweave Tabard (5.0g)
  (@VENDOR, 11, 80301, 0, 0), -- Cenarion Circle Tabard (5.0g)
  (@VENDOR, 12, 81086, 0, 0), -- Competition Tabard (5.0g)
  (@VENDOR, 13, 81289, 0, 0), -- Dalaran Tabard (5.0g)
  (@VENDOR, 14, 23710, 0, 0), -- Darkmoon Faire Tabard (5.0g)
  (@VENDOR, 15, 80304, 0, 0), -- Darkspear Tribe Tabard (5.0g)
  (@VENDOR, 16, 80305, 0, 0), -- Darnassus Tabard (1.5g)
  (@VENDOR, 17, 81089, 0, 0), -- Durotar Labor Union Tabard (5.0g)
  (@VENDOR, 18, 33133, 0, 0), -- Earthen Ring Tabard (5.0g)
  (@VENDOR, 19, 19031, 0, 0), -- Frostwolf Battle Tabard (1.0g)
  (@VENDOR, 20, 81079, 0, 0), -- Gilded Scarlet Crusade Tabard (5.0g)
  (@VENDOR, 21, 80306, 0, 0), -- Gnomeregan Tabard (5.0g)
  (@VENDOR, 22, 50044, 0, 0), -- Gold Mageweave Tabard (5.0g)
  (@VENDOR, 23, 50376, 0, 0), -- Hillsbrad Tabard (5.0g)
  (@VENDOR, 24, 81204, 0, 0), -- Illidari Tabard (5.0g)
  (@VENDOR, 25, 80303, 0, 0), -- Ironforge Tabard (5.0g)
  (@VENDOR, 26, 15198, 0, 0), -- Knight's Colors (4.0g)
  (@VENDOR, 27, 81201, 0, 0), -- Mag'har Tabardd (5.0g)
  (@VENDOR, 28, 81202, 0, 0), -- Moro'gai Tabard (5.0g)
  (@VENDOR, 29, 18732, 0, 0), -- Officer's Tabard (5.0g)
  (@VENDOR, 30, 80307, 0, 0), -- Orgrimmar Tabard (5.0g)
  (@VENDOR, 31, 50089, 0, 0), -- Pilfered Dalaran Tabard (5.0g)
  (@VENDOR, 32, 15196, 0, 0), -- Private's Tabard (5.0g)
  (@VENDOR, 33, 80317, 0, 0), -- Quel'Thalas Tabard (5.0g)
  (@VENDOR, 34, 61369, 0, 0), -- Ravenshire Tabard (5.0g)
  (@VENDOR, 35, 50038, 0, 0), -- Red Mageweave Tabard (5.0g)
  (@VENDOR, 36, 81098, 0, 0), -- Revantusk Tabard (5.0g)
  (@VENDOR, 37, 15197, 0, 0), -- Scout's Tabard (5.0g)
  (@VENDOR, 38, 80311, 0, 0), -- Silverhand Tabard (5.0g)
  (@VENDOR, 39, 19506, 0, 0), -- Silverwing Battle Tabard (5.0g)
  (@VENDOR, 40, 80310, 0, 0), -- Sin'dorei Tabard (5.0g)
  (@VENDOR, 41, 80316, 0, 0), -- Steamwheedle Cartel Tabard (5.0g)
  (@VENDOR, 42, 15199, 0, 0), -- Stone Guard's Herald (4.0g)
  (@VENDOR, 43, 19032, 0, 0), -- Stormpike Battle Tabard (1.0g)
  (@VENDOR, 44, 80320, 0, 0), -- Stormwind Tabard (1.5g)
  (@VENDOR, 45, 50086, 0, 0), -- Stromgarde Tabard (5.0g)
  (@VENDOR, 46, 109, 0, 0), -- Summer Collection of Unseen Fashion: Tabard (10.0g)
  (@VENDOR, 47, 81084, 0, 0), -- Tabard of Arcane (5.0g)
  (@VENDOR, 48, 81082, 0, 0), -- Tabard of Brilliance (5.0g)
  (@VENDOR, 49, 93099, 0, 0), -- Tabard of Defender (5.0g)
  (@VENDOR, 50, 81205, 0, 0), -- Tabard of Discovery (5.0g)
  (@VENDOR, 51, 23705, 0, 0), -- Tabard of Flame (5.0g)
  (@VENDOR, 52, 23709, 0, 0), -- Tabard of Frost (5.0g)
  (@VENDOR, 53, 81081, 0, 0), -- Tabard of Fury (5.0g)
  (@VENDOR, 54, 50093, 0, 0), -- Tabard of Hearthglen (5.0g)
  (@VENDOR, 55, 50087, 0, 0), -- Tabard of Kul Tiras (5.0g)
  (@VENDOR, 56, 81085, 0, 0), -- Tabard of Nature (5.0g)
  (@VENDOR, 57, 11364, 0, 0), -- Tabard of Stormwind (5.0g)
  (@VENDOR, 58, 81087, 0, 0), -- Tabard of Summer Flames (5.0g)
  (@VENDOR, 59, 22999, 0, 0), -- Tabard of the Argent Dawn (5.0g)
  (@VENDOR, 60, 50092, 0, 0), -- Tabard of the Crimson Legion (5.0g)
  (@VENDOR, 61, 80187, 0, 0), -- Tabard of the Immortal Guardian (5.0g)
  (@VENDOR, 62, 81088, 0, 0), -- Tabard of the Midsummer Solstice (5.0g)
  (@VENDOR, 63, 7725, 0, 0), -- Tabard of the Scarlet Crusade (5.0g)
  (@VENDOR, 64, 80314, 0, 0), -- Tabard of the Scourge (5.0g)
  (@VENDOR, 65, 81083, 0, 0), -- Tabard of Void (5.0g)
  (@VENDOR, 66, 50088, 0, 0), -- Theramore Tabard (5.0g)
  (@VENDOR, 67, 80308, 0, 0), -- Thunder Bluff Tabard (5.0g)
  (@VENDOR, 68, 80300, 0, 0), -- Time Warden's Tabard (5.0g)
  (@VENDOR, 69, 19160, 0, 0), -- Turtle WoW Tabard (5.0g)
  (@VENDOR, 70, 80309, 0, 0), -- Undercity Tabard (5.0g)
  (@VENDOR, 71, 81203, 0, 0), -- Violet Eye Tabard (5.0g)
  (@VENDOR, 72, 80318, 0, 0), -- Warden Tabard (5.0g)
  (@VENDOR, 73, 19505, 0, 0), -- Warsong Battle Tabard (5.0g)
  (@VENDOR, 74, 50090, 0, 0), -- White Tabard of Stormwind (5.0g)
  (@VENDOR, 75, 80312, 0, 0); -- Wildhammer Tabard (5.0g)

-- ---------------------------------------------------------------------------
--  REVERT - put the stock prices back (uncomment and run, then reload
--  item_template). The vendor loses those rows the moment you do.
-- ---------------------------------------------------------------------------
-- UPDATE item_template SET buy_price = 0 WHERE entry IN (
--   55578, 82002, 92076, 93100, 93116, 61368,
--   7725, 11364, 15196, 15197, 18732, 19160, 22999, 23705, 23709, 23710,
--   50038, 50044, 50086, 50087, 50088, 50089, 50090, 50091, 50092, 50093,
--   50376, 61369, 80187, 80303, 80306, 80307, 80309, 80310, 80311, 80314,
--   80317, 80318, 81079, 81081, 81082, 81083, 81084, 81085, 81086, 81087,
--   81088, 81098, 81201, 81202, 81203, 81204, 81205, 93098, 93099);
