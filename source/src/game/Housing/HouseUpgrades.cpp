/*
 * HouseUpgrades.cpp -- the working objects a house can buy.
 *
 * An upgrade is a furniture crate whose gameobject does something when it is
 * clicked: a mailbox, the repair table, a fortune. It is bought for gold, at
 * Furnisher Adela or on the exit gear's Upgrades page, and placed like any
 * other crate. sql/custom/210 holds the rows; docs/ai/housing/upgrades.md the
 * facts.
 *
 * THE MAILBOX NEEDS NO CODE. A placed object keeps its own type for everyone
 * outside the owner's edit session, and CheckMailBox only asks for a type 19
 * object within reach. The crates place the eleven stock mailbox styles.
 *
 * THE REPAIR TABLE, THE FORTUNES, REFRESHMENTS, THE JUNK COMPACTOR AND THE
 * POTIONS ARE OUR OWN TEMPLATES (100016-100026, 100040-100097),
 * type 10 with a script_name, so they take the conventional pGOHello route
 * like the exit gear. Every hello answers false in the owner's edit session:
 * OnGameObjectUse runs BEFORE HouseGameObjectUse in GameObject::Use, and
 * returning false is what lets the edit menu through.
 *
 * A HOUSE MAY HOLD ANY NUMBER OF EACH (the owner's call, 2026-10-26). There
 * was a one-of-each rule for a day; it is gone, and nothing counts upgrades.
 */

#include "Housing/HouseMgr.h"

#include "Chat.h"
#include "DBCStores.h"
#include "GameObject.h"
#include "GossipDef.h"
#include "ObjectMgr.h"
#include "Player.h"
#include "ScriptMgr.h"
#include "Spell.h"
#include "SpellAuras.h"
#include "SpellMgr.h"
#include "WorldSession.h"

#include "Bag.h"
#include "Map.h"
#include "Creature.h"

#include <algorithm>
#include <map>
#include <mutex>
#include <sstream>

namespace
{
    // sql/custom/210. The repair table's one menu page needs a title row.
    uint32 const REPAIR_TEXT   = 6400043;
    uint32 const REPAIR_SENDER = 6406;

    // The blacksmith's hammer on an anvil (SoundEntries 4614, BlackSmithCrafting
    // A to D, one picked at random by the client), played at the table.
    uint32 const REPAIR_SOUND  = 4614;

    // THE PANTRY: food and drink from a menu, not a vendor window. A vendor
    // window needs a creature, and a window would take things back; a menu
    // only sells. Each row buys the item's own vendor bundle (buy_count, 5)
    // at its own buy_price, so the prices are the stock innkeeper's.
    uint32 const PANTRY_TEXT   = 6400044;
    uint32 const PANTRY_SENDER = 6407;

    enum PantryAction
    {
        ACT_PANTRY_DRINKS = 1,
        ACT_PANTRY_FOOD   = 2,
        ACT_PANTRY_MAIN   = 3,
        ACT_PANTRY_CLOSE  = 4,
        // anything larger is the item entry to buy
    };

    // THE JUNK COMPACTOR: sells bag items at the vendor price, from pick
    // mode (ComfyUI/Moonstones.lua, prefix CSELL) or all greys at once.
    uint32 const COMPACT_TEXT   = 6400045;
    uint32 const COMPACT_SENDER = 6408;
    float  const COMPACT_REACH  = 10.0f;
    char const* const COMPACT_PREFIX = "CSELL";

    enum CompactAction
    {
        ACT_COMPACT_PICK  = 1,
        ACT_COMPACT_GREYS = 2,
        ACT_COMPACT_CLOSE = 3,
    };

    // Who is in pick mode, and at which compactor. A click is refused once the
    // player is out of reach of it. Guarded: maps update on several threads.
    std::mutex s_compactingLock;
    std::map<uint32, ObjectGuid> s_compacting;

    // The stock water and bread tiers, by level. The row names come from the
    // items, so a rename in item_template shows here.
    uint32 const PANTRY_DRINKS[] = { 159, 1179, 1205, 1708, 1645, 8766 };
    uint32 const PANTRY_FOOD[]   = { 4540, 4541, 4542, 4544, 4601, 8950 };

    enum RepairAction
    {
        ACT_REPAIR_ALL   = 1,
        ACT_REPAIR_CLOSE = 2,
    };

    // A FORTUNE LASTS HALF AN HOUR. The Darkmoon Faire's own last two hours;
    // these are the same spells with the timer cut after they land, the way
    // MountRental times a mount. A potion lasts as long as the potion does.
    int32 const FORTUNE_MS = 30 * MINUTE * IN_MILLISECONDS;

    // ONE FLASK EVERY 12 HOURS, per character. The timer is a cooldown on 9744
    // "Jarkal's Translation", a dummy spell nothing casts, so it is saved and
    // loaded with the other cooldowns and blocks no real flask in the bags.
    // _LoadSpellCooldowns drops a cooldown longer than the spell's own
    // RecoveryTime as corrupt, so sql/custom/210 gives 9744 a 12-hour one in
    // spell_mod.
    uint32 const FLASK_TIMER = 9744;
    time_t const FLASK_COOLDOWN = 12 * HOUR;

    // A buff an upgrade object gives, after a 5 s cast: Sayge's fortunes (30
    // min) and the elixirs, potions and flasks (for their own time).
    // `item` is the real consumable, for its required level; 0 for a fortune.
    // The names are the crate names in 210, for the chat line.
    struct HouseBuff
    {
        uint32      goEntry;
        uint32      spellId;
        uint32      item;
        uint32      page;           // HouseUpgradePage
        char const* name;
    };

