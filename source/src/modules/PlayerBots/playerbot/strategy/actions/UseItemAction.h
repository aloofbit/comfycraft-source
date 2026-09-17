#pragma once
#include "GenericActions.h"
#include "playerbot/ServerFacade.h"
#include "playerbot/RandomItemMgr.h"
// For SetBotMealRate below: Aura, SpellAuraHolder and the OBS_MOD aura names.
// playerbot.h pulls this in too, but this header is included directly from
// several .cpp files and should not depend on that having happened first.
#include "Spells/SpellAuras.h"

namespace ai
{
    //This class bypasses the requirement for a bot to have a key item in their inventory when opening a lock.
    class BotUseItemSpell : public Spell
    {
    public:
        BotUseItemSpell(WorldObject* caster, SpellEntry const* info, uint32 triggeredFlags, ObjectGuid originalCasterGUID = ObjectGuid(), SpellEntry const* triggeredBy = nullptr, bool itemCheats = false)
            : Spell(caster->ToUnit() ? caster->ToUnit() : (Unit*)nullptr, info, triggeredFlags != 0, originalCasterGUID, triggeredBy), itemCheats(itemCheats) {};

        static BotUseItemSpell* Create(WorldObject* caster, SpellEntry const* info, uint32 triggeredFlags, ObjectGuid originalCasterGUID = ObjectGuid(), SpellEntry const* triggeredBy = nullptr, bool itemCheats = false)
        {
            if (!caster || !info)
                return nullptr;

            if (info != sSpellTemplate.LookupEntry<SpellEntry>(info->Id))
                return nullptr;

            return new BotUseItemSpell(caster, info, triggeredFlags, originalCasterGUID, triggeredBy, itemCheats);
        }

        SpellCastResult ForceSpellStart(SpellCastTargets const* targets, Aura* triggeredByAura = nullptr);
        bool OpenLockCheck();

    private:
        bool itemCheats;
    };

    class UseAction : public ChatCommandAction, public Qualified
    {
    public:
        UseAction(PlayerbotAI* ai, std::string name = "use", uint32 duration = sPlayerbotAIConfig.reactDelay) : ChatCommandAction(ai, name, duration), Qualified() {}

    public:
        // Used when this action is executed as a reaction
        virtual bool ShouldReactionInterruptCast() const override { return true; }

    protected:
        virtual bool Execute(Event& event) override;
        bool UseItem(Player* requester, uint32 itemId, Unit* target = nullptr);
        bool UseItem(Player* requester, uint32 itemId, GameObject* target);
        bool UseItem(Player* requester, uint32 itemId, Item* target);
        bool UseGameObject(Player* requester, Event& event, GameObject* gameObject);
        
        //void TellConsumableUse(Player* requester, Item* item, std::string action, float percent);

        bool HasItemCooldown(uint32 itemId) const;

    private:
        bool UseItemInternal(Player* requester, uint32 itemId, Unit* target, GameObject* gameObjectTarget, Item* itemTarget);
        bool UseQuestGiverItem(Player* requester, Item* item);
        bool OpenItem(Player* requester, Item* item);
#ifndef MANGOSBOT_ZERO
        bool UseGemItem(Player* requester, Item* item, Item* gem, bool replace = false);
#endif
    };

    class UseItemIdAction : public UseAction
    {
    public:
        UseItemIdAction(PlayerbotAI* ai, std::string name = "use id", uint32 duration = sPlayerbotAIConfig.reactDelay) : UseAction(ai, name, duration) {}
        virtual bool isPossible() override;
        virtual bool isUseful() override;

    protected:
        virtual bool Execute(Event& event) override;
        virtual uint32 GetItemId() { return getQualifier().empty() ? 0 : getMultiQualifierInt(getQualifier(),0, ","); }
        virtual Unit* GetTarget() override { return nullptr; }
    };

    class UseTargetedItemIdAction : public UseItemIdAction
    {
    public:
        UseTargetedItemIdAction(PlayerbotAI* ai, std::string name, uint32 duration = sPlayerbotAIConfig.reactDelay) : UseItemIdAction(ai, name, duration) {}
        virtual Unit* GetTarget() override { return Action::GetTarget(); }
        virtual uint32 GetItemId() override { return  0; }
    };

