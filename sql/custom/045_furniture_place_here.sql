-- ---------------------------------------------------------------------------
--  045 -- furniture crates raise the ground reticle
--  tw_world
-- ---------------------------------------------------------------------------
--
--  *** SUPERSEDED BY 046. DO NOT RUN THIS ON ITS OWN. ***
--
--  The mechanism below is right and still the explanation worth reading. The
--  SPELL is not: 30012 turned out to be a warrior ability -- Stances 65536,
--  powerType 1 (rage), SpellFamilyName 4 -- so using a crate switched a
--  warrior into Battle Stance and drew the red refusal cursor. 046 moves to
--  27651 and carries the full reasoning.
--
--  Running this after 046 is harmless: the guard is `AND spellid_1 = 482`,
--  which nothing matches any more. The count it prints at the end will read 0,
--  which is correct and not a failure.
--
--  Placing a crate used to put it three yards ahead of you, facing the way you
--  face, and everything after that was nudging. It now raises the same ground
--  reticle dynamite does, and lands where you click.
--
--  THE WHOLE CHANGE IS ONE SPELL ID. The 1.12 client raises that reticle when
--  and only when the item's on-use spell carries TARGET_FLAG_DEST_LOCATION
--  (0x40) in SpellEntry::Targets, and then writes the clicked point into
--  CMSG_USE_ITEM, where SpellCastTargets::read picks it up and pItemUse gets it
--  for free. Our crates carried 482 "Reset" (Targets 0x0); they now carry
--  30012 "Chess Move (DND)". The reasoning for that particular spell is in the
--  header of 042, beside the @USE it sets.
--
--  042 IS STILL THE SOURCE OF TRUTH and now sets 30012 itself, so a fresh
--  install needs nothing from this file. This exists for a database that
--  already has 042 as it was, and is re-runnable.
--
--  Nothing else about the spell matters, because it is never cast: pItemUse
--  returns true, and HandleUseItemOpcode skips CastItemUseSpell entirely.
--
--  APPLYING IT
--
--    Get-Content sql\custom\045_furniture_place_here.sql | `
--      DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_world
--
--  then `reload item_template` in the mangosd console -- no restart.
--
--  A CLIENT THAT HAS ALREADY SEEN THE ITEM WILL NOT SEE THIS, AND A RELOG DOES
--  NOT FIX IT. The 1.12 client queries an item once, holds it for the life of
--  the process, and persists it to <client>\WDB\itemcache.wdb. Character
--  select and back never restarts the process.
--
--      1. quit the client completely
--      2. delete  wow-clients\<client>\WDB\itemcache.wdb
--      3. start it again
--
--  In that order. The cache is written out from memory on exit, so deleting it
--  while the game is running only gets it rewritten with the stale row.
--
--  It also needs the binary that reads the point; without it the placement
--  simply ignores the click and goes three yards ahead as before.
-- ---------------------------------------------------------------------------

UPDATE item_template
   SET spellid_1 = 30012
 WHERE entry IN (SELECT item_entry FROM house_furniture_item)
   AND spellid_1 = 482;

-- Say what happened, since an UPDATE that matched nothing looks identical to
-- one that matched everything.
SELECT CONCAT(COUNT(*), ' furniture items now raise the reticle') AS result
  FROM item_template
 WHERE entry IN (SELECT item_entry FROM house_furniture_item)
   AND spellid_1 = 30012;
