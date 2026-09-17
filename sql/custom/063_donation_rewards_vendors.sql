-- ============================================================================
--  Custom NPCs: Donation-shop rewards  (tw_world)
-- ============================================================================
--  Three vendors carrying every one of the 244 items the Turtle donation shop
--  used to sell, at 1 copper each. This server is not monetised, so the
--  catalogue is simply moved in-world; the minimap button that opened the shop
--  is hidden by the ComfyNoShop addon (addon/ComfyNoShop).
--
--  WHERE THE LIST COMES FROM. `tw_world.shop_items` is Turtle's own donation
--  catalogue - 244 rows in 8 categories, read by `ShopMgr`
--  (source/src/game/Shop/ShopMgr.cpp) and priced in donation points held in
--  `tw_logon.shop_coins`. Every row's `item` is a real `item_template` entry,
--  and buying does nothing to it but put it in your bags, so a plain vendor is
--  a faithful replacement: there is no service, script or side effect to
--  reproduce. The race, name and appearance changes in the list are themselves
--  ordinary token items.
--
--  THIS FILE EDITS STOCK ITEMS, as 038 does and for the same reason: a vendor
--  cannot sell an item whose `buy_price` is 0, and 193 of the 244 have
--  none - donation rewards were never meant to be bought with gold. Step 1
--  gives those a price of 1 copper. Consequences to know:
--
--    * A Turtle world-DB update would revert these prices and the vendors
--      would silently lose those rows. Re-run this file to fix.
--    * `sell_price` is already 0 on all 244, checked - so buying at 1 copper
--      and selling back is not a money loop, and no sell price is touched.
--    * The other 51 already carry a price and are LEFT ALONE. Twenty of
--      them are tabards priced by 038 and four are shirts stocked by
--      Merribeth; re-pricing those here would put two custom files in a tug
--      of war over the same rows. The rest are Turtle's own and none exceeds
--      5g. No STOCK vendor sells any of the 244, so nothing outside
--      sql/custom/ is affected either way. To make the catalogue uniformly 1
--      copper instead, drop the `buy_price = 0` filter from the query that
--      built step 1 and regenerate.
--    * Step 1 names entries explicitly rather than keying off `buy_price = 0`,
--      so re-running produces the same prices.
--
--  A REVERT block is at the bottom of the file, commented out.
--
--  WHY THREE NPCs. MAX_VENDOR_ITEMS = 128
--  (source/src/game/Objects/Creature.h:486) - a protocol limit, being the
--  item-count field in SMSG_LIST_INVENTORY, not a tuning knob. Going over it
--  is SILENT: the load-time check is against UINT8_MAX = 255
--  (ObjectMgr.cpp:8684), and 128 is enforced only when the vendor window is
--  opened - HandleListInventoryOpcode writes rows until count >= 128 and
--  breaks (ItemHandler.cpp:982), logging nothing. So an over-long vendor
--  serves its first 128 rows forever and never says so. Two existing
--  Curators from sql/custom/008 are over it: 100006 has 145 rows and 100007
--  has 143. Find them with:
--    SELECT entry, COUNT(*) c FROM npc_vendor GROUP BY entry HAVING c > 128;
--  The split below follows the shop's own categories; largest window is 114:
--
--    100016  Beastmaster Torvald   95 rows   Mounts + Companions
--    100017  Illusionist Sarielle 114 rows   Skins + Fashion + Illusions
--    100018  Steward Bellamy       35 rows   Miscellaneous + Gameplay + Glyphs
--
--  Apply with (PowerShell - '<' is a reserved operator there, so pipe):
--    Get-Content sql\custom\040_donation_rewards_vendors.sql | DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_world
--  then, in the mangosd console (no leading dot), no restart needed, and IN
--  THIS ORDER - npc_vendor validates its rows against the CACHED item and
--  creature templates, so reloading it first drops every row with a log-only
--  error and leaves the windows empty in game:
--    reload item_template
--    reload creature_template
--    reload npc_vendor
--
--  Spawn them in-game as GM, standing where you want each one - the other
--  custom vendors are clustered in Ironforge around (-4905, -940, 501.5):
--    .npc add 100016
--    .npc add 100017
--    .npc add 100018
-- ============================================================================

