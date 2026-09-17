-- ---------------------------------------------------------------------------
-- 012_henchman_guild.sql -- move the henchmen onto a paired <NAME>-BOT account
-- and put them in a guild with the player, so `.bot add` keeps working.
--
-- THE RULE THIS IS BUILT AROUND:
--   `.bot add <name>` accepts a character only if it is on your account OR in
--   your guild -- the core's own rejection string is "Not in your guild or
--   account", and `AiPlayerbot.AllowMultiAccountAltBots` is documented in
--   aiplayerbot.conf as requiring `AllowGuildBots` AND same guild. Both are
--   already 1 in our conf. So a separate bot account is only half of it: WITHOUT
--   THE GUILD, `.bot add` STOPS WORKING the moment the henchmen leave your
--   account. That is why this script does both in one go.
--
-- WHY A SEPARATE ACCOUNT:
--   The 10-character cap. 010_henchmen.sql put all seven on ALOOFBIT next to
--   Luf and Adawd, which used 9 of 10 slots and made character select unwieldy.
--
-- BEFORE RUNNING -- create the account from the mangosd console:
--
--       account create ALOOFBIT-BOT <the same password as ALOOFBIT>
--
--   It cannot be done here. `sha_pass_hash` is SHA1(UPPER(user):UPPER(pass)),
--   so it is username-dependent and cannot be copied across from the main
--   account, and the console also generates the SRP6 `v`/`s` values.
--   `tw_logon.account.username` is varchar(32) unique with no character
--   validation, so the hyphen is fine.
--
-- !! RUN THIS WITH mangosd STOPPED !! -- it moves characters between accounts.
--
--   DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_char < sql\custom\012_henchman_guild.sql
--
-- NOTE: this puts Luf in a guild. That is visible in game -- guild tag under
-- the name, a guild chat channel, a tabard slot. If you would rather not be
-- guilded, skip this script and leave the roster on your own account.
-- ---------------------------------------------------------------------------

SET @BOT_ACCOUNT_NAME := 'ALOOFBIT-BOT';
SET @LEADER           := 4504;      -- Luf
SET @GUILDID          := 9000;      -- clear of the 20 bot guilds at 1-21
SET @GUILDNAME        := 'Hall of Companions';

-- Resolved from tw_logon. Stays NULL if the console command above was not run,
-- and every statement below is guarded on it, so a forgotten account creation
-- makes this script a no-op instead of orphaning seven characters on account 0.
SET @BOTACC := (SELECT id FROM tw_logon.account WHERE username = UPPER(@BOT_ACCOUNT_NAME));

-- ---------------------------------------------------------------------------
-- Move the roster off the player's account.
-- ---------------------------------------------------------------------------
UPDATE characters SET account = @BOTACC
 WHERE guid IN (1160,4516,3622,3827,2047,4395,2117)
   AND @BOTACC IS NOT NULL;

-- ---------------------------------------------------------------------------
-- The guild. Re-runnable: cleared by id first, then rebuilt.
-- ---------------------------------------------------------------------------
DELETE FROM guild        WHERE guildid = @GUILDID;
DELETE FROM guild_rank   WHERE guildid = @GUILDID;
DELETE FROM guild_member WHERE guildid = @GUILDID;
-- Also drop any stale membership these eight hold elsewhere, or the PRIMARY KEY
-- on guild_member.guid rejects the inserts below.
DELETE FROM guild_member WHERE guid IN (1160,4516,3622,3827,2047,4395,2117) OR guid = @LEADER;

INSERT INTO guild (guildid, name, leaderguid, EmblemStyle, EmblemColor, BorderStyle,
                   BorderColor, BackgroundColor, info, motd, createdate)
SELECT @GUILDID, @GUILDNAME, @LEADER, 0, 0, 0, 0, 0,
       'Companions for hire. Speak to Hall Steward Corwin in Ironforge.',
       'Call a companion with .bot add <name>', UNIX_TIMESTAMP()
 WHERE @BOTACC IS NOT NULL;

-- Rights values copied from the stock guilds in this DB: 1044991 for the two
-- leadership ranks, 67 for the rest.
INSERT INTO guild_rank (guildid, rid, rname, rights)
SELECT @GUILDID, r.rid, r.rname, r.rights FROM (
  SELECT 0 AS rid, 'Guild Master' AS rname, 1044991 AS rights UNION ALL
  SELECT 1, 'Officer',  1044991 UNION ALL
  SELECT 2, 'Veteran',  67      UNION ALL
  SELECT 3, 'Member',   67      UNION ALL
  SELECT 4, 'Initiate', 67
) r WHERE @BOTACC IS NOT NULL;

INSERT INTO guild_member (guildid, guid, rank, pnote, offnote)
SELECT @GUILDID, m.guid, m.rank, '', '' FROM (
  SELECT @LEADER AS guid, 0 AS rank UNION ALL
  SELECT 1160, 3 UNION ALL   -- Stefan
  SELECT 4516, 3 UNION ALL   -- Alesia
  SELECT 3622, 3 UNION ALL   -- Mhenlo
  SELECT 3827, 3 UNION ALL   -- Aidan
  SELECT 2047, 3 UNION ALL   -- Thom
  SELECT 4395, 3 UNION ALL   -- Cynn
  SELECT 2117, 3             -- Eve
) m WHERE @BOTACC IS NOT NULL;

-- ---------------------------------------------------------------------------
-- Report. If bot_account_id is NULL, nothing above ran -- create the account
-- from the mangosd console and re-run.
-- ---------------------------------------------------------------------------
SELECT @BOT_ACCOUNT_NAME AS bot_account, @BOTACC AS bot_account_id;

SELECT c.guid, c.name, c.level, c.account, gm.guildid, gm.rank
  FROM characters c
  LEFT JOIN guild_member gm ON gm.guid = c.guid
 WHERE c.guid IN (@LEADER,1160,4516,3622,3827,2047,4395,2117)
 ORDER BY gm.rank, c.name;
