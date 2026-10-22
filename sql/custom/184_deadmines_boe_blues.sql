-- ============================================================================
--  MORE BOE BLUES IN THE DEADMINES  (tw_world)
-- ============================================================================
--  Applied with:
--
--    Get-Content sql\custom\184_deadmines_boe_blues.sql | `
--      DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_world
--
--  then `reload creature_loot_template` in the console.
--
--  Stock, only the ship mobs (Defias Pirate, Squallshaper, Goblin Shipbuilder)
--  can drop a BoE blue: three world drop references, 900605, 900636 and
--  900685, 31 blues of required level 15 to 20 at 0.025% each table. A full
--  clear gives 4.65% at rate 1. Blackfathom Deeps gives about 94%.
--
--  The references are shared by 15 to 24 loot tables across the world, so
--  their chances stay. Two changes, to Deadmines tables only (each is used by
--  its Deadmines spawns and nothing else):
--
--  1. The level 17 to 19 trash of the mines and the goblin halls gets the
--     same three references. 164 spawns, +12.3% a clear at rate 1.
--  2. The ship mobs roll the references twice (maxcount 2: LootTemplate::
--     Process rolls a reference row maxcount times). +4.65% a clear.
--
--  Together a clear gives 21.6% at rate 1, 43% at RareGear 2: one BoE blue in
--  about 2.3 clears.
--
--  Re-runnable. To undo: the DELETE alone, and maxcount back to 1.

-- 1. The references on the trash.
DELETE FROM creature_loot_template
WHERE mincountOrRef IN (-900605, -900636, -900685)
  AND entry IN (598, 634, 1729, 61960, 61959, 4416, 1731, 622, 641, 4417, 61962, 4418);

INSERT INTO creature_loot_template (entry, item, ChanceOrQuestChance, groupid, mincountOrRef, maxcount, condition_id)
SELECT t.entry, r.ref, 100, 0, -r.ref, 1, 0
FROM (SELECT 598 AS entry UNION ALL SELECT 634 UNION ALL SELECT 1729 UNION ALL SELECT 61960
      UNION ALL SELECT 61959 UNION ALL SELECT 4416 UNION ALL SELECT 1731 UNION ALL SELECT 622
      UNION ALL SELECT 641 UNION ALL SELECT 4417 UNION ALL SELECT 61962 UNION ALL SELECT 4418) t
CROSS JOIN (SELECT 900605 AS ref UNION ALL SELECT 900636 UNION ALL SELECT 900685) r;

-- 2. The ship mobs roll them twice.
UPDATE creature_loot_template SET maxcount = 2
WHERE mincountOrRef IN (-900605, -900636, -900685) AND entry IN (657, 3947, 1732);
