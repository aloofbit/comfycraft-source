-- House upgrades: mailboxes, the repair table, fortunes and potions (tw_world).
-- docs/ai/housing/upgrades.md.
--
-- An upgrade is a furniture crate whose gameobject works when clicked. The
-- core finds them by type (HouseMgr::UpgradeItems), so the 'Upgrades'
-- category below is only Furnisher Adela's tab. The exit gear's Upgrades page
-- sells the same crates at the same buy_price.
--
--   item     gameobject                        does
--   100201   2011101 Highborne Mailbox (stock)  the mail window
--   100211-100220     the other ten stock mailbox styles, listed below
--   100221   100025  Refreshments               a menu of bread and water, 5 per click
--   100222   100026  Junk Compactor             sells bag items at the vendor price
--   100281   100029  Reagents                   a vendor window of the class reagents
--   100282   100030  Magic Crafting Box         a vendor window of the trade supplies
--   100283   100031  Anvil                      an anvil for recipes (spell focus 1)
--   100284   100032  Forge                      a forge for recipes (spell focus 3)
--   100285   100033  Cooking Stove              a cooking fire for recipes (spell focus 4)
--   100286   100034  Goblin Brainwashing Device talent reset and saved specs, kept for good
--   100202   100016  Repair Table               repairs all at the smith's price
--   100203   100017  Fortune of Strength        Sayge's 23735, 30 min
--   100204   100018  Fortune of Agility         23736
--   100205   100019  Fortune of Stamina         23737
--   100206   100020  Fortune of Spirit          23738
--   100207   100021  Fortune of Intellect       23766
--   100208   100022  Fortune of Armor           23767
--   100209   100023  Fortune of Damage          23768
--   100210   100024  Fortune of Resistance      23769
--   100223-100280  100040-100097  58 elixirs, potions and flasks, listed below
--
-- The potions are the stock buff elixirs and potions that last 10 minutes or
-- more, plus the short utility ones: drunk at once, for the potion's own time,
-- from level the potion needs. A crate costs 1g plus 20s a level; a flask crate
-- 1000g, and a character can take one flask every 12 hours. One house buff at
-- a time, fortunes included (HouseUpgrades.cpp, HOUSE_BUFFS, generated with the
-- rows below).
--
-- A house may hold any number of each upgrade.
--
-- Items take the housing tools block (100200-100299; the chalk is 100200).
-- Gameobjects take the hand-written low half of ours (the website owns
-- 100500-100999). Every model has a picture in ComfyHousingDev/thumbs, so the
-- crate tooltip shows it through the [m<display>] tag.
--
-- THE GAMEOBJECTS ARE REWRITTEN on every run: the scripts own them. THE ITEMS,
-- THE MAPPING AND THE SHOP ROWS ARE INSERT IGNORE, as in 042, so a name or a
-- price changed on /admin/furniture survives a re-run.
--
-- Apply BEFORE the binary that has go_house_repair and go_house_fortune, then
-- restart: the scripts are bound at startup. Until then the objects do
-- nothing when clicked.
--
-- Apply with:
--   Get-Content sql\custom\210_house_upgrades.sql | DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_world

-- ---------------------------------------------------------------- menu titles
-- 6400042 is the Upgrades page on the exit gear; 6400043 the repair table;
-- 6400044 the Refreshments menu; 6400045 the Junk Compactor.
-- The purchase confirm reuses 6400032.

DELETE FROM `npc_text`       WHERE `ID`    IN (6400042, 6400043, 6400044, 6400045);
DELETE FROM `broadcast_text` WHERE `entry` IN (6400042, 6400043, 6400044, 6400045);

INSERT INTO `broadcast_text` (`entry`, `male_text`, `female_text`, `chat_type`, `language_id`) VALUES
(6400042, 'What does this house need?', 'What does this house need?', 0, 0),
(6400043, 'What needs mending?',        'What needs mending?',        0, 0),
(6400044, 'What would you like?',       'What would you like?',       0, 0),
(6400045, 'What goes in?',              'What goes in?',              0, 0);

INSERT INTO `npc_text` (`ID`, `BroadcastTextID0`, `Probability0`) VALUES
(6400042, 6400042, 1),
(6400043, 6400043, 1),
(6400044, 6400044, 1),
(6400045, 6400045, 1);

-- ---------------------------------------------------------------- gameobjects
-- The fortunes are all the scroll of 2003458 (ScrollB02, display 24337); the
-- name on hover tells them apart.
--
-- Type 10 (GOOBER) so the client sends a use. pGOHello answers it and returns
-- true, which keeps the goober state machine from closing the object.

DELETE FROM `gameobject_template` WHERE `entry` BETWEEN 100016 AND 100026;
INSERT INTO `gameobject_template`
    (`entry`, `type`, `displayId`, `name`, `size`, `faction`, `flags`, `script_name`) VALUES
(100016, 10, 22670, 'Repair Table',          1, 0, 0, 'go_house_repair'),
(100017, 10, 24337, 'Fortune of Strength',   1, 0, 0, 'go_house_fortune'),
(100018, 10, 24337, 'Fortune of Agility',    1, 0, 0, 'go_house_fortune'),
(100019, 10, 24337, 'Fortune of Stamina',    1, 0, 0, 'go_house_fortune'),
(100020, 10, 24337, 'Fortune of Spirit',     1, 0, 0, 'go_house_fortune'),
(100021, 10, 24337, 'Fortune of Intellect',  1, 0, 0, 'go_house_fortune'),
(100022, 10, 24337, 'Fortune of Armor',      1, 0, 0, 'go_house_fortune'),
(100023, 10, 24337, 'Fortune of Damage',     1, 0, 0, 'go_house_fortune'),
(100024, 10, 24337, 'Fortune of Resistance', 1, 0, 0, 'go_house_fortune'),
(100025, 10, 24510, 'Refreshments',          1, 0, 0, 'go_house_pantry'),
(100026, 10,    13, 'Junk Compactor',        0.3, 0, 0, 'go_house_compactor');

