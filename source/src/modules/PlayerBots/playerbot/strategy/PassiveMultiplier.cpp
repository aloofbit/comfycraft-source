
#include "playerbot/playerbot.h"
#include "PassiveMultiplier.h"
#include "playerbot/strategy/actions/GenericSpellActions.h"
#include "playerbot/PlayerbotAI.h"

using namespace ai;

std::list<std::string> PassiveMultiplier::allowedActions;
std::list<std::string> PassiveMultiplier::allowedParts;

PassiveMultiplier::PassiveMultiplier(PlayerbotAI* ai) : Multiplier(ai, "passive")
{
    EnsureLists();
}

bool PassiveMultiplier::Allows(const std::string& name)
{
    // Static, so MovementAction::isUseful can ask before any multiplier for
    // this bot has ever been constructed.
    EnsureLists();

    for (std::list<std::string>::iterator i = allowedActions.begin(); i != allowedActions.end(); i++)
    {
        if (name == *i)
            return true;
    }

    for (std::list<std::string>::iterator i = allowedParts.begin(); i != allowedParts.end(); i++)
    {
        if (name.find(*i) != std::string::npos)
            return true;
    }

    return false;
}

void PassiveMultiplier::EnsureLists()
{
    if (allowedActions.empty())
    {
        allowedActions.push_back("co");
        allowedActions.push_back("nc");
        allowedActions.push_back("load ai");
        allowedActions.push_back("save ai");
        allowedActions.push_back("list ai");
        allowedActions.push_back("reset ai");
        allowedActions.push_back("reset strats");
        allowedActions.push_back("reset values");
        allowedActions.push_back("check mount state");
        allowedActions.push_back("accept invitation");
        allowedActions.push_back("join");
        allowedActions.push_back("lfg");

        // AN EXPLICIT ORDER TO FIGHT OUTRANKS PASSIVE, and has to be able to
        // reach the queue to say so.
        //
        // This mattered little while passive was the rare `flee` mode. Since
        // `follow` was merged into it on 2026-09-07 passive is a STANDING mode
        // - a bot told to follow stays passive until an order says otherwise -
        // so these three are the only way out. Without them the order was dead
        // on arrival: zeroed by this multiplier before it could execute, which
        // is also the only place it could have cleared passive from. Chicken
        // and egg - so let the order through here, and each action drops
        // passive as it accepts. THESE ARE THE WAY BACK; deleting one strands
        // every following bot as a pacifist.
        //
        // "pull nearest target" is deliberately NOT here. That is the dungeon
        // tank pulling on its own initiative, and a master who just said
        // "follow" has said the opposite.
        allowedActions.push_back("pull my target");
        allowedActions.push_back("pull rti target");
        allowedActions.push_back("attack my target");
    }

    if (allowedParts.empty())
    {
        allowedParts.push_back("follow");
        allowedParts.push_back("stay");
        allowedParts.push_back("chat shortcut");
    }
}

float PassiveMultiplier::GetValue(Action* action) 
{
    if (!action)
		return 1.0f;

    // A PASSIVE HEALER STILL HEALS.
    //
    // `flee` is a mode, not a movement - it adds "+passive" to both engines and
    // leaves it there (FleeChatShortcutAction). Passive then zeroes everything
    // outside the small allow-list below, which is movement and housekeeping,
    // so a healer told to retreat stopped healing entirely for as long as the
    // mode lasted. That is the moment the party is most likely to need it.
    //
    // Retreating should stop a bot FIGHTING, not stop it doing its job. Only
    // heals are excused, and only for a bot that is actually a healer, so a
    // passive dps is still properly passive. The reach action that walks it to
    // the patient is deliberately NOT excused: it heals whoever is already in
    // range and keeps running otherwise, which is what was asked for.
    if (dynamic_cast<CastHealingSpellAction*>(action) && PlayerbotAI::IsHeal(bot))
        return 1.0f;

    return Allows(action->getName()) ? 1.0f : 0.0f;
}
