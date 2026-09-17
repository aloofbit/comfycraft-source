
#include "playerbot/playerbot.h"
#include "playerbot/strategy/generic/PullTuning.h"
#include "playerbot/strategy/generic/PullStrategy.h"
#include "playerbot/strategy/values/AttackersValue.h"
#include "PullActions.h"
#include "playerbot/strategy/values/PositionValue.h"
#include "playerbot/strategy/values/CcTargetValue.h"
#include "AttackAction.h"

using namespace ai;

bool ai::PullStateIs(PlayerbotAI* ai, PullState state)
{
    const PullStrategy* strategy = PullStrategy::Get(ai);
    return strategy && strategy->GetPullState() == state;
}

// Only the results a refused opener can actually come back with, named. The
// numbers are useless in a chat line and the full 200-entry table would be
// noise; anything outside this list prints as its number, which is enough to
// look up once and then add here if it ever recurs.
static const char* PullCastFailureName(SpellCastResult result)
{
    switch (result)
    {
        case SPELL_CAST_OK:                 return "no reason given";
        case SPELL_FAILED_LINE_OF_SIGHT:    return "no line of sight";
        case SPELL_FAILED_OUT_OF_RANGE:     return "out of range";
        case SPELL_FAILED_UNIT_NOT_INFRONT: return "not facing target";
        case SPELL_FAILED_NOT_INFRONT:      return "not in front";
        case SPELL_FAILED_MOVING:           return "still moving";
        case SPELL_FAILED_NOT_STANDING:     return "not standing";
        case SPELL_FAILED_TRY_AGAIN:        return "try again";
        case SPELL_FAILED_NO_AMMO:          return "out of ammo";
        default: break;
    }

    static std::string unnamed;
    unnamed = "code " + std::to_string((uint32)result);
    return unnamed.c_str();
}

// Undo everything a pull imposes, in ONE place.
//
// Two callers: the pull ending normally, and a fresh `pull` order arriving
// while one is already running. That second caller is why this had to come out
// of PullEndAction. Restarting by simply re-requesting left every latch of the
// old pull standing, and each one is a lie about the new pull: pullMade alone
// sends it straight to Returning, walking home from a mob it has not touched.
// The pet is the subtle one - SavePetReactState latches only the FIRST call of
// a pull, so skipping the restore here would record our own REACT_PASSIVE as
// the pet's own setting and leave it passive for good.
static void TearDownPull(PlayerbotAI* ai, PullStrategy* strategy)
{
    Player* bot = ai->GetBot();

    // Restore the pet react state
    Pet* pet = bot->GetPet();
    if (pet)
    {
        UnitAI* creatureAI = ((Creature*)pet)->AI();
        if (creatureAI)
        {
            creatureAI->SetReactState(strategy->GetPetReactState());
        }
    }

    // Remove the saved pull position
    AiObjectContext* context = ai->GetAiObjectContext();
    PositionMap& posMap = AI_VALUE(PositionMap&, "position");
    if (posMap["pull"].isSet())
    {
        posMap.erase("pull");
    }

    strategy->OnPullEnded();
}

Unit* PullNearestTargetAction::FindPullTarget(PlayerbotAI* ai)
{
    Player* bot = ai->GetBot();
    Unit* best = nullptr;

    // Same ceiling PullRequestAction::Execute enforces, so the trigger cannot
    // offer a target the action will then refuse.
    float bestDistance = sPlayerbotAIConfig.reactDistance * 3;

    for (const ObjectGuid& guid : ai->GetAiObjectContext()->GetValue<std::list<ObjectGuid>>("possible targets")->Get())
    {
        Unit* unit = ai->GetUnit(guid);
        if (!unit || !unit->IsAlive())
            continue;

        // "possible targets" carries neutrals too, and a neutral is not a pull.
        if (!bot->IsHostileTo(unit))
            continue;

        // Somebody is already on it - that is no longer a pull, it is a join.
        if (unit->IsInCombat())
            continue;

        if (!AttackersValue::IsValid(unit, bot, nullptr, false))
            continue;

        const float distance = unit->GetDistance(bot);
        if (distance < bestDistance)
        {
            bestDistance = distance;
            best = unit;
        }
    }

    return best;
}

Unit* PullNearestTargetAction::GetTarget(Event& event)
{
    return FindPullTarget(ai);
}

