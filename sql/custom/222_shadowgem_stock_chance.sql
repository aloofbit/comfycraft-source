-- ============================================================================
--  Shadowgem drops at its upstream chance again  (tw_world)
-- ============================================================================
--  Applied with:
--
--    Get-Content sql\custom\222_shadowgem_stock_chance.sql | `
--      DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_world
--
--  then, in the mangosd console, no restart:
--
--    reload creature_loot_template
--    reload gameobject_loot_template
--    reload pickpocketing_loot_template
--    reload reference_loot_template
--
--  sql/custom/178 doubled every positive Shadowgem (1210) chance in these
--  four tables. Shadowgem is a green that is not gear, so an ungrouped row
--  also takes Rate.Drop.Item.Uncommon (3): 6 times upstream in all. This
--  script sets each row back to the upstream chance that 178 kept in
--  comfy_loot_baseline. With Uncommon = 3 that is about 1 in 70 kills from
--  level 18-30 mobs (upstream 0.49% a kill on average).
--
--  The quest change in 178 (60031 asks for 1 Shadowgem) stays. 178 no longer
--  doubles, so a later run of 178 sets the same values. Re-runnable.
-- ============================================================================

UPDATE creature_loot_template l JOIN comfy_loot_baseline b
    ON b.src = 'creature' AND b.entry = l.entry AND b.item = l.item AND b.groupid = l.groupid
   SET l.ChanceOrQuestChance = b.chance
 WHERE l.item = 1210;
UPDATE gameobject_loot_template l JOIN comfy_loot_baseline b
    ON b.src = 'gameobject' AND b.entry = l.entry AND b.item = l.item AND b.groupid = l.groupid
   SET l.ChanceOrQuestChance = b.chance
 WHERE l.item = 1210;
UPDATE pickpocketing_loot_template l JOIN comfy_loot_baseline b
    ON b.src = 'pickpocketing' AND b.entry = l.entry AND b.item = l.item AND b.groupid = l.groupid
   SET l.ChanceOrQuestChance = b.chance
 WHERE l.item = 1210;
UPDATE reference_loot_template l JOIN comfy_loot_baseline b
    ON b.src = 'reference' AND b.entry = l.entry AND b.item = l.item AND b.groupid = l.groupid
   SET l.ChanceOrQuestChance = b.chance
 WHERE l.item = 1210;
