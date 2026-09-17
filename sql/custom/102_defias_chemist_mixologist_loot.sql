-- ============================================================================
--  Loot for the Defias Chemist and the Defias Mixologist  (tw_world)
-- ============================================================================
--  Applied with:
--
--    Get-Content sql\custom\102_defias_chemist_mixologist_loot.sql | `
--      DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_world
--
--  then, in the mangosd console, no restart:
--
--    reload creature_loot_template
--
--  Two Turtle elites in the Deadmines (map 36, eight spawns between them),
--  level 17-18, whose creature_template.loot_id points at their own entry, and
--  that entry has no rows. Every kill logged
--
--    Table 'creature_loot_template' loot id #61960 used but it doesn't have records.
--
--  and the corpse held nothing but coin. Seen as far back as 2026-08-24.
--
--  Each copies the Deadmines Defias it already borrows its pickpocket table
--  from, which is Turtle's own pairing rather than a guess:
--
--    61959  Defias Chemist     <- 634   Defias Overseer
--    61960  Defias Mixologist  <- 1729  Defias Evoker
--
--  Same level, rank and coin range as their source. The copy is a snapshot:
--  a later change to 634 or 1729 does not follow it here.
--
--  Re-runnable: deletes both entries first.
-- ============================================================================

DELETE FROM creature_loot_template WHERE entry IN (61959, 61960);

INSERT INTO creature_loot_template
    (entry, item, ChanceOrQuestChance, groupid, mincountOrRef, maxcount, condition_id)
SELECT 61959, item, ChanceOrQuestChance, groupid, mincountOrRef, maxcount, condition_id
FROM creature_loot_template WHERE entry = 634;

INSERT INTO creature_loot_template
    (entry, item, ChanceOrQuestChance, groupid, mincountOrRef, maxcount, condition_id)
SELECT 61960, item, ChanceOrQuestChance, groupid, mincountOrRef, maxcount, condition_id
FROM creature_loot_template WHERE entry = 1729;