bool PullRequestAction::Execute(Event& event)
{
    Player* requester = event.getOwner() ? event.getOwner() : GetMaster();

    // Before anything else, and deliberately before the not-a-tank bail below:
    // every companion hears this order, and the one that can crowd-control is
    // the one whose answer the player cannot otherwise see.
    ReportCcIntent(ai, requester);

    // EVERY BOT THAT HEARS THE PULL COMES OFF PASSIVE, not just the one that
    // makes it.
    //
    // This used to sit below the not-a-tank bail, so a pull order engaged the
    // tank and left the dps exactly as `follow` had left them: passive. A
    // passive bot can still CAST - a zeroed action runs when nothing outranks
    // it - but it cannot MOVE, because the passive gate in
    // MovementAction::isUseful refuses everything outside its allow-list. That
    // is a mage announcing "CC target found" and then not walking a step
    // towards it, which is precisely what was reported.
    //
    // A dps coming off passive does not mean it starts swinging: the pull hold
    // in AttackersValue is what keeps it off the tank's target, and that is
    // enforced on the target list rather than on the mode.
    EngageOnOrder(ai);

    PullStrategy* strategy = PullStrategy::Get(ai);
    if (!strategy)
    {
        // The only refusal here that used to say nothing, and the easiest one to
        // hit: AiFactory hands the `pull` strategy to tanks only (tab 2 for a
        // warrior or paladin, tank feral for a druid, blood for a DK). An arms
        // or fury warrior has no pull at all, so the order was accepted by the
        // trigger, dropped here, and read in game as the bot ignoring you.
        //
        // Only for a bot that could plausibly have been the one asked, though.
        // `pull` arrives in PARTY chat - that is how the bar sends it - so every
        // companion hears every press, and a party of dps each answering "I
        // can't pull" is three lines of noise about a question none of them was
        // being asked. A TANK without the strategy is a real misconfiguration
        // and still says so, which is the case this message was written for.
        if (PlayerbotAI::IsTank(bot))
        {
            ai->TellPlayerNoFacing(requester, "I can't pull - I'm not specced for it");
        }

        return false;
    }


    Unit* target = GetTarget(event);
    if (!target)
    {
        ai->TellPlayerNoFacing(requester, "You have no target");
        return false;
    }

    const float maxPullDistance = sPlayerbotAIConfig.reactDistance * 3;
    const float distanceToPullTarget = target->GetDistance(ai->GetBot());
    if (distanceToPullTarget > maxPullDistance)
    {
        ai->TellPlayerNoFacing(requester, "The target is too far away");
        return false;
    }

    if (!AttackersValue::IsValid(target, bot, nullptr, false))
    {
        ai->TellPlayerNoFacing(requester, "The target can't be pulled");
        return false;
    }

    // (EngageOnOrder already ran at the top of this function, for every bot
    // that heard the order rather than only the one that pulls.)

    // A `pull` given while a pull is already running means START OVER - not
    // "adjust the one in flight". So drop the old one completely before the new
    // one is set up: the mode, the anchor and the target are all rewritten
    // below, but the latches are not, and every one of them would be a claim
    // about a pull that no longer exists.
    //
    // Deliberately AFTER the four refusals above. An order that gets turned
    // down - no target, too far, unpullable, not specced - must leave a good
    // pull in progress exactly where it was; killing it and then refusing to
    // replace it is the worst of both.
    //
    // StopMoving because the old pull almost certainly has a move in flight -
    // walking to the anchor, or closing on the previous target - and the new
    // pull's first move should not have to win an argument with it.
    if (strategy->HasPullStarted())
    {
        strategy->TellStep("new order - dropping the pull in progress");
        ai->StopMoving();
        TearDownPull(ai, strategy);
    }

    // Pick how this pull gets made.
    //
    // Two reasons to use the body instead of an opener, and they are the same
    // branch: the target is already inside the ranged weapon's minimum range, or
    // there is no usable opener at all. Both end with the tank in melee having
    // taken aggro, and both then fall back identically.
    //
    // The second case used to be a flat refusal - "Can't perform pull action
    // 'shoot'" - which meant a tank with no gun could not pull at all, when
    // walking up to something is a perfectly good way to pull it.
    if (distanceToPullTarget < PullTuning::MinRange)
    {
        strategy->SetPullMode(PullMode::Body);
    }
    else if (strategy->CanDoRangedPull(target))
    {
        strategy->SetPullMode(PullMode::Ranged);
    }
    else
    {
        strategy->SetPullMode(PullMode::Body);
    }

    // The anchor is where the PLAYER is standing, not where the tank happens to
    // be. That is the whole contract of a pull: the group has positioned itself
    // somewhere, and the tank's job is to bring the fight to it. Anchoring on
    // the tank meant the fight came back to wherever the tank had wandered,
    // which is only the right place by coincidence - and the further the tank
    // had drifted before the order, the wronger it was.
    //
    // Falls back to the bot's own position when there is nobody to anchor on,
    // which is the automatic dungeon pull rather than an ordered one.
    PositionMap& posMap = AI_VALUE(PositionMap&, "position");
    PositionEntry pullPosition = posMap["pull"];

    const WorldObject* anchorOn = (requester && requester->GetMapId() == bot->GetMapId())
        ? static_cast<const WorldObject*>(requester)
        : static_cast<const WorldObject*>(bot);

    pullPosition.Set(anchorOn->GetPositionX(), anchorOn->GetPositionY(), anchorOn->GetPositionZ(), anchorOn->GetMapId());
    posMap["pull"] = pullPosition;

    strategy->RequestPull(target);
    strategy->ResetStepReport();
    {
        std::ostringstream step;
        step << "ordered: " << target->GetName() << " at "
             << (int)distanceToPullTarget << "y, anchor "
             << (int)bot->GetDistance(pullPosition.x, pullPosition.y, pullPosition.z) << "y away - ";
        if (strategy->GetPullMode() == PullMode::Body)
        {
            step << "body pull (no opener in reach)";
        }
        else
        {
            step << "opener '" << strategy->GetPullActionName()
                 << "' range " << (int)strategy->GetRange() << "y";
        }
        strategy->TellStep(step.str());
    }

    // Say yes as well as no. Every refusal above whispers its reason and
    // acceptance said nothing, so "she ignored me" and "she took the order and
    // something downstream ate it" looked identical from the chat frame - which
    // is exactly the confusion this cost on 2026-09-07. One line, target named,
    // because the pull is about to move her out of position.
    {
        std::ostringstream out;
        out << "Pulling " << target->GetName();
        ai->TellPlayerNoFacing(requester, out.str());
    }

    // The combat-state switch and the immediate react both moved into
    // EngageOnOrder at the top of this function, where attack gets them too -
    // this pair being here and nowhere else is exactly why a pull worked from a
    // standing start and an attack did not.
    return true;
}

