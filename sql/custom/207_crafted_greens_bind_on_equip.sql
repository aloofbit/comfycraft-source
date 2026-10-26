-- Crafted pieces that 162, 165 and 166 turned from white to green bind when equipped,
-- as the other crafted greens do. They kept bonding 0 from their white days.
-- tools/craft-upgrades/gen.py now sets this itself. Re-runnable.
--
--   Get-Content sql\custom\207_crafted_greens_bind_on_equip.sql | `
--     DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_world
--
-- Then: reload item_template, restart the client. The bind is set when an item is equipped,
-- so a piece a player wears now binds the next time it is put on.

UPDATE item_template SET bonding = 2 WHERE bonding = 0 AND quality = 2 AND entry IN (
  -- Leatherworking (162)
  2302, 7277, 7276, 5957, 2303, 4237, 7281, 2310, 4239, 2311,
  -- Blacksmithing (165)
  2853, 2851, 3469, 2852, 10421,
  -- Tailoring (166)
  4343, 2568, 4314, 4308, 4307, 7026, 2569, 2570, 2580, 10047, 10046, 10045, 6787
);
