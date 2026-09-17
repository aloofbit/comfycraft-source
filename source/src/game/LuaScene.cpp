/*
 * LuaScene -- see LuaScene.h for what this is and why it is this small.
 *
 * READING ORDER: the sandbox, then the handle, then the method tables (which
 * are the API and the place to add to it), then the state, then the scheduler.
 */

#include "LuaScene.h"
#include "BotNpc.h"
#include "Map.h"
#include "Player.h"
#include "Group.h"
#include "Creature.h"
#include "ObjectMgr.h"
#include "Log.h"
#include "World.h"
#include "Database/DatabaseEnv.h"
#include "DBCStores.h"
#include "MotionMaster.h"
#include "ModuleSlots.h"
#include <algorithm>
#include <list>
#include <vector>

/*
 * THE THREE HEADERS DIRECTLY, NOT lua.hpp.
 *
 * lua.hpp is four lines whose entire job is to wrap these in `extern "C"`, and
 * that is exactly wrong here: our Lua is COMPILED AS C++ (see
 * dep/lua/CMakeLists.txt on why), so its symbols have C++ linkage and declaring
 * them as C would fail to link with a wall of unresolved externals. The file is
 * not vendored, so this cannot be undone by accident.
 */
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"
#include <chrono>
#include <cstring>
#include <memory>
#include <mutex>
#include <new>
#include <vector>

/*
 * THE CURRENT BLOCK OF SCENES AND SPOTS. See LuaSceneData in the header on why
 * this is swapped whole rather than edited: map threads read it without a lock
 * and a reload comes from the world thread.
 */
static std::shared_ptr<LuaSceneData const> s_data = std::make_shared<LuaSceneData>();
static std::mutex s_dataLock;

std::shared_ptr<LuaSceneData const> LuaScene::Data()
{
    std::lock_guard<std::mutex> guard(s_dataLock);
    return s_data;
}

void LuaScene::LoadAll()
{
    auto fresh = std::make_shared<LuaSceneData>();
    {
        std::lock_guard<std::mutex> guard(s_dataLock);
        fresh->generation = s_data->generation + 1;
    }

    uint32 broken = 0;
    if (std::unique_ptr<QueryResult> res{ WorldDatabase.Query(
            "SELECT `id`, `source`, `error` FROM `dialog_lua`") })
    {
        do
        {
            Field* f = res->Fetch();
            uint32 const id = f[0].GetUInt32();
            std::string const src = f[1].GetCppString();

            /*
             * CHECKED AT LOAD, NOT AT PRESS. A script that will not compile is
             * a thing somebody wants to hear about now, while they are looking
             * at the editor, rather than in six weeks when a player presses the
             * button and nothing happens.
             *
             * It is still STORED. Refusing to load it would mean an unsaveable
             * typo silently unhooked a button; keeping it means the failure is
             * one line in the log and one broken scene.
             */
            std::string err;
            if (!Check(src, err))
            {
                sLog.outErrorDb("Table `dialog_lua` id %u will not compile: %s", id, err.c_str());
                ++broken;
            }

            /*
             * AND WRITTEN BACK INTO THE ROW, which is the only way the person
             * who typed it ever sees it. server\errors.log is not where an
             * author is looking; the editor is, and the editor reads this
             * column.
             *
             * Only when it CHANGED, so a reload of a healthy table is reads and
             * no writes. `error` is column 2.
             */
            std::string const was = f[2].GetCppString();
            if (was != err)
            {
                std::string safe = err;
                if (safe.size() > 255) safe.resize(255);
                WorldDatabase.escape_string(safe);
                WorldDatabase.PExecute("UPDATE `dialog_lua` SET `error` = '%s' WHERE `id` = %u",
                    safe.c_str(), id);
            }

            fresh->scripts[id] = src;
        } while (res->NextRow());
    }

    if (std::unique_ptr<QueryResult> res{ WorldDatabase.Query(
            "SELECT `name`, `map`, `x`, `y`, `z` FROM `dialog_spot`") })
    {
        do
        {
            Field* f = res->Fetch();
            LuaSpot sp;
            sp.map = f[1].GetUInt32();
            sp.x = f[2].GetFloat();
            sp.y = f[3].GetFloat();
            sp.z = f[4].GetFloat();
            fresh->spots[f[0].GetCppString()] = sp;
        } while (res->NextRow());
    }

    sLog.outString(">> Loaded %u dialog scene(s) and %u spot(s).",
        (uint32)fresh->scripts.size(), (uint32)fresh->spots.size());
    if (broken)
        sLog.outString(">> %u dialog scene(s) WILL NOT COMPILE -- see the errors above.", broken);

    std::lock_guard<std::mutex> guard(s_dataLock);
    s_data = fresh;
}

/*
 * =========================================================================
 *  THE SANDBOX
 * =========================================================================
 *
 * The strongest part of this is not in this file: `os`, `io` and `package` are
 * not COMPILED IN. See dep/lua/README-comfycraft.md. What is left here is the
 * base library, which arrives with a handful of things a scene has no business
 * with, and the two limits that stop a script hanging the map.
 *
 * KILLED FROM THE GLOBAL TABLE, and each for its own reason:
 *
 *   load, loadstring   compile a string, INCLUDING precompiled bytecode.
 *   dofile, loadfile   read a file off the disk. lauxlib is still compiled in,
 *                      so these would genuinely work.
 *   collectgarbage     can turn the collector off, which is the memory ceiling
 *                      turned off.
 *   rawequal/rawlen    harmless, kept.
 *   require            not compiled in, nil already, listed so a reader of this
 *                      list is not left wondering.
 *
 * `print` is NOT removed. It is redirected, below, to a whisper at the player
 * who pressed the button, because a scene you cannot debug from in game is a
 * scene you debug by rebuilding the server.
 */
static char const* const s_banished[] =
{
    "load", "loadstring", "dofile", "loadfile", "collectgarbage", "require",
    "module", "newproxy", nullptr
};