    // Generated with the SQL rows in 210, in the order each page lists them.
    HouseBuff const HOUSE_BUFFS[] =
    {
        { 100017, 23735,     0, HOUSE_UPGRADE_PAGE_FORTUNES, "Fortune of Strength" },
        { 100018, 23736,     0, HOUSE_UPGRADE_PAGE_FORTUNES, "Fortune of Agility" },
        { 100019, 23737,     0, HOUSE_UPGRADE_PAGE_FORTUNES, "Fortune of Stamina" },
        { 100020, 23738,     0, HOUSE_UPGRADE_PAGE_FORTUNES, "Fortune of Spirit" },
        { 100021, 23766,     0, HOUSE_UPGRADE_PAGE_FORTUNES, "Fortune of Intellect" },
        { 100022, 23767,     0, HOUSE_UPGRADE_PAGE_FORTUNES, "Fortune of Armor" },
        { 100023, 23768,     0, HOUSE_UPGRADE_PAGE_FORTUNES, "Fortune of Damage" },
        { 100024, 23769,     0, HOUSE_UPGRADE_PAGE_FORTUNES, "Fortune of Resistance" },
        { 100040,  2367,  2454, HOUSE_UPGRADE_PAGE_ELIXIRS, "Elixir of Lion's Strength" },
        { 100041,   673,  5997, HOUSE_UPGRADE_PAGE_ELIXIRS, "Elixir of Minor Defense" },
        { 100042,  2374,  2457, HOUSE_UPGRADE_PAGE_ELIXIRS, "Elixir of Minor Agility" },
        { 100043,  2378,  2458, HOUSE_UPGRADE_PAGE_ELIXIRS, "Elixir of Minor Fortitude" },
        { 100044,  3220,  3389, HOUSE_UPGRADE_PAGE_ELIXIRS, "Elixir of Defense" },
        { 100045,  3160,  3390, HOUSE_UPGRADE_PAGE_ELIXIRS, "Elixir of Lesser Agility" },
        { 100046,  3164,  3391, HOUSE_UPGRADE_PAGE_ELIXIRS, "Elixir of Ogre's Strength" },
        { 100047,  3593,  3825, HOUSE_UPGRADE_PAGE_ELIXIRS, "Elixir of Fortitude" },
        { 100048, 11328,  8949, HOUSE_UPGRADE_PAGE_ELIXIRS, "Elixir of Agility" },
        { 100049, 11349,  8951, HOUSE_UPGRADE_PAGE_ELIXIRS, "Elixir of Greater Defense" },
        { 100050, 11396,  9179, HOUSE_UPGRADE_PAGE_ELIXIRS, "Elixir of Greater Intellect" },
        { 100051, 11334,  9187, HOUSE_UPGRADE_PAGE_ELIXIRS, "Elixir of Greater Agility" },
        { 100052, 11405,  9206, HOUSE_UPGRADE_PAGE_ELIXIRS, "Elixir of Giants" },
        { 100053, 11348, 13445, HOUSE_UPGRADE_PAGE_ELIXIRS, "Elixir of Superior Defense" },
        { 100054, 17535, 13447, HOUSE_UPGRADE_PAGE_ELIXIRS, "Elixir of the Sages" },
        { 100055, 17537, 13453, HOUSE_UPGRADE_PAGE_ELIXIRS, "Elixir of Brute Force" },
        { 100056, 17538, 13452, HOUSE_UPGRADE_PAGE_ELIXIRS, "Elixir of the Mongoose" },
        { 100057,  3166,  3383, HOUSE_UPGRADE_PAGE_SPELL_ELIXIRS, "Elixir of Wisdom" },
        { 100058,  7844,  6373, HOUSE_UPGRADE_PAGE_SPELL_ELIXIRS, "Elixir of Firepower" },
        { 100059, 21920, 17708, HOUSE_UPGRADE_PAGE_SPELL_ELIXIRS, "Elixir of Frost Power" },
        { 100060, 11390,  9155, HOUSE_UPGRADE_PAGE_SPELL_ELIXIRS, "Arcane Elixir" },
        { 100061, 26276, 21546, HOUSE_UPGRADE_PAGE_SPELL_ELIXIRS, "Elixir of Greater Firepower" },
        { 100062, 56544, 55046, HOUSE_UPGRADE_PAGE_SPELL_ELIXIRS, "Elixir of Greater Frost Power" },
        { 100063, 56545, 55048, HOUSE_UPGRADE_PAGE_SPELL_ELIXIRS, "Elixir of Greater Arcane Power" },
        { 100064, 11474,  9264, HOUSE_UPGRADE_PAGE_SPELL_ELIXIRS, "Elixir of Shadow Power" },
        { 100065, 17539, 13454, HOUSE_UPGRADE_PAGE_SPELL_ELIXIRS, "Greater Arcane Elixir" },
        { 100066, 45988, 50237, HOUSE_UPGRADE_PAGE_SPELL_ELIXIRS, "Elixir of Greater Nature Power" },
        { 100067, 49010, 42185, HOUSE_UPGRADE_PAGE_SPELL_ELIXIRS, "Elixir of Mind's Reach" },
        { 100068,  7178,  5996, HOUSE_UPGRADE_PAGE_UTILITY, "Elixir of Water Breathing" },
        { 100069,  8212,  6662, HOUSE_UPGRADE_PAGE_UTILITY, "Elixir of Giant Growth" },
        { 100070, 11319,  8827, HOUSE_UPGRADE_PAGE_UTILITY, "Elixir of Water Walking" },
        { 100071,  6512,  3828, HOUSE_UPGRADE_PAGE_UTILITY, "Elixir of Detect Lesser Invisibility" },
        { 100072, 12608, 10592, HOUSE_UPGRADE_PAGE_UTILITY, "Catseye Elixir" },
        { 100073, 22807, 18294, HOUSE_UPGRADE_PAGE_UTILITY, "Elixir of Greater Water Breathing" },
        { 100074, 46102, 56113, HOUSE_UPGRADE_PAGE_UTILITY, "Elixir of Rapid Growth" },
        { 100075, 11389,  9154, HOUSE_UPGRADE_PAGE_UTILITY, "Elixir of Detect Undead" },
        { 100076, 11406,  9224, HOUSE_UPGRADE_PAGE_UTILITY, "Elixir of Demonslaying" },
        { 100077, 11407,  9233, HOUSE_UPGRADE_PAGE_UTILITY, "Elixir of Detect Demon" },
        { 100078,  3219,  3382, HOUSE_UPGRADE_PAGE_POTIONS, "Weak Troll's Blood Potion" },
        { 100079,  7245,  6051, HOUSE_UPGRADE_PAGE_POTIONS, "Holy Protection Potion" },
        { 100080,  3222,  3388, HOUSE_UPGRADE_PAGE_POTIONS, "Strong Troll's Blood Potion" },
        { 100081,  7242,  6048, HOUSE_UPGRADE_PAGE_POTIONS, "Shadow Protection Potion" },
        { 100082,  7233,  6049, HOUSE_UPGRADE_PAGE_POTIONS, "Fire Protection Potion" },
        { 100083,  3223,  3826, HOUSE_UPGRADE_PAGE_POTIONS, "Mighty Troll's Blood Potion" },
        { 100084,  7239,  6050, HOUSE_UPGRADE_PAGE_POTIONS, "Frost Protection Potion" },
        { 100085,  7254,  6052, HOUSE_UPGRADE_PAGE_POTIONS, "Nature Protection Potion" },
        { 100086, 24363, 20007, HOUSE_UPGRADE_PAGE_POTIONS, "Mageblood Potion" },
        { 100087, 17544, 13456, HOUSE_UPGRADE_PAGE_POTIONS, "Greater Frost Protection Potion" },
        { 100088, 17543, 13457, HOUSE_UPGRADE_PAGE_POTIONS, "Greater Fire Protection Potion" },
        { 100089, 17546, 13458, HOUSE_UPGRADE_PAGE_POTIONS, "Greater Nature Protection Potion" },
        { 100090, 17548, 13459, HOUSE_UPGRADE_PAGE_POTIONS, "Greater Shadow Protection Potion" },
        { 100091, 17545, 13460, HOUSE_UPGRADE_PAGE_POTIONS, "Greater Holy Protection Potion" },
        { 100092, 17549, 13461, HOUSE_UPGRADE_PAGE_POTIONS, "Greater Arcane Protection Potion" },
        { 100093, 24361, 20004, HOUSE_UPGRADE_PAGE_POTIONS, "Major Troll's Blood Potion" },
        { 100094, 17626, 13510, HOUSE_UPGRADE_PAGE_FLASKS, "Flask of the Titans" },
        { 100095, 17627, 13511, HOUSE_UPGRADE_PAGE_FLASKS, "Flask of Distilled Wisdom" },
        { 100096, 17628, 13512, HOUSE_UPGRADE_PAGE_FLASKS, "Flask of Supreme Power" },
        { 100097, 17629, 13513, HOUSE_UPGRADE_PAGE_FLASKS, "Flask of Chromatic Resistance" },
    };

