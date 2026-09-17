-- ============================================================================
--  Companions wait for you  (tw_char  -- NOT tw_world)
-- ============================================================================
--  Applied with:
--
--    Get-Content sql\custom\071_companion_parked.sql | `
--      DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_char
--
--  Until 2026-09-09 logging out was a dismissal: the core evicts every bot
--  from your party as you go, the group hook queued each one, and they were
--  deleted the next time you logged in. A dropped connection did not even do
--  that - it left them in your party, offline and yours, with nothing to
--  bring them back and Elowen refusing new hires because you "already had
--  two".
--
--  Now a logout of either kind PARKS them: they log out with a save, and the
--  time goes here. Log back in within AiPlayerbot.CompanionParkMinutes (15)
--  and they log in after you and rejoin; later than that and they are
--  deleted with a line saying so. See CompanionOwnership::ParkAll and
--  PlayerbotMgr::RestoreParkedCompanions.
--
--  A restart is the same case, later the same day: PurgeAtStartup keeps a row
--  whose owner still exists and whose stamp is inside the window (a row with
--  no stamp - the server died with the companion out - counts from startup),
--  and deletes everything else on the pool, which is still what keeps a crash
--  from leaking characters into it for ever.
--
--  ORDER: apply this BEFORE the binary that writes it. A missing column is a
--  hard crash on this core, the same rule housing's column migrations follow.
--
--  Re-runnable: ADD COLUMN IF NOT EXISTS, and the table comment is idempotent.
-- ============================================================================

ALTER TABLE `companion_owner`
    ADD COLUMN IF NOT EXISTS `parked_time` INT UNSIGNED NOT NULL DEFAULT 0
        COMMENT 'unix time the owner logged out with this companion, 0 = out with them'
    AFTER `created_time`;

ALTER TABLE `companion_owner`
    COMMENT = 'Ephemeral with a grace period: at startup a row with a living owner inside AiPlayerbot.CompanionParkMinutes is kept, the rest deleted with their characters.';
