-- 035_house_templates.sql -- housing templates and entrance purchase (tw_char).
--
-- Apply with:
--   Get-Content sql\custom\035_house_templates.sql | DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_char
--
-- SAFE TO RUN UNDER THE OLD BINARY. Everything here is additive: the running
-- mangosd names its columns in every housing SELECT and never touches the new
-- tables, so this can (and should) be applied before the binary that reads it
-- is swapped in. The other order is a crash -- a missing column or table is a
-- MySQLConnection::HandleMySQLError assert, not a warning.
--
-- What this is for, in one breath: a TEMPLATE is the inside a player starts
-- with -- a building shell, furniture, and an exit spot -- authored by the
-- developer in a house owned by a synthetic account, frozen by
-- `.house template save` into the two new tables, and stamped into a real
-- house when a player claims it at an entrance portal bound to it. See
-- docs/notes/housing.md.

-- 0 = bespoke: created before templates existed, or claimed at an untemplated
-- door. Every pre-template house is grandfathered as 0 and behaves exactly as
-- it always did.
ALTER TABLE `house`
    ADD COLUMN IF NOT EXISTS `template_id` INT UNSIGNED NOT NULL DEFAULT 0
        COMMENT '0 = bespoke; else the house_template this house was stamped from';

-- `source` is what makes "That came with the house." possible: template-stamped
-- rows cannot be deleted by the player and do not count against the object cap.
-- `stowed` ships now, ahead of the furniture chest, so stowing can later become
-- an UPDATE instead of another migration; the loader skips stowed rows.
ALTER TABLE `house_object`
    ADD COLUMN IF NOT EXISTS `source` TINYINT UNSIGNED NOT NULL DEFAULT 0
        COMMENT '0 placed by the player, 1 stamped from a template',
    ADD COLUMN IF NOT EXISTS `stowed` TINYINT UNSIGNED NOT NULL DEFAULT 0
        COMMENT 'furniture chest, later: 1 = stowed away, not spawned';

-- Which inside a door leads to. 0 = an untemplated door -- claiming there gives
-- an empty house, and the old non-destructive "make this my home" stays
-- available on it, which is exactly the pre-template world preserved.
ALTER TABLE `house_portal`
    ADD COLUMN IF NOT EXISTS `template_id` INT UNSIGNED NOT NULL DEFAULT 0
        COMMENT '0 = untemplated door (grandfathered semantics)';

-- One row per template. `house_id` is the AUTHORING house -- a real row in
-- `house` owned by a synthetic account (0xFFFFFFFE - template id), which is
-- what lets every normal furniture command work inside it unchanged. The
-- exit_* columns are FROZEN at save time, same as the object snapshot below:
-- half-finished edits must never leak into a purchase.
CREATE TABLE IF NOT EXISTS `house_template` (
  `id`         INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name`       VARCHAR(48)  NOT NULL COMMENT 'single word; referenced by .house entrance create',
  `house_id`   INT UNSIGNED NOT NULL COMMENT 'the authoring house row (synthetic account)',
  `exit_set`   TINYINT UNSIGNED NOT NULL DEFAULT 0,
  `exit_x`     FLOAT NOT NULL DEFAULT 0,
  `exit_y`     FLOAT NOT NULL DEFAULT 0,
  `exit_z`     FLOAT NOT NULL DEFAULT 0,
  `exit_o`     FLOAT NOT NULL DEFAULT 0,
  `saved_at`   BIGINT NOT NULL DEFAULT 0 COMMENT '0 = never saved: stamps nothing yet',
  `created_at` BIGINT NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_name` (`name`),
  KEY `idx_house` (`house_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- The frozen stamp source, rewritten wholesale by `.house template save`.
-- Deliberately NO gameobject guids here -- `id` is a plain row counter, and
-- stamping allocates fresh guids from the furniture block for each claim, so
-- a template costs nothing from the 24-bit guid space however many houses it
-- stamps.
CREATE TABLE IF NOT EXISTS `house_template_object` (
  `id`          INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `template_id` INT UNSIGNED NOT NULL,
  `go_entry`    INT UNSIGNED NOT NULL,
  `x`     FLOAT NOT NULL,
  `y`     FLOAT NOT NULL,
  `z`     FLOAT NOT NULL,
  `o`     FLOAT NOT NULL DEFAULT 0,
  `rot0`  FLOAT NOT NULL DEFAULT 0,
  `rot1`  FLOAT NOT NULL DEFAULT 0,
  `rot2`  FLOAT NOT NULL DEFAULT 0,
  `rot3`  FLOAT NOT NULL DEFAULT 0,
  `scale` FLOAT NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_template` (`template_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
