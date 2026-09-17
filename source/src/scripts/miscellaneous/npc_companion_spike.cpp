/*
 * npc_companion_spike -- the healer-companion spike (2026-09-05).
 *
 * Proves the four unknowns in docs/ai/content/companions-route.md before any
 * of the real feature is built. Two creatures, both bound by
 * creature_template.script_name in sql/custom/065:
 *
 *   100029  Sister Wren        a stationary recruiter, gossip only
 *   100030  Wren's Apprentice  the companion, summoned as a GUARDIAN_PET
 *
 * THROWAWAY. Entries, names and numbers here are for the spike; nothing else
 * should come to depend on them. What survives is whatever the answers are.
 *
 * WHY THIS NEEDED C++ AT ALL. The scope said a healer was "a creature_spells
 * row and nothing else", and the rotation genuinely is -- but the row never
 * runs. EVERY stock AI refuses to touch the spell list without a hostile
 * target:
 *
 *   AggressorAI::UpdateAI     if (!SelectHostileTarget() || !GetVictim()) return;
 *   ReactorAI::UpdateAI       the same two lines
 *   CreatureEventAI::UpdateAI if (Combat) { ... UpdateSpellsList ... }
 *   PetEventAI::UpdateAI      if (m_creature->GetVictim()) { ... }
 *   ScriptedAI::UpdateAI      if (!m_CreatureSpells.empty() && IsInCombat())
 *
 * A pure healer has no victim and often is not itself in combat, so under any
 * of them it stands there and casts nothing. PetAI does call DoSpellsListCasts
 * unconditionally for a GUARDIAN_PET (PetAI.cpp:189), but guardians never get
 * PetAI: CreatureAISelector only hands it to a pet where isControlled() is
 * true, and that is SUMMON_PET and HUNTER_PET only (Pet.h:157).
 *
 * So the ~30 lines below are the whole difference, and they are the reason the
 * healer role needs a script_name rather than a bare template. The same
 * selector line that denies guardians PetAI is what lets us in:
 * CreatureAISelector.cpp:43-46 gives a scripted AI to any pet that is not
 * controlled.
 */

#include "ScriptMgr.h"
#include "ScriptedGossip.h"
#include "ScriptedAI.h"
#include "Player.h"
#include "Creature.h"
#include "Pet.h"
#include "ObjectMgr.h"
#include "Chat.h"
#include "MotionMaster.h"
#include "Log.h"
#include "SpellMgr.h"

enum
{
    NPC_COMPANION_HEALER      = 100030,

    GOSSIP_TEXT_RECRUITER     = 68,
    GOSSIP_ACTION_HIRE_HEALER = GOSSIP_ACTION_INFO_DEF + 1,
    GOSSIP_ACTION_DISMISS     = GOSSIP_ACTION_INFO_DEF + 2,

    // Past this the companion stops casting. It still follows -- this only
    // keeps it from healing across a zone if the follow is lagging.
    COMPANION_LEAVE_DISTANCE  = 60,
};

// In combat she stops once this close to her owner, and only starts following
// again once they get this far away. The gap between the two is what stops her
// flickering between the two states on the boundary. Both are inside the 30
// yard friendly-search radius the heal slots use.
static const float COMPANION_HOLD_DIST   = 15.0f;
static const float COMPANION_RESUME_DIST = 25.0f;

/*
 * Lifted from Spell::DoSummonGuardian (SpellEffects.cpp:2632-2700) with the
 * spell-specific parts dropped. Everything here earns its line; the ordering
 * is the core's and is worth preserving.
 */
