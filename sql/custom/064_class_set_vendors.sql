-- ============================================================================
--  Custom NPCs: class armour sets, the remaining seven classes  (tw_world)
-- ============================================================================
--  001 gave the warrior his sets and 037 gave the druid hers. This finishes
--  the job: paladin, hunter, rogue, priest, shaman, mage and warlock, same
--  shape and same rules as those two -- a plain vendor window, prices are
--  item_template.buy_price, D1 -> D2 -> T1 -> T2 -> T3, each set head to
--  hands.
--
--  FINDING THE SETS: match on item_template.set_id, NEVER on item names. Set
--  names come from server\dbc\ItemSet.dbc (field 1 is the English name); the
--  world DB has no set-name table, and Turtle renames sets -- the druid D2 is
--  Moonheart here rather than Feralheart, so a name is no guide at all.
--
--  The five tiers sit in five blocks of set ids, which is why this is one
--  file rather than seven:
--
--    D1  181-189   allowable_class = -1, gated by ARMOUR TYPE
--    D2  511-519   allowable_class = -1 (519 carries every class bit instead)
--    T1  201-209   class-flagged        T2  210-218        T3  521-530
--
--  TWO TRAPS IN THOSE RANGES, both of which bite a range-based select:
--
--  1. D1, T1 and T2 share one class order -- cloth mage/priest/warlock,
--     leather rogue/druid, mail hunter/shaman, plate paladin/warrior -- so
--     181/201/210 are all mage and 189/209/218 all warrior. D2 AND T3 DO
--     NOT. D2 runs warrior, rogue, druid, priest, hunter, paladin, mage,
--     warlock, shaman. Do not carry a class's position across blocks; every
--     set id below is named explicitly for that reason.
--
--  2. set_id 522 sits inside the T3 range and IS NOT A T3 SET. It is
--     "Champion's Guard", a rogue PvP set at ilvl 66-71. Selecting 521-530
--     as a range picks it up silently.
--
--  NOTE the dungeon sets have allowable_class = -1, not a class flag: like
--  the warrior and druid ones they are gated by armour type (cloth 1, leather
--  2, mail 3, plate 4) rather than by class. Querying a class's sets with
--  allowable_class & <flag> silently misses BOTH dungeon tiers.
--
--  DUPLICATE PIECES: several sets carry more rows than they have slots --
--  Dragonstalker has 14 for 8 slots, Judgement 12, Vestments of Faith 10.
--  These are alternate APPEARANCES, identical but for display_id. This file
--  keeps ONE piece per equip slot, the lowest entry, i.e. the classic look --
--  the same choice 001 and 037 made. 13 rows were dropped that way and all
--  13 happened to share their twin's name, so deduping by name would have
--  worked here too; per SLOT is used because it is the rule that cannot be
--  fooled.
--
--  The RENAMED copies are a separate matter, and they sort themselves out.
--  Crown of Might 47240 sits beside Helm of Might 16866 with identical
--  stats, and it carries set_id 673 "Armor of Might" -- NOT 209. That is a
--  complete 8-piece twin of Battlegear of Might at entries 47240-47247,
--  against the classic 16861-16868, same ilvl 66 throughout. Turtle keeps
--  these in a parallel block around 641-680, at least one per class, and
--  the piece counts there do not always line up (641 carries 16), so read
--  that block as "where the renamed copies live" rather than a strict
--  mirror. Either way, selecting the CLASSIC set id excludes every renamed
--  copy without trying to -- and that block is where to look if a
--  look-alike vendor is ever wanted.
--
--  Every piece was checked for buy_price > 0; an item priced 0 cannot be
--  vendored at all.
--
--  EXPECT 41 ROWS AND 18 VISIBLE. The vendor window is filtered per player:
--  HandleListInventoryOpcode (ItemHandler.cpp:950) skips an item when the
--  viewer's class is not in AllowableClass AND the item is BIND_WHEN_PICKED_UP
--  -- both conditions. The tier sets are class-flagged and BoP, so they are
--  invisible to every other class; the dungeon sets are allowable_class = -1
--  and always show. A character of the wrong class therefore sees 18 of the 41
--  (the two dungeon sets, plus the two bind-on-EQUIP Felheart pieces) -- two
--  pages instead of five, with nothing wrong. The full 41 appear for the right
--  class, or for anyone with .gm on, since IsGameMaster() skips that filter
--  along with the reputation and condition_id ones.
--
--  Re-runnable: the DELETEs make this safe to apply repeatedly.
--
--  Apply with (PowerShell - '<' is a reserved operator there, so pipe):
--    Get-Content sql\custom\041_class_set_vendors.sql | DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_world
--  then, in the mangosd console (no leading dot), no restart needed, and IN
--  THIS ORDER - reload npc_vendor validates its rows against the CACHED
--  creature templates, so reversed every row is dropped with "npc_vendor has
--  data for nonexistent creature" in the log and the windows open empty in
--  game with no error shown to the player:
--    reload creature_template
--    reload npc_vendor
--
--  Then check with  .vendor  , which lists them and flags anything unloaded.
--  Spawn them in-game as GM, standing where you want each one -- the other
--  custom vendors are clustered in Ironforge around (-4905, -940, 501.5):
--    .npc add 100019    Vindicator Sareth
--    .npc add 100020    Pathfinder Ryla
--    .npc add 100021    Shadowbroker Vex
--    .npc add 100022    Confessor Miriam
--    .npc add 100023    Farseer Nahla
--    .npc add 100024    Archmage Theryn
--    .npc add 100025    Dreadweaver Malia
-- ============================================================================

-- ---------------------------------------------------------------------------
--  Vindicator Sareth (100019) - Paladin, 41 pieces
-- ---------------------------------------------------------------------------
--    D1  Lightforge Armor             set_id 188   8 pieces   ilvl 57-63
--    D2  Soulforge Armor              set_id 516   8 pieces   ilvl 60
--    T1  Lawbringer Armor             set_id 208   8 pieces   ilvl 66
--    T2  Judgement Armor              set_id 217   8 pieces   ilvl 76
--    T3  Redemption Armor             set_id 528   9 pieces   ilvl 86-92
DELETE FROM npc_vendor        WHERE entry = 100019;
DELETE FROM creature_template WHERE entry = 100019;

--  npc_flags = 4 is UNIT_NPC_FLAG_VENDOR in the 1.12 enum this server uses.
--  faction 35 = friendly to everyone. display 3346 is a paladin trainer's.
INSERT INTO creature_template
  (entry, name, subname, display_id1, faction, npc_flags,
   level_min, level_max, health_min, health_max, armor, unit_class, type,
   speed_walk, speed_run, scale, base_attack_time, ranged_attack_time,
   dmg_min, dmg_max, movement_type, inhabit_type, regeneration, ai_name)
