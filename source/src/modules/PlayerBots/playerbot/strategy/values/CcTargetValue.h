#pragma once
#include "playerbot/strategy/Value.h"
#include "TargetValue.h"

namespace ai
{
   
    class CcTargetValue : public TargetValue, public Qualified
	{
	public:
        CcTargetValue(PlayerbotAI* ai, std::string name = "cc target") : TargetValue(ai, name), Qualified() {}

    public:
        Unit* Calculate() override;
    };

    // Say out loud whether this bot has found something to crowd-control.
    //
    // Called when a pull or attack order lands, because that is the moment the
    // player wants to know - and because crowd control is otherwise entirely
    // silent whether it works or not. A bot that cannot cc at all says nothing.
    //
    // The whole point is that it asks THE SAME VALUE the bot will act on
    // ("cc target", qualified by the spell), rather than re-deriving the
    // answer. A report that works out its own answer can only end up
    // disagreeing with the one that matters - which is how three separate pull
    // bugs stayed hidden this week.
    void ReportCcIntent(PlayerbotAI* ai, Player* requester);

    // Has the fight actually started?
    //
    // The gate on crowd control OUT of combat, and the reason it exists is that
    // the mark alone used to be enough. See the definition.
    bool CcFightIsUnderway(PlayerbotAI* ai);
}
