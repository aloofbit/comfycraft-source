#ifndef CUSTOM_MERCHANT_MGR_H
#define CUSTOM_MERCHANT_MGR_H

#include "Common.h"

#include <array>
#include <unordered_map>
#include <vector>

class Creature;
class Player;
class Unit;
class WorldSession;

struct CustomMerchantItemCost
{
    uint32 item = 0;
    uint32 count = 0;
};

struct CustomMerchantItem
{
    uint32 id = 0;
    uint32 entry = 0;
    uint32 item = 0;
    uint32 count = 1;
    uint32 extendedCost = 0;
    uint32 conditionId = 0;
    uint32 honorCost = 0;
    uint32 conquestCost = 0;
    std::array<CustomMerchantItemCost, 5> itemCosts;
};

class CustomMerchantMgr
{
    public:
        void Load();
        bool HandleAddonMessage(WorldSession* session, Player* player, uint32 type, std::string const& msg);

        /*
         * PUSH A SHOP AT SOMEBODY, rather than waiting to be asked for it.
         *
         * Measured 2026-09-14: the client sends `{"command":"show"}` when a
         * gossip window opens on a CREATURE carrying npc_flags bit 0x80000000,
         * and sends NOTHING for a player-type unit with byte-identical flags.
         * A probe in HandleAddonMessage logged one line for Gazol Madaxe and
         * none for a bot NPC standing beside him.
         *
         * The client refusing to ASK is not the client refusing to DRAW, and
         * those are different questions. This is the second one: the frame is
         * fed by an addon message either way, so anything that can decide a shop
         * should be opened -- a gossip option, say -- can simply send it.
         *
         * `vendor` is what the player is talking to and only supplies faction
         * and map for the condition checks; `entry` is the `custom_merchant`
         * key, and the two no longer have to be the same thing.
         */
        bool OpenShop(Player* player, Unit* vendor, uint32 entry);
        bool HasShop(uint32 entry) const { return GetItems(entry) != nullptr; }

        // The shop-id block, shared with `npc_vendor_template` so that a number
        // says which kind of thing it is. sql/custom/092_shops.sql.
        static bool IsShopId(uint32 entry) { return entry >= 200000 && entry <= 200999; }

    private:
        typedef std::vector<CustomMerchantItem> CustomMerchantItemList;

        void SendItemList(Player* player, Unit* vendor, uint32 entry) const;
        void SendCurrencyUpdate(Player* player, char const* command) const;
        void ScheduleItemCacheUpdates(Player* player, std::vector<uint32> const& itemIds) const;
        bool BuyItem(Player* player, Unit* vendor, uint32 entry, uint32 id) const;
        bool IsItemVisible(Player* player, CustomMerchantItem const& merchantItem) const;
        bool CanUseItem(Player* player, Unit* vendor, CustomMerchantItem const& merchantItem) const;
        CustomMerchantItem const* GetItem(uint32 id) const;
        CustomMerchantItemList const* GetItems(uint32 entry) const;

        std::unordered_map<uint32, CustomMerchantItemList> m_itemsByEntry;
        std::unordered_map<uint32, CustomMerchantItem const*> m_itemsById;
};

extern CustomMerchantMgr sCustomMerchantMgr;

#endif
