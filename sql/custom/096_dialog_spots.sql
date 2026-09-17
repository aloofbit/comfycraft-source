-- ============================================================================
--  Dialog spots: named places an NPC can be told to walk to        (tw_world)
-- ============================================================================
--  Applied with:
--
--    Get-Content sql\custom\096_dialog_spots.sql | `
--      DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_world
--
--  APPLY BEFORE THE BINARY THAT WRITES IT and before the website that reads
--  it. `.spot` is a chat command in the core and a missing table is not a
--  warning here, it is `ASSERT(false)` in DatabaseMysql.cpp and a crash dump.
--  The same rule the bug tracker's table has, and for the same reason.
--
--  ------------------------------------------------------------------- WHY
--
--  SCRIPT_COMMAND_MOVE_TO (3) takes raw x/y/z. That is fine in a .sql file
--  where you paste what `.gps` told you, and it is no use at all in a web form:
--  there is no way to pick a point in the world from a browser, and three
--  floats typed by hand are three chances to send an NPC into a wall.
--
--  So the capture happens where the information is. You stand where you want
--  the NPC to end up and type
--
--      .spot the fire
--
--  and the editor offers "the fire" in a list from then on. The name is the
--  whole point: a scene reads "walks to the fire", not "walks to
--  1381.95 124.56 -62.36".
--
--  WHAT IS STORED IS A PLACE, NOT A DESTINATION FOR ANYONE IN PARTICULAR. A
--  spot has no idea which NPC might be sent to it, and two dialogs may use one.
--
--  ------------------------------------------------------------------- THE MAP
--
--  `map` is recorded and MOVE_TO cannot read it: the command moves its source
--  from wherever it is standing, with no notion of a different map, so sending
--  an NPC to a spot on another map walks it at a wall for as long as the
--  pathfinder is willing to try. The column is here so the EDITOR can say so
--  rather than so the core can check it, which is the only place the check can
--  usefully happen -- by the time the script runs there is nobody to tell.
--
--  ---------------------------------------------------------------- ID BLOCK
--
--  AUTO_INCREMENT from 1, and deliberately not one of this folder's reserved
--  ranges. Nothing outside this table and the dialog editor ever sees a spot
--  id: `gossip_scripts` stores the COORDINATES, not the spot, so renaming or
--  deleting a spot cannot reach into a script that was written using it. That
--  is the trade -- a scene keeps working after its spot is gone, and it stops
--  being obvious where it was walking to.
--
--  Re-runnable: CREATE TABLE IF NOT EXISTS, and no seed data.
-- ============================================================================

CREATE TABLE IF NOT EXISTS `dialog_spot` (
  `id`      smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `name`    varchar(48)          NOT NULL DEFAULT '',
  `map`     smallint(5) unsigned NOT NULL DEFAULT 0,
  `x`       float                NOT NULL DEFAULT 0,
  `y`       float                NOT NULL DEFAULT 0,
  `z`       float                NOT NULL DEFAULT 0,
  -- Which way to face on arrival. -10 is the core's own "do not care", which is
  -- what ScriptCommand_MoveTo substitutes for any o that is not positive, so a
  -- spot recorded facing due east (o = 0) and a spot with no facing at all are
  -- the same thing to it. Stored as captured; the editor decides.
  `o`       float                NOT NULL DEFAULT 0,
  -- Who typed .spot, so an odd one can be asked about.
  `author`  varchar(32)          NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
