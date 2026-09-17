#pragma once
#include "playerbot/strategy/Value.h"
#include "PartyMemberValue.h"

namespace ai
{
    class PartyMemberToHeal : public PartyMemberValue
	{
	public:
        PartyMemberToHeal(PlayerbotAI* ai, std::string name = "party member to heal") :
          PartyMemberValue(ai, name) {}
    
    protected:
        virtual Unit* Calculate() override;
        bool CanHealPet(Pet* pet);
        virtual bool Check(Unit* player);

    private:
        std::vector<Player*> GetPartyMembers();
	};

    // The MOB attacking one of my party, not the party member being attacked.
    //
    // Deliberately NOT PartyMemberToProtect, which only fires once the victim is
    // under 30% health (10% for a tank). That is a "save them" emergency; this
    // is "pick the add up before it gets that far", so it has no health
    // threshold at all.
    class PartyMemberAttacker : public PartyMemberValue
    {
    public:
        PartyMemberAttacker(PlayerbotAI* ai, std::string name = "party member attacker") :
            PartyMemberValue(ai, name) {}

    protected:
        Unit* Calculate() override;
    };

    class PartyMemberToProtect : public PartyMemberValue
    {
    public:
        PartyMemberToProtect(PlayerbotAI* ai, std::string name = "party member to protect") :
            PartyMemberValue(ai, name) {}

    protected:
        virtual Unit* Calculate() override;
    };

    class PartyMemberToRemoveRoots : public PartyMemberValue
    {
    public:
        PartyMemberToRemoveRoots(PlayerbotAI* ai, std::string name = "party member to remove roots") :
            PartyMemberValue(ai, name) {}

    protected:
        virtual Unit* Calculate() override;
    };
}
