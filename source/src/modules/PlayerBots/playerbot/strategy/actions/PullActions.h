#pragma once
#include "GenericSpellActions.h"
#include "GenericActions.h"

namespace ai
{
    // Triggers gate PUSHING an action, not executing it, and the action queue
    // outlives the tick that filled it. So a pull action pushed while its state
    // was current can still pop a tick or two later, once the pull has moved
    // on - and then act on a state that has already passed.
    //
    // That is not theoretical: "pull approach" popping after the state had
    // become Firing hit its "in position and cannot fire" branch and converted
    // every ranged pull into a body pull. Each pull action re-checks its own
    // state, so a stale entry is simply useless rather than wrong.
    bool PullStateIs(PlayerbotAI* ai, PullState state);

    class PullRequestAction : public ChatCommandAction
    {
    public:
        PullRequestAction(PlayerbotAI* ai, std::string name) : ChatCommandAction(ai, name) {}

    protected:
        virtual bool Execute(Event& event) override;
        virtual Unit* GetTarget(Event& event) = 0;
    };

    class PullMyTargetAction : public PullRequestAction
    {
    public:
        PullMyTargetAction(PlayerbotAI* ai) : PullRequestAction(ai, "pull my target") {}
    
    private:
        Unit* GetTarget(Event& event) override;
    };

    class PullRTITargetAction : public PullRequestAction
    {
    public:
        PullRTITargetAction(PlayerbotAI* ai) : PullRequestAction(ai, "pull rti target") {}

    private:
        Unit* GetTarget(Event& event) override;
    };

    // Picks its own target instead of being handed one by a chat command, so a
    // tank can start a fight nobody asked it to start. Everything after the
    // target choice is the existing pull path.
    class PullNearestTargetAction : public PullRequestAction
    {
    public:
        PullNearestTargetAction(PlayerbotAI* ai) : PullRequestAction(ai, "pull nearest target") {}

        // Shared with ShouldPullTrigger: asking "is there anything to pull" and
        // "what do we pull" with two different pieces of code is how they drift
        // apart.
        static Unit* FindPullTarget(PlayerbotAI* ai);

    private:
        Unit* GetTarget(Event& event) override;
    };

    class PullStartAction : public Action
    {
    public:
        PullStartAction(PlayerbotAI* ai, std::string name = "pull start") : Action(ai, name) {}
        bool Execute(Event& event) override;
    };

    class PullAction : public CastSpellAction
    {
    public:
        PullAction(PlayerbotAI* ai, std::string name = "pull action");
        bool Execute(Event& event) override;
        bool isPossible() override;
    private:
        void InitPullAction();
        std::string GetTargetName() override { return "pull target"; }
        // NO reach prerequisite. "pull approach" owns getting into position;
        // this action only fires.
        //
        // Leaving it as "reach pull" was silently fatal once movement was gated
        // in MovementAction::isUseful: CastSpellAction pushes its reach action
        // as a PREREQUISITE, the gate allows only the pull's own movers, and
        // "reach pull" is not one of them any more - so the prerequisite could
        // never be satisfied, and the engine re-queued "pull action" forever
        // without ever casting. The tank walked to its firing position, never
        // shot, and eventually went home.
        std::string GetReachActionName() override { return ""; }
    };

    // Gets the bot to somewhere the pull can be made from - the firing spot for
    // a ranged pull, or into aggro range for a body pull.
    //
    // Replaces the old "reach pull" prerequisite chain. That was a CastSpellAction
    // prerequisite, which meant the approach and the shot were two actions with
    // two ideas of "close enough" and no way to make them agree; between the two
    // thresholds they fought, one stopping the bot and the other starting it.
    // One action owning the whole approach cannot disagree with itself.
    class PullApproachAction : public MovementAction
    {
    public:
        PullApproachAction(PlayerbotAI* ai) : MovementAction(ai, "pull approach") {}
        bool Execute(Event& event) override;
        bool isUseful() override { return PullStateIs(ai, PullState::Approaching); }
    };

    // Stand on the anchor and let them come to you.
    //
    // The step that makes a pull worth doing: without it the tank is a mob taxi
    // that keeps driving, and the group never gets the fight where it set up
    // for it. Ends early the moment something is actually in melee, because by
    // then the hold has done its job and waiting longer only delays the fight.
    class PullHoldAction : public MovementAction
    {
    public:
        PullHoldAction(PlayerbotAI* ai) : MovementAction(ai, "pull hold") {}
        bool Execute(Event& event) override;
        bool isUseful() override { return PullStateIs(ai, PullState::Holding); }
    };

    class PullEndAction : public Action
    {
    public:
        PullEndAction(PlayerbotAI* ai, std::string name = "pull end") : Action(ai, name) {}
        bool Execute(Event& event) override;
    };
}