/*
 * Per-resume budget. Reset by Step, read by the hook.
 *
 * THREAD LOCAL, AND THAT IS NOT A DETAIL. Maps update in parallel here, so one
 * shared budget would have two maps running scenes at the same time resetting
 * and incrementing each other's counter -- which does not crash, it just stops
 * being a limit, at random, on a busy server. A hook has no user data pointer
 * to hang state off, so thread local is the way to give each map thread its
 * own; each one resumes exactly one script at a time.
 */
struct RunBudget
{
    uint32 instructions = 0;
    std::chrono::steady_clock::time_point started;
};
static thread_local RunBudget s_budget;

/*
 * THE INSTRUCTION HOOK IS THE ONLY THING BETWEEN A TYPO AND A HUNG SERVER.
 *
 * `while true do end` is four words and it runs on the map's update thread. No
 * amount of care about what the API exposes matters if that can be typed, so
 * this is checked every 10,000 VM instructions and the script is killed with an
 * ordinary Lua error, which unwinds through pcall like any other.
 *
 * The wall clock is here as well because instruction count is a poor proxy when
 * the instructions are expensive -- a string.rep in a loop does very little
 * counting and a great deal of work.
 */
static void CountHook(lua_State* L, lua_Debug* /*ar*/)
{
    s_budget.instructions += 10000;

    bool over = s_budget.instructions > LUA_INSTRUCTION_LIMIT;
    if (!over)
    {
        auto ms = std::chrono::duration_cast<std::chrono::milliseconds>(
            std::chrono::steady_clock::now() - s_budget.started).count();
        over = ms > LUA_WALL_MS_LIMIT;
    }

    if (over)
        luaL_error(L, "script ran too long and was stopped (a loop with no wait() in it?)");
}

/*
 * A CEILING ON MEMORY, because a script does not need a loop to take the
 * server down: `local t = {} while true do t[#t+1] = string.rep("x", 9999) end`
 * would be stopped by the hook above only after it had already asked for
 * gigabytes. Refusing the allocation makes Lua raise a normal out-of-memory
 * error instead.
 */
static void* LuaAlloc(void* ud, void* ptr, size_t osize, size_t nsize)
{
    size_t* used = static_cast<size_t*>(ud);

    if (nsize == 0)
    {
        if (ptr)
            *used -= osize;
        free(ptr);
        return nullptr;
    }

    size_t const after = *used - (ptr ? osize : 0) + nsize;
    if (after > LUA_MEMORY_LIMIT)
        return nullptr;

    void* np = realloc(ptr, nsize);
    if (!np)
        return nullptr;

    *used = after;
    return np;
}

/*
 * =========================================================================
 *  THE HANDLE
 * =========================================================================
 *
 * `npc` and `player` are a guid in a userdata and NOTHING ELSE. Every method
 * resolves it through the map on every call.
 *
 * That is not defensiveness, it is the only correct thing: a script that waits
 * ten seconds has given the world ten seconds to delete its NPC, log its player
 * out, or move either to another map. A cached Unit* would be a dangling
 * pointer and a crash dump; a guid is a lookup that returns nullptr and a call
 * that quietly does nothing, which is the right answer for a scene whose actor
 * has left.
 */
struct LuaHandle
{
    ObjectGuid guid;
};

static char const* const HANDLE_META = "comfy.unit";

static LuaHandle* CheckHandle(lua_State* L, int idx)
{
    return static_cast<LuaHandle*>(luaL_checkudata(L, idx, HANDLE_META));
}

// The map a script is running on, stashed in the registry when the state is
// made. A script can only ever touch its own map.
static Map* CurrentMap(lua_State* L)
{
    lua_getfield(L, LUA_REGISTRYINDEX, "comfy.map");
    Map* m = static_cast<Map*>(lua_touserdata(L, -1));
    lua_pop(L, 1);
    return m;
}

// And its LuaScene, for the one binding that has bookkeeping to do. Same
// registry, same lifetime: both outlive every coroutine in the state.
static LuaScene* CurrentScene(lua_State* L)
{
    lua_getfield(L, LUA_REGISTRYINDEX, "comfy.scene");
    LuaScene* s = static_cast<LuaScene*>(lua_touserdata(L, -1));
    lua_pop(L, 1);
    return s;
}

// nullptr whenever the thing has gone, which callers must all tolerate.
static Unit* Resolve(lua_State* L, int idx)
{
    LuaHandle* h = CheckHandle(L, idx);
    Map* map = CurrentMap(L);
    if (!map || h->guid.IsEmpty())
        return nullptr;
    return map->GetUnit(h->guid);
}

static Player* ResolvePlayer(lua_State* L, int idx)
{
    Unit* u = Resolve(L, idx);
    return (u && u->GetTypeId() == TYPEID_PLAYER) ? static_cast<Player*>(u) : nullptr;
}

static void PushHandle(lua_State* L, ObjectGuid guid)
{
    LuaHandle* h = static_cast<LuaHandle*>(lua_newuserdatauv(L, sizeof(LuaHandle), 0));
    new (h) LuaHandle{ guid };
    luaL_getmetatable(L, HANDLE_META);
    lua_setmetatable(L, -2);
}

/*
 * =========================================================================
 *  THE API
 * =========================================================================
 *
 * Every method a scene can call is a function here and a line in the table at
 * the bottom of this section. THAT TABLE IS THE API: adding to it is one line
 * and a function, and there is no other place to register anything, which is
 * the point of doing it this way rather than a pile of lua_register calls.
 *
 * The shape of all of them is the same: resolve, tolerate nothing being there,
 * do the smallest possible thing, return nothing. A method that cannot act
 * returns false rather than raising, because "the NPC you were talking to has
 * despawned" is a thing that happens in a live world and not a bug in the
 * script.
 *
 * ADDING ONE MEANS EDITING TWO OTHER PLACES, and nothing checks either:
 *
 *   website/lib/scenebrief.js   the brief handed to an AI on the scene page.
 *                               It promises this exact list, and a promise the
 *                               server cannot keep produces a scene that fails
 *                               when somebody presses the button.
 *   website/views/admin/scene.html   the short crib under "What is in scope".
 *
 * docs/ai/content/dialog-lua.md has the third copy, and is the least urgent:
 * a stale doc misleads a reader, a stale brief misleads a machine that will
 * confidently write against it.
 */

