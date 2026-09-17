
#include "playerbot/playerbot.h"
#include "playerbot/strategy/generic/PullTuning.h"
#include "playerbot/PlayerbotAIConfig.h"
#include "playerbot/ServerFacade.h"
#include "playerbot/strategy/PassiveMultiplier.h"
#include "playerbot/strategy/values/PositionValue.h"
#include "PullStrategy.h"

using namespace ai;

class PullStrategyActionNodeFactory : public NamedObjectFactory<ActionNode>
{
public:
    PullStrategyActionNodeFactory()
    {
        creators["pull start"] = &pull_start;
    }

private:
    static ActionNode* pull_start(PlayerbotAI* ai)
    {
        return new ActionNode("pull start",
            /*P*/ NULL,
            /*A*/ NULL,
            /*C*/ NextAction::array(0, new NextAction("pull action", ACTION_NORMAL), NULL));
    }
};

PullStrategy::PullStrategy(PlayerbotAI* ai, std::string pullAction, std::string prePullAction)
: Strategy(ai)
, pullActionName(pullAction)
, preActionName(prePullAction)
, pendingToStart(false)
, pullMade(false)
, petReactStateSaved(false)
, preparationDone(false)
, pullMode(PullMode::Ranged)
, holdStartTime(0)
, pullMadeTime(0)
, lastApproachDistance(0.0f)
, lastApproachProgress(0)
, lastReportedState(PullState::None)
, lastCalledOutState(PullState::None)
, stagedAtAnchor(false)
, pullStartTime(0)
, petReactState(REACT_DEFENSIVE)
{
    actionNodeFactories.Add(std::make_unique<PullStrategyActionNodeFactory>());

    if (!ai->GetBot())
        return;
}

std::string PullStrategy::GetPullActionName() const
{
    std::string modPullActionName = pullActionName;

    // Select the faerie fire based on druid strategy
    if (ai->GetBot()->getClass() == CLASS_DRUID)
    {
        if (modPullActionName == "faerie fire")
        {
            if (ai->HasSpell("faerie fire (feral)") && (ai->HasStrategy("tank feral", BotState::BOT_STATE_COMBAT) || ai->HasStrategy("dps feral", BotState::BOT_STATE_COMBAT)))
            {
                modPullActionName = "faerie fire (feral)";
            }
        }
    }

    return modPullActionName;
}

std::string PullStrategy::GetSpellName() const
{
    std::string spellName = GetPullActionName();
    if (spellName == "shoot")
    {
        const Item* equippedWeapon = ai->GetBot()->GetItemByPos(INVENTORY_SLOT_BAG_0, EQUIPMENT_SLOT_RANGED);
        if (equippedWeapon)
        {
            const ItemPrototype* itemPrototype = equippedWeapon->GetProto();
            if (itemPrototype)
            {
                switch (itemPrototype->SubClass)
                {
#ifdef MANGOSBOT_ZERO
                    case ITEM_SUBCLASS_WEAPON_GUN:
                    {
                        spellName += " gun";
                        break;
                    }

                    case ITEM_SUBCLASS_WEAPON_BOW:
                    {
                        spellName += " bow";
                        break;
                    }

                    case ITEM_SUBCLASS_WEAPON_CROSSBOW:
                    {
                        spellName += " crossbow";
                        break;
                    }
#endif
                    case ITEM_SUBCLASS_WEAPON_THROWN:
                    {
                        spellName = "throw";
                        break;
                    }

                    default: break;
                }
            }
        }
    }

    return spellName;
}

float PullStrategy::GetRange() const
{
    float range;

    // Try to get the pull action range
    if (ai->GetSpellRange(GetSpellName(), &range))
    {
        range -= CONTACT_DISTANCE;
    }
    else
    {
        // Set the default range if the range was not found
        range = (pullActionName == "shoot") ? ai->GetRange("shoot") : ai->GetRange("spell");
    }

    return range;
}

std::string PullStrategy::GetPreActionName() const
{
    std::string modPullActionName = preActionName;

    // Select the faerie fire based on druid strategy
    if (ai->GetBot()->getClass() == CLASS_DRUID)
    {
        if (modPullActionName == "dire bear form")
        {
            if (GetPullActionName() == "faerie fire")
            {
                modPullActionName.clear();
            }
        }
    }

    return modPullActionName;
}