VALUES
  (100019, 'Vindicator Sareth', 'Paladin Armaments', 3346, 35, 4,
   60, 60, 4007, 4007, 3272, 1, 7,
   1, 1.14286, 1, 2000, 2000,
   103.4, 129.8, 0, 3, 3, '');

--  maxcount = 0 -> unlimited stock (no restock timer, so incrtime = 0)
INSERT INTO npc_vendor (entry, slot, item, maxcount, incrtime) VALUES
  (100019, 1, 16727, 0, 0), -- [D1] Lightforge Helm (head, ilvl 62, 8.0g)
  (100019, 2, 16729, 0, 0), -- [D1] Lightforge Spaulders (shoulder, ilvl 60, 7.3g)
  (100019, 3, 16726, 0, 0), -- [D1] Lightforge Breastplate (chest, ilvl 63, 11.1g)
  (100019, 4, 16723, 0, 0), -- [D1] Lightforge Belt (waist, ilvl 58, 4.3g)
  (100019, 5, 16728, 0, 0), -- [D1] Lightforge Legplates (legs, ilvl 61, 10.2g)
  (100019, 6, 16725, 0, 0), -- [D1] Lightforge Boots (feet, ilvl 59, 6.8g)
  (100019, 7, 16722, 0, 0), -- [D1] Lightforge Bracers (wrists, ilvl 57, 4.1g)
  (100019, 8, 16724, 0, 0), -- [D1] Lightforge Gauntlets (hands, ilvl 59, 4.5g)
  (100019, 9, 22091, 0, 0), -- [D2] Soulforge Helm (head, ilvl 60, 9.9g)
  (100019, 10, 22093, 0, 0), -- [D2] Soulforge Spaulders (shoulder, ilvl 60, 9.6g)
  (100019, 11, 22089, 0, 0), -- [D2] Soulforge Breastplate (chest, ilvl 60, 13.1g)
  (100019, 12, 22086, 0, 0), -- [D2] Soulforge Belt (waist, ilvl 60, 6.2g)
  (100019, 13, 22092, 0, 0), -- [D2] Soulforge Legplates (legs, ilvl 60, 13.3g)
  (100019, 14, 22087, 0, 0), -- [D2] Soulforge Boots (feet, ilvl 60, 9.8g)
  (100019, 15, 22088, 0, 0), -- [D2] Soulforge Bracers (wrists, ilvl 60, 6.3g)
  (100019, 16, 22090, 0, 0), -- [D2] Soulforge Gauntlets (hands, ilvl 60, 5.0g)
  (100019, 17, 16854, 0, 0), -- [T1] Lawbringer Helm (head, ilvl 66, 14.0g)
  (100019, 18, 16856, 0, 0), -- [T1] Lawbringer Spaulders (shoulder, ilvl 66, 12.7g)
  (100019, 19, 16853, 0, 0), -- [T1] Lawbringer Breastplate (chest, ilvl 66, 18.6g)
  (100019, 20, 16858, 0, 0), -- [T1] Lawbringer Belt (waist, ilvl 66, 8.6g)
  (100019, 21, 16855, 0, 0), -- [T1] Lawbringer Legplates (legs, ilvl 66, 16.9g)
  (100019, 22, 16859, 0, 0), -- [T1] Lawbringer Boots (feet, ilvl 66, 12.9g)
  (100019, 23, 16857, 0, 0), -- [T1] Lawbringer Bracers (wrists, ilvl 66, 8.5g)
  (100019, 24, 16860, 0, 0), -- [T1] Lawbringer Gloves (hands, ilvl 66, 8.6g)
  (100019, 25, 16955, 0, 0), -- [T2] Judgement Helm (head, ilvl 76, 21.2g)
  (100019, 26, 16953, 0, 0), -- [T2] Judgement Spaulders (shoulder, ilvl 76, 21.1g)
  (100019, 27, 16958, 0, 0), -- [T2] Judgement Breastplate (chest, ilvl 76, 29.4g)
  (100019, 28, 16952, 0, 0), -- [T2] Judgement Belt (waist, ilvl 76, 14.0g)
  (100019, 29, 16954, 0, 0), -- [T2] Judgement Legplates (legs, ilvl 76, 28.2g)
  (100019, 30, 16957, 0, 0), -- [T2] Judgement Boots (feet, ilvl 76, 22.0g)
  (100019, 31, 16951, 0, 0), -- [T2] Judgement Bracers (wrists, ilvl 76, 13.9g)
  (100019, 32, 16956, 0, 0), -- [T2] Judgement Gloves (hands, ilvl 76, 14.2g)
  (100019, 33, 22428, 0, 0), -- [T3] Redemption Helm (head, ilvl 88, 38.6g)
  (100019, 34, 22429, 0, 0), -- [T3] Redemption Spaulders (shoulder, ilvl 86, 35.2g)
  (100019, 35, 22425, 0, 0), -- [T3] Redemption Tunic (chest, ilvl 92, 61.9g)
  (100019, 36, 22431, 0, 0), -- [T3] Redemption Belt (waist, ilvl 88, 26.0g)
  (100019, 37, 22427, 0, 0), -- [T3] Redemption Pants (legs, ilvl 88, 51.3g)
  (100019, 38, 22430, 0, 0), -- [T3] Redemption Boots (feet, ilvl 86, 35.3g)
  (100019, 39, 22424, 0, 0), -- [T3] Redemption Bracers (wrists, ilvl 88, 25.4g)
  (100019, 40, 22426, 0, 0), -- [T3] Redemption Gloves (hands, ilvl 88, 25.5g)
  (100019, 41, 23066, 0, 0); -- [T3] Ring of Redemption (finger, ilvl 92, 24.1g)

-- ---------------------------------------------------------------------------
--  Pathfinder Ryla (100020) - Hunter, 41 pieces
-- ---------------------------------------------------------------------------
--    D1  Beaststalker Armor           set_id 186   8 pieces   ilvl 57-63
--    D2  Beastmaster Armor            set_id 515   8 pieces   ilvl 60
--    T1  Giantstalker Armor           set_id 206   8 pieces   ilvl 66
--    T2  Dragonstalker Armor          set_id 215   8 pieces   ilvl 76
--    T3  Cryptstalker Armor           set_id 530   9 pieces   ilvl 86-92
DELETE FROM npc_vendor        WHERE entry = 100020;
DELETE FROM creature_template WHERE entry = 100020;

--  npc_flags = 4 is UNIT_NPC_FLAG_VENDOR in the 1.12 enum this server uses.
--  faction 35 = friendly to everyone. display 3395 is a hunter trainer's.
INSERT INTO creature_template
  (entry, name, subname, display_id1, faction, npc_flags,
   level_min, level_max, health_min, health_max, armor, unit_class, type,
   speed_walk, speed_run, scale, base_attack_time, ranged_attack_time,
   dmg_min, dmg_max, movement_type, inhabit_type, regeneration, ai_name)
