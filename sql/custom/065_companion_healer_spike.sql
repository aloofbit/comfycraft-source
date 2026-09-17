-- ============================================================================
--  Companion spike: the healer  (tw_world)
-- ============================================================================
--  THROWAWAY. This is the spike from docs/ai/content/companions-route.md,
--  built to answer four questions before the feature is designed around them.
--  Entries 100029 and 100030 are for the spike; delete the file and the rows
--  once the answers are written down, and do not build anything on them.
--
--  The C++ half is source/src/scripts/miscellaneous/npc_companion_spike.cpp
--  and IS REQUIRED -- a healer with no spell list runner casts nothing. Apply
--  this file first: a creature_template row whose script_name names a script
--  the binary does not have is inert and harmless, whereas the reverse order
--  is fine too. Neither ordering can crash, unlike the housing column cases.
--
--  WHAT IT IS FOR:
--    100029  Sister Wren        a stationary recruiter. Gossip: hire, dismiss.
--    100030  Wren's Apprentice  the companion, summoned as a GUARDIAN_PET and
--                               matched to the hiring player's level.
--
--  NO SPAWN IS CREATED. Put Sister Wren wherever you want to test from:
--
--      .npc add 100029
--
--  and remove her with .npc delete while targeting her. Left to the tester on
--  purpose -- the spike should not plant anything permanent in the world.
--
--  HOW THE ROTATION WORKS, and why it is only a table. creature_spells is
--  eight slots per list, read in slot order, at most one cast per evaluation.
--  Slot order is therefore priority. `castTarget` 15 is TARGET_T_FRIENDLY_INJURED,
--  where targetParam1 is the search radius and targetParam2 is the PERCENTAGE
--  OF HEALTH MISSING before it will fire (ScriptMgr.cpp:3057). So the priest
--  heal tiers -- shield when it is bad, a heal in the middle, a HoT to top up
--  -- are three rows and three numbers.
--
--  THE UNITS TRAP, and it cost four builds to find. delayInitial* and
--  delayRepeat* are stored in this table in SECONDS. ObjectMgr.cpp:1818
--  multiplies every one of them by IN_MILLISECONDS on load:
--
--      // in the database we store timers as seconds
--      uint32 delayInitialMin = fields[...].GetUInt16() * IN_MILLISECONDS;
--
--  The first version of this file used milliseconds, so `delayRepeatMin = 4000`
--  became 4,000,000 ms -- a 66 minute cooldown. In game the companion simply
--  stood there: right target, full mana, nothing cast, no error anywhere. The
--  stock data was right all along; Amberpaw Shaman's delayRepeatMin_1 = 30 is
--  thirty SECONDS.
--
--  Second unit fact, this one in milliseconds: the list is evaluated every
--  CREATURE_CASTING_DELAY = 1200 ms (CreatureAI.h:146), so a repeat under about
--  2 seconds buys nothing.
--
--  AND targetParam2 = 0 DOES NOT MEAN ZERO. GetTargetByType reads it as
--  `param2 ? param2 : 50`, so leaving it at the column default silently gives
--  you "only heal at 50% missing". Every row below sets it explicitly.
--
--  Re-runnable: DELETE by entry, then INSERT.
-- ============================================================================

-- ---------------------------------------------------------------------------
--  1. The two creatures
-- ---------------------------------------------------------------------------
DELETE FROM `creature_template` WHERE `entry` IN (100029, 100030);

--  Sister Wren -- recruiter. npc_flags 1 (gossip) is what makes the client
--  send CMSG_GOSSIP_HELLO at all; without it the script never gets a turn.
INSERT INTO `creature_template`
    (`entry`, `name`, `subname`, `display_id1`, `faction`, `npc_flags`,
     `level_min`, `level_max`, `health_min`, `health_max`, `unit_class`,
     `type`, `movement_type`, `regeneration`, `script_name`)