    class UseSpellItemAction : public UseAction 
    {
    public:
        UseSpellItemAction(PlayerbotAI* ai, std::string name) : UseAction(ai, name) {}
        virtual bool isUseful() override;
    };

    class UsePotionAction : public UseItemIdAction
    {
    public:
        UsePotionAction(PlayerbotAI* ai, std::string name, SpellEffects effect) : UseItemIdAction(ai, name), effect(effect) {}

        bool isUseful() override { return UseItemIdAction::isUseful() && AI_VALUE2(bool, "combat", "self target"); }

        virtual uint32 GetItemId() override
        {
            std::list<Item*> items = AI_VALUE2(std::list<Item*>, "inventory items", getName());
            if (items.empty())
            {
                return sRandomItemMgr.GetRandomPotion(bot->GetLevel(), effect);
            }

            return items.front()->GetProto()->ItemId;
        }

        bool Execute(Event& event) override
        {
            // Check the chance of using a potion (only in pvp)
#ifdef MANGOSBOT_ZERO
            const bool shouldUsePotion = !ai->IsInPvp() || frand(0.0f, 1.0f) < sPlayerbotAIConfig.usePotionChance;
#else
            const bool shouldUsePotion = !bot->InArena() && (!ai->IsInPvp() || frand(0.0f, 1.0f) < sPlayerbotAIConfig.usePotionChance);
#endif
            if (shouldUsePotion)
            {
                return UseItemIdAction::Execute(event);
            }
            else
            {
                // Force potion cooldown to prevent spamming this action
                const ItemPrototype* proto = sObjectMgr.GetItemPrototype(GetItemId());
                if (proto)
                {
                    for (int i = 0; i < MAX_ITEM_PROTO_SPELLS; ++i)
                    {
                        _Spell const& spellData = proto->Spells[i];
                        if (spellData.SpellId)
                        {
                            // wrong triggering type
#ifdef MANGOSBOT_ZERO
                            if (spellData.SpellTrigger != ITEM_SPELLTRIGGER_ON_USE && spellData.SpellTrigger != ITEM_SPELLTRIGGER_ON_NO_DELAY_USE)
#else
                            if (spellData.SpellTrigger != ITEM_SPELLTRIGGER_ON_USE)
#endif
                            {
                                continue;
                            }

                            const SpellEntry* spellInfo = sSpellTemplate.LookupEntry<SpellEntry>(spellData.SpellId);
                            if (spellInfo)
                            {
                                bot->RemoveSpellCooldown(*spellInfo, false);
                                bot->AddCooldown(*spellInfo, proto, false);
                                break;
                            }
                        }
                    }
                }
            }

            return true;
        }

    private:
        SpellEffects effect;
    };

    class UseHealingPotionAction : public UsePotionAction
    {
    public:
        UseHealingPotionAction(PlayerbotAI* ai) : UsePotionAction(ai, "healing potion", SPELL_EFFECT_HEAL) {}
    };

    class UseManaPotionAction : public UsePotionAction
    {
    public:
        UseManaPotionAction(PlayerbotAI* ai) : UsePotionAction(ai, "mana potion", SPELL_EFFECT_ENERGIZE) {}
    };

    class UseHearthStoneAction : public UseAction
    {
    public:
        UseHearthStoneAction(PlayerbotAI* ai) : UseAction(ai, "hearthstone", 10000U) {}

        virtual bool Execute(Event& event) override;

        bool isUseful() override;
    
        // Used when this action is executed as a reaction
        bool ShouldReactionInterruptMovement() const override { return true; }
    };

    class UseHealthstoneAction : public UseItemIdAction
    {
    public:
        UseHealthstoneAction(PlayerbotAI* ai) : UseItemIdAction(ai, "healthstone") {}

        bool isUseful() override { return UseItemIdAction::isUseful() && AI_VALUE2(bool, "combat", "self target"); }

        uint32 GetItemId() override
        {
            std::list<Item*> items = AI_VALUE2(std::list<Item*>, "inventory items", getName());
            if (items.empty())
            {
                const uint32 level = bot->GetLevel();
                if(level < 12)
                {
                    return 5512;
                }
                else if(level >= 12 && level < 24)
                {
                    return 5511;
                }
                else if(level >= 24 && level < 36)
                {
                    return 5509;
                }
                else if(level >= 36 && level < 48)
                {
                    return 5510;
                }
                else if(level >= 48 && level < 61)
                {
                    return 9421;
                }
                else if(level >= 61 && level < 63)
                {
                    return 22103;
                }
                else if(level >= 63 && level < 71)
                {
                    return 36889;
                }
                else
                {
                    return 36892;
                }
            }

            return items.front()->GetProto()->ItemId;
        }