    HouseBuff const* FindBuff(uint32 goEntry)
    {
        for (HouseBuff const& b : HOUSE_BUFFS)
            if (b.goEntry == goEntry)
                return &b;
        return nullptr;
    }

    HouseBuff const* FindBuffBySpell(uint32 spellId)
    {
        for (HouseBuff const& b : HOUSE_BUFFS)
            if (b.spellId == spellId)
                return &b;
        return nullptr;
    }

    bool IsFortune(HouseBuff const& b) { return b.page == HOUSE_UPGRADE_PAGE_FORTUNES; }
    bool IsFlask(HouseBuff const& b)   { return b.page == HOUSE_UPGRADE_PAGE_FLASKS; }

    // THE CAST BAR. A click starts 5017 "Divining Trance": 5 s, a white-gold
    // glow, effect 0 DUMMY, no reagent, no focus, and used by no item,
    // creature or script (the invasion sigil tried it first and left it for
    // the colour; see item_invasion_sigil.cpp). sql/custom/210 binds
    // spell_house_fortune to it.
    //
    // WHICH BUFF RIDES IN THE CAST ITSELF, as effect 0's base points: the
    // buff's spell id. Nothing is kept on the side, so there is no state
    // to clear when a cast is interrupted, and a cast of 5017 from anything
    // else carries the DBC's own base points, which name no fortune.
    uint32 const FORTUNE_CAST = 5017;

    // A POTION IS 46200 "Dummy Spell" instead: 5 s, effect 0 DUMMY, NO VISUAL,
    // movement interrupts it, and nothing else uses it. 5017's glow and
    // casting pose read wrong for a drink, and no spell in this client both
    // kneels and does nothing, so the script kneels the player for the length
    // of the cast (spell_house_potion) and stands them up when it ends either
    // way. The same base-point rule as 5017.
    uint32 const POTION_CAST = 46200;

    // ONE HOUSE BUFF AT A TIME: the spell each player last took from a house
    // object. A new one takes the old one off first. Kept here and not by
    // removing every spell in the table, because the same elixirs come out of
    // bags, and a click must not strip a raider's own Mongoose. Lost at a
    // restart, which leaves one stale buff to run out on its own.
    std::mutex s_lastBuffLock;
    std::map<uint32, uint32> s_lastBuff;

    int32 BuffDuration(HouseBuff const& b)
    {
        if (IsFortune(b))
            return FORTUNE_MS;
        SpellEntry const* info = sSpellMgr.GetSpellEntry(b.spellId);
        return info ? info->GetMaxDuration() : 0;
    }

    std::string DurationText(int32 ms)
    {
        uint32 const minutes = uint32(ms / MINUTE / IN_MILLISECONDS);
        std::ostringstream out;
        if (minutes && minutes % 60 == 0)
            out << minutes / 60 << (minutes == 60 ? " hour" : " hours");
        else
            out << minutes << (minutes == 1 ? " minute" : " minutes");
        return out.str();
    }

    // Everything that refuses a buff, asked at the click and again when the
    // cast ends. Empty means it may be taken.
    std::string RefuseBuff(Player* player, HouseBuff const& b)
    {
        if (b.item)
            if (ItemPrototype const* proto = sObjectMgr.GetItemPrototype(b.item))
                if (player->GetLevel() < proto->RequiredLevel)
                {
                    std::ostringstream out;
                    out << "You must be level " << proto->RequiredLevel << ".";
                    return out.str();
                }

        if (IsFlask(b) && player->HasSpellCooldown(FLASK_TIMER))
        {
            time_t const left = player->GetSpellCooldownDelay(FLASK_TIMER);
            std::ostringstream out;
            out << "You can take another flask in ";
            if (left >= HOUR)
                out << left / HOUR << " h " << (left % HOUR) / MINUTE << " min.";
            else
                out << (left + MINUTE - 1) / MINUTE << " min.";
            return out.str();
        }

        // A buff with more time left than this one gives is kept: a Faire
        // fortune, or the player's own elixir.
        int32 const duration = BuffDuration(b);
        if (SpellAuraHolder const* holder = player->GetSpellAuraHolder(b.spellId))
            if (holder->GetAuraDuration() > duration)
                return "You already have a longer one.";
        if (IsFortune(b))
            for (HouseBuff const& f : HOUSE_BUFFS)
                if (IsFortune(f))
                    if (SpellAuraHolder const* holder = player->GetSpellAuraHolder(f.spellId))
                        if (holder->GetAuraDuration() > FORTUNE_MS)
                            return "You already have a longer fortune.";

        return std::string();
    }

