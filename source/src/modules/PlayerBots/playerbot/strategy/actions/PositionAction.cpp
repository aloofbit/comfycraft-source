
#include "playerbot/playerbot.h"
#include "playerbot/ServerFacade.h"
#include "playerbot/strategy/generic/PullTuning.h"
#include "playerbot/strategy/values/PositionValue.h"
#include "playerbot/strategy/values/FreeMoveValues.h"
#include "PositionAction.h"

using namespace ai;

void TellPosition(PlayerbotAI* ai, Player* requester, std::string name, ai::PositionEntry pos)
{
    std::ostringstream out; out << "Position " << name;
    if (pos.isSet())
    {
        float x = pos.x, y = pos.y;
        Map2ZoneCoordinates(x, y, ai->GetBot()->GetZoneId());
        out << " is set to " << x << "," << y;
    }
    else
        out << " is not set";
    ai->TellPlayer(requester, out);
}

bool PositionAction::Execute(Event& event)
{
    Player* requester = event.getOwner() ? event.getOwner() : GetMaster();
    std::string param = event.getParam();
	if (param.empty())
		return false;

    if (!requester)
        return false;

    ai::PositionMap& posMap = context->GetValue<ai::PositionMap&>("position")->Get();
    if (param == "?")
    {
        for (ai::PositionMap::iterator i = posMap.begin(); i != posMap.end(); ++i)
        {
            if (i->second.isSet())
                TellPosition(ai, requester, i->first, i->second);
        }
        return true;
    }

    std::vector<std::string> params = split(param, ' ');
    if (params.size() != 2)
    {
        ai->TellPlayer(requester, "Whisper position <name> ?/set/reset");
        return false;
    }

    std::string name = params[0];
    std::string action = params[1];
	ai::PositionEntry pos = posMap[name];
	if (action == "?")
	{
	    TellPosition(ai, requester, name, pos);
	    return true;
	}

    std::vector<std::string> coords = split(action, ',');
    if (coords.size() == 3)
    {
        pos.Set(atoi(coords[0].c_str()), atoi(coords[1].c_str()), atoi(coords[2].c_str()), ai->GetBot()->GetMapId());
        posMap[name] = pos;

        std::ostringstream out; out << "Position " << name << " is set";
        ai->TellPlayer(requester, out);
        return true;
    }

	if (action == "set")
	{
        pos.Set(bot->GetPositionX(), bot->GetPositionY(), bot->GetPositionZ(), ai->GetBot()->GetMapId());
	    posMap[name] = pos;

	    std::ostringstream out; out << "Position " << name << " is set";
	    ai->TellPlayer(requester, out);
	    return true;
	}

	if (action == "reset")
	{
	    pos.Reset();
	    posMap[name] = pos;

	    std::ostringstream out; out << "Position " << name << " is reset";
	    ai->TellPlayer(requester, out);
	    return true;
	}

    return false;
}

bool MoveToPositionAction::Execute(Event& event)
{
    Player* requester = event.getOwner() ? event.getOwner() : GetMaster();
	ai::PositionEntry pos = context->GetValue<ai::PositionMap&>("position")->Get()[qualifier];
    if (!pos.isSet())
    {
        std::ostringstream out; out << "Position " << qualifier << " is not set";
        ai->TellPlayer(requester, out);
        return false;
    }

    return MoveTo(bot->GetMapId(), pos.x, pos.y, pos.z, idle);
}

bool MoveToPositionAction::isUseful()
{
    ai::PositionEntry pos = context->GetValue<ai::PositionMap&>("position")->Get()[qualifier];
    float distance = AI_VALUE2(float, "distance", std::string("position_") + qualifier);
    return pos.isSet() && distance > ai->GetRange("follow") && ai->CanMove();
}

bool GuardAction::isUseful()
{
    if (ai->IsStateActive(BotState::BOT_STATE_COMBAT))
    {
        Unit* target = AI_VALUE(Unit*, "current target");

        if (!target)
            return true;

        if (target->GetTarget() == bot) //Try pulling target to guard position
            return true;

        if (!ai->IsRanged(bot)) //Melee bots stay in melee.
            return false;

        WorldPosition formationPosition = AI_VALUE(WorldPosition, "formation position");

        if (formationPosition.sqDistance2d(target) > ai->GetRange("spell")) //Do not move to guard if we can't attack from that position.
            return false;
    }
    else
    {
        if (AI_VALUE(GuidPosition, "rpg target") && CanFreeMoveValue::CanFreeMoveTo(ai, AI_VALUE(GuidPosition, "rpg target")))
        {
            return false;
        }
    }
            
    return true;
}

bool SetReturnPositionAction::Execute(Event& event)
{
    ai::PositionMap& posMap = context->GetValue<ai::PositionMap&>("position")->Get();
    ai::PositionEntry returnPos = posMap["return"];
    ai::PositionEntry randomPos = posMap["random"];
    if (returnPos.isSet() && !randomPos.isSet())
    {
        float angle = 2 * M_PI * urand(0, 1000) / 100.0f;
        float dist = ai->GetRange("follow") * urand(0, 1000) / 1000.0f;
        float x = returnPos.x + cos(angle) * dist,
             y = returnPos.y + sin(angle) * dist,
             z = bot->GetPositionZ();
        bot->UpdateAllowedPositionZ(x, y, z);

        if (!bot->IsWithinLOS(x, y, z, true))
            return false;

        randomPos.Set(x, y, z, bot->GetMapId());
        posMap["random"] = randomPos;
        return true;
    }
    return false;
}