        bool Execute(Event& event) override
        {
            // Check the chance of using a healthstone (only in pvp)
            const bool shouldUsePotion = !ai->IsInPvp() || frand(0.0f, 1.0f) < sPlayerbotAIConfig.usePotionChance;
            if (shouldUsePotion)
            {
                return UseItemIdAction::Execute(event);
            }
            else
            {
                // Force potion cooldown to prevent spamming this action
                const ItemPrototype* proto = sObjectMgr.GetItemPrototype(GetItemId());
                if (proto)
                {
                    for (int i = 0; i < MAX_ITEM_PROTO_SPELLS; ++i)
                    {
                        _Spell const& spellData = proto->Spells[i];
                        if (spellData.SpellId)
                        {
                            // wrong triggering type
#ifdef MANGOSBOT_ZERO
                            if (spellData.SpellTrigger != ITEM_SPELLTRIGGER_ON_USE && spellData.SpellTrigger != ITEM_SPELLTRIGGER_ON_NO_DELAY_USE)
#else
                            if (spellData.SpellTrigger != ITEM_SPELLTRIGGER_ON_USE)
#endif
                            {
                                continue;
                            }

                            const SpellEntry* spellInfo = sSpellTemplate.LookupEntry<SpellEntry>(spellData.SpellId);
                            if (spellInfo)
                            {
                                bot->RemoveSpellCooldown(*spellInfo, false);
                                bot->AddCooldown(*spellInfo, proto, false);
                                break;
                            }
                        }
                    }
                }
            }

            return true;
        }
    };

    class UseWhipperRootTuberAction : public UseItemIdAction
    {
    public:
        UseWhipperRootTuberAction(PlayerbotAI* ai) : UseItemIdAction(ai, "whipper root tuber") {}

        bool isUseful() override { return bot->GetLevel() >= 45 && UseItemIdAction::isUseful() && AI_VALUE2(bool, "combat", "self target"); }

        uint32 GetItemId() override { return 11951; }
    };

    class UseAntiVenomAction : public UseItemIdAction
    {
    public:
        UseAntiVenomAction(PlayerbotAI* ai) : UseItemIdAction(ai, "anti-venom") {}

        bool isUseful() override
        {
            if (!UseItemIdAction::isUseful())
                return false;

            return ai->HasAuraToDispel(bot, DISPEL_POISON);
        }

        uint32 GetItemId() override
        {
            int firstAidSkillValue = bot->GetSkillValue(129);
            if (firstAidSkillValue >= 300 && bot->HasItemCount(19440, 1))
                return 19440;
            if (firstAidSkillValue >= 130 && bot->HasItemCount(6453, 1))
                return 6453;
            if (firstAidSkillValue >= 80 && bot->HasItemCount(6452, 1))
                return 6452;
            return 0;
        }
    };

    class UseRandomRecipeAction : public UseAction
    {
    public:
        UseRandomRecipeAction(PlayerbotAI* ai) : UseAction(ai, "random recipe", 6000U) {}

        virtual bool isUseful() override;
        virtual bool isPossible() override {return AI_VALUE2(uint32,"item count", "recipe") > 0; }
      
        virtual bool Execute(Event& event) override;

        // Used when this action is executed as a reaction
        bool ShouldReactionInterruptMovement() const override { return true; }
    };

    class OpenRandomItemAction : public UseAction
    {
    public:
        OpenRandomItemAction(PlayerbotAI* ai) : UseAction(ai, "open random item") {}

        virtual bool isUseful() override;

        virtual bool isPossible() override { return AI_VALUE2(uint32, "item count", "open") > 0; }

        virtual bool Execute(Event& event) override;

        // Used when this action is executed as a reaction
        bool ShouldReactionInterruptMovement() const override { return true; }
    };

    class UseRandomQuestItemAction : public UseAction
    {
    public:
        UseRandomQuestItemAction(PlayerbotAI* ai) : UseAction(ai, "use random quest item") {}

