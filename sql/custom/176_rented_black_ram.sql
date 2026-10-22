-- ============================================================================
--  A rentable Black Ram  (tw_world)
-- ============================================================================
--  Follow-on from 079. Creature 12370 "Black Ram" wears display 2784, the
--  model of spell 6896 "Black Ram" (instant, permanent, +mounted speed), so
--  the ram you click and the ram you ride are the same. It uses the ram
--  greeting 90381 that Brown Ram (12372) and Gray Ram (12373) already use.
--
--  IT IS CLAMPED LIKE EVERYTHING ELSE: 50 copper, rental speed by level,
--  5 minutes.
--
--  IT IS NOT SPAWNED. 12370 has no `creature` row. Stand where it should be
--  and type `.npc add 12370`, which writes its own row.
--
--  RELOAD, IN THIS ORDER, LIVE:
--    creature_template, rented_mount
--  Re-running 079 does not touch this row.
-- ============================================================================

DELETE FROM `rented_mount` WHERE `creature_entry` = 12370;
INSERT INTO `rented_mount` (`creature_entry`, `spell_id`, `cost`, `speed`, `duration`, `text_id`, `noun`) VALUES
  (12370, 6896, 50, 40, 300000, 90381, 'ram');

UPDATE `creature_template` SET `npc_flags` = `npc_flags` | 1, `script_name` = 'rented_mount'
WHERE `entry` = 12370;

-- -- check -------------------------------------------------------------------
--  Expect 1, 1 and 0. The last is UNIT_FLAG_NOT_SELECTABLE, which makes a
--  renter you cannot click.

SELECT
  (SELECT COUNT(*) FROM `rented_mount` WHERE `creature_entry` = 12370) AS rentable,
  (SELECT COUNT(*) FROM `creature_template` WHERE `entry` = 12370
     AND `script_name` = 'rented_mount' AND (`npc_flags` & 1) = 1) AS wired,
  (SELECT COUNT(*) FROM `creature_template` WHERE `entry` = 12370
     AND (`unit_flags` & 0x02000000) <> 0) AS not_selectable;
