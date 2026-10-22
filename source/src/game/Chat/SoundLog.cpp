#include "SoundLog.h"
#include "ComfyCommands.h"
#include "Chat.h"
#include "World.h"
#include "WorldSession.h"
#include "WorldPacket.h"
#include "Player.h"
#include "GameObject.h"
#include "Map.h"
#include <cstdio>
#include <mutex>
#include <set>
#include <unordered_map>

std::atomic<uint32> SoundLog::sWatchers{0};

namespace
{
    std::mutex sLock;
    std::set<uint32> sAccounts;

    // Names from SoundEntries.dbc, read on the first .soundlog on. The core
    // does not load this DBC. An id the server's copy lacks (Turtle's patches
    // add some) prints with no name.
    std::unordered_map<uint32, std::string> sNames;
    bool sNamesLoaded = false;

    void LoadNames()
    {
        sNamesLoaded = true;
        std::string const path = sWorld.GetDataPath() + "dbc/SoundEntries.dbc";
        FILE* f = fopen(path.c_str(), "rb");
        if (!f)
            return;

        uint32 header[5];
        if (fread(header, 4, 5, f) == 5 && header[0] == 0x43424457)  // 'WDBC'
        {
            uint32 const records = header[1], recordSize = header[3], stringSize = header[4];
            std::vector<uint8> data(size_t(records) * recordSize + stringSize);
            if (fread(data.data(), 1, data.size(), f) == data.size())
            {
                char const* strings = reinterpret_cast<char const*>(data.data() + size_t(records) * recordSize);
                for (uint32 i = 0; i < records; ++i)
                {
                    uint32 const* row = reinterpret_cast<uint32 const*>(data.data() + size_t(i) * recordSize);
                    if (row[2] < stringSize)                     // field 2 is the name
                        sNames[row[0]] = strings + row[2];
                }
            }
        }
        fclose(f);
    }

    std::string SoundName(uint32 id)
    {
        std::lock_guard<std::mutex> guard(sLock);
        auto const itr = sNames.find(id);
        return itr == sNames.end() ? std::string() : " " + itr->second;
    }

    // "Fishing Bobber (Chiro), 32 yd", or the guid when the object is not on your map.
    std::string Source(Player* me, ObjectGuid guid)
    {
        WorldObject* obj = me->GetMap() ? me->GetMap()->GetWorldObject(guid) : nullptr;
        if (!obj)
            return guid.GetString();

        std::string text = obj->GetName();
        if (GameObject* go = obj->ToGameObject())
            if (Unit* owner = go->GetOwner())
                text += std::string(" (") + owner->GetName() + ")";

        char dist[32];
        snprintf(dist, sizeof(dist), ", %.0f yd", me->GetDistance(obj));
        return text + dist;
    }
}

void SoundLog::OnSend(WorldSession* session, WorldPacket const& packet)
{
    uint16 const opcode = packet.GetOpcode();
    if (opcode != SMSG_PLAY_OBJECT_SOUND && opcode != SMSG_PLAY_SOUND && opcode != SMSG_PLAY_MUSIC &&
        opcode != SMSG_GAMEOBJECT_CUSTOM_ANIM)
        return;

    {
        std::lock_guard<std::mutex> guard(sLock);
        if (!sAccounts.count(session->GetAccountId()))
            return;
    }

    Player* me = session->GetPlayer();
    if (!me || !me->IsInWorld())
        return;

    std::string line;
    switch (opcode)
    {
        case SMSG_PLAY_OBJECT_SOUND:
        {
            uint32 const id = packet.read<uint32>(0);
            line = "Sound " + std::to_string(id) + SoundName(id) + ": " + Source(me, ObjectGuid(packet.read<uint64>(4)));
            break;
        }
        case SMSG_PLAY_SOUND:
        {
            uint32 const id = packet.read<uint32>(0);
            line = "Sound " + std::to_string(id) + SoundName(id) + ": no source";
            break;
        }
        case SMSG_PLAY_MUSIC:
            line = "Music " + std::to_string(packet.read<uint32>(0));
            break;
        case SMSG_GAMEOBJECT_CUSTOM_ANIM:
            // The client plays the display's custom sound with this, as the
            // fishing bobber's splash does.
            line = "Anim " + std::to_string(packet.read<uint32>(8)) + ": " + Source(me, ObjectGuid(packet.read<uint64>(0)));
            break;
    }

    ChatHandler(session).SendSysMessage(line.c_str());
}

// .soundlog [on | off]: for your account until a restart.
bool ComfyCommands::HandleSoundLogCommand(ChatHandler* handler, char* args)
{
    WorldSession* session = handler->m_session;
    if (!session)
        return false;

    std::string const arg = args ? args : "";
    if (!arg.empty() && arg != "on" && arg != "off")
    {
        handler->SendSysMessage(".soundlog [on | off]");
        handler->SetSentErrorMessage(true);
        return false;
    }

    bool on;
    {
        std::lock_guard<std::mutex> guard(sLock);
        uint32 const account = session->GetAccountId();
        if (arg == "on" && !sAccounts.count(account))
        {
            if (!sNamesLoaded)
                LoadNames();
            sAccounts.insert(account);
        }
        else if (arg == "off")
            sAccounts.erase(account);
        SoundLog::sWatchers.store(uint32(sAccounts.size()), std::memory_order_relaxed);
        on = sAccounts.count(account) != 0;
    }

    handler->PSendSysMessage("Sound log %s.", on ? "on" : "off");
    return true;
}
