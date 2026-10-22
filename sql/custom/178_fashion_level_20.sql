-- ============================================================================
--  Fashion Demands Sacrifices (level 20): no Medium Leather, 1 Shadowgem,
--  3 Small Furry Paw; Shadowgem drops twice as often  (tw_world)
-- ============================================================================
--  Applied with:
--
--    Get-Content sql\custom\178_fashion_level_20.sql | `
--      DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_world
--
--  then, in the mangosd console, no restart:
--
--    reload creature_loot_template
--    reload gameobject_loot_template
--    reload pickpocketing_loot_template
--    reload reference_loot_template
--    reload quest_template
--
--  Upstream 60031 asks for 5 Wool Cloth, 5 Medium Leather, 5 Shadowgem and
--  5 Small Furry Paw. Medium Leather (2319) comes from Skinning, three level
--  58-60 mobs at 0.6% and Lhara at the Darkmoon Faire, so it is removed.
--  Shadowgem (1210) drops at 0.49% on average from level 18-30 mobs. The
--  paw (5134) drops only from level 10-20 cats in Darkshore, The Barrens and
--  Frostmane Hollow. The quest now asks for:
--
--    1  Wool Cloth (2592)        5
--    2  Shadowgem (1210)         1
--    3  Small Furry Paw (5134)   3
--
--  Every positive Shadowgem chance in these four tables is now two times the
--  upstream value:
--
--    creature_loot_template      1017 rows   (the highest is 50%)
--    gameobject_loot_template      19 rows   (6 in a vein's gem group; the
--                                             group is 6% in all at most)
--    pickpocketing_loot_template   55 rows   (the highest is 40%)
--    reference_loot_template       11 rows
--
--  Not changed: quest-only rows (a negative chance), containers in
--  item_loot_template and the two jewelcrafting vendors.
--
--  comfy_loot_baseline (sql/custom/143) keeps the upstream chance, so a
--  second run sets the same value and does not multiply again. The quest
--  text names no items. A character with the quest in progress when this
--  lands has its counts in the old slots: abandon and take it again.
--  Re-runnable.
-- ============================================================================

UPDATE quest_template
   SET ReqItemId1 = 2592, ReqItemCount1 = 5,
       ReqItemId2 = 1210, ReqItemCount2 = 1,
       ReqItemId3 = 5134, ReqItemCount3 = 3,
       ReqItemId4 = 0,    ReqItemCount4 = 0
 WHERE entry = 60031;

CREATE TABLE IF NOT EXISTS comfy_loot_baseline (
  src     VARCHAR(32)        NOT NULL,
  entry   MEDIUMINT UNSIGNED NOT NULL,
  item    MEDIUMINT UNSIGNED NOT NULL,
  groupid TINYINT UNSIGNED   NOT NULL,
  chance  FLOAT              NOT NULL,
  PRIMARY KEY (src, entry, item, groupid)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3
  COMMENT='Upstream loot chances, kept by sql/custom scripts that scale them';

INSERT IGNORE INTO comfy_loot_baseline
SELECT 'creature', entry, item, groupid, ChanceOrQuestChance
  FROM creature_loot_template WHERE item = 1210 AND ChanceOrQuestChance > 0;
INSERT IGNORE INTO comfy_loot_baseline
SELECT 'gameobject', entry, item, groupid, ChanceOrQuestChance
  FROM gameobject_loot_template WHERE item = 1210 AND ChanceOrQuestChance > 0;
INSERT IGNORE INTO comfy_loot_baseline
SELECT 'pickpocketing', entry, item, groupid, ChanceOrQuestChance
  FROM pickpocketing_loot_template WHERE item = 1210 AND ChanceOrQuestChance > 0;
INSERT IGNORE INTO comfy_loot_baseline
SELECT 'reference', entry, item, groupid, ChanceOrQuestChance
  FROM reference_loot_template WHERE item = 1210 AND ChanceOrQuestChance > 0;

UPDATE creature_loot_template l JOIN comfy_loot_baseline b
    ON b.src = 'creature' AND b.entry = l.entry AND b.item = l.item AND b.groupid = l.groupid
   SET l.ChanceOrQuestChance = LEAST(b.chance * 2, 100)
 WHERE l.item = 1210;
UPDATE gameobject_loot_template l JOIN comfy_loot_baseline b
    ON b.src = 'gameobject' AND b.entry = l.entry AND b.item = l.item AND b.groupid = l.groupid
   SET l.ChanceOrQuestChance = LEAST(b.chance * 2, 100)
 WHERE l.item = 1210;
UPDATE pickpocketing_loot_template l JOIN comfy_loot_baseline b
    ON b.src = 'pickpocketing' AND b.entry = l.entry AND b.item = l.item AND b.groupid = l.groupid
   SET l.ChanceOrQuestChance = LEAST(b.chance * 2, 100)
 WHERE l.item = 1210;
UPDATE reference_loot_template l JOIN comfy_loot_baseline b
    ON b.src = 'reference' AND b.entry = l.entry AND b.item = l.item AND b.groupid = l.groupid
   SET l.ChanceOrQuestChance = LEAST(b.chance * 2, 100)
 WHERE l.item = 1210;
