-- ============================================================================
--  PLANS: SHADOWFORGED EYE DROP CHANCE  (tw_world)
-- ============================================================================
--  Applied with:
--
--    Get-Content sql\custom\204_shadowforged_eye_plans.sql | `
--      DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_world
--
--  Then `reload creature_loot_template` in the mangosd console.
--
--  Plans: Shadowforged Eye (70204) drops from Shadowforge Prowler (80207) and
--  Shadowforge Fire Priest (80205), in loot group 5 with Amber Topaz (81094).
--  Upstream gives it 1%: half of players needed about 70 kills. The owner set
--  it to 3% on 2026-10-25 (about 23 kills). The group stays below 100%.
-- ============================================================================

UPDATE creature_loot_template
SET ChanceOrQuestChance = 3
WHERE item = 70204 AND entry IN (80205, 80207);