void PullStrategy::InitCombatTriggers(std::list<TriggerNode*>& triggers)
{
    // One trigger per state, every one of them a single test of GetPullState().
    //
    // They are all pushed at the same relevance ON PURPOSE. Relevance is what
    // resolves competition, and there is none left to resolve: the states are
    // mutually exclusive, so at most one of these can be active on any tick.
    // If two ever fire together that is a bug in GetPullState, and it should be
    // fixed there rather than by out-bidding one with the other.
    triggers.push_back(new TriggerNode(
        "pull prepare",
        NextAction::array(0, new NextAction("pull start", ACTION_MOVE), NULL)));

    triggers.push_back(new TriggerNode(
        "pull stage",
        NextAction::array(0, new NextAction("return to pull position", ACTION_MOVE), NULL)));

    triggers.push_back(new TriggerNode(
        "pull approach",
        NextAction::array(0, new NextAction("pull approach", ACTION_MOVE), NULL)));

    triggers.push_back(new TriggerNode(
        "pull fire",
        NextAction::array(0, new NextAction("pull action", ACTION_MOVE), NULL)));

    triggers.push_back(new TriggerNode(
        "pull return",
        NextAction::array(0, new NextAction("return to pull position", ACTION_MOVE), NULL)));

    triggers.push_back(new TriggerNode(
        "pull hold",
        NextAction::array(0, new NextAction("pull hold", ACTION_MOVE), NULL)));

    triggers.push_back(new TriggerNode(
        "pull finish",
        NextAction::array(0, new NextAction("pull end", ACTION_MOVE), NULL)));
}

void PullStrategy::InitNonCombatTriggers(std::list<TriggerNode*>& triggers)
{
    InitCombatTriggers(triggers);

    // ShouldPullTrigger is restrictive enough - dungeon, tank, grouped, nobody
    // fighting, healer with mana, a reachable target - that it can afford a high
    // relevance. Without one it loses to whatever the bot does while idle, which
    // is the behaviour this is meant to replace.
    triggers.push_back(new TriggerNode(
        "should pull",
        NextAction::array(0, new NextAction("pull nearest target", ACTION_HIGH), NULL)));
}

void PullStrategy::InitCombatMultipliers(std::list<Multiplier*>& multipliers)
{
    multipliers.push_back(new PullMultiplier(ai));
}

void PullStrategy::InitNonCombatMultipliers(std::list<Multiplier*>& multipliers)
{
    InitCombatMultipliers(multipliers);
}

PullStrategy* PullStrategy::Get(PlayerbotAI* ai)
{
    return ai ? ai->GetStrategy<PullStrategy>("pull", BotState::BOT_STATE_COMBAT) : nullptr;
}

bool PullStrategy::IsGroupPullRunning(PlayerbotAI* ai)
{
    Player* bot = ai ? ai->GetBot() : nullptr;
    if (!bot)
        return false;

    Group* group = bot->GetGroup();
    if (!group)
        return false;

    for (GroupReference* ref = group->GetFirstMember(); ref; ref = ref->next())
    {
        Player* member = ref->getSource();
        if (!member || member == bot)
            continue;

        if (!member->IsInWorld() || member->GetMapId() != bot->GetMapId())
            continue;

        // A DEAD TANK IS NOT PULLING. Its combat engine has stopped running, so
        // nothing will ever execute `pull end` for it and HasPullStarted stays
        // true for good - which held the entire group in place indefinitely.
        if (!member->IsAlive())
            continue;

        PlayerbotAI* memberAi = GetBotAI(member);
        if (!memberAi)
            continue;

        PullStrategy* pull = PullStrategy::Get(memberAi);
        if (!pull || !pull->HasPullStarted())
            continue;

        // AND THE HOLD CANNOT OUTLIVE THE PULL'S OWN BUDGET.
        //
        // pullStartTime is cleared by OnPullEnded and by nothing else, so every
        // way a pull can stop without running `pull end` - the tank dying,
        // zoning, being dismissed mid-pull - used to leave the rest of the
        // group waiting on a pull that no longer exists. Reading the clock here
        // rather than trusting the flag means the worst case is that everyone
        // waits out the same 15 seconds the pull itself is allowed, and then
        // goes, whatever state the tank got stuck in.
        if (time(0) - pull->GetPullStartTime() >= (time_t)GetMaxPullTime())
            continue;

        return true;
    }

    return false;
}

Unit* PullStrategy::GetTarget() const
{
    AiObjectContext* context = ai->GetAiObjectContext();
    return AI_VALUE(Unit*, "pull target");
}

void PullStrategy::SetTarget(Unit* target)
{
    AiObjectContext* context = ai->GetAiObjectContext();
    SET_AI_VALUE(Unit*, "pull target", target);
}

bool PullStrategy::CanDoRangedPull(Unit* target)
{
    return CanDoPullAction(target);
}

