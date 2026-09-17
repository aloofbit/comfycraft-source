-- The confirm page for claiming or moving a house at an entrance (tw_world).
--
-- There are NO confirmation popups in this client's gossip -- the packet
-- carries index, icon, coded and text per option and nothing else, so
-- AddMenuItem's BoxMessage is never transmitted (see CLAUDE.md). A confirm is
-- therefore a SECOND MENU: the gear re-opens on this text with a single yes
-- option and a way out. 6400031 stays the main greeting; this is the page you
-- only see when about to claim a home or move one.
--
-- broadcast_text is NOT reloadable, so this needs a restart -- which is fine,
-- because it ships with the binary that uses it.

DELETE FROM npc_text       WHERE ID    = 6400032;
DELETE FROM broadcast_text WHERE entry = 6400032;

INSERT INTO broadcast_text (entry, male_text, female_text, chat_type, language_id) VALUES
(6400032, 'Nothing is decided yet.', 'Nothing is decided yet.', 0, 0);

INSERT INTO npc_text (ID, BroadcastTextID0, Probability0) VALUES
(6400032, 6400032, 1);