-- ---------------------------------------------------------------------------
--  1. Price the unpriced rewards at 1 copper  (STOCK ITEM EDIT - see header)
-- ---------------------------------------------------------------------------
UPDATE item_template SET buy_price = 1
 WHERE entry IN (
   1041, 5663, 8630, 8635, 12302, 12303, 12325, 12326, 12327, 13328,
   13583, 13584, 18768, 20371, 22781, 23193, 31825, 31826, 36500, 36501,
   36502, 36503, 36504, 36505, 36506, 36507, 36508, 36509, 36510, 36511,
   36512, 36513, 36514, 36515, 36516, 50000, 50003, 50004, 50005, 50007,
   50009, 50011, 50013, 50019, 50071, 50072, 50073, 50074, 50076, 50083,
   50084, 50085, 50105, 50106, 50204, 50205, 50206, 50207, 50208, 50209,
   50212, 50220, 50221, 50223, 50224, 50250, 50251, 50252, 50290, 50291,
   50292, 50399, 50400, 50401, 50402, 50403, 50404, 50406, 50407, 50408,
   50536, 50602, 50603, 50604, 50605, 50606, 50607, 50608, 50609, 50610,
   50612, 50613, 51007, 51010, 51011, 51056, 51057, 51065, 51201, 51205,
   51206, 51208, 51215, 51253, 51266, 51306, 51421, 51431, 51432, 51715,
   51830, 51920, 51921, 53008, 61104, 61105, 61106, 69004, 69006, 80430,
   80431, 80443, 80447, 80449, 80455, 80499, 80555, 80648, 80694, 80699,
   81091, 81100, 81102, 81120, 81121, 81145, 81150, 81151, 81153, 81154,
   81155, 81158, 81206, 81207, 81208, 81209, 81210, 81227, 81228, 81229,
   81230, 81231, 81232, 81234, 81235, 81236, 81238, 81239, 81242, 81255,
   81258, 83090, 83091, 83092, 83099, 83100, 83150, 83151, 83152, 83154,
   83155, 83158, 83300, 83301, 83302, 92030, 92031, 92032, 92033, 92034,
   92035, 92036, 92037, 92038, 92039, 92040, 92041, 92042, 92043, 92044,
   92050, 92051, 92052);

-- ---------------------------------------------------------------------------
--  Beastmaster Torvald (100016) - 95 items
-- ---------------------------------------------------------------------------
DELETE FROM npc_vendor        WHERE entry = 100016;
DELETE FROM creature_template WHERE entry = 100016;

--  npc_flags = 4 is UNIT_NPC_FLAG_VENDOR in the 1.12 enum this server uses.
--  faction 35 = friendly to everyone.
INSERT INTO creature_template
  (entry, name, subname, display_id1, faction, npc_flags,
   level_min, level_max, health_min, health_max, armor, unit_class, type,
   speed_walk, speed_run, scale, base_attack_time, ranged_attack_time,
   dmg_min, dmg_max, movement_type, inhabit_type, regeneration, ai_name)
VALUES
  (100016, 'Beastmaster Torvald', 'Mounts & Companions', 2790, 35, 4,
   60, 60, 4007, 4007, 3272, 1, 7,
   1, 1.14286, 1, 2000, 2000,
   103.4, 129.8, 0, 3, 3, '');

