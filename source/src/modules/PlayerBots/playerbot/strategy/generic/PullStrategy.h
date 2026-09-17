#pragma once
#include "playerbot/strategy/Strategy.h"
#include "playerbot/strategy/Multiplier.h"

namespace ai
{
    // How this pull is being made.
    //
    // Two spec branches turn out to be one mode. "No opener available - walk in
    // until something aggros" and "the target is already inside minimum range,
    // skip the opener and just swing" differ only in how far the walk is: both
    // end with the tank in melee having taken aggro with its body, and both then
    // fall back exactly like a shot pull. Keeping them as one mode is why this
    // is a small change rather than two branches that drift apart.
    enum class PullMode
    {
        Ranged,     // fire an opener from range
        Body,       // close until something notices, and let that be the pull
    };

    // Where a pull is up to. Exactly one of these is true at a time, and it is
    // DERIVED rather than advanced - see PullStrategy::GetPullState.
    //
    // Before this the pull was five independent triggers that could all be
    // active at once, competing in the shared action queue and held off each
    // other by relevance numbers. Every bug in it had the same shape: two parts
    // both thought they should be running, and which one won came down to
    // arithmetic. Three separate leaks were patched that way before it became
    // clear the shape was the problem, not the numbers.
    enum class PullState
    {
        None,           // no pull is running
        Preparing,      // pre-action (bear form, seal) and pet set passive
        Staging,        // get to the anchor BEFORE leaving, so the pull starts from it
        Approaching,    // getting to somewhere the pull can be made from
        Firing,         // in position - take the shot
        Returning,      // walking back to the anchor
        Holding,        // on the anchor, waiting, allowed to swing
        Finishing,      // done, clean up
    };

    class PullStrategy : public Strategy
    {
    public:
        PullStrategy(PlayerbotAI* ai, std::string pullAction, std::string prePullAction = "");

    public:
        std::string getName() override { return "pull"; }

        static PullStrategy* Get(PlayerbotAI* ai);
        static uint8 GetMaxPullTime() { return 15; }

        // Is somebody ELSE in my group mid-pull?
        //
        // What the rest of the group needs in order to hold: the tank has taken
        // the order and has not finished. Asked of every bot's target selection,
        // so it is deliberately built out of HasPullStarted() and nothing else -
        // GetPullState() narrates and calls out to party chat as a side effect
        // of being asked, so calling it from another bot's code would have every
        // dps in the group re-announcing the tank's pull on every tick.
        static bool IsGroupPullRunning(PlayerbotAI* ai);
        const time_t& GetPullStartTime() const { return pullStartTime; }
        
        bool CanDoPullAction(Unit* target);

        Unit* GetTarget() const;
        bool HasTarget() const { return GetTarget() != nullptr; }

        std::string GetPullActionName() const;
        std::string GetSpellName() const;
        float GetRange() const;

        // Where the approach stops and the shot starts. ONE number, used by
        // both sides.
        //
        // They used to disagree: "reach pull" walked toward GetRange() - 5 and
        // kept moving while further than that, while PullAction called anything
        // inside GetRange() close enough and stopped the bot to fire. Anywhere
        // in the gap - 27 yd of a 29.5 yd range, say - the two fought: the
        // action stopped the bot, the reach started it again, and the bot never
        // got a stationary tick to shoot in. It looped until the 15s failsafe.
        //
        // The buffer is against a target drifting out of range mid-cast; a shot
        // fired at the very edge is a shot wasted.
        static float GetApproachBuffer() { return 5.0f; }
        float GetApproachRange() const
        {
            const float range = GetRange();
            return range > GetApproachBuffer() ? range - GetApproachBuffer() : range;
        }

