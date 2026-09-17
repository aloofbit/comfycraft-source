-- 057_house_critters.sql   (tw_char)
--
-- Critters that live in a house: rabbits, cats, turtles. The exact shape of
-- house_object, one table over, because they ride the exact same seam --
-- ObjectGridLoader::Visit reads the per-instance grid set for creatures as
-- well as for gameobjects, so registering a creature there makes it belong to
-- one house instead of every house on map 28.
--
--   Get-Content sql\custom\057_house_critters.sql | DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_char
--
-- APPLY THIS BEFORE THE BINARY. A missing table is a hard crash on this
-- server, not a warning -- the same rule sql/custom/040 carries.
--
-- CREATE TABLE IF NOT EXISTS, and no DROP: this holds player content. It is
-- re-runnable in the sense that running it twice is harmless, NOT in the
-- sense that it resets anything.

CREATE TABLE IF NOT EXISTS `house_critter` (
  `id`        INT(10) UNSIGNED NOT NULL COMMENT 'this is the creature guid',
  `house_id`  INT(10) UNSIGNED NOT NULL,
  `slot`      INT(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'short per-house number, 1-based; 0 = not yet assigned',
  `entry`     INT(10) UNSIGNED NOT NULL COMMENT 'creature_template.entry',
  `x`         FLOAT NOT NULL,
  `y`         FLOAT NOT NULL,
  `z`         FLOAT NOT NULL,
  `o`         FLOAT NOT NULL DEFAULT 0,
  `wander`    FLOAT NOT NULL DEFAULT 0 COMMENT 'yards it may roam; 0 = stays put',
  `placed_at` BIGINT(20) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_house` (`house_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