    void ApplyBuff(Player* player, HouseBuff const& b)
    {
        std::string const why = RefuseBuff(player, b);
        if (!why.empty())
        {
            ChatHandler(player).SendSysMessage(why.c_str());
            return;
        }

        uint32 last = 0;
        {
            std::lock_guard<std::mutex> guard(s_lastBuffLock);
            auto it = s_lastBuff.find(player->GetGUIDLow());
            if (it != s_lastBuff.end())
                last = it->second;
        }
        if (last)
            player->RemoveAurasDueToSpell(last);

        // Sayge's fortunes are one at a time at the Faire too.
        if (IsFortune(b))
            for (HouseBuff const& f : HOUSE_BUFFS)
                if (IsFortune(f))
                    player->RemoveAurasDueToSpell(f.spellId);

        // CAST, NOT ADDED, so the client plays the spell's own visual: the
        // glow of a Flask of the Titans, the Faire's fortune. Triggered, so it
        // is instant, free and skips the standing and reagent checks.
        // AddAura is the fallback for a spell the cast refuses.
        player->RemoveAurasDueToSpell(b.spellId);
        player->CastSpell(player, b.spellId, true);
        SpellAuraHolder* holder = player->GetSpellAuraHolder(b.spellId);
        if (!holder)
            holder = player->AddAura(b.spellId);
        if (!holder)
        {
            ChatHandler(player).SendSysMessage("That did not take.");
            return;
        }

        int32 const duration = BuffDuration(b);
        if (IsFortune(b))
        {
            // The same three calls MountRental makes to time a mount.
            holder->SetAuraMaxDuration(FORTUNE_MS);
            holder->SetAuraDuration(FORTUNE_MS);
            holder->UpdateAuraDuration();
        }

        if (IsFlask(b))
            player->AddSpellCooldown(FLASK_TIMER, 0, time(nullptr) + FLASK_COOLDOWN);

        {
            std::lock_guard<std::mutex> guard(s_lastBuffLock);
            s_lastBuff[player->GetGUIDLow()] = b.spellId;
        }

        ChatHandler(player).PSendSysMessage("%s for %s.", b.name, DurationText(duration).c_str());
    }

    // WHAT A FULL REPAIR COSTS, asked without repairing. Player::
    // DurabilityRepair charges item by item and returns 0 whatever it took,
    // and a player short of gold gets some items mended and some not. The
    // table quotes first and refuses when the gold is short, so it needs the
    // price on its own: the same formula over the same slots
    // (DurabilityRepairAll), with the same 1 copper floor per damaged item.
    // The playerbots' BudgetValues.cpp prices repairs the same way.
    uint32 RepairCost(Item const* item)
    {
        if (!item)
            return 0;

        uint32 const maxDurability = item->GetUInt32Value(ITEM_FIELD_MAXDURABILITY);
        uint32 const curDurability = item->GetUInt32Value(ITEM_FIELD_DURABILITY);
        if (!maxDurability || curDurability >= maxDurability)
            return 0;

        ItemPrototype const* proto = item->GetProto();
        DurabilityCostsEntry const* dcost = sDurabilityCostsStore.LookupEntry(proto->ItemLevel);
        DurabilityQualityEntry const* dquality = sDurabilityQualityStore.LookupEntry((proto->Quality + 1) * 2);
        if (!dcost || !dquality)
            return 0;   // DurabilityRepair refuses these too, with a log line

        uint32 const multiplier = dcost->multiplier[ItemSubClassToDurabilityMultiplierId(proto->Class, proto->SubClass)];
        uint32 const costs = uint32((maxDurability - curDurability) * multiplier * double(dquality->quality_mod));
        return costs ? costs : 1;
    }

    uint32 RepairAllCost(Player const* player)
    {
        uint32 total = 0;
        for (int i = EQUIPMENT_SLOT_START; i < INVENTORY_SLOT_ITEM_END; ++i)
            total += RepairCost(player->GetItemByPos(INVENTORY_SLOT_BAG_0, i));
        for (int j = INVENTORY_SLOT_BAG_START; j < INVENTORY_SLOT_BAG_END; ++j)
            for (int i = 0; i < MAX_BAG_SIZE; ++i)
                total += RepairCost(player->GetItemByPos(j, i));
        return total;
    }
}

//== HouseMgr ==================================================================

bool HouseMgr::IsDecorativeType(GameObjectInfo const* info)
{
    if (!info)
        return false;

    switch (info->type)
    {
        case GAMEOBJECT_TYPE_GENERIC:
        case GAMEOBJECT_TYPE_CHAIR:
        case GAMEOBJECT_TYPE_MAP_OBJECT:
            return true;
        default:
            return false;
    }
}

void HouseMgr::UpgradeItems(std::vector<uint32>& out) const
{
    // m_furnitureItems is a std::map, so this is item entry order.
    for (auto const& itr : m_furnitureItems)
    {
        GameObjectInfo const* info = sObjectMgr.GetGameObjectInfo(itr.second.goEntry);
        if (info && !IsDecorativeType(info))
            out.push_back(itr.first);
    }
}

uint32 HouseMgr::GetFurnitureGoEntry(uint32 itemEntry) const
{
    auto itr = m_furnitureItems.find(itemEntry);
    return itr != m_furnitureItems.end() ? itr->second.goEntry : 0;
}

