-- ============================================================================
--  The Zulian Tiger joins the Gadgetzan pen  (tw_world)
-- ============================================================================
--  Follow-on from 079. Asked whether there was a rentable "Riding Tiger", the
--  answer turned out to be that THERE IS NO TIGER MODEL SEPARATE FROM THE
--  NIGHTSABERS. Every cat mount in 1.12 is internally named `Riding Tiger
--  (colour)` in creature_template -- 6448 is "Riding Tiger (BlackStriped)" --
--  while the spells players actually see call the same models Nightsaber,
--  Frostsaber, Panther and Sabercat. So renting Gadgetzan's Riding Tiger and
--  getting a black nightsaber was correct, and looked like a bug.
--
--  The one cat in this client that reads as an orange-and-black tiger is the
--  Zul'Gurub mount: spell 24252 "Zulian Tiger", creature 15104, display 15290.
--  Nothing was standing anywhere for a player to rent it from, so this file
--  adds the NPC.
--
--  ENTRY 100032 IS THE NEXT FREE ONE, 100031 being Mordrin the Marked. The
--  template is creature 12360 (Riding Striped Nightsaber) with the display and
--  the name changed: same faction 35, same level 1-2, same everything else, so
--  it behaves exactly like every other animal in a pen.
--
--  IT IS CLAMPED LIKE EVERYTHING ELSE. Spell 24252 is a 100% epic mount; the
--  rented_mount row below holds it to +40% for five minutes, same as the
--  Qiraji battle tanks 079 made rentable. A 50-copper Zulian Tiger is a
--  costume, not a fast mount.
--
--  IT IS SPAWNED HERE, unlike Mordrin in 078, because the point of the request
--  was to be able to rent one and an unplaced NPC cannot be rented. It goes in
--  the Gadgetzan pen beside the cats it belongs with, about four yards from the
--  Riding Tiger and on the same flat ground (z 8.63018, which the three
--  neighbouring spawns all share). Move it with `.npc del` and `.npc add
--  100032` somewhere else; the guid is one past the highest static spawn.
--
--  WHAT RELOADS AND WHAT DOES NOT:
--    reload creature_template, reload rented_mount   -- in that order, live.
--    The SPAWN needs a restart. `reload creature` does not place a guid that
--    was not there when the map loaded.
--  No new text: it borrows the cat greeting 079 wrote (100600).
-- ============================================================================

-- -- the NPC -------------------------------------------------------------------

DELETE FROM `creature_template` WHERE `entry` = 100032;
INSERT INTO `creature_template`
  (`entry`, `name`, `display_id1`, `level_min`, `level_max`, `faction`,
   `npc_flags`, `unit_flags`, `type`, `rank`, `health_min`, `health_max`,
   `movement_type`, `speed_walk`, `speed_run`, `script_name`)
VALUES
  (100032, 'Zulian Tiger', 15290, 1, 2, 35,
   1, 0, 1, 0, 46, 61,
   0, 1, 1.38571, 'rented_mount');

-- -- rentable ------------------------------------------------------------------
--  Spell 24252 is the Zul'Gurub mount, whose own display is 15290 -- the same
--  one the NPC wears -- so the animal in the pen and the animal you ride are
--  the same beast by construction, and the core's display index agrees with the
--  row rather than overriding it.

DELETE FROM `rented_mount` WHERE `creature_entry` = 100032;
INSERT INTO `rented_mount` (`creature_entry`, `spell_id`, `cost`, `speed`, `duration`, `text_id`, `noun`) VALUES
  (100032, 24252, 50, 40, 300000, 100600, 'tiger');

-- -- where it stands ------------------------------------------------------------
--  Gadgetzan's stable pen, map 1. Its neighbours, for reference:
--    8882 Riding Tiger   -7092.20  -3729.85  8.63018
--    8883 Riding Horse   -7090.77  -3732.81  8.63018
--    8885 Riding Raptor  -7097.74  -3704.55  8.64253
--  Guid 2902685 is one past MAX(guid) 2902684. That is deliberate rather than a
--  round number: mangosd reserves its runtime creature guids ABOVE the highest
--  static one (GuidReserveSize.Creature = 5300000), so a static row tucked in
--  just above the top shifts the reserve up by one and collides with nothing.

DELETE FROM `creature` WHERE `guid` = 2902685;
INSERT INTO `creature`
  (`guid`, `id`, `map`, `position_x`, `position_y`, `position_z`, `orientation`,
   `spawntimesecsmin`, `spawntimesecsmax`, `wander_distance`, `health_percent`,
   `mana_percent`, `movement_type`)
VALUES
  (2902685, 100032, 1, -7094.5, -3726.0, 8.63018, 3.3,
   300, 300, 0, 100,
   100, 0);

-- -- check -------------------------------------------------------------------
--  Expect 1, 1, 1 and 0 -- the last being a guid collision, which must be zero.

SELECT
  (SELECT COUNT(*) FROM `creature_template` WHERE `entry` = 100032) AS template,
  (SELECT COUNT(*) FROM `rented_mount` WHERE `creature_entry` = 100032) AS rentable,
  (SELECT COUNT(*) FROM `creature` WHERE `guid` = 2902685 AND `id` = 100032) AS spawned,
  (SELECT COUNT(*) FROM `creature` WHERE `guid` = 2902685 AND `id` <> 100032) AS guid_clash;