VALUES
  (100020, 'Pathfinder Ryla', 'Hunter Armor', 3395, 35, 4,
   60, 60, 4007, 4007, 3272, 1, 7,
   1, 1.14286, 1, 2000, 2000,
   103.4, 129.8, 0, 3, 3, '');

--  maxcount = 0 -> unlimited stock (no restock timer, so incrtime = 0)
INSERT INTO npc_vendor (entry, slot, item, maxcount, incrtime) VALUES
  (100020, 1, 16677, 0, 0), -- [D1] Beaststalker's Cap (head, ilvl 62, 12.4g)
  (100020, 2, 16679, 0, 0), -- [D1] Beaststalker's Mantle (shoulder, ilvl 60, 11.4g)
  (100020, 3, 16674, 0, 0), -- [D1] Beaststalker's Tunic (chest, ilvl 63, 17.2g)
  (100020, 4, 16680, 0, 0), -- [D1] Beaststalker's Belt (waist, ilvl 58, 6.9g)
  (100020, 5, 16678, 0, 0), -- [D1] Beaststalker's Pants (legs, ilvl 61, 15.8g)
  (100020, 6, 16675, 0, 0), -- [D1] Beaststalker's Boots (feet, ilvl 59, 10.7g)
  (100020, 7, 16681, 0, 0), -- [D1] Beaststalker's Bindings (wrists, ilvl 57, 6.5g)
  (100020, 8, 16676, 0, 0), -- [D1] Beaststalker's Gloves (hands, ilvl 59, 7.1g)
  (100020, 9, 22013, 0, 0), -- [D2] Beastmaster's Cap (head, ilvl 60, 14.6g)
  (100020, 10, 22016, 0, 0), -- [D2] Beastmaster's Mantle (shoulder, ilvl 60, 14.2g)
  (100020, 11, 22060, 0, 0), -- [D2] Beastmaster's Tunic (chest, ilvl 60, 20.5g)
  (100020, 12, 22010, 0, 0), -- [D2] Beastmaster's Belt (waist, ilvl 60, 9.2g)
  (100020, 13, 22017, 0, 0), -- [D2] Beastmaster's Pants (legs, ilvl 60, 19.9g)
  (100020, 14, 22061, 0, 0), -- [D2] Beastmaster's Boots (feet, ilvl 60, 15.5g)
  (100020, 15, 22011, 0, 0), -- [D2] Beastmaster's Bindings (wrists, ilvl 60, 9.3g)
  (100020, 16, 22015, 0, 0), -- [D2] Beastmaster's Gloves (hands, ilvl 60, 7.5g)
  (100020, 17, 16846, 0, 0), -- [T1] Giantstalker's Helmet (head, ilvl 66, 20.4g)
  (100020, 18, 16848, 0, 0), -- [T1] Giantstalker's Epaulets (shoulder, ilvl 66, 20.6g)
  (100020, 19, 16845, 0, 0), -- [T1] Giantstalker's Breastplate (chest, ilvl 66, 27.1g)
  (100020, 20, 16851, 0, 0), -- [T1] Giantstalker's Belt (waist, ilvl 66, 13.8g)
  (100020, 21, 16847, 0, 0), -- [T1] Giantstalker's Leggings (legs, ilvl 66, 27.3g)
  (100020, 22, 16849, 0, 0), -- [T1] Giantstalker's Boots (feet, ilvl 66, 20.7g)
  (100020, 23, 16850, 0, 0), -- [T1] Giantstalker's Bracers (wrists, ilvl 66, 13.8g)
  (100020, 24, 16852, 0, 0), -- [T1] Giantstalker's Gloves (hands, ilvl 66, 13.9g)
  (100020, 25, 16939, 0, 0), -- [T2] Dragonstalker's Helm (head, ilvl 76, 32.3g)
  (100020, 26, 16937, 0, 0), -- [T2] Dragonstalker's Spaulders (shoulder, ilvl 76, 32.2g)
  (100020, 27, 16942, 0, 0), -- [T2] Dragonstalker's Breastplate (chest, ilvl 76, 44.7g)
  (100020, 28, 16936, 0, 0), -- [T2] Dragonstalker's Belt (waist, ilvl 76, 21.3g)
  (100020, 29, 16938, 0, 0), -- [T2] Dragonstalker's Legguards (legs, ilvl 76, 43.0g)
  (100020, 30, 16941, 0, 0), -- [T2] Dragonstalker's Greaves (feet, ilvl 76, 33.6g)
  (100020, 31, 16935, 0, 0), -- [T2] Dragonstalker's Bracers (wrists, ilvl 76, 21.2g)
  (100020, 32, 16940, 0, 0), -- [T2] Dragonstalker's Gauntlets (hands, ilvl 76, 21.6g)
  (100020, 33, 22438, 0, 0), -- [T3] Cryptstalker Headpiece (head, ilvl 88, 55.8g)
  (100020, 34, 22439, 0, 0), -- [T3] Cryptstalker Spaulders (shoulder, ilvl 86, 51.0g)
  (100020, 35, 22436, 0, 0), -- [T3] Cryptstalker Tunic (chest, ilvl 92, 96.7g)
  (100020, 36, 22442, 0, 0), -- [T3] Cryptstalker Girdle (waist, ilvl 88, 37.7g)
  (100020, 37, 22437, 0, 0), -- [T3] Cryptstalker Legguards (legs, ilvl 88, 79.8g)
  (100020, 38, 22440, 0, 0), -- [T3] Cryptstalker Boots (feet, ilvl 86, 51.2g)
  (100020, 39, 22443, 0, 0), -- [T3] Cryptstalker Wristguards (wrists, ilvl 88, 37.9g)
  (100020, 40, 22441, 0, 0), -- [T3] Cryptstalker Handguards (hands, ilvl 88, 37.6g)
  (100020, 41, 23067, 0, 0); -- [T3] Ring of the Cryptstalker (finger, ilvl 92, 24.1g)

-- ---------------------------------------------------------------------------
--  Shadowbroker Vex (100021) - Rogue, 41 pieces
-- ---------------------------------------------------------------------------
--    D1  Shadowcraft Armor            set_id 184   8 pieces   ilvl 57-63
--    D2  Darkmantle Armor             set_id 512   8 pieces   ilvl 60
--    T1  Nightslayer Armor            set_id 204   8 pieces   ilvl 66
--    T2  Bloodfang Armor              set_id 213   8 pieces   ilvl 76
--    T3  Bonescythe Armor             set_id 524   9 pieces   ilvl 86-92
DELETE FROM npc_vendor        WHERE entry = 100021;
DELETE FROM creature_template WHERE entry = 100021;