VALUES
    (100029, 'Sister Wren', 'Helping Hand', 1295, 35, 1,
     40, 40, 3000, 3000, 1,
     7, 0, 3, 'npc_companion_recruiter');

--  Wren's Apprentice -- the companion itself.
--
--  health_max / mana_max / dmg_* are THE DIFFICULTY DIAL. A guardian takes
--  them flat from this row and does NOT scale them by level (Pet.cpp:1519-1536),
--  while its level comes separately from InitStatsForLevel. That is the whole
--  reason "same level, deliberately worse numbers" is the dial to use rather
--  than a level offset: it is these three columns, and `reload creature_template`
--  picks a change up without a restart.
--
--  unit_class 8 (mage) so she has a mana pool at all. faction 35 here is only
--  a placeholder -- the summon overwrites it with the owner's faction, which
--  is what puts the player inside her friendly search.
INSERT INTO `creature_template`
    (`entry`, `name`, `subname`, `display_id1`, `faction`, `npc_flags`,
     `level_min`, `level_max`, `health_min`, `health_max`,
     `mana_min`, `mana_max`, `armor`, `unit_class`,
     `dmg_min`, `dmg_max`, `base_attack_time`,
     `ranged_dmg_min`, `ranged_dmg_max`, `ranged_attack_time`, `equipment_id`,
     `type`, `movement_type`, `regeneration`, `spell_list_id`, `script_name`)
VALUES
    (100030, 'Wren''s Apprentice', 'Companion', 3344, 35, 0,
     12, 12, 600, 600,
     900, 900, 300, 8,
     5, 8, 2000,
     8, 12, 2000, 100030,
     7, 0, 3, 100030, 'npc_companion_healer');

--  NO flags_extra HERE ANY MORE, deliberately. An attempt on 2026-09-06 to stop
--  her pivoting between wand target and heal target added a
--  CREATURE_FLAG_EXTRA_LAZY_CAST_FACING bit and a matching skip in Spell::cast.
--  It made the turning WORSE, not better -- she began holding a stale facing and
--  visibly snapping back to it -- so both the flag and the core change were
--  reverted. See docs/ai/content/companions-route.md for what is known and
--  what is not; do not re-add either without re-reading that.

--  THE WAND. Shoot (5019) is a WEAPON attack, so its damage comes from the
--  creature's ranged_dmg_min/max above and NOT from any spell coefficient --
--  leave those at 0 and she shoots for nothing at all. They are the dial for
--  how much she chips in.
--
--  The wand itself is only the visual, and creatures skip every item
--  requirement: Spell::CheckItems returns SPELL_CAST_OK for any non-player
--  caster on its second line (Spell.cpp:7306), so she can shoot bare-handed.
--  Item 6230 is "Monster - Wand, Basic", which exists for exactly this. Slot 3
--  of the equip template is the ranged slot.
DELETE FROM `creature_equip_template` WHERE `entry` = 100030;
INSERT INTO `creature_equip_template` (`entry`, `equipentry1`, `equipentry2`, `equipentry3`)
VALUES (100030, 0, 0, 6230);

