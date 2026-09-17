-- ============================================================================
--  Custom NPC: level 60 one-handed sword vendor  (tw_world)
-- ============================================================================
--  Blademaster Koren (creature 100003) sells every one-handed sword in the
--  database that requires level 60.
--
--  SELECTION: class = 2 (weapon), subclass = 7 (one-handed sword),
--  required_level = 60, buy_price > 0. That is 59 swords, sorted best first
--  (quality descending, then item level).
--
--  Weapon subclasses in this core: 0 axe1h, 1 axe2h, 4 mace1h, 5 mace2h,
--  6 polearm, 7 sword1h, 8 sword2h, 10 staff, 13 fist, 15 dagger, 19 wand.
--
--  ONE SWORD IS DELIBERATELY ABSENT: Andonisus, Reaper of Souls (22736, ilvl
--  100) has buy_price = 0, and a vendor cannot sell a zero-price item - it
--  would simply not appear. Give it with .additem 22736 if you want it.
--
--  INCLUDES THE WARGLAIVES: The Twin Blades of Azzinoth (18582) and both
--  Warglaive of Azzinoth halves (18583/18584) are quality 6, ilvl 100, and sit
--  in this DB at required_level 60, so "all one-handed swords" catches them.
--  Delete those three rows if you would rather they stayed unobtainable.
--
--  Re-runnable: the DELETEs make this safe to apply repeatedly.
--
--  Apply with:
--    DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_world < sql\custom\006_onehand_sword_vendor.sql
--  then restart mangosd (creature_template is cached at startup).
--  Spawn with:  .npc add 100003
-- ============================================================================

SET @VENDOR := 100003;

DELETE FROM npc_vendor        WHERE entry = @VENDOR;
DELETE FROM creature_template WHERE entry = @VENDOR;

INSERT INTO creature_template
  (entry, name, subname, display_id1, faction, npc_flags,
   level_min, level_max, health_min, health_max, armor, unit_class, type,
   speed_walk, speed_run, scale, base_attack_time, ranged_attack_time,
   dmg_min, dmg_max, movement_type, inhabit_type, regeneration, ai_name)
VALUES
  (@VENDOR, 'Blademaster Koren', 'One-Handed Swords', 18647, 35, 4,
   60, 60, 4007, 4007, 3272, 1, 7,
   1, 1.14286, 1, 2000, 2000,
   103.4, 129.8, 0, 3, 3, '');