static Pet* SummonCompanion(Player* owner, uint32 entry, uint32 level)
{
    CreatureInfo const* cInfo = sObjectMgr.GetCreatureTemplate(entry);
    if (!cInfo)
        return nullptr;

    Map* map = owner->GetMap();
    CreatureCreatePos pos(owner, owner->GetOrientation());

    Pet* pet = new Pet(GUARDIAN_PET);
    uint32 petNumber = sObjectMgr.GeneratePetNumber();
    if (!pet->Create(map->GenerateLocalLowGuid(HIGHGUID_PET), pos, cInfo, petNumber))
    {
        delete pet;
        return nullptr;
    }

    pet->SetSummonPoint(pos);
    pet->SetOwnerGuid(owner->GetObjectGuid());
    pet->SetInitCreaturePowerType();

    /*
     * THE SECOND NAME TAG, and the probe for it. In game the companion shows
     * two lines under its name: "<Companion>", which is plainly our own
     * creature_template.subname, and "<Owner's Minion>", which is not ours --
     * the client builds it. "Minion" is not a plain string in WoW.exe OR in
     * mangosd.exe, so the word comes out of a compressed MPQ and cannot be
     * reworded from the server by picking a different string.
     *
     * PROBE RUN AND ANSWERED, 2026-09-05. Dropping SetCreatorGuid to see
     * whether it was what drew that line had a much louder result: the client
     * stopped treating the companion as the player's own and put the ATTACK
     * CURSOR on her. The server still refused the attack -- she carries the
     * owner's faction template, so the faction check says no -- but the sword
     * on mouseover is a bad enough lie on its own.
     *
     * So UNIT_FIELD_CREATEDBY is not cosmetic: it is how the CLIENT decides
     * "this one is mine". Server-side almost nothing reads it (Unit::GetCreator
     * and one loot-for-creator branch, Unit.cpp:1212), which is exactly why it
     * looks droppable and is not. Put back and left alone.
     *
     * The wording itself is settled and is not ours: the string lives in the
     * client, in Interface\FrameXML\GlobalStrings.lua, served here out of
     * patch-9.mpq, as one of five titles --
     *
     *     UNITNAME_TITLE          = "%s"
     *     UNITNAME_TITLE_CHARM    = "%s's Minion"
     *     UNITNAME_TITLE_CREATION = "%s's Creation"
     *     UNITNAME_TITLE_GUARDIAN = "%s's Guardian"
     *     UNITNAME_TITLE_MINION   = "%s's Minion"
     *     UNITNAME_TITLE_PET      = "%s's Pet"
     *
     * A GUARDIAN_PET renders as "Minion", not "Guardian", so the client is not
     * choosing by our pet type. Changing the word means shipping a client
     * patch, which is a decision about every warlock minion in the game, not
     * just about this creature.
     */
    pet->SetCreatorGuid(owner->GetObjectGuid());
    pet->SetUInt32Value(UNIT_NPC_FLAGS, cInfo->npc_flags);
    pet->SetUInt32Value(UNIT_FIELD_PET_NAME_TIMESTAMP, 0);

    // Faction is copied from the owner rather than taken from the template, so
    // the companion is friendly to whoever hired it and hostile to whatever is
    // hostile to them. This is also what makes FindLowestHpFriendlyUnit find
    // the player at all.
    pet->SetFactionTemplateId(owner->GetFactionTemplateId());

    // Guardians already stagger themselves around the owner, so a second and
    // third companion do not stand inside the first.
    float followAngle = PET_FOLLOW_ANGLE + (M_PI_F / 6) * owner->GetGuardiansCount();
    while (followAngle > M_PI_F * 2)
        followAngle -= M_PI_F * 2;
    pet->SetFollowAngle(followAngle);

    pet->InitStatsForLevel(level, owner);
    pet->GetCharmInfo()->SetPetNumber(petNumber, false);
    pet->LoadCreatureAddon();
    pet->InitializeDefaultName();

    // Pet::Pet sets REACT_AGGRESSIVE for every GUARDIAN_PET (Pet.cpp:81-82).
    // Left alone, a companion pulls everything you walk past.
    pet->SetReactState(REACT_PASSIVE);

    pet->AIM_Initialize();
    owner->AddGuardian(pet);
    map->Add(static_cast<Creature*>(pet));

    // AIM_Initialize does NOT leave it following, whatever the selector says.
    // See the comment on npc_companion_healerAI::KeepUp.
    pet->GetMotionMaster()->MoveFollow(owner, PET_FOLLOW_DIST, pet->GetFollowAngle());

    return pet;
}

/*
 * The companion. Never attacks; its whole behaviour is the creature_spells
 * list on its template, which sql/custom/065 fills with the priest heal tiers.
 */
struct npc_companion_healerAI : public ScriptedAI
{
    uint32 m_reportTimer = 0;
    bool   m_holding = false;   // standing still mid-fight rather than following
    uint32 m_faceTimer = 0;     // throttles re-facing while planted

