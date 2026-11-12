#pragma once

#include "WorldPosition.h"
#include "Maps/PathFinder.h"

class Player;
class Unit;

namespace ai
{
    class Action;

    // THE ONE SPOT TEST (2026-11-05, the owner).
    //
    // A healer used to have four movers: flee, the heal walk, avoid patrol and the walk
    // to a wand target. Each had its own distance, its own sight test and its own idea
    // of a safe place, and none knew the others. One walked it to a spot, the next
    // called that spot bad and walked it back. Now one test says if the place a healer
    // stands is good, and one chooser picks where to go when it is not. `healer move`
    // is the only combat mover. The old triggers are false for a LedHealer.
    //
    //   Good: it sees its patient in heal range, it is 10 yd from the fight, out of
    //   the aggro of mobs not in the fight, and out of area damage.
    //
    // The owner's order of work sits on top of the test:
    //   - A heal that comes first (patient under 60%, in range and in sight): no move.
    //   - A mob on the healer: it stands for the tank, in area damage too. It still
    //     walks for sight of a patient. The mob comes with it, toward the tank.
    //   - Under 40% with no mob on it: danger counts before any heal.
    enum class HealerFault : uint8
    {
        None,
        Area,       // in hostile area damage
        Fight,      // a mob in the fight under 10 yd
        Idle,       // in reach of a mob that is not in the fight
        Range,      // a patient worth walking to, past heal range
        Sight       // a patient worth walking to, out of sight
    };

    const char* HealerFaultName(HealerFault fault);

    // A mob that runs: a low health flee, fear, or the run for help. It has no target and
    // hits nobody. The core does not call AttackStop for it, so it stays on its victim's
    // attacker list until the run ends. A healer ignores it (2026-11-05, the owner).
    bool MobFleeing(Unit* unit);

    // The first mob on this healer that is not fleeing, or nullptr.
    Unit* MobOnHealer(Player* bot);

    // A healer led by a real player, on the player's map. The rules here are for this
    // healer. Any other healer keeps the old movers.
    bool LedHealer(PlayerbotAI* ai);

    // What is wrong with the place the healer stands now.
    HealerFault HealerSpotFault(PlayerbotAI* ai);

    // HealerSpotFault, less the holds on `healer move`: a walk under way, a search that
    // found no spot in the last 3 s, and two walks in the last 7 s.
    bool HealerWantsToMove(PlayerbotAI* ai);

    // The nearest spot that passes the test, with a walk that stays clear of mobs. For a
    // patient out of sight or out of range: first the points along the path to it, so
    // the walk ends at first sight. Then short steps from where the healer stands, then
    // rings around the owner and a player patient. The smallest move wins, so the walk
    // limit of each pass comes before its margins. False when no spot passes. The
    // healer then stays where it is.
    bool FindHealerSpot(PlayerbotAI* ai, HealerFault fault, float& rx, float& ry, float& rz, std::string& note);

    // True while a healer walks to its spot, and the engine then holds its spells and
    // moves. A walk for sight stops here, the moment the fault clears.
    bool HealerWalkingOut(PlayerbotAI* ai);

    // What an engine may still run while HealerWalkingOut is true.
    bool AllowedWhileHealerWalksOut(PlayerbotAI* ai, Action* action);

    // The nearest a walk along a path comes to (x, y), in 2D, from the bot to the spot
    // (toX, toY, toZ). nearest, if given, gets that point on the walk.
    float WalkGap(Player* bot, PathFinder const& path, float toX, float toY, float toZ, float x, float y, float* nearest = nullptr);

    // How near a walk may come to the player or a mob in the fight. A bot that starts
    // nearer may not get nearer.
    const float WALK_CLEAR = 8.0f;
}
