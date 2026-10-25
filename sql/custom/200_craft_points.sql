-- ============================================================================
--  CRAFT POINTS  (tw_char)
-- ============================================================================
--  Applied with:
--
--    Get-Content sql\custom\200_craft_points.sql | `
--      DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_char
--
--  Skill points from one craft. Stock gives 1 point for each successful craft
--  (SkillGain.Crafting). A recipe with a row in craft_points gives `points`
--  in place of that 1, and `green_points` while the recipe is green. The
--  recipe colour still sets the chance of a gain (SkillChance.*).
--
--  craft_points_rule is the rule for one profession, by skill id
--  (165 Leatherworking). Only the website reads it. The Craft points page
--  (/admin/craftpoints) applies the rule to every recipe of the profession,
--  writes the result to craft_points and sends the console command
--  `craftpoints`, which re-reads craft_points. mangosd also reads it at
--  startup. A recipe added to the world later gives 1 point until the next
--  save of its profession.
--
--  In tw_char and not tw_world: it is a setting of this realm, and content
--  moved between local and prod must not carry it.
--
--  mangosd probes information_schema before it reads, so a binary that meets
--  a database without this table gives stock points.
--
--  Re-runnable: creates if missing and never touches a row.

-- One rule for each profession. kinds is the comma list of product kinds that
-- get more points: armor, weapon, bag, other. green is full, half or one.
-- hand is a JSON object of points set by hand, {"<spell id>": points}.
CREATE TABLE IF NOT EXISTS `craft_points_rule` (
  `skill_id`       SMALLINT UNSIGNED NOT NULL,
  `enabled`        TINYINT UNSIGNED NOT NULL DEFAULT 0,
  `mats_per_point` TINYINT UNSIGNED NOT NULL DEFAULT 4,
  `max_points`     TINYINT UNSIGNED NOT NULL DEFAULT 4,
  `kinds`          VARCHAR(64) NOT NULL DEFAULT 'armor',
  `green`          VARCHAR(8) NOT NULL DEFAULT 'full',
  `hand`           TEXT NOT NULL,
  `changed_at`     DATETIME NULL,
  `changed_by`     VARCHAR(32) NOT NULL DEFAULT '',
  PRIMARY KEY (`skill_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- The points of one recipe, by its spell id (2149 is Handstitched Leather
-- Boots). No row: 1 point. skill_id is the profession, so a save can replace
-- its own rows.
CREATE TABLE IF NOT EXISTS `craft_points` (
  `spell_id`     INT UNSIGNED NOT NULL,
  `skill_id`     SMALLINT UNSIGNED NOT NULL,
  `points`       TINYINT UNSIGNED NOT NULL DEFAULT 1,
  `green_points` TINYINT UNSIGNED NOT NULL DEFAULT 1,
  PRIMARY KEY (`spell_id`),
  KEY `skill_id` (`skill_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