        virtual bool isUseful() override;
        virtual bool isPossible() override { return AI_VALUE2(uint32, "item count", "quest") > 0;}

        virtual bool Execute(Event& event) override;

        // Used when this action is executed as a reaction
        bool ShouldReactionInterruptMovement() const override { return true; }
    };

    // goblin sappers
    class UseGoblinSapperChargeAction : public UseItemIdAction
    {
    public:
        UseGoblinSapperChargeAction(PlayerbotAI* ai) : UseItemIdAction(ai, "goblin sapper") {}
        virtual bool isUseful() override { return UseItemIdAction::isUseful() && bot->GetSkillValue(202) >= 205 && bot->GetHealth() > 1000; }

        virtual uint32 GetItemId() override
        { 
#ifndef MANGOSBOT_ZERO
            if (bot->InArena())
                return false;
#endif
            return (bot->GetLevel() >= 68) ? 23827 : 10646; 
        }
    };

    // oil of immolation
    class UseOilOfImmolationAction : public UseItemIdAction
    {
    public:
        UseOilOfImmolationAction(PlayerbotAI* ai) : UseItemIdAction(ai, "oil of immolation") {}
        virtual bool isUseful() override
        {
#ifndef MANGOSBOT_ZERO
            if (bot->InArena())
                return false;
#endif
            return UseItemIdAction::isUseful() && bot->GetLevel() >= 31 && !ai->HasAura(11350, bot);
        }

        virtual uint32 GetItemId() override { return 8956; }
    };

    // stoneshield potion
    class UseStoneshieldPotionAction : public UseItemIdAction
    {
    public:
        UseStoneshieldPotionAction(PlayerbotAI* ai) : UseItemIdAction(ai, "stoneshield potion") {}
        virtual bool isUseful() override
        {
#ifndef MANGOSBOT_ZERO
            if (bot->InArena())
                return false;
#endif
            return UseItemIdAction::isUseful() && bot->GetLevel() >= 46 && !ai->HasAura(17540, bot);
        }

        virtual uint32 GetItemId() override { return 13455; }
    };

    class UseBgBannerAction : public UseItemIdAction
    {
    public:
        UseBgBannerAction(PlayerbotAI* ai) : UseItemIdAction(ai, "bg banner") {}

        virtual bool isUseful() override
        {
            if (!UseItemIdAction::isUseful())
                return false;

            if (!bot->InBattleGround() || bot->GetLevel() < 60 || !bot->IsInCombat())
                return false;

            std::list<ObjectGuid> units = *context->GetValue<std::list<ObjectGuid> >("nearest npcs no los");
            for (std::list<ObjectGuid>::iterator i = units.begin(); i != units.end(); i++)
            {
                Unit* unit = ai->GetUnit(*i);
                if (!unit)
                    continue;

                if (bot->GetTeam() == HORDE && unit->GetEntry() == 14466)
                    return false;

                if (bot->GetTeam() == ALLIANCE && unit->GetEntry() == 14465)
                    return false;
            }

            return true;
        }

        virtual uint32 GetItemId() override
        {
            return bot->GetTeam() == ALLIANCE ? 18606 : 18607;
        }

        // Used when this action is executed as a reaction
        bool ShouldReactionInterruptMovement() const override { return true; }
    };

    class UseRocketBootsAction : public UseItemIdAction
    {
    public:
        UseRocketBootsAction(PlayerbotAI* ai) : UseItemIdAction(ai, "rocket boots") {}

        virtual bool isUseful() override
        {
            if(!UseItemIdAction::isUseful())
                return false;

            if (ai->HasAnyAuraOf(bot, "sprint", "speed", "goblin rocket boots", "dash", NULL))
                return false;

            return true;
        }

        virtual uint32 GetItemId() override
        {
            return 7189;
        }
    };

    class UseBandageAction : public UseTargetedItemIdAction
    {
    public:
        UseBandageAction(PlayerbotAI* ai) : UseTargetedItemIdAction(ai, "use bandage", 8000U) {}

