-- ============================================================================
--  FURNISHER ADELA OPENS NAMED SHOPS; MISTER BONES SELLS HALLOW'S END  (tw_world)
-- ============================================================================
--  Applied with:
--
--    Get-Content sql\custom\219_adela_shops_and_hallows_end.sql | `
--      DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_world
--
--  then, in the mangosd console, in this order:
--
--    reload gameobject_template
--    reload item_template
--    house furniture reload
--    reload creature_template
--    reload npc_vendor
--    reload broadcast_text
--    reload npc_text
--    reload gossip_menu
--    reload gossip_menu_option
--
--  THEN RESTART, or target Adela and .die, then .respawn. A spawned creature copies gossip_menu_id
--  and npc_flags from its template when it spawns (Creature.cpp,
--  SetDefaultGossipMenuId), and reload creature_template does not touch the
--  creatures already in the world. Her script IS read live
--  (Creature::GetScriptId), so after the reload alone she has neither the
--  tabs nor the menu, and her dialog opens empty.
--
--  ADELA. One vendor window holds 128 items (MAX_VENDOR_ITEMS), and her tabs
--  only filtered one npc_vendor list, so every crate counted against her one
--  128. Now each tab is a named shop (npc_vendor_template, a `shop` row), and
--  Adela is a plain dialog, "Furnisher Adela", with one "Opens a shop" button
--  for each. Each shop holds 128. One page holds 32 buttons
--  (GOSSIP_MAX_MENU_ITEMS); a 33rd fails an assert, so past 32 shops add a
--  second page.
--
--  A shop is filled from house_furniture_item.category, which is what her
--  tabs were drawn from. The crates made on /admin/furniture are in that table
--  on every server, so this works on production with no import.
--
--  NUMBERS ARE TAKEN BY NAME, WHEN THIS RUNS. Shop ids, the dialog, its page
--  and its text are numbered by each server separately
--  (docs/features/content-transfer.md), so this file never writes one of
--  those numbers. It finds the thing by name, makes it with the editors' own
--  rule when it is missing (shop: max + 1 in 200000-200999; page: lowest free
--  in 64200-64997; text: max + 1 in 6410000-6419999) and leaves it alone when
--  it is there. A shop is stocked only on the run that makes it, so a re-run
--  does not put back what somebody took out in /admin/shops. Edit the shops
--  and the dialog in their editors after this.
--
--  HALLOW'S END. Fifteen crates at 50s (a vendor buys one back for 10s) in
--  the shop "Furniture: Hallow's End", sold by Mister Bones (100045). He is not spawned
--  here: `.npc add 100045`, and `.npc delete` when the holiday ends. The
--  crates place all year. Item numbers 100400-100414: the furniture page
--  continues after them.
--
--  The stock Apple Bob (300203) is a type 3 chest. A crate places only types
--  5 and 7, so 100098 is a type 5 copy of its model (6405).
--
--  Safe to run again. It needs 042 and 210 first.
-- ============================================================================


-- ---------------------------------------------------------------- the tub
DELETE FROM gameobject_template WHERE entry = 100098;
CREATE TEMPORARY TABLE comfy_go AS SELECT * FROM gameobject_template WHERE entry = 180412;
UPDATE comfy_go SET entry = 100098, displayId = 6405, name = 'Apple Bobbing Tub';
INSERT INTO gameobject_template SELECT * FROM comfy_go;
DROP TEMPORARY TABLE comfy_go;


-- ---------------------------------------------------------------- the crates
--  Copied from crate 100100 like every crate the page makes
--  (website/lib/furniture.js insert): the icon, the use spell and the script
--  come from that one row. INSERT IGNORE, so a name or price changed on the
--  page stays changed.
CREATE TEMPORARY TABLE comfy_hallow (
  item_entry mediumint unsigned NOT NULL PRIMARY KEY,
  go_entry   mediumint unsigned NOT NULL,
  crate_name varchar(48) NOT NULL
);
INSERT INTO comfy_hallow VALUES
  (100400, 180412, 'Candy Bucket'),
  (100401, 180405, 'Pumpkin'),
  (100402, 180406, 'Crooked Pumpkin'),
  (100403, 180407, 'Curly Pumpkin'),
  (100404, 100098, 'Apple Bobbing Tub'),
  (100405, 180410, 'Hanging Skeleton'),
  (100406, 180411, 'Hanging Ghost'),
  (100407, 180472, 'Skull Chandelier'),
  (100408, 180471, 'Skull Lantern'),
  (100409, 180427, 'Flying Bat'),
  (100410, 180426, 'Roosting Bat'),
  (100411, 180425, 'Skull Candle'),
  (100412, 180415, 'Black Candle'),
  (100413, 180434, 'Bonfire'),
  (100414, 186720, 'Wickerman');

CREATE TEMPORARY TABLE comfy_crate AS
  SELECT h.item_entry AS new_entry, h.crate_name AS new_name, g.displayId AS new_display, i.*
    FROM comfy_hallow h
    JOIN gameobject_template g ON g.entry = h.go_entry
    JOIN item_template i ON i.entry = 100100;
UPDATE comfy_crate SET entry = new_entry, name = new_name, buy_price = 5000, sell_price = 1000,
       description = CONCAT('Right-click to place this in your house. [m', new_display, ']');
ALTER TABLE comfy_crate DROP COLUMN new_entry, DROP COLUMN new_name, DROP COLUMN new_display;
INSERT IGNORE INTO item_template SELECT * FROM comfy_crate;
DROP TEMPORARY TABLE comfy_crate;

INSERT IGNORE INTO house_furniture_item (item_entry, go_entry, scale, category)
  SELECT item_entry, go_entry, 0, 'Hallow''s End' FROM comfy_hallow;
DROP TEMPORARY TABLE comfy_hallow;


-- ---------------------------------------------------------------- the shops
--  One block per shop: make it if the name is missing, then stock it from its
--  category on that run only. Slot = item entry - 100000 keeps the window in
--  the order the crates were made.
SET @name := 'Furniture: Seating', @cat := 'Seating';
SET @new := NOT EXISTS (SELECT 1 FROM shop WHERE name = @name);
INSERT INTO shop (id, name, shop_type, comment)
  SELECT m.id, @name, 0, 'Furnisher Adela. sql/custom/219' FROM
    (SELECT COALESCE(MAX(id), 199999) + 1 AS id FROM shop WHERE id BETWEEN 200000 AND 200999) m WHERE @new;
SET @id := (SELECT id FROM shop WHERE name = @name);
INSERT IGNORE INTO npc_vendor_template (entry, slot, item, maxcount, incrtime)
  SELECT @id, item_entry - 100000, item_entry, 0, 0 FROM house_furniture_item WHERE category = @cat AND @new;

SET @name := 'Furniture: Tables', @cat := 'Tables';
SET @new := NOT EXISTS (SELECT 1 FROM shop WHERE name = @name);
INSERT INTO shop (id, name, shop_type, comment)
  SELECT m.id, @name, 0, 'Furnisher Adela. sql/custom/219' FROM
    (SELECT COALESCE(MAX(id), 199999) + 1 AS id FROM shop WHERE id BETWEEN 200000 AND 200999) m WHERE @new;
SET @id := (SELECT id FROM shop WHERE name = @name);
INSERT IGNORE INTO npc_vendor_template (entry, slot, item, maxcount, incrtime)
  SELECT @id, item_entry - 100000, item_entry, 0, 0 FROM house_furniture_item WHERE category = @cat AND @new;

SET @name := 'Furniture: Storage', @cat := 'Storage';
SET @new := NOT EXISTS (SELECT 1 FROM shop WHERE name = @name);
INSERT INTO shop (id, name, shop_type, comment)
  SELECT m.id, @name, 0, 'Furnisher Adela. sql/custom/219' FROM
    (SELECT COALESCE(MAX(id), 199999) + 1 AS id FROM shop WHERE id BETWEEN 200000 AND 200999) m WHERE @new;
SET @id := (SELECT id FROM shop WHERE name = @name);
INSERT IGNORE INTO npc_vendor_template (entry, slot, item, maxcount, incrtime)
  SELECT @id, item_entry - 100000, item_entry, 0, 0 FROM house_furniture_item WHERE category = @cat AND @new;

SET @name := 'Furniture: Odds & Ends', @cat := 'Odds & Ends';
SET @new := NOT EXISTS (SELECT 1 FROM shop WHERE name = @name);
INSERT INTO shop (id, name, shop_type, comment)
  SELECT m.id, @name, 0, 'Furnisher Adela. sql/custom/219' FROM
    (SELECT COALESCE(MAX(id), 199999) + 1 AS id FROM shop WHERE id BETWEEN 200000 AND 200999) m WHERE @new;
SET @id := (SELECT id FROM shop WHERE name = @name);
INSERT IGNORE INTO npc_vendor_template (entry, slot, item, maxcount, incrtime)
  SELECT @id, item_entry - 100000, item_entry, 0, 0 FROM house_furniture_item WHERE category = @cat AND @new;

SET @name := 'Furniture: Mailboxes', @cat := 'Mailboxes';
SET @new := NOT EXISTS (SELECT 1 FROM shop WHERE name = @name);
INSERT INTO shop (id, name, shop_type, comment)
  SELECT m.id, @name, 0, 'Furnisher Adela. sql/custom/219' FROM
    (SELECT COALESCE(MAX(id), 199999) + 1 AS id FROM shop WHERE id BETWEEN 200000 AND 200999) m WHERE @new;
SET @id := (SELECT id FROM shop WHERE name = @name);
INSERT IGNORE INTO npc_vendor_template (entry, slot, item, maxcount, incrtime)
  SELECT @id, item_entry - 100000, item_entry, 0, 0 FROM house_furniture_item WHERE category = @cat AND @new;

SET @name := 'Furniture: Upgrades', @cat := 'Upgrades';
SET @new := NOT EXISTS (SELECT 1 FROM shop WHERE name = @name);
INSERT INTO shop (id, name, shop_type, comment)
  SELECT m.id, @name, 0, 'Furnisher Adela. sql/custom/219' FROM
    (SELECT COALESCE(MAX(id), 199999) + 1 AS id FROM shop WHERE id BETWEEN 200000 AND 200999) m WHERE @new;
SET @id := (SELECT id FROM shop WHERE name = @name);
INSERT IGNORE INTO npc_vendor_template (entry, slot, item, maxcount, incrtime)
  SELECT @id, item_entry - 100000, item_entry, 0, 0 FROM house_furniture_item WHERE category = @cat AND @new;

SET @name := 'Furniture: Hallow''s End', @cat := 'Hallow''s End';
SET @new := NOT EXISTS (SELECT 1 FROM shop WHERE name = @name);
INSERT INTO shop (id, name, shop_type, comment)
  SELECT m.id, @name, 0, 'Mister Bones. sql/custom/219' FROM
    (SELECT COALESCE(MAX(id), 199999) + 1 AS id FROM shop WHERE id BETWEEN 200000 AND 200999) m WHERE @new;
SET @id := (SELECT id FROM shop WHERE name = @name);
INSERT IGNORE INTO npc_vendor_template (entry, slot, item, maxcount, incrtime)
  SELECT @id, item_entry - 100000, item_entry, 0, 0 FROM house_furniture_item WHERE category = @cat AND @new;


-- ---------------------------------------------------------------- Mister Bones
--  A copy of Adela's row with every field that differs set here, so it does
--  not depend on what Adela looks like. Vendor only (4): a right-click opens
--  the shop window. Display 158 is the plain skeleton (creature 6412).
DELETE FROM creature_template WHERE entry = 100045;
CREATE TEMPORARY TABLE comfy_bones AS SELECT * FROM creature_template WHERE entry = 100028;
UPDATE comfy_bones SET entry = 100045, name = 'Mister Bones', subname = 'Hallow''s End Decor',
       display_id1 = 158, display_id2 = 0, display_id3 = 0, display_id4 = 0,
       npc_flags = 4, gossip_menu_id = 0, script_name = '',
       vendor_id = (SELECT id FROM shop WHERE name = 'Furniture: Hallow''s End');
INSERT INTO creature_template SELECT * FROM comfy_bones;
DROP TEMPORARY TABLE comfy_bones;


-- ---------------------------------------------------------------- Adela's dialog
--  One page, "Greeting", made the way lib/dialogs.js addPage and savePage
--  make one, and only when no dialog has the name.
SET @newd := NOT EXISTS (SELECT 1 FROM dialog WHERE name = 'Furnisher Adela');

INSERT INTO dialog (name, comment)
  SELECT 'Furnisher Adela', 'Opens her furniture shops. sql/custom/219' FROM DUAL WHERE @newd;
SET @did := (SELECT id FROM dialog WHERE name = 'Furnisher Adela');

SET @menu := (SELECT MIN(c.n) FROM (
    SELECT 64200 AS n
    UNION SELECT entry + 1 FROM gossip_menu WHERE entry BETWEEN 64200 AND 64996
    UNION SELECT menu_id + 1 FROM dialog_page WHERE menu_id BETWEEN 64200 AND 64996) c
  WHERE c.n NOT IN (SELECT entry FROM gossip_menu)
    AND c.n NOT IN (SELECT menu_id FROM dialog_page));
SET @text := (SELECT COALESCE(MAX(x.n), 6409999) + 1 FROM (
    SELECT entry AS n FROM broadcast_text WHERE entry BETWEEN 6410000 AND 6419999
    UNION SELECT ID FROM npc_text WHERE ID BETWEEN 6410000 AND 6419999
    UNION SELECT text_id FROM dialog_page WHERE text_id BETWEEN 6410000 AND 6419999) x);
SET @body := 'Every room needs something. What are you looking for?';

INSERT INTO broadcast_text (entry, male_text, female_text, chat_type)
  SELECT @text, @body, @body, 0 FROM DUAL WHERE @newd;
INSERT INTO npc_text (ID, BroadcastTextID0, Probability0)
  SELECT @text, @text, 1 FROM DUAL WHERE @newd;
INSERT INTO gossip_menu (entry, text_id, script_id)
  SELECT @menu, @text, 0 FROM DUAL WHERE @newd;
INSERT INTO dialog_page (menu_id, dialog_id, text_id, adopted, title, sort)
  SELECT @menu, @did, @text, 0, 'Greeting', 1 FROM DUAL WHERE @newd;
UPDATE dialog SET root_menu_id = @menu WHERE id = @did AND @newd;

--  option_id 3 (vendor), npc_option_npcflag 4, action_menu_id the shop id:
--  the editor's "Opens a shop" button. Icon 1 is the bag.
INSERT INTO gossip_menu_option
  (menu_id, id, option_icon, option_text, option_id, npc_option_npcflag,
   action_menu_id, action_script_id, action_poi_id, condition_id)
  SELECT @menu, o.id, 1, o.label, 3, 4, s.id, 0, 0, 0
    FROM (SELECT 0 AS id, 'Seating' AS label, 'Furniture: Seating' AS shop
          UNION ALL SELECT 1, 'Tables', 'Furniture: Tables'
          UNION ALL SELECT 2, 'Storage', 'Furniture: Storage'
          UNION ALL SELECT 3, 'Odds and ends', 'Furniture: Odds & Ends'
          UNION ALL SELECT 4, 'Mailboxes', 'Furniture: Mailboxes'
          UNION ALL SELECT 5, 'House upgrades', 'Furniture: Upgrades') o
    JOIN shop s ON s.name = o.shop
   WHERE @newd;


-- ---------------------------------------------------------------- Adela
--  Every run. Her own list goes: the shops hold the stock now, and a crate on
--  her own list would show on the furniture page as sold by her.
UPDATE creature_template
   SET script_name = '', npc_flags = 5, vendor_id = 0,
       gossip_menu_id = (SELECT root_menu_id FROM dialog WHERE name = 'Furnisher Adela')
 WHERE entry = 100028;
DELETE FROM npc_vendor WHERE entry = 100028;


-- ----------------------------------------------------------------------------
-- ROLLBACK: re-run 042 and 210 from before this change (git), which put
-- Adela's script and stock back, then:
--
-- DELETE FROM creature_template   WHERE entry = 100045;
-- DELETE FROM npc_vendor_template WHERE entry IN (SELECT id FROM shop WHERE comment LIKE '%sql/custom/219');
-- DELETE FROM shop                WHERE comment LIKE '%sql/custom/219';
-- Delete the dialog "Furnisher Adela" in /admin/dialogs.
-- The crates 100400-100414 stay: a crate already bought keeps its number.
-- ----------------------------------------------------------------------------
