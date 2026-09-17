-- ============================================================================
--  Chalk-only AIMING. The crates stop aiming; they keep their cast.
--  tw_world  (+ one tw_char statement at the end, run separately)
-- ============================================================================
--  TWO THINGS A CRATE USED TO DO, AND ONLY ONE OF THEM GOES. They were briefly
--  treated as one decision and both were removed, which was wrong -- so they
--  are written out separately here.
--
--    THE RETICLE GOES (045/046). A crate carried 261 so the client raised its
--    ground circle and sent back the clicked point. The Decorator's Chalk (054)
--    does that for every route into housing now -- commands, the addon, and
--    crates alike -- and a per-item spell never could: it could only ever aim
--    the twelve items that carried it, never `.house object add` and its 10,289
--    catalogue models. Two aiming mechanisms is one too many, and the per-item
--    one was always the weaker half.
--
--    THE CAST BAR STAYS (052). Making furniture should FEEL like making
--    something: a one-second bar and the crafting animation. That is the point
--    of it. It was briefly justified as filling the empty moment when there was
--    nothing to aim -- which made it look like a consolation prize that the
--    chalk had made redundant. It is not. Aiming happens earlier, with the
--    chalk; this is the moment the thing gets built.
--
--  So a crate carries 33453 both before and after this file. What actually
--  changes in the world DB is nothing about the crates at all -- this file
--  exists to make the state explicit and re-assertable, because the setting
--  that used to rewrite this column at every startup is gone from the binary.
--
--  Measured against server/dbc/Spell.dbc and SpellCastTimes.dbc, 2026-09-03:
--
--      spell    Targets  Visual  Cast    Effect0     used by
--      -----    -------  ------  ------  ----------  -------------------------
--      33453    0x0      215     1000ms  3 DUMMY     the crates -- this file
--      13487    0x40     0       0ms     76 SUMMON   the chalk -- 054
--      261      0x40     3       0ms     42 SUMMON   nothing. Was the chalk's,
--                                                    and its visual is why not
--      482      0x0      0       0ms     3 DUMMY     nothing. No bar, no
--                                                    animation -- the shape a
--                                                    silent crate would take
--
--  NEITHER AIMING SPELL IS INERT, AND NONE IS AVAILABLE. 13487 and 261 both
--  summon something if they ever actually cast, and 0x40 is the only way to
--  raise a reticle -- there is no spell in this client with both the mask and a
--  harmless effect, scanned for strictly and then loosely (the one loose hit
--  was an AoE fear trigger). The pItemUse veto is the protection, which makes
--  the ordering rule below load-bearing rather than tidy.
--
--  ORDER: THE BINARY MUST LEAD THIS FILE, the opposite of housing's usual rule.
--  Normally SQL goes first because a missing column is a hard crash. Here, SQL
--  that names a script the running binary does not have leaves the veto absent
--  and the spell casts for real -- which on 2026-09-03 summoned a skeleton in
--  somebody's house. Swap the binary, then apply this.
--
--  Re-runnable. `reload item_template` picks up the item change; the script
--  binding is read once at startup, so a NEW binding needs a restart.
--
--  Apply with:
--    Get-Content sql\custom\055_chalk_only_placing.sql | DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_world
-- ============================================================================

SET @CAST := 33453;  -- "Over-Tinkered Lens": Targets 0x0 (no reticle),
                     -- SpellVisual 215 (the crafting animation),
                     -- CastingTimeIndex 4 = 1000ms, Effect0 3 (DUMMY).

-- Every furniture crate, found through the mapping table rather than by an
-- entry range, so furniture added later is covered without editing this file.
UPDATE `item_template`
   SET `spellid_1` = @CAST
 WHERE `entry` IN (SELECT `item_entry` FROM `house_furniture_item`);

-- The cast route's other half: the script that puts the furniture down when the
-- bar finishes. It MUST be bound, or a crate casts a one-second spell and
-- nothing appears.
UPDATE `spell_template`
   SET `script_name` = 'spell_house_furniture_place'
 WHERE `entry` = @CAST;

-- ---------------------------------------------------------------------------
--  Check
-- ---------------------------------------------------------------------------
--  Every crate on the cast spell, and that spell bound to the placing script.
SELECT COUNT(*)                                             AS crates,
       SUM(it.spellid_1 = @CAST)                            AS on_cast_spell_must_match,
       (SELECT COUNT(*) FROM spell_template
         WHERE entry = @CAST
           AND script_name = 'spell_house_furniture_place')  AS bound_must_be_1
  FROM house_furniture_item f
  JOIN item_template it ON it.entry = f.item_entry;

--  Startup must then log, with BOTH zeros:
--    Loaded 953 spell script names (0 for unknown spells, 0 with no compiled script)

-- ----------------------------------------------------------------------------
--  tw_char -- RUN THIS ONE SEPARATELY, it is a different database:
--
--    DELETE FROM house_setting WHERE setting = 0;
--
--  Setting 0 was `point_and_click_placing`, which chose between the reticle and
--  the cast. Neither is a choice any more -- the chalk aims, the crate casts --
--  so the setting is gone from the binary. It ignores ids it does not know, so
--  leaving the rows is harmless; this is housekeeping.
--
--  *** DO NOT RENUMBER THE REMAINING SETTINGS TO CLOSE THE GAP. ***
--  house_setting rows are keyed by that id. Moving `glow` from 1 down to 0
--  would not remove a setting, it would REINTERPRET every saved row as the
--  setting that took the vacated slot. On this server before the removal, one
--  account held both placing=0 and glow=0 -- so the shuffle would have read a
--  dead placing row as a glow preference and dropped the real one. Slot 0 is
--  retired in the enum for exactly this reason.
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
-- ROLLBACK -- a silent, instant crate with no bar and no animation:
--
--   UPDATE item_template SET spellid_1 = 482
--    WHERE entry IN (SELECT item_entry FROM house_furniture_item);
--   UPDATE spell_template SET script_name = ''
--    WHERE entry = 33453;
--
-- That needs the binary changed too: pItemUse must return TRUE to veto the cast
-- rather than false to allow it. SQL alone would leave crates casting an inert
-- spell with nothing bound to place anything.
-- ----------------------------------------------------------------------------
