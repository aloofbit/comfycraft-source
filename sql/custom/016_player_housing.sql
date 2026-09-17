-- ---------------------------------------------------------------------------
-- 016_player_housing.sql -- the housing tables. Runs against tw_char, NOT
-- tw_world: a house belongs to an account, not to static world content.
--
--   DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_char < sql\custom\016_player_housing.sql
--
-- Additive only. Creating these on a live server is safe; the core does not
-- read them until the housing module ships. (The reverse is not true -- a table
-- the binary references and cannot find is a hard crash here, not a warning.)
--
-- InnoDB, not MyISAM. Most of tw_char is MyISAM, which has no crash recovery
-- and is why shutdown order matters so much on this server. 41 tables in
-- tw_char are already InnoDB, so this is not a novel choice -- and player-built
-- content is exactly the kind of data that should survive a hard kill.
--
-- WHY `house` IS AUTHORITATIVE AND `instance_id` IS ONLY A CACHE.
-- Two things in the core will happily rewrite instance state underneath us:
--
--   * PackInstances() (World.cpp:2047) RENUMBERS every instance id on every
--     startup. It rewrites `instance` and `character_instance` together, so
--     binds survive -- but any id held outside those tables goes stale. Phase 1
--     turns this off; until then, treat house.instance_id as disposable.
--   * CleanupInstances() deletes `instance` rows that no character or group is
--     bound to. Delete the wrong character and the house's instance evaporates.
--
-- So furniture is keyed by house_id and NEVER by instance_id. If the instance
-- row is gone, a new one is created and the same furniture loads into it.
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `house` (
  `id`          INT UNSIGNED      NOT NULL AUTO_INCREMENT,
  `account`     INT UNSIGNED      NOT NULL                 COMMENT 'tw_logon.account.id -- houses are per account, so alts share one',
  `map`         SMALLINT UNSIGNED NOT NULL DEFAULT 817,
  `instance_id` INT UNSIGNED      NOT NULL DEFAULT 0       COMMENT 'cache only, revalidated on entry -- see header',
  `name`        VARCHAR(48)       NOT NULL DEFAULT '',
  `created_at`  BIGINT            NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_account_map` (`account`, `map`),
  KEY `idx_instance` (`instance_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- `id` IS the gameobject guid. Not a derived value, not id+offset -- one number,
-- so nothing can drift out of sync and `.gobject` commands take it directly.
--
-- The range is not arbitrary. GameObject low guids are 24 BITS in this core:
-- ObjectGuid::HasEntry(HIGHGUID_GAMEOBJECT) is true, so the counter is masked
-- to 0x00FFFFFF and the hard ceiling is 16,777,215. Of that:
--
--   1 .. 7,002,997        tw_world.gameobject, in use today
--   7,002,998 ..          .gobject add, from GuidReserveSize.GameObject
--   8,000,000 ..          THIS TABLE, 4M slots
--   12,002,998 ..         temporary summons, per map instance
--   .. 16,777,215         ceiling
--
-- That layout REQUIRES GuidReserveSize.GameObject = 5000000 in mangosd.conf
-- (it ships at 1000, which puts the temporary floor at 7,003,998 -- below us).
-- The setting is configNoReload, so it needs a restart, and it must land before
-- the first object is placed.
CREATE TABLE IF NOT EXISTS `house_object` (
  `id`        INT UNSIGNED NOT NULL AUTO_INCREMENT           COMMENT 'this is the gameobject guid',
  `house_id`  INT UNSIGNED NOT NULL,
  `go_entry`  INT UNSIGNED NOT NULL                          COMMENT 'gameobject_template.entry',
  `x`         FLOAT        NOT NULL,
  `y`         FLOAT        NOT NULL,
  `z`         FLOAT        NOT NULL,
  `o`         FLOAT        NOT NULL DEFAULT 0,
  `rot0`      FLOAT        NOT NULL DEFAULT 0,
  `rot1`      FLOAT        NOT NULL DEFAULT 0,
  `rot2`      FLOAT        NOT NULL DEFAULT 0,
  `rot3`      FLOAT        NOT NULL DEFAULT 0,
  `placed_at` BIGINT       NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_house` (`house_id`)
) ENGINE=InnoDB AUTO_INCREMENT=8000000 DEFAULT CHARSET=utf8;

-- Phase 2. A permanent bind beats a group bind and beats a solo bind, so
-- visiting cannot be built out of parties -- a visitor with their own house
-- would be routed straight back to it, and DungeonMap::BindPlayerOrGroupOnEnter
-- MANGOS_ASSERTs on the mismatch (Map.cpp:2144). It takes a core patch.
CREATE TABLE IF NOT EXISTS `house_guest` (
  `house_id`   INT UNSIGNED NOT NULL,
  `account`    INT UNSIGNED NOT NULL,
  `level`      TINYINT UNSIGNED NOT NULL DEFAULT 1  COMMENT '1 visit, 2 decorate',
  `granted_at` BIGINT NOT NULL DEFAULT 0,
  PRIMARY KEY (`house_id`, `account`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ---------------------------------------------------------------------------
-- ROLLBACK
--   DROP TABLE IF EXISTS `house_guest`, `house_object`, `house`;
-- ---------------------------------------------------------------------------