--  npc_flags = 4 is UNIT_NPC_FLAG_VENDOR in the 1.12 enum this server uses.
--  faction 35 = friendly to everyone. display 3351 is a rogue trainer's.
INSERT INTO creature_template
  (entry, name, subname, display_id1, faction, npc_flags,
   level_min, level_max, health_min, health_max, armor, unit_class, type,
   speed_walk, speed_run, scale, base_attack_time, ranged_attack_time,
   dmg_min, dmg_max, movement_type, inhabit_type, regeneration, ai_name)
VALUES
  (100021, 'Shadowbroker Vex', 'Rogue Leathers', 3351, 35, 4,
   60, 60, 4007, 4007, 3272, 1, 7,
   1, 1.14286, 1, 2000, 2000,
   103.4, 129.8, 0, 3, 3, '');

--  maxcount = 0 -> unlimited stock (no restock timer, so incrtime = 0)
INSERT INTO npc_vendor (entry, slot, item, maxcount, incrtime) VALUES
  (100021, 1, 16707, 0, 0), -- [D1] Shadowcraft Cap (head, ilvl 62, 10.0g)
  (100021, 2, 16708, 0, 0), -- [D1] Shadowcraft Spaulders (shoulder, ilvl 60, 9.1g)
  (100021, 3, 16721, 0, 0), -- [D1] Shadowcraft Tunic (chest, ilvl 63, 15.1g)
  (100021, 4, 16713, 0, 0), -- [D1] Shadowcraft Belt (waist, ilvl 58, 5.6g)
  (100021, 5, 16709, 0, 0), -- [D1] Shadowcraft Pants (legs, ilvl 61, 12.8g)
  (100021, 6, 16711, 0, 0), -- [D1] Shadowcraft Boots (feet, ilvl 59, 8.8g)
  (100021, 7, 16710, 0, 0), -- [D1] Shadowcraft Bracers (wrists, ilvl 57, 5.2g)
  (100021, 8, 16712, 0, 0), -- [D1] Shadowcraft Gloves (hands, ilvl 59, 5.9g)
  (100021, 9, 22005, 0, 0), -- [D2] Darkmantle Cap (head, ilvl 60, 13.1g)
  (100021, 10, 22008, 0, 0), -- [D2] Darkmantle Spaulders (shoulder, ilvl 60, 11.4g)
  (100021, 11, 22009, 0, 0), -- [D2] Darkmantle Tunic (chest, ilvl 60, 16.0g)
  (100021, 12, 22002, 0, 0), -- [D2] Darkmantle Belt (waist, ilvl 60, 8.0g)
  (100021, 13, 22007, 0, 0), -- [D2] Darkmantle Pants (legs, ilvl 60, 15.9g)
  (100021, 14, 22003, 0, 0), -- [D2] Darkmantle Boots (feet, ilvl 60, 12.6g)
  (100021, 15, 22004, 0, 0), -- [D2] Darkmantle Bracers (wrists, ilvl 60, 8.3g)
  (100021, 16, 22006, 0, 0), -- [D2] Darkmantle Gloves (hands, ilvl 60, 6.0g)
  (100021, 17, 16821, 0, 0), -- [T1] Nightslayer Cover (head, ilvl 66, 16.2g)
  (100021, 18, 16823, 0, 0), -- [T1] Nightslayer Shoulder Pads (shoulder, ilvl 66, 16.4g)
  (100021, 19, 16820, 0, 0), -- [T1] Nightslayer Chestpiece (chest, ilvl 66, 21.6g)
  (100021, 20, 16827, 0, 0), -- [T1] Nightslayer Belt (waist, ilvl 66, 11.1g)
  (100021, 21, 16822, 0, 0), -- [T1] Nightslayer Pants (legs, ilvl 66, 21.7g)
  (100021, 22, 16824, 0, 0), -- [T1] Nightslayer Boots (feet, ilvl 66, 16.4g)
  (100021, 23, 16825, 0, 0), -- [T1] Nightslayer Bracelets (wrists, ilvl 66, 11.0g)
  (100021, 24, 16826, 0, 0), -- [T1] Nightslayer Gloves (hands, ilvl 66, 11.0g)
  (100021, 25, 16908, 0, 0), -- [T2] Bloodfang Hood (head, ilvl 76, 27.9g)
  (100021, 26, 16832, 0, 0), -- [T2] Bloodfang Spaulders (shoulder, ilvl 76, 28.3g)
  (100021, 27, 16905, 0, 0), -- [T2] Bloodfang Chestpiece (chest, ilvl 76, 36.7g)
  (100021, 28, 16910, 0, 0), -- [T2] Bloodfang Belt (waist, ilvl 76, 17.4g)
  (100021, 29, 16909, 0, 0), -- [T2] Bloodfang Pants (legs, ilvl 76, 34.6g)
  (100021, 30, 16906, 0, 0), -- [T2] Bloodfang Boots (feet, ilvl 76, 27.7g)
  (100021, 31, 16911, 0, 0), -- [T2] Bloodfang Bracers (wrists, ilvl 76, 17.4g)
  (100021, 32, 16907, 0, 0), -- [T2] Bloodfang Gloves (hands, ilvl 76, 18.5g)
  (100021, 33, 22478, 0, 0), -- [T3] Bonescythe Helmet (head, ilvl 88, 46.5g)
  (100021, 34, 22479, 0, 0), -- [T3] Bonescythe Pauldrons (shoulder, ilvl 86, 42.3g)
  (100021, 35, 22476, 0, 0), -- [T3] Bonescythe Breastplate (chest, ilvl 92, 82.6g)
  (100021, 36, 22482, 0, 0), -- [T3] Bonescythe Waistguard (waist, ilvl 88, 31.4g)
  (100021, 37, 22477, 0, 0), -- [T3] Bonescythe Legplates (legs, ilvl 88, 68.2g)
  (100021, 38, 22480, 0, 0), -- [T3] Bonescythe Sabatons (feet, ilvl 86, 42.5g)
  (100021, 39, 22483, 0, 0), -- [T3] Bonescythe Bracers (wrists, ilvl 88, 31.6g)
  (100021, 40, 22481, 0, 0), -- [T3] Bonescythe Gauntlets (hands, ilvl 88, 31.3g)
  (100021, 41, 23060, 0, 0); -- [T3] Bonescythe Ring (finger, ilvl 92, 24.1g)

-- ---------------------------------------------------------------------------
--  Confessor Miriam (100022) - Priest, 41 pieces
-- ---------------------------------------------------------------------------
--    D1  Vestments of the Devout      set_id 182   8 pieces   ilvl 57-63
--    D2  Vestments of the Virtuous    set_id 514   8 pieces   ilvl 60
--    T1  Vestments of Prophecy        set_id 202   8 pieces   ilvl 66
--    T2  Vestments of Transcendence   set_id 211   8 pieces   ilvl 76
--    T3  Vestments of Faith           set_id 525   9 pieces   ilvl 86-92
DELETE FROM npc_vendor        WHERE entry = 100022;
DELETE FROM creature_template WHERE entry = 100022;

