
#include "playerbot/playerbot.h"
#include "playerbot/PlayerbotAIConfig.h"
#include "playerbot/ServerFacade.h"
#include "playerbot/strategy/Action.h"
#include "playerbot/strategy/generic/PullStrategy.h"
#include "PullTriggers.h"
#include "playerbot/strategy/values/PositionValue.h"
#include "playerbot/strategy/actions/PullActions.h"

using namespace ai;

bool ShouldPullTrigger::IsActive()
{
    // Dungeons only, deliberately. Outdoors a bot already has grinding and travel
    // behaviour that this would compete with, and a pull that goes wrong out there
    // only adds to the death numbers. Inside, somebody has to start the fight or
    // the group stands around until a real player does it.
    Map* map = bot->GetMap();
    if (!map || !map->IsDungeon())
        return false;

    if (!PlayerbotAI::IsTank(bot))
        return false;

    // Never start a pull on top of one already running. This was implicit
    // before and only ever held by luck: FindPullTarget skips anything already
    // in combat, so nothing was offered ONCE the pulled mob had aggro - but for
    // the whole preparing/staging/approaching window it has none, and the tank
    // is not in combat either. A second request landing in that window used to
    // be near-harmless because it just overwrote the target; now that a request
    // tears the running pull down and starts over, it would be a dungeon tank
    // restarting its own pull on a timer.
    if (!PullStateIs(ai, PullState::None))
        return false;

    Group* group = bot->GetGroup();
    if (!group)
        return false;

    for (GroupReference* ref = group->GetFirstMember(); ref; ref = ref->next())
    {
        Player* member = ref->getSource();
        if (!member || !member->IsInWorld() || member->GetMapId() != bot->GetMapId())
            continue;

        // Never pull on top of a fight that is still running, and never onto a
        // corpse - somebody has to be raised first.
        if (member->IsInCombat() || !member->IsAlive())
            return false;

        // The healer decides the pace. Pulling with an empty healer is how a
        // group wipes on trash it could otherwise walk through.
        if (PlayerbotAI::IsHeal(member) && member->GetPowerType() == POWER_MANA)
        {
            const uint32 maxMana = member->GetMaxPower(POWER_MANA);
            if (maxMana && (100 * member->GetPower(POWER_MANA)) / maxMana < sPlayerbotAIConfig.mediumMana)
                return false;
        }
    }

    return PullNearestTargetAction::FindPullTarget(ai) != nullptr;
}
