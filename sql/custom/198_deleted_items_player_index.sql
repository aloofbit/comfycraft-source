-- ============================================================================
--  CHARACTER DELETED ITEMS: AN INDEX ON player_guid  (tw_char)
-- ============================================================================
--  Applied with:
--
--    Get-Content sql\custom\198_deleted_items_player_index.sql | `
--      DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_char
--
--  Any order against the binary: the binary reads no new column.
--
--  Player::DeleteFromDB runs `DELETE FROM character_deleted_items WHERE
--  player_guid = N`. With no index on player_guid that is a scan of the whole
--  table, and on InnoDB a scan locks every row it reads until the commit. Two
--  character deletes at the same time (two companions dismissed together)
--  then wait on each other's rows and deadlock. With the index, each delete
--  locks only its own character's rows.
--
--  Re-runnable: adds the index if missing.

ALTER TABLE `character_deleted_items`
  ADD INDEX IF NOT EXISTS `idx_player_guid` (`player_guid`);