--  npc_flags = 4 is UNIT_NPC_FLAG_VENDOR in the 1.12 enum this server uses.
--  faction 35 = friendly to everyone. display 1495 is a priest trainer's.
INSERT INTO creature_template
  (entry, name, subname, display_id1, faction, npc_flags,
   level_min, level_max, health_min, health_max, armor, unit_class, type,
   speed_walk, speed_run, scale, base_attack_time, ranged_attack_time,
   dmg_min, dmg_max, movement_type, inhabit_type, regeneration, ai_name)
VALUES
  (100022, 'Confessor Miriam', 'Priest Vestments', 1495, 35, 4,
   60, 60, 4007, 4007, 3272, 1, 7,
   1, 1.14286, 1, 2000, 2000,
   103.4, 129.8, 0, 3, 3, '');

--  maxcount = 0 -> unlimited stock (no restock timer, so incrtime = 0)
INSERT INTO npc_vendor (entry, slot, item, maxcount, incrtime) VALUES
  (100022, 1, 16693, 0, 0), -- [D1] Devout Crown (head, ilvl 62, 8.2g)
  (100022, 2, 16695, 0, 0), -- [D1] Devout Mantle (shoulder, ilvl 60, 7.5g)
  (100022, 3, 16690, 0, 0), -- [D1] Devout Robe (robe, ilvl 63, 11.3g)
  (100022, 4, 16696, 0, 0), -- [D1] Devout Belt (waist, ilvl 58, 4.5g)
  (100022, 5, 16694, 0, 0), -- [D1] Devout Skirt (legs, ilvl 61, 10.4g)
  (100022, 6, 16691, 0, 0), -- [D1] Devout Sandals (feet, ilvl 59, 7.0g)
  (100022, 7, 16697, 0, 0), -- [D1] Devout Bracers (wrists, ilvl 57, 4.3g)
  (100022, 8, 16692, 0, 0), -- [D1] Devout Gloves (hands, ilvl 59, 4.7g)
  (100022, 9, 22080, 0, 0), -- [D2] Virtuous Crown (head, ilvl 60, 10.3g)
  (100022, 10, 22082, 0, 0), -- [D2] Virtuous Mantle (shoulder, ilvl 60, 9.9g)
  (100022, 11, 22083, 0, 0), -- [D2] Virtuous Robe (robe, ilvl 60, 13.8g)
  (100022, 12, 22078, 0, 0), -- [D2] Virtuous Belt (waist, ilvl 60, 6.5g)
  (100022, 13, 22085, 0, 0), -- [D2] Virtuous Skirt (legs, ilvl 60, 13.0g)
  (100022, 14, 22084, 0, 0), -- [D2] Virtuous Sandals (feet, ilvl 60, 9.7g)
  (100022, 15, 22079, 0, 0), -- [D2] Virtuous Bracers (wrists, ilvl 60, 6.5g)
  (100022, 16, 22081, 0, 0), -- [D2] Virtuous Gloves (hands, ilvl 60, 5.2g)
  (100022, 17, 16813, 0, 0), -- [T1] Circlet of Prophecy (head, ilvl 66, 13.9g)
  (100022, 18, 16816, 0, 0), -- [T1] Mantle of Prophecy (shoulder, ilvl 66, 12.7g)
  (100022, 19, 16815, 0, 0), -- [T1] Robes of Prophecy (robe, ilvl 66, 16.9g)
  (100022, 20, 16817, 0, 0), -- [T1] Girdle of Prophecy (waist, ilvl 66, 8.5g)
  (100022, 21, 16814, 0, 0), -- [T1] Pants of Prophecy (legs, ilvl 66, 18.6g)
  (100022, 22, 16811, 0, 0), -- [T1] Boots of Prophecy (feet, ilvl 66, 13.5g)
  (100022, 23, 16819, 0, 0), -- [T1] Vambraces of Prophecy (wrists, ilvl 66, 8.6g)
  (100022, 24, 16812, 0, 0), -- [T1] Gloves of Prophecy (hands, ilvl 66, 9.0g)
  (100022, 25, 16921, 0, 0), -- [T2] Halo of Transcendence (head, ilvl 76, 21.7g)
  (100022, 26, 16924, 0, 0), -- [T2] Pauldrons of Transcendence (shoulder, ilvl 76, 22.0g)
  (100022, 27, 16923, 0, 0), -- [T2] Robes of Transcendence (robe, ilvl 76, 29.2g)
  (100022, 28, 16925, 0, 0), -- [T2] Belt of Transcendence (waist, ilvl 76, 15.1g)
  (100022, 29, 16922, 0, 0), -- [T2] Leggings of Transcendence (legs, ilvl 76, 29.1g)
  (100022, 30, 16919, 0, 0), -- [T2] Boots of Transcendence (feet, ilvl 76, 21.6g)
  (100022, 31, 16926, 0, 0), -- [T2] Bindings of Transcendence (wrists, ilvl 76, 15.1g)
  (100022, 32, 16920, 0, 0), -- [T2] Handguards of Transcendence (hands, ilvl 76, 14.4g)
  (100022, 33, 22514, 0, 0), -- [T3] Circlet of Faith (head, ilvl 88, 40.5g)
  (100022, 34, 22515, 0, 0), -- [T3] Mantle of Faith (shoulder, ilvl 86, 36.9g)
  (100022, 35, 22512, 0, 0), -- [T3] Robe of Faith (robe, ilvl 92, 65.1g)
  (100022, 36, 22518, 0, 0), -- [T3] Belt of Faith (waist, ilvl 88, 25.5g)
  (100022, 37, 22513, 0, 0), -- [T3] Leggings of Faith (legs, ilvl 88, 53.8g)
  (100022, 38, 22516, 0, 0), -- [T3] Sandals of Faith (feet, ilvl 86, 37.0g)
  (100022, 39, 22519, 0, 0), -- [T3] Bindings of Faith (wrists, ilvl 88, 25.6g)
  (100022, 40, 22517, 0, 0), -- [T3] Gloves of Faith (hands, ilvl 88, 27.3g)
  (100022, 41, 23061, 0, 0); -- [T3] Ring of Faith (finger, ilvl 92, 24.1g)

-- ---------------------------------------------------------------------------
--  Farseer Nahla (100023) - Shaman, 41 pieces
-- ---------------------------------------------------------------------------
--    D1  The Elements                 set_id 187   8 pieces   ilvl 57-63
--    D2  The Five Thunders            set_id 519   8 pieces   ilvl 60
--    T1  The Earthfury                set_id 207   8 pieces   ilvl 66
--    T2  Garb of the Ten Storms       set_id 216   8 pieces   ilvl 76
--    T3  The Earthshatterer           set_id 527   9 pieces   ilvl 86-92
DELETE FROM npc_vendor        WHERE entry = 100023;
DELETE FROM creature_template WHERE entry = 100023;