    explicit npc_companion_healerAI(Creature* pCreature) : ScriptedAI(pCreature)
    {
        // Creature::InitEntry attaches the list for DB-spawned creatures. A
        // guardian is built by Pet::Create instead, so do it here rather than
        // find out in game that the list is empty.
        if (m_creature->GetCreatureInfo()->spell_list_id)
            SetSpellsList(m_creature->GetCreatureInfo()->spell_list_id);

        // SPIKE DIAGNOSTICS. Throwaway with the rest of this file. The first
        // in-game run healed nothing and there were four candidate reasons
        // (AI not selected, list empty, UpdateAI never reached, target search
        // returning nobody), so the spike is made to say which rather than
        // costing a build per guess.
        sLog.outString("[companion] AI constructed for entry %u, spell_list_id %u, %u spells loaded.",
                       m_creature->GetEntry(),
                       m_creature->GetCreatureInfo()->spell_list_id,
                       uint32(m_CreatureSpells.size()));

        Reset();
    }

    void Reset() override {}

    // A healer that swings at things is a healer that stands in the fire.
    void AttackStart(Unit*) override {}
    void MoveInLineOfSight(Unit*) override {}

    /*
     * FOLLOWING IS NOT FREE, WHICH THE SCOPE GOT WRONG. FactorySelector::
     * selectMovementGenerator does ask for FOLLOW_MOTION_TYPE for any creature
     * whose owner is a player (CreatureAISelector.cpp:109) -- but nothing can
     * build one. CreatureAIRegistry registers exactly three movement
     * generators, RANDOM, WAYPOINT and PATROL (CreatureAIRegistry.cpp:57-59),
     * so GetRegistryItem(FOLLOW_MOTION_TYPE) returns null, selectMovementGenerator
     * returns null, and MotionMaster::Initialize falls back to si_idleMovement.
     * The companion stands exactly where it was summoned.
     *
     * So the follow has to be asked for by hand, the way PetAI does it
     * (PetAI.cpp:600). Re-asserted here rather than only at summon because
     * anything that calls MotionMaster::Initialize again -- an evade, a
     * knockback -- drops it back to idle for the same reason.
     */
    void KeepUp(Unit* owner)
    {
        /*
         * IN A FIGHT SHE PLANTS AND STAYS PLANTED. MoveFollow holds a fixed two
         * yards, so out of the box she shuffles after every step her owner
         * takes, which looks anxious and - more to the point - cancels
         * everything with a cast time. Lesser Heal has one; the wand and Renew
         * do not, which is why instants were landing while heals were not.
         *
         * Two distances rather than one, so she does not oscillate on the
         * boundary: she stops once inside HOLD, and only takes up the chase
         * again past RESUME. Both sit inside the 30 yard search radius the heal
         * slots use for targetParam1, so holding never costs her the target.
         *
         * Out of combat she just follows, which is what you want when walking
         * between quests.
         */
        const bool fighting = owner->IsInCombat();

        if (fighting)
        {
            if (m_holding)
            {
                if (m_creature->IsWithinDistInMap(owner, COMPANION_RESUME_DIST))
                    return;

                m_holding = false;              // owner walked off; go after them
            }
            else if (m_creature->IsWithinDistInMap(owner, COMPANION_HOLD_DIST))
            {
                m_creature->GetMotionMaster()->Clear(false);
                m_creature->GetMotionMaster()->MoveIdle();
                m_creature->StopMoving();
                m_holding = true;
                return;
            }
        }
        else
            m_holding = false;

        if (m_creature->GetMotionMaster()->GetCurrentMovementGeneratorType() != FOLLOW_MOTION_TYPE)
        {
            m_creature->GetMotionMaster()->Clear(false);
            m_creature->GetMotionMaster()->MoveFollow(owner, PET_FOLLOW_DIST,
                                                      static_cast<Pet*>(m_creature)->GetFollowAngle());
        }
    }

