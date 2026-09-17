#pragma once
#include "playerbot/strategy/Value.h"
#include "TargetValue.h"

namespace ai
{
    class FindLeastHpTargetStrategy : public FindNonCcTargetStrategy
    {
    public:
        FindLeastHpTargetStrategy(PlayerbotAI* ai) : FindNonCcTargetStrategy(ai)
        {
            minHealth = 0;
        }
    public:
        virtual void CheckAttacker(Unit* attacker, ThreatManager* threatManager) override
        {
            // do not use this logic for pvp
            if (attacker->IsPlayer())
                return;

            // The moon used to be checked again here, separately. It is already
            // part of IsCcTarget - which now also remembers what it passed over,
            // so that a marked mob left alone while there were others can still
            // be attacked when it is the last one standing. Checking it twice
            // meant the second check returned without recording anything, and
            // the fallback never saw it.
            if (IsCcTarget(attacker))
                return;

            if (!result || result->GetHealth() > attacker->GetHealth())
                result = attacker;
        }
    protected:
        float minHealth;
    };

    class LeastHpTargetValue : public TargetValue
	{
	public:
        LeastHpTargetValue(PlayerbotAI* ai, std::string name = "least hp target") : TargetValue(ai, name) {}

    public:
        Unit* Calculate() override;
    };
}
