-- 040 -- short per-house object numbers.
--
-- `house_object.id` IS the gameobject guid, allocated from one global block
-- starting at 8,000,000 (see CLAUDE.md, "house_object.id IS the gameobject
-- guid"). That is right for the core and hostile to type: `.house object move
-- away 2 #8000051` is seven digits of nothing, and the number is different in
-- every house for no reason a player can see.
--
-- `slot` is the same object counted from 1 WITHIN ITS OWN HOUSE. It is what
-- every command and every message uses now; the guid is still accepted as
-- input (anything >= 8000000 is read as one) and is simply never printed.
--
-- NO BACKFILL HERE ON PURPOSE. The loader numbers any row whose slot is still
-- 0 and writes it back, so this file is only the column -- which also means a
-- row inserted by hand, or by a future migration that forgets, heals itself on
-- the next start rather than becoming unreachable.
--
-- ORDER MATTERS: apply this BEFORE swapping in the binary that reads it. A
-- missing column is a failed query, and a failed query is a hard crash here.

ALTER TABLE house_object
    ADD COLUMN IF NOT EXISTS slot INT UNSIGNED NOT NULL DEFAULT 0
    COMMENT 'short per-house number, 1-based; 0 = not yet assigned' AFTER house_id;
