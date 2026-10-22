-- ============================================================================
--  MORE BOE BLUES IN WAILING CAVERNS  (tw_world)
-- ============================================================================
--  Applied with:
--
--    Get-Content sql\custom\185_wailing_caverns_boe_blues.sql | `
--      DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_world
--
--  then `reload creature_loot_template` in the console.
--
--  The same change as 184 made to the Deadmines. Stock, the BoE blues come
--  from the three world drop references 900605, 900636 and 900685 (31 blues
--  of required level 15 to 20, 0.025% each table), on 76 spawns: the Deviate
--  Shamblers, Vipers, Venomwings, Dreadfangs and the Unnatural Overgrowth. A
--  full clear gives 8.9% at rate 1.
--
--  The references are shared by 15 to 24 loot tables across the world, so
--  their chances stay. The level 17 to 20 trash without them gets them: 220
--  spawns, +16.5% a clear. Each table below is used by its Wailing Caverns
--  spawns and nothing else.
--
--    3640 Evolving Ectoplasm    5053 Deviate Crocolisk    3636 Deviate Ravager
--    3637 Deviate Guardian      8886 Deviate Python       5048 Deviate Adder
--    3840 Druid of the Fang     5055 Deviate Lasher
--
--  A clear then gives 25.4% at rate 1, 51% at RareGear 2: one BoE blue in
--  about 2 clears. The Deadmines after 184: 43%, one in 2.3.
--
--  Re-runnable. To undo: the DELETE alone.

DELETE FROM creature_loot_template
WHERE mincountOrRef IN (-900605, -900636, -900685)
  AND entry IN (3640, 5053, 3636, 3637, 8886, 5048, 3840, 5055);

INSERT INTO creature_loot_template (entry, item, ChanceOrQuestChance, groupid, mincountOrRef, maxcount, condition_id)
SELECT t.entry, r.ref, 100, 0, -r.ref, 1, 0
FROM (SELECT 3640 AS entry UNION ALL SELECT 5053 UNION ALL SELECT 3636 UNION ALL SELECT 3637
      UNION ALL SELECT 8886 UNION ALL SELECT 5048 UNION ALL SELECT 3840 UNION ALL SELECT 5055) t
CROSS JOIN (SELECT 900605 AS ref UNION ALL SELECT 900636 UNION ALL SELECT 900685) r;
