-- ============================================================================
--  Wailing Caverns: each sleep caster casts its sleep once a fight  (tw_world)
-- ============================================================================
--  Applied with:
--
--    Get-Content sql\custom\193_wailing_caverns_sleep_once.sql | `
--      DB\bin\mariadb.exe -h 127.0.0.1 -P 3307 -u root tw_world
--
--  then, in the mangosd console: reload creature_spells
--
--  creature_spells has no "cast once" setting. The repeat delay is set to its
--  maximum, 65535 s (about 18 hours). Spell timers reset when the creature
--  leaves combat, so a creature that resets can sleep once more in the next
--  fight. The first cast keeps its stock delay.
--
--  Each list belongs to one creature only. Marisa du'Paige (Westfall) also
--  casts Sleep 700 from her own list, 5990, which this does not touch.
--
--  Stock repeat delays, for a rollback:
--    38400 Druid of the Fang   slot 3, Druid's Slumber 8040   10 to 20
--    36690 Lord Cobrahn        slot 1, Druid's Slumber 8040   13 to 20
--    36700 Lord Pythas         slot 2, Sleep 700              12 to 20
--    36710 Lady Anacondra      slot 3, Sleep 700              12 to 25
--    36730 Lord Serpentis      slot 2, Sleep 700              10 to 20
-- ============================================================================

UPDATE creature_spells SET delayRepeatMin_3 = 65535, delayRepeatMax_3 = 65535 WHERE entry = 38400 AND spellId_3 = 8040;
UPDATE creature_spells SET delayRepeatMin_1 = 65535, delayRepeatMax_1 = 65535 WHERE entry = 36690 AND spellId_1 = 8040;
UPDATE creature_spells SET delayRepeatMin_2 = 65535, delayRepeatMax_2 = 65535 WHERE entry = 36700 AND spellId_2 = 700;
UPDATE creature_spells SET delayRepeatMin_3 = 65535, delayRepeatMax_3 = 65535 WHERE entry = 36710 AND spellId_3 = 700;
UPDATE creature_spells SET delayRepeatMin_2 = 65535, delayRepeatMax_2 = 65535 WHERE entry = 36730 AND spellId_2 = 700;
