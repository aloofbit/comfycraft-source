
#include "playerbot/playerbot.h"
#include "MageTriggers.h"
#include "MageActions.h"
#include "playerbot/strategy/values/PossibleAttackTargetsValue.h"

using namespace ai;

// FROST NOVA IS FOR A MOB ON THE MAGE (2026-10-21).
//
// The trigger was "enemy ten yards": the mage's own target within 10 yd, with
// nothing about who the mob hit. A tank that held its mob next to the mage met
// that, so the mage rooted the tank's mob, and the nova's damage broke any
// sheep in reach.
Unit* ai::FrostNovaTarget(PlayerbotAI* ai)
{
    Player* bot = ai->GetBot();
    const float radius = 10.0f;

    Unit* hitsMe = nullptr;
    for (Unit* attacker : bot->getAttackers())
    {
        if (attacker && attacker->IsAlive() && attacker->GetVictim() == bot && bot->IsWithinDistInMap(attacker, radius))
        {
            hitsMe = attacker;
            break;
        }
    }

    if (!hitsMe)
        return nullptr;

    // Search past the radius: a sheep walks about, and the nova lands later.
    if (PossibleAttackTargetsValue::DamageBreakableCCNear(bot, bot->GetPositionX(), bot->GetPositionY(), radius + 5.0f))
        return nullptr;

    return hitsMe;
}

bool AnyMageArmorTrigger::IsActive()
{
    Unit* target = GetTarget();
    return !ai->HasAura("ice armor", target) &&
           !ai->HasAura("frost armor", target) &&
           !ai->HasAura("molten armor", target) &&
           !ai->HasAura("mage armor", target);
}

bool MageArmorTrigger::IsActive()
{
    Unit* target = GetTarget();
    return !ai->HasAura("mage armor", target);
}

bool IceArmorTrigger::IsActive()
{
    Unit* target = GetTarget();
    return !ai->HasAura("ice armor", target) &&
           !ai->HasAura("frost armor", target);
}

bool MoltenArmorTrigger::IsActive()
{
    Unit* target = GetTarget();
    return !ai->HasAura("molten armor", target);
}

bool ManaShieldTrigger::IsActive()
{
    return !ai->HasAura("mana shield", bot) && AI_VALUE2(uint8, "mana", "self target") > sPlayerbotAIConfig.mediumMana;
}

bool IceLanceTrigger::IsActive()
{
    Unit* target = GetTarget();
    return target && ai->HasAnyAuraOf(target, "frost nova", "frostbite", NULL);
}

bool HotStreakTrigger::IsActive()
{
    //Usage by id. By name hot streak aura doesn't work.
    return ai->HasAura(48108, bot);
}

bool FireballOrFrostfireBoltFreeTrigger::IsActive()
{
    return ai->HasAura("fireball!", bot);
}

bool NoImprovedScorchDebuffTrigger::IsActive()
{
    if (bot->HasSpell(11095) || bot->HasSpell(12872) || bot->HasSpell(12873))
    {
        return DebuffTrigger::IsActive();
    }

    return false;
}