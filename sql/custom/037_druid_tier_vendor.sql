-- ============================================================================
--  Custom NPC: Druid armour vendor  (tw_world)
-- ============================================================================
--  The druid counterpart to 001_warrior_tier_vendor.sql - same shape, same
--  rules. Sells the complete Druid dungeon and tier sets for gold.
--
--    D1  Wildheart Raiment      set_id 185   8 pieces   ilvl 57-63
--    D2  Moonheart Raiment      set_id 513   8 pieces   ilvl 60
--    T1  Cenarion Raiment       set_id 205   8 pieces   ilvl 66
--    T2  Stormrage Raiment      set_id 214   8 pieces   ilvl 76
--    T3  Dreamwalker Raiment    set_id 521   9 pieces   ilvl 86-92
--
--  FINDING THE SETS: match on item_template.set_id, never on item names. Set
--  names come from server\dbc\ItemSet.dbc (field 1 is the English name); the
--  world DB has no set-name table. Note the vanilla D2 druid set is
--  "Feralheart" everywhere else - Turtle renamed it Moonheart, so the name is
--  no guide at all here.
--
--  NOTE the two dungeon sets have allowable_class = -1, not 1024: like the
--  warrior ones they are gated by armour type (leather, subclass 2) rather
--  than a class flag. Querying druid sets with allowable_class = 1024 silently
--  misses both Wildheart and Moonheart.
--
--  DUPLICATE ENTRIES: five Stormrage pieces, the Moonheart belt and the
--  Dreamwalker headpiece each exist twice, under the SAME name at a high
--  entry (1447079, 281044, 1891641...). They are not junk and not renames:
--  stats are identical and only display_id differs, so they are alternate
--  APPEARANCES of the same piece. This vendor stocks the low stock entries,
--  i.e. the classic look, which is also what 001 did for the warrior sets.
--
--  Re-runnable: the DELETEs make this safe to apply repeatedly.
--
--  Apply with (PowerShell - '<' is a reserved operator there, so pipe):
--    Get-Content sql\custom\037_druid_tier_vendor.sql | DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_world
--  then, in the mangosd console (no leading dot), no restart needed - and IN THIS
--  ORDER, because reload npc_vendor validates rows against the CACHED creature
--  templates. Reversed, all 41 rows are dropped with "npc_vendor has data for
--  nonexistent creature" in the log and the vendor window opens empty in game,
--  with no error shown to the player:
--    reload creature_template
--    reload npc_vendor
--
--  Spawn it in-game as GM, standing where you want it:
--    .npc add 100014
-- ============================================================================

-- 100000-100009 is the vendor block and is full; 100010-100013 are the housing
-- gameobjects (and creature 100010, the retired furniture handle). The vendor
-- block therefore continues at 100014.
SET @VENDOR := 100014;

DELETE FROM npc_vendor        WHERE entry = @VENDOR;
DELETE FROM creature_template WHERE entry = @VENDOR;

-- ---------------------------------------------------------------------------
--  The NPC
-- ---------------------------------------------------------------------------
--  npc_flags = 4 is UNIT_NPC_FLAG_VENDOR in the 1.12 enum this server uses.
--  (NOT 128 - that is INNKEEPER here.)  faction 35 = friendly to everyone.
--  display 2261 is Mathrengyl Bearwalker's, the Darnassus druid trainer.
INSERT INTO creature_template
  (entry, name, subname, display_id1, faction, npc_flags,
   level_min, level_max, health_min, health_max, armor, unit_class, type,
   speed_walk, speed_run, scale, base_attack_time, ranged_attack_time,
   dmg_min, dmg_max, movement_type, inhabit_type, regeneration, ai_name)
VALUES
  (@VENDOR, 'Keeper Faelyn', 'Druid Raiment', 2261, 35, 4,
   60, 60, 4007, 4007, 3272, 1, 7,
   1, 1.14286, 1, 2000, 2000,
   103.4, 129.8, 0, 3, 3, '');

