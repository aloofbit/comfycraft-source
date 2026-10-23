#pragma once
#include "playerbot/strategy/Value.h"
#include "PartyMemberValue.h"

namespace ai
{
    class PartyMemberToDispel : public PartyMemberValue, public Qualified
	{
	public:
        PartyMemberToDispel(PlayerbotAI* ai, std::string name = "party member to dispel", bool lossOfControlOnly = false) :
          PartyMemberValue(ai, name), Qualified(), lossOfControlOnly(lossOfControlOnly) {}

    protected:
        virtual Unit* Calculate() override;

        // Only sleep, stun, fear, polymorph and charm.
        bool lossOfControlOnly;
	};
}