        // Close enough to shoot from - a SEPARATE, looser number from the one
        // the approach walks toward, and it has to be.
        //
        // MoveChase has slack of its own: told to close to 24 yards it will sit
        // at 25 and consider that arrived. Testing arrival against the same 24
        // then deadlocks - the mover thinks it is done, the checker thinks it
        // is not, and neither moves. Measured 2026-09-07: stuck at "25y, need
        // 24y" through three polls and out to the 15s failsafe, one yard short.
        //
        // Firing only really needs to be inside the spell's range, so this is
        // the range less a small margin against the target drifting out
        // mid-cast. It is comfortably wider than MoveChase's slack, and it also
        // means a target that is already close enough is simply shot rather
        // than walked at - which is what step 1 of the spec asks for anyway.
        static float GetFiringBuffer() { return 2.0f; }
        float GetInPositionRange() const
        {
            const float range = GetRange();
            return range > GetFiringBuffer() ? range - GetFiringBuffer() : range;
        }

        std::string GetPreActionName() const;

        void RequestPull(Unit* target, bool resetTime = true);
        bool IsPullPendingToStart() const { return pendingToStart; }
        bool HasPullStarted() const { return pullStartTime > 0; }
        void OnPullStarted();
        void OnPullEnded();

        // The pull has actually been made - the opener went off, or a body pull
        // took aggro. Distinct from HasPullStarted(), which is true from the
        // moment the order is accepted: between the two the bot is still walking
        // in, and that is exactly the window in which it must NOT start walking
        // back. Disarms the sequence WITHOUT touching pullStartTime, because the
        // 15s failsafe measures from the order, and restarting it on every
        // successful cast is why it never expired.
        void OnPullMade();
        bool HasPullBeenMade() const { return pullMade; }

        // THE state function. One place, one answer, no ordering between
        // triggers to get wrong: every pull trigger is just a test of this, so
        // only one pull action can be eligible on any tick.
        //
        // Derived from facts rather than advanced through transitions, so it
        // cannot get stuck in a state that no longer matches the world - which
        // is what "re-arm pendingToStart" was doing by hand, badly.
        PullState GetPullState() const;
    private:
        PullState ComputePullState() const;
    public:

        // Facts the state is derived from, each with one definition.
        bool IsInFiringPosition() const;
        bool IsAtAnchor() const;
        bool HasAnchor() const;
        bool IsUnderAttack() const;     // anything attacking me, at any range - aggro
        bool IsInMeleeContact() const;  // something actually in reach and swinging
        bool HasTimedOut() const;

        // Is the approach actually getting anywhere?
        //
        // "Moving" is not the same as "closing". A bot can carry the moving
        // flag while its distance to the target does not budge - blocked path,
        // a chase the generator has quietly given up on - and the approach's
        // "do not re-issue while already moving" guard then traps it: it polls,
        // sees moving, returns, and never asks for the move again. Measured
        // 2026-09-07: stuck at "29y, need 27y" for every poll until the 15s
        // failsafe, reporting "moving" throughout.
        void NoteApproachProgress(float distance);
        void ResetApproachProgress();
        bool IsApproachStalled() const;
        bool HasApproachProgress() const { return lastApproachProgress != 0; }

        bool IsPreparationDone() const { return preparationDone; }
        void OnPreparationDone() { preparationDone = true; }

        // Narrate a step of the pull to whoever is watching.
        //
        // Silent unless the bot carries the "pull debug" strategy, and silent
        // when the line repeats - actions run every tick, so an undeduplicated
        // report is a wall of the same sentence. Kept on the strategy rather
        // than in each action so "what did it just do" has one answer and one
        // place to turn off.
        void TellStep(const std::string& step) const;

        // Tell the GROUP where the pull is up to, in party chat, so a healer or
        // a dps knows whether to hold or to come in. Three lines a pull and no
        // more: this is not the step narration, which is a debugging tool that
        // whispers the master only.
        void CallOut(PullState state) const;
        static const char* PullStateName(PullState state);
        void ResetStepReport() { lastStep.clear(); }

        PullMode GetPullMode() const { return pullMode; }
        void SetPullMode(PullMode mode) { pullMode = mode; }