--  maxcount = 0 -> unlimited stock (no restock timer, so incrtime = 0)
INSERT INTO npc_vendor (entry, slot, item, maxcount, incrtime) VALUES
  --  Mounts
  (100016, 1, 81154, 0, 0), -- [epic] Armored Black Bear (200pt -> 1c)
  (100016, 2, 80449, 0, 0), -- [epic] Armored Black Steed (150pt -> 1c)
  (100016, 3, 80443, 0, 0), -- [epic] Armored Brewfest Ram (180pt -> 1c)
  (100016, 4, 18768, 0, 0), -- [epic] Armored Dawnsaber (130pt -> 1c)
  (100016, 5, 81158, 0, 0), -- [epic] Armored Frostmane Bear (200pt -> 1c)
  (100016, 6, 83154, 0, 0), -- [epic] Armored Ice Raptor (180pt -> 1c)
  (100016, 7, 81153, 0, 0), -- [epic] Armored Purple Bear (200pt -> 1c)
  (100016, 8, 81155, 0, 0), -- [epic] Armored Red Bear (200pt -> 1c)
  (100016, 9, 80430, 0, 0), -- [epic] Azure Spectral Tiger (2000pt -> 1c)
  (100016, 10, 81091, 0, 0), -- [epic] Big Blizzard Bear (250pt -> 1c)
  (100016, 11, 83150, 0, 0), -- [epic] Big Turtle WoW Bear (180pt -> 1c)
  (100016, 12, 83151, 0, 0), -- [epic] Black Spectral Tiger (2000pt -> 1c)
  (100016, 13, 83158, 0, 0), -- [epic] Brown Zhevra (180pt -> 1c)
  (100016, 14, 92050, 0, 0), -- [epic] Celestial Steed (250pt -> 1c)
  (100016, 15, 81121, 0, 0), -- [epic] Cenarion Hippogryph (250pt -> 1c)
  (100016, 16, 92052, 0, 0), -- [epic] Crimson Spectral Tiger (2000pt -> 1c)
  (100016, 17, 81102, 0, 0), -- [epic] Darkmoon Dancing Bear (150pt -> 1c)
  (100016, 18, 83152, 0, 0), -- [epic] Green Spectral Tiger (2000pt -> 1c)
  (100016, 19, 92051, 0, 0), -- [epic] Invincible (250pt -> 1c)
  (100016, 20, 81120, 0, 0), -- [epic] Long-Forgotten Hippogryph (250pt -> 1c)
  (100016, 21, 81100, 0, 0), -- [epic] Raven Lord (250pt -> 1c)
  (100016, 22, 83155, 0, 0), -- [epic] Scarlet Charger (180pt -> 1c)
  (100016, 23, 50536, 0, 0), -- [epic] Twilight (500pt -> 1c)
  (100016, 24, 13328, 0, 0), -- [rare] Ancient Black Ram (100pt -> 1c)
  (100016, 25, 1041, 0, 0), -- [rare] Ancient Black Wolf (100pt -> 1c)
  (100016, 26, 12302, 0, 0), -- [rare] Ancient Frostsaber (100pt -> 1c)
  (100016, 27, 8635, 0, 0), -- [rare] Ancient Nightsaber (100pt -> 1c)
  (100016, 28, 5663, 0, 0), -- [rare] Ancient Red Wolf (100pt -> 1c)
  (100016, 29, 81236, 0, 0), -- [rare] Armored Grey Steed (100pt -> 1c)
  (100016, 30, 50401, 0, 0), -- [rare] Armored Ivory Raptor (180pt -> 1c)
  (100016, 31, 50404, 0, 0), -- [rare] Armored Obsidian Raptor (180pt -> 1c)
  (100016, 32, 50403, 0, 0), -- [rare] Armored Red Raptor (180pt -> 1c)
  (100016, 33, 50402, 0, 0), -- [rare] Armored Violet Raptor (180pt -> 1c)
  (100016, 34, 81232, 0, 0), -- [rare] Azure Frostsaber (80pt -> 1c)
  (100016, 35, 23193, 0, 0), -- [rare] Black Deathcharger (150pt -> 1c)
  (100016, 36, 12303, 0, 0), -- [rare] Black Zulian Panther (100pt -> 1c)
  (100016, 37, 80455, 0, 0), -- [rare] Brewfest Kodo (200pt -> 1c)
  (100016, 38, 81234, 0, 0), -- [rare] Brewfest Ram (100pt -> 1c)
  (100016, 39, 50072, 0, 0), -- [rare] Brown Tallstrider (50pt -> 1c)
  (100016, 40, 81242, 0, 0), -- [rare] Cloudwing Hippogryph (150pt -> 1c)
  (100016, 41, 12327, 0, 0), -- [rare] Golden Leopard (100pt -> 1c)
  (100016, 42, 50073, 0, 0), -- [rare] Gray Tallstrider (50pt -> 1c)
  (100016, 43, 81239, 0, 0), -- [rare] Happy Dalaran Cloud (150pt -> 1c)
  (100016, 44, 80447, 0, 0), -- [rare] Horde Worg (150pt -> 1c)
  (100016, 45, 50071, 0, 0), -- [rare] Ivory Tallstrider (50pt -> 1c)
  (100016, 46, 80431, 0, 0), -- [rare] Magic Rooster (150pt -> 1c)
  (100016, 47, 50074, 0, 0), -- [rare] Pink Tallstrider (50pt -> 1c)
  (100016, 48, 50406, 0, 0), -- [rare] Shadowhorn Stag (100pt -> 1c)
  (100016, 49, 12325, 0, 0), -- [rare] Spotted Leopard (100pt -> 1c)
  (100016, 50, 8630, 0, 0), -- [rare] Stranglethorn Tiger (100pt -> 1c)
  (100016, 51, 81227, 0, 0), -- [rare] Striped Dawnsaber (100pt -> 1c)
  (100016, 52, 81231, 0, 0), -- [rare] Tamed Rak'Shiri (100pt -> 1c)
  (100016, 53, 12326, 0, 0), -- [rare] Tawny Leopard (100pt -> 1c)
  (100016, 54, 81238, 0, 0), -- [rare] Turbo-Charged Flying Machine (250pt -> 1c)
  (100016, 55, 50076, 0, 0), -- [rare] Turquoise Tallstrider (50pt -> 1c)
  (100016, 56, 50407, 0, 0), -- [rare] Twilight Unicorn (100pt -> 1c)
  (100016, 57, 81235, 0, 0), -- [rare] Vermilion Deathcharger (150pt -> 1c)
  (100016, 58, 50399, 0, 0), -- [rare] White Unicorn (100pt -> 1c)
  (100016, 59, 50400, 0, 0), -- [rare] Zhevra (100pt -> 1c)
  --  Companions
  (100016, 60, 36506, 0, 0), -- Alliance Lion Cub (75pt -> 1c)
  (100016, 61, 50083, 0, 0), -- Azure Whelpling (40pt -> 1c)
  (100016, 62, 36504, 0, 0), -- Azure Wind Serpent (75pt -> 1c)
  (100016, 63, 36509, 0, 0), -- Black Panther Cub (75pt -> 1c)
  (100016, 64, 50013, 0, 0), -- Bone Golem (40pt -> 1c)
  (100016, 65, 36515, 0, 0), -- Cheetah Cub (75pt -> 1c)
  (100016, 66, 36516, 0, 0), -- Chestnut (75pt -> 1c)
  (100016, 67, 83301, 0, 0), -- Core Hound Pup (150pt -> 1c)
  (100016, 68, 36505, 0, 0), -- Crimson Sabercat Cub (75pt -> 1c)
  (100016, 69, 81207, 0, 0), -- Dalaran Cloud Familiar (75pt -> 1c)
  (100016, 70, 36502, 0, 0), -- Dark Wind Serpent (75pt -> 1c)
  (100016, 71, 13584, 0, 0), -- Diablo Stone (40pt -> 1c)
  (100016, 72, 36503, 0, 0), -- Emerald Wind Serpent (75pt -> 1c)
  (100016, 73, 36514, 0, 0), -- Frostsaber Cub (75pt -> 1c)
  (100016, 74, 50085, 0, 0), -- Frostwolf Ghostpup (40pt -> 1c)
  (100016, 75, 69006, 0, 0), -- Glitterwing (100pt -> 1c)
  (100016, 76, 50084, 0, 0), -- Kirin Tor Familiar (40pt -> 1c)
  (100016, 77, 83300, 0, 0), -- Lil' K.T. (150pt -> 1c)
  (100016, 78, 83302, 0, 0), -- Lil' Ragnaros (150pt -> 1c)
  (100016, 79, 50019, 0, 0), -- Moonkin Hatchling (40pt -> 1c)
  (100016, 80, 20371, 0, 0), -- Murky (40pt -> 1c)
  (100016, 81, 36511, 0, 0), -- Nightsaber Cub (75pt -> 1c)
  (100016, 82, 13583, 0, 0), -- Panda Collar (40pt -> 1c)
  (100016, 83, 69004, 0, 0), -- Pengu (100pt -> 1c)
  (100016, 84, 81150, 0, 0), -- Phoenix Hatchling (75pt -> 1c)
  (100016, 85, 22781, 0, 0), -- Poley (40pt -> 1c)
  (100016, 86, 36512, 0, 0), -- Snow Cub (75pt -> 1c)
  (100016, 87, 81258, 0, 0), -- Spectral Cub (100pt -> 1c)
  (100016, 88, 81151, 0, 0), -- Spectral Faeling (40pt -> 1c)
  (100016, 89, 36507, 0, 0), -- Spot (75pt -> 1c)
  (100016, 90, 36513, 0, 0), -- Stangletorn Tiger Cub (75pt -> 1c)
  (100016, 91, 36500, 0, 0), -- Sunfire Fox (75pt -> 1c)
  (100016, 92, 36501, 0, 0), -- Tangerine Wind Serpent (75pt -> 1c)
  (100016, 93, 36510, 0, 0), -- Tawny (75pt -> 1c)
  (100016, 94, 51007, 0, 0), -- Teldrassil Sproutling (40pt -> 1c)
  (100016, 95, 36508, 0, 0); -- Twilight Paws (75pt -> 1c)