Unit* PullMyTargetAction::GetTarget(Event& event)
{
    Unit* target = nullptr;

    Player* requester = event.getOwner() ? event.getOwner() : GetMaster();
    if (event.getSource() == "attack anything")
    {
        ObjectGuid guid = event.getObject();
        target = ai->GetCreature(guid);
    }
    else if (requester)
    {
        target = ai->GetUnit(requester->GetSelectionGuid());
    }

    return target;
}

Unit* PullRTITargetAction::GetTarget(Event& event)
{
    return AI_VALUE(Unit*, "rti target");
}

bool PullStartAction::Execute(Event& event)
{
    bool result = false;
    PullStrategy* strategy = PullStrategy::Get(ai);
    if (strategy)
    {
        Unit* target = strategy->GetTarget();
        if (target)
        {
            if (strategy->GetPreActionName().empty())
                result = true;
            else
            {
                result = ai->DoSpecificAction(strategy->GetPreActionName(), event, true);
                if(result)
                    SetDuration(ai->GetAIInternalUpdateDelay());
            }

            // Set the pet on passive mode during the pull
            Pet* pet = bot->GetPet();
            if (pet)
            {
                UnitAI* creatureAI = ((Creature*)pet)->AI();
                if (creatureAI)
                {
                    strategy->SavePetReactState(creatureAI->GetReactState());
                    creatureAI->SetReactState(REACT_PASSIVE);
                }
            }

            strategy->TellStep(strategy->GetPreActionName().empty()
                ? "start (no pre-action)"
                : "start (pre-action '" + strategy->GetPreActionName() + "')");
            strategy->OnPullStarted();
            strategy->OnPreparationDone();
        }
    }

    return result;
}


PullAction::PullAction(PlayerbotAI* ai, std::string name) : CastSpellAction(ai, name)
{
    InitPullAction();
}

