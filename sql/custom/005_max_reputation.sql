-- ============================================================================
--  Set one character to Exalted with every faction  (tw_char)
-- ============================================================================
--  There is no GM command that does all factions at once - .modify rep takes a
--  single faction id. This does all 54 in one statement.
--
--  SCALE: standing is the raw reputation value, not a rank.
--    Neutral 0 | Friendly 3000 | Honored 9000 | Revered 21000 | Exalted 42000
--  42999 is the top of Exalted.
--
--  FLAGS: bit 2 is AT_WAR. Clearing it avoids being Exalted *and* at war with
--  a faction at the same time. Other bits (1 visible, 4 hidden, 16 peace
--  forced) are left as they are.
--
--  ONLY 54 of the 204 factions can hold reputation (faction.reputation_list_id
--  >= 0); the rest are combat/template factions. Characters already have all 54
--  rows, so this is an UPDATE - no inserts needed.
--
--  RUN WITH THE CHARACTER LOGGED OUT. A logged-in character holds reputation in
--  memory and will overwrite this on its next save (PlayerSave.Interval = 60s).
--
--    DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_char < sql\custom\005_max_reputation.sql
-- ============================================================================

SET @CHAR := 'Luf';   -- <-- change to the character you want

UPDATE character_reputation r
  JOIN characters c ON c.guid = r.guid
   SET r.standing = 42999,
       r.flags    = r.flags & ~2
 WHERE c.name = @CHAR;

SELECT c.name AS character_name, COUNT(*) AS factions_set, MIN(r.standing) AS lowest_standing
  FROM character_reputation r JOIN characters c ON c.guid = r.guid
 WHERE c.name = @CHAR GROUP BY c.name;