-- ---------------------------------------------------------------------------
--  Illusionist Sarielle (100017) - 114 items
-- ---------------------------------------------------------------------------
DELETE FROM npc_vendor        WHERE entry = 100017;
DELETE FROM creature_template WHERE entry = 100017;

--  npc_flags = 4 is UNIT_NPC_FLAG_VENDOR in the 1.12 enum this server uses.
--  faction 35 = friendly to everyone.
INSERT INTO creature_template
  (entry, name, subname, display_id1, faction, npc_flags,
   level_min, level_max, health_min, health_max, armor, unit_class, type,
   speed_walk, speed_run, scale, base_attack_time, ranged_attack_time,
   dmg_min, dmg_max, movement_type, inhabit_type, regeneration, ai_name)
VALUES
  (100017, 'Illusionist Sarielle', 'Fashion & Illusions', 1497, 35, 4,
   60, 60, 4007, 4007, 3272, 1, 7,
   1, 1.14286, 1, 2000, 2000,
   103.4, 129.8, 0, 3, 3, '');

--  maxcount = 0 -> unlimited stock (no restock timer, so incrtime = 0)
INSERT INTO npc_vendor (entry, slot, item, maxcount, incrtime) VALUES
  --  Skins
  (100017, 1, 50290, 0, 0), -- Mark of Azotha (80pt -> 1c)
  (100017, 2, 50207, 0, 0), -- Mark of Blackrock Clan I (80pt -> 1c)
  (100017, 3, 51920, 0, 0), -- Mark of Darkness (80pt -> 1c)
  (100017, 4, 81210, 0, 0), -- Mark of Death I (80pt -> 1c)
  (100017, 5, 81229, 0, 0), -- Mark of Death II (80pt -> 1c)
  (100017, 6, 50291, 0, 0), -- Mark of Fel Power (80pt -> 1c)
  (100017, 7, 83091, 0, 0), -- Mark of Frost Affinity (80pt -> 1c)
  (100017, 8, 81209, 0, 0), -- Mark of Magic Addiction (80pt -> 1c)
  (100017, 9, 83092, 0, 0), -- Mark of Nature I (80pt -> 1c)
  (100017, 10, 83099, 0, 0), -- Mark of Nature II (80pt -> 1c)
  (100017, 11, 83100, 0, 0), -- Mark of Nature III (80pt -> 1c)
  (100017, 12, 50106, 0, 0), -- Mark of Necromancy I (80pt -> 1c)
  (100017, 13, 81230, 0, 0), -- Mark of Necromancy III (80pt -> 1c)
  (100017, 14, 50212, 0, 0), -- Mark of Radioactive Fallout (80pt -> 1c)
  (100017, 15, 50292, 0, 0), -- Mark of the Arcane Binder (80pt -> 1c)
  (100017, 16, 50221, 0, 0), -- Mark of the Blackrock Clan II (80pt -> 1c)
  (100017, 17, 50208, 0, 0), -- Mark of the Burning Blade (80pt -> 1c)
  (100017, 18, 83090, 0, 0), -- Mark of the Dalaran Legacy (80pt -> 1c)
  (100017, 19, 50205, 0, 0), -- Mark of the Dark Iron Clan (80pt -> 1c)
  (100017, 20, 81206, 0, 0), -- Mark of the Dark Ranger (80pt -> 1c)
  (100017, 21, 51010, 0, 0), -- Mark of the Dark Trolls (80pt -> 1c)
  (100017, 22, 61105, 0, 0), -- Mark of the Demon Hunter (80pt -> 1c)
  (100017, 23, 50223, 0, 0), -- Mark of the Dreadskull Clan I (80pt -> 1c)
  (100017, 24, 50224, 0, 0), -- Mark of the Dreadskull Clan II (80pt -> 1c)
  (100017, 25, 81255, 0, 0), -- Mark of the Dreadskull Clan III (80pt -> 1c)
  (100017, 26, 50206, 0, 0), -- Mark of the Earthen Dwarves (80pt -> 1c)
  (100017, 27, 51011, 0, 0), -- Mark of the Frozen Trolls (80pt -> 1c)
  (100017, 28, 50209, 0, 0), -- Mark of the Mag'har Heritage (80pt -> 1c)
  (100017, 29, 61106, 0, 0), -- Mark of the Necromancy II (80pt -> 1c)
  (100017, 30, 50105, 0, 0), -- Mark of the Scarlet Crusade (80pt -> 1c)
  (100017, 31, 81228, 0, 0), -- Mark of the Spirit Walker (80pt -> 1c)
  (100017, 32, 50204, 0, 0), -- Mark of the Wildhammer Clan I (80pt -> 1c)
  (100017, 33, 50250, 0, 0), -- Mark of the Wildhammer Clan II (80pt -> 1c)
  (100017, 34, 50251, 0, 0), -- Mark of the Wildhammer Clan III (80pt -> 1c)
  (100017, 35, 50252, 0, 0), -- Mark of the Wildhammer Clan IV (80pt -> 1c)
  (100017, 36, 81208, 0, 0), -- Mark of Zul'Farrak Curse (80pt -> 1c)
  (100017, 37, 61104, 0, 0), -- Night Elf: Demon (80pt -> 1c)
  (100017, 38, 50220, 0, 0), -- Orc: Blackrock II (80pt -> 1c)
  (100017, 39, 51921, 0, 0), -- Undead: Blood Widow (80pt -> 1c)
  --  Fashion
  (100017, 40, 41091, 0, 0), -- Apparel of the Bells (100pt -> 1g)
  (100017, 41, 50091, 0, 0), -- Black Mageweave Tabard (80pt -> 5g)
  (100017, 42, 69132, 0, 0), -- Blooming Wisteria Robes (100pt -> 0.0277g)
  (100017, 43, 69101, 0, 0), -- Crimson Warbrands (100pt -> 0.0001g)
  (100017, 44, 69123, 0, 0), -- Dalaran Archmage Robe (90pt -> 0.0277g)
  (100017, 45, 23710, 0, 0), -- Darkmoon Faire Tabard (100pt -> 5g)
  (100017, 46, 69150, 0, 0), -- Dawn Star Gown (100pt -> 0.0277g)
  (100017, 47, 69149, 0, 0), -- Dusk Star Gown (100pt -> 0.0277g)
  (100017, 48, 69147, 0, 0), -- Evening Star Gown (100pt -> 0.0277g)
  (100017, 49, 69118, 0, 0), -- Gilnean Archmage Robe (90pt -> 0.0277g)
  (100017, 50, 50044, 0, 0), -- Gold Mageweave Tabard (80pt -> 5g)
  (100017, 51, 50376, 0, 0), -- Hillsbrad Tabard (80pt -> 5g)
  (100017, 52, 81204, 0, 0), -- Illidari Tabard (90pt -> 5g)
  (100017, 53, 69100, 0, 0), -- Illidari Warbrands (100pt -> 0.0001g)
  (100017, 54, 69117, 0, 0), -- Jaina Proudmoore Robe (90pt -> 0.0277g)
  (100017, 55, 41092, 0, 0), -- Jingle Belle Frock (100pt -> 1g)
  (100017, 56, 69122, 0, 0), -- Kul Tiras Archmage Robe (90pt -> 0.0277g)
  (100017, 57, 69124, 0, 0), -- Lordaeron Archmage Robe (90pt -> 0.0277g)
  (100017, 58, 69146, 0, 0), -- Midnight Star Gown (100pt -> 0.0277g)
  (100017, 59, 69151, 0, 0), -- Morning Star Gown (80pt -> 0.0277g)
  (100017, 60, 69103, 0, 0), -- Netherforged Warbrands (100pt -> 0.0001g)
  (100017, 61, 69131, 0, 0), -- Peach Garden Robes (100pt -> 0.0277g)
  (100017, 62, 50038, 0, 0), -- Red Mageweave Tabard (80pt -> 5g)
  (100017, 63, 69128, 0, 0), -- Robes of Spring (100pt -> 0.0277g)
  (100017, 64, 69127, 0, 0), -- Robes of the Lotus Pond (90pt -> 0.0277g)
  (100017, 65, 68070, 0, 0), -- Robes of the Moonless Night (100pt -> 0.0277g)
  (100017, 66, 83479, 0, 0), -- Romantic Pink Corset Dress (125pt -> 0.0277g)
  (100017, 67, 83478, 0, 0), -- Romantic Red Corset Dress (125pt -> 0.0277g)
  (100017, 68, 69121, 0, 0), -- Scarlet Archmage Robe (90pt -> 0.0277g)
  (100017, 69, 69152, 0, 0), -- Silver Star Sandals (80pt -> 0.0005g)
  (100017, 70, 80310, 0, 0), -- Sin'dorei Tabard (90pt -> 5g)
  (100017, 71, 69119, 0, 0), -- Stormwind Archmage Robe (90pt -> 0.0277g)
  (100017, 72, 50086, 0, 0), -- Stromgarde Tabard (80pt -> 5g)
  (100017, 73, 81084, 0, 0), -- Tabard of Arcane (100pt -> 5g)
  (100017, 74, 81082, 0, 0), -- Tabard of Brilliance (100pt -> 5g)
  (100017, 75, 23705, 0, 0), -- Tabard of Flame (100pt -> 5g)
  (100017, 76, 23709, 0, 0), -- Tabard of Frost (100pt -> 5g)
  (100017, 77, 81081, 0, 0), -- Tabard of Fury (100pt -> 5g)
  (100017, 78, 81085, 0, 0), -- Tabard of Nature (100pt -> 5g)
  (100017, 79, 81087, 0, 0), -- Tabard of Summer Flames (90pt -> 5g)
  (100017, 80, 50092, 0, 0), -- Tabard of the Crimson Legion (80pt -> 5g)
  (100017, 81, 81088, 0, 0), -- Tabard of the Midsummer Solstice (90pt -> 5g)
  (100017, 82, 80314, 0, 0), -- Tabard of the Scourge (100pt -> 5g)
  (100017, 83, 81083, 0, 0), -- Tabard of Void (100pt -> 5g)
  (100017, 84, 69125, 0, 0), -- Theramore Archmage Robe (90pt -> 0.0277g)
  (100017, 85, 69120, 0, 0), -- Tirisfal Archmage Robe (90pt -> 0.0277g)
  (100017, 86, 69130, 0, 0), -- Traditional New Year Robes (100pt -> 0.0277g)
  (100017, 87, 69148, 0, 0), -- Twilight Star Gown (100pt -> 0.0277g)
  (100017, 88, 81203, 0, 0), -- Violet Eye Tabard (90pt -> 5g)
  (100017, 89, 69102, 0, 0), -- Voidbound Warbrands (100pt -> 0.0001g)
  (100017, 90, 69129, 0, 0), -- Year of the Dragon Robes (100pt -> 0.0277g)
  --  Illusions
  (100017, 91, 51206, 0, 0), -- Tome of Disguise: Banshee (80pt -> 1c)
  (100017, 92, 92035, 0, 0), -- Tome of Disguise: Blue Dragonkin (80pt -> 1c)
  (100017, 93, 92034, 0, 0), -- Tome of Disguise: Bronze Dragonkin (80pt -> 1c)
  (100017, 94, 92032, 0, 0), -- Tome of Disguise: Chromatic Dragonkin (80pt -> 1c)
  (100017, 95, 50408, 0, 0), -- Tome of Disguise: Dryad (80pt -> 1c)
  (100017, 96, 92030, 0, 0), -- Tome of Disguise: Felguard (80pt -> 1c)
  (100017, 97, 51253, 0, 0), -- Tome of Disguise: Furbolg (80pt -> 1c)
  (100017, 98, 51205, 0, 0), -- Tome of Disguise: Ghost (80pt -> 1c)
  (100017, 99, 92039, 0, 0), -- Tome of Disguise: Ghoul (80pt -> 1c)
  (100017, 100, 92037, 0, 0), -- Tome of Disguise: Gilnean Worgen (80pt -> 1c)
  (100017, 101, 80648, 0, 0), -- Tome of Disguise: Gnoll (80pt -> 1c)
  (100017, 102, 92041, 0, 0), -- Tome of Disguise: Incubus (80pt -> 1c)
  (100017, 103, 92033, 0, 0), -- Tome of Disguise: Infinite Dragonkin (80pt -> 1c)
  (100017, 104, 92036, 0, 0), -- Tome of Disguise: Murloc (80pt -> 1c)
  (100017, 105, 81145, 0, 0), -- Tome of Disguise: Pandaren (80pt -> 1c)
  (100017, 106, 92031, 0, 0), -- Tome of Disguise: Prismatic Dragonkin (80pt -> 1c)
  (100017, 107, 51215, 0, 0), -- Tome of Disguise: Satyr (80pt -> 1c)
  (100017, 108, 92040, 0, 0), -- Tome of Disguise: Scourge Mage (80pt -> 1c)
  (100017, 109, 80694, 0, 0), -- Tome of Disguise: Scourge Warrior (80pt -> 1c)
  (100017, 110, 51208, 0, 0), -- Tome of Disguise: Succubus (80pt -> 1c)
  (100017, 111, 53008, 0, 0), -- Tome of Disguise: Two-headed Ogre (80pt -> 1c)
  (100017, 112, 51201, 0, 0), -- Tome of Disguise: Worgen (80pt -> 1c)
  (100017, 113, 51065, 0, 0), -- Tome of Disguise: Wraith (80pt -> 1c)
  (100017, 114, 92038, 0, 0); -- Tome of Disguise: Zombie (80pt -> 1c)