bool PullAction::Execute(Event& event)
{
    InitPullAction();

    PullStrategy* strategy = PullStrategy::Get(ai);
    if (!strategy)
        return false;

    Unit* target = strategy->GetTarget();
    if (!target)
        return false;

    // No distance or movement checks left here. GetPullState only reports
    // Firing once the bot has arrived AND settled, so by the time this runs
    // "are we in position" is already answered. It used to be asked again here
    // with a different threshold, and the two answers fought: the approach
    // walked the bot in, this stopped it, the approach started it again.
    SET_AI_VALUE(Unit*, "current target", GetTarget());

    // Cast it here, rather than delegating to another action by name.
    //
    // This used to call DoSpecificAction(GetPullActionName()) - the action
    // called "shoot" - while isPossible() had validated GetSpellName(), which
    // for a gun is "shoot gun". Checking one thing and casting another. The
    // delegate reported ACTION_RESULT_OK, so the pull believed it had fired,
    // moved straight to Returning, and walked home from a mob that had never
    // been touched: trace 2026-09-07 went Preparing -> Firing -> "opener away"
    // with no shot and ended "nobody came".
    //
    // PullAction IS a CastSpellAction, and InitPullAction has already pointed
    // it at the resolved spell. Casting directly means the spell that was
    // checked is the spell that goes off.
    if (CastSpellAction::Execute(event))
    {
        std::ostringstream step;
        step << "opener away ('" << strategy->GetSpellName() << "' at "
             << (int)target->GetDistance(bot) << "y) - falling back now";
        strategy->TellStep(step.str());
        strategy->OnPullMade();
        return true;
    }

    // The cast was refused, and isPossible() could not have caught it.
    //
    // isPossible asks CanCastSpell with ignoreRange = true, and that call
    // FORGIVES SEVEN RESULTS the real cast does not - LINE_OF_SIGHT and
    // OUT_OF_RANGE among them (the switch at the end of CanCastSpell in
    // PlayerbotAI.cpp). So "close enough to shoot" and "able to shoot" are two
    // different questions, and standing between two poles answers them
    // differently: trace 2026-09-07 read "in range at 26y, stopping to fire"
    // and then "FAILED to cast", with a pole in the way the whole time.
    //
    // Ask again for the reason - this time WITHOUT the forgiveness - and let
    // the reason decide. Nothing below can run on a pull that fires; it is
    // reached only where the pull is already broken.
    SpellCastResult reason = SPELL_CAST_OK;
    ai->CanCastSpell(strategy->GetSpellName(), target, 0, nullptr, false, false, false, &reason);

    std::ostringstream step;
    step << "opener FAILED ('" << strategy->GetSpellName() << "': " << PullCastFailureName(reason) << ")";
    strategy->TellStep(step.str());

    // No shot from here, and standing still re-asking cannot change that - the
    // pole does not move. Walking in can, and a body pull is what the spec asks
    // for when no opener is available, so take that same road.
    if (reason == SPELL_FAILED_LINE_OF_SIGHT || reason == SPELL_FAILED_OUT_OF_RANGE)
    {
        strategy->TellStep("no line of fire - going in instead");
        strategy->SetPullMode(PullMode::Body);
    }

    return false;
}

bool PullAction::isPossible()
{
    InitPullAction();

    PullStrategy* strategy = PullStrategy::Get(ai);
    if (strategy)
    {
        std::string spellName = strategy->GetSpellName();
        Unit* target = strategy->GetTarget();
        if (!spellName.empty() && target)
        {
            if (!ai->CanCastSpell(spellName, target, true, nullptr, true))
            {
                return false;
            }
        }
    }

    return true;
}

void PullAction::InitPullAction()
{
    // Get the pull action spell name from the strategy
    PullStrategy* strategy = PullStrategy::Get(ai);
    if (strategy)
    {
        std::string spellName = strategy->GetSpellName();
        if (!spellName.empty())
        {
            SetSpellName(spellName);

            float spellRange;
            if (ai->GetSpellRange(spellName, &spellRange))
            {
                range = spellRange;
            }
        }
    }
}