uint32 HouseMgr::UpgradePage(uint32 itemEntry) const
{
    uint32 const goEntry = GetFurnitureGoEntry(itemEntry);
    GameObjectInfo const* info = sObjectMgr.GetGameObjectInfo(goEntry);
    if (info && info->type == GAMEOBJECT_TYPE_MAILBOX)
        return HOUSE_UPGRADE_PAGE_MAILBOXES;
    if (HouseBuff const* b = FindBuff(goEntry))
        return b->page;
    // Everything else is a tool: the repair table, Refreshments, the shops,
    // the crafting stations. A new upgrade lands here with no change.
    return HOUSE_UPGRADE_PAGE_TOOLS;
}

bool HouseMgr::BuyUpgrade(Player* player, uint32 itemEntry, std::string& error)
{
    std::vector<uint32> upgrades;
    UpgradeItems(upgrades);
    if (std::find(upgrades.begin(), upgrades.end(), itemEntry) == upgrades.end())
    {
        error = "That is not an upgrade.";
        return false;
    }

    ItemPrototype const* proto = sObjectMgr.GetItemPrototype(itemEntry);
    if (!proto)
    {
        error = "That is not an upgrade.";
        return false;
    }

    uint32 const price = proto->BuyPrice;
    if (player->GetMoney() < price)
    {
        error = "You need " + MoneyText(price) + ".";
        return false;
    }

    // BAGS FIRST, then the gold: a refusal must leave both where they were.
    ItemPosCountVec dest;
    if (player->CanStoreNewItem(NULL_BAG, NULL_SLOT, dest, itemEntry, 1) != EQUIP_ERR_OK)
    {
        error = "Your bags are full.";
        return false;
    }

    Item* given = player->StoreNewItem(dest, itemEntry, true);
    if (!given)
    {
        error = "Could not put that in your bags.";
        return false;
    }

    player->LogModifyMoney(-int32(price), "HouseUpgrade", ObjectGuid(), itemEntry);
    player->SendNewItem(given, 1, true, false);
    return true;
}

std::string HouseMgr::MoneyText(uint32 copper)
{
    uint32 const gold   = copper / 10000;
    uint32 const silver = (copper % 10000) / 100;
    uint32 const rest   = copper % 100;

    std::ostringstream out;
    if (gold)
        out << gold << "g";
    if (silver)
        out << (gold ? " " : "") << silver << "s";
    if (rest || (!gold && !silver))
        out << (gold || silver ? " " : "") << rest << "c";
    return out.str();
}

//== the repair table ==========================================================

static bool GOHello_go_house_repair(Player* player, GameObject* go)
{
    if (sHouseMgr.InEditSession(player, go->GetGUIDLow()))
        return false;

    uint32 const cost = RepairAllCost(player);
    if (!cost)
    {
        ChatHandler(player).SendSysMessage("Nothing needs repair.");
        return true;
    }

    GossipMenu& menu = player->PlayerTalkClass->GetGossipMenu();
    player->PlayerTalkClass->ClearMenus();

    std::string const label = "Repair all: " + HouseMgr::MoneyText(cost);
    menu.AddMenuItem(HOUSE_GOSSIP_ICON, label.c_str(), REPAIR_SENDER, ACT_REPAIR_ALL);
    menu.AddMenuItem(HOUSE_GOSSIP_ICON, "Close",       REPAIR_SENDER, ACT_REPAIR_CLOSE);

    player->PlayerTalkClass->SendGossipMenu(REPAIR_TEXT, go->GetObjectGuid());
    return true;
}

static bool GossipSelect_go_house_repair(Player* player, GameObject* go, uint32 sender, uint32 action)
{
    if (sender != REPAIR_SENDER)
        return false;

    player->PlayerTalkClass->CloseGossip();
    if (action != ACT_REPAIR_ALL)
        return true;

    // PRICED AGAIN ON THE CLICK. The menu is a photograph, and the player can
    // take a hit or swap gear between the draw and the click.
    uint32 const cost = RepairAllCost(player);
    if (!cost)
    {
        ChatHandler(player).SendSysMessage("Nothing needs repair.");
        return true;
    }

    if (player->GetMoney() < cost)
    {
        ChatHandler(player).PSendSysMessage("You need %s.", HouseMgr::MoneyText(cost).c_str());
        return true;
    }

    player->DurabilityRepairAll(true, 1.0f);
    go->PlayDistanceSound(REPAIR_SOUND);
    ChatHandler(player).PSendSysMessage("Repaired for %s.", HouseMgr::MoneyText(cost).c_str());
    return true;
}

//== the pantry ================================================================

static void SendPantryMain(Player* player, GameObject* go)
{
    GossipMenu& menu = player->PlayerTalkClass->GetGossipMenu();
    player->PlayerTalkClass->ClearMenus();

    menu.AddMenuItem(HOUSE_GOSSIP_ICON, "Drinks", PANTRY_SENDER, ACT_PANTRY_DRINKS);
    menu.AddMenuItem(HOUSE_GOSSIP_ICON, "Food",   PANTRY_SENDER, ACT_PANTRY_FOOD);
    menu.AddMenuItem(HOUSE_GOSSIP_ICON, "Close",  PANTRY_SENDER, ACT_PANTRY_CLOSE);

    player->PlayerTalkClass->SendGossipMenu(PANTRY_TEXT, go->GetObjectGuid());
}

// "Melon Juice (level 15): 5s". The action is the item entry, so a click
// names what it buys and needs no index.
static void SendPantryPage(Player* player, GameObject* go, uint32 const* items, size_t count)
{
    GossipMenu& menu = player->PlayerTalkClass->GetGossipMenu();
    player->PlayerTalkClass->ClearMenus();

    for (size_t i = 0; i < count; ++i)
    {
        ItemPrototype const* proto = sObjectMgr.GetItemPrototype(items[i]);
        if (!proto)
            continue;

        std::ostringstream label;
        label << proto->Name1 << " (level " << proto->RequiredLevel << "): "
              << HouseMgr::MoneyText(proto->BuyPrice);
        menu.AddMenuItem(HOUSE_GOSSIP_ICON, label.str().c_str(), PANTRY_SENDER, items[i]);
    }

    menu.AddMenuItem(HOUSE_GOSSIP_ICON, "Back", PANTRY_SENDER, ACT_PANTRY_MAIN);
    player->PlayerTalkClass->SendGossipMenu(PANTRY_TEXT, go->GetObjectGuid());
}

