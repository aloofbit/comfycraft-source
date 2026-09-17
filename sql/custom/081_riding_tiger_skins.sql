-- ============================================================================
--  The Gadgetzan tiger's four skins all rent the right colour  (tw_world)
-- ============================================================================
--  Reported: "there's a white tiger outside gadgetzan that turns into a black
--  tiger mount". True, and the last corner of the multi-display problem that
--  080's core change left open.
--
--  CREATURE 8882 "Riding Tiger" WEARS ONE OF FOUR SKINS, chosen at random by
--  Creature::ChooseDisplayId when it spawns and re-rolled on every restart. The
--  core resolves the mount spell from the display it is actually wearing, but
--  two of its four displays are not produced by ANY mount spell, so those two
--  fell back to the row's spell -- display 6448, RidingTigerSkinDark. A white
--  tiger handing you a black one.
--
--  THEY ARE NOT UNMATCHED, THEY ARE DUPLICATES. Every cat mount in the game is
--  the same model, RidingFrostSabre.mdx, with a different texture, and read out
--  of CreatureDisplayInfo.dbc the two orphans are exact copies of two displays
--  that do have spells:
--
--    6079  RidingTigerSkinNostripeWhite  ==  9695  -> spell 16056 Frostsaber
--    9952  RidingTigerSkinRed            ==  6443  -> spell 10790 Tiger
--
--  Same model id, same texture, same scale, same ExtendedDisplayInfoID --
--  checked, all four, not assumed. So pointing the NPC at the twins changes
--  NOTHING about how it looks and everything about what it can hand you. It
--  keeps all four of its appearances; each one now rents that appearance.
--
--  A happy side effect: spell 10790 is named, simply, "Tiger" -- the red cat,
--  and the closest thing in this client to an actual tiger short of the Zul'Gurub
--  one 080 added. It has never been reachable before.
--
--  WHY NOT FIX IT IN THE CORE. The obvious general fix is to key the display
--  index on (model, texture) so any duplicate resolves by itself. The core
--  cannot: CreatureDisplayInfoEntry stops before the texture columns --
--  "6-8 m_textureVariation[3]" is a comment, not a field, at
--  DBCStructure.h:190 -- so it would mean extending the struct and its format
--  string first. Swept all 94 renters before deciding that was not worth it:
--  8882 is the ONLY one with a display slot no mount spell can produce. 93 of
--  94 were already right. A data fix for a data problem of exactly one row.
--
--  THIS ONE NEEDS A RESTART, not a reload, and that is not the usual reason.
--  `reload creature_template` refreshes the cache, but a creature that is
--  already spawned keeps the display it rolled at spawn time -- so the tiger
--  standing in Gadgetzan right now goes on wearing 6079 until it is respawned.
--  Restart, then look at what it is wearing and rent it.
-- ============================================================================

UPDATE `creature_template`
   SET `display_id2` = 9695,   -- was 6079, same RidingTigerSkinNostripeWhite
       `display_id3` = 6443    -- was 9952, same RidingTigerSkinRed
 WHERE `entry` = 8882;

-- -- check -------------------------------------------------------------------
--  Expect 6448, 9695, 6443, 6080 -- four distinct skins, and every one of them
--  is a display some mount spell produces:
--    6448 -> 10793 Striped Nightsaber   (dark, and the row's own spell)
--    9695 -> 16056 Frostsaber           (white, no stripes)
--    6443 -> 10790 Tiger                (red)
--    6080 -> 8394  Striped Frostsaber   (white, striped)

SELECT `entry`, `name`, `display_id1`, `display_id2`, `display_id3`, `display_id4`
  FROM `creature_template`
 WHERE `entry` = 8882;
