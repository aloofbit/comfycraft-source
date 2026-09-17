/*
 * LuaScene -- a small, sandboxed Lua for gossip scenes.
 *
 * WHAT THIS IS FOR. A gossip button can already give, cast, emote, speak and
 * walk, each on a second of its own. That covers a scene a person can write as
 * a list. It does not cover one with a loop, a condition, a variable, or a line
 * that depends on who pressed the button -- and writing "wait two" between
 * every pair of rows stops being the clearest way to say a thing at about the
 * eighth row.
 *
 *     npc:WalkTo("the fire")
 *     wait(10)
 *     npc:Emote(KNEEL)
 *     wait(4)
 *     npc:Say("wow that fire is hot")
 *     npc:Emote(STAND)
 *     npc:WalkTo("his usual place")
 *     wait(6)
 *     npc:Say("That was an excellent adventure, thanks " .. player.name)
 *
 * WHAT IT IS DELIBERATELY NOT. This is not Eluna and should not grow into it.
 * There are no event hooks, no access to the world at large, no way to reach a
 * unit that is not the two this script was started with. The API is a list in
 * LuaScene.cpp and every entry on it was a decision.
 *
 * ------------------------------------------------------------------ THREADING
 *
 * ONE STATE PER MAP, CREATED ON FIRST USE. Maps update in parallel here, so a
 * single global state would need a lock around every call and would serialise
 * two unrelated conversations on opposite sides of the world. Most maps never
 * run a script at all and never pay for one.
 *
 * Everything below runs on the map's own update thread, inside Map::Update.
 * That is also why the instruction cap is not optional: a script that loops for
 * ever does not hang itself, it hangs the map, and with it every player on it.
 *
 * --------------------------------------------------------------------- WAITING
 *
 * `wait(n)` is `coroutine.yield(n)`. The thread is parked in the state's
 * registry (which is what keeps it from being collected) and resumed by
 * LuaScene::Update when its time comes. So a script reads top to bottom and
 * costs nothing while it waits.
 *
 * A PARKED SCRIPT HOLDS NO POINTERS. npc and player are ObjectGuids resolved on
 * every single call, because ten seconds is long enough for an NPC to die or a
 * player to log out, and a stale Unit* would be a crash rather than a mistake.
 * A call whose subject has gone simply does nothing.
 */

#ifndef COMFY_LUASCENE_H
#define COMFY_LUASCENE_H

#include "Common.h"
#include "ObjectGuid.h"
#include <map>
#include <memory>
#include <string>
#include <unordered_map>
#include <vector>

struct lua_State;
class Map;

// Where a named place is. dialog_spot, in memory.
struct LuaSpot
{
    uint32 map;
    float x, y, z;
};

/*
 * EVERY SCENE AND EVERY SPOT, AS ONE IMMUTABLE BLOCK.
 *
 * Maps update in PARALLEL here, so `reload dialog_scenes` cannot edit a
 * container that a map thread may be reading -- that is a data race and the
 * kind that works in testing. So a reload builds a whole new block and swaps
 * the pointer; a reader takes a copy of the shared_ptr and keeps the block it
 * started with alive until it is done with it.
 *
 * `generation` is how a LuaScene knows its compiled chunks are stale: the
 * source behind them may have changed, and a chunk compiled from the old text
 * would keep running for ever otherwise.
 */
struct LuaSceneData
{
    std::unordered_map<uint32, std::string> scripts;        // dialog_lua.id -> source
    std::unordered_map<std::string, LuaSpot> spots;         // dialog_spot.name -> where
    uint32 generation = 0;
};

// What a running script is allowed to spend before it is killed. Both are
// per-RESUME, not per-script: a scene that waits is not being charged for the
// time it spent waiting.
//
// 20 million VM instructions is far past any honest scene and reached in well
// under a second, and the wall clock is the backstop for the case where the
// instructions are individually expensive.
static constexpr uint32 LUA_INSTRUCTION_LIMIT = 20000000;
static constexpr uint32 LUA_WALL_MS_LIMIT = 500;

// The whole state, all scripts on this map together.
static constexpr size_t LUA_MEMORY_LIMIT = 16 * 1024 * 1024;

// How long a scene may wait in one go, and how long it may run in total. The
// same 300 seconds the editor caps a timeline at, and for the same reason:
// nothing cancels a scene except the script's own end.
static constexpr uint32 LUA_MAX_WAIT = 300;

/*
 * HOW FAR `PlayersNear` MAY LOOK.
 *
 * A grid search is bounded by its range, so an unbounded one is a way to make
 * the map thread walk every cell it owns from inside a loop. 100 yards is well
 * past anything an NPC can plausibly notice and short of the cell size the
 * search visits in one go.
 */
