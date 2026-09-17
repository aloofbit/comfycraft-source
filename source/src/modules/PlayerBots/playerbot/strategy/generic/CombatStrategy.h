#pragma once
#include "playerbot/strategy/Strategy.h"

namespace ai
{
    // TO DO: Remove this class when no more dependencies
    class CombatStrategy : public Strategy
    {
    public:
        CombatStrategy(PlayerbotAI* ai) : Strategy(ai) {}
        virtual int GetType() override { return STRATEGY_TYPE_COMBAT; }

    protected:
        virtual void InitCombatTriggers(std::list<TriggerNode*>& triggers) override;
    };

    class AvoidAoeStrategy : public Strategy
    {
    public:
        AvoidAoeStrategy(PlayerbotAI* ai) : Strategy(ai) {}
        std::string getName() override { return "avoid aoe"; }

#ifdef GenerateBotHelp
        virtual std::string GetHelpName() { return "avoid aoe"; } //Must equal iternal name
        virtual std::string GetHelpDescription() 
        {
            return "This strategy will make bots move away when they are in aoe.";
        }
        virtual std::vector<std::string> GetRelatedStrategies() { return { }; }
#endif

    private:
        void InitCombatMultipliers(std::list<Multiplier*>& multipliers) override;
        void InitReactionMultipliers(std::list<Multiplier*>& multipliers) override;
        void InitCombatTriggers(std::list<TriggerNode*>& triggers) override;
        void InitReactionTriggers(std::list<TriggerNode*>& triggers) override;
    };

    // A healer that helps with damage, but stops the moment it costs it.
    //
    // Holy paladins and resto druids are given "dps assist" (AiFactory 413 and
    // 470), and neither has a ranged attack - so "assist" means WALK INTO
    // MELEE, which is where area damage lands. AvoidAoeStrategy already flees
    // out, but nothing stops the healer strolling straight back in, so it ends
    // up cycling through the fire.
    //
    // This suppresses only the go-and-hit-something half, and only for a while
    // after the healer was actually caught in something. Heals, flee and
    // movement are untouched: the point is to stop it RETURNING to melee, not
    // to make it passive.
    class HealerCautionMultiplier : public Multiplier
    {
    public:
        HealerCautionMultiplier(PlayerbotAI* ai)
            : Multiplier(ai, "healer caution"), m_backOffUntil(0) {}

        float GetValue(Action* action) override;

    private:
        time_t m_backOffUntil;
    };

    // See the implementation for why flee has to be dampened rather than the
    // heals raised: flee sits at ACTION_EMERGENCY + 9 and nothing outranks it.
    class HealBeforeFleeMultiplier : public Multiplier
    {
    public:
        HealBeforeFleeMultiplier(PlayerbotAI* ai) : Multiplier(ai, "heal before flee") {}
        float GetValue(Action* action) override;
    };

    class HealerCautionStrategy : public Strategy
    {
    public:
        HealerCautionStrategy(PlayerbotAI* ai) : Strategy(ai) {}
        std::string getName() override { return "healer caution"; }

#ifdef GenerateBotHelp
        virtual std::string GetHelpName() { return "healer caution"; }
        virtual std::string GetHelpDescription()
        {
            return "Stops a healer returning to melee for a while after it takes area damage.";
        }
        virtual std::vector<std::string> GetRelatedStrategies() { return { "avoid aoe", "dps assist" }; }
#endif

    private:
        void InitCombatMultipliers(std::list<Multiplier*>& multipliers) override;
    };

    class AvoidAoeStrategyMultiplier : public Multiplier
    {
    public:
        AvoidAoeStrategyMultiplier(PlayerbotAI* ai) : Multiplier(ai, "run away on area debuff") {}
        float GetValue(Action* action) override;
        
#ifdef GenerateBotHelp
        virtual std::string GetHelpName() { return "run away on area debuff"; } //Must equal iternal name
        virtual std::string GetHelpDescription() {
            return "This stops bots from casting certain (cast-time) spells when affected by an area debuf.";
        }
        virtual std::vector<std::string> GetRelatedStrategies() { return {}; }
#endif
    };

    class WaitForAttackStrategy : public Strategy
    {
    public:
        WaitForAttackStrategy(PlayerbotAI* ai) : Strategy(ai) {}
        std::string getName() override { return "wait for attack"; }

        static bool ShouldWait(PlayerbotAI* ai);
        static uint8 GetWaitTime(PlayerbotAI* ai);
        static float GetSafeDistance() { return sPlayerbotAIConfig.spellDistance; }
        static float GetSafeDistanceThreshold() { return 2.5f; }

#ifdef GenerateBotHelp
        virtual std::string GetHelpName() { return "wait for attack"; } //Must equal iternal name
        virtual std::string GetHelpDescription() {
            return "This strategy will make bots wait a specified time before attacking.";
        }
        virtual std::vector<std::string> GetRelatedStrategies() { return { }; }
#endif

    private:
        void InitCombatTriggers(std::list<TriggerNode*>& triggers) override;
        void InitCombatMultipliers(std::list<Multiplier*>& multipliers) override;
    };

    class WaitForAttackMultiplier : public Multiplier
    {
    public:
        WaitForAttackMultiplier(PlayerbotAI* ai) : Multiplier(ai, "wait for for attack") {}
        float GetValue(Action* action) override;
    };

    class HealInterruptStrategy : public Strategy
    {
    public:
        HealInterruptStrategy(PlayerbotAI* ai) : Strategy(ai) {}
        std::string getName() override { return "heal interrupt"; }

#ifdef GenerateBotHelp
        virtual std::string GetHelpName() { return "heal interrupt"; } //Must equal iternal name
        virtual std::string GetHelpDescription()
        {
            return "This strategy will make the bot interrupt the heal it currently casts if target is at full health";
        }
#endif

    private:
        void InitCombatTriggers(std::list<TriggerNode*>& triggers) override;
        void InitReactionTriggers(std::list<TriggerNode*>& triggers) override;
    };

    class PreHealStrategy : public Strategy
    {
    public:
        PreHealStrategy(PlayerbotAI* ai) : Strategy(ai) {}
        std::string getName() override { return "preheal"; }

#ifdef GenerateBotHelp
        virtual std::string GetHelpName() { return "preheal"; } //Must equal iternal name
        virtual std::string GetHelpDescription()
        {
            return "This strategy will make the bot calculate melee damage of attacker when deciding how to heal target";
        }
#endif
    };
}