-- ---------------------------------------------------------------------------
--  Steward Bellamy (100018) - 35 items
-- ---------------------------------------------------------------------------
DELETE FROM npc_vendor        WHERE entry = 100018;
DELETE FROM creature_template WHERE entry = 100018;

--  npc_flags = 4 is UNIT_NPC_FLAG_VENDOR in the 1.12 enum this server uses.
--  faction 35 = friendly to everyone.
INSERT INTO creature_template
  (entry, name, subname, display_id1, faction, npc_flags,
   level_min, level_max, health_min, health_max, armor, unit_class, type,
   speed_walk, speed_run, scale, base_attack_time, ranged_attack_time,
   dmg_min, dmg_max, movement_type, inhabit_type, regeneration, ai_name)
VALUES
  (100018, 'Steward Bellamy', 'Curios & Services', 1492, 35, 4,
   60, 60, 4007, 4007, 3272, 1, 7,
   1, 1.14286, 1, 2000, 2000,
   103.4, 129.8, 0, 3, 3, '');

--  maxcount = 0 -> unlimited stock (no restock timer, so incrtime = 0)
INSERT INTO npc_vendor (entry, slot, item, maxcount, incrtime) VALUES
  --  Miscellaneous
  (100018, 1, 51306, 0, 0), -- [rare] Large Pouch of Fashion Coins (100pt -> 1c)
  (100018, 2, 80699, 0, 0), -- Appearance Change Token (80pt -> 1c)
  (100018, 3, 50000, 0, 0), -- Character Name Change (80pt -> 1c)
  (100018, 4, 80499, 0, 0), -- Guild Name Change Token (150pt -> 1c)
  (100018, 5, 80555, 0, 0), -- Pet Name Change Token (50pt -> 1c)
  (100018, 6, 50605, 0, 0), -- Race Change Token: Dwarf (150pt -> 1c)
  (100018, 7, 50604, 0, 0), -- Race Change Token: Gnome (150pt -> 1c)
  (100018, 8, 50613, 0, 0), -- Race Change Token: Goblin (150pt -> 1c)
  (100018, 9, 50612, 0, 0), -- Race Change Token: High Elf (150pt -> 1c)
  (100018, 10, 50603, 0, 0), -- Race Change Token: Human (150pt -> 1c)
  (100018, 11, 50606, 0, 0), -- Race Change Token: Night Elf (150pt -> 1c)
  (100018, 12, 50607, 0, 0), -- Race Change Token: Orc (150pt -> 1c)
  (100018, 13, 50609, 0, 0), -- Race Change Token: Tauren (150pt -> 1c)
  (100018, 14, 50608, 0, 0), -- Race Change Token: Troll (150pt -> 1c)
  (100018, 15, 50610, 0, 0), -- Race Change Token: Undead (150pt -> 1c)
  --  Gameplay
  (100018, 16, 31825, 0, 0), -- [rare] Blazing Forge Kit (125pt -> 1c)
  (100018, 17, 51715, 0, 0), -- [rare] Goblin Brainwashing Device (100pt -> 1c)
  (100018, 18, 31826, 0, 0), -- [rare] Tome of Tactical Escape I (125pt -> 1c)
  (100018, 19, 50004, 0, 0), -- [uncommon] Portable Pocket Dimension (150pt -> 1c)
  (100018, 20, 51421, 0, 0), -- Caravan Kodo (125pt -> 1c)
  (100018, 21, 50005, 0, 0), -- Field Repair Bot 75B (100pt -> 1c)
  (100018, 22, 50007, 0, 0), -- Forworn Mule (125pt -> 1c)
  (100018, 23, 50003, 0, 0), -- Loremaster's Backpack (100pt -> 1c)
  (100018, 24, 50009, 0, 0), -- Mechanical Auctioneer (100pt -> 1c)
  (100018, 25, 50011, 0, 0), -- MOLL-E, Remote Mail Terminal (100pt -> 1c)
  (100018, 26, 50602, 0, 0), -- Summon: Auctioneer (100pt -> 1c)
  --  Glyphs
  (100018, 27, 51432, 0, 0), -- Glyph of Stars (75pt -> 1c)
  (100018, 28, 92042, 0, 0), -- Glyph of the Autumn Treant (75pt -> 1c)
  (100018, 29, 51056, 0, 0), -- Glyph of the Forest Stag (75pt -> 1c)
  (100018, 30, 51431, 0, 0), -- Glyph of the Frostkin (75pt -> 1c)
  (100018, 31, 51057, 0, 0), -- Glyph of the Frostsaber (75pt -> 1c)
  (100018, 32, 92043, 0, 0), -- Glyph of the Golden Treant (75pt -> 1c)
  (100018, 33, 51266, 0, 0), -- Glyph of the Ice Bear (75pt -> 1c)
  (100018, 34, 51830, 0, 0), -- Glyph of the Orca (75pt -> 1c)
  (100018, 35, 92044, 0, 0); -- Glyph of the Withered Treant (75pt -> 1c)

