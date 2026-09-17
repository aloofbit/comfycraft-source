/*
 * item_house_furniture -- right-click a furniture item to place it in your
 * house. Bound by item_template.script_name on every row of
 * tw_world.house_furniture_item; see sql/custom/042_furniture_items.sql.
 *
 * IT DOES NOT AIM, AND IT DOES CAST. Those are separate decisions and it is
 * worth keeping them apart, because they were briefly conflated and the wrong
 * one got removed:
 *
 *   - NO RETICLE. The crate used to carry a spell with
 *     TARGET_FLAG_DEST_LOCATION so the client raised its ground circle and
 *     sent back the clicked point. The Decorator's Chalk does that for every
 *     route into housing now, including `.house object add` and the addon,
 *     which a per-item spell never could. Twelve items that aimed themselves,
 *     beside a tool that aims everything, was one mechanism too many. The
 *     whole design is in docs/notes/point-and-click-placing.md.
 *
 *   - BUT KEEP THE CAST BAR. Making furniture should FEEL like making
 *     something: a one-second bar and the crafting animation. That is the
 *     point of it, and it is not a consolation for having nothing to aim --
 *     which is the mistake that briefly deleted it. Aiming happens earlier,
 *     with the chalk; this is the moment the thing gets built.
 *
 * SO THE SPELL REALLY CASTS, AND THE PLACEMENT WAITS FOR IT. pItemUse is
 * called from WorldSession::HandleUseItemOpcode (Handlers/SpellHandler.cpp:174)
 * BEFORE CastItemUseSpell, so returning FALSE is the whole mechanism: the
 * caller goes on to cast, the client draws its bar, and
 * spell_house_furniture_place::OnSuccessfulFinish puts the object down.
 *
 * A REFUSAL STILL COSTS NOTHING, because it is decided BEFORE the cast starts.
 * HouseFurnitureShouldCast asks whether placing could work and returns true
 * only if it could, so a full house or somebody else's is an instant message
 * with no bar, no cooldown, no charge and the crate still in the bag.
 *
 * WHY OnSuccessfulFinish AND NOT pItemUseSpell. The name says "after the cast"
 * and it is not: Player::CastItemUseSpell calls OnItemUseSpell straight after
 * spell->prepare(), which for a timed spell is the moment the bar STARTS.
 * OnSuccessfulFinish is the last statement of Spell::finish(true), so an
 * interrupted cast places nothing and keeps the crate, with no code of ours to
 * make that true.
 *
 * IT RUNS AFTER TakeCastItem, WHICH IS WHAT MAKES CONSUMING THE ITEM SAFE.
 * The crates carry spellcharges_1 = 0, so that function finds nothing
 * expendable and leaves m_CastItem alone; by the time the script runs nothing
 * else will touch it.
 *
 * THE CRATES CARRY 33453 "Over-Tinkered Lens": Targets 0x0 (no reticle),
 * SpellVisual 215 (the crafting animation), CastingTimeIndex 4 = 1000ms, and
 * Effect0 = 3 (DUMMY) so the cast itself does nothing but look right. Its
 * Description is about engineering goggles, which would otherwise appear as the
 * green "Use:" line on every crate -- ComfyHousing's Tooltip.lua strips it, and
 * a client without the addon sees it. That is the standing cost of the
 * animation, and it was accepted knowingly.
 */

#include "ScriptMgr.h"
#include "Player.h"
#include "Item.h"
// SpellCastTargets is only forward-declared in ScriptMgr.h; the chalk below
// reads its destination, which needs the definition. TARGET_FLAG_DEST_LOCATION
// comes from DBCEnums.h, which ScriptMgr.h already pulls in.
#include "Spell.h"

// src/game/Housing is the one game subfolder missing from the scripts
// project's include path (src/scripts/CMakeLists.txt), so HouseMgr.h cannot be
// included here. Declaring the entry points extern is the seam this repo
// already uses to reach a module from the core -- the same shape as
// BotActionLog_* and SCRIPT_COMMAND_RECRUIT_BOT. Both are defined in
// src/game/Housing/HouseMgr.cpp and message the player themselves on failure.
extern bool HouseUseFurnitureItem(Player* player, Item* item);
extern bool HouseFurnitureShouldCast(Player* player, Item* item);

bool ItemUse_item_house_furniture(Player* player, Item* item, SpellCastTargets& /*targets*/)
{
    if (!player || !item)
        return true;

    // FALSE hands it to the spell, which is what the client is about to draw a
    // bar for. TRUE stops here, and the refusal message has already been sent.
    return !HouseFurnitureShouldCast(player, item);
}

