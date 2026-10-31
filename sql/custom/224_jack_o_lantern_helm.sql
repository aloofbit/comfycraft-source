-- ============================================================================
--  Jack-o'-Lantern Helm  (tw_world)
-- ============================================================================
--  Applied with:
--
--    Get-Content sql\custom\224_jack_o_lantern_helm.sql | `
--      DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_world
--
--  then, in the mangosd console:  reload item_template
--
--  A cloth helm with no stats: the Hallow's End jack-o'-lantern (G_Pumpkin_01)
--  worn as a head. Display 46514 is Turtle's pumpkin helm; patch-V replaces its
--  models and icon (patches/build-patch-v.js, patches/lib/jack-helm.js). A
--  client without the new patch-V shows the item with no model. It hides
--  hair, beards and ears on every race. Any class and race can wear it. It is
--  not bound, so players can trade it.
--
--  Nothing sells or drops it yet. `.additem 100078` gives one.
-- ============================================================================

DELETE FROM item_template WHERE entry = 100078;

INSERT INTO item_template
  (entry, class, subclass, name, description, display_id, quality, flags,
   buy_count, buy_price, sell_price, inventory_type, allowable_class,
   allowable_race, item_level, required_level, stackable, max_count,
   armor, bonding, material, sheath, max_durability)
VALUES
  (100078, 4, 1, 'Jack-o''-Lantern Helm', 'Recommended remove candle before wearing', 46514, 1, 0,
   1, 500, 125, 1, -1,
   -1, 1, 0, 1, 0,
   2, 0, 7, 0, 20);
