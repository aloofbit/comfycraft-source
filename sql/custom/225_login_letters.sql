-- ============================================================================
--  LOGIN LETTERS  (tw_char)
-- ============================================================================
--  Applied with:
--
--    Get-Content sql\custom\225_login_letters.sql | `
--      DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_char
--
--  APPLY BEFORE THE BINARY THAT READS IT. mangosd probes for these tables at
--  start-up, so a binary that starts without them sends no letters. Applied
--  later, they need a restart.
--
--  A letter that is on goes by mail to each character when it logs in, once.
--  The sender is "ComfyCraft Staff" (creature 100041, sql/custom/153) on the
--  staff letter paper, as /admin/mail sends. Bots and companions get none.
--
--  login_letter        the letters: a switch, the subject, the text, and one
--                      item stack (1.12 mail holds one). item_entry 0 is a
--                      letter with no item.
--  login_letter_sent   one row for each letter and character that had it.
--                      Character guids are reused, so Player::DeleteFromDB
--                      deletes a character's rows.
--
--  The Login letters page on the website (/admin/loginletters) writes the
--  letters. mangosd reads them at each login, so a save needs no console
--  command.
--
--  In tw_char and not tw_world: it is a setting of this realm, and content
--  moved between local and prod must not carry it.
--
--  Re-runnable: creates if missing, and seeds the Hallow's End letter, off,
--  only when no letter exists.
-- ============================================================================

CREATE TABLE IF NOT EXISTS `login_letter` (
  `id`         INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `enabled`    TINYINT UNSIGNED NOT NULL DEFAULT 0,
  `subject`    VARCHAR(64) NOT NULL,
  `body`       VARCHAR(1000) NOT NULL DEFAULT '',
  `item_entry` INT UNSIGNED NOT NULL DEFAULT 0,
  `item_count` INT UNSIGNED NOT NULL DEFAULT 1,
  `changed_at` DATETIME NULL,
  `changed_by` VARCHAR(32) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `login_letter_sent` (
  `letter_id` INT UNSIGNED NOT NULL,
  `guid`      INT UNSIGNED NOT NULL,
  `sent_at`   DATETIME NOT NULL,
  PRIMARY KEY (`letter_id`, `guid`),
  KEY `guid` (`guid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `login_letter` (`enabled`, `subject`, `body`, `item_entry`, `item_count`)
SELECT 0, 'Happy Hallow''s End!',
       'Happy Hallow''s End!\n\nWanted to thank you for being here and helping with alpha testing. We spent the last week carving each of these by hand. Please enjoy!\n\nWarning: Recommended remove candle before wearing\n\nBest,\nComfyCraft',
       100078, 1
  FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM `login_letter`);