// The other end of the cast route, bound by spell_template.script_name on the
// one spell the crates carry; see sql/custom/055.
struct spell_house_furniture_place : public SpellScript
{
    void OnSuccessfulFinish(Spell* spell) const override
    {
        if (!spell)
            return;

        Player* player = spell->m_casterUnit ? spell->m_casterUnit->ToPlayer() : nullptr;
        Item* item = spell->GetCastItem();

        // NO CAST ITEM MEANS THIS WAS NOT US. The spell is a stock one and the
        // script is bound to the spell, not to the item -- so anything else
        // that ever casts it falls out here rather than placing furniture.
        // HouseUseFurnitureItem checks the entry as well.
        if (!player || !item)
            return;

        // Where it lands is decided downstream: the chalk mark if there is one,
        // otherwise HOUSE_PLACE_DISTANCE yards ahead. Nothing about aiming is
        // known here, which is the point -- one rule, in PlaceObject.
        if (!HouseUseFurnitureItem(player, item))
            return;

        // Clear the spell's handle BEFORE destroying, the pattern the core uses
        // two lines up from where this is called. TakeCastItem has already run
        // and found nothing expendable, so the item is still here and nothing
        // else is going to read the pointer.
        spell->SetCastItem(nullptr);

        uint32 count = 1;
        player->DestroyItemCount(item, count, true);
    }
};

template <class T>
static SpellScript* GetHouseSpellScript(SpellEntry const*)
{
    return new T();
}

/*
 * item_house_chalk -- the Decorator's Chalk. Right-click it inside your own
 * house, click the floor, and the point is remembered; the next object you
 * place lands on it. sql/custom/054, item entry 100200.
 *
 * IT LIVES IN THIS FILE RATHER THAN ITS OWN, and that is a build decision
 * rather than a taxonomic one. A new .cpp under src/scripts has to be added by
 * hand to THREE lists -- src/scripts/CMakeLists.txt (which enumerates every
 * file and does not glob), and both the declaration and the call in
 * ScriptLoader.cpp -- and needs a configure re-run. Adding a fourth line to an
 * AddSC that already registers two scripts costs none of that. The file is
 * housing's item scripts; the name is one script old.
 *
 * WHY IT AIMS THE SAME WAY A CRATE DOES. The reticle comes from the item's own
 * spell carrying TARGET_FLAG_DEST_LOCATION -- see the header above -- and the
 * chalk carries 261, the identical spell, for the identical reason. It is not
 * re-chosen: 261 is the only spell in this client proven to raise the circle,
 * accept a point at any distance including your feet, and say nothing on the
 * item's tooltip.
 *
 * IT IS NEVER CONSUMED, AND RETURNING TRUE IS THE WHOLE MECHANISM FOR THAT.
 * pItemUse runs before CastItemUseSpell, so true means no cast, no cooldown,
 * no charge and no consume -- which is exactly what a reusable tool wants, and
 * is the same property that makes a furniture refusal free next door. Nothing
 * here destroys the item, on any path.
 *
 * A REFUSAL IS NOT AN ERROR WORTH BRANCHING ON. HouseUseChalk messages the
 * player itself -- not in your house, aimed too far, or a client whose cached
 * copy of the item predates the spell and so sent no point at all. This
 * returns true either way, because the item is ours whatever the answer was.
 */
extern bool HouseUseChalk(Player* player, bool haveSpot, float x, float y, float z);

bool ItemUse_item_house_chalk(Player* player, Item* item, SpellCastTargets& targets)
{
    if (!player || !item)
        return true;

    float x = 0.0f, y = 0.0f, z = 0.0f;
    bool const haveSpot = (targets.m_targetMask & TARGET_FLAG_DEST_LOCATION) != 0;
    if (haveSpot)
        targets.getDestination(x, y, z);

    HouseUseChalk(player, haveSpot, x, y, z);
    return true;
}

void AddSC_item_house_furniture()
{
    Script* newscript = new Script;
    newscript->Name = "item_house_furniture";
    newscript->pItemUse = &ItemUse_item_house_furniture;
    newscript->RegisterSelf();

    newscript = new Script;
    newscript->Name = "spell_house_furniture_place";
    newscript->GetSpellScript = &GetHouseSpellScript<spell_house_furniture_place>;
    newscript->RegisterSelf();

    newscript = new Script;
    newscript->Name = "item_house_chalk";
    newscript->pItemUse = &ItemUse_item_house_chalk;
    newscript->RegisterSelf();
}