static bool InList(uint32 const* items, size_t count, uint32 entry)
{
    return std::find(items, items + count, entry) != items + count;
}

// Bags first, then the gold, the order BuyUpgrade uses: a refusal takes
// nothing.
static void BuyPantryItem(Player* player, uint32 entry)
{
    ItemPrototype const* proto = sObjectMgr.GetItemPrototype(entry);
    if (!proto)
        return;

    uint32 const amount = proto->BuyCount ? proto->BuyCount : 1;
    if (player->GetMoney() < proto->BuyPrice)
    {
        ChatHandler(player).PSendSysMessage("You need %s.", HouseMgr::MoneyText(proto->BuyPrice).c_str());
        return;
    }

    ItemPosCountVec dest;
    if (player->CanStoreNewItem(NULL_BAG, NULL_SLOT, dest, entry, amount) != EQUIP_ERR_OK)
    {
        ChatHandler(player).SendSysMessage("Your bags are full.");
        return;
    }

    Item* given = player->StoreNewItem(dest, entry, true);
    if (!given)
        return;

    player->LogModifyMoney(-int32(proto->BuyPrice), "HousePantry", ObjectGuid(), entry);
    player->SendNewItem(given, amount, true, false);
}

static bool GOHello_go_house_pantry(Player* player, GameObject* go)
{
    if (sHouseMgr.InEditSession(player, go->GetGUIDLow()))
        return false;

    SendPantryMain(player, go);
    return true;
}

static bool GossipSelect_go_house_pantry(Player* player, GameObject* go, uint32 sender, uint32 action)
{
    if (sender != PANTRY_SENDER)
        return false;

    size_t const drinks = sizeof(PANTRY_DRINKS) / sizeof(PANTRY_DRINKS[0]);
    size_t const food   = sizeof(PANTRY_FOOD) / sizeof(PANTRY_FOOD[0]);

    switch (action)
    {
        case ACT_PANTRY_DRINKS: SendPantryPage(player, go, PANTRY_DRINKS, drinks); return true;
        case ACT_PANTRY_FOOD:   SendPantryPage(player, go, PANTRY_FOOD, food);     return true;
        case ACT_PANTRY_MAIN:   SendPantryMain(player, go);                         return true;
        default: break;
    }

    // THE PAGE STAYS OPEN after a purchase, for the next five. The entry is
    // checked against the lists: it arrives off the wire.
    if (InList(PANTRY_DRINKS, drinks, action))
    {
        BuyPantryItem(player, action);
        SendPantryPage(player, go, PANTRY_DRINKS, drinks);
        return true;
    }
    if (InList(PANTRY_FOOD, food, action))
    {
        BuyPantryItem(player, action);
        SendPantryPage(player, go, PANTRY_FOOD, food);
        return true;
    }

    player->PlayerTalkClass->CloseGossip();
    return true;
}

//== the junk compactor ========================================================

// What a vendor would pay for the whole stack, or 0 when no vendor would take
// it. The same refusals and the same charge rule as HandleSellItemOpcode.
static uint32 CompactValue(Player* player, Item* item, char const*& why)
{
    why = "No merchant would buy that.";
    ItemPrototype const* proto = item->GetProto();
    if (!proto || !proto->SellPrice)
        return 0;

    if (item->GetOwnerGuid() != player->GetObjectGuid() || item->IsInTrade() ||
        player->GetLootGuid() == item->GetObjectGuid())
        return 0;

    if (item->IsBag() && !((Bag*)item)->IsEmpty())
    {
        why = "Empty the bag first.";
        return 0;
    }

    uint32 money = proto->SellPrice * item->GetCount();

    // An item that is used up by charges is worth what is left of them.
    for (int i = 0; i < MAX_ITEM_PROTO_SPELLS; ++i)
    {
        auto const& spell = proto->Spells[i];
        if (spell.SpellId && spell.SpellCharges < 0)
        {
            money = uint32(money * float(item->GetSpellCharges(i)) / spell.SpellCharges);
            break;
        }
    }

    if (uint64(player->GetMoney()) + money > MAX_MONEY_AMOUNT)
    {
        why = "You cannot carry more gold.";
        return 0;
    }
    return money;
}

// The item goes; there is no buyback, which is why ComfyUI asks before
// anything better than grey.
static void CompactSell(Player* player, Item* item, uint32 money)
{
    player->LogItem(item, LogItemAction::Sold);
    player->ItemRemovedQuestCheck(item->GetEntry(), item->GetCount());
    player->DestroyItem(item->GetBagSlot(), item->GetSlot(), true);
    player->LogModifyMoney(int32(money), "HouseCompactor", ObjectGuid(), 0);
}

// SPARKS ON A SALE: a stock object wearing the Lightning Bolt impact model
// (2001155, SPELLS\LightningBolt_Impact_Chest.mdx), summoned on the compactor
// for two seconds, and a gnome machine's sparks sound (SoundEntries 4902,
// GnomeRoboArmStandFidget01Sparks). An object, not a visual kit: no kit uses
// that model. The owner picked it from `.gobject tmpadd` trials, 2026-10-26.
uint32 const COMPACT_SPARKS       = 2001155;
uint32 const COMPACT_SPARKS_SECS  = 2;
uint32 const COMPACT_SOUND        = 4902;

static void CompactorSparks(GameObject* go)
{
    if (!go)
        return;
    go->SummonGameObject(COMPACT_SPARKS, go->GetPositionX(), go->GetPositionY(), go->GetPositionZ(),
                         go->GetOrientation(), 0, 0, 0, 0, COMPACT_SPARKS_SECS, false);
    go->PlayDistanceSound(COMPACT_SOUND);
}

static void StopCompacting(Player* player)
{
    {
        std::lock_guard<std::mutex> guard(s_compactingLock);
        s_compacting.erase(player->GetGUIDLow());
    }
    player->SendAddonMessage(COMPACT_PREFIX, "S");
}

