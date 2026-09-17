/*
 * HouseVendor.cpp -- the furniture shop, sorted into pages.
 *
 * Carpenter Bram sells fifteen crates out of a plain vendor window and that was
 * fine at fifteen. At sixty-four it is four pages of scrolling past beds to
 * reach a rug, so Furnisher Adela (creature 100028) puts a menu in front of the
 * same stock: one row per category, each opening a vendor window holding only
 * that category.
 *
 * ONE npc_vendor LIST, FILTERED ON THE WAY OUT. There is no second stock table
 * and no hidden creature per tab. WorldSession::SendListInventory takes an
 * optional whitelist of item entries and simply leaves the rest out of the
 * packet.
 *
 * THAT IS SAFE BECAUSE THE CLIENT BUYS BY ITEM ENTRY, NOT BY LIST INDEX.
 * CMSG_BUY_ITEM carries the entry (HandleBuyItemOpcode reads `item`), and
 * Player::BuyItemFromVendor resolves it against the creature's FULL vendor
 * list. So a filtered window cannot buy the wrong thing, and nothing has to be
 * restored afterwards -- the filter never touches a row, only a packet. Worth
 * checking before copying this trick to a client-era where buying is by slot.
 *
 * THE CATEGORIES ARE DATA, NOT CODE. house_furniture_item.category carries a
 * label per crate; this file groups by whatever strings it finds and knows none
 * of the names. The rule that PRODUCES them lives in tools/categorise.js, which
 * is also where the addon's storage shelf and the catalogue browser get theirs
 * -- so all three agree by construction rather than by three word lists kept in
 * step. Renaming a bucket is one regeneration of sql/custom/042.
 *
 * WHY A SCRIPT RATHER THAN A HOOK IN NPCHandler. Housing's critters and
 * furniture reach gossip through direct calls in the core because they use
 * stock templates we do not own, so script_name is not ours to set. Creature
 * 100028 IS ours, so it takes the conventional route: creature_template.
 * script_name -> npc_house_furniture_shop -> pGossipHello/pGossipSelect. The
 * consequence worth having is that a SECOND tabbed shop is one SQL field and no
 * code at all.
 *
 * The seam is the same free-function one SCRIPT_COMMAND_RECRUIT_BOT and
 * HouseUseFurnitureItem use, because src/game/Housing is not on the scripts
 * project's include path (src/scripts/CMakeLists.txt:448 lists every other
 * src/game/* subfolder and not this one).
 */

#include "Housing/HouseMgr.h"

#include "Creature.h"
#include "GossipDef.h"
#include "Log.h"
#include "ObjectMgr.h"
#include "Player.h"
#include "WorldSession.h"

namespace
{
    // Our own sender id, distinct from HouseHandle.cpp's 700, so a stray click
    // carrying the other menu's sender falls through instead of being read as a
    // category index.
    uint32 const SHOP_SENDER = 701;

    // sql/custom/062. A code-built menu needs exactly one database row: an
    // npc_text id, because SendGossipMenu takes an id rather than a string and
    // npc_text in this core has no inline text -- it points at broadcast_text.
    uint32 const SHOP_TEXT = 6400040;

    // Action ids are 1-based category indices, so 0 stays available as "not one
    // of ours" and no separate page enum is needed: the menu has exactly one
    // page and every row on it does the same thing with a different argument.
    uint32 const ACT_CATEGORY_BASE = 1;

    // The whole list, for people who would rather scroll than click.
    // Deliberately LAST -- the pages are the reason this NPC exists, and a
    // first row that undoes them is a first row most people will take out of
    // habit.
    uint32 const ACT_EVERYTHING = 100;
}

// ---------------------------------------------------------------------------

// The one page: a row per category, then All.
//
// A category with nothing in it cannot happen -- the list is built FROM the
// items at load, so a name only exists because something carries it. That is
// worth knowing because it is why there is no empty-page guard here.
static void SendShopMenu(Player* player, Creature* shop)
{
    std::vector<std::string> const& cats = sHouseMgr.FurnitureCategories();

    player->PlayerTalkClass->ClearMenus();
    GossipMenu& menu = player->PlayerTalkClass->GetGossipMenu();

    for (uint32 i = 0; i < cats.size(); ++i)
        menu.AddMenuItem(GOSSIP_ICON_VENDOR, cats[i].c_str(), SHOP_SENDER,
                         ACT_CATEGORY_BASE + i);

    // Only worth offering when it would show something the pages do not: with
    // one category, "All" IS that category under a vaguer name.
    if (cats.size() > 1)
        menu.AddMenuItem(GOSSIP_ICON_VENDOR, "All", SHOP_SENDER, ACT_EVERYTHING);

    // No categories at all means an unmigrated database -- sql/custom/062 not
    // applied, so every row's category is blank. Degrade to the plain vendor
    // window rather than to an empty menu, which would read as a broken NPC.
    if (cats.empty())
    {
        player->GetSession()->SendListInventory(shop->GetObjectGuid());
        return;
    }

    player->PlayerTalkClass->SendGossipMenu(SHOP_TEXT, shop->GetObjectGuid());
}

// ---------------------------------------------------------------------------
// The seam. Both return false for anything that is not this shop, so the core
// falls through to its ordinary handling.

bool HouseFurnitureShopGossipHello(Player* player, Creature* shop)
{
    if (!player || !shop)
        return false;

    SendShopMenu(player, shop);
    return true;
}

bool HouseFurnitureShopGossipSelect(Player* player, Creature* shop,
                                    uint32 sender, uint32 action)
{
    if (!player || !shop || sender != SHOP_SENDER)
        return false;

    if (action == ACT_EVERYTHING)
    {
        player->PlayerTalkClass->CloseGossip();
        player->GetSession()->SendListInventory(shop->GetObjectGuid());
        return true;
    }

    std::vector<std::string> const& cats = sHouseMgr.FurnitureCategories();
    uint32 const index = action - ACT_CATEGORY_BASE;

    // A MENU IS A PHOTOGRAPH. `.house furniture reload` can drop a category
    // between the menu being drawn and a row being clicked, so the index is
    // re-checked rather than trusted -- the same rule the entrance gear's party
    // offer follows. Out of range redraws instead of erroring, because the
    // honest answer to "that tab is gone" is the menu as it is now.
    if (index >= cats.size())
    {
        SendShopMenu(player, shop);
        return true;
    }

    std::set<uint32> page;
    sHouseMgr.FurnitureItemsIn(cats[index], page);

    // CLOSE THE MENU BEFORE THE WINDOW. The vendor frame and the gossip frame
    // are the same client frame, so leaving gossip open puts the server and the
    // client into different ideas of what is on screen -- the same trap
    // sql/custom/004 records from the other direction, where a gossip option
    // that ran only a script left the window up with no menu prepared.
    player->PlayerTalkClass->CloseGossip();
    player->GetSession()->SendListInventory(shop->GetObjectGuid(), VENDOR_MENU_ALL, &page);
    return true;
}
