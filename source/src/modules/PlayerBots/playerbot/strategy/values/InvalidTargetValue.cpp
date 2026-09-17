
#include "playerbot/playerbot.h"
#include "InvalidTargetValue.h"
#include "PossibleAttackTargetsValue.h"
#include "EnemyPlayerValue.h"
#include "playerbot/PlayerbotAIConfig.h"
#include "playerbot/ServerFacade.h"

using namespace ai;

bool InvalidTargetValue::Calculate()
{
    Unit* target = AI_VALUE(Unit*, qualifier);
    if (!target || !target->IsInWorld() || target->GetMapId() != bot->GetMapId())
    {
        return true;
    }

    Unit* duelTarget = AI_VALUE(Unit*, "duel target");
    if (duelTarget && duelTarget == target)
    {
        return false;
    }

    if (qualifier == "current target")
    {
        if (target->GetObjectGuid() != bot->GetSelectionGuid())
        {
            return true;
        }
    }

    // THE MOB WE ARE CROWD-CONTROLLING IS NOT AN INVALID TARGET. It is spoken
    // for, which is the opposite.
    //
    // This is the polymorph loop, end to end. A cc-marked mob is deliberately
    // not a valid ATTACK target - that is what stops the warrior sundering the
    // sheep - so once the mage's current target was the moon, this value
    // reported it invalid every tick. The invalid target trigger then ran
    // "select new target" at ACTION_EMERGENCY, which outranks polymorph's
    // ACTION_INTERRUPT, and the first thing that action does is
    // ai->InterruptSpell(). The sheep died a fraction of a second into its cast,
    // found no replacement target - the only mob nearby being the one it is not
    // allowed to attack - and the whole thing went round again on the next tick.
    //
    // Every symptom follows from that: a cast visibly starting and never
    // finishing, no spell in flight by the time the cc action re-entered, and
    // the action reporting its constructor's default duration because its
    // success path never got to run.
    //
    // Marked for cc is a REASON TO KEEP the target, not to discard it. The
    // ordinary invalidity checks above still apply - dead, gone, wrong map - so
    // this only skips the "not worth attacking" test, which was never the right
    // question to ask about something being sheeped.
    if (Unit* ccTarget = AI_VALUE(Unit*, "rti cc target"))
    {
        if (ccTarget == target)
        {
            return false;
        }
    }

    const bool validTarget = PossibleAttackTargetsValue::IsValid(target, bot);
    if (!validTarget)
    {
        std::list<ObjectGuid> attackers = AI_VALUE(std::list<ObjectGuid>, "possible attack targets");
        if (std::find(attackers.begin(), attackers.end(), target->GetObjectGuid()) != attackers.end())
        {
            return false;
        }
    }

    return !validTarget;
}