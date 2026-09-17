-- ============================================================================
--  Custom NPC: shirt vendor  (tw_world)
-- ============================================================================
--  Tailor Merribeth (creature 100008) sells 106 distinct shirts - every shirt
--  in the database a vendor can sell, with duplicate names collapsed.
--
--  SELECTION: inventory_type = 4 (shirt) AND buy_price > 0, grouped by name so
--  repeated entries (two "Ale-Stained Anniversary Shirt" rows, for instance)
--  appear once. 113 purchasable rows become 106 distinct shirts.
--
--  Shirts are cosmetic - they occupy the shirt slot, give no stats, and are
--  mostly quality 1, so this is a wardrobe rather than a gear vendor. Prices
--  run from a few copper to 20g.
--
--  42 shirts are absent: buy_price = 0 makes them unvendorable, which covers
--  all 5 epic and the single artifact-quality shirt. Use .additem for those.
--
--  Re-runnable. Apply with:
--    DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_world < sql\custom\009_shirt_vendor.sql
--  then restart mangosd - creature_template is cached at startup, so a new NPC
--  is NOT visible to a running server (".npc add" answers "invalid creature id"
--  until you restart). Spawn with:  .npc add 100008
-- ============================================================================

SET @VENDOR := 100008;

DELETE FROM npc_vendor        WHERE entry = @VENDOR;
DELETE FROM creature_template WHERE entry = @VENDOR;

INSERT INTO creature_template
  (entry, name, subname, display_id1, faction, npc_flags,
   level_min, level_max, health_min, health_max, armor, unit_class, type,
   speed_walk, speed_run, scale, base_attack_time, ranged_attack_time,
   dmg_min, dmg_max, movement_type, inhabit_type, regeneration, ai_name)
VALUES
  (@VENDOR, 'Tailor Merribeth', 'Shirts', 6631, 35, 4,
   60, 60, 4007, 4007, 3272, 1, 7,
   1, 1.14286, 1, 2000, 2000,
   103.4, 129.8, 0, 3, 3, '');