        virtual bool isUseful() override
        {
            if (!UseTargetedItemIdAction::isUseful())
                return false;

            // A bot the SERVER feeds does not bandage. It has Food (24005) for
            // nothing, out of no bag slot, at a rate we set -- so a bandage is
            // a strictly worse version of sitting down: it burns a real item,
            // channels for 8 seconds, and leaves a minute of Recently Bandaged
            // (11196) behind. See bot-food-and-drink.md for the two paths.
            //
            // It also WINS, which is why this reads as "they bandage instead of
            // eating" rather than as a harmless extra. "use bandage" is queued
            // at ACTION_MEDIUM_HEAL (70) and the meal actions at 6.0, and the
            // bandage trigger is in the COMBAT and REACTION engines while food
            // is in the non-combat one -- reactions run before the
            // CanUpdateAIInternal gate, so the bandage preempts the meal
            // outright the moment a fight ends and attacker count hits zero.
            // Between 20% and 50% health, the band "low health" covers, a
            // companion could therefore never sit down at all.
            //
            // The owner's own alts, run with .bot add, keep bandaging: they
            // carry real bags and real food and this is not their trade-off.
            if (ai->HasCheat(BotCheatMask::item))
                return false;

            if (bot->HasAura(11196))
                return false;

            if (AI_VALUE(uint8, "my attacker count") > 0 || bot->HasAuraType(SPELL_AURA_PERIODIC_DAMAGE))
                return false;

            if (bot->GetSkillValue(129) < 1)
                return false;
              
            // Prevent tanks from bandaging in dungeons and raids
            if (ai->IsTank(bot) && ai->IsStateActive(BotState::BOT_STATE_COMBAT))
            {
                const Map* map = bot->GetMap();
                if (map->IsDungeon() || map->IsRaid())
                {
                    return false;
                }
            }

            return true;
        }

        virtual std::string GetTargetName() override { return "self target"; }

        virtual uint32 GetItemId() override
        {
            int firstAidSkillValue = bot->GetSkillValue(129);
#ifdef MANGOSBOT_TWO
            if (firstAidSkillValue >= 400)
                return 34722;
            if (firstAidSkillValue >= 350)
                return 34721;
#endif
#ifndef MANGOSBOT_ZERO
            if (firstAidSkillValue >= 325)
                return 21991;
            if (firstAidSkillValue >= 300)
                return 21990;
#endif
            if (firstAidSkillValue >= 225)
                return 14530;
            if (firstAidSkillValue >= 200)
                return 14529;
            if (firstAidSkillValue >= 175)
                return 8545;
            if (firstAidSkillValue >= 150)
                return 8544;
            if (firstAidSkillValue >= 125)
                return 6451;
            if (firstAidSkillValue >= 100)
                return 6450;
            if (firstAidSkillValue >= 75)
                return 3531;
            if (firstAidSkillValue >= 50)
                return 3530;
            if (firstAidSkillValue >= 20)
                return 2581;
            return 1251;
        }

        // Used when this action is executed as a reaction
        bool ShouldReactionInterruptMovement() const override { return true; }
    };

    class ThrowGrenadeAction : public UseTargetedItemIdAction
    {
    public:
        ThrowGrenadeAction(PlayerbotAI* ai) : UseTargetedItemIdAction(ai, "throw grenade") {}

        virtual std::string GetTargetName() override { return "current target"; }

        virtual bool isUseful() override
        {
#ifndef MANGOSBOT_ZERO
            if (bot->InArena())
                return false;
#endif

            Unit* target = GetTarget();
            if (!target)
                return false;

            if (!UseTargetedItemIdAction::isUseful())
                return false;

            if (!target->IsNonMeleeSpellCasted(false) && target->IsStopped())
                return false;

            if (bot->GetSkillValue(202) < 175)
                return false;

            return bot->GetLevel() >= 52;
        }

        virtual uint32 GetItemId() override
        { 
            if (bot->GetSkillValue(202) >= 325)
                return 23737;
            if (bot->GetSkillValue(202) >= 260)
                return 15993;
            return 4390; 
        }
    };

    class UseDarkRuneAction : public UseItemIdAction
    {
    public:
        UseDarkRuneAction(PlayerbotAI* ai) : UseItemIdAction(ai, "dark rune") {}

        virtual bool isUseful() override
        {
            if(!UseItemIdAction::isUseful())
                return false;

#ifndef MANGOSBOT_ZERO
            if (bot->InArena())
                return false;
#endif

            if (bot->getClass() == CLASS_MAGE) // mage should use mana gem, shares cd with dark rune
                return false;

            return bot->GetHealth() > 1000;
        }

        virtual uint32 GetItemId() override { return 20520; }
    };

