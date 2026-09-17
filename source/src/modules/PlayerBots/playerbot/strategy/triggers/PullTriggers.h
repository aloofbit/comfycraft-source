#pragma once
#include "playerbot/strategy/Trigger.h"
#include "playerbot/strategy/generic/PullStrategy.h"

namespace ai
{
    // One trigger per pull state. Each is a single test of GetPullState(), so
    // exactly one can be active on any tick - the whole point of the refactor.
    class PullStateTrigger : public Trigger
    {
    public:
        PullStateTrigger(PlayerbotAI* ai, std::string name, PullState state)
            : Trigger(ai, name), state(state) {}

        bool IsActive() override
        {
            const PullStrategy* strategy = PullStrategy::Get(ai);
            return strategy && strategy->GetPullState() == state;
        }

    private:
        PullState state;
    };

    class PullPrepareTrigger : public PullStateTrigger
    {
    public:
        PullPrepareTrigger(PlayerbotAI* ai) : PullStateTrigger(ai, "pull prepare", PullState::Preparing) {}
    };

    class PullStageTrigger : public PullStateTrigger
    {
    public:
        PullStageTrigger(PlayerbotAI* ai) : PullStateTrigger(ai, "pull stage", PullState::Staging) {}
    };

    class PullApproachTrigger : public PullStateTrigger
    {
    public:
        PullApproachTrigger(PlayerbotAI* ai) : PullStateTrigger(ai, "pull approach", PullState::Approaching) {}
    };

    class PullFireTrigger : public PullStateTrigger
    {
    public:
        PullFireTrigger(PlayerbotAI* ai) : PullStateTrigger(ai, "pull fire", PullState::Firing) {}
    };

    class PullReturnTrigger : public PullStateTrigger
    {
    public:
        PullReturnTrigger(PlayerbotAI* ai) : PullStateTrigger(ai, "pull return", PullState::Returning) {}
    };

    class PullHoldTrigger : public PullStateTrigger
    {
    public:
        PullHoldTrigger(PlayerbotAI* ai) : PullStateTrigger(ai, "pull hold", PullState::Holding) {}
    };

    class PullFinishTrigger : public PullStateTrigger
    {
    public:
        PullFinishTrigger(PlayerbotAI* ai) : PullStateTrigger(ai, "pull finish", PullState::Finishing) {}
    };

    // True when a tank in a dungeon group should start the next fight itself.
    class ShouldPullTrigger : public Trigger
    {
    public:
        ShouldPullTrigger(PlayerbotAI* ai) : Trigger(ai, "should pull", 5) {}

        bool IsActive() override;
    };
}
