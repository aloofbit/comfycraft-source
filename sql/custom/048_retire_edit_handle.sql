-- ---------------------------------------------------------------------------
--  048 -- retire the edit handle
--  tw_world
-- ---------------------------------------------------------------------------
--
--  Edit mode used to summon a small gear beside every piece of furniture,
--  because a chair could not be clicked: GameObject::Use raises gossip only for
--  QUESTGIVER and GOOBER, and housing's types are GENERIC, CHAIR and
--  MAP_OBJECT. You clicked the gear, and the gear carried the menu.
--
--  The furniture carries its own menu now. While an object is in your edit
--  session the client is told -- for you alone, in Object::BuildValuesUpdate --
--  that it is a GOOBER, so it highlights under the cursor and can be clicked
--  directly. Nothing summons a gear any more and the C++ that did was deleted.
--
--  WHAT THIS FILE FIXES. Both 100010 rows still name a script that no longer
--  registers, so startup logged:
--
--      ERROR:Script not found: go_house_handle.
--      ERROR:Script not found: npc_house_handle.
--
--  Harmless, and exactly the kind of noise that trains you to ignore the error
--  log. Clearing script_name is the whole fix.
--
--  THE ROWS THEMSELVES STAY. They cost nothing, nothing references them, and
--  sql/custom/018-025 is the record of four model changes it took to find one
--  that worked -- a marker you have to click cannot be the usual invisible
--  stalker, and it had to be a gameobject rather than a creature because a
--  creature model carries an ambient loop through CreatureModelData ->
--  CreatureSoundData that cannot be silenced from the server. Deleting the rows
--  would leave those files describing objects that are not there.
--
--  Creature 100010 was already retired once, when the handle moved from a
--  creature to a gameobject; this retires the gameobject beside it.
--
--  APPLYING IT
--
--    Get-Content sql\custom\048_retire_edit_handle.sql | `
--      DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_world
--
--  Takes effect at the next restart -- script names are bound at startup, and
--  the error itself only appears there.
-- ---------------------------------------------------------------------------

UPDATE gameobject_template SET script_name = '' WHERE entry = 100010 AND script_name = 'go_house_handle';
UPDATE creature_template   SET script_name = '' WHERE entry = 100010 AND script_name = 'npc_house_handle';

SELECT CONCAT(
    (SELECT COUNT(*) FROM gameobject_template WHERE entry = 100010 AND script_name = ''),
    ' gameobject and ',
    (SELECT COUNT(*) FROM creature_template   WHERE entry = 100010 AND script_name = ''),
    ' creature row retired'
) AS result;