-- ---------------------------------------------------------------------------
--  REVERT - uncomment to undo everything above
-- ---------------------------------------------------------------------------
--  None of these items had a price before, so putting them back to 0 restores
--  the stock rows exactly.
--
-- UPDATE item_template SET buy_price = 0
--  WHERE entry IN (
--    1041, 5663, 8630, 8635, 12302, 12303, 12325, 12326, 12327, 13328,
--    13583, 13584, 18768, 20371, 22781, 23193, 31825, 31826, 36500, 36501,
--    36502, 36503, 36504, 36505, 36506, 36507, 36508, 36509, 36510, 36511,
--    36512, 36513, 36514, 36515, 36516, 50000, 50003, 50004, 50005, 50007,
--    50009, 50011, 50013, 50019, 50071, 50072, 50073, 50074, 50076, 50083,
--    50084, 50085, 50105, 50106, 50204, 50205, 50206, 50207, 50208, 50209,
--    50212, 50220, 50221, 50223, 50224, 50250, 50251, 50252, 50290, 50291,
--    50292, 50399, 50400, 50401, 50402, 50403, 50404, 50406, 50407, 50408,
--    50536, 50602, 50603, 50604, 50605, 50606, 50607, 50608, 50609, 50610,
--    50612, 50613, 51007, 51010, 51011, 51056, 51057, 51065, 51201, 51205,
--    51206, 51208, 51215, 51253, 51266, 51306, 51421, 51431, 51432, 51715,
--    51830, 51920, 51921, 53008, 61104, 61105, 61106, 69004, 69006, 80430,
--    80431, 80443, 80447, 80449, 80455, 80499, 80555, 80648, 80694, 80699,
--    81091, 81100, 81102, 81120, 81121, 81145, 81150, 81151, 81153, 81154,
--    81155, 81158, 81206, 81207, 81208, 81209, 81210, 81227, 81228, 81229,
--    81230, 81231, 81232, 81234, 81235, 81236, 81238, 81239, 81242, 81255,
--    81258, 83090, 83091, 83092, 83099, 83100, 83150, 83151, 83152, 83154,
--    83155, 83158, 83300, 83301, 83302, 92030, 92031, 92032, 92033, 92034,
--    92035, 92036, 92037, 92038, 92039, 92040, 92041, 92042, 92043, 92044,
--    92050, 92051, 92052);
--
-- DELETE FROM npc_vendor        WHERE entry BETWEEN 100016 AND 100018;
-- DELETE FROM creature          WHERE id    BETWEEN 100016 AND 100018;
-- DELETE FROM creature_template WHERE entry BETWEEN 100016 AND 100018;