        // The hold: stand on the anchor and let them come to you.
        //
        // The clock starts when the tank actually arrives, not when it turns to
        // walk back, so a long walk home does not eat the hold it was walking
        // home to take. Zero means "not holding yet".
        time_t GetHoldStartTime() const { return holdStartTime; }
        bool IsHolding() const { return holdStartTime > 0; }
        void OnHoldStarted() { holdStartTime = time(0); }
        bool HasHoldExpired() const;


        // Whether a ranged opener is available at all: the class has one and the
        // bot is carrying what it needs to use it. Split out of CanDoPullAction
        // so the request can fall back to a body pull instead of refusing.
        bool CanDoRangedPull(Unit* target);
        ReactStates GetPetReactState() const { return petReactState; }
        // Only the first call in a pull sticks - see petReactStateSaved.
        void SavePetReactState(ReactStates reactState)
        {
            if (!petReactStateSaved)
            {
                petReactState = reactState;
                petReactStateSaved = true;
            }
        }

    private:
        void SetTarget(Unit* target);

        void InitCombatTriggers(std::list<TriggerNode*>& triggers) override;
        void InitNonCombatTriggers(std::list<TriggerNode*>& triggers) override;
        void InitCombatMultipliers(std::list<Multiplier*>& multipliers) override;
        void InitNonCombatMultipliers(std::list<Multiplier*>& multipliers) override;

    private:
        std::string pullActionName; //shoot
        std::string preActionName;
        bool pendingToStart;
        bool pullMade;
        // Whether petReactState below holds the pet's own setting rather than
        // the REACT_PASSIVE we imposed. "pull start" can run more than once in
        // a pull, and capturing every time overwrote the real state with our
        // own - so PullEndAction "restored" passive and the pet stayed passive
        // for good.
        bool petReactStateSaved;
        bool preparationDone;
        PullMode pullMode;
        time_t holdStartTime;
        time_t pullMadeTime;
        float lastApproachDistance;
        time_t lastApproachProgress;
        // Mutable so the narration can run from the const state function -
        // reporting is not part of the pull logic.
        mutable std::string lastStep;
        mutable PullState lastReportedState;
        mutable PullState lastCalledOutState;

        // Staging is a step, not a condition. Latched once the tank has stood
        // on the anchor, because "not at the anchor" is true for the whole
        // approach - so testing it directly sent the bot home the instant it
        // set off, then out, then home, until the failsafe.
        mutable bool stagedAtAnchor;
        time_t pullStartTime;
        ReactStates petReactState;
    };

    class PullMultiplier : public Multiplier
    {
    public:
        PullMultiplier(PlayerbotAI* ai) : Multiplier(ai, "pull") {}

    public:
        float GetValue(Action* action) override;
    };

    class PossibleAdsStrategy : public Strategy
    {
    public:
        PossibleAdsStrategy(PlayerbotAI* ai) : Strategy(ai) {}
        std::string getName() override { return "ads"; }

    private:
        void InitCombatTriggers(std::list<TriggerNode*> &triggers) override;
    };

    // A flag, not a behaviour - it installs no triggers and no actions.
    // PullStrategy::TellStep tests for it, so the pull's step-by-step narration
    // is entirely opt-in.
    //
    // OFF BY DEFAULT since 2026-09-07. It was added to all four tank engines in
    // AiFactory while the pull was being built and left there, so every tank
    // narrated every step to its owner forever. Turn it on for one bot with
    //
    //     co +pull debug
    //
    // and off again with `co -pull debug`. It is the COMBAT engine - `co`, not
    // `nc`, which this comment used to say and which silently does nothing -
    // because that is the engine AiFactory attaches the pull strategy to. The
    // prefix itself is not optional: a bare `+pull debug` is swallowed without
    // a word (see docs/ai/content/companion-commands.md).
    class PullDebugStrategy : public Strategy
    {
    public:
        PullDebugStrategy(PlayerbotAI* ai) : Strategy(ai) {}
        std::string getName() override { return "pull debug"; }
    };

}