-- ---------------------------------------------------------------------------
--  2. The rotation
-- ---------------------------------------------------------------------------
--  Ranks are chosen low on purpose: the spike is about whether the machinery
--  works, not about balance. Lesser Heal r3 is spellLevel 10, Renew r1 is 8,
--  Power Word: Shield r1 is 6, so a level 12 companion can plausibly own all
--  three.
--
--  Slot 1  Power Word: Shield  below 50% health.  CF_AURA_NOT_PRESENT (32) so
--                              she does not try to re-shield through the
--                              Weakened Soul she just caused.
--  Slot 2  Lesser Heal (r3)    below 65% health. The workhorse.
--  Slot 3  Renew               below 85% health, and only if it is not already
--                              ticking -- again castFlags 32.
--
--  There is deliberately NO buff row. TARGET_T_FRIENDLY_MISSING_BUFF (17)
--  cannot see players: FindFriendlyUnitMissingBuff searches with
--  Cell::VisitGridObjects (Unit.cpp:10409), which is creatures and gameobjects
--  only -- players live in the world container, reached by VisitWorldObjects.
--  It also requires the target to be IsInCombat() already. Healing works
--  because FindLowestHpFriendlyUnit uses VisitAllObjects instead. Buffing the
--  player needs either castTarget 7 (TARGET_T_OWNER, no search at all) once
--  there is a real owner, or a one-word core fix.
--  Slots 4 and 5 are the FILLER, and they work because slot order is priority:
--  a damage slot is only reached when every heal above it either has no target
--  or is on cooldown. "Help a bit when nothing needs healing" is not a rule
--  anybody had to write - it falls out of the ordering.
--
--  castTarget 1 is TARGET_T_HOSTILE, which resolves off THIS creature's victim.
--  A pure healer has none, so the AI hands her the owner's target without
--  starting a melee swing (see HelpFight in npc_companion_spike.cpp). Without
--  that, both slots below silently find nothing.
--
--  Slot 4  Shoot (5019)   the wand. Auto-repeat (attributesEx2 0x20), 0 mana,
--                         damage from ranged_dmg_min/max on the template.
--  Slot 5  Smite r1 (585) a backstop, so if the auto-repeat wand misbehaves in
--                         a spell list the spike still shows SOMETHING firing
--                         and we know which of the two is at fault.
DELETE FROM `creature_spells` WHERE `entry` = 100030;

INSERT INTO `creature_spells`
    (`entry`, `name`,
     `spellId_1`, `probability_1`, `castTarget_1`, `targetParam1_1`, `targetParam2_1`, `castFlags_1`, `delayInitialMin_1`, `delayInitialMax_1`, `delayRepeatMin_1`, `delayRepeatMax_1`,
     `spellId_2`, `probability_2`, `castTarget_2`, `targetParam1_2`, `targetParam2_2`, `castFlags_2`, `delayInitialMin_2`, `delayInitialMax_2`, `delayRepeatMin_2`, `delayRepeatMax_2`,
     `spellId_3`, `probability_3`, `castTarget_3`, `targetParam1_3`, `targetParam2_3`, `castFlags_3`, `delayInitialMin_3`, `delayInitialMax_3`, `delayRepeatMin_3`, `delayRepeatMax_3`,
     `spellId_4`, `probability_4`, `castTarget_4`, `targetParam1_4`, `targetParam2_4`, `castFlags_4`, `delayInitialMin_4`, `delayInitialMax_4`, `delayRepeatMin_4`, `delayRepeatMax_4`,
     `spellId_5`, `probability_5`, `castTarget_5`, `targetParam1_5`, `targetParam2_5`, `castFlags_5`, `delayInitialMin_5`, `delayInitialMax_5`, `delayRepeatMin_5`, `delayRepeatMax_5`)
VALUES
    (100030, 'Companion Healer',
     17,   100, 15, 30, 50, 32, 0, 1, 15, 20,
     2053, 100, 15, 30, 35,  0, 0, 1,  4,  6,
     139,  100, 15, 30, 15, 32, 0, 1,  9, 12,
     5019, 100,  1,  0,  0,  0, 1, 2,  2,  3,
     585,  100,  1,  0,  0,  0, 2, 3,  4,  5);

-- ============================================================================
--  Applying it, with the server up:
--
--    Get-Content sql\custom\065_companion_healer_spike.sql | `
--      DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_world
--
--  then, in the mangosd console (no leading dot), IN THIS ORDER:
--
--    reload creature_template
--    reload creature_spells
--
--  creature_template first: reload validation resolves against the cached
--  templates, the same trap that emptied Keeper Faelyn's vendor.
--
--  The C++ half needs a build, so script_name only binds after
--  .\Build-Server.ps1 -Live.
-- ============================================================================
