
#include "playerbot/playerbot.h"
#include "PartyMemberToDispel.h"

#include "playerbot/ServerFacade.h"
using namespace ai;

class PartyMemberToDispelPredicate : public FindPlayerPredicate, public PlayerbotAIAware
{
public:
    PartyMemberToDispelPredicate(PlayerbotAI* ai, uint32 dispelType, bool lossOfControlOnly) :
        PlayerbotAIAware(ai), FindPlayerPredicate(), dispelType(dispelType), lossOfControlOnly(lossOfControlOnly) {}

public:
    virtual bool Check(Unit* unit) override
    {
        Pet* pet = dynamic_cast<Pet*>(unit);
        if (pet && (pet->getPetType() == MINI_PET || pet->getPetType() == SUMMON_PET))
            return false;

        return sServerFacade.IsAlive(unit) && sServerFacade.GetDistance2d(ai->GetBot(), unit) <= ai->GetRange("spell") && ai->HasAuraToDispel(unit, dispelType, lossOfControlOnly);
    }

private:
    uint32 dispelType;
    bool lossOfControlOnly;
};

Unit* PartyMemberToDispel::Calculate()
{
    uint32 dispelType = atoi(qualifier.c_str());

    PartyMemberToDispelPredicate predicate(ai, dispelType, lossOfControlOnly);
    return FindPartyMember(predicate);
}
