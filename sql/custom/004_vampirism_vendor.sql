-- ============================================================================
--  Custom NPC: vampirism vendor  (tw_world)
-- ============================================================================
--  Countess Nightvein (creature 100002) sells every item in the database that
--  grants Vampirism - Turtle's "% of damage dealt is returned as healing".
--
--  HOW VAMPIRISM WORKS HERE: it is not an item stat, it is an equip-triggered
--  spell. Items carry spellid_N = one of the Vampirism aura spells with
--  spelltrigger_N = 1 (on equip):
--      45420 Vampirism 1  - 1% of damage dealt returned as healing
--      45421 Vampirism 2  - 2%
--      45422 Vampirism 3  - 3%
--      45423 Vampirism 4  - 4%   (no items carry this)
--      45424 Vampirism 5  - 5%   (no items carry this)
--      51001 Vampirism 5  - 5% (timed variant; Bloodmoon uses this)
--  So the way to find vampirism gear is to join item_template to those spells,
--  NOT to search names - most of these items have no vampiric wording at all
--  (Bloodvine, Transcendence, Jinxed Hoodoo Skin).
--
--  Stock is 57 distinct items (duplicate name variants collapsed to the lowest
--  entry), sorted strongest first: 5% and 3% at the top, then 2%, then 1%.
--  All 57 have a non-zero buy_price, which a vendor requires.
--
--  RELATED, NOT SOLD HERE: Enchant Bracer - Vampirism (57146) and Enchant Boots
--  - Vampirism (57148) each add another 1%, but they are enchants and so need
--  the reagent-granting gossip machinery - see 003_enchant_scroll_npc.sql.
--
--  Apply, then RESTART mangosd (creature_template is cached at startup):
--    DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_world < sql\custom\004_vampirism_vendor.sql
--  Spawn with:  .npc add 100002
-- ============================================================================

SET @VENDOR := 100002;

DELETE FROM npc_vendor        WHERE entry = @VENDOR;
DELETE FROM creature_template WHERE entry = @VENDOR;

INSERT INTO creature_template
  (entry, name, subname, display_id1, faction, npc_flags,
   level_min, level_max, health_min, health_max, armor, unit_class, type,
   speed_walk, speed_run, scale, base_attack_time, ranged_attack_time,
   dmg_min, dmg_max, movement_type, inhabit_type, regeneration, ai_name)
VALUES
  (@VENDOR, 'Countess Nightvein', 'Vampiric Goods', 6631, 35, 4,
   60, 60, 4007, 4007, 3272, 1, 7,
   1, 1.14286, 1, 2000, 2000,
   103.4, 129.8, 0, 3, 3, '');

