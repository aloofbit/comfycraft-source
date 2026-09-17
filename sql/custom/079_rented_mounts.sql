-- ============================================================================
--  Rentable mounts, everywhere  (tw_world)
-- ============================================================================
--  Turtle rents you a mount for 50 copper at about forty stables, and at
--  every one of them there are mounts standing in the pen that you cannot
--  rent. Gadgetzan is the clearest case: five rentable, and beside them a
--  Riding Raptor, a Riding Tiger and a Riding Horse that are scenery. This
--  file makes all of them rentable, and 82 more like them across the world.
--
--  THE OLD SYSTEM WAS A SWITCH STATEMENT. Twelve creature entries hardcoded
--  in src/scripts/miscellaneous/random_scripts_1.cpp, so adding one mount
--  meant editing C++ and rebuilding the core. `rented_mount` below replaces
--  it: a row per mount, and the script reads the row. Adding a rentable
--  mount is now two statements and a reload.
--
--  THE SPELL IS THE MOUNT OWN SPELL, NOT A RENTAL SPELL. There are only
--  twelve Rented-something spells in Spell.dbc (40700-40711) and the client
--  has the same twelve, so a thirteenth would mean shipping a patched
--  Spell.dbc to every client. Instead each row points at the real mount
--  spell for that model -- "Striped Nightsaber", 10793 -- which the client
--  already knows, and the core clamps it on cast to `speed` and `duration`:
--  +40% for 5 minutes, the rental terms, whatever the spell itself says.
--  The one visible seam is the spell tooltip, which still calls a clamped
--  epic mount "very fast". The buff name, icon and model are all correct.
--
--  COST, SPEED AND DURATION ARE PER ROW. They are all 50 / 40 / 300000 here,
--  which is exactly what the twelve originals already did. Change one row to
--  make one mount dearer or faster; `speed` or `duration` of 0 means "leave
--  the spell alone", which is how a row would opt out of the clamp.
--
--  WHAT RELOADS AND WHAT DOES NOT:
--    reload creature_template   -- FIRST, and required: the new renters need
--                                  their npc_flags and script_name cached
--                                  before anything else will see them.
--    reload rented_mount        -- new subcommand, added with this feature.
--    npc_text                   -- reloads.
--    broadcast_text             -- DOES NOT. The ten new greetings below need
--                                  a restart to appear. Everything else works
--                                  before it; the gossip body is just blank.
--  This file needs the matching core build. Applied against an older binary
--  it is inert -- the table sits there unread and the NPCs open an empty
--  gossip window.
--
--  NOT RENTABLE, and each for a reason:
--    4252  Gnome Racer                   -- display 2490 - .dismount refuses it (Mirage Raceway car)
--    4946  Gnome Drag Car                -- display 2490 - .dismount refuses it (Mirage Raceway car)
--    5405  Pinto                         -- questgiver (npc_flags 2); a gossip script would shadow its quest menu
--    50034 Little Lost Turtle            -- quest/vendor NPC (npc_flags 135)
--    51569 Riding Gryphon                -- already carries the npc_flying_mount script
--    62819 Tamed Moonstrider Hatchling   -- a companion hatchling, not a stabled mount
--    80163 Steelwing                     -- named NPC with its own gossip menu (npc_flags 1)
--  Any of them becomes rentable with one INSERT here and one UPDATE below.
-- ============================================================================

