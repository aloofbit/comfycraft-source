-- The greeting line for the entrance portal's menu (tw_world).
--
-- The menu itself is built in C++ (source/src/game/Housing/HousePortal.cpp),
-- so none of the gossip_menu machinery is involved -- see CLAUDE.md. But
-- SendGossipMenu takes an npc_text ID rather than a string, so one row is
-- unavoidable, and npc_text has no inline strings in this core: it only points
-- at broadcast_text, so both are needed. Same 6400xxx custom block as 003, 004
-- and 018.
--
-- broadcast_text is NOT reloadable, so this one needs a restart. The menu
-- OPTIONS are inline in the C++ and need nothing.

DELETE FROM npc_text       WHERE ID    = 6400031;
DELETE FROM broadcast_text WHERE entry = 6400031;

INSERT INTO broadcast_text (entry, male_text, female_text, chat_type, language_id) VALUES
(6400031, 'A way home stands here.', 'A way home stands here.', 0, 0);

INSERT INTO npc_text (ID, BroadcastTextID0, Probability0) VALUES
(6400031, 6400031, 1);
