-- ============================================================================
--  The Zulian Tiger leaves the Gadgetzan pen  (tw_world)
-- ============================================================================
--  Undoes the SPAWN half of 080, and only that half.
--
--  080 put it there because the answer to "is there a rentable tiger" was no.
--  081 changed that answer: creature 8882's red skin now rents spell 10790,
--  which is named simply "Tiger", so the pen has a tiger in it without this one
--  and a second cat standing beside the four the Riding Tiger already rotates
--  through is clutter rather than content.
--
--  WHAT IS KEPT, AND WHY. Creature 100032 and its `rented_mount` row both stay.
--  The Zulian Tiger is not the same mount as 10790 -- it is the Zul'Gurub one,
--  the striped orange cat, and it is the flashiest in the client -- so what is
--  wrong with it is the PLACE, not the mount. Keeping the definition means
--  putting it somewhere it belongs later costs one command and no SQL:
--
--      .npc add 100032
--
--  which spawns it where you are standing and writes its own `creature` row.
--  Yojamba Isle or Booty Bay would be the thematic homes, being the Zul'Gurub
--  end of the world.
--
--  TO REMOVE IT COMPLETELY instead, add these two and it is as if 080 never
--  ran -- nothing else references either row:
--
--      DELETE FROM `rented_mount`      WHERE `creature_entry` = 100032;
--      DELETE FROM `creature_template` WHERE `entry`          = 100032;
--
--  Entry 100032 stays claimed either way until then; CLAUDE.md says the next
--  free one is 100033.
--
--  IT NEEDS A RESTART, or `.npc delete` while targeting it. Deleting the row
--  takes it out of the world the map loads NEXT time; the creature already
--  spawned lives in memory until then. `.npc delete` from the console cannot do
--  it -- the handler reads m_session->GetPlayer() for the map to look in, and a
--  console session has no player (Commands.cpp:10840).
-- ============================================================================

DELETE FROM `creature` WHERE `guid` = 2902685 AND `id` = 100032;

-- -- check -------------------------------------------------------------------
--  Expect spawned 0, and template and rentable both still 1 -- the mount is
--  still defined and still rentable, it is simply nowhere.

SELECT
  (SELECT COUNT(*) FROM `creature`          WHERE `id`             = 100032) AS spawned,
  (SELECT COUNT(*) FROM `creature_template` WHERE `entry`          = 100032) AS template,
  (SELECT COUNT(*) FROM `rented_mount`      WHERE `creature_entry` = 100032) AS rentable;
