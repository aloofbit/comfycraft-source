-- ============================================================================
--  Housing settings: the choices that are the player's  (tw_char)
-- ============================================================================
--  Two of them so far, and both are preferences rather than rules -- the server
--  has no opinion about either, which is exactly what makes them settings:
--
--    0  point_and_click_placing   RETIRED 2026-09-03. The slot stays burnt:
--                                 ids key the rows below, so reusing 0 for a
--                                 DIFFERENT setting would reinterpret saved
--                                 preferences rather than replace them.
--                 1 = a crate from your bags lands where you clicked
--                 0 = it lands HOUSE_PLACE_DISTANCE yards in front of you, and
--                     item_template.spellid_1 is rewritten for every furniture
--                     item so no client raises the ground reticle either
--    1  glow      1 = the selected object wears its shimmer
--                 0 = it does not
--
--  SCOPE IS A PROPERTY OF THE SETTING. Most are the player's; one is not,
--  because what it controls is a column shared by every client and could never
--  have varied per player. A global setting is stored under `account` 0 -- real
--  account ids count up from 1, so that row can never collide with anybody's --
--  and is refused below SEC_DEVELOPER.
--
--  THE NAME IS WHAT THE PLAYER TYPES AND IT HAS TO SAY WHAT ON MEANS. Setting 0
--  was called `placing` for one build, which left the reader to guess what the
--  other state even was. Renaming it cost nothing here: the id is what this
--  table stores, so every row already written kept its meaning.
--
--  KEYED BY ACCOUNT, like `house` and `house_storage`, so an alt walks into the
--  same room set up the same way. There is no per-character form of this and
--  there should not be: the house is the account's.
--
--  AN ABSENT ROW IS THE DEFAULT, and every default is 1 -- which is housing
--  exactly as it behaved before any of this existed. So a table that has never
--  been written to is indistinguishable from the server as it shipped, and
--  there is nothing to backfill when a setting is added. `value` is wider than
--  a boolean needs on purpose: the next setting may not be one.
--
--  A SETTING ID THE BINARY DOES NOT KNOW IS IGNORED AT LOAD, not an error.
--  Rolling a binary back past a setting somebody has used would otherwise be a
--  startup failure over a preference, which is the wrong price for it.
--
--  Re-runnable, and non-destructive: it only ever creates.
--
--  Apply with:
--    Get-Content sql\custom\050_house_settings.sql | DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_char
-- ============================================================================

CREATE TABLE IF NOT EXISTS `house_setting` (
  `account` INT UNSIGNED     NOT NULL  COMMENT 'tw_logon.account.id, matching house.account',
  `setting` TINYINT UNSIGNED NOT NULL  COMMENT 'HouseSetting: 0 RETIRED (was point_and_click_placing), 1 glow',
  `value`   INT UNSIGNED     NOT NULL  COMMENT 'the chosen value; absent row = the default, which is 1',
  PRIMARY KEY (`account`, `setting`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------------------------------------------------------
-- ROLLBACK
--
-- Dropping this loses every player's preferences and nothing else -- housing
-- reverts to the defaults, which is how it behaved before 2026-09-03.
--
-- DROP TABLE IF EXISTS `house_setting`;
-- ----------------------------------------------------------------------------
