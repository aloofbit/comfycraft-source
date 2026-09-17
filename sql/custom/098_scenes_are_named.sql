-- ============================================================================
--  Scenes become things in their own right                        (tw_world)
-- ============================================================================
--  Applied with:
--
--    Get-Content sql\custom\098_scenes_are_named.sql | `
--      DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_world
--
--  APPLY BEFORE THE WEBSITE THAT READS IT. The core does not read `name` at all
--  -- LuaScene::LoadAll selects id, source and error and nothing else -- so
--  mangosd is indifferent to when this lands, the same as `dialog`.
--
--  ------------------------------------------------------------------- WHY
--
--  `dialog_lua` was written on 2026-09-15 as something a BUTTON OWNS: a row was
--  allocated when an action was added, rewritten when it was edited, and
--  deleted when the button stopped using it. That is the right shape for a
--  spoken line, which is one sentence belonging to one place, and it turned out
--  to be the wrong shape for a scene.
--
--  A scene is a piece of writing. It is worth a name, it is worth finding
--  again, and it is worth putting on a second NPC without copying it. None of
--  that is possible when its identity is "whatever row that button happens to
--  point at" and its display name is "a script, 9 lines".
--
--  So a scene is now what a SHOP is: a named row on a page of its own, which a
--  dialog button REFERENCES. `/admin/scenes` is the editor, exactly as
--  `/admin/shops` is for a shop.
--
--  ------------------------------------------------------- WHAT THIS INVERTS
--
--  OWNERSHIP GOES THE OTHER WAY, and that is the whole change:
--
--      before   deleting a button deleted its scene
--      after    deleting a button stops REFERENCING a scene, and the scene
--               stays until somebody deletes it on its own page
--
--  Which means orphans are now possible, and that is fine as long as they are
--  VISIBLE: the scenes page counts how many buttons use each one, so a scene
--  nobody runs shows as used by none rather than quietly existing for ever.
--
--  It also means one scene can serve many buttons, which is most of the point,
--  and that editing a shared one changes every NPC using it. Identical to
--  editing a shop, and the reason both pages say who uses what.
--
--  ---------------------------------------------------------------- THE NAMES
--
--  Existing rows are seeded from their own first line, because a scene with no
--  name is unreachable on a page that lists scenes by name. They are not
--  guaranteed pretty and they are meant to be renamed.
--
--  `name` is UNIQUE. Two scenes called the same thing is exactly the confusion
--  this table is being given names to avoid.
--
--  Re-runnable: every statement checks first. MySQL has no ADD COLUMN IF NOT
--  EXISTS in every version we might meet, so the adds go through
--  information_schema and a prepared statement.
-- ============================================================================

-- --------------------------------------------------------------------- name
SET @has := (SELECT COUNT(*) FROM information_schema.COLUMNS
              WHERE TABLE_SCHEMA = DATABASE()
                AND TABLE_NAME = 'dialog_lua' AND COLUMN_NAME = 'name');
SET @ddl := IF(@has = 0,
  'ALTER TABLE `dialog_lua` ADD COLUMN `name` varchar(64) NOT NULL DEFAULT '''' AFTER `id`',
  'DO 0');
PREPARE s FROM @ddl; EXECUTE s; DEALLOCATE PREPARE s;

-- ------------------------------------------------------------------ comment
-- For the author. Nothing a player ever sees, the same as `dialog.comment`.
SET @has := (SELECT COUNT(*) FROM information_schema.COLUMNS
              WHERE TABLE_SCHEMA = DATABASE()
                AND TABLE_NAME = 'dialog_lua' AND COLUMN_NAME = 'comment');
SET @ddl := IF(@has = 0,
  'ALTER TABLE `dialog_lua` ADD COLUMN `comment` varchar(255) NOT NULL DEFAULT '''' AFTER `error`',
  'DO 0');
PREPARE s FROM @ddl; EXECUTE s; DEALLOCATE PREPARE s;

-- ------------------------------------------------- seed the names that are ''
--
-- The first line, trimmed, with the id appended so the UNIQUE key below cannot
-- fail on two scenes that happen to open the same way.
UPDATE `dialog_lua`
   SET `name` = CONCAT(
         LEFT(TRIM(SUBSTRING_INDEX(`source`, CHAR(10), 1)), 40),
         ' (', `id`, ')')
 WHERE `name` = '';

-- ------------------------------------------------------------- unique on name
SET @has := (SELECT COUNT(*) FROM information_schema.STATISTICS
              WHERE TABLE_SCHEMA = DATABASE()
                AND TABLE_NAME = 'dialog_lua' AND INDEX_NAME = 'name');
SET @ddl := IF(@has = 0,
  'ALTER TABLE `dialog_lua` ADD UNIQUE KEY `name` (`name`)',
  'DO 0');
PREPARE s FROM @ddl; EXECUTE s; DEALLOCATE PREPARE s;