-- THE JUNK COMPACTOR'S DISPLAY IS 13, BORROWED. Its model, GnomeMachine04
-- (display 23830), loops a machine sound from an event inside the model.
-- patch-V carries a copy with no event and points display row 13 (an unused
-- Blizzard test door) at it; see "A quiet Junk Compactor" in
-- patches/build-patch-v.js. A client without that patch-V shows the test
-- door. The crate keeps [m23830] below, for its picture.

-- 100029 is Reagents: a mortar and pestle (25516, the model of 2004637). A
-- click summons its invisible vendor, creature 100043 below, and opens that
-- vendor's window (go_house_shop in HouseUpgrades.cpp).
DELETE FROM `gameobject_template` WHERE `entry` = 100029;
INSERT INTO `gameobject_template`
    (`entry`, `type`, `displayId`, `name`, `size`, `faction`, `flags`, `script_name`) VALUES
(100029, 10, 25516, 'Reagents', 0.3, 0, 0, 'go_house_shop');

-- 100030 is the Magic Crafting Box: a naga crate (29868, the model of
-- 2008966), the same kind of shop with the trade supplies (vendor 100044).
DELETE FROM `gameobject_template` WHERE `entry` = 100030;
INSERT INTO `gameobject_template`
    (`entry`, `type`, `displayId`, `name`, `size`, `faction`, `flags`, `script_name`) VALUES
(100030, 10, 29868, 'Magic Crafting Box', 0.5, 0, 0, 'go_house_shop');

-- 100031-100033 are crafting stations: type 8, SPELL_FOCUS, which is all a
-- recipe asks for (data0 the focus, data1 its range in yards). No script and
-- no code: a placed object keeps its type. The anvil and forge are Turtle's
-- Blazing Forge Kit pieces (3000685, 3000684) under plain names; the stove is
-- the potbelly stove of 2003520 (24399), which stock has only as decoration.
DELETE FROM `gameobject_template` WHERE `entry` BETWEEN 100031 AND 100033;
INSERT INTO `gameobject_template`
    (`entry`, `type`, `displayId`, `name`, `size`, `faction`, `flags`, `data0`, `data1`, `script_name`) VALUES
(100031, 8,   273, 'Anvil',        0.5, 0, 0, 1, 10, ''),
(100032, 8,   209, 'Forge',        0.5, 0, 0, 3, 10, ''),
(100033, 8, 24399, 'Cooking Stove',  1, 0, 0, 4, 10, '');

-- 100034 is the house's Goblin Brainwashing Device: a copy of Turtle's
-- (1000333, summoned by the toy 51715 for a while) under go_house_brainwash,
-- which shows the same menu without asking for the toy's spell and lets the
-- edit menu through. The choices are the stock device's own.
DELETE FROM `gameobject_template` WHERE `entry` = 100034;
CREATE TEMPORARY TABLE comfy_device AS SELECT * FROM `gameobject_template` WHERE `entry` = 1000333;
UPDATE comfy_device SET `entry` = 100034, `script_name` = 'go_house_brainwash';
INSERT INTO `gameobject_template` SELECT * FROM comfy_device;
DROP TEMPORARY TABLE comfy_device;

-- The potions: 29525 (a blue bottle) for elixirs, 29528 (purple) for spell
-- elixirs, 24076 (dark blue) for utility elixirs, 24708 (an orc bottle) for
-- potions, 24414 (an alchemy set) for flasks. 100027-100039 are not potions:
-- 100028 and 100035 are Turtle's Shaman Shrine, 100029 is Reagents,
-- 100030 the Magic Crafting Box, 100031-100033 the crafting stations,
-- 100034 the Goblin Brainwashing Device.
DELETE FROM `gameobject_template` WHERE `entry` BETWEEN 100040 AND 100097;
INSERT INTO `gameobject_template`
    (`entry`, `type`, `displayId`, `name`, `size`, `faction`, `flags`, `script_name`) VALUES