    /*
     * MATCH THE OWNER'S COMBAT STATE, or she is useless in the only situation
     * that matters.
     *
     * castTarget 15 resolves through FindLowestHpFriendlyUnit, whose predicate
     * MostHPMissingInRangeCheck requires
     *
     *     i_obj->IsInCombat() == u->IsInCombat()
     *
     * (GridNotifiers.h:816). A pure healer never acquires a victim, so she
     * never enters combat by herself, so the instant her owner is attacked the
     * owner drops out of her search completely. Measured, before this existed:
     *
     *     tick: ... ownerCombat 0, ownerHp 35%, target Luf.
     *     tick: ... ownerCombat 1, ownerHp 35%, target NOBODY.
     *
     * SetInCombatState(0, nullptr) is deliberately the narrowest tool here.
     * IsInCombat() is nothing but UNIT_FLAG_IN_COMBAT (Unit.h:1423), and a null
     * enemy makes Creature::OnEnterCombat return at its first line
     * (Creature.cpp:3351) -- so CSTATE_COMBAT is never set and the evade, leash
     * and call-for-help machinery all stay asleep. No threat is generated, so
     * nothing starts attacking her because of this. The one real side effect is
     * that her health stops regenerating while flagged, which is correct.
     *
     * The alternatives were worse. Relaxing the predicate changes every healing
     * creature in the world; a private target search throws away the point of
     * driving targeting from creature_spells; and castTarget 7 (the owner, no
     * search) would work but discards the per-spell health thresholds, which
     * ARE the tiering.
     */
    void MatchOwnerCombatState(Unit* owner)
    {
        if (owner->IsInCombat())
        {
            if (!m_creature->IsInCombat())
                m_creature->SetInCombatState(0, nullptr);
        }
        else if (m_creature->IsInCombat())
            m_creature->ClearInCombat();
    }

    /*
     * ADOPT THE OWNER'S TARGET so the filler damage slots have something to
     * aim at.
     *
     * creature_spells has no cast target meaning "whatever my owner is
     * fighting". The hostile types (1 TARGET_T_HOSTILE, 4 RANDOM, and the rest)
     * all resolve off THIS creature's own victim or threat list, and a pure
     * healer has neither -- she never attacks, so slot 4 would find nothing and
     * silently never fire.
     *
     * Attack(foe, false) is the whole fix: the false is meleeAttack, so she
     * takes a victim without starting to swing, and because our AttackStart is
     * a no-op and the movement generator stays FOLLOW, nothing makes her chase.
     * She keeps walking at her owner's heel and shoots from wherever she is.
     *
     * Threat is real and worth expecting: healing already pulls mobs off a
     * low-damage owner, and adding a wand adds to that. The dial for how much
     * she can survive is health_max in creature_template.
     */
    void HelpFight(Unit* owner)
    {
        // ONLY WHILE THE OWNER IS ACTUALLY FIGHTING. Without this guard she
        // adopts whatever GetVictim() happens to still return when the owner is
        // out of combat, which is how she ended up opening on a mob that had
        // respawned near her. Her target is derived fresh from her owner every
        // tick and is never remembered, so gating on combat is the whole fix:
        // no combat, no target, and AttackStop below clears any she still had.
        Unit* foe = owner->IsInCombat() ? owner->GetVictim() : nullptr;

        /*
         * DO NOT USE Unit::CanAttack HERE, IN EITHER FORM. Both were tried on
         * 2026-09-06 and both refuse yellow, non-aggressive mobs:
         *
         *   CanAttack(foe)        -> "am I hostile to it" (Unit.cpp:5742). She
         *                            is not. Attacking a neutral makes the
         *                            PLAYER temporarily at war with its faction
         *                            (Creature::OnEnterCombat), but at-war is a
         *                            player ReputationMgr concept. She carries
         *                            her owner's faction TEMPLATE, not their
         *                            reputations.
         *   CanAttack(foe, true)  -> for a pet this defers to
         *                            pOwner->CanAttack(target) (Unit.cpp:5734),
         *                            which looked like the right rule and is
         *                            not: that inner call is itself unforced,
         *                            so it asks whether the PLAYER is hostile,
         *                            and the at-war flag is only set when the
         *                            creature has a reputation faction at all
         *                            (`GetReputationId() >= 0`). Ordinary
         *                            wildlife has none, so it stays false.
         *
         * The owner having it as GetVictim() already IS the statement that they
         * are fighting it. So the only questions left are whether she would be
         * hitting a friend and whether the thing can be hit at all.
         */
        const bool bValidFoe = foe
            && foe->IsAlive()
            && !m_creature->IsFriendlyTo(foe)
            && foe->IsTargetable(true, true)
            // Players are excluded deliberately: in a duel the owner's victim
            // is the opponent, and a companion joining in would be
            // interference. Whether companions should ever help in PvP is a
            // design decision, not something to fall into by accident.
            && !foe->IsPlayer();

        if (!bValidFoe)
        {
            if (m_creature->GetVictim())
                m_creature->AttackStop();
            return;
        }

        if (m_creature->GetVictim() != foe)
            m_creature->Attack(foe, false);
    }