bool PullApproachAction::Execute(Event& event)
{
    PullStrategy* strategy = PullStrategy::Get(ai);
    if (!strategy)
        return false;

    Unit* target = strategy->GetTarget();
    if (!target)
        return false;

    const float distance = target->GetDistance(bot);

    // Walk toward the TARGET'S OWN POSITION, and let the poll stop us.
    //
    // Not toward a computed stand-off point. That was the previous attempt and
    // it broke indoors: a spot standOff yards from the mob on the bot's bearing
    // lands inside geometry as often as not, and MoveTo then pathfinds AROUND
    // it - which in Deadmines means walking back out of the dungeon.
    //
    // The mob's own position is guaranteed reachable, because something is
    // standing on it. Overshoot is not a problem any more either: the approach
    // re-checks every PollInterval and stops the moment it is in range, which
    // is roughly two yards of travel at run speed. That is why this works now
    // when the same idea (MoveTo the target) overshot to 12 yards earlier -
    // back then nothing was watching.
    auto walkToward = [&]() -> bool
    {
        return MoveTo(target->GetMapId(),
                      target->GetPositionX(),
                      target->GetPositionY(),
                      target->GetPositionZ());
    };

    // One line per evaluation, at the poll interval below.
    {
        std::ostringstream check;
        check << "check: " << (int)distance << "y from target, "
              << (sServerFacade.isMoving(bot) ? "moving" : "still");
        strategy->TellStep(check.str());
    }

    // Body pull: walk in and let aggro be the pull. Checked first, because for
    // this mode there is no firing position to arrive at.
    if (strategy->GetPullMode() == PullMode::Body)
    {
        // Two signals, catching different things: the target picking the bot as
        // its victim is the ordinary case, and having attackers catches a patrol
        // or a link that woke up instead of the intended target.
        if (target->GetVictim() == bot || strategy->IsUnderAttack())
        {
            std::ostringstream step;
            step << "aggro at " << (int)distance << "y - falling back now";
            strategy->TellStep(step.str());

            // Stop where the aggro happened; those yards would only have to be
            // given back on the way home.
            ai->StopMoving();
            strategy->OnPullMade();
            return true;
        }

        std::ostringstream step;
        step << "body pull: walking in, " << (int)distance << "y";
        strategy->TellStep(step.str());

        // Do not re-path while a move is already under way. Aggro is tested at
        // the top of this function every tick, so a move still in flight is
        // interrupted the moment something notices - which is what ends a body
        // pull.
        if (sServerFacade.isMoving(bot))
        {
            SetDuration(PullTuning::PollInterval);
            return true;
        }

        // Poll AFTER the move - see the ranged branch for why.
        const bool bodyMoving = walkToward();
        SetDuration(PullTuning::PollInterval);
        return bodyMoving;
    }

    // Too close to open with a ranged weapon - there is a real minimum range
    // and CheckCast refuses below it. This is not only the case of ordering a
    // pull on something already next to you: a mob that closed while the bot
    // was walking in ends up here too, and standing there failing to cast is
    // the worst of the options.
    if (distance < PullTuning::MinRange)
    {
        strategy->TellStep("too close to shoot - pulling with my body");
        strategy->SetPullMode(PullMode::Body);
        return true;
    }

    // Staging walks to the anchor and uses the SAME progress clock, so without
    // this the approach starts with a timestamp from before it began - two
    // seconds stale already - and declares itself stalled on its very first
    // tick, before it has moved at all. Seen in the trace as "not getting
    // closer at 30y - asking again" immediately after "closing: 30y".
    if (!strategy->HasApproachProgress())
        strategy->NoteApproachProgress(distance);

    // Ranged: walk toward the mob until close enough to shoot, then stop.
    // GetPullState flips to Firing the moment this settles in range, so nothing
    // here needs to decide when to shoot.
    //
    // Only one distance is left. GetApproachRange - the tighter walking goal -
    // was only ever needed to give MoveChase a stand-off to aim at, and there
    // is no stand-off now: the bot walks at the mob and the poll stops it.
    const float inPosition = strategy->GetInPositionRange();

    if (distance > inPosition)
    {
        std::ostringstream step;
        step << "closing: " << (int)distance << "y, need " << (int)inPosition << "y";
        strategy->TellStep(step.str());

        // Progress, not just motion.
        //
        // Do not re-issue while a move is genuinely under way: each call is a
        // fresh path, and against a moving target that is a bot re-deciding
        // instead of arriving. But "moving" is not "closing" - a bot can carry
        // the moving flag while the distance never changes, and then this guard
        // traps it forever. So it yields once the approach stops making ground,
        // and the move is asked for again.
        strategy->NoteApproachProgress(distance);

        const bool stalled = strategy->IsApproachStalled();
        if (sServerFacade.isMoving(bot) && !stalled)
        {
            SetDuration(PullTuning::PollInterval);
            return true;
        }

        if (stalled)
        {
            std::ostringstream stuck;
            stuck << "not getting closer at " << (int)distance << "y - asking again";
            strategy->TellStep(stuck.str());

            ai->StopMoving();
            strategy->ResetApproachProgress();
        }

        // Poll AFTER the move, never before.
        //
        // MoveTo calls WaitForReach, and WaitForReach calls SetDuration on THIS
        // action with the whole remaining travel time, capped at maxWaitForMove
        // - three seconds. Setting the poll first achieved nothing: the move
        // overwrote it on the way out, ListenAndExecute applied the travel time,
        // and the bot sailed from 30 yards to 16 without a single check.
        const bool moving = walkToward();
        SetDuration(PullTuning::PollInterval);
        return moving;
    }

    // Close enough but still drifting - settle, so the shot can be cast.
    if (sServerFacade.isMoving(bot))
    {
        std::ostringstream step;
        step << "in range at " << (int)distance << "y, stopping to fire";
        strategy->TellStep(step.str());
        ai->StopMoving();
        SetDuration(sPlayerbotAIConfig.reactDelay);
        return true;
    }

    // In position and still, and the shot is genuinely not available - line of
    // sight, or ammo that does not match the weapon. Convert rather than stand
    // there.
    //
    // ASK, do not infer. This used to reason "GetPullState would have said
    // Firing if we could shoot, so reaching here proves we cannot" - which is
    // only true if this action can never run a tick late, and it can. Every
    // ranged pull became a body pull on the strength of that inference.
    if (!strategy->CanDoRangedPull(target))
    {
        strategy->TellStep("can't open from here - closing in to pull with my body");
        strategy->SetPullMode(PullMode::Body);
    }

    return true;
}

