-- ============================================================================
--  Decorator's Chalk -- mark a spot, and the next thing you place lands on it
--  tw_world
-- ============================================================================
--  THE PROBLEM IT SOLVES. Twelve furniture crates can aim, because each one
--  carries a spell with TARGET_FLAG_DEST_LOCATION and the client raises its
--  ground reticle off that. The ComfyHousing catalogue browses 10,289 models,
--  and every one of them is placed by `.house object add <entry>`, which has
--  never been able to aim at anything: it puts the object two yards ahead of
--  you and always has. So the catalogue -- the part of housing with real
--  choice in it -- is the part with no aim.
--
--  A COMMAND CAN NEVER RAISE A RETICLE, AND THAT IS SETTLED. Ground targeting
--  is raised entirely client-side. Every spell-related SMSG in
--  Protocol/Opcodes_1_12_1.h *reports* a cast that is already happening, and
--  there is no opcode that induces the client to begin one. Using an item is
--  one of the two things that can (the other is casting a spell you know), so
--  an item is the only route to a reticle.
--
--  AN ITEM THAT PLACES NOTHING MUST THEREFORE STORE A POINT. That is what this
--  is: right-click it, click the ground, and the point is remembered with a
--  glow standing on it. The next object you place -- from a command, from the
--  addon, or out of a crate that did not aim itself -- lands there, and the
--  mark is spent. The two-step is not a design preference with a tidier
--  alternative next to it; there is no one-step version available.
--
--  ENTRY 100200, NOT 100112. The obvious next entry after the crates is inside
--  042's own blast radius:
--
--      DELETE FROM item_template WHERE entry BETWEEN 100100 AND 100199;
--
--  so a chalk at 100112 would be deleted by any re-run of the furniture file,
--  silently and much later. 100100-100199 belongs to furniture; 100200-100299
--  is housing TOOLS, and this is the first of them.
--
--  *** IT MUST NEVER BE A ROW IN house_furniture_item. ***
--  HouseMgr::ApplyPlacingSpell loops that table and rewrites spellid_1 on
--  every entry in it, so a chalk listed there would have its reticle spell
--  swapped for the cast-bar one the moment point-and-click placing was turned
--  off -- and the chalk with no reticle does nothing at all. It is a tool, not
--  furniture, and the two tables are what keep that true.
--
--  Re-runnable. Needs no restart: `reload item_template` picks it up, and
--  `reload npc_vendor` after it (that order -- see CLAUDE.md).
--
--  A CLIENT THAT HAS ALREADY SEEN THE CHALK NEEDS RESTARTING -- but not by
--  hand. The 1.12 client holds an item prototype for the life of the process
--  and writes it to WDB\itemcache.wdb, so `reload item_template` updates the
--  server only and a relog to character select changes nothing.
--
--  THE LAUNCHER ALREADY DOES THE CLEARING. wow-clients/<client>/realmlist
--  (Launcher.cs, ClearWdbCache) deletes every *.wdb before starting the game,
--  which is both halves of the fix in the right order. So the instruction here
--  is just "restart the client", and the manual quit-delete-start dance in
--  CLAUDE.md is for a client started some other way.
--
--  RELOAD THE SERVER FIRST, THOUGH. The launcher only clears the CLIENT's copy;
--  if the server is still holding the old prototype, a freshly-cleared client
--  simply re-caches the stale value and nothing has changed.
--
--  Apply with:
--    Get-Content sql\custom\054_decorator_chalk.sql | DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_world
--
--  APPLY AFTER 042. 042 does `DELETE FROM npc_vendor WHERE entry = @VENDOR`,
--  which takes the chalk off Bram's shelf along with everything else. Running
--  042 again means running this again.
-- ============================================================================