static int l_Say(lua_State* L)
{
    Unit* u = Resolve(L, 1);
    char const* text = luaL_checkstring(L, 2);
    if (!u) { lua_pushboolean(L, 0); return 1; }
    u->MonsterSay(text, LANG_UNIVERSAL, nullptr);
    lua_pushboolean(L, 1);
    return 1;
}

static int l_Yell(lua_State* L)
{
    Unit* u = Resolve(L, 1);
    char const* text = luaL_checkstring(L, 2);
    if (!u) { lua_pushboolean(L, 0); return 1; }
    u->MonsterYell(text, LANG_UNIVERSAL, nullptr);
    lua_pushboolean(L, 1);
    return 1;
}

static int l_Emote(lua_State* L)
{
    Unit* u = Resolve(L, 1);
    uint32 id = (uint32)luaL_checkinteger(L, 2);
    if (!u) { lua_pushboolean(L, 0); return 1; }
    // 0 is ONESHOT_NONE, the thing that clears a lasting emote, so it is a
    // legal argument and must not be rejected as "unset".
    if (id && !sEmotesStore.LookupEntry(id))
        return luaL_error(L, "there is no emote %d", (int)id);
    u->HandleEmote(id);
    lua_pushboolean(L, 1);
    return 1;
}

static int l_PlayEffect(lua_State* L)
{
    Unit* u = Resolve(L, 1);
    uint32 kit = (uint32)luaL_checkinteger(L, 2);
    if (!u) { lua_pushboolean(L, 0); return 1; }
    u->SendPlaySpellVisual(kit);
    lua_pushboolean(L, 1);
    return 1;
}

static int l_Cast(lua_State* L)
{
    Unit* caster = Resolve(L, 1);
    uint32 spell = (uint32)luaL_checkinteger(L, 2);
    if (!caster) { lua_pushboolean(L, 0); return 1; }
    if (!sSpellMgr.GetSpellEntry(spell))
        return luaL_error(L, "there is no spell %d", (int)spell);

    // Optional second unit, so npc:Cast(id) is "on itself" and
    // npc:Cast(id, player) is the usual thing a scene wants.
    Unit* victim = caster;
    if (!lua_isnoneornil(L, 3))
    {
        victim = Resolve(L, 3);
        if (!victim) { lua_pushboolean(L, 0); return 1; }
    }

    // Triggered, always. An NPC in a conversation has no business paying a
    // cast time or a mana cost, and a bot NPC has no mana bar to pay from.
    caster->CastSpell(victim, spell, true);
    lua_pushboolean(L, 1);
    return 1;
}

static int l_MoveTo(lua_State* L)
{
    Unit* u = Resolve(L, 1);
    float x = (float)luaL_checknumber(L, 2);
    float y = (float)luaL_checknumber(L, 3);
    float z = (float)luaL_checknumber(L, 4);
    bool run = lua_toboolean(L, 5) != 0;
    if (!u) { lua_pushboolean(L, 0); return 1; }

    // Same call SCRIPT_COMMAND_MOVE_TO makes, and the same reason it works on
    // a bot NPC: MonsterMoveWithSpeed is on Unit, not Creature.
    uint32 const options = MOVE_PATHFINDING | (run ? MOVE_RUN_MODE : MOVE_WALK_MODE);
    u->MonsterMoveWithSpeed(x, y, z, -10.0f, 0.0f, options);
    lua_pushboolean(L, 1);
    return 1;
}

/*
 * WalkTo("the fire") -- the same named places the dialog editor offers, read
 * out of dialog_spot. Named rather than numeric because three floats typed into
 * a script are three chances to send an NPC into a wall, and because a scene
 * that says "the fire" survives somebody moving the fire.
 *
 * The lookup is a query per call and that is fine: a scene walks somewhere a
 * handful of times, not in a loop, and caching it would mean a spot moved with
 * .spot did not take effect until a restart.
 */
static int l_WalkTo(lua_State* L)
{
    Unit* u = Resolve(L, 1);
    char const* name = luaL_checkstring(L, 2);
    bool run = lua_toboolean(L, 3) != 0;
    if (!u) { lua_pushboolean(L, 0); return 1; }

    /*
     * FROM MEMORY, NOT A QUERY. This is called from a script that may well be
     * in a loop, on the map's update thread, so a synchronous SELECT here would
     * be a way to stall every player on the map by writing a `for`.
     */
    auto data = LuaScene::Data();

    /*
     * ITS OWN SPOT FIRST. `.spot` saves "<NPC>: <name>" since 2026-09-16, so
     * Mother's scene says WalkTo("the fire") and means "Mother: the fire" --
     * which is what lets two NPCs each have a fire without either scene
     * spelling out whose. The exact name is the fallback, so a spot written the
     * long way, or one of the old unprefixed ones, still works.
     */
    auto it = data->spots.find(std::string(u->GetName()) + ": " + name);
    if (it == data->spots.end())
        it = data->spots.find(name);
    if (it == data->spots.end())
        return luaL_error(L, "there is no spot called \"%s\" (select the NPC and make one in game with .spot)", name);

    if (u->GetMapId() != it->second.map)
        return luaL_error(L, "\"%s\" is on map %d and this one is on map %d", name, (int)it->second.map, (int)u->GetMapId());

    uint32 const options = MOVE_PATHFINDING | (run ? MOVE_RUN_MODE : MOVE_WALK_MODE);
    u->MonsterMoveWithSpeed(it->second.x, it->second.y, it->second.z, -10.0f, 0.0f, options);
    lua_pushboolean(L, 1);
    return 1;
}

