#pragma once
#include "Action.h"
#include "Multiplier.h"

namespace ai
{
    class PassiveMultiplier : public Multiplier
    {
    public:
        PassiveMultiplier(PlayerbotAI* ai);

    public:
        virtual float GetValue(Action* action) override;

        // Is this action one of the few passive leaves alone?
        //
        // Public and static because a MULTIPLIER CANNOT ACTUALLY STOP ANYTHING.
        // Engine::DoNextAction only re-queues an action whose relevance dropped
        // when something still in the basket outranks it; when the zeroed action
        // is the last one left, nothing does, and it executes at relevance zero
        // anyway. Suppression therefore has to be enforced somewhere that can
        // say no - isUseful - and both places must agree on the same list, or
        // they drift. Same lesson PullMultiplier learned: a gate, not a weight.
        static bool Allows(const std::string& name);

    private:
        static void EnsureLists();

    private:
        static std::list<std::string> allowedActions;
        static std::list<std::string> allowedParts;
    };
}
