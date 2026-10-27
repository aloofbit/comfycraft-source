-- ============================================================================
--  A faction saved for one creature spawn  (tw_world)
-- ============================================================================
--  One row per spawn that keeps a faction of its own, set with
--  `.npc savefaction <faction>`. guid is creature.guid. CreatureSpawnFaction
--  loads the table at startup and uses it wherever the core would put the
--  template's faction back: create, respawn, the end of a temporary faction,
--  and the escort and follower AIs.
--
--  Creature::DeleteFromDB deletes the row with the spawn, because `.npc add`
--  can give a new spawn the guid of a deleted one.
--
--  Re-runnable. Apply BEFORE the binary that reads it: a table the binary
--  reads and the database lacks crashes the server.
--
--  Applied with:
--
--    Get-Content sql\custom\211_creature_spawn_faction.sql | `
--      DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_world

CREATE TABLE IF NOT EXISTS `creature_spawn_faction` (
  `guid`    INT UNSIGNED NOT NULL COMMENT 'creature.guid',
  `faction` INT UNSIGNED NOT NULL COMMENT 'FactionTemplate.dbc id',
  PRIMARY KEY (`guid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COMMENT='A faction kept for one creature spawn (.npc savefaction)';