bool SetReturnPositionAction::isUseful()
{
    ai::PositionMap& posMap = context->GetValue<ai::PositionMap&>("position")->Get();
    return posMap["return"].isSet() && !posMap["random"].isSet();
}


bool ReturnAction::isUseful()
{
    ai::PositionEntry pos = context->GetValue<ai::PositionMap&>("position")->Get()[qualifier];
    return pos.isSet() && AI_VALUE2(float, "distance", "position_random") > ai->GetRange("follow");
}

bool ReturnToStayPositionAction::isPossible()
{
    PositionMap& posMap = AI_VALUE(PositionMap&, "position");
    PositionEntry stayPosition = posMap["stay"];
    if (stayPosition.isSet())
    {
        const float distance = bot->GetDistance(stayPosition.x, stayPosition.y, stayPosition.z);
        if (distance > sPlayerbotAIConfig.reactDistance)
        {
            ai->TellError(GetMaster(), "The stay position is too far to return. I am going to stay where I am now");
            
            // Set the stay position to current position
            stayPosition.Set(bot->GetPositionX(), bot->GetPositionY(), bot->GetPositionZ(), bot->GetMapId());
            posMap["stay"] = stayPosition;
        }

        return true;
    }

    return false;
}

bool ReturnToPullPositionAction::Execute(Event& event)
{
    ai::PositionEntry anchor = context->GetValue<ai::PositionMap&>("position")->Get()[qualifier];
    if (!anchor.isSet())
        return MoveToPositionAction::Execute(event);

    PullStrategy* strategy = PullStrategy::Get(ai);
    const float distance = bot->GetDistance(anchor.x, anchor.y, anchor.z);

    // Try harder to actually arrive, rather than settling for "near enough".
    //
    // Poll while walking so progress is watched, and if the bot stops making
    // ground - blocked, or a path that quietly gave up - stop and ask again
    // instead of standing there until the failsafe. Same treatment the approach
    // needed, for the same reason.
    //
    // There is a floor on how exact this can get: the anchor is where the
    // PLAYER is standing, and a bot cannot occupy the same space as them, so
    // "exactly" is unreachable by construction. Tolerance is about a yard,
    // which is standing next to you - tightening it below the collision radius
    // would only guarantee the pull never ends.
    if (strategy)
    {
        strategy->NoteApproachProgress(distance);

        if (strategy->IsApproachStalled())
        {
            std::ostringstream stuck;
            stuck << "not getting home at " << (int)distance << "y - asking again";
            strategy->TellStep(stuck.str());

            ai->StopMoving();
            strategy->ResetApproachProgress();
        }
        else if (sServerFacade.isMoving(bot))
        {
            SetDuration(PullTuning::PollInterval);
            return true;
        }
    }

    // Poll AFTER the move. MoveTo calls WaitForReach, which calls SetDuration
    // on this action with the whole travel time - so setting it first is simply
    // overwritten, and the walk home stops being watched exactly like the
    // approach did.
    const bool moving = MoveToPositionAction::Execute(event);
    SetDuration(PullTuning::PollInterval);
    return moving;
}

bool ReturnToPullPositionAction::isUseful()
{
    ai::PositionEntry pos = context->GetValue<ai::PositionMap&>("position")->Get()[qualifier];
    const float distance = AI_VALUE2(float, "distance", std::string("position_") + qualifier);
    return pos.isSet() && distance > PullTuning::AnchorTolerance && ai->CanMove();
}

bool ReturnToPullPositionAction::isPossible()
{
    PositionMap& posMap = AI_VALUE(PositionMap&, "position");
    PositionEntry anchor = posMap["pull"];
    if (!anchor.isSet())
        return false;

    // Nothing else. GetPullState() has already decided the bot should be
    // walking home; re-deriving that here can only disagree with it.
    //
    // It used to also require target->GetTarget() == bot, which is wrong in the
    // exact case that exposed it: a body pull often takes aggro from a patrol or
    // a link rather than from the pull target, so the target is not looking at
    // the bot, this returned false, and the Returning state was left with no
    // runnable action at all. The gate blocks every other mover, but "melee" is
    // allowed - so the tank stood where it was and fought, which is precisely
    // what a pull exists to prevent.
    const float distance = bot->GetDistance(anchor.x, anchor.y, anchor.z);
    if (distance > sPlayerbotAIConfig.reactDistance)
    {
        ai->TellError(GetMaster(), "The pull position is too far to return. I am going to pull where I am now");

        anchor.Set(bot->GetPositionX(), bot->GetPositionY(), bot->GetPositionZ(), bot->GetMapId());
        posMap["pull"] = anchor;
    }

    return true;
}


