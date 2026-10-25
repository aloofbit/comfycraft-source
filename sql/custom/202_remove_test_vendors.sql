-- ============================================================================
--  Remove the early test vendors  (tw_world)
-- ============================================================================
--  These NPCs were made for testing. Each sold every vendorable item of one
--  kind, test and "Deprecated" items included:
--
--    100000  Quartermaster Aldric  warrior sets              001
--    100002  Countess Nightvein    vampirism gear            004
--    100003  Blademaster Koren     level 60 one-hand swords  006
--    100004  Shieldmaster Brannd   level 60 shields          007
--    100005  Curator Vaelen        epic and legendary trinkets  008
--    100006  Curator Sylwen        rare trinkets             008
--    100007  Curator Dob           uncommon and lesser trinkets 008
--    100008  Tailor Merribeth      shirts                    009
--    100014  Keeper Faelyn         druid sets                037
--    100019  Vindicator Sareth     paladin sets              064
--    100020  Pathfinder Ryla       hunter sets               064
--    100021  Shadowbroker Vex      rogue sets                064
--    100022  Confessor Miriam      priest sets               064
--    100023  Farseer Nahla         shaman sets               064
--    100024  Archmage Theryn       mage sets                 064
--    100025  Dreadweaver Malia     warlock sets              064
--
--  The files in the last column made them and are deleted from the repo. This
--  file removes them from a server that already ran those. Do not reuse the
--  entries.
--
--  Re-runnable. Restart mangosd after it: no reload forgets a spawned creature.
-- ============================================================================

SET @ids := '100000,100002,100003,100004,100005,100006,100007,100008,100014,100019,100020,100021,100022,100023,100024,100025';

DELETE FROM creature          WHERE FIND_IN_SET(id, @ids);
DELETE FROM npc_vendor        WHERE FIND_IN_SET(entry, @ids);
DELETE FROM creature_template WHERE FIND_IN_SET(entry, @ids);