(100040, 10, 29525, 'Elixir of Lion''s Strength', 1, 0, 0, 'go_house_potion'),
(100041, 10, 29525, 'Elixir of Minor Defense', 1, 0, 0, 'go_house_potion'),
(100042, 10, 29525, 'Elixir of Minor Agility', 1, 0, 0, 'go_house_potion'),
(100043, 10, 29525, 'Elixir of Minor Fortitude', 1, 0, 0, 'go_house_potion'),
(100044, 10, 29525, 'Elixir of Defense', 1, 0, 0, 'go_house_potion'),
(100045, 10, 29525, 'Elixir of Lesser Agility', 1, 0, 0, 'go_house_potion'),
(100046, 10, 29525, 'Elixir of Ogre''s Strength', 1, 0, 0, 'go_house_potion'),
(100047, 10, 29525, 'Elixir of Fortitude', 1, 0, 0, 'go_house_potion'),
(100048, 10, 29525, 'Elixir of Agility', 1, 0, 0, 'go_house_potion'),
(100049, 10, 29525, 'Elixir of Greater Defense', 1, 0, 0, 'go_house_potion'),
(100050, 10, 29525, 'Elixir of Greater Intellect', 1, 0, 0, 'go_house_potion'),
(100051, 10, 29525, 'Elixir of Greater Agility', 1, 0, 0, 'go_house_potion'),
(100052, 10, 29525, 'Elixir of Giants', 1, 0, 0, 'go_house_potion'),
(100053, 10, 29525, 'Elixir of Superior Defense', 1, 0, 0, 'go_house_potion'),
(100054, 10, 29525, 'Elixir of the Sages', 1, 0, 0, 'go_house_potion'),
(100055, 10, 29525, 'Elixir of Brute Force', 1, 0, 0, 'go_house_potion'),
(100056, 10, 29525, 'Elixir of the Mongoose', 1, 0, 0, 'go_house_potion'),
(100057, 10, 29528, 'Elixir of Wisdom', 1, 0, 0, 'go_house_potion'),
(100058, 10, 29528, 'Elixir of Firepower', 1, 0, 0, 'go_house_potion'),
(100059, 10, 29528, 'Elixir of Frost Power', 1, 0, 0, 'go_house_potion'),
(100060, 10, 29528, 'Arcane Elixir', 1, 0, 0, 'go_house_potion'),
(100061, 10, 29528, 'Elixir of Greater Firepower', 1, 0, 0, 'go_house_potion'),
(100062, 10, 29528, 'Elixir of Greater Frost Power', 1, 0, 0, 'go_house_potion'),
(100063, 10, 29528, 'Elixir of Greater Arcane Power', 1, 0, 0, 'go_house_potion'),
(100064, 10, 29528, 'Elixir of Shadow Power', 1, 0, 0, 'go_house_potion'),
(100065, 10, 29528, 'Greater Arcane Elixir', 1, 0, 0, 'go_house_potion'),
(100066, 10, 29528, 'Elixir of Greater Nature Power', 1, 0, 0, 'go_house_potion'),
(100067, 10, 29528, 'Elixir of Mind''s Reach', 1, 0, 0, 'go_house_potion'),
(100068, 10, 24076, 'Elixir of Water Breathing', 1, 0, 0, 'go_house_potion'),
(100069, 10, 24076, 'Elixir of Giant Growth', 1, 0, 0, 'go_house_potion'),
(100070, 10, 24076, 'Elixir of Water Walking', 1, 0, 0, 'go_house_potion'),
(100071, 10, 24076, 'Elixir of Detect Lesser Invisibility', 1, 0, 0, 'go_house_potion'),
(100072, 10, 24076, 'Catseye Elixir', 1, 0, 0, 'go_house_potion'),
(100073, 10, 24076, 'Elixir of Greater Water Breathing', 1, 0, 0, 'go_house_potion'),
(100074, 10, 24076, 'Elixir of Rapid Growth', 1, 0, 0, 'go_house_potion'),
(100075, 10, 24076, 'Elixir of Detect Undead', 1, 0, 0, 'go_house_potion'),
(100076, 10, 24076, 'Elixir of Demonslaying', 1, 0, 0, 'go_house_potion'),
(100077, 10, 24076, 'Elixir of Detect Demon', 1, 0, 0, 'go_house_potion'),
(100078, 10, 24708, 'Weak Troll''s Blood Potion', 1, 0, 0, 'go_house_potion'),
(100079, 10, 24708, 'Holy Protection Potion', 1, 0, 0, 'go_house_potion'),
(100080, 10, 24708, 'Strong Troll''s Blood Potion', 1, 0, 0, 'go_house_potion'),
(100081, 10, 24708, 'Shadow Protection Potion', 1, 0, 0, 'go_house_potion'),
(100082, 10, 24708, 'Fire Protection Potion', 1, 0, 0, 'go_house_potion'),
(100083, 10, 24708, 'Mighty Troll''s Blood Potion', 1, 0, 0, 'go_house_potion'),
(100084, 10, 24708, 'Frost Protection Potion', 1, 0, 0, 'go_house_potion'),
(100085, 10, 24708, 'Nature Protection Potion', 1, 0, 0, 'go_house_potion'),
(100086, 10, 24708, 'Mageblood Potion', 1, 0, 0, 'go_house_potion'),
(100087, 10, 24708, 'Greater Frost Protection Potion', 1, 0, 0, 'go_house_potion'),
(100088, 10, 24708, 'Greater Fire Protection Potion', 1, 0, 0, 'go_house_potion'),
(100089, 10, 24708, 'Greater Nature Protection Potion', 1, 0, 0, 'go_house_potion'),
(100090, 10, 24708, 'Greater Shadow Protection Potion', 1, 0, 0, 'go_house_potion'),
(100091, 10, 24708, 'Greater Holy Protection Potion', 1, 0, 0, 'go_house_potion'),
(100092, 10, 24708, 'Greater Arcane Protection Potion', 1, 0, 0, 'go_house_potion'),
(100093, 10, 24708, 'Major Troll''s Blood Potion', 1, 0, 0, 'go_house_potion'),
(100094, 10, 24414, 'Flask of the Titans', 1, 0, 0, 'go_house_potion'),
(100095, 10, 24414, 'Flask of Distilled Wisdom', 1, 0, 0, 'go_house_potion'),
(100096, 10, 24414, 'Flask of Supreme Power', 1, 0, 0, 'go_house_potion'),
(100097, 10, 24414, 'Flask of Chromatic Resistance', 1, 0, 0, 'go_house_potion');

-- ---------------------------------------------------------------- the cast
-- A fortune is a 5 s cast of 5017 "Divining Trance" (a dummy effect, used by
-- nothing else); spell_house_fortune applies the buff when the bar is full.
-- Script names are read once at startup: apply this before the restart.

UPDATE `spell_template` SET `script_name` = 'spell_house_fortune' WHERE `entry` = 5017;

-- A potion is a 5 s cast of 46200 "Dummy Spell" instead: no visual, movement
-- interrupts it, nothing else uses it. spell_house_potion kneels the player
-- for the length of the cast and applies the buff when the bar is full.
UPDATE `spell_template` SET `script_name` = 'spell_house_potion' WHERE `entry` = 46200;

-- The kneel fails CheckCast's standing test when the cast completes ("You must
-- be standing for that"). SPELL_ATTR_CASTABLE_WHILE_SITTING (0x08000000) lets
-- it through; 46200 has no other attributes.
DELETE FROM `spell_mod` WHERE `Id` = 46200;
INSERT INTO `spell_mod` (`Id`, `Attributes`, `Comment`) VALUES
(46200, 134217728, 'House potion cast: completes while kneeling (sql/custom/210)');

