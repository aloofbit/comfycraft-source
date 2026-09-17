-- ============================================================================
--  Custom NPC: Warrior armour vendor  (tw_world)
-- ============================================================================
--  Sells the complete Warrior dungeon and tier sets for gold.
--
--    D1  Battlegear of Valor       set_id 189   8 pieces   ilvl 57-63
--    D2  Battlegear of Heroism     set_id 511   8 pieces   ilvl 60
--    T1  Battlegear of Might       set_id 209   8 pieces   ilvl 66
--    T2  Battlegear of Wrath       set_id 218   8 pieces   ilvl 76
--    T3  Dreadnaught's Battlegear  set_id 523   9 pieces   ilvl 86-92
--
--  FINDING THE SETS: match on item_template.set_id, never on item names - Turtle
--  ships renamed duplicate copies of the classic sets (a second "Crown of Might"
--  at 47240/70679 alongside stock "Helm of Might" 16866). Set names come from
--  server\dbc\ItemSet.dbc (field 1 is the English name); the world DB has no
--  set-name table.
--
--  NOTE the dungeon sets have allowable_class = -1, not 1: they are restricted
--  by armour type (plate, subclass 4) rather than a class flag. Querying warrior
--  sets with allowable_class = 1 silently misses both of them.
--
--  Re-runnable: the DELETEs make this safe to apply repeatedly.
--
--  Apply with:
--    DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_world < sql\custom\001_warrior_tier_vendor.sql
--  then restart mangosd (creature_template is cached at startup).
--
--  Spawn it in-game as GM, standing where you want it:
--    .npc add 100000
-- ============================================================================

SET @VENDOR := 100000;   -- entry 100000-109999 is an empty block in this DB

DELETE FROM npc_vendor        WHERE entry = @VENDOR;
DELETE FROM creature_template WHERE entry = @VENDOR;

-- ---------------------------------------------------------------------------
--  The NPC
-- ---------------------------------------------------------------------------
--  npc_flags = 4 is UNIT_NPC_FLAG_VENDOR in the 1.12 enum this server uses.
--  (NOT 128 - that is INNKEEPER here. 128 is the vendor bit in TBC+ cores only.)
--  Useful additions: +1 gossip menu, +16384 repair  ->  16389 for a full armorer.
--  faction 35 = friendly to everyone, so both factions can use it.
INSERT INTO creature_template
  (entry, name, subname, display_id1, faction, npc_flags,
   level_min, level_max, health_min, health_max, armor, unit_class, type,
   speed_walk, speed_run, scale, base_attack_time, ranged_attack_time,
   dmg_min, dmg_max, movement_type, inhabit_type, regeneration, ai_name)
VALUES
  (@VENDOR, 'Quartermaster Aldric', 'Warrior Battlegear', 3644, 35, 4,
   60, 60, 4007, 4007, 3272, 1, 7,
   1, 1.14286, 1, 2000, 2000,
   103.4, 129.8, 0, 3, 3, '');

