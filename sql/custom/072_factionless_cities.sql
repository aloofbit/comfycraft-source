-- ============================================================================
--  Factionless: end the war with the eight capitals  (tw_world + tw_char)
-- ============================================================================
--    Get-Content sql\custom\072_factionless_cities.sql | `
--      DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_world
--
--  Every table name below is fully qualified, so the database you connect to
--  does not matter -- every database here lives on the one MariaDB instance.
--  This file touches BOTH tw_world and tw_char, and doing only the first looks
--  exactly like doing nothing at all. See the second half for why.
--
--  WHY. WorldObject::GetReactionTo (Objects/Object.cpp:3560) answers "is this
--  hostile to me" down two different paths, and the capitals take the one where
--  the faction template bitmasks are never consulted:
--
--      // if faction has reputation, hostile state depends only from AtWar state
--      if (FactionState const* factionState = ...GetState(targetFactionEntry))
--          if (factionState->Flags & FACTION_FLAG_AT_WAR)
--              return REP_HOSTILE;
--      return REP_FRIENDLY;
--
--  A Horde player is hostile to a Stormwind guard purely because their standing
--  with Stormwind starts at Hated and At War. The reverse direction reads the
--  same player's reputation, so one row governs both. Clear the war and the
--  guards, vendors, trainers, innkeepers, bankers, flight masters and quest
--  givers all go peaceful together -- there is no separate switch for any of
--  them.
--
--  Each of these eight rows carries four race-mask/value/flag slots, and on all
--  eight it is slot 2 that holds the opposite team:
--
--      434 = Orc+Undead+Tauren+Troll+Goblin      589 = the Alliance races
--
--  NEUTRAL, NOT FRIENDLY. base_rep_value2 = 0 is Neutral, which is the minimum
--  that clears both faction gates in Player::CanInteractWithNPC
--  (Objects/Player.cpp:3361) -- it refuses on IsHostileTo and again on
--  GetRank(faction) <= REP_UNFRIENDLY. Raising it further would make the cities
--  Friendly and hand out reputation discounts nobody asked for.
--
--  THE STANDING MUST STAY ABOVE HATED or the core simply re-declares the war on
--  load whatever the flags say (ReputationMgr.cpp:538):
--
--      else if (GetRank(factionEntry) <= REP_HOSTILE)
--          SetAtWar(faction, true);
--
--  reputation_flags2 = 1 is VISIBLE without PEACE_FORCED, chosen over 17 on
--  purpose: it leaves the At War checkbox in the reputation pane live, so a
--  player who wants the old world back can right-click Orgrimmar and declare
--  war on it personally. Both directions read that player's own state, so it is
--  symmetric, immediate, and changes nobody else's game.
--
--  NOT RELOADABLE. `faction` is absent from the 103 .reload subcommands, so
--  this needs a restart to take effect.
--
--  Re-runnable: both statements are plain idempotent UPDATEs.
--
--  Design: docs/features/factionless.md, piece 3.
-- ============================================================================

-- ---------------------------------------------------------------------------
--  tw_world: the base standing every character is handed at login
-- ---------------------------------------------------------------------------
--  47  Ironforge          54  Gnomeregan Exiles   68  Undercity
--  69  Darnassus          72  Stormwind           76  Orgrimmar
--  81  Thunder Bluff     530  Darkspear Trolls

UPDATE tw_world.faction
SET    base_rep_value2   = 0,
       reputation_flags2 = 1
WHERE  id IN (47, 54, 68, 69, 72, 76, 81, 530);

-- ---------------------------------------------------------------------------
--  tw_char: the stored At War flag, which is re-applied on every login
-- ---------------------------------------------------------------------------
--  The UPDATE above only moves the BASE standing. ReputationMgr::GetBaseReputation
--  recomputes that from tw_world.faction at every login and character_reputation
--  holds just the delta, so existing characters do pick the change up with no
--  further surgery -- but the At War FLAG is stored per character and re-applied
--  verbatim on load (ReputationMgr.cpp:522):
--
--      if (dbFactionFlags & FACTION_FLAG_AT_WAR)   // DB at war
--          SetAtWar(faction, true);
--
--  So without this second statement every existing character walks straight back
--  into a hostile capital and the tw_world change looks like it did nothing.
--  Measured before writing this file: 4601 rows per capital, of which 1896
--  (Alliance capitals) to 2705 (Horde capitals) carry the flag.
--
--  0x02 is FACTION_FLAG_AT_WAR (ReputationMgr.h:32-36). Nothing else is touched,
--  so a player who has since chosen war keeps it only if they re-tick the box.

UPDATE tw_char.character_reputation
SET    flags = flags & ~0x02
WHERE  faction IN (47, 54, 68, 69, 72, 76, 81, 530)
  AND  (flags & 0x02);