-- 5017 carries no interrupt flags, so walking away did not stop the cast. 15 is
-- what the crate spell (33453) has: movement, pushback, interrupt, auto attack.
-- The client's copy still says 0, so the server stops the bar, not the client.
DELETE FROM `spell_mod` WHERE `Id` = 5017;
INSERT INTO `spell_mod` (`Id`, `InterruptFlags`, `Comment`) VALUES
(5017, 15, 'House fortune cast: stops on movement (sql/custom/210)');

-- THE FLASK TIMER is a 12-hour cooldown on 9744 "Jarkal's Translation", a
-- dummy spell nothing casts. _LoadSpellCooldowns drops a saved cooldown that
-- is longer than the spell's own RecoveryTime, so this gives it 12 hours.
DELETE FROM `spell_mod` WHERE `Id` = 9744;
INSERT INTO `spell_mod` (`Id`, `RecoveryTime`, `Comment`) VALUES
(9744, 43200000, 'House flask timer: one flask every 12 hours (sql/custom/210)');

-- ---------------------------------------------------------------- crates
-- Copied from the Wooden Chair (100100), as /admin/furniture copies every new
-- crate: the crate icon, the on-use spell and item_house_furniture come with
-- it. Sell price is a fifth of the buy price.

CREATE TEMPORARY TABLE comfy_upgrade (
  `entry`  INT UNSIGNED NOT NULL,
  `go`     INT UNSIGNED NOT NULL,
  `name`   VARCHAR(48)  NOT NULL,
  `price`  INT UNSIGNED NOT NULL
);
INSERT INTO comfy_upgrade VALUES
(100201, 2011101, 'Highborne Mailbox',     100000),
(100202,  100016, 'Repair Table',          50000),
(100203,  100017, 'Fortune of Strength',   20000),
(100204,  100018, 'Fortune of Agility',    20000),
(100205,  100019, 'Fortune of Stamina',    20000),
(100206,  100020, 'Fortune of Spirit',     20000),
(100207,  100021, 'Fortune of Intellect',  20000),
(100208,  100022, 'Fortune of Armor',      20000),
(100209,  100023, 'Fortune of Damage',     20000),
(100210,  100024, 'Fortune of Resistance', 20000),
(100211,  144131, 'Alliance Mailbox',      100000),
(100212,  142102, 'Dwarven Mailbox',       100000),
(100213,  142109, 'Ornamental Mailbox',    100000),
(100214,  173221, 'Horde Mailbox',         100000),
(100215,  144112, 'Mechanical Mailbox',    100000),
(100216,  143983, 'Carved Mailbox',        100000),
(100217, 1000391, 'Creaking Mailbox',      100000),
(100218,  177044, 'Damaged Mailbox',       100000),
(100219,  179895, 'Primitive Mailbox',     100000),
(100220, 2011102, 'Illidari Mailbox',      100000),
(100221,  100025, 'Refreshments',          50000),
(100222,  100026, 'Junk Compactor',        100000),
(100281,  100029, 'Reagents',              500000),
(100282,  100030, 'Magic Crafting Box',    500000),
(100283,  100031, 'Anvil',                 150000),
(100284,  100032, 'Forge',                 150000),
(100285,  100033, 'Cooking Stove',         100000),
(100286,  100034, 'Goblin Brainwashing Device', 1000000),
(100223, 100040, 'Elixir of Lion''s Strength', 12000),
(100224, 100041, 'Elixir of Minor Defense', 12000),
(100225, 100042, 'Elixir of Minor Agility', 14000),
(100226, 100043, 'Elixir of Minor Fortitude', 14000),
(100227, 100044, 'Elixir of Defense', 42000),
(100228, 100045, 'Elixir of Lesser Agility', 46000),
(100229, 100046, 'Elixir of Ogre''s Strength', 50000),
(100230, 100047, 'Elixir of Fortitude', 60000),
(100231, 100048, 'Elixir of Agility', 64000),
(100232, 100049, 'Elixir of Greater Defense', 68000),
(100233, 100050, 'Elixir of Greater Intellect', 84000),
(100234, 100051, 'Elixir of Greater Agility', 86000),
(100235, 100052, 'Elixir of Giants', 86000),
(100236, 100053, 'Elixir of Superior Defense', 96000),
(100237, 100054, 'Elixir of the Sages', 98000),
(100238, 100055, 'Elixir of Brute Force', 100000),
(100239, 100056, 'Elixir of the Mongoose', 102000),
(100240, 100057, 'Elixir of Wisdom', 30000),
(100241, 100058, 'Elixir of Firepower', 46000),
(100242, 100059, 'Elixir of Frost Power', 66000),
(100243, 100060, 'Arcane Elixir', 84000),
(100244, 100061, 'Elixir of Greater Firepower', 90000),
(100245, 100062, 'Elixir of Greater Frost Power', 90000),
(100246, 100063, 'Elixir of Greater Arcane Power', 90000),
(100247, 100064, 'Elixir of Shadow Power', 90000),
(100248, 100065, 'Greater Arcane Elixir', 104000),
(100249, 100066, 'Elixir of Greater Nature Power', 106000),
(100250, 100067, 'Elixir of Mind''s Reach', 120000),
(100251, 100068, 'Elixir of Water Breathing', 26000),
(100252, 100069, 'Elixir of Giant Growth', 26000),
(100253, 100070, 'Elixir of Water Walking', 58000),
(100254, 100071, 'Elixir of Detect Lesser Invisibility', 68000),
(100255, 100072, 'Catseye Elixir', 70000),
(100256, 100073, 'Elixir of Greater Water Breathing', 80000),
(100257, 100074, 'Elixir of Rapid Growth', 80000),
(100258, 100075, 'Elixir of Detect Undead', 82000),
(100259, 100076, 'Elixir of Demonslaying', 90000),
(100260, 100077, 'Elixir of Detect Demon', 90000),
(100261, 100078, 'Weak Troll''s Blood Potion', 12000),
(100262, 100079, 'Holy Protection Potion', 30000),
(100263, 100080, 'Strong Troll''s Blood Potion', 40000),
(100264, 100081, 'Shadow Protection Potion', 44000),
(100265, 100082, 'Fire Protection Potion', 56000),
(100266, 100083, 'Mighty Troll''s Blood Potion', 62000),
(100267, 100084, 'Frost Protection Potion', 66000),
(100268, 100085, 'Nature Protection Potion', 66000),
(100269, 100086, 'Mageblood Potion', 90000),
(100270, 100087, 'Greater Frost Protection Potion', 106000),
(100271, 100088, 'Greater Fire Protection Potion', 106000),
(100272, 100089, 'Greater Nature Protection Potion', 106000),
(100273, 100090, 'Greater Shadow Protection Potion', 106000),
(100274, 100091, 'Greater Holy Protection Potion', 106000),
(100275, 100092, 'Greater Arcane Protection Potion', 106000),
(100276, 100093, 'Major Troll''s Blood Potion', 116000),
(100277, 100094, 'Flask of the Titans', 10000000),
(100278, 100095, 'Flask of Distilled Wisdom', 10000000),
(100279, 100096, 'Flask of Supreme Power', 10000000),
(100280, 100097, 'Flask of Chromatic Resistance', 10000000);

