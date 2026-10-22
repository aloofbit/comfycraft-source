
#include "playerbot/playerbot.h"
#include "MageActions.h"
#include "MageTriggers.h"

using namespace ai;

// The blast wave fallback reaches Frost Nova without the trigger, so the
// target carries the same test: no target, no nova.
Unit* CastFrostNovaAction::GetTarget()
{
    return FrostNovaTarget(ai);
}