-- Stock: maxcount 0 = unlimited. Price is item_template.buy_price.
INSERT INTO npc_vendor (entry, slot, item, maxcount, incrtime) VALUES
  (@VENDOR, 1, 55080, 0, 0), -- [5%] Bloodmoon, Sickle of the Murderous Flight (ilvl 88, 133.6g)
  (@VENDOR, 2, 55113, 0, 0), -- [3%] Dreadslayer Horns (ilvl 92, 44.0g)
  (@VENDOR, 3, 9473, 0, 0), -- [3%] Jinxed Hoodoo Skin (ilvl 49, 6.6g)
  (@VENDOR, 4, 55363, 0, 0), -- [3%] Grail of Forgotten Memories (ilvl 59, 9.5g)
  (@VENDOR, 5, 61284, 0, 0), -- [2%] Vest of Encroaching Darkness (ilvl 70, 18.1g)
  (@VENDOR, 6, 61353, 0, 0), -- [2%] Blackthorn Gauntlets (ilvl 47, 2.4g)
  (@VENDOR, 7, 19302, 0, 0), -- [2%] Darkmoon Ring (ilvl 55, 5.0g)
  (@VENDOR, 8, 55263, 0, 0), -- [2%] Twilight Opal Cascade (ilvl 63, 3.3g)
  (@VENDOR, 9, 61263, 0, 0), -- [2%] Tooth of the Packlord (ilvl 68, 8.6g)
  (@VENDOR, 10, 61278, 0, 0), -- [2%] Vampiric Kris (ilvl 68, 25.9g)
  (@VENDOR, 11, 51731, 0, 0), -- [2%] Venom Covered Cloak (ilvl 75, 6.4g)
  (@VENDOR, 12, 60294, 0, 0), -- [2%] Bloodstone Warblade (ilvl 47, 10.8g)
  (@VENDOR, 13, 61328, 0, 0), -- [2%] Wolfblood (ilvl 51, 13.4g)
  (@VENDOR, 14, 61571, 0, 0), -- [2%] Leeching Fang (ilvl 64, 23.3g)
  (@VENDOR, 15, 61313, 0, 0), -- [1%] Greymane Helmet (ilvl 49, 3.6g)
  (@VENDOR, 16, 55382, 0, 0), -- [1%] Mitre of the First Light (ilvl 25, 0.9g)
  (@VENDOR, 17, 55203, 0, 0), -- [1%] Reinforced Aquamarine Pendant (ilvl 43, 4.5g)
  (@VENDOR, 18, 61662, 0, 0), -- [1%] Stillward Amulet (ilvl 45, 2.7g)
  (@VENDOR, 19, 61302, 0, 0), -- [1%] Wolfheart Necklace (ilvl 46, 2.0g)
  (@VENDOR, 20, 58255, 0, 0), -- [1%] Crystal Pauldrons (ilvl 63, 14.6g)
  (@VENDOR, 21, 61356, 0, 0), -- [1%] Dreamhide Mantle (ilvl 76, 21.9g)
  (@VENDOR, 22, 4508, 0, 0), -- [1%] Blood-tinged Armor (ilvl 42, 3.7g)
  (@VENDOR, 23, 19682, 0, 0), -- [1%] Bloodvine Vest (ilvl 65, 12.5g)
  (@VENDOR, 24, 3845, 0, 0), -- [1%] Golden Scale Cuirass (ilvl 40, 3.3g)
  (@VENDOR, 25, 47208, 0, 0), -- [1%] Raiments of Transcendence (ilvl 76, 29.2g)
  (@VENDOR, 26, 61603, 0, 0), -- [1%] Robes of Ravenshire (ilvl 46, 3.0g)
  (@VENDOR, 27, 61331, 0, 0), -- [1%] Blackcowl Sash (ilvl 48, 3.4g)
  (@VENDOR, 28, 55386, 0, 0), -- [1%] Harbinger Girdle (ilvl 35, 1.3g)
  (@VENDOR, 29, 61288, 0, 0), -- [1%] Nightwoven Belt (ilvl 68, 6.0g)
  (@VENDOR, 30, 47211, 0, 0), -- [1%] Sash of Transcendence (ilvl 76, 15.1g)
  (@VENDOR, 31, 61727, 0, 0), -- [1%] Wolfwood Sash (ilvl 43, 1.9g)
  (@VENDOR, 32, 19683, 0, 0), -- [1%] Bloodvine Leggings (ilvl 65, 12.6g)
  (@VENDOR, 33, 61285, 0, 0), -- [1%] Duskwrapped Leggings (ilvl 68, 13.9g)
  (@VENDOR, 34, 19684, 0, 0), -- [1%] Bloodvine Boots (ilvl 65, 9.5g)
  (@VENDOR, 35, 61281, 0, 0), -- [1%] Shadeweave Boots (ilvl 66, 10.9g)
  (@VENDOR, 36, 61528, 0, 0), -- [1%] Aquis Bindings (ilvl 56, 4.9g)
  (@VENDOR, 37, 61440, 0, 0), -- [1%] Barkskin Elder Cuffs (ilvl 64, 4.3g)
  (@VENDOR, 38, 61282, 0, 0), -- [1%] Deepshadow Bracers (ilvl 68, 5.5g)
  (@VENDOR, 39, 61630, 0, 0), -- [1%] Ebonmere Vambraces (ilvl 46, 1.4g)
  (@VENDOR, 40, 61283, 0, 0), -- [1%] Darkgrasp Gloves (ilvl 68, 6.3g)
  (@VENDOR, 41, 58134, 0, 0), -- [1%] Stormreaver Gloves (ilvl 36, 0.7g)
  (@VENDOR, 42, 56048, 0, 0), -- [1%] Dazzling Aquamarine Loop (ilvl 41, 0.8g)
  (@VENDOR, 43, 58185, 0, 0), -- [1%] Leechmist Vine (ilvl 39, 3.8g)
  (@VENDOR, 44, 61385, 0, 0), -- [1%] Magnetic Band (ilvl 35, 1.6g)
  (@VENDOR, 45, 61498, 0, 0), -- [1%] Signet of Gilneas (ilvl 47, 1.7g)
  (@VENDOR, 46, 58175, 0, 0), -- [1%] Blood-etched Fetish (ilvl 42, 1.7g)
  (@VENDOR, 47, 58162, 0, 0), -- [1%] Horn of Razorscale (ilvl 37, 1.8g)
  (@VENDOR, 48, 55341, 0, 0), -- [1%] Totem of Self Preservation (ilvl 30, 0.3g)
  (@VENDOR, 49, 58116, 0, 0), -- [1%] Bloodstained Fangblade (ilvl 48, 9.2g)
  (@VENDOR, 50, 61261, 0, 0), -- [1%] Battlescarred Cloak (ilvl 68, 8.8g)
  (@VENDOR, 51, 33348, 0, 0), -- [1%] Brutalist Shroud (ilvl 61, 6.2g)
  (@VENDOR, 52, 20218, 0, 0), -- [1%] Faded Hakkari Cloak (ilvl 59, 7.3g)
  (@VENDOR, 53, 20219, 0, 0), -- [1%] Tattered Hakkari Cape (ilvl 59, 7.3g)
  (@VENDOR, 54, 60392, 0, 0), -- [1%] Sword of Laneron (ilvl 25, 1.3g)
  (@VENDOR, 55, 55030, 0, 0), -- [1%] Alidens Prejudice (ilvl 63, 27.8g)
  (@VENDOR, 56, 61755, 0, 0), -- [1%] Stagwood Grasp (ilvl 64, 28.6g)
  (@VENDOR, 57, 61286, 0, 0); -- [1%] Bloodfang Effigy (ilvl 68, 21.1g)
