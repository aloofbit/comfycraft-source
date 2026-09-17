#pragma once
#include "playerbot/strategy/Value.h"
#include "ItemUsageValue.h"
#include "BudgetValues.h"

#include <algorithm>

namespace ai
{
    class CanMoveAroundValue : public BoolCalculatedValue
    {
    public:
        CanMoveAroundValue(PlayerbotAI* ai) : BoolCalculatedValue(ai, "can move around", 2) {}
        virtual bool Calculate() override
        {
            if (bot->GetTradeData())
                return false;

            if (!AI_VALUE(bool, "group ready"))
                return false;

            if (AI_VALUE2(bool, "trigger active", "castnc"))
                return false;

            if (ai->HasStrategy("wander", BotState::BOT_STATE_NON_COMBAT))
            {
                float dist = AI_VALUE2(float, "distance", "master target");
                bool wanderTooFar = dist > ai->GetRange("wandermax");

                if (wanderTooFar)
                    return false;
            }

            return true;
        }

#ifdef GenerateBotHelp
        virtual std::string GetHelpName() { return "can move around"; } //Must equal iternal name
        virtual std::string GetHelpTypeName() { return "movement"; }
        virtual std::string GetHelpDescription() { return "This value indicates whether the bot should wait for a trade to complete, a crafting cast or for the group to have enough health/mana before moving to rpg, grind or travel targets."; }
        virtual std::vector<std::string> GetUsedValues() { return {"group ready", "trigger active"}; }
#endif 
    };

    class ShouldHomeBindValue : public BoolCalculatedValue
    {
    public:
        ShouldHomeBindValue(PlayerbotAI* ai) : BoolCalculatedValue(ai, "should home bind", 2) {}
        virtual bool Calculate() override { return AI_VALUE2(float, "distance", "home bind") > 1000.0f; };
    };


    class ShouldRepairValue : public BoolCalculatedValue
	{
	public:
        ShouldRepairValue(PlayerbotAI* ai) : BoolCalculatedValue(ai,"should repair",2) {}
        virtual bool Calculate() override { return AI_VALUE(uint8, "durability") < 30 || AI_VALUE(uint8, "lowest durability") < 10; };
    };

    class CanRepairValue : public BoolCalculatedValue
    {
    public:
        CanRepairValue(PlayerbotAI* ai) : BoolCalculatedValue(ai, "can repair",2) {}
        virtual bool Calculate() override { return  ai->HasStrategy("rpg maintenance", BotState::BOT_STATE_NON_COMBAT) && AI_VALUE(uint8, "durability inventory") < 100 && AI_VALUE(uint32, "min repair cost") < AI_VALUE2(uint32, "free money for", (uint32)NeedMoneyFor::repair); };
    };

    class ShouldSellValue : public BoolCalculatedValue
    {
    public:
        ShouldSellValue(PlayerbotAI* ai, std::string name = "should sell", int checkInterval = 2) : BoolCalculatedValue(ai, name , checkInterval) {}
        virtual bool Calculate() override { return AI_VALUE(uint8, "bag space") > 80; };
    };

    class CanSellValue : public BoolCalculatedValue
    {
    public:
        CanSellValue(PlayerbotAI* ai) : BoolCalculatedValue(ai, "can sell",2) {}
        virtual bool Calculate() override { return ai->HasStrategy("rpg vendor", BotState::BOT_STATE_NON_COMBAT) && AI_VALUE2(uint32, "item count", "usage " + std::to_string((uint8)ItemUsage::ITEM_USAGE_VENDOR)) > 0; };
    };

    class CanBuyValue : public BoolCalculatedValue
    {
    public:
        CanBuyValue(PlayerbotAI* ai) : BoolCalculatedValue(ai, "can buy", 2) {}
        virtual bool Calculate() override { return ai->HasStrategy("rpg vendor", BotState::BOT_STATE_NON_COMBAT) && !AI_VALUE(bool, "should repair") && AI_VALUE(uint8, "bag space") < 90 && !AI_VALUE(bool, "can get mail") && (AI_VALUE2(uint32, "free money for", (uint32)NeedMoneyFor::ammo) || AI_VALUE2(uint32, "free money for", (uint32)NeedMoneyFor::consumables) || AI_VALUE2(uint32, "free money for", (uint32)NeedMoneyFor::gear) || AI_VALUE2(uint32, "free money for", (uint32)NeedMoneyFor::tradeskill)); };
    };

    class ShouldAHSellValue : public ShouldSellValue
    {
    public:
        ShouldAHSellValue(PlayerbotAI* ai) : ShouldSellValue(ai, "should ah sell", 2) {}
        virtual bool Calculate() override;
    };

    class CanAHSellValue : public BoolCalculatedValue
    {
    public:
        CanAHSellValue(PlayerbotAI* ai) : BoolCalculatedValue(ai, "can ah sell", 2) {}
        virtual bool Calculate() override { return ai->HasStrategy("rpg vendor", BotState::BOT_STATE_NON_COMBAT) && AI_VALUE2(uint32, "item count", "usage " + std::to_string((uint8)ItemUsage::ITEM_USAGE_AH)) > 1 && AI_VALUE2(uint32, "free money for", (uint32)NeedMoneyFor::ah) > GetAuctionDeposit(); };