-- ---------------------------------------------------------------------------
--  Stock list, ordered D1 -> D2 -> T1 -> T2 -> T3, each set head to hands.
-- ---------------------------------------------------------------------------
--  slot     = display order in the vendor window
--  maxcount = 0 -> unlimited stock (no restock timer, so incrtime = 0)
--  Price is item_template.buy_price; this core's npc_vendor has no ExtendedCost
--  column, so vendor purchases are plain gold only.
INSERT INTO npc_vendor (entry, slot, item, maxcount, incrtime) VALUES
  (@VENDOR, 1, 16731, 0, 0), -- [D1] Helm of Valor (ilvl 62, 8.1g)
  (@VENDOR, 2, 16733, 0, 0), -- [D1] Spaulders of Valor (ilvl 60, 7.6g)
  (@VENDOR, 3, 16730, 0, 0), -- [D1] Breastplate of Valor (ilvl 63, 11.3g)
  (@VENDOR, 4, 16736, 0, 0), -- [D1] Belt of Valor (ilvl 58, 4.6g)
  (@VENDOR, 5, 16732, 0, 0), -- [D1] Legplates of Valor (ilvl 61, 10.6g)
  (@VENDOR, 6, 16734, 0, 0), -- [D1] Boots of Valor (ilvl 59, 7.3g)
  (@VENDOR, 7, 16735, 0, 0), -- [D1] Bracers of Valor (ilvl 57, 4.4g)
  (@VENDOR, 8, 16737, 0, 0), -- [D1] Gauntlets of Valor (ilvl 59, 4.9g)
  (@VENDOR, 9, 21999, 0, 0), -- [D2] Helm of Heroism (ilvl 60, 10.0g)
  (@VENDOR, 10, 22001, 0, 0), -- [D2] Spaulders of Heroism (ilvl 60, 9.6g)
  (@VENDOR, 11, 21997, 0, 0), -- [D2] Breastplate of Heroism (ilvl 60, 13.2g)
  (@VENDOR, 12, 21994, 0, 0), -- [D2] Belt of Heroism (ilvl 60, 6.2g)
  (@VENDOR, 13, 22000, 0, 0), -- [D2] Legplates of Heroism (ilvl 60, 13.4g)
  (@VENDOR, 14, 21995, 0, 0), -- [D2] Boots of Heroism (ilvl 60, 9.8g)
  (@VENDOR, 15, 21996, 0, 0), -- [D2] Bracers of Heroism (ilvl 60, 6.3g)
  (@VENDOR, 16, 21998, 0, 0), -- [D2] Gauntlets of Heroism (ilvl 60, 5.0g)
  (@VENDOR, 17, 16866, 0, 0), -- [T1] Helm of Might (ilvl 66, 13.6g)
  (@VENDOR, 18, 16868, 0, 0), -- [T1] Pauldrons of Might (ilvl 66, 13.7g)
  (@VENDOR, 19, 16865, 0, 0), -- [T1] Breastplate of Might (ilvl 66, 18.0g)
  (@VENDOR, 20, 16864, 0, 0), -- [T1] Belt of Might (ilvl 66, 9.0g)
  (@VENDOR, 21, 16867, 0, 0), -- [T1] Legplates of Might (ilvl 66, 18.2g)
  (@VENDOR, 22, 16862, 0, 0), -- [T1] Sabatons of Might (ilvl 66, 13.4g)
  (@VENDOR, 23, 16861, 0, 0), -- [T1] Bracers of Might (ilvl 66, 8.9g)
  (@VENDOR, 24, 16863, 0, 0), -- [T1] Gauntlets of Might (ilvl 66, 9.0g)
  (@VENDOR, 25, 16963, 0, 0), -- [T2] Helm of Wrath (ilvl 76, 22.5g)
  (@VENDOR, 26, 16961, 0, 0), -- [T2] Pauldrons of Wrath (ilvl 76, 22.3g)
  (@VENDOR, 27, 16966, 0, 0), -- [T2] Breastplate of Wrath (ilvl 76, 30.3g)
  (@VENDOR, 28, 16960, 0, 0), -- [T2] Waistband of Wrath (ilvl 76, 14.8g)
  (@VENDOR, 29, 16962, 0, 0), -- [T2] Legplates of Wrath (ilvl 76, 29.8g)
  (@VENDOR, 30, 16965, 0, 0), -- [T2] Sabatons of Wrath (ilvl 76, 22.6g)
  (@VENDOR, 31, 16959, 0, 0), -- [T2] Bracelets of Wrath (ilvl 76, 14.8g)
  (@VENDOR, 32, 16964, 0, 0), -- [T2] Gauntlets of Wrath (ilvl 76, 15.0g)
  (@VENDOR, 33, 22418, 0, 0), -- [T3] Dreadnaught Helmet (ilvl 88, 40.0g)
  (@VENDOR, 34, 22419, 0, 0), -- [T3] Dreadnaught Pauldrons (ilvl 86, 36.5g)
  (@VENDOR, 35, 22416, 0, 0), -- [T3] Dreadnaught Breastplate (ilvl 92, 64.4g)
  (@VENDOR, 36, 22422, 0, 0), -- [T3] Dreadnaught Waistguard (ilvl 88, 25.2g)
  (@VENDOR, 37, 22417, 0, 0), -- [T3] Dreadnaught Legplates (ilvl 88, 53.2g)
  (@VENDOR, 38, 22420, 0, 0), -- [T3] Dreadnaught Sabatons (ilvl 86, 36.6g)
  (@VENDOR, 39, 22423, 0, 0), -- [T3] Dreadnaught Bracers (ilvl 88, 25.3g)
  (@VENDOR, 40, 22421, 0, 0), -- [T3] Dreadnaught Gauntlets (ilvl 88, 27.0g)
  (@VENDOR, 41, 23059, 0, 0); -- [T3] Ring of the Dreadnaught (ilvl 92, 24.1g)