INSERT INTO npc_vendor (entry, slot, item, maxcount, incrtime) VALUES
  (@VENDOR, 1, 93088, 0, 0), -- [q3] Red Serpent Warbrands (0.00g)
  (@VENDOR, 2, 6097, 0, 0), -- [q1] Acolyte's Shirt (0.00g)
  (@VENDOR, 3, 41469, 0, 0), -- [q1] Ale-Stained Anniversary Shirt (0.00g)
  (@VENDOR, 4, 41293, 0, 0), -- [q1] All Black Waistcoat Set (20.00g)
  (@VENDOR, 5, 6096, 0, 0), -- [q1] Apprentice's Shirt (0.00g)
  (@VENDOR, 6, 41271, 0, 0), -- [q1] Black Darcy Shirt (20.00g)
  (@VENDOR, 7, 41268, 0, 0), -- [q1] Black Dress Shirt (20.00g)
  (@VENDOR, 8, 4336, 0, 0), -- [q1] Black Swashbuckler's Shirt (0.60g)
  (@VENDOR, 9, 41277, 0, 0), -- [q1] Black Tie Black Waistcoat (20.00g)
  (@VENDOR, 10, 41278, 0, 0), -- [q1] Black Tie Blue Waistcoat (20.00g)
  (@VENDOR, 11, 41279, 0, 0), -- [q1] Black Tie Brown Waistcoat (20.00g)
  (@VENDOR, 12, 41280, 0, 0), -- [q1] Black Tie Green Waistcoat (20.00g)
  (@VENDOR, 13, 41281, 0, 0), -- [q1] Black Tie Grey Waistcoat (20.00g)
  (@VENDOR, 14, 41282, 0, 0), -- [q1] Black Tie Lavender Waistcoat (20.00g)
  (@VENDOR, 15, 41276, 0, 0), -- [q1] Black Tie Light Blue Waistcoat (20.00g)
  (@VENDOR, 16, 41283, 0, 0), -- [q1] Black Tie Mint Waistcoat (20.00g)
  (@VENDOR, 17, 41284, 0, 0), -- [q1] Black Tie Pink Waistcoat (20.00g)
  (@VENDOR, 18, 41285, 0, 0), -- [q1] Black Tie Plum Waistcoat (20.00g)
  (@VENDOR, 19, 41286, 0, 0), -- [q1] Black Tie Purple Waistcoat (20.00g)
  (@VENDOR, 20, 41287, 0, 0), -- [q1] Black Tie Red Waistcoat (20.00g)
  (@VENDOR, 21, 41288, 0, 0), -- [q1] Black Tie Spring Green Waistcoat (20.00g)
  (@VENDOR, 22, 41289, 0, 0), -- [q1] Black Tie Tan Waistcoat (20.00g)
  (@VENDOR, 23, 41290, 0, 0), -- [q1] Black Tie Teal Waistcoat (20.00g)
  (@VENDOR, 24, 41291, 0, 0), -- [q1] Black Tie White Waistcoat (20.00g)
  (@VENDOR, 25, 41292, 0, 0), -- [q1] Black Tie Yellow Waistcoat (20.00g)
  (@VENDOR, 26, 69105, 0, 0), -- [q1] Blood Draconic Tattoo (0.00g)
  (@VENDOR, 27, 69111, 0, 0), -- [q1] Bloodied Bandages (15.00g)
  (@VENDOR, 28, 2577, 0, 0), -- [q1] Blue Linen Shirt (0.03g)
  (@VENDOR, 29, 142, 0, 0), -- [q1] Bluebell Bow Corset Shirt (0.00g)
  (@VENDOR, 30, 3426, 0, 0), -- [q1] Bold Yellow Shirt (0.40g)
  (@VENDOR, 31, 6125, 0, 0), -- [q1] Brawler's Harness (0.00g)
  (@VENDOR, 32, 4332, 0, 0), -- [q1] Bright Yellow Shirt (0.20g)
  (@VENDOR, 33, 4344, 0, 0), -- [q1] Brown Linen Shirt (0.01g)
  (@VENDOR, 34, 3342, 0, 0), -- [q1] Captain Sander's Shirt (0.06g)
  (@VENDOR, 35, 16059, 0, 0), -- [q1] Common Brown Shirt (0.04g)
  (@VENDOR, 36, 3428, 0, 0), -- [q1] Common Gray Shirt (0.04g)
  (@VENDOR, 37, 16060, 0, 0), -- [q1] Common White Shirt (0.04g)
  (@VENDOR, 38, 69101, 0, 0), -- [q1] Crimson Warbrands (0.00g)
  (@VENDOR, 39, 4333, 0, 0), -- [q1] Dark Silk Shirt (0.48g)
  (@VENDOR, 40, 5107, 0, 0), -- [q1] Deckhand's Shirt (0.07g)
  (@VENDOR, 41, 123, 0, 0), -- [q1] Deprecated Orc Apprentice Shirt (0.00g)
  (@VENDOR, 42, 3149, 0, 0), -- [q1] Deprecated Ripped Vest (0.00g)
  (@VENDOR, 43, 3147, 0, 0), -- [q1] Deprecated Tattered Shirt (0.00g)
  (@VENDOR, 44, 5090, 0, 0), -- [q1] Deprecated Torn Shirt (0.00g)
  (@VENDOR, 45, 3148, 0, 0), -- [q1] Deprecated Work Shirt (0.00g)
  (@VENDOR, 46, 859, 0, 0), -- [q1] Fine Cloth Shirt (0.04g)
  (@VENDOR, 47, 964, 0, 0), -- [q1] Finely-Tailored Linen Shirt (0.01g)
  (@VENDOR, 48, 49, 0, 0), -- [q1] Footpad's Shirt (0.00g)
  (@VENDOR, 49, 4334, 0, 0), -- [q1] Formal White Shirt (0.22g)
  (@VENDOR, 50, 69109, 0, 0), -- [q1] Fresh Bandages (15.00g)
  (@VENDOR, 51, 2587, 0, 0), -- [q1] Gray Woolen Shirt (0.08g)
  (@VENDOR, 52, 17723, 0, 0), -- [q1] Green Holiday Shirt (0.30g)
  (@VENDOR, 53, 2579, 0, 0), -- [q1] Green Linen Shirt (0.02g)
  (@VENDOR, 54, 69100, 0, 0), -- [q1] Illidari Warbrands (0.00g)
  (@VENDOR, 55, 94, 0, 0), -- [q1] Lavender Bow Corset Shirt (0.00g)
  (@VENDOR, 56, 10054, 0, 0), -- [q1] Lavender Mageweave Shirt (1.20g)
  (@VENDOR, 57, 128, 0, 0), -- [q1] Lemon Bow Corset Shirt (0.00g)
  (@VENDOR, 58, 11840, 0, 0), -- [q1] Master Builder's Shirt (2.86g)
  (@VENDOR, 59, 112, 0, 0), -- [q1] Mint Bow Corset Shirt (0.00g)
  (@VENDOR, 60, 53, 0, 0), -- [q1] Neophyte's Shirt (0.00g)
  (@VENDOR, 61, 69103, 0, 0), -- [q1] Netherforged Warbrands (0.00g)
  (@VENDOR, 62, 138, 0, 0), -- [q1] New Leaf Bow Corset Shirt (0.00g)
  (@VENDOR, 63, 69106, 0, 0), -- [q1] Night Draconic Tattoo (0.00g)
  (@VENDOR, 64, 69110, 0, 0), -- [q1] Old Bandages (15.00g)
  (@VENDOR, 65, 51435, 0, 0), -- [q1] Old-Fashioned Loose Shirt (0.04g)
  (@VENDOR, 66, 93, 0, 0), -- [q1] OLDDwarven Initiate's Shirt (0.00g)
  (@VENDOR, 67, 89, 0, 0), -- [q1] OLDThick Trapper's Shirt (0.00g)
  (@VENDOR, 68, 119, 0, 0), -- [q1] Onyx Bow Corset Shirt (0.00g)
  (@VENDOR, 69, 10056, 0, 0), -- [q1] Orange Mageweave Shirt (0.60g)
  (@VENDOR, 70, 10052, 0, 0), -- [q1] Orange Martial Shirt (0.60g)
  (@VENDOR, 71, 10055, 0, 0), -- [q1] Pink Mageweave Shirt (1.20g)
  (@VENDOR, 72, 154, 0, 0), -- [q1] Primitive Mantle (0.00g)
  (@VENDOR, 73, 38, 0, 0), -- [q1] Recruit's Shirt (0.00g)
  (@VENDOR, 74, 2575, 0, 0), -- [q1] Red Linen Shirt (0.01g)
  (@VENDOR, 75, 6796, 0, 0), -- [q1] Red Swashbuckler's Shirt (0.30g)
  (@VENDOR, 76, 4335, 0, 0), -- [q1] Rich Purple Silk Shirt (0.60g)
  (@VENDOR, 77, 41273, 0, 0), -- [q1] Rolled-Sleeve Black Darcy Shirt (20.00g)
  (@VENDOR, 78, 41269, 0, 0), -- [q1] Rolled-Sleeve Black Dress Shirt (20.00g)
  (@VENDOR, 79, 41272, 0, 0), -- [q1] Rolled-Sleeve White Darcy Shirt (20.00g)
  (@VENDOR, 80, 41267, 0, 0), -- [q1] Rolled-Sleeve White Dress Shirt (20.00g)
  (@VENDOR, 81, 41275, 0, 0), -- [q1] Rolled-Sleeve White Shirt with Black Cravat (20.00g)
  (@VENDOR, 82, 86, 0, 0), -- [q1] Rose Bow Corset Shirt (0.00g)
  (@VENDOR, 83, 148, 0, 0), -- [q1] Rugged Trapper's Shirt (0.00g)
  (@VENDOR, 84, 14617, 0, 0), -- [q1] Sawbones Shirt (2.50g)
  (@VENDOR, 85, 69104, 0, 0), -- [q1] Spectral Warbrands (0.00g)
  (@VENDOR, 86, 45, 0, 0), -- [q1] Squire's Shirt (0.00g)
  (@VENDOR, 87, 3427, 0, 0), -- [q1] Stylish Black Shirt (0.60g)
  (@VENDOR, 88, 6384, 0, 0), -- [q1] Stylish Blue Shirt (0.10g)
  (@VENDOR, 89, 6385, 0, 0), -- [q1] Stylish Green Shirt (0.10g)
  (@VENDOR, 90, 4330, 0, 0), -- [q1] Stylish Red Shirt (0.10g)
  (@VENDOR, 91, 5091, 0, 0), -- [q1] test Eric Shirt (0.00g)
  (@VENDOR, 92, 2105, 0, 0), -- [q1] Thug Shirt (0.00g)
  (@VENDOR, 93, 127, 0, 0), -- [q1] Trapper's Shirt (0.00g)
  (@VENDOR, 94, 10034, 0, 0), -- [q1] Tuxedo Shirt (0.80g)
  (@VENDOR, 95, 69102, 0, 0), -- [q1] Voidbound Warbrands (0.00g)
  (@VENDOR, 96, 41270, 0, 0), -- [q1] White Darcy Shirt (20.00g)
  (@VENDOR, 97, 41266, 0, 0), -- [q1] White Dress Shirt (20.00g)
  (@VENDOR, 98, 2576, 0, 0), -- [q1] White Linen Shirt (0.03g)
  (@VENDOR, 99, 41274, 0, 0), -- [q1] White Shirt with Black Cravat (20.00g)
  (@VENDOR, 100, 6795, 0, 0), -- [q1] White Swashbuckler's Shirt (0.20g)
  (@VENDOR, 101, 6833, 0, 0), -- [q1] White Tuxedo Shirt (0.20g)
  (@VENDOR, 102, 69112, 0, 0), -- [q1] Worryingly Bloodied Bandages (15.00g)
  (@VENDOR, 103, 24143, 0, 0), -- [q0] Initiate's Shirt (0.00g)
  (@VENDOR, 104, 20897, 0, 0), -- [q0] Lookout's Shirt (0.00g)
  (@VENDOR, 105, 18231, 0, 0), -- [q0] Sleeveless T-Shirt (0.14g)
  (@VENDOR, 106, 20901, 0, 0); -- [q0] Warder's Shirt (0.00g)
