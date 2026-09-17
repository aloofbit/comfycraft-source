-- ============================================================================
--  Factionless: let either side use either side's flight masters  (tw_world)
-- ============================================================================
--    Get-Content sql\custom\073_factionless_taxi.sql | `
--      DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_world
--
--  WHY. A taxi node is offered to a team only if its mount column for that team
--  is non-zero -- ObjectMgr::GetNearestTaxiNode (ObjectMgr.cpp:5147):
--
--      if (!node || node->map_id != mapid || !node->MountCreatureID[team == ALLIANCE ? 1 : 0])
--          continue;
--
--  Column 1 is Horde, column 2 is Alliance. Measured on the live table before
--  writing this file:
--
--      horde only 46 | alliance only 46 | already shared 12 | total 124
--
--  The remaining 20 rows have both mounts zero -- dead nodes, and the WHERE
--  clauses below leave them alone rather than inventing a mount for them.
--
--  Copying the mount across rather than substituting your own side's means an
--  Alliance player leaving Orgrimmar rides a wyvern, which is the right answer
--  anyway.
--
--  NO CLIENT PATCH. The node list the client draws comes from the player's own
--  taximask, sent by the server in SMSG_SHOWTAXINODES, so nothing on disk needs
--  changing.
--
--  THE LIMIT, STATED HONESTLY. The routes are still TaxiPath.dbc, and the
--  Alliance and Horde networks are two disjoint graphs. This buys "use their
--  flight masters, and their whole network once you have discovered it". It
--  does NOT buy a direct Stormwind -> Orgrimmar flight, because no such path
--  exists to select. Bridging them needs either a client-side DBC patch or
--  chaining through taxi_path_transitions where an Alliance and a Horde path
--  actually meet. Neither is done here.
--
--  NOT RELOADABLE. `taxi_nodes` is absent from the 103 .reload subcommands, so
--  this needs a restart to take effect.
--
--  Re-runnable: both statements are idempotent, and running them twice is a
--  no-op because after the first pass no row matches either WHERE any more.
--
--  ORDER MATTERS between the two, but only for readability -- each fills a gap
--  the other cannot see, so neither can undo the other.
--
--  Design: docs/features/factionless.md, piece 6.
-- ============================================================================

-- Alliance can use what only Horde could reach
UPDATE tw_world.taxi_nodes
SET    mount_creature_id2 = mount_creature_id1
WHERE  mount_creature_id2 = 0
  AND  mount_creature_id1 > 0;

-- Horde can use what only Alliance could reach
UPDATE tw_world.taxi_nodes
SET    mount_creature_id1 = mount_creature_id2
WHERE  mount_creature_id1 = 0
  AND  mount_creature_id2 > 0;