bool PullStrategy::CanDoPullAction(Unit* target)
{
    // Check if the bot can perform the pull action

    // check if has ranged weapon
    if (ai->GetBot()->getClass() != CLASS_DRUID && ai->GetBot()->getClass() != CLASS_PALADIN && !ai->GetBot()->GetItemByPos(INVENTORY_SLOT_BAG_0, EQUIPMENT_SLOT_RANGED))
        return false;

    bool canPull = false;
    const std::string& pullAction = GetPullActionName();
    if (!pullAction.empty())
    {
        // Temporarily set the pull target to be used by the can do specific action method
        AiObjectContext* context = ai->GetAiObjectContext();
        Unit* previousTarget = GetTarget();
        SetTarget(target);

        canPull = ai->CanDoSpecificAction("pull action", true, false);

        // Restore the previous pull target
        SetTarget(previousTarget);
    }

    return canPull;
}


void PullStrategy::OnPullStarted()
{
    pendingToStart = false;
}

const char* PullStrategy::PullStateName(PullState state)
{
    switch (state)
    {
        case PullState::None:        return "None";
        case PullState::Preparing:   return "Preparing";
        case PullState::Staging:     return "Staging";
        case PullState::Approaching: return "Approaching";
        case PullState::Firing:      return "Firing";
        case PullState::Returning:   return "Returning";
        case PullState::Holding:     return "Holding";
        case PullState::Finishing:   return "Finishing";
    }

    return "?";
}

void PullStrategy::CallOut(PullState state) const
{
    if (state == lastCalledOutState)
        return;

    // Only the three moments the rest of the group needs. Approaching and
    // Firing are both "still pulling" from a healer's point of view, and
    // Preparing is over before anyone could act on it.
    std::string line;
    switch (state)
    {
        case PullState::Approaching:
        {
            Unit* target = GetTarget();
            line = target ? ("Pulling " + std::string(target->GetName())) : "Pulling";
            break;
        }

        case PullState::Firing:
        {
            // Only if we did not already say it while walking in - a pull that
            // starts in range goes straight here.
            if (lastCalledOutState == PullState::Approaching)
                return;

            Unit* target = GetTarget();
            line = target ? ("Pulling " + std::string(target->GetName())) : "Pulling";
            break;
        }

        case PullState::Holding:
            line = "Waiting - hold off";
            break;

        case PullState::Staging:
            // Nothing to say. Walking to the group is not news, and the pull
            // has not started yet.
            lastCalledOutState = state;
            return;

        case PullState::Finishing:
        {
            // "Help!" means the pull worked and the fight is arriving. A pull
            // that timed out, or never got made at all, delivered nothing - and
            // calling the group in on nothing is worse than saying nothing,
            // because they break position for it.
            //
            // A dead target is its own ending and reads differently from both:
            // nothing is coming, and nothing went wrong either.
            Unit* endTarget = GetTarget();
            if (!endTarget || !endTarget->IsAlive())
            {
                line = "Target's dead - hold";
                break;
            }

            if (!pullMade || HasTimedOut())
            {
                line = "Pull failed - hold";
                break;
            }

            line = "Help!";
            break;
        }

        default:
            // None, Preparing, Returning: nothing anyone needs to act on. The
            // walk back is not a cue, because coming in while the tank is still
            // moving is exactly what the pull is trying to prevent.
            lastCalledOutState = state;
            return;
    }

    lastCalledOutState = state;

    // Only worth saying to a group. Strategy has no `bot` member of its own -
    // that is an Action thing - so ask the AI for it.
    if (ai->GetBot() && ai->GetBot()->GetGroup())
    {
        ai->SayToParty(line);
    }
}

void PullStrategy::TellStep(const std::string& step) const
{
    if (!ai->HasStrategy("pull debug", BotState::BOT_STATE_COMBAT))
        return;

    if (step == lastStep)
        return;

    lastStep = step;

    Player* master = ai->GetMaster();
    if (master)
    {
        std::ostringstream out;
        out << "[pull] " << step;
        ai->TellPlayerNoFacing(master, out.str());
    }
}

bool PullStrategy::HasAnchor() const
{
    AiObjectContext* context = ai->GetAiObjectContext();
    return AI_VALUE(PositionMap&, "position")["pull"].isSet();
}

bool PullStrategy::IsAtAnchor() const
{
    AiObjectContext* context = ai->GetAiObjectContext();
    PositionEntry anchor = AI_VALUE(PositionMap&, "position")["pull"];
    if (!anchor.isSet())
        return true;    // nowhere to go back to counts as home

    Player* bot = ai->GetBot();
    return bot->GetDistance(anchor.x, anchor.y, anchor.z) <= PullTuning::AnchorTolerance;
}