-- ---------------------------------------------------------------------------
--  Stock list, ordered D1 -> D2 -> T1 -> T2 -> T3, each set head to hands.
-- ---------------------------------------------------------------------------
--  slot     = display order in the vendor window
--  maxcount = 0 -> unlimited stock (no restock timer, so incrtime = 0)
--  Price is item_template.buy_price; this core's npc_vendor has no
--  ExtendedCost column, so vendor purchases are plain gold only. Every piece
--  below was checked for buy_price > 0 - an item priced 0 cannot be vendored.
INSERT INTO npc_vendor (entry, slot, item, maxcount, incrtime) VALUES
  (@VENDOR, 1, 16720, 0, 0), -- [D1] Wildheart Cowl (ilvl 62, 10.7g)
  (@VENDOR, 2, 16718, 0, 0), -- [D1] Wildheart Spaulders (ilvl 60, 9.7g)
  (@VENDOR, 3, 16706, 0, 0), -- [D1] Wildheart Vest (ilvl 63, 13.9g)
  (@VENDOR, 4, 16716, 0, 0), -- [D1] Wildheart Belt (ilvl 58, 5.8g)
  (@VENDOR, 5, 16719, 0, 0), -- [D1] Wildheart Kilt (ilvl 61, 13.6g)
  (@VENDOR, 6, 16715, 0, 0), -- [D1] Wildheart Boots (ilvl 59, 8.9g)
  (@VENDOR, 7, 16714, 0, 0), -- [D1] Wildheart Bracers (ilvl 57, 5.3g)
  (@VENDOR, 8, 16717, 0, 0), -- [D1] Wildheart Gloves (ilvl 59, 6.1g)
  (@VENDOR, 9, 22109, 0, 0), -- [D2] Moonheart Cowl (ilvl 60, 12.3g)
  (@VENDOR, 10, 22112, 0, 0), -- [D2] Moonheart Spaulders (ilvl 60, 11.9g)
  (@VENDOR, 11, 22113, 0, 0), -- [D2] Moonheart Vest (ilvl 60, 16.7g)
  (@VENDOR, 12, 22106, 0, 0), -- [D2] Moonheart Belt (ilvl 60, 7.8g)
  (@VENDOR, 13, 22111, 0, 0), -- [D2] Moonheart Kilt (ilvl 60, 16.6g)
  (@VENDOR, 14, 22107, 0, 0), -- [D2] Moonheart Boots (ilvl 60, 12.2g)
  (@VENDOR, 15, 22108, 0, 0), -- [D2] Moonheart Bracers (ilvl 60, 7.8g)
  (@VENDOR, 16, 22110, 0, 0), -- [D2] Moonheart Gloves (ilvl 60, 6.3g)
  (@VENDOR, 17, 16834, 0, 0), -- [T1] Cenarion Helm (ilvl 66, 17.5g)
  (@VENDOR, 18, 16836, 0, 0), -- [T1] Cenarion Spaulders (ilvl 66, 15.9g)
  (@VENDOR, 19, 16833, 0, 0), -- [T1] Cenarion Vestments (ilvl 66, 23.2g - a robe)
  (@VENDOR, 20, 16828, 0, 0), -- [T1] Cenarion Belt (ilvl 66, 11.1g)
  (@VENDOR, 21, 16835, 0, 0), -- [T1] Cenarion Leggings (ilvl 66, 21.2g)
  (@VENDOR, 22, 16829, 0, 0), -- [T1] Cenarion Boots (ilvl 66, 17.2g)
  (@VENDOR, 23, 16830, 0, 0), -- [T1] Cenarion Bracers (ilvl 66, 11.5g)
  (@VENDOR, 24, 16831, 0, 0), -- [T1] Cenarion Gloves (ilvl 66, 11.5g)
  (@VENDOR, 25, 16900, 0, 0), -- [T2] Stormrage Cover (ilvl 76, 27.1g)
  (@VENDOR, 26, 16902, 0, 0), -- [T2] Stormrage Pauldrons (ilvl 76, 27.3g)
  (@VENDOR, 27, 16897, 0, 0), -- [T2] Stormrage Chestguard (ilvl 76, 35.7g)
  (@VENDOR, 28, 16903, 0, 0), -- [T2] Stormrage Belt (ilvl 76, 18.2g)
  (@VENDOR, 29, 16901, 0, 0), -- [T2] Stormrage Legguards (ilvl 76, 36.2g)
  (@VENDOR, 30, 16898, 0, 0), -- [T2] Stormrage Boots (ilvl 76, 26.9g)
  (@VENDOR, 31, 16904, 0, 0), -- [T2] Stormrage Bracers (ilvl 76, 18.3g)
  (@VENDOR, 32, 16899, 0, 0), -- [T2] Stormrage Gloves (ilvl 76, 18.0g)
  (@VENDOR, 33, 22490, 0, 0), -- [T3] Dreamwalker Headpiece (ilvl 88, 49.9g)
  (@VENDOR, 34, 22491, 0, 0), -- [T3] Dreamwalker Spaulders (ilvl 86, 45.4g)
  (@VENDOR, 35, 22488, 0, 0), -- [T3] Dreamwalker Tunic (ilvl 92, 80.3g)
  (@VENDOR, 36, 22494, 0, 0), -- [T3] Dreamwalker Belt (ilvl 88, 33.7g)
  (@VENDOR, 37, 22489, 0, 0), -- [T3] Dreamwalker Legguards (ilvl 88, 66.3g)
  (@VENDOR, 38, 22492, 0, 0), -- [T3] Dreamwalker Boots (ilvl 86, 45.6g)
  (@VENDOR, 39, 22495, 0, 0), -- [T3] Dreamwalker Bracers (ilvl 88, 33.9g)
  (@VENDOR, 40, 22493, 0, 0), -- [T3] Dreamwalker Handguards (ilvl 88, 33.6g)
  (@VENDOR, 41, 23064, 0, 0); -- [T3] Ring of The Dreamwalker (ilvl 92, 24.1g)
