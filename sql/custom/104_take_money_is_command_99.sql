-- ============================================================================
--  SCRIPT_COMMAND_TAKE_MONEY is 99 here, not 93  (tw_world)
-- ============================================================================
--  Applied with:
--
--    Get-Content sql\custom\104_take_money_is_command_99.sql | `
--      DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_world
--
--  then a restart on a binary that has command 99 (gossip_scripts is read
--  at startup and `reload gossip_scripts` needs the command compiled in).
--
--  Upstream (tortoise-wow/tortoise-wow, ab6d64a "Northwind Quest Fixes")
--  added SCRIPT_COMMAND_TAKE_MONEY as 93. Ours has been
--  SCRIPT_COMMAND_RECRUIT_BOT since the companions work, with 94-98 after
--  it, so the upstream command was pulled in as 99 instead.
--
--  Upstream's 20260906081248_world.sql writes command 93 for the Northwind
--  "Pay 20 Silver" option. On this core that row would hire a companion,
--  so it is moved to 99. Any later upstream SQL using 93 as TAKE_MONEY
--  needs the same treatment: every 93 row of our own is in 6400000+.
-- ============================================================================

UPDATE `gossip_scripts`
SET `command` = 99
WHERE `command` = 93
  AND `id` < 6400000;