/*
 * WalkOffset(forward, right[, run]) -- so many yards ahead of and to the right
 * of the unit's POST, not of where it stands. 0, 0 is home.
 *
 * The same calculation SCRIPT_COMMAND_WALK_FROM_POST uses, from the same
 * function, so a timeline and a scene cannot disagree about where "two yards to
 * her left" is. BotNpc_PointFromPost has why it is the post, why the height is
 * searched from above, and which post a creature or a player has.
 *
 * Nothing to look up in memory and nothing that can be missing, which is the
 * difference from WalkTo: the only failure is a bot NPC standing on a map its
 * row does not name, and that answers false rather than stopping the scene.
 */
static int l_WalkOffset(lua_State* L)
{
    Unit* u = Resolve(L, 1);
    lua_Number forward = luaL_checknumber(L, 2);
    lua_Number right = luaL_optnumber(L, 3, 0.0);
    bool run = lua_toboolean(L, 4) != 0;
    if (!u) { lua_pushboolean(L, 0); return 1; }

    float x, y, z, o;
    if (!BotNpc_PointFromPost(u, float(forward), float(right), x, y, z, o))
    {
        lua_pushboolean(L, 0);
        return 1;
    }

    uint32 const options = MOVE_PATHFINDING | (run ? MOVE_RUN_MODE : MOVE_WALK_MODE);
    u->MonsterMoveWithSpeed(x, y, z, o, 0.0f, options);
    lua_pushboolean(L, 1);
    return 1;
}

/*
 * HideGossip / ShowGossip -- the NPC stops being clickable, then starts again.
 *
 * WHAT THIS IS ACTUALLY FOR: nothing else stops a scene being started twice.
 * There is no lock on a gossip script and no "already running" check anywhere,
 * so two players can press one button at the same moment and the NPC plays the
 * whole thing twice, overlapping itself. Estelle Gendry's shipped script opens
 * by removing her gossip flag and closes by putting it back, and that is the
 * answer the game itself has always used.
 *
 * THEY CLEAR THE WHOLE UNIT_NPC_FLAGS WORD, WHICH IS WIDER THAN THE NAME.
 *
 * The first version took UNIT_NPC_FLAG_GOSSIP off and nothing else, which is
 * what the name says and is not what anybody wants. Orcy is npc_flags 5 --
 * gossip plus vendor -- so he kept the vendor bit, and the client draws a
 * usable cursor from the flag whether or not there is any stock behind it. The
 * scene ran with the NPC still lit up and still clickable.
 *
 * Every bit in that field is another way in, and a scene that wants to be left
 * alone wants to be left alone. The names stay because "hide the gossip" is
 * what somebody writing a scene means by this, but they do the wider thing.
 *
 * HIDING IS REMEMBERED AND GIVEN BACK. See LuaScene::HiddenFlag: a scene can
 * end without reaching its last line, and an NPC left permanently unclickable
 * is a soft brick that needs a GM to unstick. So Step restores it whatever
 * happens -- an error, the instruction cap, a despawn, the map going away.
 *
 * On a BOT NPC this works for the same reason a bot NPC can be a questgiver at
 * all: UNIT_NPC_FLAGS is in Player::updateVisualBits, so a change to it
 * actually reaches the other clients. See content/playerbot-npcs.md.
 */
static int l_HideGossip(lua_State* L)
{
    Unit* u = Resolve(L, 1);
    if (!u) { lua_pushboolean(L, 0); return 1; }

    uint32 const was = u->GetUInt32Value(UNIT_NPC_FLAGS);
    u->SetUInt32Value(UNIT_NPC_FLAGS, UNIT_NPC_FLAG_NONE);

    if (LuaScene* sc = CurrentScene(L))
        sc->NoteHidden(L, CheckHandle(L, 1)->guid, was);

    lua_pushboolean(L, 1);
    return 1;
}

static int l_ShowGossip(lua_State* L)
{
    Unit* u = Resolve(L, 1);
    if (!u) { lua_pushboolean(L, 0); return 1; }

    LuaScene* sc = CurrentScene(L);
    ObjectGuid const guid = CheckHandle(L, 1)->guid;

    /*
     * PUT BACK WHAT IT HAD, if this run is the one that took it. Restoring the
     * remembered word rather than setting the gossip bit is what keeps a vendor
     * or a questgiver working afterwards.
     *
     * With nothing remembered -- a script that shows without hiding -- the
     * gossip bit alone is the only honest guess, and it is what the name says.
     */
    uint32 remembered = 0;
    bool const owed = sc && sc->TakeHidden(L, guid, remembered);
    if (owed)
        u->SetUInt32Value(UNIT_NPC_FLAGS, remembered);
    else
        u->SetFlag(UNIT_NPC_FLAGS, UNIT_NPC_FLAG_GOSSIP);

    lua_pushboolean(L, 1);
    return 1;
}

static int l_HasGossip(lua_State* L)
{
    Unit* u = Resolve(L, 1);
    lua_pushboolean(L, u && u->HasFlag(UNIT_NPC_FLAGS, UNIT_NPC_FLAG_GOSSIP));
    return 1;
}

/*
 * player:Party() -- everyone in the group, as handles, INCLUDING the caller.
 *
 * Including them is what makes the interesting test read plainly: somebody on
 * their own is a party of one, so `#player:Party() == 1` is "you came alone"
 * and no special case is needed for having no group at all.
 *
 * ONE BINDING RATHER THAN SIX. The obvious wants here are "is there a party",
 * "how many", "who is nearby", "buff them all" -- and every one of those is
 * this plus a `for` loop, because DistanceTo and Cast already take a handle.
 * A PartySize(), a PartyNear(yards) and a BuffParty() would each be a new
 * decision about whose distance, measured from whom, and this leaves all three
 * where the author can see them:
 *
 *     for _, m in ipairs(player:Party()) do
 *       if not m:IsGone() and m:DistanceTo(npc) <= 20 then ... end
 *     end
 *
 * HANDLES, NOT NAMES, and guids inside them like every other handle. A party
 * member can log out or walk onto another map mid-scene exactly as the two
 * principals can, and `IsGone()` is how a script notices. A member on another
 * map resolves to nothing, which is correct and not an error.
 *
 * ORDER IS THE GROUP'S OWN, which is the party frame's order, so a script that
 * picks `[1]` gets the leader's slot rather than something arbitrary.
 */