bool PullHoldAction::Execute(Event& event)
{
    PullStrategy* strategy = PullStrategy::Get(ai);
    if (!strategy)
        return false;

    if (!strategy->IsHolding())
    {
        strategy->OnHoldStarted();
        strategy->TellStep("home - holding the anchor");
    }

    // Stand still. Auto-attack keeps running on its own timer and "melee" is
    // let through the pull multiplier, so holding still is a position decision,
    // not a decision to stop fighting - a tank that refuses to swing for five
    // seconds hands its threat to whoever opened.
    if (sServerFacade.isMoving(bot))
    {
        ai->StopMoving();
    }

    // Face what is coming.
    //
    // Safe here in a way it was not for the backpedal: the bot is standing
    // still, so setting orientation directly is not fighting a spline for
    // control. It is also worth more than it looks - melee auto-attack tests
    // HasInArc, so a tank holding with its back to the incoming mob would take
    // the first hits without returning any.
    if (Unit* target = strategy->GetTarget())
    {
        const float angle = bot->GetAngle(target);

        // Only when it has actually drifted. This runs every tick, and each
        // update is a heartbeat to every client that can see the bot.
        if (fabs(bot->GetOrientation() - angle) > 0.1f)
        {
            sServerFacade.SetFacingTo(bot, angle, true);
        }
    }

    SetDuration(sPlayerbotAIConfig.reactDelay);
    return true;
}

bool PullEndAction::Execute(Event& event)
{
    PullStrategy* strategy = PullStrategy::Get(ai);
    if (strategy)
    {
        // Say WHY the pull ended, worked out before OnPullEnded() wipes the
        // state it is read from. The three endings look identical from the
        // chat frame and mean completely different things: the hold did its
        // job, the hold ran out, or the whole pull hit its failsafe.
        //
        // Attackers first: if something is swinging, that is the early break
        // regardless of whether the hold also happened to expire this tick.
        //
        // Except a dead target, which outranks even that - it is the reason the
        // pull is ending, and every other line here would misdescribe it.
        Unit* endTarget = strategy->GetTarget();
        if (!endTarget || !endTarget->IsAlive())
        {
            strategy->TellStep("target is dead - pull over");
        }
        else if (strategy->IsInMeleeContact())
        {
            strategy->TellStep("target close enough - hold broken early");
        }
        else if (strategy->HasHoldExpired())
        {
            strategy->TellStep("nobody came - going to get them");
        }
        else if ((time(0) - strategy->GetPullStartTime()) >= strategy->GetMaxPullTime())
        {
            strategy->TellStep("timed out - giving up on the pull");
        }
        else
        {
            strategy->TellStep("pull over");
        }

        TearDownPull(ai, strategy);
        return true;
    }

    return false;
}