bool PullStrategy::IsInFiringPosition() const
{
    Unit* target = GetTarget();
    if (!target)
        return false;

    // Standing still matters as much as the distance: a ranged opener cannot
    // be cast while moving, so "in position" means arrived, not merely close.
    Player* bot = ai->GetBot();
    if (sServerFacade.isMoving(bot))
        return false;

    return target->GetDistance(bot) <= GetInPositionRange();
}

bool PullStrategy::IsUnderAttack() const
{
    // "Something has decided to attack me" - true from the moment the pull
    // lands, at any distance. This is the AGGRO test, and it is what the body
    // pull wants: it means the walk-in worked.
    return !ai->GetBot()->getAttackers().empty();
}

bool PullStrategy::IsInMeleeContact() const
{
    // "Something is actually swinging at me" - which is a different question,
    // and the one the hold needs.
    //
    // getAttackers() is filled by Unit::Attack() with no distance test at all,
    // so it goes true the instant the pulled mob aggros - before the tank has
    // even turned for home. Using it to break the hold meant the hold ended the
    // moment the tank arrived and the five seconds never ran once. It also made
    // the report read "target close enough" when the target could still be
    // thirty yards away.
    Player* bot = ai->GetBot();
    for (Unit* attacker : bot->getAttackers())
    {
        if (attacker && attacker->IsAlive() && attacker->CanReachWithMeleeAttack(bot))
            return true;
    }

    return false;
}

void PullStrategy::ResetApproachProgress()
{
    lastApproachDistance = 0.0f;
    lastApproachProgress = 0;
}

void PullStrategy::NoteApproachProgress(float distance)
{
    // First look, or genuinely closer than the best seen so far.
    //
    // Half a yard of slop, so ordinary jitter in the distance does not read as
    // progress and keep resetting the clock on a bot that is really stuck.
    if (!lastApproachProgress || distance < lastApproachDistance - 0.5f)
    {
        lastApproachDistance = distance;
        lastApproachProgress = time(0);
    }
}

bool PullStrategy::IsApproachStalled() const
{
    if (!lastApproachProgress)
        return false;

    return (time(0) - lastApproachProgress) >= 2;
}

bool PullStrategy::HasTimedOut() const
{
    // Two budgets, not one clock for the whole thing.
    //
    // The failsafe is there to abandon a pull that never happens. Measured from
    // the order for the WHOLE pull, a slow one spent its budget getting there -
    // a ranged approach that fails, converts to a body pull and walks in again
    // can eat fifteen seconds before it has aggro - and then the walk home had
    // none left, so the pull ended on the spot and the tank simply fought where
    // it stood.
    //
    // So: getting the pull made has a budget, and having made it, coming home
    // gets its own.
    if (pullMade)
        return pullMadeTime && (time(0) - pullMadeTime) >= (time_t)GetMaxPullTime();

    return pullStartTime && (time(0) - pullStartTime) >= (time_t)GetMaxPullTime();
}

PullState PullStrategy::GetPullState() const
{
    const PullState state = ComputePullState();

    // Say so when it actually changes. Every bug in this pull has been a
    // disagreement about which state it is in, and until now the trace showed
    // only which ACTION won - leaving the state itself to be inferred from
    // that, which is exactly the inference that keeps turning out wrong.
    if (state != lastReportedState)
    {
        lastReportedState = state;
        TellStep(std::string("state: ") + PullStateName(state));
    }

    // Separate from the trace above on purpose: the group hears three lines a
    // pull, whether or not anyone is debugging.
    CallOut(state);

    return state;
}