/*
 * WHO IS STANDING NEARBY, AS HANDLES, NEAREST FIRST.
 *
 * The other way to reach a second person is `player:Party()`, and it is no use
 * to a scene that was never given a player: a `custom` idle behaviour starts
 * with the NPC alone and nobody else in scope. Without this it can talk to
 * itself and walk about and nothing more.
 *
 * NEAREST FIRST IS A PROMISE, not an accident of the grid. `here[1]` is the
 * obvious thing to write and it should mean the person in front of the NPC
 * rather than whichever cell was visited first.
 *
 * REAL PLAYERS ONLY, the same set the `near` trigger fires on -- anything
 * carrying the bot module's AI slot is a companion, an alt bot or another bot
 * NPC, and an invisible GM is not somebody who walked up. Two names for one
 * idea is worse than either, so "a player nearby" means the same thing in a
 * scene as it does on the editor page.
 *
 * A grid search is not cheap the way `DistanceTo` is. The wall-clock half of
 * the budget is what stands behind calling it in a tight loop, because the
 * instruction count is a poor proxy for work this shape.
 */
static int l_PlayersNear(lua_State* L)
{
    Unit* self = Resolve(L, 1);
    lua_Number yards = luaL_optnumber(L, 2, 20.0);

    lua_newtable(L);
    if (!self)
        return 1;                                           // gone: nobody near

    if (yards < 1.0) yards = 1.0;
    if (yards > lua_Number(LUA_MAX_NEAR)) yards = lua_Number(LUA_MAX_NEAR);

    std::list<Player*> found;
    self->GetAlivePlayerListInRange(self, found, float(yards));

    std::vector<Player*> keep;
    for (Player* p : found)
    {
        if (!p || p == self || !p->IsInWorld())
            continue;
        if (p->GetModuleSlot(MODULE_SLOT_BOT_AI))
            continue;
        if (p->IsGameMaster() && !p->isGMVisible())
            continue;
        keep.push_back(p);
    }

    std::sort(keep.begin(), keep.end(), [self](Player* a, Player* b)
    {
        return self->GetDistance(a) < self->GetDistance(b);
    });

    int n = 0;
    for (Player* p : keep)
    {
        PushHandle(L, p->GetObjectGuid());
        lua_rawseti(L, -2, ++n);
    }
    return 1;
}

static int l_Party(lua_State* L)
{
    Player* p = ResolvePlayer(L, 1);
    lua_newtable(L);
    if (!p)
        return 1;                                           // an empty party

    Group* group = p->GetGroup();
    if (!group)
    {
        // Alone is a party of one, not an empty one. See the note above.
        PushHandle(L, p->GetObjectGuid());
        lua_rawseti(L, -2, 1);
        return 1;
    }

    int n = 0;
    for (Group::MemberSlot const& slot : group->GetMemberSlots())
    {
        PushHandle(L, slot.guid);
        lua_rawseti(L, -2, ++n);
    }
    return 1;
}

// Whether two units are in the same group. `npc:` is meaningless here and it is
// on the shared table anyway, so it reads as player:IsWith(someone).
static int l_IsWith(lua_State* L)
{
    Player* a = ResolvePlayer(L, 1);
    Player* b = ResolvePlayer(L, 2);
    lua_pushboolean(L, a && b && a->IsInGroup(b));
    return 1;
}

static int l_GiveItem(lua_State* L)
{
    Player* p = ResolvePlayer(L, 1);
    uint32 itemId = (uint32)luaL_checkinteger(L, 2);
    int32 count = (int32)luaL_optinteger(L, 3, 1);
    if (count < 1) count = 1;
    if (count > 100) count = 100;

    if (!p) { lua_pushboolean(L, 0); return 1; }
    if (!sObjectMgr.GetItemPrototype(itemId))
        return luaL_error(L, "there is no item %d", (int)itemId);

    ItemPosCountVec dest;
    if (p->CanStoreNewItem(NULL_BAG, NULL_SLOT, dest, itemId, count) != EQUIP_ERR_OK)
    {
        // A full bag is the player's problem and a normal outcome, not a
        // script error. Say so by returning false so a scene can react.
        lua_pushboolean(L, 0);
        return 1;
    }

    Item* item = p->StoreNewItem(dest, itemId, true, Item::GenerateItemRandomPropertyId(itemId));
    if (item)
        p->SendNewItem(item, count, true, false);
    lua_pushboolean(L, item != nullptr);
    return 1;
}

static int l_HasItem(lua_State* L)
{
    Player* p = ResolvePlayer(L, 1);
    uint32 itemId = (uint32)luaL_checkinteger(L, 2);
    uint32 count = (uint32)luaL_optinteger(L, 3, 1);
    lua_pushboolean(L, p && p->HasItemCount(itemId, count));
    return 1;
}

static int l_Distance(lua_State* L)
{
    Unit* a = Resolve(L, 1);
    Unit* b = Resolve(L, 2);
    lua_pushnumber(L, (a && b) ? a->GetDistance(b) : -1.0);
    return 1;
}

static int l_Gone(lua_State* L)
{
    lua_pushboolean(L, Resolve(L, 1) == nullptr);
    return 1;
}

/*
 * THE TABLE THAT IS THE API.
 *
 * One line per method. Both handles share it: an npc and a player are the same
 * kind of thing to every call above, and the ones that need a Player say so by
 * resolving to one and doing nothing when it is not.
 */