-- One copy of the chair per upgrade, numbered, then each copy gets its own
-- upgrade's entry, name and price by number.
CREATE TEMPORARY TABLE comfy_upgrade_item AS
  SELECT i.* FROM `item_template` i JOIN comfy_upgrade u WHERE i.`entry` = 100100;
ALTER TABLE comfy_upgrade_item ADD COLUMN `k` INT NOT NULL AUTO_INCREMENT PRIMARY KEY;

CREATE TEMPORARY TABLE comfy_upgrade_n AS
  SELECT `entry`, `go`, `name`, `price`, ROW_NUMBER() OVER (ORDER BY `entry`) AS `k` FROM comfy_upgrade;

UPDATE comfy_upgrade_item t JOIN comfy_upgrade_n u ON u.`k` = t.`k`
   SET t.`entry` = u.`entry`, t.`name` = u.`name`,
       t.`buy_price` = u.`price`, t.`sell_price` = u.`price` DIV 5;

ALTER TABLE comfy_upgrade_item DROP COLUMN `k`;
INSERT IGNORE INTO `item_template` SELECT * FROM comfy_upgrade_item;
DROP TEMPORARY TABLE comfy_upgrade_item;
DROP TEMPORARY TABLE comfy_upgrade_n;

INSERT IGNORE INTO `house_furniture_item` (`item_entry`, `go_entry`, `scale`, `category`)
  SELECT `entry`, `go`, 0, 'Upgrades' FROM comfy_upgrade;

-- ---------------------------------------------------------------- descriptions
-- What each upgrade does, in the tooltip. Rewritten on every run: the
-- furniture page edits names and prices only, so these belong to this file.
-- The model tag stays last; ComfyUI reads it and hides it.

