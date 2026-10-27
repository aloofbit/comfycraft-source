#include "CreatureSpawnFaction.h"
#include "Chat/Chat.h"
#include "Chat/ComfyCommands.h"
#include "Creature.h"
#include "Database/DatabaseEnv.h"
#include "Language.h"
#include "Log.h"
#include "ObjectMgr.h"
#include "World.h"

#include <cstring>
#include <memory>
#include <mutex>

CreatureSpawnFaction sCreatureSpawnFaction;

void CreatureSpawnFaction::LoadFromDB()
{
    std::unique_lock<std::shared_mutex> guard(m_lock);
    m_factions.clear();

    std::unique_ptr<QueryResult> result(WorldDatabase.Query("SELECT `guid`, `faction` FROM `creature_spawn_faction`"));
    if (result)
    {
        do
        {
            Field* fields = result->Fetch();
            m_factions[fields[0].GetUInt32()] = fields[1].GetUInt32();
        } while (result->NextRow());
    }

    sLog.outString(">> Loaded %u saved creature spawn faction(s)", uint32(m_factions.size()));
}

uint32 CreatureSpawnFaction::GetFaction(Creature const* creature) const
{
    uint32 const fallback = creature->GetCreatureInfo()->faction;

    // A summon has a guid of its own that is no spawn's.
    if (!creature->HasStaticDBSpawnData())
        return fallback;

    uint32 const saved = GetSaved(creature->GetGUIDLow());
    return saved ? saved : fallback;
}

uint32 CreatureSpawnFaction::GetSaved(uint32 spawnGuid) const
{
    std::shared_lock<std::shared_mutex> guard(m_lock);
    auto itr = m_factions.find(spawnGuid);
    return itr != m_factions.end() ? itr->second : 0;
}

void CreatureSpawnFaction::Save(uint32 spawnGuid, uint32 faction)
{
    {
        std::unique_lock<std::shared_mutex> guard(m_lock);
        m_factions[spawnGuid] = faction;
    }
    sWorld.ExecuteUpdate("REPLACE INTO `creature_spawn_faction` (`guid`, `faction`) VALUES (%u, %u)", spawnGuid, faction);
}

void CreatureSpawnFaction::Remove(uint32 spawnGuid)
{
    {
        std::unique_lock<std::shared_mutex> guard(m_lock);
        m_factions.erase(spawnGuid);
    }
    sWorld.ExecuteUpdate("DELETE FROM `creature_spawn_faction` WHERE `guid` = %u", spawnGuid);
}

void CreatureSpawnFaction::Forget(uint32 spawnGuid)
{
    std::unique_lock<std::shared_mutex> guard(m_lock);
    m_factions.erase(spawnGuid);
}

// .npc savefaction [<faction> | off]
//
// No argument: the selected spawn's faction and where it comes from. A
// faction: set now and saved for this spawn. off: the saved faction is
// deleted and the template's comes back. 35 is friendly to everyone, which
// makes an NPC that nobody can attack.
bool ComfyCommands::HandleNpcSaveFactionCommand(ChatHandler* handler, char* args)
{
    Creature* creature = handler->GetSelectedCreature();
    if (!creature)
    {
        handler->SendSysMessage(LANG_SELECT_CREATURE);
        handler->SetSentErrorMessage(true);
        return false;
    }

    if (!creature->HasStaticDBSpawnData())
    {
        handler->PSendSysMessage("%s is not a saved spawn, so it cannot keep a faction.", creature->GetName());
        handler->SetSentErrorMessage(true);
        return false;
    }

    uint32 const guid     = creature->GetGUIDLow();
    uint32 const template_ = creature->GetCreatureInfo()->faction;
    uint32 const saved    = sCreatureSpawnFaction.GetSaved(guid);

    while (*args == ' ')
        ++args;

    if (!*args)
    {
        if (saved)
            handler->PSendSysMessage("%s (guid %u): faction %u, saved. Template: %u.", creature->GetName(), guid, saved, template_);
        else
            handler->PSendSysMessage("%s (guid %u): faction %u, from the template.", creature->GetName(), guid, template_);
        return true;
    }

    if (strncmp(args, "off", 3) == 0)
    {
        if (!saved)
        {
            handler->PSendSysMessage("%s (guid %u) has no saved faction.", creature->GetName(), guid);
            return true;
        }

        sWorld.GetMigration().SetAuthor(handler->GetSession() ? handler->GetSession()->GetUsername() : "console");
        sCreatureSpawnFaction.Remove(guid);
        creature->SetFactionTemplateId(template_);
        handler->PSendSysMessage("%s (guid %u): saved faction removed, back to %u.", creature->GetName(), guid, template_);
        return true;
    }

    uint32 faction;
    if (!handler->ExtractUInt32(&args, faction))
        return false;

    if (!sObjectMgr.GetFactionTemplateEntry(faction))
    {
        handler->PSendSysMessage(LANG_WRONG_FACTION, faction);
        handler->SetSentErrorMessage(true);
        return false;
    }

    sWorld.GetMigration().SetAuthor(handler->GetSession() ? handler->GetSession()->GetUsername() : "console");
    sCreatureSpawnFaction.Save(guid, faction);
    creature->SetFactionTemplateId(faction);
    handler->PSendSysMessage("%s (guid %u): faction %u saved.", creature->GetName(), guid, faction);
    return true;
}
