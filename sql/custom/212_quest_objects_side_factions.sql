-- ============================================================================
--  Quest objects of one side can be used by both sides  (tw_world)
-- ============================================================================
--  Applied with:
--
--    Get-Content sql\custom\212_quest_objects_side_factions.sql | `
--      DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_world
--
--  then restart the server. An object that is already spawned keeps its old
--  faction until a restart.
--
--  151 moved the questgivers and chests on a player race faction to 35. It
--  missed the objects on a faction template that belongs to one side, such as
--  210 and 84 (Alliance Generic, no reputation bar) and 83 and 106 (Horde
--  Generic). The client does not let the other side use such an object. A
--  Horde player could take "Iverron's Antidote" (3521) but could not click the
--  Moonpetal Lily.
--
--  This moves every questgiver (type 2) and chest (type 3) whose faction
--  template is friendly to one player side and hostile to the other to
--  faction 35, which is friendly to everyone. That includes the city factions
--  (Stormwind, Orgrimmar and others), so no quest object depends on the
--  reputation that the factionless peace sets.
--
--  Left alone:
--  - Objects spawned in a battleground (Alterac Valley supplies and others).
--  - Objects on a monster faction that is hostile to one side, such as the
--    Alliance Chest and Horde Chest. They are loot taken from the enemy.
--
--  Re-runnable.
-- ============================================================================

UPDATE `gameobject_template` t
JOIN `faction_template` ft ON ft.`id` = t.`faction`
SET t.`faction` = 35
WHERE t.`type` IN (2, 3)
  AND (ft.`hostile_mask` & 6) <> 0
  AND ((ft.`friendly_mask` | ft.`our_mask`) & 6) <> 0
  AND t.`entry` NOT IN (
      SELECT `id` FROM `gameobject` WHERE `map` IN (30, 489, 529, 26, 27)
  );
