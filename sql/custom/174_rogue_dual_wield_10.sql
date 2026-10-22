-- ============================================================================
--  ROGUES TRAIN DUAL WIELD AT LEVEL 10  (tw_world)
-- ============================================================================
--  Applied with:
--
--    Get-Content sql\custom\174_rogue_dual_wield_10.sql | `
--      DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_world
--
--  then restart the server. Trainer lists load at startup.
--
--  Turtle WoW trains Dual Wield (teaching spell 1424) for rogues at level 10.
--  Upstream update 20260809183358 (trainer_updates.sql) set 1424 to level 20
--  on every trainer, with no trainer list. 20260826183610 put warriors back to
--  10 for 11 silver and left rogues at 20. This puts rogues back the same way.
--
--  The stock rogue trainers are the rows in comfy_trainer_stock with
--  trainer_class 4 (made by 116). A group trainer reads list 1104, not its own
--  npc_trainer rows. The generator (tools/gen-group-trainer-sql.js) builds 1104
--  from the stock rows, so both are changed here.
-- ============================================================================

UPDATE npc_trainer t JOIN comfy_trainer_stock s ON s.entry = t.entry
SET t.reqlevel = 10, t.spellcost = 1100
WHERE t.spell = 1424 AND s.trainer_class = 4;

UPDATE npc_trainer_template
SET reqlevel = 10, spellcost = 1100
WHERE entry = 1104 AND spell = 1424;