PullState PullStrategy::ComputePullState() const
{
    if (!HasPullStarted())
        return PullState::None;

    // No target left - nothing to pull, so stop pretending.
    //
    // A CORPSE IS NOT A NULL POINTER. "pull target" holds a guid and resolves
    // it through the object accessor, which keeps answering for as long as the
    // body is on the ground - tens of seconds, far past the 15s failsafe. So a
    // target that died early (somebody else's aoe, a passing player, the pull
    // itself landing on something nearly dead) left the tank walking the whole
    // sequence over a corpse and then calling the group in with "Pull failed".
    // Dead is exactly as good a reason to stop as gone.
    Unit* target = GetTarget();
    if (!target || !target->IsAlive())
        return PullState::Finishing;

    // The failsafe outranks everything: whatever the pull thinks it is doing,
    // fifteen seconds is the whole budget.
    if (HasTimedOut())
        return PullState::Finishing;

    if (!preparationDone)
        return PullState::Preparing;

    if (!pullMade)
    {
        // Start the pull FROM the anchor - ONCE.
        //
        // The anchor is where the group is standing and the walk home is
        // measured to it, so leaving from anywhere else means walking back to a
        // spot the tank was never at, over a distance nobody chose.
        //
        // Latched, because this is a step and not a condition. "Not at the
        // anchor" stays true for the whole approach, so testing it directly
        // sent the bot home the moment it set off, then out again, then home,
        // until the failsafe. Once it has stood on the anchor it is staged, and
        // walking away from it is the pull working.
        if (!stagedAtAnchor)
        {
            if (!IsAtAnchor())
                return PullState::Staging;

            stagedAtAnchor = true;
        }

        // A body pull has nothing to fire, so it stays in Approaching until it
        // takes aggro - which is what sets pullMade for that mode.
        if (pullMode == PullMode::Body)
            return PullState::Approaching;

        return IsInFiringPosition() ? PullState::Firing : PullState::Approaching;
    }

    // Do not walk away from a shot that has not gone off yet.
    //
    // CastSpellAction::Execute returns true when the cast STARTS, so pullMade
    // is set while the opener is still in the air - and moving cancels a ranged
    // cast, so the tank was interrupting its own pull and then walking home
    // from a mob it had not hit.
    if (ai->GetBot()->IsNonMeleeSpellCasted(true))
        return PullState::Firing;

    if (!IsAtAnchor())
        return PullState::Returning;

    // Home. The hold owns the rest, and ends on contact or on time.
    if (IsInMeleeContact() || HasHoldExpired())
        return PullState::Finishing;

    return PullState::Holding;
}


bool PullStrategy::HasHoldExpired() const
{
    if (!holdStartTime)
        return false;

    return (time(0) - holdStartTime) >= (time_t)PullTuning::HoldSeconds;
}

void PullStrategy::OnPullMade()
{
    pullMade = true;
    pullMadeTime = time(0);
    pendingToStart = false;
}

void PullStrategy::OnPullEnded()
{
    pullStartTime = 0;
    pendingToStart = false;
    pullMade = false;
    petReactStateSaved = false;
    preparationDone = false;
    pullMode = PullMode::Ranged;
    holdStartTime = 0;
    pullMadeTime = 0;
    ResetApproachProgress();
    stagedAtAnchor = false;
    SetTarget(nullptr);
}

void PullStrategy::RequestPull(Unit* target, bool resetTime)
{
    SetTarget(target);
    pendingToStart = true;
    if(resetTime)
    {
        pullStartTime = time(0);
    }
}

float PullMultiplier::GetValue(Action* action)
{
    PullStrategy* strategy = PullStrategy::Get(ai);
    if (!strategy || strategy->GetPullState() == PullState::None)
        return 1.0f;

    // A gate, not a weight.
    //
    // This used to scale relevance and let a few things through at 0.01 for
    // emergencies. That is not suppression, it is a discount: with everything
    // else multiplied to nothing, an action pushed at 100 still came out at 1.0
    // and won the tick. Twice that was how "reach melee" walked the tank back
    // into the fight it had just pulled out of.
    //
    // While a pull is running the only legal actions are the pull's own, plus
    // swinging at whatever is already in reach. Everything else is zero, bar
    // the loot release below.
    const std::string& name = action->getName();

    if ((name == "pull start") ||
        (name == "pull approach") ||
        (name == "pull action") ||
        (name == "return to pull position") ||
        (name == "pull hold") ||
        (name == "pull end") ||
        (name == "pull my target") ||
        (name == "pull rti target") ||
        (name == "pull nearest target"))
    {
        return 1.0f;
    }

    // Swinging is allowed, closing is not - and during Holding it is the whole
    // point: stand still, keep attacking.
    if (name == "melee")
        return 1.0f;

    // The one exception, and it is not a behaviour: "store loot" answers a loot
    // response that is already open. It does not move, and it is the only thing
    // that releases the corpse, so zeroing it (the engine discards a zeroed
    // action, it does not retry) left a tank that opened a corpse a second
    // before a pull kneeling until the loot watchdog stood it up.
    if (name == "store loot")
        return 1.0f;

    return 0.0f;
}

void PossibleAdsStrategy::InitCombatTriggers(std::list<TriggerNode*>& triggers)
{
    triggers.push_back(new TriggerNode(
        "possible ads",
        NextAction::array(0, new NextAction("flee with pet", ACTION_EMERGENCY), NULL)));
}

