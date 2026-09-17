/*
 * npc_house_furniture_shop -- the furniture shop with pages.
 *
 * Bound by creature_template.script_name; sql/custom/042 sets it on Furnisher
 * Adela (100028). POINT IT AT ANOTHER CREATURE AND THERE IS A SECOND TABBED
 * SHOP, with no code change at all -- which is the reason this went through
 * script_name rather than a direct call in NPCHandler like housing's critters
 * and furniture do. Those two have no choice: they use stock templates we do
 * not own, so script_name is not ours to set.
 *
 * ALL THIS FILE DOES IS CROSS THE PROJECT BOUNDARY. The menu, the categories
 * and the filtered vendor window are src/game/Housing/HouseVendor.cpp;
 * src/game/Housing is not on the scripts project's include path
 * (src/scripts/CMakeLists.txt lists every other src/game/* subfolder and not
 * that one), so the two sides meet at a pair of extern free functions -- the
 * same seam HouseUseFurnitureItem and SCRIPT_COMMAND_RECRUIT_BOT use.
 *
 * AND THAT CMakeLists LISTS EVERY .cpp BY HAND. A new script file not added to
 * it compiles fine and fails at link with an unresolved AddSC_*.
 *
 * THE NPC NEEDS BOTH npc_flags 1 AND 4, for different reasons. Gossip (1) so
 * the client sends CMSG_GOSSIP_HELLO and this script gets a chance at all --
 * with vendor alone it opens the stock window directly and the pages are
 * unreachable. Vendor (4) so GetNPCIfCanInteractWith(guid,
 * UNIT_NPC_FLAG_VENDOR) inside SendListInventory and BuyItemFromVendor still
 * finds her -- without it every page is empty and nothing can be bought.
 */

#include "ScriptMgr.h"
#include "Player.h"
#include "Creature.h"

// src/game/Housing/HouseVendor.cpp. Both answer false for anything that is not
// this shop, so the core falls through to its ordinary handling.
extern bool HouseFurnitureShopGossipHello(Player* player, Creature* shop);
extern bool HouseFurnitureShopGossipSelect(Player* player, Creature* shop,
                                           uint32 sender, uint32 action);

bool GossipHello_npc_house_furniture_shop(Player* pPlayer, Creature* pCreature)
{
    return HouseFurnitureShopGossipHello(pPlayer, pCreature);
}

bool GossipSelect_npc_house_furniture_shop(Player* pPlayer, Creature* pCreature,
                                           uint32 uiSender, uint32 uiAction)
{
    return HouseFurnitureShopGossipSelect(pPlayer, pCreature, uiSender, uiAction);
}

void AddSC_npc_house_furniture_shop()
{
    Script* newscript = new Script;
    newscript->Name = "npc_house_furniture_shop";
    newscript->pGossipHello = &GossipHello_npc_house_furniture_shop;
    newscript->pGossipSelect = &GossipSelect_npc_house_furniture_shop;
    newscript->RegisterSelf();
}