-- -- the table ---------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `rented_mount` (
  `creature_entry` mediumint(8) unsigned NOT NULL COMMENT 'creature_template.entry of the NPC you talk to',
  `spell_id`       mediumint(8) unsigned NOT NULL COMMENT 'mount spell to cast; supplies the model, name and icon',
  `cost`           int(10) unsigned     NOT NULL DEFAULT 50     COMMENT 'copper',
  `speed`          tinyint(3) unsigned  NOT NULL DEFAULT 40     COMMENT 'mounted speed %; 0 = leave the spell as it is',
  `duration`       int(10) unsigned     NOT NULL DEFAULT 300000 COMMENT 'ms; 0 = leave the spell as it is',
  `text_id`        mediumint(8) unsigned NOT NULL DEFAULT 0     COMMENT 'npc_text greeting; 0 = no greeting body',
  `noun`           varchar(32)          NOT NULL DEFAULT 'mount' COMMENT '"horse" in "Hire this horse for 50 copper."',
  PRIMARY KEY (`creature_entry`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='ComfyCraft: mounts a player can rent from a stable NPC';

-- -- greetings ---------------------------------------------------------------
--  Turtle already wrote five, for horse (90365), wolf (90368), undead horse
--  (90369), ram (90381) and kodo (90382), and those are reused as they are.
--  These ten cover the families it never had a rentable mount for.

DELETE FROM `broadcast_text` WHERE `entry` BETWEEN 100600 AND 100699;
INSERT INTO `broadcast_text` (`entry`, `male_text`, `chat_type`, `language_id`) VALUES
  (100600, 'The great cat watches you without blinking. Its tail moves, once.', 0, 0),   -- saber
  (100601, 'The raptor cocks its head at you. Whatever it is thinking, it thinks quickly.', 0, 0),   -- raptor
  (100602, 'The mechanostrider vents steam and settles onto its haunches. Something inside it is still ticking.', 0, 0),   -- strider
  (100603, 'The bear is enormous, and entirely unbothered by you. It waits.', 0, 0),   -- bear
  (100604, 'The turtle regards you with great patience. It is in no hurry, and suggests you are not either.', 0, 0),   -- turtle
  (100605, 'The unicorn lowers its head. There is something knowing in the way it looks at you.', 0, 0),   -- unicorn
  (100606, 'The stag holds still, antlers high. It has decided you are not a threat.', 0, 0),   -- stag
  (100607, 'It folds its wings and eyes you. It will carry you, but it will not fly.', 0, 0),   -- winged
  (100608, 'The beetle shifts its plates as it breathes. Something rattles inside the armour.', 0, 0),   -- tank
  (100609, 'The engine ticks as it cools. The seat is still warm.', 0, 0);   -- car

DELETE FROM `npc_text` WHERE `ID` BETWEEN 100600 AND 100699;
INSERT INTO `npc_text` (`ID`, `BroadcastTextID0`, `Probability0`) VALUES
  (100600, 100600, 1),
  (100601, 100601, 1),
  (100602, 100602, 1),
  (100603, 100603, 1),
  (100604, 100604, 1),
  (100605, 100605, 1),
  (100606, 100606, 1),
  (100607, 100607, 1),
  (100608, 100608, 1),
  (100609, 100609, 1);

-- -- the mounts --------------------------------------------------------------
--  spell_id is the real mount spell whose model matches this NPC display id,
--  so the buff reads as the mount you are actually sitting on. Where the NPC
--  and the spell disagree on a name the spell is the truthful one: the
--  Gadgetzan "Riding Tiger" is a Striped Nightsaber and always was.
--
--  The eleven that were already rentable keep their own 40700-40711 rental
--  spells, so nothing changes for them. 40045 is the exception worth naming:
--  spell 40711 "Rented Thalassian Unicorn" has been in the core switch since
--  the beginning with no gossip case to reach it. It works now.

DELETE FROM `rented_mount`;
INSERT INTO `rented_mount` (`creature_entry`, `spell_id`, `cost`, `speed`, `duration`, `text_id`, `noun`) VALUES
  (284   , 458   , 50, 40, 300000, 90365, 'horse'         ),  -- Brown Riding Horse -> Brown Horse
  (308   , 470   , 50, 40, 300000, 90365, 'horse'         ),  -- Black Stallion -> Black Stallion
  (4269  , 6648  , 50, 40, 300000, 90365, 'horse'         ),  -- Riding Horse (Chestnut) -> Chestnut Mare
  (4710  , 40708 , 50, 40, 300000, 90381, 'ram'           ),  -- Gray Riding Ram -> Gray Rented Ram   [was already rentable]
  (4779  , 40707 , 50, 40, 300000, 90381, 'ram'           ),  -- Brown Riding Ram -> Brown Rented Ram   [was already rentable]
  (5195  , 6654  , 50, 40, 300000, 90368, 'wolf'          ),  -- Brown Riding Wolf -> Brown Wolf
  (5198  , 581   , 50, 40, 300000, 90368, 'wolf'          ),  -- Arctic Riding Wolf -> Winter Wolf
  (5403  , 468   , 50, 40, 300000, 90365, 'horse'         ),  -- White Stallion -> White Stallion
  (5404  , 470   , 50, 40, 300000, 90365, 'horse'         ),  -- Black Stallion -> Black Stallion
  (5406  , 40700 , 50, 40, 300000, 90365, 'horse'         ),  -- Palomino -> Rented Palomino
  (5774  , 578   , 50, 40, 300000, 90368, 'wolf'          ),  -- Riding Wolf -> Black Wolf
  (8882  , 10793 , 50, 40, 300000, 100600, 'cat'           ),  -- Riding Tiger -> Striped Nightsaber
  (8883  , 470   , 50, 40, 300000, 90365, 'horse'         ),  -- Riding Horse -> Black Stallion
  (8885  , 16084 , 50, 40, 300000, 100601, 'raptor'        ),  -- Riding Raptor -> Mottled Red Raptor
  (11156 , 17465 , 50, 40, 300000, 90369, 'horse'         ),  -- Green Skeletal Warhorse -> Green Skeletal Warhorse
  (12346 , 8395  , 50, 40, 300000, 100601, 'raptor'        ),  -- Emerald Raptor -> Emerald Raptor
  (12349 , 10796 , 50, 40, 300000, 100601, 'raptor'        ),  -- Turquoise Raptor -> Turquoise Raptor
  (12350 , 10799 , 50, 40, 300000, 100601, 'raptor'        ),  -- Violet Raptor -> Violet Raptor
  (12351 , 40702 , 50, 40, 300000, 90368, 'wolf'          ),  -- Dire Riding Wolf -> Rented Dire Wolf
  (12353 , 40703 , 50, 40, 300000, 90368, 'wolf'          ),  -- Timber Riding Wolf -> Rented Timber Wolf
  (12354 , 40709 , 50, 40, 300000, 90382, 'kodo'          ),  -- Brown Riding Kodo -> Brown Rented Kodo   [was already rentable]
  (12355 , 40710 , 50, 40, 300000, 90382, 'kodo'          ),  -- Gray Riding Kodo -> Gray Rented Kodo   [was already rentable]
  (12358 , 8394  , 50, 40, 300000, 100600, 'cat'           ),  -- Riding Striped Frostsaber -> Striped Frostsaber
  (12359 , 10789 , 50, 40, 300000, 100600, 'cat'           ),  -- Riding Spotted Frostsaber -> Spotted Frostsaber
  (12360 , 10793 , 50, 40, 300000, 100600, 'cat'           ),  -- Riding Striped Nightsaber -> Striped Nightsaber
  (12363 , 10969 , 50, 40, 300000, 100602, 'mechanostrider'),  -- Blue Mechanostrider -> Blue Mechanostrider
  (12365 , 10873 , 50, 40, 300000, 100602, 'mechanostrider'),  -- Red Mechanostrider -> Red Mechanostrider
  (12366 , 17454 , 50, 40, 300000, 100602, 'mechanostrider'),  -- Unpainted Mechanostrider -> Unpainted Mechanostrider
  (12367 , 17453 , 50, 40, 300000, 100602, 'mechanostrider'),  -- Green Mechanostrider -> Green Mechanostrider
  (12371 , 17460 , 50, 40, 300000, 90381, 'ram'           ),  -- Frost Ram -> Frost Ram
  (12372 , 6899  , 50, 40, 300000, 90381, 'ram'           ),  -- Brown Ram -> Brown Ram
  (12373 , 6777  , 50, 40, 300000, 90381, 'ram'           ),  -- Gray Ram -> Gray Ram
  (12374 , 6898  , 50, 40, 300000, 90381, 'ram'           ),  -- White Riding Ram -> White Ram
  (12375 , 6648  , 50, 40, 300000, 90365, 'horse'         ),  -- Chestnut Mare -> Chestnut Mare
  (12376 , 458   , 50, 40, 300000, 90365, 'horse'         ),  -- Brown Horse -> Brown Horse
  (14539 , 23251 , 50, 40, 300000, 90368, 'wolf'          ),  -- Swift Timber Wolf -> Swift Timber Wolf
  (14540 , 23250 , 50, 40, 300000, 90368, 'wolf'          ),  -- Swift Brown Wolf -> Swift Brown Wolf
  (14541 , 23252 , 50, 40, 300000, 90368, 'wolf'          ),  -- Swift Gray Wolf -> Swift Gray Wolf
  (14542 , 23247 , 50, 40, 300000, 90382, 'kodo'          ),  -- Great White Kodo -> Great White Kodo
  (14543 , 23242 , 50, 40, 300000, 100601, 'raptor'        ),  -- Swift Olive Raptor -> Swift Olive Raptor
  (14544 , 23243 , 50, 40, 300000, 100601, 'raptor'        ),  -- Swift Orange Raptor -> Swift Orange Raptor
  (14545 , 23241 , 50, 40, 300000, 100601, 'raptor'        ),  -- Swift Blue Raptor -> Swift Blue Raptor
  (14546 , 23238 , 50, 40, 300000, 90381, 'ram'           ),  -- Swift Brown Ram -> Swift Brown Ram
  (14547 , 23240 , 50, 40, 300000, 90381, 'ram'           ),  -- Swift White Ram -> Swift White Ram
  (14548 , 23239 , 50, 40, 300000, 90381, 'ram'           ),  -- Swift Gray Ram -> Swift Gray Ram
  (14549 , 23249 , 50, 40, 300000, 90382, 'kodo'          ),  -- Great Brown Kodo -> Great Brown Kodo
  (14550 , 23248 , 50, 40, 300000, 90382, 'kodo'          ),  -- Great Gray Kodo -> Great Gray Kodo
  (14551 , 23222 , 50, 40, 300000, 100602, 'mechanostrider'),  -- Swift Yellow Mechanostrider -> Swift Yellow Mechanostrider
  (14552 , 23223 , 50, 40, 300000, 100602, 'mechanostrider'),  -- Swift White Mechanostrider -> Swift White Mechanostrider
  (14553 , 23225 , 50, 40, 300000, 100602, 'mechanostrider'),  -- Swift Green Mechanostrider -> Swift Green Mechanostrider
  (14555 , 23219 , 50, 40, 300000, 100600, 'cat'           ),  -- Swift Mistsaber -> Swift Mistsaber
  (14556 , 23221 , 50, 40, 300000, 100600, 'cat'           ),  -- Swift Frostsaber -> Swift Frostsaber
  (14558 , 23246 , 50, 40, 300000, 90369, 'horse'         ),  -- Purple Skeletal Warhorse -> Purple Skeletal Warhorse
  (14559 , 23227 , 50, 40, 300000, 90365, 'horse'         ),  -- Swift Palamino -> Armored Swift Palomino
  (14560 , 23228 , 50, 40, 300000, 90365, 'horse'         ),  -- Swift White Steed -> Swift White Steed
  (14561 , 23229 , 50, 40, 300000, 90365, 'horse'         ),  -- Swift Brown Steed -> Swift Brown Steed
  (14602 , 23338 , 50, 40, 300000, 100600, 'cat'           ),  -- Swift Stormsaber -> Swift Stormsaber
  (15666 , 25863 , 50, 40, 300000, 100608, 'battle tank'   ),  -- Black Qiraji Battle Tank -> Black Qiraji Battle Tank
  (15714 , 26055 , 50, 40, 300000, 100608, 'battle tank'   ),  -- Yellow Qiraji Battle Tank -> Yellow Qiraji Battle Tank
  (15715 , 26056 , 50, 40, 300000, 100608, 'battle tank'   ),  -- Green Qiraji Battle Tank -> Green Qiraji Battle Tank
  (15716 , 26054 , 50, 40, 300000, 100608, 'battle tank'   ),  -- Red Qiraji Battle Tank -> Red Qiraji Battle Tank
  (17266 , 30174 , 50, 40, 300000, 100604, 'turtle'        ),  -- Riding Turtle -> Riding Turtle
  (33000 , 33400 , 50, 40, 300000, 90365, 'horse'         ),  -- Black Tournament Charger -> Black Tournament Charger
  (40007 , 45009 , 50, 40, 300000, 100603, 'bear'          ),  -- Black Riding Bear -> Black Riding Bear
  (40008 , 45010 , 50, 40, 300000, 100603, 'bear'          ),  -- Ash Riding Bear -> Ash Riding Bear
  (40009 , 45011 , 50, 40, 300000, 100603, 'bear'          ),  -- Dark Brown Riding Bear -> Dark Brown Riding Bear
  (40011 , 45013 , 50, 40, 300000, 100603, 'bear'          ),  -- Brown Riding Bear -> Brown Riding Bear
  (40023 , 45028 , 50, 40, 300000, 90365, 'horse'         ),  -- Scarlet Warhorse -> Summon Scarlet Warhorse
  (40043 , 45047 , 50, 40, 300000, 100605, 'unicorn'       ),  -- Armored Thalassian Unicorn -> Swift Armored Unicorn
  (40044 , 45048 , 50, 40, 300000, 100605, 'unicorn'       ),  -- Ornate Thalassian Unicorn -> Swift Thalassian Unicorn
  (40045 , 40711 , 50, 40, 300000, 100605, 'unicorn'       ),  -- White Thalassian Unicorn -> Rented Thalassian Unicorn
  (50035 , 30174 , 50, 40, 300000, 100604, 'turtle'        ),  -- Tamed Turtle -> Riding Turtle
  (50097 , 46449 , 50, 40, 300000, 100606, 'stag'          ),  -- Shadowhorn Stag -> Shadowhorn Stag
  (51560 , 468   , 50, 40, 300000, 90365, 'horse'         ),  -- White Stallion -> White Stallion   [was already rentable]
  (51561 , 40700 , 50, 40, 300000, 90365, 'horse'         ),  -- Palomino -> Rented Palomino   [was already rentable]
  (51580 , 40702 , 50, 40, 300000, 90368, 'wolf'          ),  -- Dire Riding Wolf -> Rented Dire Wolf   [was already rentable]
  (51581 , 40703 , 50, 40, 300000, 90368, 'wolf'          ),  -- Timber Riding Wolf -> Rented Timber Wolf   [was already rentable]
  (51587 , 17464 , 50, 40, 300000, 90369, 'horse'         ),  -- Brown Skeletal Horse -> Brown Skeletal Horse   [was already rentable]
  (51588 , 17462 , 50, 40, 300000, 90369, 'horse'         ),  -- Red Skeletal Horse -> Red Skeletal Horse   [was already rentable]
  (51589 , 17463 , 50, 40, 300000, 90369, 'horse'         ),  -- Blue Skeletal Horse -> Blue Skeletal Horse   [was already rentable]
  (61267 , 472   , 50, 40, 300000, 90365, 'horse'         ),  -- Perimus -> Pinto Horse
  (61268 , 470   , 50, 40, 300000, 90365, 'horse'         ),  -- Valius -> Black Stallion
  (80146 , 46207 , 50, 40, 300000, 100600, 'cat'           ),  -- Riding Ice Saber -> Riding Ice Saber
  (80156 , 46212 , 50, 40, 300000, 100607, 'beast'         ),  -- Bronze Drake -> Riding Bronze Drake
  (80164 , 46220 , 50, 40, 300000, 100607, 'beast'         ),  -- Riding Armored Gryphon -> Armored Wildhammer Gryphon
  (80300 , 45051 , 50, 40, 300000, 100609, 'car'           ),  -- Blue Rocket Car -> Swift Blue Rocket Car
  (80301 , 45050 , 50, 40, 300000, 100609, 'car'           ),  -- Red Rocket Car -> Swift Red Rocket Car
  (80302 , 45052 , 50, 40, 300000, 100609, 'car'           ),  -- Green Rocket Car -> Green Rocket Car
  (80454 , 45049 , 50, 40, 300000, 100605, 'unicorn'       ),  -- Unicorn -> Thalassian Unicorn
  (81013 , 46524 , 50, 40, 300000, 100603, 'bear'          ),  -- Armored Brown War Bear -> Armored Black Bear
  (83106 , 50056 , 50, 40, 300000, 90365, 'horse'         ),  -- Kul Tiran Warhorse -> Kul Tiran Warhorse
  (90975 , 46441 , 50, 40, 300000, 90365, 'horse'         ),  -- Armored Dalaran Warhorse -> Dalaran Warhorse
  (90976 , 46442 , 50, 40, 300000, 90365, 'horse'         );  -- Armored Knight's Warhorse -> Knight's Warhorse

-- -- make them talk ----------------------------------------------------------
--  npc_flags 1 is gossip in the 1.12 enum. Every entry below is at 0 today --
--  scenery you cannot click -- so the OR is only ever setting the one bit.
--  script_name binds the gossip to the rewritten rented_mount script.
--  None of them carries UNIT_FLAG_NOT_SELECTABLE, checked, so clicking works.

UPDATE `creature_template` SET `npc_flags` = `npc_flags` | 1, `script_name` = 'rented_mount'
WHERE `entry` IN (
  284, 308, 4269, 5195, 5198, 5403, 5404, 5406, 5774, 8882, 8883, 8885,
  11156, 12346, 12349, 12350, 12351, 12353, 12358, 12359, 12360, 12363, 12365, 12366,
  12367, 12371, 12372, 12373, 12374, 12375, 12376, 14539, 14540, 14541, 14542, 14543,
  14544, 14545, 14546, 14547, 14548, 14549, 14550, 14551, 14552, 14553, 14555, 14556,
  14558, 14559, 14560, 14561, 14602, 15666, 15714, 15715, 15716, 17266, 33000, 40007,
  40008, 40009, 40011, 40023, 40043, 40044, 40045, 50035, 50097, 61267, 61268, 80146,
  80156, 80164, 80300, 80301, 80302, 80454, 81013, 83106, 90975, 90976
);

-- -- check -------------------------------------------------------------------
--  Expect 93 rentable, 0 unscripted, 0 pointing at a creature that is not there.

SELECT
  (SELECT COUNT(*) FROM `rented_mount`) AS rentable,
  (SELECT COUNT(*) FROM `rented_mount` rm JOIN `creature_template` ct ON ct.`entry` = rm.`creature_entry`
     WHERE ct.`script_name` <> 'rented_mount' OR (ct.`npc_flags` & 1) = 0) AS not_wired,
  (SELECT COUNT(*) FROM `rented_mount` rm LEFT JOIN `creature_template` ct ON ct.`entry` = rm.`creature_entry`
     WHERE ct.`entry` IS NULL) AS no_such_creature,
  (SELECT COUNT(*) FROM `rented_mount` rm LEFT JOIN `npc_text` nt ON nt.`ID` = rm.`text_id`
     WHERE rm.`text_id` <> 0 AND nt.`ID` IS NULL) AS no_such_text;