    /*
     * TURN TO FACE WHAT SHE IS SHOOTING -- because standing still stopped the
     * client from being told.
     *
     * Spell::cast turns a creature toward its target with Unit::SetInFront,
     * and SetInFront is SetOrientation and nothing else (Unit.cpp:3306): a
     * server-side value, with no packet. While she was following, the client
     * was receiving movement constantly and her facing came out right as a side
     * effect of that. The moment she plants and stops moving, nothing tells the
     * client she turned, so she wands with her back to the mob. The hold
     * behaviour caused this; it is not a stray bug.
     *
     * Unit::SetFacingTo is the one that actually launches a spline and informs
     * the client, and SetFacingToObject wraps it with an "only when stopped"
     * guard (Unit.cpp:3322) -- exactly our case, and a no-op while following,
     * where movement already handles it.
     *
     * Doing it here rather than in Spell::cast is also what makes it calm. The
     * earlier attempt to suppress core facing failed because turning LESS is
     * not what was wanted; turning less OFTEN is. So: only while planted, only
     * when the target has drifted more than about 45 degrees off her nose, and
     * at most once a second.
     */
    void FaceTarget(const uint32 uiDiff)
    {
        if (m_faceTimer > uiDiff)
        {
            m_faceTimer -= uiDiff;
            return;
        }
        m_faceTimer = 1000;

        if (!m_holding)
            return;

        Unit* foe = m_creature->GetVictim();
        if (!foe || !foe->IsAlive())
            return;

        // M_PI_F / 2 is a 90 degree arc, so 45 degrees either side of where she
        // is already looking. Inside that she is facing it well enough.
        if (m_creature->HasInArc(foe, M_PI_F / 2))
            return;

        m_creature->SetFacingToObject(foe);
    }

    void UpdateAI(const uint32 uiDiff) override
    {
        Unit* owner = m_creature->GetOwner();
        if (!owner || !owner->IsInWorld() || !owner->IsAlive())
            return;

        KeepUp(owner);
        MatchOwnerCombatState(owner);
        HelpFight(owner);
        FaceTarget(uiDiff);

        if (m_CreatureSpells.empty())
            return;

        if (!m_creature->IsWithinDistInMap(owner, float(COMPANION_LEAVE_DISTANCE)))
            return;

        // The one line the stock AIs will not give us: cast the list whether or
        // not anybody is being hit.
        UpdateSpellsList(uiDiff);

        // SPIKE DIAGNOSTICS, once every three seconds. Reports what the heal
        // target search actually returns, using the same call the spell list
        // makes: FindLowestHpFriendlyUnit(radius, percent-missing, bPercent).
        if (m_reportTimer <= uiDiff)
        {
            m_reportTimer = 3000;

            Unit* found = m_creature->FindLowestHpFriendlyUnit(30.0f, 15, true);
            sLog.outString("[companion] tick: spells %u, moving %u, casting %u, myCombat %u, ownerCombat %u, ownerHp %u%%, mana %u, target %s.",
                           uint32(m_CreatureSpells.size()),
                           uint32(m_creature->IsMoving()),
                           uint32(m_creature->IsNonMeleeSpellCasted(false)),
                           uint32(m_creature->IsInCombat()),
                           uint32(owner->IsInCombat()),
                           uint32(owner->GetHealthPercent()),
                           m_creature->GetPower(POWER_MANA),
                           found ? found->GetName() : "NOBODY");

            sLog.outString("[companion]   holding %u, myVictim %s, ownerVictim %s.",
                           uint32(m_holding),
                           m_creature->GetVictim() ? m_creature->GetVictim()->GetName() : "none",
                           owner->GetVictim() ? owner->GetVictim()->GetName() : "none");

            // Which gate is refusing a target, rather than another round of
            // guessing at it.
            if (Unit* ov = owner->GetVictim())
                sLog.outString("[companion]   foe '%s': friendly %u, hostile %u, targetable %u, canAtk %u, canAtkForce %u, ownerCanAtk %u.",
                               ov->GetName(),
                               uint32(m_creature->IsFriendlyTo(ov)),
                               uint32(m_creature->IsHostileTo(ov)),
                               uint32(ov->IsTargetable(true, true)),
                               uint32(m_creature->CanAttack(ov)),
                               uint32(m_creature->CanAttack(ov, true)),
                               uint32(owner->CanAttack(ov)));

            // Mana never moved across nineteen seconds with a valid target, so
            // nothing was being cast at all. Print each slot's remaining
            // cooldown, and then ask TryToCast directly for the failure code --
            // the one number that says why. A successful probe simply heals,
            // which is the wanted outcome anyway.
            for (const auto& sp : m_CreatureSpells)
                sLog.outString("[companion]   slot spell %u cooldown %u castTarget %u param2 %u flags %u prob %u.",
                               sp.spellId, sp.cooldown, uint32(sp.castTarget),
                               uint32(sp.targetParam2), uint32(sp.castFlags), uint32(sp.probability));

            // The direct TryToCast probe that lived here has done its job and is
            // gone: it answered 255, which is SPELL_CAST_OK (SpellDefines.h:433),
            // proving the cast path was never the problem. What was wrong was
            // the timers -- see the units trap in sql/custom/065. Leaving a
            // probe that force-casts every three seconds in place would mask
            // the real rotation, which is the thing now under test.
        }
        else
            m_reportTimer -= uiDiff;
    }
};