    class UseFireProtectionPotionAction : public UseItemIdAction
    {
    public:
        UseFireProtectionPotionAction(PlayerbotAI* ai) : UseItemIdAction(ai, "fire protection potion") {}

        virtual bool isUseful() override
        {
            return UseItemIdAction::isUseful() && !bot->HasAura(17543) && (bot->GetLevel() >= 48);
        }

        virtual uint32 GetItemId() override { return 13457; }
    };

    class UseFreeActionPotionAction : public UseItemIdAction
    {
    public:
        UseFreeActionPotionAction(PlayerbotAI* ai) : UseItemIdAction(ai, "free action potion") {}

        virtual bool isUseful() override
        {
            if (!UseItemIdAction::isUseful())
                return false;

            if (bot->GetLevel() < 20 || bot->HasAura(6615))
                return false;

            Unit* target = AI_VALUE(Unit*, "current target");
            if (!target || !target->IsPlayer())
                return false;

            if (!bot->InBattleGround() && urand(0, 1))
                return false;

            return true;
        }

        virtual uint32 GetItemId() override { return 5634; }
    };

    // Override how fast Food (24005) and Drink (24355) restore, on the aura
    // that has just been applied to this bot.
    //
    // Both are read every tick as m_modifier.m_amount, a percentage of the
    // bot's maximum -- SpellAuras.cpp, the SPELL_AURA_OBS_MOD_HEALTH and
    // SPELL_AURA_OBS_MOD_MANA cases. Spell.dbc ships 2. Aura::GetModifier()
    // is non-const, so raising the rate needs no core change and no DBC edit,
    // which also means the CLIENT still shows the stock tooltip -- the icon is
    // honest about what is happening, the number in it is not.
    //
    // This has to run after EVERY apply: the holder recomputes m_amount from
    // the spell's base points each time, so a refresh silently drops back to
    // 2%. Called from both meal actions below, on both auras, every time.
    inline void SetBotMealRate(Player* bot, uint32 spellId)
    {
        const uint32 pct = sPlayerbotAIConfig.botEatDrinkPercentPerSecond;
        if (pct == 2)
            return;                                 // the DBC's own value

        SpellAuraHolder* holder = bot->GetSpellAuraHolder(spellId);
        if (!holder)
            return;

        for (uint32 i = 0; i < MAX_EFFECT_INDEX; ++i)
        {
            Aura* aura = holder->GetAuraByEffectIndex(SpellEffectIndex(i));
            if (!aura)
                continue;

            // Only the regen effect. Touching anything else on the holder
            // would be writing a percentage into a field that is not one.
            const uint32 auraName = aura->GetModifier()->m_auraname;
            if (auraName == SPELL_AURA_OBS_MOD_HEALTH || auraName == SPELL_AURA_OBS_MOD_MANA)
                aura->GetModifier()->m_amount = (int32)pct;
        }
    }

    class DrinkAction : public UseAction
    {
    public:
        DrinkAction(PlayerbotAI* ai) : UseAction(ai, "drink") {}