static void SellAllGreys(Player* player, GameObject* go)
{
    uint32 sold = 0, total = 0;
    char const* why = nullptr;

    auto consider = [&](Item* item)
    {
        if (!item || item->GetProto()->Quality != ITEM_QUALITY_POOR)
            return;
        if (uint32 const money = CompactValue(player, item, why))
        {
            CompactSell(player, item, money);
            ++sold;
            total += money;
        }
    };

    for (uint8 i = INVENTORY_SLOT_ITEM_START; i < INVENTORY_SLOT_ITEM_END; ++i)
        consider(player->GetItemByPos(INVENTORY_SLOT_BAG_0, i));
    for (uint8 j = INVENTORY_SLOT_BAG_START; j < INVENTORY_SLOT_BAG_END; ++j)
        if (Bag* bag = (Bag*)player->GetItemByPos(INVENTORY_SLOT_BAG_0, j))
            for (uint8 i = 0; i < bag->GetBagSize(); ++i)
                consider(bag->GetItemByPos(i));

    if (sold)
    {
        CompactorSparks(go);
        ChatHandler(player).PSendSysMessage("Sold %u grey item%s for %s.", sold, sold == 1 ? "" : "s",
                                            HouseMgr::MoneyText(total).c_str());
    }
    else
        ChatHandler(player).SendSysMessage("Nothing grey to sell.");
}

static bool GOHello_go_house_compactor(Player* player, GameObject* go)
{
    if (sHouseMgr.InEditSession(player, go->GetGUIDLow()))
        return false;

    GossipMenu& menu = player->PlayerTalkClass->GetGossipMenu();
    player->PlayerTalkClass->ClearMenus();

    menu.AddMenuItem(HOUSE_GOSSIP_ICON, "Compact Item",        COMPACT_SENDER, ACT_COMPACT_PICK);
    menu.AddMenuItem(HOUSE_GOSSIP_ICON, "Sell all grey items", COMPACT_SENDER, ACT_COMPACT_GREYS);
    menu.AddMenuItem(HOUSE_GOSSIP_ICON, "Close",               COMPACT_SENDER, ACT_COMPACT_CLOSE);

    player->PlayerTalkClass->SendGossipMenu(COMPACT_TEXT, go->GetObjectGuid());
    return true;
}

static bool GossipSelect_go_house_compactor(Player* player, GameObject* go, uint32 sender, uint32 action)
{
    if (sender != COMPACT_SENDER)
        return false;

    player->PlayerTalkClass->CloseGossip();

    if (action == ACT_COMPACT_PICK)
    {
        {
            std::lock_guard<std::mutex> guard(s_compactingLock);
            s_compacting[player->GetGUIDLow()] = go->GetObjectGuid();
        }
        player->SendAddonMessage(COMPACT_PREFIX, "P");
    }
    else if (action == ACT_COMPACT_GREYS)
        SellAllGreys(player, go);

    return true;
}

// `.compact <bag> <slot>`, one per click in pick mode. The bag is the
// client's 0-4 and the slot counts from 1, as `.moonstone` takes them.
void HouseCompactItem(Player* player, uint32 bag, uint32 slot)
{
    ObjectGuid goGuid;
    {
        std::lock_guard<std::mutex> guard(s_compactingLock);
        auto it = s_compacting.find(player->GetGUIDLow());
        if (it != s_compacting.end())
            goGuid = it->second;
    }

    GameObject* go = goGuid ? player->GetMap()->GetGameObject(goGuid) : nullptr;
    if (!go || !player->IsWithinDistInMap(go, COMPACT_REACH))
    {
        StopCompacting(player);
        player->GetSession()->SendNotification("Use the Junk Compactor first.");
        return;
    }

    if (bag > 4 || !slot)
        return;
    uint8 const serverBag = bag ? uint8(INVENTORY_SLOT_BAG_START + bag - 1) : INVENTORY_SLOT_BAG_0;
    uint32 const serverSlot = bag ? slot - 1 : INVENTORY_SLOT_ITEM_START + slot - 1;
    if (!bag && serverSlot >= INVENTORY_SLOT_ITEM_END)
        return;

    Item* item = player->GetItemByPos(serverBag, uint8(serverSlot));
    if (!item)
        return;

    char const* why = nullptr;
    uint32 const money = CompactValue(player, item, why);
    if (!money)
    {
        player->GetSession()->SendNotification("%s", why);
        return;
    }

    std::string const name = item->GetProto()->Name1;
    uint32 const count = item->GetCount();
    CompactSell(player, item, money);
    CompactorSparks(go);

    if (count > 1)
        ChatHandler(player).PSendSysMessage("Sold %s x%u for %s.", name.c_str(), count, HouseMgr::MoneyText(money).c_str());
    else
        ChatHandler(player).PSendSysMessage("Sold %s for %s.", name.c_str(), HouseMgr::MoneyText(money).c_str());
}

//== the shops =================================================================

// AN OBJECT THAT OPENS A REAL VENDOR WINDOW. A list too long for a menu (the
// reagents) wants the window, and the window needs a creature: every vendor
// packet carries a creature guid and GetNPCIfCanInteractWith resolves it. So
// the object summons an invisible vendor on itself (model 11686, the trigger
// model) the first time it is clicked, and opens that vendor's window. The
// vendor stays SHOP_STAY_MS and is found again by the next click. It cannot be
// NOT_SELECTABLE: CanInteractWithNPC refuses such a unit.
//
// NOTHING CAN BE SOLD TO ONE: HandleSellItemOpcode asks HouseShopRefusesSales.
// The Junk Compactor is the house's way to sell.
namespace
{
    struct HouseShop
    {
        uint32 goEntry;
        uint32 vendorEntry;     // creature_template, its stock in npc_vendor
    };

    HouseShop const HOUSE_SHOPS[] =
    {
        { 100029, 100043 },     // Reagents: the class reagents (sql/custom/210)
        { 100030, 100044 },     // Magic Crafting Box: the trade supplies
    };

    uint32 const SHOP_STAY_MS = 30 * MINUTE * IN_MILLISECONDS;
}

bool HouseObjectInEditSession(Player* player, uint32 goGuidLow)
{
    return player && sHouseMgr.InEditSession(player, goGuidLow);
}

bool HouseShopRefusesSales(Creature const* vendor)
{
    if (vendor)
        for (HouseShop const& shop : HOUSE_SHOPS)
            if (shop.vendorEntry == vendor->GetEntry())
                return true;
    return false;
}

