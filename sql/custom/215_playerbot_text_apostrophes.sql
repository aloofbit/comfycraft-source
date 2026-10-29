-- ============================================================================
--  Apostrophes in the bot chat lines  (tw_world)
-- ============================================================================
--  Applied with:
--
--    Get-Content sql\custom\215_playerbot_text_apostrophes.sql | `
--      DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_world
--
--  then restart the server. The bot texts are read at startup.
--
--  24 rows of ai_playerbot_texts had a curly apostrophe that the import
--  stored as a plain '?' (0x3F). A companion greeted its owner with
--  "How?s it going?". Every broken row has the '?' between two letters,
--  and no correct English line has that, so one pattern fixes all of them.
--
--  Re-runnable: a fixed row no longer matches.
-- ============================================================================

UPDATE ai_playerbot_texts
SET text = REGEXP_REPLACE(text, BINARY '([A-Za-z])[?]([A-Za-z])', '\\1''\\2')
WHERE text REGEXP BINARY '[A-Za-z][?][A-Za-z]';
