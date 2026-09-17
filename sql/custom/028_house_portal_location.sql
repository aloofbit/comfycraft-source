-- Where the world-side housing portal stands (tw_char).
--
-- One row, id 1. It lives in tw_char rather than tw_world because it is state
-- the server writes at runtime (.house portal moves it), not authored content:
-- tw_world is hand-applied and a runtime write there would be lost the next
-- time the file was re-run.
--
-- map = 0 means "not placed yet". Nothing spawns and .house go still works, so
-- an unplaced portal is a supported state rather than a broken one.

CREATE TABLE IF NOT EXISTS `house_portal` (
    `id`  tinyint(3) unsigned NOT NULL DEFAULT 1,
    `map` int(10) unsigned    NOT NULL DEFAULT 0,
    `x`   float               NOT NULL DEFAULT 0,
    `y`   float               NOT NULL DEFAULT 0,
    `z`   float               NOT NULL DEFAULT 0,
    `o`   float               NOT NULL DEFAULT 0,
    PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