CREATE TEMPORARY TABLE comfy_upgrade_text (
  `entry` INT UNSIGNED NOT NULL,
  `text`  VARCHAR(200) NOT NULL
);
INSERT INTO comfy_upgrade_text VALUES
(100201, 'Send and collect mail at home.'),
(100202, 'Repairs all your gear at the price a smith asks.'),
(100203, 'Read it for 10% more Strength for 30 minutes. One fortune at a time.'),
(100204, 'Read it for 10% more Agility for 30 minutes. One fortune at a time.'),
(100205, 'Read it for 10% more Stamina for 30 minutes. One fortune at a time.'),
(100206, 'Read it for 10% more Spirit for 30 minutes. One fortune at a time.'),
(100207, 'Read it for 10% more Intellect for 30 minutes. One fortune at a time.'),
(100208, 'Read it for 10% more armor for 30 minutes. One fortune at a time.'),
(100209, 'Read it for 10% more damage for 30 minutes. One fortune at a time.'),
(100210, 'Read it for 25 to all resistances for 30 minutes. One fortune at a time.'),
(100221, 'Buy bread and water for any level, five at a time.'),
(100222, 'Sell items from your bags at the vendor price, or every grey item at once.'),
(100281, 'A shop of the class reagents: powders, runes, candles, seeds, symbols and more. It buys nothing.'),
(100282, 'A shop of trade supplies: thread, dyes, vials, flux, spices and more. It buys nothing.'),
(100283, 'An anvil for blacksmithing and engineering recipes.'),
(100284, 'A forge for smelting and blacksmithing recipes.'),
(100285, 'A cooking fire for cooking recipes.'),
(100286, 'Reset your talents, and save and switch between talent specializations, from level 10.'),
(100223, 'The Elixir of Lion''s Strength buff for 1 hour. One house buff at a time.'),
(100224, 'The Elixir of Minor Defense buff for 1 hour. One house buff at a time.'),
(100225, 'The Elixir of Minor Agility buff for 1 hour. Needs level 2. One house buff at a time.'),
(100226, 'The Elixir of Minor Fortitude buff for 1 hour. Needs level 2. One house buff at a time.'),
(100227, 'The Elixir of Defense buff for 1 hour. Needs level 16. One house buff at a time.'),
(100228, 'The Elixir of Lesser Agility buff for 1 hour. Needs level 18. One house buff at a time.'),
(100229, 'The Elixir of Ogre''s Strength buff for 1 hour. Needs level 20. One house buff at a time.'),
(100230, 'The Elixir of Fortitude buff for 1 hour. Needs level 25. One house buff at a time.'),
(100231, 'The Elixir of Agility buff for 1 hour. Needs level 27. One house buff at a time.'),
(100232, 'The Elixir of Greater Defense buff for 1 hour. Needs level 29. One house buff at a time.'),
(100233, 'The Elixir of Greater Intellect buff for 1 hour. Needs level 37. One house buff at a time.'),
(100234, 'The Elixir of Greater Agility buff for 1 hour. Needs level 38. One house buff at a time.'),
(100235, 'The Elixir of Giants buff for 1 hour. Needs level 38. One house buff at a time.'),
(100236, 'The Elixir of Superior Defense buff for 1 hour. Needs level 43. One house buff at a time.'),
(100237, 'The Elixir of the Sages buff for 1 hour. Needs level 44. One house buff at a time.'),
(100238, 'The Elixir of Brute Force buff for 1 hour. Needs level 45. One house buff at a time.'),
(100239, 'The Elixir of the Mongoose buff for 1 hour. Needs level 46. One house buff at a time.'),
(100240, 'The Elixir of Wisdom buff for 1 hour. Needs level 10. One house buff at a time.'),
(100241, 'The Elixir of Firepower buff for 30 minutes. Needs level 18. One house buff at a time.'),
(100242, 'The Elixir of Frost Power buff for 30 minutes. Needs level 28. One house buff at a time.'),
(100243, 'The Arcane Elixir buff for 30 minutes. Needs level 37. One house buff at a time.'),
(100244, 'The Elixir of Greater Firepower buff for 1 hour. Needs level 40. One house buff at a time.'),
(100245, 'The Elixir of Greater Frost Power buff for 1 hour. Needs level 40. One house buff at a time.'),
(100246, 'The Elixir of Greater Arcane Power buff for 1 hour. Needs level 40. One house buff at a time.'),
(100247, 'The Elixir of Shadow Power buff for 1 hour. Needs level 40. One house buff at a time.'),
(100248, 'The Greater Arcane Elixir buff for 1 hour. Needs level 47. One house buff at a time.'),
(100249, 'The Elixir of Greater Nature Power buff for 1 hour. Needs level 48. One house buff at a time.'),
(100250, 'The Elixir of Mind''s Reach buff for 2 minutes. Needs level 55. One house buff at a time.'),
(100251, 'The Elixir of Water Breathing buff for 30 minutes. Needs level 8. One house buff at a time.'),
(100252, 'The Elixir of Giant Growth buff for 2 minutes. Needs level 8. One house buff at a time.'),
(100253, 'The Elixir of Water Walking buff for 30 minutes. Needs level 24. One house buff at a time.'),
(100254, 'The Elixir of Detect Lesser Invisibility buff for 10 minutes. Needs level 29. One house buff at a time.'),
(100255, 'The Catseye Elixir buff for 10 minutes. Needs level 30. One house buff at a time.'),
(100256, 'The Elixir of Greater Water Breathing buff for 1 hour. Needs level 35. One house buff at a time.'),
(100257, 'The Elixir of Rapid Growth buff for 2 minutes. Needs level 35. One house buff at a time.'),
(100258, 'The Elixir of Detect Undead buff for 1 hour. Needs level 36. One house buff at a time.'),
(100259, 'The Elixir of Demonslaying buff for 5 minutes. Needs level 40. One house buff at a time.'),
(100260, 'The Elixir of Detect Demon buff for 1 hour. Needs level 40. One house buff at a time.'),
(100261, 'The Weak Troll''s Blood Potion buff for 1 hour. One house buff at a time.'),
(100262, 'The Holy Protection Potion buff for 1 hour. Needs level 10. One house buff at a time.'),
(100263, 'The Strong Troll''s Blood Potion buff for 1 hour. Needs level 15. One house buff at a time.'),
(100264, 'The Shadow Protection Potion buff for 1 hour. Needs level 17. One house buff at a time.'),
(100265, 'The Fire Protection Potion buff for 1 hour. Needs level 23. One house buff at a time.'),
(100266, 'The Mighty Troll''s Blood Potion buff for 1 hour. Needs level 26. One house buff at a time.'),
(100267, 'The Frost Protection Potion buff for 1 hour. Needs level 28. One house buff at a time.'),
(100268, 'The Nature Protection Potion buff for 1 hour. Needs level 28. One house buff at a time.'),
(100269, 'The Mageblood Potion buff for 1 hour. Needs level 40. One house buff at a time.'),
(100270, 'The Greater Frost Protection Potion buff for 1 hour. Needs level 48. One house buff at a time.'),
(100271, 'The Greater Fire Protection Potion buff for 1 hour. Needs level 48. One house buff at a time.'),
(100272, 'The Greater Nature Protection Potion buff for 1 hour. Needs level 48. One house buff at a time.'),
(100273, 'The Greater Shadow Protection Potion buff for 1 hour. Needs level 48. One house buff at a time.'),
(100274, 'The Greater Holy Protection Potion buff for 1 hour. Needs level 48. One house buff at a time.'),
(100275, 'The Greater Arcane Protection Potion buff for 1 hour. Needs level 48. One house buff at a time.'),
(100276, 'The Major Troll''s Blood Potion buff for 1 hour. Needs level 53. One house buff at a time.'),
(100277, 'The Flask of the Titans buff for 2 hours. Needs level 50. One house buff at a time. One flask every 12 hours.'),
(100278, 'The Flask of Distilled Wisdom buff for 2 hours. Needs level 50. One house buff at a time. One flask every 12 hours.'),
(100279, 'The Flask of Supreme Power buff for 2 hours. Needs level 50. One house buff at a time. One flask every 12 hours.'),
(100280, 'The Flask of Chromatic Resistance buff for 2 hours. Needs level 50. One house buff at a time. One flask every 12 hours.');
INSERT INTO comfy_upgrade_text
  SELECT `entry`, 'Send and collect mail at home.'
    FROM comfy_upgrade WHERE `entry` BETWEEN 100211 AND 100220;

