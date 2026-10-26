-- ============================================================================
--  Portal Home: the way back, saved  (tw_char)
-- ============================================================================
--  One row per character who went into a house through a Portal Home and has
--  not come out yet: the spot they clicked from. Leave puts them back there.
--  HouseMgr keeps the same rows in memory (m_returns) and loads this table at
--  startup, so a restart no longer sends them to their hearthstone.
--
--  via_account is the account whose portal it was; host_guid is the character
--  who cast it. instance is the dungeon copy (0 on a continent). The way back
--  checks the bind before it uses it.
--
--  CHARACTER GUIDS ARE REUSED: Player::DeleteFromDB deletes the row.
--
--  Re-runnable. Apply BEFORE the binary that reads it.
--
--  Applied with:
--
--    Get-Content sql\custom\209_character_house_return.sql | `
--      DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_char
--
--  The deploy reads the database from that line. Without it the file went to
--  tw_world on 2026-10-25 and mangosd stopped at start-up.

CREATE TABLE IF NOT EXISTS `character_house_return` (
    `guid`        INT UNSIGNED      NOT NULL,
    `via_account` INT UNSIGNED      NOT NULL DEFAULT 0,
    `host_guid`   INT UNSIGNED      NOT NULL DEFAULT 0,
    `map`         SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    `instance`    INT UNSIGNED      NOT NULL DEFAULT 0,
    `x`           FLOAT             NOT NULL DEFAULT 0,
    `y`           FLOAT             NOT NULL DEFAULT 0,
    `z`           FLOAT             NOT NULL DEFAULT 0,
    `o`           FLOAT             NOT NULL DEFAULT 0,
    PRIMARY KEY (`guid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