static const luaL_Reg s_unitMethods[] =
{
    { "Say",        l_Say },
    { "Yell",       l_Yell },
    { "Emote",      l_Emote },
    { "PlayEffect", l_PlayEffect },
    { "Cast",       l_Cast },
    { "MoveTo",     l_MoveTo },
    { "WalkTo",     l_WalkTo },
    { "WalkOffset", l_WalkOffset },
    { "GiveItem",   l_GiveItem },
    { "HasItem",    l_HasItem },
    { "DistanceTo", l_Distance },
    { "IsGone",     l_Gone },
    { "HideGossip", l_HideGossip },
    { "ShowGossip", l_ShowGossip },
    { "HasGossip",  l_HasGossip },
    { "Party",      l_Party },
    { "PlayersNear", l_PlayersNear },
    { "IsWith",     l_IsWith },
    { nullptr, nullptr }
};

/*
 * Read-only fields: `unit.name`, `unit.level`, `unit.hp`. Through __index so
 * that they read as properties rather than calls, which is what somebody
 * writing "thanks " .. player.name expects.
 */
static int l_Index(lua_State* L)
{
    char const* key = luaL_checkstring(L, 2);

    if (!strcmp(key, "name"))
    {
        Unit* u = Resolve(L, 1);
        lua_pushstring(L, u ? u->GetName() : "");
        return 1;
    }
    if (!strcmp(key, "level"))
    {
        Unit* u = Resolve(L, 1);
        lua_pushinteger(L, u ? u->GetLevel() : 0);
        return 1;
    }
    if (!strcmp(key, "hp"))
    {
        Unit* u = Resolve(L, 1);
        lua_pushinteger(L, u ? u->GetHealth() : 0);
        return 1;
    }

    // Otherwise a method off the shared table.
    luaL_getmetatable(L, HANDLE_META);
    lua_getfield(L, -1, "methods");
    lua_getfield(L, -1, key);
    return 1;
}

/*
 * wait(seconds) -- the whole reason a scene is readable.
 *
 * coroutine.yield, and the resume happens in LuaScene::Update. Everything
 * between two waits is one uninterrupted run charged against the instruction
 * budget; the waiting itself costs nothing at all.
 */
static int l_wait(lua_State* L)
{
    lua_Number secs = luaL_checknumber(L, 1);
    if (secs < 0) secs = 0;
    if (secs > LUA_MAX_WAIT)
        return luaL_error(L, "wait(%d) is longer than the %d second limit", (int)secs, (int)LUA_MAX_WAIT);

    // Whole seconds, because that is the resolution the map ticks scripts at
    // and pretending otherwise would round silently.
    lua_pushinteger(L, (lua_Integer)(secs + 0.5));
    return lua_yield(L, 1);
}

/*
 * print(...) -- whispered to the player who pressed the button.
 *
 * A scene you cannot debug from in game is a scene you debug by rebuilding the
 * server, so this is not a nicety. It goes nowhere if the player has left, and
 * it also goes to the log so an unattended one leaves a trace.
 */
static int l_print(lua_State* L)
{
    int const n = lua_gettop(L);
    std::string out;
    for (int i = 1; i <= n; i++)
    {
        if (i > 1) out += "  ";
        size_t len = 0;
        char const* s = luaL_tolstring(L, i, &len);
        out.append(s, len);
        lua_pop(L, 1);
    }
    if (out.size() > 255)
        out.resize(255);

    /*
     * WHOSE print THIS IS, as an upvalue rather than a global.
     *
     * Each run gets its own print closure carrying its own player guid. The
     * obvious alternative -- stash the current player somewhere shared and read
     * it here -- is wrong for exactly the reason the environment below is:
     * two scenes can be mid-run on one map at the same time, and the second one
     * to start would have redirected the first one's output to its own player.
     */
    LuaHandle* h = static_cast<LuaHandle*>(lua_touserdata(L, lua_upvalueindex(1)));
    Map* map = CurrentMap(L);
    if (h && map)
    {
        if (Player* p = map->GetPlayer(h->guid))
            p->MonsterWhisper(out.c_str(), p, false);
    }
    sLog.outString("[lua] %s", out.c_str());
    return 0;
}

/*
 * =========================================================================
 *  THE STATE
 * =========================================================================
 */

LuaScene::LuaScene(Map* map) : m_map(map)
{
    m_L = lua_newstate(LuaAlloc, &m_allocated);
    if (!m_L)
    {
        sLog.outError("LuaScene: could not create a state for map %u.", map ? map->GetId() : 0);
        return;
    }

    // Exactly these, opened by hand. There is no luaL_openlibs call here on
    // purpose -- see dep/lua/README-comfycraft.md on why linit.c is not even
    // compiled in. A new library is a decision, not a default.
    luaL_requiref(m_L, LUA_GNAME, luaopen_base, 1);      lua_pop(m_L, 1);
    luaL_requiref(m_L, LUA_TABLIBNAME, luaopen_table, 1); lua_pop(m_L, 1);
    luaL_requiref(m_L, LUA_STRLIBNAME, luaopen_string, 1); lua_pop(m_L, 1);
    luaL_requiref(m_L, LUA_MATHLIBNAME, luaopen_math, 1); lua_pop(m_L, 1);
    luaL_requiref(m_L, LUA_COLIBNAME, luaopen_coroutine, 1); lua_pop(m_L, 1);
    luaL_requiref(m_L, LUA_UTF8LIBNAME, luaopen_utf8, 1); lua_pop(m_L, 1);

    for (int i = 0; s_banished[i]; i++)
    {
        lua_pushnil(m_L);
        lua_setglobal(m_L, s_banished[i]);
    }

    lua_pushcfunction(m_L, l_wait);
    lua_setglobal(m_L, "wait");
    lua_pushcfunction(m_L, l_print);
    lua_setglobal(m_L, "print");

    /*
     * The emote ids a scene is most likely to want, by name. Not the whole of
     * Emotes.dbc: this is the same curated handful the editor offers, and a
     * number still works for anything else.
     */
    struct { char const* name; int id; } consts[] =
    {
        { "BOW", 2 }, { "WAVE", 3 }, { "CHEER", 4 }, { "TALK", 1 },
        { "LAUGH", 11 }, { "KNEEL", 68 }, { "STAND", 0 }, { "DANCE", 10 },
        { "SIT", 13 }, { "SLEEP", 12 }, { "POINT", 25 }, { "APPLAUD", 21 },
        { "SALUTE", 66 }, { "ROAR", 15 }, { "CRY", 18 }, { "FLEX", 23 },
        { "SHY", 24 }, { "NO", 274 }, { "YES", 273 }, { "WORK", 28 },
        { nullptr, 0 }
    };
    for (int i = 0; consts[i].name; i++)
    {
        lua_pushinteger(m_L, consts[i].id);
        lua_setglobal(m_L, consts[i].name);
    }

    // The handle metatable, built once from the method table above.
    luaL_newmetatable(m_L, HANDLE_META);
    lua_newtable(m_L);
    luaL_setfuncs(m_L, s_unitMethods, 0);
    lua_setfield(m_L, -2, "methods");
    lua_pushcfunction(m_L, l_Index);
    lua_setfield(m_L, -2, "__index");
    // No __newindex: a script must not be able to hang state off a handle and
    // expect it to still be there after a wait, since the handle is rebuilt.
    lua_pushstring(m_L, "locked");
    lua_setfield(m_L, -2, "__metatable");
    lua_pop(m_L, 1);

    lua_pushlightuserdata(m_L, m_map);
    lua_setfield(m_L, LUA_REGISTRYINDEX, "comfy.map");
    lua_pushlightuserdata(m_L, this);
    lua_setfield(m_L, LUA_REGISTRYINDEX, "comfy.scene");
}