--  npc_flags = 4 is UNIT_NPC_FLAG_VENDOR in the 1.12 enum this server uses.
--  faction 35 = friendly to everyone. display 4552 is a shaman trainer's.
INSERT INTO creature_template
  (entry, name, subname, display_id1, faction, npc_flags,
   level_min, level_max, health_min, health_max, armor, unit_class, type,
   speed_walk, speed_run, scale, base_attack_time, ranged_attack_time,
   dmg_min, dmg_max, movement_type, inhabit_type, regeneration, ai_name)
VALUES
  (100023, 'Farseer Nahla', 'Shaman Regalia', 4552, 35, 4,
   60, 60, 4007, 4007, 3272, 1, 7,
   1, 1.14286, 1, 2000, 2000,
   103.4, 129.8, 0, 3, 3, '');

--  maxcount = 0 -> unlimited stock (no restock timer, so incrtime = 0)
INSERT INTO npc_vendor (entry, slot, item, maxcount, incrtime) VALUES
  (100023, 1, 16667, 0, 0), -- [D1] Coif of Elements (head, ilvl 62, 12.9g)
  (100023, 2, 16669, 0, 0), -- [D1] Pauldrons of Elements (shoulder, ilvl 60, 11.0g)
  (100023, 3, 16666, 0, 0), -- [D1] Vest of Elements (chest, ilvl 63, 18.0g)
  (100023, 4, 16673, 0, 0), -- [D1] Cord of Elements (waist, ilvl 58, 6.7g)
  (100023, 5, 16668, 0, 0), -- [D1] Kilt of Elements (legs, ilvl 61, 15.3g)
  (100023, 6, 16670, 0, 0), -- [D1] Boots of Elements (feet, ilvl 59, 10.5g)
  (100023, 7, 16671, 0, 0), -- [D1] Bindings of Elements (wrists, ilvl 57, 6.3g)
  (100023, 8, 16672, 0, 0), -- [D1] Gauntlets of Elements (hands, ilvl 59, 7.0g)
  (100023, 9, 22097, 0, 0), -- [D2] Coif of The Five Thunders (head, ilvl 60, 15.2g)
  (100023, 10, 22101, 0, 0), -- [D2] Pauldrons of The Five Thunders (shoulder, ilvl 60, 13.8g)
  (100023, 11, 22102, 0, 0), -- [D2] Vest of The Five Thunders (chest, ilvl 60, 19.2g)
  (100023, 12, 22098, 0, 0), -- [D2] Cord of The Five Thunders (waist, ilvl 60, 9.7g)
  (100023, 13, 22100, 0, 0), -- [D2] Kilt of The Five Thunders (legs, ilvl 60, 19.1g)
  (100023, 14, 22096, 0, 0), -- [D2] Boots of The Five Thunders (feet, ilvl 60, 15.2g)
  (100023, 15, 22095, 0, 0), -- [D2] Bindings of The Five Thunders (wrists, ilvl 60, 9.6g)
  (100023, 16, 22099, 0, 0), -- [D2] Gauntlets of The Five Thunders (hands, ilvl 60, 7.8g)
  (100023, 17, 16842, 0, 0), -- [T1] Earthfury Helmet (head, ilvl 66, 19.6g)
  (100023, 18, 16844, 0, 0), -- [T1] Earthfury Spaulders (shoulder, ilvl 66, 19.8g)
  (100023, 19, 16841, 0, 0), -- [T1] Earthfury Chestpiece (robe, ilvl 66, 26.0g)
  (100023, 20, 16838, 0, 0), -- [T1] Earthfury Belt (waist, ilvl 66, 12.8g)
  (100023, 21, 16843, 0, 0), -- [T1] Earthfury Pants (legs, ilvl 66, 26.2g)
  (100023, 22, 16837, 0, 0), -- [T1] Earthfury Boots (feet, ilvl 66, 19.3g)
  (100023, 23, 16840, 0, 0), -- [T1] Earthfury Bracers (wrists, ilvl 66, 12.9g)
  (100023, 24, 16839, 0, 0), -- [T1] Earthfury Gloves (hands, ilvl 66, 12.9g)
  (100023, 25, 16947, 0, 0), -- [T2] Visor of Ten Storms (head, ilvl 76, 34.2g)
  (100023, 26, 16945, 0, 0), -- [T2] Epaulets of Ten Storms (shoulder, ilvl 76, 34.1g)
  (100023, 27, 16950, 0, 0), -- [T2] Raiments of Ten Storms (chest, ilvl 76, 41.7g)
  (100023, 28, 16944, 0, 0), -- [T2] Sash of Ten Storms (waist, ilvl 76, 22.5g)
  (100023, 29, 16946, 0, 0), -- [T2] Legplates of Ten Storms (legs, ilvl 76, 45.4g)
  (100023, 30, 16949, 0, 0), -- [T2] Greaves of Ten Storms (feet, ilvl 76, 31.3g)
  (100023, 31, 16943, 0, 0), -- [T2] Bindings of Ten Storms (wrists, ilvl 76, 22.5g)
  (100023, 32, 16948, 0, 0), -- [T2] Gauntlets of Ten Storms (hands, ilvl 76, 20.7g)
  (100023, 33, 22466, 0, 0), -- [T3] Earthshatter Headpiece (head, ilvl 88, 57.5g)
  (100023, 34, 22467, 0, 0), -- [T3] Earthshatter Spaulders (shoulder, ilvl 86, 52.6g)
  (100023, 35, 22464, 0, 0), -- [T3] Earthshatter Tunic (chest, ilvl 92, 92.4g)
  (100023, 36, 22470, 0, 0), -- [T3] Earthshatter Belt (waist, ilvl 88, 39.9g)
  (100023, 37, 22465, 0, 0), -- [T3] Earthshatter Legguards (legs, ilvl 88, 76.3g)
  (100023, 38, 22468, 0, 0), -- [T3] Earthshatter Boots (feet, ilvl 86, 52.8g)
  (100023, 39, 22471, 0, 0), -- [T3] Earthshatter Wristguards (wrists, ilvl 88, 40.1g)
  (100023, 40, 22469, 0, 0), -- [T3] Earthshatter Handguards (hands, ilvl 88, 38.7g)
  (100023, 41, 23065, 0, 0); -- [T3] Ring of the Earthshatterer (finger, ilvl 92, 24.1g)