        bool Execute(Event& event) override
        {
            if (sServerFacade.IsInCombat(bot))
                return false;

            if (!bot->HasMana())
                return false;

            if (ai->HasCheat(BotCheatMask::item))
            {
                if (bot->IsNonMeleeSpellCasted(true))
                    return false;

                bot->clearUnitState(UNIT_STAT_CHASE);
                bot->clearUnitState(UNIT_STAT_FOLLOW);

                if (ai->GetBot()->GetMotionMaster()->GetCurrentMovementGeneratorType() == FOLLOW_MOTION_TYPE)
                {
                    ai->StopMoving();
                }

                if (sServerFacade.isMoving(bot))
                {
                    ai->StopMoving();
                    SetDuration(sPlayerbotAIConfig.globalCoolDown);
                    return false;
                }

                // DO NOT sit down here. The aura seats the bot itself on
                // apply -- "Sitdown on apply aura req seated",
                // SpellAuras.cpp:6919 -- and sitting BEFORE the cast stops the
                // cast happening at all: PlayerbotAI::CastSpell refuses for any
                // bot that is not in stand state, standing it back up and
                // returning false. The bot then stops, bobs, and never drinks.
                //
                // The original line here was addUnitState(UNIT_STAND_STATE_SIT),
                // which is a different enum: 1 is also UNIT_STAT_MELEE_ATTACKING,
                // so it sat nobody down and flagged the bot as swinging at
                // something. Correcting it to SetStandState is what exposed the
                // conflict above, on 2026-09-06. Standing is what ENDS a meal
                // (AURA_INTERRUPT_FLAG_NOT_SEATED), so make sure we are stood up
                // before refreshing rather than fighting CastSpell for it.
                if (!bot->IsStandState())
                    bot->SetStandState(UNIT_STAND_STATE_STAND);
                ai->InterruptSpell();

                float drinkDuration = AI_VALUE(float, "drink duration");

                const SpellEntry* pSpellInfo = sServerFacade.LookupSpellInfo(24355);
                if (!pSpellInfo)
                    return false;

                ai->Unmount();

                // A TRIGGERED cast. Neither of the two obvious calls works here
                // and both failures are silent:
                //
                //   ai->CastSpell(24355, bot) - Spell::prepare() does not cast
                //   an instant spell. "If timer = 0, it's an instant cast spell
                //   and will be casted on the next tick", and the "Cast on self
                //   -> execute NOW" cast(true) under it is commented out. The
                //   aura therefore does not exist when this function returns,
                //   so anything inspecting it on the next line sees nothing.
                //
                //   ai->AddAura(bot, 24355) - builds a SpellAuraHolder by hand
                //   and lands one on the bot that shows a buff icon and seats
                //   it, but carries no working periodic aura: the holder is
                //   there and GetAuraByEffectIndex is null at every index, so
                //   NOTHING TICKS. Measured 2026-09-08. This is why the "eat
                //   and drink at the same time" second aura had been cosmetic
                //   since the original graft - an icon restoring nothing, and
                //   invisible because the first aura was doing the work.
                //
                // Triggered is the third door and the right one: prepare()'s
                // `else if (m_timer == 0) cast(true)` branch is for triggered
                // spells, so this applies a real aura through the real spell
                // system, synchronously, with no cast bar and no GCD.
                bot->CastSpell(bot, 24355, true);
                bot->RemoveSpellCooldown(*pSpellInfo);
                SetBotMealRate(bot, 24355);

                // Eat and drink at the same time

                if (AI_VALUE(bool, "should eat"))
                {
                    const SpellEntry* pSpellInfo2 = sServerFacade.LookupSpellInfo(24005);
                    if (pSpellInfo2)
                    {
                        bot->CastSpell(bot, 24005, true);   // triggered - see DrinkAction above
                        bot->RemoveSpellCooldown(*pSpellInfo2);
                        SetBotMealRate(bot, 24005);

                        // Sit for whichever meal takes longer. The duration is
                        // the AI's sleep, and standing up cancels BOTH auras
                        // (AURA_INTERRUPT_FLAG_NOT_SEATED) -- so a bot at 94%
                        // mana and 30% health that happens to reach this from
                        // the drink side would otherwise sit for three seconds
                        // and stand up with almost none of its health back.
                        // Both actions are relevance 6.0 in UseFoodStrategy,
                        // so which one gets here is a coin toss and neither may
                        // assume its own resource is the binding one.
                        const float eatDuration = AI_VALUE(float, "eat duration");
                        if (eatDuration > drinkDuration)
                            drinkDuration = eatDuration;
                    }
                }

                SetDuration(drinkDuration);
                return true;
            }

            if (AI_VALUE2(std::list<Item*>, "inventory items", name).empty())
                return false;

            return UseAction::Execute(event);
        }

        bool isUseful() override
        {
            // ALREADY DRINKING IS NOT A REASON TO DRINK.
            //
            // A damage tick - a DoT left over from the fight - flips the bot
            // into its combat engine and straight back out, and each of those
            // transitions resets the meal's sleep. The non-combat engine then
            // ran this action again, which stands the bot up (the aura carries
            // AURA_INTERRUPT_FLAG_NOT_SEATED, so that ends the meal) and
            // starts it over: a companion with a DoT on it bobbed up and down
            // on every tick and never finished a drink. The Drink aura itself
            // does not care about damage, so once it is on, leave it alone.
            // Cheat bots carry 24355; a bot drinking a real item has the same
            // periodic-mana aura from that item, sitting.
            if (bot->HasAura(24355) || (bot->IsSitState() && bot->HasAuraType(SPELL_AURA_OBS_MOD_MANA)))
                return false;

            return UseAction::isUseful() && AI_VALUE(bool, "should drink");
        }

