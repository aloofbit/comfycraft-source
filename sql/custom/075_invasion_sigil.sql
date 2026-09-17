-- ============================================================================
--  The Invader's Sigil  (tw_world)
-- ============================================================================
--  One item, and it is the whole player-facing surface of invasions. Right-click
--  it and the server finds somebody flagged for PvP within Invasion.LevelRange
--  levels of you, tells THEM something is coming, and a few seconds later
--  teleports YOU in behind them. Nobody else is ever moved. The design, the
--  filters and the reasoning are docs/features/invasions.md; the code is
--  source/src/game/Invasion/InvasionMgr.cpp and
--  source/src/scripts/miscellaneous/item_invasion_sigil.cpp.
--
--  APPLY THIS AFTER THE BINARY THAT READS IT, not before. script_name is looked
--  up against the script registry at startup, so a row naming a script the
--  running binary has never heard of loads as an unbound item -- right-clicking
--  it would fall through to CastItemUseSpell and cast Divining Trance for real.
--  This is the opposite of the housing column rule (sql/custom/040), where the
--  SQL has to land first or a missing column crashes the server. The rule is not
--  "SQL first" or "binary first"; it is "whichever failure is the quiet one goes
--  second".
--
--  IT CARRIES A SPELL IT NEVER CASTS. The 1.12 client decides whether an item is
--  right-clickable from its own spell list, so an item with no ON_USE spell
--  never sends CMSG_USE_ITEM at all and the script would never run. 5017
--  "Divining Trance" is there to make the item usable and for no other reason --
--  the script returns true, which stops the route before CastItemUseSpell.
--  It was picked for three properties, all of which matter:
--
--    * description is EMPTY, so no green "Use:" line of borrowed flavour text
--      lands on the tooltip. The furniture crates carry 33453 and its
--      engineering-goggles description, and pay for it with an addon that
--      strips the line.
--    * targets = 0, so no ground reticle. The Decorator's Chalk picks a spell
--      that deliberately DOES raise one; this is the mirror of that choice.
--    * script_name is empty upstream, so binding the item here collides with
--      nothing.
--
--  bonding = 1, max_count = 1. Soulbound and one to a character: the sigil is a
--  thing you own rather than stock, and the cooldown that limits it lives on the
--  character in InvasionMgr rather than on the item, so a bagful would buy
--  nothing anyway.
--
--  quality 3 (rare) and display 22952, the Demonic Rune icon. It is not junk and
--  it should not read as junk in a bag.
--
--  NOTHING SELLS IT YET. That is deliberate and it is the open question the
--  feature ships with: a vendor, a quest reward, or a drop are three different
--  games. Until that is decided, `.additem 100035` in a GM session is how one
--  is obtained.
-- ============================================================================

DELETE FROM item_template WHERE entry = 100035;

INSERT INTO item_template
  (entry, class, subclass, name, description, display_id, quality, flags,
   buy_price, sell_price, inventory_type, allowable_class, allowable_race,
   item_level, required_level, stackable, max_count, bonding, material, sheath,
   spellid_1, spelltrigger_1, spellcharges_1, script_name)
VALUES
  (100035, 15, 0, 'Invader\'s Sigil',
   'Right-click to hunt down someone flagged for war. You go to them.',
   22952, 3, 0,
   0, 0, 0, -1, -1,
   1, 0, 1, 1, 1, 6, 0,
   5017, 0, 0, 'item_invasion_sigil');

-- `reload item_template` in the mangosd console picks this up without a
-- restart; the client needs a relaunch to see the new item, which the
-- realmlist launcher's WDB wipe covers.