-- ---------------------------------------------------------------------------
--  Archmage Theryn (100024) - Mage, 41 pieces
-- ---------------------------------------------------------------------------
--    D1  Magister's Regalia           set_id 181   8 pieces   ilvl 57-63
--    D2  Sorcerer's Regalia           set_id 517   8 pieces   ilvl 60
--    T1  Arcanist's Regalia           set_id 201   8 pieces   ilvl 66
--    T2  Netherwind Regalia           set_id 210   8 pieces   ilvl 76
--    T3  Frostfire Regalia            set_id 526   9 pieces   ilvl 86-92
DELETE FROM npc_vendor        WHERE entry = 100024;
DELETE FROM creature_template WHERE entry = 100024;

--  npc_flags = 4 is UNIT_NPC_FLAG_VENDOR in the 1.12 enum this server uses.
--  faction 35 = friendly to everyone. display 5001 is a mage trainer's.
INSERT INTO creature_template
  (entry, name, subname, display_id1, faction, npc_flags,
   level_min, level_max, health_min, health_max, armor, unit_class, type,
   speed_walk, speed_run, scale, base_attack_time, ranged_attack_time,
   dmg_min, dmg_max, movement_type, inhabit_type, regeneration, ai_name)
VALUES
  (100024, 'Archmage Theryn', 'Mage Regalia', 5001, 35, 4,
   60, 60, 4007, 4007, 3272, 1, 7,
   1, 1.14286, 1, 2000, 2000,
   103.4, 129.8, 0, 3, 3, '');

--  maxcount = 0 -> unlimited stock (no restock timer, so incrtime = 0)
INSERT INTO npc_vendor (entry, slot, item, maxcount, incrtime) VALUES
  (100024, 1, 16686, 0, 0), -- [D1] Magister's Crown (head, ilvl 62, 8.0g)
  (100024, 2, 16689, 0, 0), -- [D1] Magister's Mantle (shoulder, ilvl 60, 7.3g)
  (100024, 3, 16688, 0, 0), -- [D1] Magister's Robes (robe, ilvl 63, 11.2g)
  (100024, 4, 16685, 0, 0), -- [D1] Magister's Belt (waist, ilvl 58, 4.3g)
  (100024, 5, 16687, 0, 0), -- [D1] Magister's Leggings (legs, ilvl 61, 10.1g)
  (100024, 6, 16682, 0, 0), -- [D1] Magister's Boots (feet, ilvl 59, 7.3g)
  (100024, 7, 16683, 0, 0), -- [D1] Magister's Bindings (wrists, ilvl 57, 4.4g)
  (100024, 8, 16684, 0, 0), -- [D1] Magister's Gloves (hands, ilvl 59, 4.5g)
  (100024, 9, 22065, 0, 0), -- [D2] Sorcerer's Crown (head, ilvl 60, 10.4g)
  (100024, 10, 22068, 0, 0), -- [D2] Sorcerer's Mantle (shoulder, ilvl 60, 9.4g)
  (100024, 11, 22069, 0, 0), -- [D2] Sorcerer's Robes (robe, ilvl 60, 13.1g)
  (100024, 12, 22062, 0, 0), -- [D2] Sorcerer's Belt (waist, ilvl 60, 6.6g)
  (100024, 13, 22067, 0, 0), -- [D2] Sorcerer's Leggings (legs, ilvl 60, 12.8g)
  (100024, 14, 22064, 0, 0), -- [D2] Sorcerer's Boots (feet, ilvl 60, 10.4g)
  (100024, 15, 22063, 0, 0), -- [D2] Sorcerer's Bindings (wrists, ilvl 60, 6.6g)
  (100024, 16, 22066, 0, 0), -- [D2] Sorcerer's Gloves (hands, ilvl 60, 4.8g)
  (100024, 17, 16795, 0, 0), -- [T1] Arcanist Crown (head, ilvl 66, 13.7g)
  (100024, 18, 16797, 0, 0), -- [T1] Arcanist Mantle (shoulder, ilvl 66, 12.8g)
  (100024, 19, 16798, 0, 0), -- [T1] Arcanist Robes (robe, ilvl 66, 17.1g)
  (100024, 20, 16802, 0, 0), -- [T1] Arcanist Belt (waist, ilvl 66, 8.7g)
  (100024, 21, 16796, 0, 0), -- [T1] Arcanist Leggings (legs, ilvl 66, 17.0g)
  (100024, 22, 16800, 0, 0), -- [T1] Arcanist Boots (feet, ilvl 66, 12.9g)
  (100024, 23, 16799, 0, 0), -- [T1] Arcanist Bindings (wrists, ilvl 66, 8.6g)
  (100024, 24, 16801, 0, 0), -- [T1] Arcanist Gloves (hands, ilvl 66, 8.7g)
  (100024, 25, 16914, 0, 0), -- [T2] Netherwind Crown (head, ilvl 76, 21.2g)
  (100024, 26, 16917, 0, 0), -- [T2] Netherwind Mantle (shoulder, ilvl 76, 21.4g)
  (100024, 27, 16916, 0, 0), -- [T2] Netherwind Robes (robe, ilvl 76, 28.4g)
  (100024, 28, 16818, 0, 0), -- [T2] Netherwind Belt (waist, ilvl 76, 13.9g)
  (100024, 29, 16915, 0, 0), -- [T2] Netherwind Pants (legs, ilvl 76, 28.3g)
  (100024, 30, 16912, 0, 0), -- [T2] Netherwind Boots (feet, ilvl 76, 21.0g)
  (100024, 31, 16918, 0, 0), -- [T2] Netherwind Bindings (wrists, ilvl 76, 14.3g)
  (100024, 32, 16913, 0, 0), -- [T2] Netherwind Gloves (hands, ilvl 76, 14.1g)
  (100024, 33, 22498, 0, 0), -- [T3] Frostfire Circlet (head, ilvl 88, 37.2g)
  (100024, 34, 22499, 0, 0), -- [T3] Frostfire Shoulderpads (shoulder, ilvl 86, 33.8g)
  (100024, 35, 22496, 0, 0), -- [T3] Frostfire Robe (robe, ilvl 92, 66.1g)
  (100024, 36, 22502, 0, 0), -- [T3] Frostfire Belt (waist, ilvl 88, 25.8g)
  (100024, 37, 22497, 0, 0), -- [T3] Frostfire Leggings (legs, ilvl 88, 54.6g)
  (100024, 38, 22500, 0, 0), -- [T3] Frostfire Sandals (feet, ilvl 86, 34.0g)
  (100024, 39, 22503, 0, 0), -- [T3] Frostfire Bindings (wrists, ilvl 88, 25.9g)
  (100024, 40, 22501, 0, 0), -- [T3] Frostfire Gloves (hands, ilvl 88, 25.1g)
  (100024, 41, 23062, 0, 0); -- [T3] Frostfire Ring (finger, ilvl 92, 24.1g)

