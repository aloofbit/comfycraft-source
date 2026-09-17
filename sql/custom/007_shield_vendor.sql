-- ============================================================================
--  Custom NPC: level 60 shield vendor  (tw_world)
-- ============================================================================
--  Shieldmaster Brannd (creature 100004) sells every shield in the database
--  that requires level 60.
--
--  SELECTION: class = 4 (armour), subclass = 6 (shield), required_level = 60,
--  buy_price > 0. That is 50 shields, sorted best first (quality descending,
--  then item level). All 50 shields at that level are purchasable - unlike the
--  sword list, nothing had to be dropped for a zero price.
--
--  Armour subclasses in this core: 0 misc, 1 cloth, 2 leather, 3 mail,
--  4 plate, 5 buckler (unused), 6 shield, 7 libram, 8 idol, 9 totem.
--
--  Includes Plate Wall Shield (3988), quality 0 - a genuine grey shield at
--  ilvl 65, not test data.
--
--  SCOPE NOTE: this is level 60 only, matching the sword vendor. The database
--  holds 453 shields overall (447 purchasable) across every level; widen by
--  dropping the required_level clause if you want the lot.
--
--  Re-runnable. Apply with:
--    DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_world < sql\custom\007_shield_vendor.sql
--  then restart mangosd. Spawn with:  .npc add 100004
-- ============================================================================

SET @VENDOR := 100004;

DELETE FROM npc_vendor        WHERE entry = @VENDOR;
DELETE FROM creature_template WHERE entry = @VENDOR;

INSERT INTO creature_template
  (entry, name, subname, display_id1, faction, npc_flags,
   level_min, level_max, health_min, health_max, armor, unit_class, type,
   speed_walk, speed_run, scale, base_attack_time, ranged_attack_time,
   dmg_min, dmg_max, movement_type, inhabit_type, regeneration, ai_name)
VALUES
  (@VENDOR, 'Shieldmaster Brannd', 'Shields', 775, 35, 4,
   60, 60, 4007, 4007, 3272, 1, 7,
   1, 1.14286, 1, 2000, 2000,
   103.4, 129.8, 0, 3, 3, '');