LuaScene::~LuaScene()
{
    if (m_L)
        lua_close(m_L);
}

bool LuaScene::Check(std::string const& source, std::string& error)
{
    // A throwaway state with nothing in it. This only has to PARSE, and doing
    // it in the map's own state would leave a compiled chunk behind on every
    // failed edit.
    lua_State* L = luaL_newstate();
    if (!L)
    {
        error = "out of memory";
        return false;
    }

    // "t" is text only. Refusing precompiled bytecode matters even here: the
    // loader is not hardened against malformed bytecode and never was.
    int const rc = luaL_loadbufferx(L, source.c_str(), source.size(), "=scene", "t");
    if (rc != LUA_OK)
    {
        char const* msg = lua_tostring(L, -1);
        error = msg ? msg : "would not compile";
        lua_close(L);
        return false;
    }
    lua_close(L);
    error.clear();
    return true;
}

/*
 * COMPILED FRESH ON EVERY RUN, and the cache that used to be here was a bug
 * rather than an optimisation.
 *
 * A compiled chunk is a CLOSURE, and a closure's first upvalue is its _ENV.
 * Handing each run its own environment therefore means writing to the closure,
 * and a cached closure is shared -- so a second scene starting while a first
 * was mid-wait would have redirected the first one's `npc` to its own. Caching
 * would only be correct with a fresh closure per run, which is what loading
 * fresh already gives.
 *
 * The cost is a parse of a few hundred bytes, which is nothing beside the
 * gossip click that got here.
 */
bool LuaScene::Run(uint32 scriptId, std::string const& source, char const* name,
                   ObjectGuid npc, ObjectGuid player)
{
    if (!m_L)
        return false;

    lua_State* thread = lua_newthread(m_L);
    int const threadRef = luaL_ref(m_L, LUA_REGISTRYINDEX);   // pops the thread

    std::string chunkName = std::string("=") + (name ? name : "scene");
    // "t" is text only. Refusing precompiled bytecode matters: Lua's loader is
    // not hardened against malformed bytecode and never claimed to be.
    if (luaL_loadbufferx(thread, source.c_str(), source.size(), chunkName.c_str(), "t") != LUA_OK)
    {
        sLog.outError("LuaScene: scene %u will not compile: %s", scriptId, lua_tostring(thread, -1));
        luaL_unref(m_L, LUA_REGISTRYINDEX, threadRef);
        return false;
    }

    /*
     * ITS OWN ENVIRONMENT, falling back to the shared globals.
     *
     * Two things come out of this. Concurrency: `npc` and `player` are per run,
     * so two scenes on one map cannot see each other's. And isolation: a script
     * that assigns to a name it never declared local gets a global in ITS table
     * and nobody else's, so a typo cannot leak across conversations or outlive
     * the scene that made it.
     *
     * __index to the real globals is what keeps string, math, table and wait
     * available without copying them per run.
     */
    lua_newtable(thread);                                    // env
    PushHandle(thread, npc);
    lua_setfield(thread, -2, "npc");
    PushHandle(thread, player);
    lua_setfield(thread, -2, "player");

    // print carries its own player, for the same reason env exists.
    PushHandle(thread, player);
    lua_pushcclosure(thread, l_print, 1);
    lua_setfield(thread, -2, "print");

    /*
     * _G POINTS AT THE SCRIPT'S OWN TABLE, not the real globals.
     *
     * Without this the isolation above has a hole straight through it:
     * luaopen_base puts `_G` in the shared globals, __index would find it, and
     * `_G.npc` or `_G.whatever = 1` would be reading and writing the table every
     * scene on this map shares. Pointing it at the environment keeps the idiom
     * working and keeps the promise.
     */
    lua_pushvalue(thread, -1);
    lua_setfield(thread, -2, "_G");

    lua_newtable(thread);                                    // its metatable
    lua_rawgeti(thread, LUA_REGISTRYINDEX, LUA_RIDX_GLOBALS);
    lua_setfield(thread, -2, "__index");
    lua_setmetatable(thread, -2);

    // _ENV is upvalue 1 of any main chunk. setupvalue pops it.
    if (!lua_setupvalue(thread, -2, 1))
    {
        sLog.outError("LuaScene: scene %u has no _ENV upvalue, which should be impossible.", scriptId);
        lua_pop(thread, 2);
        luaL_unref(m_L, LUA_REGISTRYINDEX, threadRef);
        return false;
    }

    Parked p{ threadRef, npc, player, scriptId };
    Step(p, 0);
    return true;
}