-- ---------------------------------------------------------------------------
--  Dreadweaver Malia (100025) - Warlock, 41 pieces
-- ---------------------------------------------------------------------------
--    D1  Dreadmist Raiment            set_id 183   8 pieces   ilvl 57-63
--    D2  Deathmist Raiment            set_id 518   8 pieces   ilvl 60
--    T1  Felheart Raiment             set_id 203   8 pieces   ilvl 66
--    T2  Nemesis Raiment              set_id 212   8 pieces   ilvl 76
--    T3  Plagueheart Raiment          set_id 529   9 pieces   ilvl 86-92
DELETE FROM npc_vendor        WHERE entry = 100025;
DELETE FROM creature_template WHERE entry = 100025;

--  npc_flags = 4 is UNIT_NPC_FLAG_VENDOR in the 1.12 enum this server uses.
--  faction 35 = friendly to everyone. display 1469 is a warlock trainer's.
INSERT INTO creature_template
  (entry, name, subname, display_id1, faction, npc_flags,
   level_min, level_max, health_min, health_max, armor, unit_class, type,
   speed_walk, speed_run, scale, base_attack_time, ranged_attack_time,
   dmg_min, dmg_max, movement_type, inhabit_type, regeneration, ai_name)
VALUES
  (100025, 'Dreadweaver Malia', 'Warlock Raiment', 1469, 35, 4,
   60, 60, 4007, 4007, 3272, 1, 7,
   1, 1.14286, 1, 2000, 2000,
   103.4, 129.8, 0, 3, 3, '');

--  maxcount = 0 -> unlimited stock (no restock timer, so incrtime = 0)
INSERT INTO npc_vendor (entry, slot, item, maxcount, incrtime) VALUES
  (100025, 1, 16698, 0, 0), -- [D1] Dreadmist Mask (head, ilvl 62, 8.3g)
  (100025, 2, 16701, 0, 0), -- [D1] Dreadmist Mantle (shoulder, ilvl 60, 7.8g)
  (100025, 3, 16700, 0, 0), -- [D1] Dreadmist Robe (robe, ilvl 63, 12.0g)
  (100025, 4, 16702, 0, 0), -- [D1] Dreadmist Belt (waist, ilvl 58, 4.3g)
  (100025, 5, 16699, 0, 0), -- [D1] Dreadmist Leggings (legs, ilvl 61, 10.6g)
  (100025, 6, 16704, 0, 0), -- [D1] Dreadmist Sandals (feet, ilvl 59, 6.8g)
  (100025, 7, 16703, 0, 0), -- [D1] Dreadmist Bracers (wrists, ilvl 57, 4.1g)
  (100025, 8, 16705, 0, 0), -- [D1] Dreadmist Wraps (hands, ilvl 59, 4.6g)
  (100025, 9, 22074, 0, 0), -- [D2] Deathmist Mask (head, ilvl 60, 10.0g)
  (100025, 10, 22073, 0, 0), -- [D2] Deathmist Mantle (shoulder, ilvl 60, 9.6g)
  (100025, 11, 22075, 0, 0), -- [D2] Deathmist Robe (robe, ilvl 60, 13.4g)
  (100025, 12, 22070, 0, 0), -- [D2] Deathmist Belt (waist, ilvl 60, 6.3g)
  (100025, 13, 22072, 0, 0), -- [D2] Deathmist Leggings (legs, ilvl 60, 13.3g)
  (100025, 14, 22076, 0, 0), -- [D2] Deathmist Sandals (feet, ilvl 60, 10.1g)
  (100025, 15, 22071, 0, 0), -- [D2] Deathmist Bracers (wrists, ilvl 60, 6.3g)
  (100025, 16, 22077, 0, 0), -- [D2] Deathmist Wraps (hands, ilvl 60, 5.1g)
  (100025, 17, 16808, 0, 0), -- [T1] Felheart Horns (head, ilvl 66, 13.3g)
  (100025, 18, 16807, 0, 0), -- [T1] Felheart Shoulder Pads (shoulder, ilvl 66, 13.3g)
  (100025, 19, 16809, 0, 0), -- [T1] Felheart Robes (robe, ilvl 66, 17.8g)
  (100025, 20, 16806, 0, 0), -- [T1] Felheart Belt (waist, ilvl 66, 8.8g)
  (100025, 21, 16810, 0, 0), -- [T1] Felheart Pants (legs, ilvl 66, 17.9g)
  (100025, 22, 16803, 0, 0), -- [T1] Felheart Slippers (feet, ilvl 66, 13.1g)
  (100025, 23, 16804, 0, 0), -- [T1] Felheart Bracers (wrists, ilvl 66, 8.8g)
  (100025, 24, 16805, 0, 0), -- [T1] Felheart Gloves (hands, ilvl 66, 8.8g)
  (100025, 25, 16929, 0, 0), -- [T2] Nemesis Skullcap (head, ilvl 76, 20.8g)
  (100025, 26, 16932, 0, 0), -- [T2] Nemesis Spaulders (shoulder, ilvl 76, 21.0g)
  (100025, 27, 16931, 0, 0), -- [T2] Nemesis Robes (robe, ilvl 76, 27.9g)
  (100025, 28, 16933, 0, 0), -- [T2] Nemesis Belt (waist, ilvl 76, 14.1g)
  (100025, 29, 16930, 0, 0), -- [T2] Nemesis Pants (legs, ilvl 76, 27.8g)
  (100025, 30, 16927, 0, 0), -- [T2] Nemesis Slippers (feet, ilvl 76, 22.8g)
  (100025, 31, 16934, 0, 0), -- [T2] Nemesis Bracers (wrists, ilvl 76, 14.1g)
  (100025, 32, 16928, 0, 0), -- [T2] Nemesis Gloves (hands, ilvl 76, 13.8g)
  (100025, 33, 22506, 0, 0), -- [T3] Plagueheart Circlet (head, ilvl 88, 39.3g)
  (100025, 34, 22507, 0, 0), -- [T3] Plagueheart Shoulderpads (shoulder, ilvl 86, 35.8g)
  (100025, 35, 22504, 0, 0), -- [T3] Plagueheart Robe (robe, ilvl 92, 63.3g)
  (100025, 36, 22510, 0, 0), -- [T3] Plagueheart Belt (waist, ilvl 88, 26.6g)
  (100025, 37, 22505, 0, 0), -- [T3] Plagueheart Pants (legs, ilvl 88, 52.3g)
  (100025, 38, 22508, 0, 0), -- [T3] Plagueheart Sandals (feet, ilvl 86, 35.9g)
  (100025, 39, 22511, 0, 0), -- [T3] Plagueheart Bracers (wrists, ilvl 88, 26.7g)
  (100025, 40, 22509, 0, 0), -- [T3] Plagueheart Gloves (hands, ilvl 88, 26.5g)
  (100025, 41, 23063, 0, 0); -- [T3] Plagueheart Ring (finger, ilvl 92, 24.1g)