        uint32 GetAuctionDeposit()
        {
            float minDeposit = 0;
            for (auto item : AI_VALUE2(std::list<Item*>, "inventory items", "usage " + std::to_string((uint8)ItemUsage::ITEM_USAGE_AH)))
            {
                uint32 deposit = ItemUsageValue::GetAhDepositCost(item->GetProto(), item->GetCount());

                if (minDeposit == 0 || deposit < minDeposit)
                    minDeposit = deposit;
            }

            return minDeposit;
        }
    };

    class CanAHBuyValue : public BoolCalculatedValue
    {
    public:
        CanAHBuyValue(PlayerbotAI* ai) : BoolCalculatedValue(ai, "can ah buy", 2) {}
        virtual bool Calculate() override { return ai->HasStrategy("rpg vendor", BotState::BOT_STATE_NON_COMBAT) && !AI_VALUE(bool, "should repair") && !AI_VALUE(bool, "should sell") && !AI_VALUE(bool, "can get mail") && AI_VALUE2(uint32, "free money for", (uint32)NeedMoneyFor::ah) > 0; };
    };


    class CanGetMailValue : public BoolCalculatedValue
    {
    public:
        CanGetMailValue(PlayerbotAI* ai) : BoolCalculatedValue(ai, "can get mail", 2) {}
        virtual bool Calculate() override;
    };

    class ShouldGetMailValue : public BoolCalculatedValue
    {
    public:
        ShouldGetMailValue(PlayerbotAI* ai) : BoolCalculatedValue(ai, "should get mail", 60) {}
        virtual bool Calculate() override;
    };

    class CanFightEqualValue: public BoolCalculatedValue
    {
    public:
        CanFightEqualValue(PlayerbotAI* ai) : BoolCalculatedValue(ai, "can fight equal",2) {}
        virtual bool Calculate() override { return AI_VALUE(uint8, "durability") > 20 && !ai->HasAura(SPELL_ID_PASSIVE_RESURRECTION_SICKNESS,bot); };
    };

    class CanFightEliteValue : public BoolCalculatedValue
    {
    public:
        CanFightEliteValue(PlayerbotAI* ai) : BoolCalculatedValue(ai, "can fight elite", 2) {}
        virtual bool Calculate() override { return bot->GetGroup() && AI_VALUE2(bool, "group and", "can fight equal") && AI_VALUE2(bool, "group and", "following party") && !AI_VALUE2(bool, "group or", "should sell,can sell"); };
    };

    class CanFightBossValue : public BoolCalculatedValue
    {
    public:
        CanFightBossValue(PlayerbotAI* ai) : BoolCalculatedValue(ai, "can fight boss", 2) {}
        virtual bool Calculate() override { return bot->GetGroup() && bot->GetGroup()->GetMembersCount() > 3 && AI_VALUE2(bool, "group and", "can fight equal") && AI_VALUE2(bool, "group and", "following party") && !AI_VALUE2(bool, "group or", "should sell,can sell"); };
    };        

    class ShouldDrinkValue : public BoolCalculatedValue
    {
    public:
        ShouldDrinkValue(PlayerbotAI* ai) : BoolCalculatedValue(ai, "should drink", 2) {}
        virtual bool Calculate() override
        {
            if (!bot->HasMana())
                return false;

            if (AI_VALUE2(uint8, "mana", "self target") >= sPlayerbotAIConfig.drinkAtMana)
                return false;

            Player* master = ai->GetMaster();
            if (!master)
                return true;

            if (!bot->GetGroup())
                return true;

            if (!(ai->HasStrategy("follow", BotState::BOT_STATE_NON_COMBAT) ||
                ai->HasStrategy("wander", BotState::BOT_STATE_NON_COMBAT)))
                return true;

            if (!bot->IsWithinDist(master, sPlayerbotAIConfig.EatDrinkMaxDistance))
                return true;

            if (!master->IsMoving())
                return true;

            float minDistance = sPlayerbotAIConfig.EatDrinkMinDistance;
            if (!bot->GetGroup()->IsRaidGroup())
                minDistance += sPlayerbotAIConfig.followDistance;
            else
                minDistance += sPlayerbotAIConfig.raidFollowDistance;
            
            if (bot->IsWithinDist(master, minDistance))
                return true;

            return false;
        }
    };

    class ShouldEatValue : public BoolCalculatedValue
    {
    public:
        ShouldEatValue(PlayerbotAI* ai) : BoolCalculatedValue(ai, "should eat", 2) {}
        virtual bool Calculate() override
        {
            if (AI_VALUE2(uint8, "health", "self target") >= sPlayerbotAIConfig.eatAtHealth)
                return false;

            Player* master = ai->GetMaster();
            if (!master)
                return true;

            if (!bot->GetGroup())
                return true;

            if (!(ai->HasStrategy("follow", BotState::BOT_STATE_NON_COMBAT) ||
                ai->HasStrategy("wander", BotState::BOT_STATE_NON_COMBAT)))
                return true;

            if (!bot->IsWithinDist(master, sPlayerbotAIConfig.EatDrinkMaxDistance))
                return true;

            if (!master->IsMoving())
                return true;

            float minDistance = sPlayerbotAIConfig.EatDrinkMinDistance;
            if (!bot->GetGroup()->IsRaidGroup())
                minDistance += sPlayerbotAIConfig.followDistance;
            else
                minDistance += sPlayerbotAIConfig.raidFollowDistance;

            if (bot->IsWithinDist(master, minDistance))
                return true;

            return false;
        }
    };