        bool isPossible() override
        {
            return !sServerFacade.IsInCombat(bot) && UseAction::isPossible();
        }
    };

    class EatAction : public UseAction
    {
    public:
        EatAction(PlayerbotAI* ai) : UseAction(ai, "food") {}

        bool Execute(Event& event) override
        {
            if (sServerFacade.IsInCombat(bot))
                return false;

            if (ai->HasCheat(BotCheatMask::item))
            {
                if (bot->IsNonMeleeSpellCasted(true))
                    return false;

                bot->clearUnitState(UNIT_STAT_CHASE);
                bot->clearUnitState(UNIT_STAT_FOLLOW);

                if (ai->GetBot()->GetMotionMaster()->GetCurrentMovementGeneratorType() == FOLLOW_MOTION_TYPE)
                {
                    ai->StopMoving();
                }

                if (sServerFacade.isMoving(bot))
                {
                    ai->StopMoving();
                    SetDuration(sPlayerbotAIConfig.globalCoolDown);
                    return false;
                }

                // DO NOT sit down here. The aura seats the bot itself on
                // apply -- "Sitdown on apply aura req seated",
                // SpellAuras.cpp:6919 -- and sitting BEFORE the cast stops the
                // cast happening at all: PlayerbotAI::CastSpell refuses for any
                // bot that is not in stand state, standing it back up and
                // returning false. The bot then stops, bobs, and never drinks.
                //
                // The original line here was addUnitState(UNIT_STAND_STATE_SIT),
                // which is a different enum: 1 is also UNIT_STAT_MELEE_ATTACKING,
                // so it sat nobody down and flagged the bot as swinging at
                // something. Correcting it to SetStandState is what exposed the
                // conflict above, on 2026-09-06. Standing is what ENDS a meal
                // (AURA_INTERRUPT_FLAG_NOT_SEATED), so make sure we are stood up
                // before refreshing rather than fighting CastSpell for it.
                if (!bot->IsStandState())
                    bot->SetStandState(UNIT_STAND_STATE_STAND);
                ai->InterruptSpell();

                float eatDuration = AI_VALUE(float, "eat duration");

                const SpellEntry* pSpellInfo = sServerFacade.LookupSpellInfo(24005);
                if (!pSpellInfo)
                    return false;

                ai->Unmount();

                // AddAura, not CastSpell -- see the same call in DrinkAction
                // above for why a queued instant cast made the rate override
                // unreachable and delayed the buff.
                // Triggered cast, not AddAura and not ai->CastSpell - see DrinkAction above.
                bot->CastSpell(bot, 24005, true);
                bot->RemoveSpellCooldown(*pSpellInfo);
                SetBotMealRate(bot, 24005);

                // Eat and drink at the same time
                if (AI_VALUE(bool, "should drink"))
                {
                    const SpellEntry* pSpellInfo2 = sServerFacade.LookupSpellInfo(24355);
                    if (pSpellInfo2)
                    {
                        bot->CastSpell(bot, 24355, true);   // triggered - see DrinkAction above
                        bot->RemoveSpellCooldown(*pSpellInfo2);
                        SetBotMealRate(bot, 24355);

                        // Sit for whichever meal takes longer -- see the same
                        // block in DrinkAction above for why neither side may
                        // assume its own resource is the binding one.
                        const float drinkDuration = AI_VALUE(float, "drink duration");
                        if (drinkDuration > eatDuration)
                            eatDuration = drinkDuration;
                    }
                }

                SetDuration(eatDuration);
                return true;
            }

            if (AI_VALUE2(std::list<Item*>, "inventory items", name).empty())
                return false;

            return UseAction::Execute(event);
        }

        bool isUseful() override
        {
            // Already eating is not a reason to eat - see DrinkAction::isUseful.
            if (bot->HasAura(24005) || (bot->IsSitState() && bot->HasAuraType(SPELL_AURA_OBS_MOD_HEALTH)))
                return false;

            return UseAction::isUseful() && AI_VALUE(bool, "should eat");
        }

        bool isPossible() override
        {
            return !sServerFacade.IsInCombat(bot) && UseAction::isPossible();
        }
    };
}