UPDATE `item_template` i
  JOIN comfy_upgrade_text t ON t.`entry` = i.`entry`
  JOIN `house_furniture_item` f ON f.`item_entry` = i.`entry`
  JOIN `gameobject_template` g ON g.`entry` = f.`go_entry`
   SET i.`description` = CONCAT(t.`text`, ' Right-click to place it in your house. [m',
                                IF(g.`entry` = 100026, 23830, g.`displayId`), ']');

DROP TEMPORARY TABLE comfy_upgrade_text;

-- ---------------------------------------------------------------- the tabs
-- A shop tab is house_furniture_item.category. The fortunes and the potions
-- are filed the way the exit gear's pages file them. Rewritten on every run;
-- the furniture page does not edit categories.

UPDATE `house_furniture_item` SET `category` = CASE
    WHEN `item_entry` = 100201 OR `item_entry` BETWEEN 100211 AND 100220 THEN 'Mailboxes'
    WHEN `item_entry` BETWEEN 100203 AND 100210 THEN 'Fortunes'
    WHEN `item_entry` BETWEEN 100223 AND 100239 THEN 'Elixirs'
    WHEN `item_entry` BETWEEN 100240 AND 100250 THEN 'Spell Elixirs'
    WHEN `item_entry` BETWEEN 100251 AND 100260 THEN 'Utility Elixirs'
    WHEN `item_entry` BETWEEN 100261 AND 100276 THEN 'Potions'
    WHEN `item_entry` BETWEEN 100277 AND 100280 THEN 'Flasks'
    ELSE `category` END
 WHERE `item_entry` BETWEEN 100201 AND 100286;

-- ---------------------------------------------------------------- the shops
-- Furnisher Adela (100028) sells the mailboxes, the repair table,
-- Refreshments and the Junk Compactor, after her other stock. The fortunes
-- moved to the potion seller.

DELETE FROM `npc_vendor` WHERE `entry` = 100028 AND `item` BETWEEN 100203 AND 100210;
SET @slot = (SELECT COALESCE(MAX(`slot`), 0) FROM `npc_vendor` WHERE `entry` = 100028);
INSERT IGNORE INTO `npc_vendor` (`entry`, `slot`, `item`, `maxcount`, `incrtime`)
  SELECT 100028, @slot + (`entry` - 100200), `entry`, 0, 0 FROM comfy_upgrade
   WHERE `entry` NOT BETWEEN 100203 AND 100210 AND `entry` NOT BETWEEN 100223 AND 100280;

-- The Reagents object's vendor (100043): a copy of Adela's template, made
-- invisible (model 11686, the trigger model), vendor only, named for the
-- window's title. It is summoned by the object and never spawned here.
-- HandleSellItemOpcode refuses every sale to it (HouseShopRefusesSales).
DELETE FROM `creature_template` WHERE `entry` = 100043;
CREATE TEMPORARY TABLE comfy_shopkeeper AS SELECT * FROM `creature_template` WHERE `entry` = 100028;
UPDATE comfy_shopkeeper SET `entry` = 100043, `name` = 'Reagents', `subname` = '',
                            `display_id1` = 11686, `display_id2` = 0, `display_id3` = 0, `display_id4` = 0,
                            `npc_flags` = 4, `script_name` = '';
INSERT INTO `creature_template` SELECT * FROM comfy_shopkeeper;
DROP TEMPORARY TABLE comfy_shopkeeper;

-- The class reagents every stock reagent vendor sells, by class: mage,
-- priest, druid, paladin, shaman, warlock, rogue.
DELETE FROM `npc_vendor` WHERE `entry` = 100043;
INSERT INTO `npc_vendor` (`entry`, `slot`, `item`, `maxcount`, `incrtime`) VALUES
(100043,  1, 17020, 0, 0),   -- Arcane Powder
(100043,  2, 17019, 0, 0),   -- Arcane Dust
(100043,  3, 17031, 0, 0),   -- Rune of Teleportation
(100043,  4, 17032, 0, 0),   -- Rune of Portals
(100043,  5, 17028, 0, 0),   -- Holy Candle
(100043,  6, 17029, 0, 0),   -- Sacred Candle
(100043,  7, 17021, 0, 0),   -- Wild Berries
(100043,  8, 17026, 0, 0),   -- Wild Thornroot
(100043,  9, 17034, 0, 0),   -- Maple Seed
(100043, 10, 17035, 0, 0),   -- Stranglethorn Seed
(100043, 11, 17036, 0, 0),   -- Ashwood Seed
(100043, 12, 17037, 0, 0),   -- Hornbeam Seed
(100043, 13, 17038, 0, 0),   -- Ironwood Seed
(100043, 14, 17033, 0, 0),   -- Symbol of Divinity
(100043, 15, 21177, 0, 0),   -- Symbol of Kings
(100043, 16, 17030, 0, 0),   -- Ankh
(100043, 17,  5565, 0, 0),   -- Infernal Stone
(100043, 18, 16583, 0, 0),   -- Demonic Figurine
(100043, 19,  5140, 0, 0);   -- Flash Powder

-- The Magic Crafting Box's vendor (100044): the same copy, the trade supplies
-- that at least three stock trade-supplies vendors sell.
DELETE FROM `creature_template` WHERE `entry` = 100044;
CREATE TEMPORARY TABLE comfy_shopkeeper AS SELECT * FROM `creature_template` WHERE `entry` = 100043;
UPDATE comfy_shopkeeper SET `entry` = 100044, `name` = 'Magic Crafting Box';
INSERT INTO `creature_template` SELECT * FROM comfy_shopkeeper;
DROP TEMPORARY TABLE comfy_shopkeeper;

