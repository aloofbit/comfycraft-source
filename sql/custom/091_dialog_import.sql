-- ============================================================================
--  Dialogs learn to adopt a menu somebody wrote by hand  (tw_world)
-- ============================================================================
--  Applied with:
--
--    Get-Content sql\custom\091_dialog_import.sql | `
--      DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_world
--
--  APPLY BEFORE THE WEBSITE THAT READS IT, as with 090. The core reads neither
--  of these tables and is indifferent.
--
--  WHY. sql/custom/090 DERIVED a page's npc_text.ID and broadcast_text.entry
--  from its menu id -- 6410000 + (menu_id - 64200) -- and that is still how new
--  pages are numbered, because it makes delete-and-recreate idempotent and lets
--  any of a page's three ids be worked out from the others.
--
--  What it cannot do is describe a page the editor did not create. Menu 64100 is
--  sql/custom/084's hand-written demo and its text lives at 6400050, which is
--  nowhere near the formula; running the formula on it yields 6410000 + (64100 -
--  64200) = 6409900, a row that does not exist. Adopting that menu into the
--  editor without this column would have pointed it at empty text and, on the
--  first save, WRITTEN THE PARAGRAPH TO THE WRONG ROW -- losing the original and
--  leaving the menu silently blank.
--
--  So the text id is now RECORDED rather than recomputed. For a page the editor
--  creates it is still the derived value, so nothing about 090's scheme changes
--  in practice; for an adopted page it is whatever that page already used.
--
--  Existing rows are backfilled with the formula below, which is correct for
--  every page that exists today: all of them were made by the editor.
--
--  THE SECOND COLUMN, `adopted`, IS A SAFETY INTERLOCK AND IT IS NOT OPTIONAL.
--  Removing a dialog deletes its pages -- gossip_menu, gossip_menu_option,
--  npc_text and broadcast_text -- which is right for pages the editor created
--  and catastrophic for pages it merely adopted. On 2026-09-14, during this very
--  change, adopting Magister Elandra's enchanting menu as a test and then
--  "rolling it back" deleted eighteen menus and a hundred and seventy-four
--  options of live content. sql/custom/003 put it back, because it was written
--  re-runnable; nothing about the editor made that recoverable.
--
--  So: adopted = 0 means the editor allocated these rows and may delete them.
--  adopted = 1 means it found them, and removing the dialog only forgets it.
--
--  Inferring this from the menu id block (64200-64997 is the editor's) was the
--  obvious alternative and was rejected: it is correct only for as long as
--  nobody hand-writes a menu inside that block, and the failure mode if anybody
--  ever does is silent deletion of their work.
--
--  Re-runnable: both ADD COLUMNs are guarded, the UPDATE only touches zeroes.
-- ============================================================================

-- MariaDB has no ADD COLUMN IF NOT EXISTS on every version this might meet, so
-- the guard is the information_schema shape sql/custom/086 settled on.
SET @have := (SELECT COUNT(*) FROM information_schema.columns
               WHERE table_schema = DATABASE()
                 AND table_name   = 'dialog_page'
                 AND column_name  = 'text_id');

SET @ddl := IF(@have = 0,
  'ALTER TABLE `dialog_page` ADD COLUMN `text_id` mediumint(8) unsigned NOT NULL DEFAULT 0 AFTER `dialog_id`',
  'DO 0');
PREPARE s FROM @ddl; EXECUTE s; DEALLOCATE PREPARE s;

SET @have := (SELECT COUNT(*) FROM information_schema.columns
               WHERE table_schema = DATABASE()
                 AND table_name   = 'dialog_page'
                 AND column_name  = 'adopted');

SET @ddl := IF(@have = 0,
  'ALTER TABLE `dialog_page` ADD COLUMN `adopted` tinyint(1) unsigned NOT NULL DEFAULT 0 AFTER `text_id`',
  'DO 0');
PREPARE s FROM @ddl; EXECUTE s; DEALLOCATE PREPARE s;

-- Backfill. 6410000 + (menu_id - 64200) is sql/custom/090's formula; every page
-- in the table right now was created by the editor, so it is right for all of
-- them. A zero left here after this would be a page with no text at all.
UPDATE `dialog_page`
   SET `text_id` = 6410000 + (`menu_id` - 64200)
 WHERE `text_id` = 0
   AND `menu_id` BETWEEN 64200 AND 64997;

-- Anything already recorded that sits OUTSIDE the editor's own block was adopted
-- by definition: the editor has never allocated a page anywhere else.
UPDATE `dialog_page` SET `adopted` = 1 WHERE `menu_id` NOT BETWEEN 64200 AND 64997;
