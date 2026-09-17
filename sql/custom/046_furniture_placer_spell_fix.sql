-- ---------------------------------------------------------------------------
--  046 -- the placer spell, settled: 261
--  tw_world
-- ---------------------------------------------------------------------------
--
--  045 gave the furniture crates the client's ground reticle by putting a spell
--  with TARGET_FLAG_DEST_LOCATION on them. The MECHANISM was right first time.
--  The SPELL took three attempts, and the two failures are the useful part of
--  this file, because both were chosen by reading Spell.dbc and reasoning about
--  which fields the client checks -- and both times the reasoning was the thing
--  that failed.
--
--  ATTEMPT 1: 30012 "Chess Move (DND)"
--
--      Right mask, 25 yards, a 5-yard circle identical to dynamite's, blank
--      description, no cost, Attributes 0x0. Using a crate SWITCHED A WARRIOR
--      INTO BATTLE STANCE and drew the red refusal cursor.
--
--          Stances         = 65536 = 1 << (FORM_BATTLESTANCE - 1)
--          powerType       = 1     = POWER_RAGE
--          SpellFamilyName = 4     = warrior
--
--      It is a warrior ability. The filter had checked description, reagents,
--      cost, cooldown and Attributes, and never looked at these three.
--
--  ATTEMPT 2: 27651 "Picnic Blanket Ritual Effect"
--
--      Chosen by profiling against Rough Dynamite instead -- Stances 0,
--      StancesNot 0, powerType 0, manaCost 0, SpellFamilyName 0 -- which is the
--      right method and got the class problem gone for good. But it drew the
--      red cursor when aimed NEAR the player and went green further out. Real
--      Rough Dynamite in the same spot in the same house was green at every
--      distance, so it was the spell and not the geometry.
--
--  WHAT ACTUALLY DECIDES IT, and it refines what 045 says rather than
--  contradicting it:
--
--      Targets & 0x40          decides whether the reticle APPEARS.
--                              This is the whole rule for that, and implicit
--                              targets are irrelevant to it -- Target Dummy
--                              (4071) has EffectImplicitTargetA 0 and reticles.
--
--      EffectImplicitTargetA   decides whether a given POINT IS VALID.
--                              27651 carries 52, TARGET_ENUM_GAMEOBJECTS_-
--                              SCRIPT_AOE_AT_DEST_LOC, a server-side
--                              enumeration target -- and the client refuses
--                              near-field points for it. 0 and 16 are fine.
--
--  That second half was not derived, it was MEASURED. Four throwaway crates
--  (sql/custom/047, since deleted) carried four candidate spells, and a brand-
--  new item entry is not in the client's WDB cache -- so all four could be
--  compared with `.additem` in one sitting, with no client restart per guess.
--  That probe is the technique to repeat if this ever needs revisiting.
--
--  ATTEMPT 3, AND THE ANSWER: 261 "Summon Skeleton"
--
--      Targets      0x40      the reticle
--      tgtA         0         same as Target Dummy, which works point-blank
--      Stances      0 / 0     any class, any form
--      powerType    0         no rage, no mana, no cost of any kind
--      family       0         generic, not somebody's class ability
--      range        0 - 20    minimum 0, so it is green at your feet; and 20
--                             is under housing's own 40-yard clamp, so the
--                             client's range check does all the bounding
--      radius       none      no circle, just the placement cursor -- the
--                             smallest indicator available, since no fully
--                             gated spell here draws a circle under 10 yards
--      effect       42        never runs; pItemUse returns true before the cast
--      Attributes   0x0 / 0x0 nothing conditional at all
--      text         description AND tooltip empty, so the Use line stays blank
--      SpellVisual  3         confirmed in play to trigger no animation
--
--      Present in server/dbc/Spell.dbc as well as the client's.
--
--  042 SETS @USE TO 261 ITSELF, so a fresh install needs nothing from here.
--  This file is the migration for a database carrying any earlier value, and
--  is re-runnable.
--
--  APPLYING IT
--
--    Get-Content sql\custom\046_furniture_placer_spell_fix.sql | `
--      DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_world
--
--  then `reload item_template` in the mangosd console. NO REBUILD -- the core
--  reads the clicked point out of the packet and never looks the spell up.
--
--  Then the client cache, which a relog does NOT clear: quit the client,
--  delete <client>\WDB\itemcache.wdb, start it. In that order; see 045.
-- ---------------------------------------------------------------------------

UPDATE item_template
   SET spellid_1 = 261
 WHERE entry IN (SELECT item_entry FROM house_furniture_item)
   AND spellid_1 IN (482, 30012, 27651);

SELECT CONCAT(COUNT(*), ' furniture items on the placer spell') AS result
  FROM item_template
 WHERE entry IN (SELECT item_entry FROM house_furniture_item)
   AND spellid_1 = 261;
