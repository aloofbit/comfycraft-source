
#include "playerbot/playerbot.h"
#include "RangedCombatStrategy.h"

using namespace ai;

void RangedCombatStrategy::InitCombatTriggers(std::list<TriggerNode*> &triggers)
{
    triggers.push_back(new TriggerNode(
        "enemy too close for spell",
        NextAction::array(0, new NextAction("flee", ACTION_MOVE), NULL)));

    // Above damage spells, below heals: one step, then the bot casts again.
    triggers.push_back(new TriggerNode(
        "rooted attacker in reach",
        NextAction::array(0, new NextAction("step out of reach", ACTION_MOVE + 5), NULL)));
}
