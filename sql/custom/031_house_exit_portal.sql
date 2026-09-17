-- Where the way OUT of a house stands (tw_char).
--
-- Until now the exit portal was summoned at a constant: HOUSE_ENTRY_* stepped
-- back by HOUSE_EXIT_OFFSET, which put it at 15797 16394 0 in every house that
-- has ever existed. That was fine while a house was a bare plain and the portal
-- was the only thing on it. It stops being fine the moment somebody builds --
-- the doorway of the inn you put up is where the portal belongs, and no
-- constant can know where you put the inn.
--
-- So each house may now carry its own. `.house exit` writes these; unset falls
-- back to the old constant, which is why exit_set exists rather than treating
-- 0,0,0 as "unset". A house whose owner never runs the command behaves exactly
-- as it did before, and that includes every house created before this file.
--
-- Columns rather than a side table: it is one optional position per house, the
-- house row is already loaded for every house at startup, and house_portal is a
-- separate table only because it is a single global row belonging to no house.
--
-- Safe to apply while the server is running. HouseMgr::LoadFromDB selects its
-- columns by name, so the old binary neither sees nor minds these.

ALTER TABLE `house`
    ADD COLUMN IF NOT EXISTS `exit_set` tinyint(3) unsigned NOT NULL DEFAULT 0,
    ADD COLUMN IF NOT EXISTS `exit_x`   float NOT NULL DEFAULT 0,
    ADD COLUMN IF NOT EXISTS `exit_y`   float NOT NULL DEFAULT 0,
    ADD COLUMN IF NOT EXISTS `exit_z`   float NOT NULL DEFAULT 0,
    ADD COLUMN IF NOT EXISTS `exit_o`   float NOT NULL DEFAULT 0;
