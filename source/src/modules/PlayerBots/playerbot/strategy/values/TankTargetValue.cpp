
#include "playerbot/playerbot.h"
#include "TankTargetValue.h"
#include "PossibleAttackTargetsValue.h"
#include "AttackersValue.h"

using namespace ai;

class FindTargetForTankStrategy : public FindNonCcTargetStrategy
{
public:
    FindTargetForTankStrategy(PlayerbotAI* ai, Unit* held, Player* master) : FindNonCcTargetStrategy(ai), held(held), master(master)
    {
        minThreat = 0;
    }

public:
    virtual void CheckAttacker(Unit* creature, ThreatManager* threatManager) override
    {
        Player* bot = ai->GetBot();
        AiObjectContext* context = ai->GetAiObjectContext();

        // A mob the player has only started on has no threat from the tank, so
        // the least-threat pick took it at once, then dropped it when the cast
        // bar ended and took it again when the spell landed. While the tank has
        // a fight, it waits for the mob to be in combat.
        if (held && creature != held && AttackersValue::IsOnlyStartedOn(creature, master)) return;

        if (IsCcTarget(creature)) return;

        if (!PossibleAttackTargetsValue::IsValid(creature, bot))
        {
            std::list<ObjectGuid> attackers = AI_VALUE(std::list<ObjectGuid>, "possible attack targets");
            if (std::find(attackers.begin(), attackers.end(), creature->GetObjectGuid()) == attackers.end())
                return;
        }

        float threat = threatManager->getThreat(bot);
        if (!result || (minThreat - threat) > 0.1f)
        {
            minThreat = threat;
            result = creature;
        }
    }

protected:
    float minThreat;
    Unit* held;
    Player* master;
};

// Only a mob that attacks somebody other than the tank.
class FindLooseTargetForTankStrategy : public FindTargetForTankStrategy
{
public:
    FindLooseTargetForTankStrategy(PlayerbotAI* ai, Unit* held, Player* master) : FindTargetForTankStrategy(ai, held, master) {}

    void CheckAttacker(Unit* creature, ThreatManager* threatManager) override
    {
        Unit* victim = creature->GetVictim();
        if (!victim || victim == ai->GetBot())
            return;

        FindTargetForTankStrategy::CheckAttacker(creature, threatManager);
    }

    // No fallback to a crowd-controlled mob: a sheep is not loose.
    Unit* GetResult() override { return result; }
};

Unit* TankTargetValue::Calculate()
{
    // A LOOSE MOB BEFORE THE SKULL (2026-10-28). The skull was the tank's target
    // whatever else happened, so a mob on the healer stayed there. The skull is
    // now the tank's target only when no mob attacks another member of the
    // group. TankAssistTrigger switches to a loose mob, and the skull is first
    // again once that mob is on the tank. AttackersValue keeps every mob on a
    // tank's list for this.
    Unit* rti = RtiTargetValue::Calculate();
    if (rti)
    {
        FindLooseTargetForTankStrategy loose(ai, AttackersValue::HeldTarget(ai), ai->GetMaster());
        Unit* looseMob = FindTarget(&loose);
        return looseMob ? looseMob : rti;
    }

    FindTargetForTankStrategy strategy(ai, AttackersValue::HeldTarget(ai), ai->GetMaster());
    return FindTarget(&strategy);
}
