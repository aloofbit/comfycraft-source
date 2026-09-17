-- ============================================================================
--  Companion ownership  (tw_char  -- NOT tw_world, unlike most of this folder)
-- ============================================================================
--  Applied with:
--
--    Get-Content sql\custom\066_companion_ownership.sql | `
--      DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_char
--
--  WHAT THIS IS FOR. Companions are playerbots created to order when you hire
--  one and deleted when you dismiss one, so a companion IS a real row in
--  `characters` with a real account behind it -- there is no way to have a
--  Player without both (WorldSession::HandlePlayerLogin reads the character
--  tables, and AddPlayerBot refuses a guid with no account).
--
--  They do NOT live on the hiring player's account. That account caps at 9
--  characters shared with their real ones, and three companions would eat a
--  third of somebody's roster. They live on a server-owned COMPANION0..N pool
--  instead, walked and created lazily the same way RNDBOT accounts are.
--
--  WHICH BREAKS OWNERSHIP, AND IS WHY THIS TABLE EXISTS. PlayerbotHolder
--  decides "is this yours" as:
--
--      it is on a random-pool account, OR it is on your account
--
--  There is no third notion of an owner, so a companion on a COMPANION account
--  is nobody's and `.bot delete` refuses it with "Not your bot". This table is
--  that third notion: companion guid -> owning character guid.
--
--  COMPANION ACCOUNTS ARE DELIBERATELY *NOT* ADDED TO randomBotAccounts. That
--  list is how RandomPlayerbotMgr decides what it owns and may recycle, and a
--  companion swept into the random pool would be re-rolled or logged out from
--  under its owner.
--
--  EPHEMERAL BY DESIGN. Every row here is purged at startup and the characters
--  it names are deleted -- see CompanionOwnership::PurgeAtStartup. A row that
--  survives a restart means the server died with companions out, and deleting
--  them is the correct recovery: without it a crash leaks characters into a
--  COMPANION account for ever. So this table is CRASH RECOVERY, not
--  persistence, and a companion is never expected to outlive the session that
--  hired it.
--
--  Re-runnable: CREATE TABLE IF NOT EXISTS, and the purge empties it anyway.
-- ============================================================================

CREATE TABLE IF NOT EXISTS `companion_owner` (
    `companion_guid` INT UNSIGNED NOT NULL COMMENT 'characters.guid of the companion',
    `owner_guid`     INT UNSIGNED NOT NULL COMMENT 'characters.guid of the player who hired it',
    `account_id`     INT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'the COMPANION pool account it was made on',
    `created_time`   INT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'unix time, for stale-row triage',
    PRIMARY KEY (`companion_guid`),
    KEY `idx_owner` (`owner_guid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8
  COMMENT='Ephemeral: purged and its characters deleted at every startup.';

-- ============================================================================
--  No restart needed for the table itself, but the code that reads it ships in
--  the binary, so this must be applied BEFORE the build that uses it. A missing
--  table is a hard crash on this core (MySQLConnection::HandleMySQLError
--  asserts), which is the same ordering rule housing's column migrations follow.
-- ============================================================================