static bool GOHello_go_house_shop(Player* player, GameObject* go)
{
    if (sHouseMgr.InEditSession(player, go->GetGUIDLow()))
        return false;

    HouseShop const* shop = nullptr;
    for (HouseShop const& s : HOUSE_SHOPS)
        if (s.goEntry == go->GetEntry())
            shop = &s;
    if (!shop)
        return true;

    Creature* vendor = go->FindNearestCreature(shop->vendorEntry, 1.0f);
    if (!vendor)
        vendor = go->SummonCreature(shop->vendorEntry, go->GetPositionX(), go->GetPositionY(), go->GetPositionZ(),
                                    go->GetOrientation(), TEMPSUMMON_TIMED_DESPAWN, SHOP_STAY_MS);
    if (!vendor)
    {
        ChatHandler(player).SendSysMessage("The shop is closed.");
        return true;
    }

    player->GetSession()->SendListInventory(vendor->GetObjectGuid());
    return true;
}

//== the fortunes and the potions ==============================================

// THE CAST BAR'S WORD. The client names the bar from its own Spell.dbc, so
// ComfyUI (Cast.lua) renames "Divining Trance" to the word this sends on
// prefix CCAST just before the cast starts.
char const* const CAST_PREFIX = "CCAST";

// A click starts the cast; there is no menu. The refusals are asked here so
// the answer is instant, and again when the cast ends.
static bool StartBuffCast(Player* player, GameObject* go)
{
    if (sHouseMgr.InEditSession(player, go->GetGUIDLow()))
        return false;

    HouseBuff const* b = FindBuff(go->GetEntry());
    if (!b)
        return true;

    std::string const why = RefuseBuff(player, *b);
    if (!why.empty())
    {
        ChatHandler(player).SendSysMessage(why.c_str());
        return true;
    }

    player->SendAddonMessage(CAST_PREFIX, IsFortune(*b) ? "Reading" : "Drinking");

    // Not triggered, so it is a real cast: the bar, the visual, and an
    // interrupt when the player moves. A refusal (already casting, say) is
    // reported to the client by Spell::prepare.
    int32 const which = int32(b->spellId);
    player->CastCustomSpell(player, IsFortune(*b) ? FORTUNE_CAST : POTION_CAST, &which, nullptr, nullptr, false);
    return true;
}

static bool GOHello_go_house_fortune(Player* player, GameObject* go)
{
    return StartBuffCast(player, go);
}

static bool GOHello_go_house_potion(Player* player, GameObject* go)
{
    return StartBuffCast(player, go);
}

struct spell_house_fortune : public SpellScript
{
    // The dummy effect does nothing; the buff lands when the bar is full.
    bool OnEffectExecute(Spell* /*spell*/, SpellEffectIndex /*effIdx*/) const override
    {
        return false;
    }

    void OnSuccessfulFinish(Spell* spell) const override
    {
        Player* player = spell->m_casterUnit ? spell->m_casterUnit->ToPlayer() : nullptr;
        if (!player)
            return;

        if (HouseBuff const* b = FindBuffBySpell(uint32(spell->m_currentBasePoints[EFFECT_INDEX_0])))
            ApplyBuff(player, *b);
    }
};

// The fortune's script plus the kneel. OnFinish runs for a cast that ends
// either way, cancel() included, so the player never stays down.
struct spell_house_potion : public spell_house_fortune
{
    void OnSuccessfulStart(Spell* spell) const override
    {
        if (spell->m_casterUnit && FindBuffBySpell(uint32(spell->m_currentBasePoints[EFFECT_INDEX_0])))
            spell->m_casterUnit->SetStandState(UNIT_STAND_STATE_KNEEL);
    }

    void OnFinish(Spell* spell, bool /*ok*/) const override
    {
        if (spell->m_casterUnit && spell->m_casterUnit->GetStandState() == UNIT_STAND_STATE_KNEEL)
            spell->m_casterUnit->SetStandState(UNIT_STAND_STATE_STAND);
    }
};

static SpellScript* GetSpellScript_spell_house_fortune(SpellEntry const*)
{
    return new spell_house_fortune();
}

static SpellScript* GetSpellScript_spell_house_potion(SpellEntry const*)
{
    return new spell_house_potion();
}

void AddSC_house_upgrades()
{
    // pGOHello, not pGOGossipHello: the first fires before the goober state
    // machine, and returning true stops it closing the object (see
    // AddSC_house_control).
    Script* pNewScript = new Script;
    pNewScript->Name = "go_house_repair";
    pNewScript->pGOHello = &GOHello_go_house_repair;
    pNewScript->pGOGossipSelect = &GossipSelect_go_house_repair;
    pNewScript->RegisterSelf();

    pNewScript = new Script;
    pNewScript->Name = "go_house_fortune";
    pNewScript->pGOHello = &GOHello_go_house_fortune;
    pNewScript->RegisterSelf();

    pNewScript = new Script;
    pNewScript->Name = "go_house_potion";
    pNewScript->pGOHello = &GOHello_go_house_potion;
    pNewScript->RegisterSelf();

    pNewScript = new Script;
    pNewScript->Name = "go_house_shop";
    pNewScript->pGOHello = &GOHello_go_house_shop;
    pNewScript->RegisterSelf();

    pNewScript = new Script;
    pNewScript->Name = "go_house_pantry";
    pNewScript->pGOHello = &GOHello_go_house_pantry;
    pNewScript->pGOGossipSelect = &GossipSelect_go_house_pantry;
    pNewScript->RegisterSelf();

    pNewScript = new Script;
    pNewScript->Name = "go_house_compactor";
    pNewScript->pGOHello = &GOHello_go_house_compactor;
    pNewScript->pGOGossipSelect = &GossipSelect_go_house_compactor;
    pNewScript->RegisterSelf();

    pNewScript = new Script;
    pNewScript->Name = "spell_house_fortune";
    pNewScript->GetSpellScript = &GetSpellScript_spell_house_fortune;
    pNewScript->RegisterSelf();

    pNewScript = new Script;
    pNewScript->Name = "spell_house_potion";
    pNewScript->GetSpellScript = &GetSpellScript_spell_house_potion;
    pNewScript->RegisterSelf();
}
