-- 022 -- the furniture handle becomes a gameobject.
--
-- 019, 020 and 021 all chased the wisp's hum around the model list and none of
-- them could remove it: the loop reaches the client through
-- CreatureModelData -> CreatureSoundData, and the client reads its own copy of
-- both out of the MPQ. Every silent model was the wrong shape; the right shape
-- was never silent.
--
-- A GAMEOBJECT DOES NOT GO THROUGH EITHER TABLE. There is no creature sound
-- path to escape, whatever model it wears. The noise problem is not solved
-- here so much as deleted.
--
-- What made it possible is that the piece the handle actually needed -- a
-- clickable thing that opens a menu -- exists for gameobjects too, and is
-- reached earlier and more cleanly than the creature version:
--
--   type 10 GOOBER            what the client reads out of the replicated
--                             GAMEOBJECT_TYPE_ID field to decide it is
--                             interactable -- the gear cursor and the highlight
--   script_name go_house_handle
--                             bound to pGOHello, which ScriptMgr::OnGameObjectUse
--                             calls at GameObject.cpp:1448 -- BEFORE the type
--                             switch at 1461. Returning true there makes Use()
--                             return immediately.
--
-- THAT EARLY RETURN IS LOAD-BEARING. The goober case further down does
-- SetFlag(GO_FLAG_IN_USE) -> SetLootState(GO_ACTIVATED), and with autoCloseTime
-- 0 the next Update flips it to GO_JUST_DEACTIVATED, which for a summoned
-- object means delete. Hooking the gossip inside the goober case (pGOGossipHello,
-- which fires there) would give a handle that works exactly once and vanishes.
-- pGOHello runs before any of that machinery.
--
-- Selection comes back through a different door: CMSG_GOSSIP_SELECT_OPTION is
-- handled by HandleGossipSelectOptionOpcode, which has its own
-- guid.IsGameObject() branch reaching pGOGossipSelect. So hello and select are
-- deliberately on two different hooks here; they are not a matched pair.
--
-- display 426 World\Kalimdor\Blackfathom\PassiveDoodads\Lights\BFD_WispSmall.mdx
--   The Blackfathom Deeps wisp light -- the same look as the creature wisp, as a
--   doodad. 427 (Med) and 428 (Large) are the same model bigger, and 1267 /
--   1307 are green and purple. If the client turns out not to raise a cursor on
--   this one, the World\Goober\ folder (342 G_RuneBlue01, 404 G_RelicNESphere)
--   is where the known-clickable models live.
--
-- Every data field is left at 0 deliberately. pageId (data7) must be 0 or the
-- client is sent a page instead of a menu, and none of the rest is reached at
-- all now that pGOHello returns first.
--
-- Handles are summoned with Map::SummonGameObject, which allocates from the
-- per-map temporary guid range -- so this needs no guid block, exactly as the
-- creature version needed none. It also drops the creature 100010 entirely;
-- 018's creature_template row is left in place, harmless and unspawned, in case
-- this has to be reverted.

DELETE FROM gameobject_template WHERE entry = 100010;
INSERT INTO gameobject_template
    (entry, type, displayId, name, faction, flags, size,
     data0, data1, data2, data3, data4, data5, data6, data7, data8, data9,
     data10, data11, data12, data13, data14, data15, data16, data17, data18,
     data19, data20, data21, data22, data23,
     mingold, maxgold, script_name)
VALUES
    (100010, 10, 426, 'Furniture Handle', 0, 0, 1,
     0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
     0, 0, 0, 0, 0, 0, 0, 0, 0,
     0, 0, 0, 0, 0,
     0, 0, 'go_house_handle');
