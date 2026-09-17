-- ============================================================================
--  house_furniture_item.category, and the furniture shop's greeting  (tw_world)
-- ============================================================================
--  The migration half of sql/custom/042. That file's CREATE TABLE now declares
--  the column, which covers a fresh install and does NOTHING for one that
--  already has the table -- CREATE TABLE IF NOT EXISTS does not add columns.
--
--  APPLY THIS BEFORE THE BINARY THAT READS IT. HouseMgr::LoadFurnitureItems
--  selects `category`, and in this core a query against a missing column is
--  not a warning: MySQLConnection::HandleMySQLError asserts, mangosd writes a
--  crash dump and dies. See "Known DB gaps in this install" in CLAUDE.md.
--
--  The single pass that satisfies both this and 042:
--    Get-Content sql\custom\062_furniture_category.sql | DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_world
--    Get-Content sql\custom\042_furniture_items.sql    | DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_world
--    .\Build-Server.ps1 -Live
--
--  A RESTART IS NEEDED WHATEVER ELSE HAPPENS, for two separate reasons, and
--  neither is the column:
--    * broadcast_text has no .reload, so the greeting below is invisible until
--      the server comes back;
--    * creature_template.script_name binds to a script id the binary registers
--      at startup, so the shop is a plain vendor until then.
--
--  What the column IS: the label on the tab a crate is bought from, which is
--  the same string the furniture shelf filters by. Blank means "no tab" -- the
--  item is still sold and still storable, it simply does not appear under a
--  category heading, which is what an unmigrated row degrades to.
--
--  The core groups by whatever string it finds and knows none of these names.
--  042 fills them from tools/categorise.js so the vendor tab, the shelf filter
--  and the addon catalogue's own bucket are one answer from one rule.
-- ============================================================================

-- Re-runnable: adding a column that exists is an error, so check first. MySQL
-- has no ADD COLUMN IF NOT EXISTS in this version, hence the prepared
-- statement rather than a bare ALTER.
SET @add := (SELECT COUNT(*) FROM information_schema.COLUMNS
             WHERE TABLE_SCHEMA = DATABASE()
               AND TABLE_NAME   = 'house_furniture_item'
               AND COLUMN_NAME  = 'category');

SET @sql := IF(@add = 0,
  'ALTER TABLE `house_furniture_item`
     ADD COLUMN `category` VARCHAR(24) NOT NULL DEFAULT ''''
     COMMENT ''vendor tab / shelf filter; blank = untabbed'' AFTER `scale`',
  'DO 0');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ---------------------------------------------------------------------------
--  The shop's greeting
-- ---------------------------------------------------------------------------
--  A code-built gossip menu still needs ONE database row: SendGossipMenu takes
--  an npc_text id rather than a string, and npc_text in this core carries no
--  inline text of its own -- it points at broadcast_text. So a page title is
--  two rows, and it is the only thing a menu built in C++ pays for. See the
--  housing gossip pages at 6400030-6400039 for the same pattern.
--
--  NOT RELOADABLE. `reload npc_text` exists; broadcast_text has none.
SET @TEXT := 6400040;

DELETE FROM npc_text       WHERE ID    = @TEXT;
DELETE FROM broadcast_text WHERE entry = @TEXT;

-- male_text and female_text are both filled, which is what every other housing
-- page does: the core picks by the SPEAKER's gender, and an empty female_text
-- would leave a female NPC -- which Adela is -- with a blank greeting.
INSERT INTO broadcast_text (entry, male_text, female_text, chat_type, language_id) VALUES
(@TEXT, 'What are you furnishing?', 'What are you furnishing?', 0, 0);

INSERT INTO npc_text (ID, BroadcastTextID0, Probability0) VALUES
(@TEXT, @TEXT, 1);