DELETE FROM `npc_vendor` WHERE `entry` = 100044;
INSERT INTO `npc_vendor` (`entry`, `slot`, `item`, `maxcount`, `incrtime`) VALUES
(100044,  1,  2320, 0, 0),   -- Coarse Thread
(100044,  2,  2321, 0, 0),   -- Fine Thread
(100044,  3,  4291, 0, 0),   -- Silken Thread
(100044,  4,  8343, 0, 0),   -- Heavy Silken Thread
(100044,  5, 14341, 0, 0),   -- Rune Thread
(100044,  6,  2324, 0, 0),   -- Bleach
(100044,  7,  2604, 0, 0),   -- Red Dye
(100044,  8,  6260, 0, 0),   -- Blue Dye
(100044,  9,  2605, 0, 0),   -- Green Dye
(100044, 10,  4340, 0, 0),   -- Gray Dye
(100044, 11,  4341, 0, 0),   -- Yellow Dye
(100044, 12,  2325, 0, 0),   -- Black Dye
(100044, 13,  4342, 0, 0),   -- Purple Dye
(100044, 14,  3371, 0, 0),   -- Empty Vial
(100044, 15,  3372, 0, 0),   -- Leaded Vial
(100044, 16,  8925, 0, 0),   -- Crystal Vial
(100044, 17, 18256, 0, 0),   -- Imbued Vial
(100044, 18,  2880, 0, 0),   -- Weak Flux
(100044, 19,  3466, 0, 0),   -- Strong Flux
(100044, 20,  3857, 0, 0),   -- Coal
(100044, 21,  6217, 0, 0),   -- Copper Rod
(100044, 22,  2678, 0, 0),   -- Mild Spices
(100044, 23,  2692, 0, 0),   -- Hot Spices
(100044, 24,  3713, 0, 0),   -- Soothing Spices
(100044, 25,  4289, 0, 0),   -- Salt
(100044, 26, 42005, 0, 0),   -- Remedy Herbs
(100044, 27, 42006, 0, 0),   -- Springy Rope
(100044, 28, 50231, 0, 0),   -- Sturdy Rope
(100044, 29,  4399, 0, 0),   -- Wooden Stock
(100044, 30,  4400, 0, 0),   -- Heavy Stock
(100044, 31,  2928, 0, 0),   -- Dust of Decay
(100044, 32,  3777, 0, 0);   -- Lethargy Root

-- Apothecary Lenna (100042), "Scrolls & Flasks": the fortunes and the 58
-- elixirs, potions and flasks, 66 items, a tab per kind. The same tabbed
-- shop as Adela (npc_house_furniture_shop), which draws only the tabs a
-- shop's own stock fills. Her row is a copy of Adela's with the name, the
-- title and Alchemist Mallory's model (3237).

DELETE FROM `creature_template` WHERE `entry` = 100042;
CREATE TEMPORARY TABLE comfy_seller AS SELECT * FROM `creature_template` WHERE `entry` = 100028;
UPDATE comfy_seller SET `entry` = 100042, `name` = 'Apothecary Lenna', `subname` = 'Scrolls & Flasks',
                        `display_id1` = 3237, `display_id2` = 0, `display_id3` = 0, `display_id4` = 0;
INSERT INTO `creature_template` SELECT * FROM comfy_seller;
DROP TEMPORARY TABLE comfy_seller;

DELETE FROM `npc_vendor` WHERE `entry` = 100042;
INSERT INTO `npc_vendor` (`entry`, `slot`, `item`, `maxcount`, `incrtime`)
  SELECT 100042, `entry` - 100200, `entry`, 0, 0 FROM comfy_upgrade
   WHERE `entry` BETWEEN 100203 AND 100210 OR `entry` BETWEEN 100223 AND 100280;

-- Beside Adela in Goldshire, on her right. Guid 2949001 is from our block for
-- spawns written in SQL (CLAUDE.md, the id ranges).
DELETE FROM `creature` WHERE `guid` = 2949001;
INSERT INTO `creature` (`guid`, `id`, `map`, `position_x`, `position_y`, `position_z`, `orientation`,
                        `spawntimesecsmin`, `spawntimesecsmax`, `wander_distance`, `movement_type`) VALUES
(2949001, 100042, 0, -9461.45, 20.91, 63.8058, 4.36951, 120, 120, 0, 0);

DROP TEMPORARY TABLE comfy_upgrade;

-- ----------------------------------------------------------------------------
-- ROLLBACK
--
-- DELETE FROM `npc_vendor`           WHERE `entry` = 100028 AND `item` BETWEEN 100201 AND 100222;
-- DELETE FROM `npc_vendor`           WHERE `entry` IN (100042, 100043, 100044);
-- DELETE FROM `creature`             WHERE `guid` = 2949001;
-- DELETE FROM `creature_template`    WHERE `entry` IN (100042, 100043, 100044);
-- DELETE FROM `house_furniture_item` WHERE `item_entry` BETWEEN 100201 AND 100286;
-- DELETE FROM `item_template`        WHERE `entry` BETWEEN 100201 AND 100286;
-- DELETE FROM `gameobject_template`  WHERE `entry` BETWEEN 100016 AND 100026 OR `entry` BETWEEN 100029 AND 100034 OR `entry` BETWEEN 100040 AND 100097;
-- DELETE FROM `npc_text`             WHERE `ID`    IN (6400042, 6400043, 6400044, 6400045);
-- DELETE FROM `broadcast_text`       WHERE `entry` IN (6400042, 6400043, 6400044, 6400045);
-- UPDATE `spell_template` SET `script_name` = '' WHERE `entry` IN (5017, 46200);
-- DELETE FROM `spell_mod` WHERE `Id` IN (5017, 9744, 46200);
-- ----------------------------------------------------------------------------