    class DrinkDurationValue : public FloatCalculatedValue
    {
    public:
        DrinkDurationValue(PlayerbotAI* ai) : FloatCalculatedValue(ai, "drink duration") {}
        virtual float Calculate() override
        {
            Player* master = ai->GetMaster();

            // How long to sit. This has to match what the drink actually
            // does, because the bot now really sits down and standing up
            // cancels the aura (AURA_INTERRUPT_FLAG_NOT_SEATED) -- sitting for
            // less time than the mana takes just means standing up half fed.
            //
            // Drink (24355) restores AiPlayerbot.BotEatDrinkPercentPerSecond
            // of max mana per second, so a full top up is 100/that seconds --
            // 50 at the DBC's own 2%, which is where the 50000 this used to
            // hardcode came from. Derived rather than written down, because a
            // raised rate that does not shorten the sit leaves the bot sitting
            // on a finished meal. Capped at the aura's own 30s duration
            // (SpellDuration.dbc index 9): past that it is sitting on an
            // expired buff. In a battleground the sit is deliberately cut to
            // 40% of a full one instead.
            float mpMissingPct = 100.0f - bot->GetPowerPercent();
            float fullTopUp = (100.0f / (float)sPlayerbotAIConfig.botEatDrinkPercentPerSecond) * 1000.0f;
            float multiplier = bot->InBattleGround() ? fullTopUp * 0.4f : fullTopUp;
            float drinkDuration = std::min(multiplier * (mpMissingPct / 100.0f), 30000.0f);

            if (!master)
                return drinkDuration;

            if (!bot->GetGroup())
                return drinkDuration;

            if (!(ai->HasStrategy("follow", BotState::BOT_STATE_NON_COMBAT) ||
                ai->HasStrategy("wander", BotState::BOT_STATE_NON_COMBAT)))
                return drinkDuration;

            float minDistance = sPlayerbotAIConfig.followDistance;

            if (bot->GetGroup()->IsRaidGroup())
                minDistance = sPlayerbotAIConfig.raidFollowDistance;

            if (!master->IsMoving())
                minDistance += sPlayerbotAIConfig.EatDrinkMinDistance;

            if (bot->IsWithinDist(master, minDistance))
                return drinkDuration;

            float masterOrientation = master->GetOrientation();
            float angleToBot = master->GetAngle(bot);
            float angleDiff = fabs(masterOrientation - angleToBot);

            if (angleDiff > M_PI / 2 && angleDiff < 3 * M_PI / 2)
            {
                drinkDuration *= 0.25f;
            }
            return drinkDuration;
        }
    };

    class EatDurationValue : public FloatCalculatedValue
    {
    public:
        EatDurationValue(PlayerbotAI* ai) : FloatCalculatedValue(ai, "eat duration") {}
        virtual float Calculate() override
        {
            Player* master = ai->GetMaster();

            // As for drink duration above. Food (24005) runs at the same
            // configured percent per second, capped here at its own 25s aura
            // (SpellDuration.dbc index 63) rather than drink's 30s.
            float hpMissingPct = 100.0f - bot->GetHealthPercent();
            float fullTopUp = (100.0f / (float)sPlayerbotAIConfig.botEatDrinkPercentPerSecond) * 1000.0f;
            float multiplier = bot->InBattleGround() ? fullTopUp * 0.4f : fullTopUp;
            float eatDuration = std::min(multiplier * (hpMissingPct / 100.0f), 25000.0f);
          
            if (!master)
                return eatDuration;

            if (!bot->GetGroup())
                return eatDuration;

            if (!(ai->HasStrategy("follow", BotState::BOT_STATE_NON_COMBAT) ||
                ai->HasStrategy("wander", BotState::BOT_STATE_NON_COMBAT)))
                return eatDuration;

            float minDistance = sPlayerbotAIConfig.followDistance;

            if (bot->GetGroup()->IsRaidGroup())
                minDistance = sPlayerbotAIConfig.raidFollowDistance;

            if (!master->IsMoving())
                minDistance += sPlayerbotAIConfig.EatDrinkMinDistance;

            if (bot->IsWithinDist(master, minDistance))
                return eatDuration;

            float masterOrientation = master->GetOrientation();
            float angleToBot = master->GetAngle(bot);
            float angleDiff = fabs(masterOrientation - angleToBot);

            if (angleDiff > M_PI / 2 && angleDiff < 3 * M_PI / 2)
            {
                eatDuration *= 0.25f;
            }
            return eatDuration;
        }
    };
}