CreatureAI* GetAI_npc_companion_healer(Creature* pCreature)
{
    return new npc_companion_healerAI(pCreature);
}

bool GossipHello_npc_companion_recruiter(Player* pPlayer, Creature* pCreature)
{
    pPlayer->ADD_GOSSIP_ITEM(GOSSIP_ICON_CHAT, "I could use a healer.",
                             GOSSIP_SENDER_MAIN, GOSSIP_ACTION_HIRE_HEALER);
    pPlayer->ADD_GOSSIP_ITEM(GOSSIP_ICON_CHAT, "Send my companion away.",
                             GOSSIP_SENDER_MAIN, GOSSIP_ACTION_DISMISS);
    pPlayer->SEND_GOSSIP_MENU(GOSSIP_TEXT_RECRUITER, pCreature->GetObjectGuid());
    return true;
}

bool GossipSelect_npc_companion_recruiter(Player* pPlayer, Creature* /*pCreature*/,
                                          uint32 /*uiSender*/, uint32 uiAction)
{
    ChatHandler chat(pPlayer);

    switch (uiAction)
    {
        case GOSSIP_ACTION_HIRE_HEALER:
        {
            if (pPlayer->FindGuardianWithEntry(NPC_COMPANION_HEALER))
            {
                chat.SendSysMessage("You already have a healer.");
                break;
            }

            // Matched to the player for the spike. Whether that is the right
            // rule, and what the power dial should be, is the next question
            // after this one answers.
            Pet* companion = SummonCompanion(pPlayer, NPC_COMPANION_HEALER, pPlayer->GetLevel());
            if (!companion)
            {
                chat.SendSysMessage("Nobody is free just now.");
                break;
            }

            chat.PSendSysMessage("%s falls in beside you.", companion->GetName());
            break;
        }
        case GOSSIP_ACTION_DISMISS:
        {
            if (!pPlayer->FindGuardianWithEntry(NPC_COMPANION_HEALER))
            {
                chat.SendSysMessage("You have no companion out.");
                break;
            }

            pPlayer->RemoveGuardiansWithEntry(NPC_COMPANION_HEALER);
            chat.SendSysMessage("Your companion takes her leave.");
            break;
        }
    }

    pPlayer->CLOSE_GOSSIP_MENU();
    return true;
}

void AddSC_npc_companion_spike()
{
    Script* newscript;

    newscript = new Script;
    newscript->Name = "npc_companion_recruiter";
    newscript->pGossipHello = &GossipHello_npc_companion_recruiter;
    newscript->pGossipSelect = &GossipSelect_npc_companion_recruiter;
    newscript->RegisterSelf();

    newscript = new Script;
    newscript->Name = "npc_companion_healer";
    newscript->GetAI = &GetAI_npc_companion_healer;
    newscript->RegisterSelf();
}