static constexpr float LUA_MAX_NEAR = 100.0f;

class LuaScene
{
    public:
        explicit LuaScene(Map* map);
        ~LuaScene();

        // Start `source` with these two as npc and player. `name` is what an
        // error message calls the script. Returns false and logs if it would
        // not compile or threw on its first step.
        bool Run(uint32 scriptId, std::string const& source, char const* name,
                 ObjectGuid npc, ObjectGuid player);

        // Resume whatever is due. Called once per map tick.
        void Update();

        // Does it compile? Used by the loader so a broken script is found at
        // reload rather than when somebody presses the button. Fills `error`.
        static bool Check(std::string const& source, std::string& error);

        // Read dialog_lua and dialog_spot into a fresh block and swap it in.
        // Startup and `reload dialog_scenes`, both on the world thread.
        static void LoadAll();

        // The current block, safe to hold across anything.
        static std::shared_ptr<LuaSceneData const> Data();

        /*
         * IS ANY SCENE STILL GOING FOR THIS NPC.
         *
         * Asked by BotNpcIdle, whose `custom` behaviour is a scene that loops:
         * "is it still going" is the only question the driver ever has about
         * one. Only PARKED threads are counted, which is every live scene as
         * far as anyone outside can tell -- a scene runs to its next wait()
         * synchronously, on this same thread, so between two ticks it is either
         * parked or finished.
         */
        bool IsRunningFor(ObjectGuid npc, uint32 sceneId = 0) const;

        /*
         * DROP EVERY SCENE RUNNING FOR THIS NPC, and give back whatever they
         * hid. Returns how many.
         *
         * Starting a second copy of a looping scene over the first is the
         * failure this exists to prevent: nothing else in here cancels a scene,
         * so two would run for ever, saying everything twice.
         *
         * A SCENE ID NARROWS IT, and the caller that has one should pass it: a
         * bot NPC can have a conversation scene running from a gossip button at
         * the same time as its own idle loop, and restarting the loop is no
         * reason to cut somebody off mid-sentence. 0 means every scene on it,
         * which is what an NPC being taken out of the world wants.
         */
        uint32 StopFor(ObjectGuid npc, uint32 sceneId = 0);

    public:
        /*
         * A UNIT THIS RUN MADE UNCLICKABLE, AND THE WHOLE FLAGS WORD IT HAD.
         *
         * Hiding an NPC for the length of a scene is the thing that stops two
         * people starting it at once. It is also the easiest way to leave one
         * permanently unclickable, because a scene can end without reaching its
         * last line: an error, the instruction cap, a despawn. So nothing a
         * script hides stays hidden -- Step gives it back when the run ENDS,
         * however it ends.
         *
         * THE WHOLE WORD, NOT THE GOSSIP BIT. The first version cleared
         * UNIT_NPC_FLAG_GOSSIP alone and that is not the same as "cannot be
         * interacted with": Orcy is npc_flags 5, gossip plus vendor, so he kept
         * the vendor bit and the client kept drawing a usable cursor over him
         * for the whole scene. Every other bit in that field is another way in.
         *
         * Storing the value rather than a set of bits is also what makes the
         * restore exact. Putting a flag back that the unit never had would be a
         * different bug in the same place.
         */
        struct HiddenFlag
        {
            ObjectGuid guid;
            uint32 flags;                                   // what to put back
        };

        // Called by the bindings, which have a coroutine and nothing else.
        void NoteHidden(lua_State* thread, ObjectGuid guid, uint32 flags);
        bool TakeHidden(lua_State* thread, ObjectGuid guid, uint32& flags);

    private:
        void RestoreFlags(lua_State* thread);

        struct Parked
        {
            int threadRef;                                  // registry ref, keeps it alive
            ObjectGuid npc;
            ObjectGuid player;
            uint32 scriptId;
        };

        // Push the thread on, resume it, and either park it again or let it go.
        void Step(Parked const& p, int nargs);
        void Drop(Parked const& p);

        Map* m_map;
        lua_State* m_L = nullptr;
        size_t m_allocated = 0;

        // When to resume what. A multimap because two scenes may come due in
        // the same second and both should run.
        std::multimap<time_t, Parked> m_waiting;

        // What each running coroutine has hidden and owes back. Keyed by the
        // thread because that is the only handle a binding function has.
        std::unordered_map<lua_State*, std::vector<HiddenFlag>> m_hidden;

        friend struct LuaSceneAccess;
};

#endif