SET @CHALK  := 100200;
SET @VENDOR := 100026;   -- Carpenter Bram, from 042
-- ItemDisplayInfo 38656 -> INV_Ingot_Adamantite: a pale bar, which is the
-- closest thing this client has to a stick of chalk. There is no icon actually
-- called chalk -- checked against all 4,497 the client ships, which is what the
-- site's /icons page exists to make answerable.
--
-- THE COLUMN IS A DISPLAY ID, NOT AN ICON NAME. item_template.display_id points
-- at ItemDisplayInfo.dbc, whose field 5 is the icon leaf; the client does that
-- lookup in its own copy, so nothing in tw_world needs to know the name. Two
-- display ids carry this icon (38656 and 39486) and no shipped item uses
-- either, which is why neither shows up by searching item names.
--
-- It was 946 (INV_Misc_Rune_01) until 2026-09-03.
SET @ICON   := 38656;

-- THE SPELL IS 13487 "Create Relic Coffer Chest", settled 2026-09-03 by probe
-- (sql/custom/056, deleted after use) against the WHOLE candidate space rather
-- than by reading. Of 27,916 spells, exactly ELEVEN raise the ground reticle
-- while also being instant, class-safe and text-free; only TWO of those eleven
-- have SpellVisual 0, and this is the usable one.
--
--     Targets 0x40        TARGET_FLAG_DEST_LOCATION -- the whole reason the
--                         reticle appears. Nothing else is consulted for that.
--     tgtA 0              Target Dummy's implicit target, proven point-blank.
--                         52 draws the red refusal cursor near the player.
--     SpellVisual 0       SILENT. This is the field that settled it, and the
--                         one the previous pick got wrong.
--     CastingTimeIndex 1  = 0 ms, read out of SpellCastTimes.dbc rather than
--                         assumed, so "instant" is a measurement.
--     range 0-5           minimum 0, so it is green at your feet. See below.
--     Stances 0           not a class ability. 30012 was, and using it
--     powerType 0         switched a warrior into Battle Stance.
--     SpellFamilyName 0
--     Reagent 0           nothing to carry
--     Description ''      BOTH blank, or the green "Use:" line advertises
--     ToolTip     ''      somebody else's item. Description (dbc field 138) is
--                         the one that shows; ToolTip (147) is blank on most
--                         things and proves nothing on its own.
--
--  THE 5 YARDS IS A REAL LIMIT AND IT IS ON THE SAFE SIDE. You chalk within
--  about five yards of where you stand, so decorating across a room means
--  walking. What it buys is that the CLIENT refuses first: housing's own clamp
--  is 40 yards (HOUSE_PLACE_DISTANCE_MAX), so a 5-yard spell can never aim
--  somewhere the server would then reject. The other silent candidate, 52878,
--  reaches 100 yards with a 13-yard circle and would have done exactly that.
--
--  ACCEPTED IN PLAY, 2026-09-03 -- not an open trade. Reach and silence cannot
--  both be had: 261 reaches 20 and animates, 52878 reaches 100 and overshoots
--  the clamp, and those are the only three spells in the client that qualify at
--  all. Do not go looking for a fourth; the scan that found these is described
--  above and the space is exhausted.
--
--  WHAT IT WAS BEFORE, AND WHY IT CHANGED. 261 "Summon Skeleton" carried the
--  right mask and the right target and passed every check the earlier work knew
--  to make -- but its SpellVisual 3 plays a cast animation and turns the
--  player's hands green. CLAUDE.md asserted that visual "triggers no
--  animation"; that was wrong, and only using the item showed it.
--
--  A SECOND, QUIETER REASON TO BE GLAD OF THE SWAP. 261's Effect0 is 42,
--  SPELL_EFFECT_SUMMON_GUARDIAN -- it really does summon a skeleton if it ever
--  casts, which it did on 2026-09-03 when this SQL reached a binary that had no
--  `item_house_chalk` script to veto it. 13487's Effect0 is 76,
--  SPELL_EFFECT_SUMMON_OBJECT_WILD, which is no better in principle; NEITHER is
--  inert, because no spell in this client has both the reticle mask and a
--  harmless effect -- that was scanned for too. The veto is the protection, and
--  the ordering rule below is what keeps the veto present.
--
--  Present in server/dbc/Spell.dbc as well as the client's -- a spell id
--  existing in one proves nothing about the other.
--
--  DO NOT PICK A REPLACEMENT BY READING Spell.dbc. That has now failed three
--  times: 30012 was a warrior ability, 27651 refused near-field points, 261 was
--  not silent. Build the probe -- a new item entry is not in the client's WDB
--  cache, so candidates compare in one sitting. The method and the full history
--  are in docs/notes/point-and-click-placing.md.
SET @USE    := 13487;
SET @SCRIPT := 'item_house_chalk';