INSERT INTO npc_vendor (entry, slot, item, maxcount, incrtime) VALUES
  (@VENDOR, 1, 55349, 0, 0), -- [q4] Nethraka, Wing of Oblivion (ilvl 96, 105.4g)
  (@VENDOR, 2, 55121, 0, 0), -- [q4] Bulwark of Enduring Earth (ilvl 92, 97.1g)
  (@VENDOR, 3, 22819, 0, 0), -- [q4] Shield of Condemnation (ilvl 92, 97.1g)
  (@VENDOR, 4, 23043, 0, 0), -- [q4] The Face of Death (ilvl 90, 87.4g)
  (@VENDOR, 5, 84033, 0, 0), -- [q4] Bulwark of the Light (ilvl 88, 62.2g)
  (@VENDOR, 6, 55090, 0, 0), -- [q4] Scaleshield of Azure Flight (ilvl 88, 62.2g)
  (@VENDOR, 7, 23075, 0, 0), -- [q4] Death's Bargain (ilvl 83, 66.7g)
  (@VENDOR, 8, 1316602, 0, 0), -- [q4] Death's Bargain (ilvl 83, 66.7g)
  (@VENDOR, 9, 22818, 0, 0), -- [q4] The Plague Bearer (ilvl 83, 62.4g)
  (@VENDOR, 10, 18825, 0, 0), -- [q4] Veteran's Aegis (ilvl 83, 15.9g)
  (@VENDOR, 11, 18826, 0, 0), -- [q4] Veteran's Shield Wall (ilvl 83, 16.0g)
  (@VENDOR, 12, 61526, 0, 0), -- [q4] Jadestone Protector (ilvl 81, 49.2g)
  (@VENDOR, 13, 21610, 0, 0), -- [q4] Wormscale Blocker (ilvl 81, 61.4g)
  (@VENDOR, 14, 61238, 0, 0), -- [q4] Scaleshield of Emerald Flight (ilvl 78, 38.3g)
  (@VENDOR, 15, 33155, 0, 0), -- [q4] Scaleshield of Obsidian Flight (ilvl 78, 48.0g)
  (@VENDOR, 16, 23238, 0, 0), -- [q4] Stygian Buckler (ilvl 78, 64.3g)
  (@VENDOR, 17, 19349, 0, 0), -- [q4] Elementium Reinforced Bulwark (ilvl 77, 49.0g)
  (@VENDOR, 18, 33073, 0, 0), -- [q4] Philosopher's Barrier (ilvl 76, 48.0g)
  (@VENDOR, 19, 19348, 0, 0), -- [q4] Red Dragonscale Protector (ilvl 76, 42.2g)
  (@VENDOR, 20, 65103, 0, 0), -- [q4] Shell of the Great Sleeper (ilvl 76, 48.0g)
  (@VENDOR, 21, 33254, 0, 0), -- [q4] Shield of Wailing Souls (ilvl 76, 48.0g)
  (@VENDOR, 22, 33262, 0, 0), -- [q4] Wall of Earthen Attunement (ilvl 76, 48.1g)
  (@VENDOR, 23, 17106, 0, 0), -- [q4] Malistar's Defender (ilvl 75, 44.0g)
  (@VENDOR, 24, 33885, 0, 0), -- [q4] Partisan's Aegis (ilvl 72, 13.9g)
  (@VENDOR, 25, 33906, 0, 0), -- [q4] Partisan's Shield Wall (ilvl 72, 13.9g)
  (@VENDOR, 26, 33135, 0, 0), -- [q4] Bulwark of Unshaken Earth (ilvl 70, 18.3g)
  (@VENDOR, 27, 22198, 0, 0), -- [q4] Jagged Obsidian Shield (ilvl 70, 33.7g)
  (@VENDOR, 28, 19862, 0, 0), -- [q4] Aegis of the Blood God (ilvl 68, 32.5g)
  (@VENDOR, 29, 21485, 0, 0), -- [q4] Buru's Skull Fragment (ilvl 68, 30.3g)
  (@VENDOR, 30, 20688, 0, 0), -- [q4] Earthen Guard (ilvl 68, 28.3g)
  (@VENDOR, 31, 17066, 0, 0), -- [q4] Drillborer Disk (ilvl 67, 29.0g)
  (@VENDOR, 32, 55498, 0, 0), -- [q4] Clamshell of the Depths (ilvl 66, 40.3g)
  (@VENDOR, 33, 51796, 0, 0), -- [q4] Shield of Consuming Darkness (ilvl 66, 5.7g)
  (@VENDOR, 34, 58242, 0, 0), -- [q4] Sulfuron Aegis (ilvl 66, 40.3g)
  (@VENDOR, 35, 18168, 0, 0), -- [q4] Force Reactive Disk (ilvl 65, 28.2g)
  (@VENDOR, 36, 19321, 0, 0), -- [q4] The Immovable Object (ilvl 65, 79.5g)
  (@VENDOR, 37, 61276, 0, 0), -- [q4] Hyperchromatic Deflector (ilvl 60, 23.1g)
  (@VENDOR, 38, 50417, 0, 0), -- [q3] Time-shifting Wheel (ilvl 70, 19.3g)
  (@VENDOR, 39, 19915, 0, 0), -- [q3] Zulian Defender (ilvl 68, 24.4g)
  (@VENDOR, 40, 61028, 0, 0), -- [q3] Bulwark of the Crimson Guard (ilvl 66, 15.2g)
  (@VENDOR, 41, 83444, 0, 0), -- [q3] Bonewall (ilvl 65, 15.2g)
  (@VENDOR, 42, 80543, 0, 0), -- [q3] Quel'dorei Defender's Bulwark (ilvl 65, 9.4g)
  (@VENDOR, 43, 80643, 0, 0), -- [q3] Revantusk Defender's Bulwark (ilvl 65, 9.4g)
  (@VENDOR, 44, 60726, 0, 0), -- [q3] Spellguard's Shield (ilvl 65, 10.5g)
  (@VENDOR, 45, 40003, 0, 0), -- [q3] Vault's Defender (ilvl 65, 15.4g)
  (@VENDOR, 46, 14982, 0, 0), -- [q2] Exalted Shield (ilvl 65, 17.1g)
  (@VENDOR, 47, 10367, 0, 0), -- [q2] Hyperion Shield (ilvl 65, 16.5g)
  (@VENDOR, 48, 10271, 0, 0), -- [q2] Masterwork Shield (ilvl 65, 16.3g)
  (@VENDOR, 49, 15687, 0, 0), -- [q2] Triumphant Shield (ilvl 65, 16.2g)
  (@VENDOR, 50, 3988, 0, 0); -- [q0] Plate Wall Shield (ilvl 65, 6.5g)
