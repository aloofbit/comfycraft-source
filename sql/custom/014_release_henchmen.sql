-- ---------------------------------------------------------------------------
-- 014_release_henchmen.sql -- undo 010_henchmen.sql.
--
-- WHY: 010 conscripted seven random bots into permanent named companions on the
-- player's account, because `.bot add` only accepts a character on your account
-- or in your guild, and no script command could put a bot in a party. Both
-- reasons are gone:
--
--   * SCRIPT_COMMAND_RECRUIT_BOT (93) now hires from the live 300-bot
--     population on a gossip click -- see 013_henchman_hall_recruit.sql.
--   * The ownership check in PlayerbotHolder::ProcessBotCommand exempts random
--     bots entirely (`isRandomAccount` short-circuits it), so the account and
--     guild requirement never applied to them in the first place. It only
--     applied because conscripting them onto a player account is what made them
--     stop being random bots.
--
-- So this hands all seven back: original RNDBOT accounts, original names, and
-- back into the recycling pool. It frees seven of the ten character slots on
-- ALOOFBIT and un-clutters character select.
--
-- 012_henchman_guild.sql is obsolete too. If it was ever applied, the guild it
-- created is dropped below.
--
-- !! RUN THIS WITH mangosd STOPPED !! -- it moves characters between accounts.
--
--   DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_char < sql\custom\014_release_henchmen.sql
--
-- Re-runnable: every statement keys off the fixed guid.
-- ---------------------------------------------------------------------------

-- guid, original name, original RNDBOT account id -- captured before 010 ran.
UPDATE characters SET account = 287, name = 'Toraggs'    WHERE guid = 1160;
UPDATE characters SET account =  51, name = 'Nolantan'   WHERE guid = 4516;
UPDATE characters SET account = 378, name = 'Claranca'   WHERE guid = 3622;
UPDATE characters SET account = 384, name = 'Ilydreath'  WHERE guid = 3827;
UPDATE characters SET account = 153, name = 'Evenian'    WHERE guid = 2047;
UPDATE characters SET account = 406, name = 'Penkiflee'  WHERE guid = 4395;
UPDATE characters SET account = 331, name = 'Jikiklul'   WHERE guid = 2117;

-- The Ironforge homebind 010 set. Random bots get relocated constantly, so this
-- is cosmetic either way, but leaving seven bots bound to the vendor block is
-- untidy. Their own randomiser will reset it on the next pass.

-- Guild built by 012, if it was ever applied.
DELETE FROM guild        WHERE guildid = 9000;
DELETE FROM guild_rank   WHERE guildid = 9000;
DELETE FROM guild_member WHERE guildid = 9000;

-- ---------------------------------------------------------------------------
SELECT guid, name, level, class, account FROM characters
 WHERE guid IN (1160,4516,3622,3827,2047,4395,2117) ORDER BY guid;
SELECT 'characters left on ALOOFBIT' AS note, COUNT(*) FROM characters WHERE account = 510;