/*
 * ONE RESUME. Either the script finished, or it asked to wait, or it broke.
 *
 * The budget is reset here rather than at Run, so a scene that waits is not
 * charged for the time it spent waiting -- which is the whole point of it
 * having waited.
 */
void LuaScene::Step(Parked const& p, int nargs)
{
    lua_rawgeti(m_L, LUA_REGISTRYINDEX, p.threadRef);
    lua_State* thread = lua_tothread(m_L, -1);
    lua_pop(m_L, 1);
    if (!thread)
        return;

    s_budget.instructions = 0;
    s_budget.started = std::chrono::steady_clock::now();
    lua_sethook(thread, CountHook, LUA_MASKCOUNT, 10000);

    int results = 0;
    int const rc = lua_resume(thread, m_L, nargs, &results);
    lua_sethook(thread, nullptr, 0, 0);

    if (rc == LUA_YIELD)
    {
        lua_Integer secs = (results > 0 && lua_isinteger(thread, -1)) ? lua_tointeger(thread, -1) : 0;
        lua_pop(thread, results);
        if (secs < 0) secs = 0;
        if (secs > (lua_Integer)LUA_MAX_WAIT) secs = LUA_MAX_WAIT;

        m_waiting.emplace(time_t(sWorld.GetGameTime() + secs), p);
        return;
    }

    if (rc != LUA_OK)
    {
        char const* msg = lua_tostring(thread, -1);
        sLog.outError("LuaScene: script %u stopped: %s", p.scriptId, msg ? msg : "unknown error");

        // And tell whoever pressed the button, because they are the one who can
        // fix it and the server log is not where they are looking.
        if (m_map)
        {
            if (Player* pl = m_map->GetPlayer(p.player))
            {
                std::string say = std::string("Script error: ") + (msg ? msg : "unknown");
                if (say.size() > 255) say.resize(255);
                pl->MonsterWhisper(say.c_str(), pl, false);
            }
        }
    }

    // Whatever it hid, it owes back -- and this is below the error branch on
    // purpose, so a script that threw halfway is not the one case that leaks.
    RestoreFlags(thread);
    Drop(p);
}

/*
 * ONE ENTRY PER UNIT, NOT ONE PER CALL. A scene in a loop calling HideGossip on
 * the same NPC twice owes exactly one restore, and the FIRST word it recorded
 * is the true one -- by the second call the flags are already zero, and
 * remembering that would restore nothing at all.
 */
void LuaScene::NoteHidden(lua_State* thread, ObjectGuid guid, uint32 flags)
{
    auto& list = m_hidden[thread];
    for (HiddenFlag const& f : list)
        if (f.guid == guid)
            return;
    list.push_back(HiddenFlag{ guid, flags });
}

// What this run owes for that unit, and the debt is settled by asking.
bool LuaScene::TakeHidden(lua_State* thread, ObjectGuid guid, uint32& flags)
{
    auto it = m_hidden.find(thread);
    if (it == m_hidden.end())
        return false;

    for (size_t i = 0; i < it->second.size(); i++)
    {
        if (it->second[i].guid != guid)
            continue;
        flags = it->second[i].flags;
        it->second.erase(it->second.begin() + i);
        if (it->second.empty())
            m_hidden.erase(it);
        return true;
    }
    return false;
}

void LuaScene::RestoreFlags(lua_State* thread)
{
    auto it = m_hidden.find(thread);
    if (it == m_hidden.end())
        return;

    for (HiddenFlag const& f : it->second)
    {
        // Gone is fine and common: a creature that despawned and came back is
        // holding whatever its template says, which is where it started.
        if (m_map)
        {
            if (Unit* u = m_map->GetUnit(f.guid))
                u->SetUInt32Value(UNIT_NPC_FLAGS, f.flags);
        }
    }
    m_hidden.erase(it);
}

void LuaScene::Drop(Parked const& p)
{
    luaL_unref(m_L, LUA_REGISTRYINDEX, p.threadRef);
}

bool LuaScene::IsRunningFor(ObjectGuid npc, uint32 sceneId) const
{
    for (auto const& parked : m_waiting)
        if (parked.second.npc == npc && (!sceneId || parked.second.scriptId == sceneId))
            return true;
    return false;
}

uint32 LuaScene::StopFor(ObjectGuid npc, uint32 sceneId)
{
    if (!m_L)
        return 0;

    uint32 dropped = 0;
    for (auto it = m_waiting.begin(); it != m_waiting.end(); )
    {
        if (it->second.npc != npc || (sceneId && it->second.scriptId != sceneId))
        {
            ++it;
            continue;
        }

        /*
         * WHATEVER IT HID COMES BACK, exactly as it would if the scene had
         * ended on its own. Step does this below its error branch for the same
         * reason: the case that stops early must not be the one case that
         * leaves an NPC permanently unclickable.
         */
        lua_rawgeti(m_L, LUA_REGISTRYINDEX, it->second.threadRef);
        if (lua_State* thread = lua_tothread(m_L, -1))
            RestoreFlags(thread);
        lua_pop(m_L, 1);

        Drop(it->second);
        it = m_waiting.erase(it);
        ++dropped;
    }
    return dropped;
}

void LuaScene::Update()
{
    if (!m_L || m_waiting.empty())
        return;

    time_t const now = sWorld.GetGameTime();

    /*
     * TAKEN OFF THE QUEUE BEFORE IT RUNS, and that is not tidiness. Resuming a
     * script can park it again -- a scene is usually a row of waits -- which
     * would be inserting into the container being iterated.
     */
    std::vector<Parked> due;
    for (auto it = m_waiting.begin(); it != m_waiting.end() && it->first <= now; )
    {
        due.push_back(it->second);
        it = m_waiting.erase(it);
    }

    for (Parked const& p : due)
        Step(p, 0);
}