DELETE FROM item_template WHERE entry BETWEEN 100200 AND 100299;
-- Scoped to the tool block so Bram's twelve crates from 042 are left alone.
DELETE FROM npc_vendor    WHERE entry = @VENDOR AND item BETWEEN 100200 AND 100299;

-- ---------------------------------------------------------------------------
--  The chalk
-- ---------------------------------------------------------------------------
--  class 0 subclass 0, exactly like the crates. That is Consumable in the 1.12
--  enum and this is not consumable, which looks like the wrong choice and is
--  the right one: the crates are the only items in this DB proven to reach
--  pItemUse with a destination attached, and matching a working item beats
--  tidying towards a category. What makes "Use" appear is spellid_1 with
--  spelltrigger_1 = 0, not the class.
--
--  spellcharges_1 = 0 -- no charges, so nothing is ever expended. The script
--  never destroys it either: this is the one housing item you keep.
--
--  max_count = 1, so a bag cannot fill with chalk. You only ever need one.
--  bonding = 1 (soulbound) -- it is a tool, not trade goods, and a chalk on
--  the auction house would be somebody paying gold for a free thing.
--
--  buy_price 100 = one silver. A vendor CANNOT sell an item priced 0 in this
--  core, so free is not available; one silver is the nearest honest thing.
INSERT INTO item_template
  (entry, class, subclass, name, description, display_id, quality, flags,
   buy_price, sell_price, inventory_type, allowable_class, allowable_race,
   item_level, required_level, stackable, max_count, bonding, material, sheath,
   spellid_1, spelltrigger_1, spellcharges_1, script_name)
VALUES
  (@CHALK, 0, 0, 'Decorator''s Chalk',
   'Right-click to mark a spot in your house. The next thing you place lands on it.',
   @ICON, 1, 0,
   100, 0, 0, -1, -1, 1, 0, 1, 1, 1, 1, 0,
   @USE, 0, 0, @SCRIPT);

-- Slot 20 leaves 13-19 free for more furniture before the tools start.
INSERT INTO npc_vendor (entry, slot, item, maxcount, incrtime) VALUES
  (@VENDOR, 20, @CHALK, 0, 0);   -- Decorator's Chalk   1s

-- ---------------------------------------------------------------------------
--  Check
-- ---------------------------------------------------------------------------
--  The chalk must be sellable, scripted, carry 261, and NOT be furniture.
SELECT it.entry, it.name, it.spellid_1, it.script_name, it.buy_price,
       (SELECT COUNT(*) FROM npc_vendor v WHERE v.item = it.entry)          AS on_a_shelf,
       (SELECT COUNT(*) FROM house_furniture_item f WHERE f.item_entry = it.entry)
                                                                            AS is_furniture_must_be_0
  FROM item_template it
 WHERE it.entry = @CHALK;

-- ----------------------------------------------------------------------------
-- ROLLBACK
--
--   DELETE FROM item_template WHERE entry BETWEEN 100200 AND 100299;
--   DELETE FROM npc_vendor    WHERE entry = 100026 AND item BETWEEN 100200 AND 100299;
--
-- Anyone holding one keeps a dead item until they destroy it: the row is gone
-- but the client's WDB cache is not. Harmless -- right-clicking it reaches no
-- script and does nothing.
-- ----------------------------------------------------------------------------
