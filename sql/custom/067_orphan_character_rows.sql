-- ============================================================================
--  Sweep per-character rows whose character no longer exists  (tw_char)
-- ============================================================================
--    Get-Content sql\custom\067_orphan_character_rows.sql | `
--      DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_char
--
--  WHY. Character low guids are REUSED: delete a character and the next one
--  created can be handed the same number. Any table still holding rows for the
--  dead character then collides with the live one, and on this core a failing
--  query is not a warning -- MySQLConnection::HandleMySQLError asserts, mangosd
--  writes a crash dump and dies. That is what happened on 2026-09-06:
--
--      ERROR:SQL ERROR: Duplicate entry '4642-53' for key 'PRIMARY'
--      ERROR:[CRASH] signal-SIGABRT (code 0xc0000420)
--
--  guid 4642 had been a companion, was deleted, and the next companion was
--  handed 4642 again -- but character_transmogs still held the old one's rows,
--  because Player::DeleteFromDB never knew about Turtle's own per-character
--  tables. The binary fix is in that function; this file clears the debris
--  already in the database, including the historical orphans that predate the
--  companion work (1642 character_inventory, 3422 character_spell and 850
--  character_skills rows were counted on 2026-09-06 before any of this).
--
--  SAFE TO RE-RUN, and safe with the server up: every statement deletes only
--  rows with no matching `characters` row, so nothing a live character owns can
--  be touched. It is a plain sweep, not a migration.
--
--  Nine of these key PRIMARY on guid and were each a waiting abort. The rest
--  only leak, but leak into a table somebody will one day count.
-- ============================================================================

DELETE t FROM `character_transmogs`       t LEFT JOIN `characters` c ON c.`guid` = t.`guid` WHERE c.`guid` IS NULL;
DELETE t FROM `character_account_data`    t LEFT JOIN `characters` c ON c.`guid` = t.`guid` WHERE c.`guid` IS NULL;
DELETE t FROM `character_armory_stats`    t LEFT JOIN `characters` c ON c.`guid` = t.`guid` WHERE c.`guid` IS NULL;
DELETE t FROM `character_aura_suspended`  t LEFT JOIN `characters` c ON c.`guid` = t.`guid` WHERE c.`guid` IS NULL;
DELETE t FROM `character_pvp_currency`    t LEFT JOIN `characters` c ON c.`guid` = t.`guid` WHERE c.`guid` IS NULL;
DELETE t FROM `character_spell_dual_spec` t LEFT JOIN `characters` c ON c.`guid` = t.`guid` WHERE c.`guid` IS NULL;
DELETE t FROM `character_stats`           t LEFT JOIN `characters` c ON c.`guid` = t.`guid` WHERE c.`guid` IS NULL;
DELETE t FROM `character_titles`          t LEFT JOIN `characters` c ON c.`guid` = t.`guid` WHERE c.`guid` IS NULL;
DELETE t FROM `character_xp_from_log`     t LEFT JOIN `characters` c ON c.`guid` = t.`guid` WHERE c.`guid` IS NULL;
DELETE t FROM `character_honor_cp`        t LEFT JOIN `characters` c ON c.`guid` = t.`guid` WHERE c.`guid` IS NULL;
DELETE t FROM `character_inventory_copy`  t LEFT JOIN `characters` c ON c.`guid` = t.`guid` WHERE c.`guid` IS NULL;
DELETE t FROM `ai_playerbot_db_store`     t LEFT JOIN `characters` c ON c.`guid` = t.`guid` WHERE c.`guid` IS NULL;

--  These three are in Player::DeleteFromDB already, so their orphans came from
--  somewhere else -- a hand-deleted character, or the resurrect race fixed in
--  b26e654 earlier the same day. Swept for the same reason regardless.
DELETE t FROM `character_inventory`       t LEFT JOIN `characters` c ON c.`guid` = t.`guid` WHERE c.`guid` IS NULL;
DELETE t FROM `character_spell`           t LEFT JOIN `characters` c ON c.`guid` = t.`guid` WHERE c.`guid` IS NULL;
DELETE t FROM `character_skills`          t LEFT JOIN `characters` c ON c.`guid` = t.`guid` WHERE c.`guid` IS NULL;
DELETE t FROM `character_queststatus`     t LEFT JOIN `characters` c ON c.`guid` = t.`guid` WHERE c.`guid` IS NULL;
DELETE t FROM `character_reputation`      t LEFT JOIN `characters` c ON c.`guid` = t.`guid` WHERE c.`guid` IS NULL;
DELETE t FROM `character_action`          t LEFT JOIN `characters` c ON c.`guid` = t.`guid` WHERE c.`guid` IS NULL;
DELETE t FROM `character_aura`            t LEFT JOIN `characters` c ON c.`guid` = t.`guid` WHERE c.`guid` IS NULL;
DELETE t FROM `character_homebind`        t LEFT JOIN `characters` c ON c.`guid` = t.`guid` WHERE c.`guid` IS NULL;
DELETE t FROM `character_spell_cooldown`  t LEFT JOIN `characters` c ON c.`guid` = t.`guid` WHERE c.`guid` IS NULL;

-- ---------------------------------------------------------------------------
--  Pet tables, added 2026-09-06 after the SECOND crash of the day.
--
--  PET GUIDS ARE REUSED TOO, and all three of these key PRIMARY on the pet's
--  guid, so the character-table sweep above fixed only one level of the same
--  fault. A companion hunter or warlock gets a pet; dismissing the companion
--  deleted character_pet but left these, and the next pet handed that id died
--  on:
--
--      ERROR:SQL ERROR: Duplicate entry '174-46023' for key 'PRIMARY'
--
--  6089 orphan pet_spell rows were counted when this was written.
-- ---------------------------------------------------------------------------
--  OWNERLESS PETS GO FIRST. Sweeping the satellites before this would leave
--  behind exactly the rows this statement is about to orphan, which is the
--  ordering mistake that makes a cleanup script need running twice.
DELETE t FROM `character_pet` t LEFT JOIN `characters` c ON c.`guid` = t.`owner` WHERE c.`guid` IS NULL;

DELETE t FROM `pet_spell`          t LEFT JOIN `character_pet` p ON p.`id` = t.`guid` WHERE p.`id` IS NULL;
DELETE t FROM `pet_aura`           t LEFT JOIN `character_pet` p ON p.`id` = t.`guid` WHERE p.`id` IS NULL;
DELETE t FROM `pet_spell_cooldown` t LEFT JOIN `character_pet` p ON p.`id` = t.`guid` WHERE p.`id` IS NULL;