-- maxcount 0 = unlimited stock. Price is item_template.buy_price.
INSERT INTO npc_vendor (entry, slot, item, maxcount, incrtime) VALUES
  (@VENDOR, 1, 18582, 0, 0), -- [q6] The Twin Blades of Azzinoth (ilvl 100, 612.2g)
  (@VENDOR, 2, 18584, 0, 0), -- [q6] Warglaive of Azzinoth (Left) (ilvl 100, 558.1g)
  (@VENDOR, 3, 18583, 0, 0), -- [q6] Warglaive of Azzinoth (Right) (ilvl 100, 556.0g)
  (@VENDOR, 4, 23051, 0, 0), -- [q5] Glaive of the Defender (ilvl 86, 126.6g)
  (@VENDOR, 5, 55129, 0, 0), -- [q4] Desecration (ilvl 92, 111.3g)
  (@VENDOR, 6, 23054, 0, 0), -- [q4] Gressil, Dawn of Ruin (ilvl 89, 139.2g)
  (@VENDOR, 7, 23577, 0, 0), -- [q4] The Hungering Cold (ilvl 89, 134.6g)
  (@VENDOR, 8, 33330, 0, 0), -- [q4] Ephanel, Dawn of Ruination (ilvl 83, 91.8g)
  (@VENDOR, 9, 23014, 0, 0), -- [q4] Iblis, Blade of the Fallen Seraph (ilvl 83, 91.8g)
  (@VENDOR, 10, 33331, 0, 0), -- [q4] Lophanel, Dusk of Calamity (ilvl 83, 91.8g)
  (@VENDOR, 11, 33332, 0, 0), -- [q4] Thil'phoral, the Omen of Aln (ilvl 83, 91.8g)
  (@VENDOR, 12, 16345, 0, 0), -- [q4] Veteran's Blade (ilvl 83, 24.7g)
  (@VENDOR, 13, 12584, 0, 0), -- [q4] Veteran's Longsword (ilvl 83, 24.8g)
  (@VENDOR, 14, 23467, 0, 0), -- [q4] Veteran's Quickblade (ilvl 83, 22.8g)
  (@VENDOR, 15, 23456, 0, 0), -- [q4] Veteran's Swiftblade (ilvl 83, 22.8g)
  (@VENDOR, 16, 22806, 0, 0), -- [q4] Widow's Remorse (ilvl 83, 91.1g)
  (@VENDOR, 17, 22807, 0, 0), -- [q4] Wraith Blade (ilvl 83, 100.8g)
  (@VENDOR, 18, 1784250, 0, 0), -- [q4] Wraith Blade (ilvl 83, 100.8g)
  (@VENDOR, 19, 1980975, 0, 0), -- [q4] Wraith Blade (ilvl 83, 100.8g)
  (@VENDOR, 20, 61523, 0, 0), -- [q4] Crystal Sword of the Blossom (ilvl 81, 60.1g)
  (@VENDOR, 21, 19457, 0, 0), -- [q4] 1500 Test sword 80 purple (ilvl 80, 83.9g)
  (@VENDOR, 22, 19456, 0, 0), -- [q4] 2900 Test sword 80 purple (ilvl 80, 83.9g)
  (@VENDOR, 23, 21622, 0, 0), -- [q4] Sharpened Silithid Femur (ilvl 78, 80.5g)
  (@VENDOR, 24, 1984562, 0, 0), -- [q4] Sharpened Silithid Femur (ilvl 78, 80.5g)
  (@VENDOR, 25, 21650, 0, 0), -- [q4] Ancient Qiraji Ripper (ilvl 77, 73.3g)
  (@VENDOR, 26, 19352, 0, 0), -- [q4] Chromatically Tempered Sword (ilvl 77, 79.5g)
  (@VENDOR, 27, 22805, 0, 0), -- [q4] Naxxramas Sword 1H 1 [PH] (ilvl 77, 74.7g)
  (@VENDOR, 28, 33157, 0, 0), -- [q4] Broodwarden's Bulwarkblade (ilvl 76, 75.9g)
  (@VENDOR, 29, 19351, 0, 0), -- [q4] Maladath, Runed Blade of the Black Flight (ilvl 76, 70.0g)
  (@VENDOR, 30, 20577, 0, 0), -- [q4] Nightmare Blade (ilvl 76, 54.0g)
  (@VENDOR, 31, 17075, 0, 0), -- [q4] Vis'kag the Bloodletter (ilvl 76, 67.6g)
  (@VENDOR, 32, 83487, 0, 0), -- [q4] Blade of the Fallen Star (ilvl 75, 48.9g)
  (@VENDOR, 33, 33907, 0, 0), -- [q4] Partisan's Blade (ilvl 72, 19.7g)
  (@VENDOR, 34, 33886, 0, 0), -- [q4] Partisan's Longsword (ilvl 72, 19.8g)
  (@VENDOR, 35, 33913, 0, 0), -- [q4] Partisan's Quickblade (ilvl 72, 17.8g)
  (@VENDOR, 36, 33892, 0, 0), -- [q4] Partisan's Swiftblade (ilvl 72, 17.8g)
  (@VENDOR, 37, 17103, 0, 0), -- [q4] Azuresong Mageblade (ilvl 71, 55.9g)
  (@VENDOR, 38, 61453, 0, 0), -- [q4] Anasterian's Legacy (ilvl 70, 46.1g)
  (@VENDOR, 39, 19168, 0, 0), -- [q4] Blackguard (ilvl 70, 51.4g)
  (@VENDOR, 40, 18832, 0, 0), -- [q4] Brutality Blade (ilvl 70, 52.0g)
  (@VENDOR, 41, 19864, 0, 0), -- [q4] Bloodcaller (ilvl 68, 51.2g)
  (@VENDOR, 42, 83564, 0, 0), -- [q4] Tempest's Rage (ilvl 68, 41.4g)
  (@VENDOR, 43, 19865, 0, 0), -- [q4] Warblade of the Hakkari (ilvl 68, 51.4g)
  (@VENDOR, 44, 19867, 0, 0), -- [q4] Bloodlord's Defender (ilvl 66, 43.7g)
  (@VENDOR, 45, 65008, 0, 0), -- [q4] Dream's Herald (ilvl 66, 35.2g)
  (@VENDOR, 46, 19866, 0, 0), -- [q4] Warblade of the Hakkari (ilvl 66, 43.5g)
  (@VENDOR, 47, 17015, 0, 0), -- [q4] Dark Iron Reaver (ilvl 65, 43.5g)
  (@VENDOR, 48, 1728, 0, 0), -- [q4] Teebu's Blazing Longsword (ilvl 65, 43.5g)
  (@VENDOR, 49, 55030, 0, 0), -- [q4] Aliden's Prejudice (ilvl 63, 27.8g)
  (@VENDOR, 50, 19550, 0, 0), -- [q3] Legionnaire's Sword (ilvl 71, 27.5g)
  (@VENDOR, 51, 19554, 0, 0), -- [q3] Protector's Sword (ilvl 71, 27.5g)
  (@VENDOR, 52, 19968, 0, 0), -- [q3] Fiery Retributer (ilvl 68, 37.2g)
  (@VENDOR, 53, 19964, 0, 0), -- [q3] Renataki's Soul Conduit (ilvl 68, 36.6g)
  (@VENDOR, 54, 19901, 0, 0), -- [q3] Zulian Slicer (ilvl 68, 35.3g)
  (@VENDOR, 55, 60384, 0, 0), -- [q3] Fleet Scimitar (ilvl 65, 25.7g)
  (@VENDOR, 56, 80536, 0, 0), -- [q3] Quel'dorei Assassin's Sword (ilvl 65, 9.4g)
  (@VENDOR, 57, 80535, 0, 0), -- [q3] Quel'dorei Defender's Deflector (ilvl 65, 9.4g)
  (@VENDOR, 58, 80636, 0, 0), -- [q3] Revantusk Stalker's Blade (ilvl 65, 9.4g)
  (@VENDOR, 59, 15221, 0, 0); -- [q2] Holy War Sword (ilvl 65, 26.0g)
