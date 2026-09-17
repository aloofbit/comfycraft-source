#ifndef MANGOS_BOTNPC_H
#define MANGOS_BOTNPC_H

#include "Common.h"
#include "Policies/Singleton.h"
#include "UnitDefines.h"

#include <array>
#include <map>
#include <string>

/*
 * BOT NPCs -- characters that act as NPCs.
 *
 * A playerbot can be an NPC. Measured 2026-09-13: set UNIT_NPC_FLAGS on a
 * PLAYER unit and the 1.12 client draws the talk cursor, sends
 * CMSG_GOSSIP_HELLO with that player's guid, renders whatever menu comes back
 * keyed to the guid, and returns the click with sender and action intact. The
 * whole measurement, and the updateVisualBits bit without which none of it
 * reaches a viewer, is docs/ai/content/playerbot-npcs.md.
 *
 * WHY BOTHER, given the core already has creatures. A creature's worn armour
 * lives in the CLIENT -- DBCStructure.h:205 says so itself, "client show its by
 * self" -- so dressing a custom creature means shipping a patched
 * CreatureDisplayInfoExtra.dbc to every player. A bot is a real Player and
 * wears what is in its inventory with nothing shipped, cape included, which a
 * creature can never have at all: 1.12 has ten NPC item slots, ending at
 * tabard.
 *
 * A ROW IS A DESIGN, AND THE CHARACTER IS SOMETHING IT ACQUIRES. That split is
 * the design rather than an unfinished half of it. A character can only safely
 * be created by the server -- guids are reused, and this repo has been bitten
 * three times by rows outliving the character they named -- and placing one
 * needs a person standing where it should go. So the WEBSITE owns the parts
 * that are decisions (name, race, look, words) and the GAME owns the parts that
 * are allocations (the character, the spot). characterGuid is 0 until
 * `.npcbot place` makes one.
 *
 * RACE AND GENDER ARE FIXED AT DESIGN TIME, because they cannot be dressed on.
 * That is what lets the dressing room open "for this NPC" with the race locked,
 * so a look and a character that were not drawn for each other cannot be
 * expressed in the first place.
 *
 * WHAT IT SAYS IS NOT IN HERE. The dialog is ordinary world data in
 * `gossip_menu` and `gossip_menu_option`, so changing the words needs nothing
 * from this table -- `.reload gossip_menu` already covers it. Only the binding
 * lives here, which is why one `reload bot_npc` covers everything the website
 * does to it.
 */

class Player;
class Unit;
struct VendorItemData;

/*
 * PUTS `look` ON `bot`. Implemented in the playerbots module and stubbed in
 * src/game/PlayerbotStubs.cpp, because THE CORE NEVER INCLUDES PLAYERBOT
 * HEADERS -- an extern free function is the crossing this codebase uses, the
 * same one SCRIPT_COMMAND_RECRUIT_BOT goes through.
 *
 * It lives on the module's side rather than here because the equip it does is
 * RandomPlayerbotMgr::CanEquipUnseenItem: a bot NPC wears its outfit as a
 * costume and has no business meeting the level, class and faction
 * requirements of the piece whose LOOK was chosen. Player::CanEquipNewItem
 * would enforce them and quietly leave slots empty.
 *
 * Returns false and fills `error` only for a whole-outfit refusal -- a race
 * that does not match. Individual slots that cannot be resolved are skipped.
 */
bool BotNpc_Dress(Player* bot, std::string const& look, std::string& error);

/*
 * PUTS `bot` IN A GUILD CALLED `subname`, creating it if nobody has yet, so the
 * client draws "<Innkeeper>" under the name where a creature's subname would
 * be. An empty subname takes it back out of whatever it was in.
 *
 * Core-side and not in the module, unlike BotNpc_Dress -- guilds are ordinary
 * core machinery with no playerbot involvement at all.
 */
void BotNpc_ApplySubname(Player* bot, std::string const& subname);

/*
 * THE NAME EVERY RANK IN A BOT NPC'S GUILD WEARS, WHICH IS A MARKER FOR THE
 * CLIENT AND NOT A LABEL FOR ANYONE.
 *
 * The 1.12 client decides "this is a player" from the guid's high bits, so the
 * tooltip is a player's tooltip no matter what the server says: it reads
 * "Level 60 Player" where a real NPC would read "Level 60 Humanoid". Masking
 * UNIT_FLAG_PLAYER_CONTROLLED per viewer (Object.cpp) does not move it, and the
 * NPC form of the line cannot be reached anyway -- the creature type travels in
 * SMSG_CREATURE_QUERY_RESPONSE, which needs a creature entry a player has not
 * got. So the tooltip is fixed up client-side, by addon/ComfyNPC.
 *
 * WHICH LEAVES THE ADDON NEEDING TO RECOGNISE ONE, and this is the cheapest
 * honest answer. Rank names ride in SMSG_GUILD_QUERY_RESPONSE, all ten of them,
 * and Guild::Query answers any session for any guild id with no membership
 * check -- the same open door that makes the <Innkeeper> line work at all.
 * PLAYER_GUILDRANK is in Player::InitVisibleBits, so the index reaches other
 * viewers too. Between them GetGuildInfo(unit) hands a 1.12 addon this string,
 * for a unit it has no relationship with, over packets the client already asks
 * for. No new opcode, no roster to push, and nothing to keep in sync as NPCs
 * are added.
 *
 * EVERY rank, not one. A bot NPC founds the guild wearing its subname or joins
 * an existing one at GetLowestRank(), so which rank it holds depends on the
 * order they were placed in. Naming them all the same makes the marker true
 * whichever it got. Nobody reads these: a guild that exists to be a subname has
 * no roster anyone opens.
 */
#define BOT_NPC_GUILD_RANK "ComfyNPC"

/*
 * THE STOCK LIST A BOT NPC SELLS, or nullptr for anything that is not one.
 *
 * A bot NPC has no creature entry, so `npc_vendor` -- which is keyed by one --
 * can never hold its stock. It points at a `npc_vendor_template` row set
 * instead, by id, and that is the ONLY reason the website builds shops on the
 * template table rather than on npc_vendor. sql/custom/092 has the long version.
 *
 * Answers nullptr for the overwhelming majority of units, which are not bot
 * NPCs or do not sell anything -- callers treat that as "not a vendor" rather
 * than as an error, the same way sBotNpcMgr.Get does.
 *
 * A free function rather than a Unit member because src/game/Housing and the
 * playerbot module already established this seam, and because nothing about
 * Unit should have to know what a bot NPC is.
 */
VendorItemData const* BotNpc_VendorItems(Unit const* unit);

/*
 * MAKES A BOT NPC UNKILLABLE, or takes that back when `on` is false.
 *
 * UNIT_FLAG_IMMUNE_TO_PLAYER and UNIT_FLAG_IMMUNE_TO_NPC are the two halves of
 * "nothing may attack this": Unit.cpp:7003 refuses a player attacker on the
 * first and :7006 a creature attacker on the second.
 *
 * HAS TO BE RE-ASSERTED RATHER THAN SET ONCE. Player::InitStatsForLevel clears
 * both -- along with most of UNIT_FIELD_FLAGS -- on its way through login and
 * any level change, with the comment "will be re-applied if need at aura load".
 * A bot NPC has no aura to re-apply it, so the maintenance is ours.
 */
void BotNpc_ApplyInvulnerability(Player* bot, bool on);

/*
 * WHAT A BOT NPC STANDS WITH IN ITS HANDS, read off its own `look`.
 *
 * The dressing room has had the control all along -- Away / Melee / Ranged,
 * the game's own three states (UnitDefines.h:130) -- and it has been writing
 * `hold=` into the look since the day looks could be saved onto an NPC.
 * Nothing in game ever read it, so every bot NPC stood with everything put
 * away: UNIT_FIELD_BYTES_2 byte 0 is never set server-side for a PLAYER --
 * the client owns it, over CMSG_SETSHEATHED -- and a bot NPC has no client,
 * so the byte stayed at its zero, which is SHEATH_STATE_UNARMED.
 *
 * THE LOOK IS THE WHOLE CONTROL AND THERE IS NO COLUMN FOR THIS. A second
 * place to say it would be a second place to disagree, and the toggle the
 * outfit was drawn under is the one somebody meant.
 *
 * NO `hold` AT ALL MEANS MELEE, because that is what the dressing room draws
 * by default: the figure it shows with the sword out is the promise being
 * kept. Designs that predate this therefore stand up drawn, and `hold=away`
 * on one puts the weapons back.
 *
 * Reaching other viewers needs UNIT_FIELD_BYTES_2 in Player::InitVisibleBits,
 * the same way UNIT_NPC_FLAGS does. That one was already there.
 */
SheathState BotNpc_SheathFor(std::string const& look);

/*
 * WHERE A BOT NPC'S QUESTS HANG, and why the number is not a creature entry.
 *
 * `creature_questrelation` and `creature_involvedrelation` are keyed by an id
 * that is USUALLY a creature entry, and nothing in the loader requires it to
 * be one. So a bot NPC points at an id in this block instead, and the two
 * world tables, the two reload commands and the website editor all carry bot
 * quests without knowing they are doing it. The alternative -- a bot-shaped
 * pair of tables and a second set of maps in ObjectMgr -- buys nothing and has
 * to be kept in step with the creature pair for ever.
 *
 * A BLOCK RATHER THAN "ANY ID THAT IS NOT A CREATURE", so a number says which
 * kind of thing it is the way shop ids 200000-200999 do, and so the relation
 * loaders can tell a deliberate bot id from a typo'd creature entry. They warn
 * about the second and say nothing about the first.
 */
#define BOT_NPC_QUEST_ID_MIN 210000
#define BOT_NPC_QUEST_ID_MAX 210999

inline bool BotNpc_IsQuestGiverId(uint32 id)
{
    return id >= BOT_NPC_QUEST_ID_MIN && id <= BOT_NPC_QUEST_ID_MAX;
}

/*
 * WHAT A BOT NPC DOES WHEN NOBODY HAS TOLD IT TO DO ANYTHING.
 *
 * A bot NPC stands there, deliberately: the module's update returns before
 * DoNextAction for anything IsBotNpc(), because the first one placed in the
 * world re-rolled its gear on a loop and then wandered off to attack something.
 * Switching the AI off was right. These rows are the other half -- what it
 * should do INSTEAD, written by a person rather than decided by an engine.
 *
 * THREE TRIGGERS, ONE ROW EACH, in `bot_npc_idle`. A design may carry any of
 * them or none, which is what the UNIQUE key on (bot_npc_id, trigger_kind)
 * buys: a section is ABSENT rather than zeroed when it is not in use.
 *
 * WHAT EACH ONE RUNS IS AN ORDINARY SCRIPT, a `generic_scripts` id in the block
 * below, with the same delay-and-priority timeline a gossip button already has.
 * Map::ScriptsStart runs it with the NPC as source and whoever set it off as
 * target. No second executor, and every command handler already works --
 * including SCRIPT_COMMAND_MOVE_TO, which was widened from Creature to Unit on
 * 2026-09-15 for precisely this kind of reason.
 *
 * `docs/ai/content/npc-idle.md`, and sql/custom/100.
 */
/*
 * A POINT SO MANY YARDS AHEAD OF AND TO THE RIGHT OF A UNIT'S POST, standing on
 * the ground. Negative is behind and to the left; 0, 0 is the post itself.
 *
 * THE POST, NOT WHERE IT IS STANDING. An offset from wherever the NPC happens
 * to be drifts: "three yards forward" in a loop is a walk that never comes
 * back. An offset from its post means the same place every time, and because
 * the post is data rather than a point in the world, `.npcbot move` carries a
 * whole routine along with the NPC -- which is the one thing named spots cannot
 * do.
 *
 * Which post:
 *   a bot NPC   its bot_npc row: where `.npcbot place` stood it, facing the
 *               way it faced then
 *   a creature  its spawn point and facing
 *   a player    where it stands now -- a GM running a scene on themselves to
 *               test one, which is the only way a real player gets here
 *
 * TURNED BY THE POST'S FACING, so "ahead" is the way the NPC looks when it is at
 * home. Orientation 0 faces +X and grows anticlockwise, so right is o - pi/2.
 *
 * AND SNAPPED TO THE GROUND, which is the half that makes hills work. The
 * offset is flat, so the height has to be found: searched downward from a few
 * yards ABOVE the post's height, because a search from the post's own height
 * misses ground that rises, and a destination more than 3 yards under the
 * walkable surface is refused by the pathfinder outright (PathFinder.cpp,
 * FindWalkPoly), which sends the NPC in a straight line through the hill. The
 * headroom is deliberately small: indoors, a big one finds the floor upstairs.
 *
 * Returns false only when there is no post to be relative to on this map -- a
 * bot NPC standing somewhere other than where its row says.
 */
bool BotNpc_PointFromPost(Unit const* unit, float forward, float right,
                          float& x, float& y, float& z, float& o);

// The post itself: the position and facing that "ahead" and "right" are
// measured from. False when a bot NPC's row names another map. Split out so the
// two functions either side of it cannot disagree about which post a unit has.
bool BotNpc_Post(Unit const* unit, float& x, float& y, float& z, float& o);

/*
 * THE INVERSE: how far ahead of and to the right of a unit's post a world
 * position is. `.spotfrom` stands on the answer -- walk to where the NPC should
 * go, select it, and read off the two numbers to type into "Walks from its
 * post" or `npc:WalkOffset`. Guessing "3 ahead, 2 left" was the weak half of
 * post offsets; naming a spot by standing on it is easy, so this makes the
 * numbers just as easy.
 */
bool BotNpc_OffsetFromPost(Unit const* unit, float worldX, float worldY,
                           float& forward, float& right);

// How far above the post's height the ground search starts. See above.
#define BOT_NPC_POST_GROUND_HEADROOM 5.0f

// The furthest an offset may reach, either way. A routine that walks forty
// yards from home has stopped being a chore and become a patrol, and a spot is
// the better tool for that.
#define BOT_NPC_POST_MAX_OFFSET 40.0f

#define BOT_NPC_IDLE_SCRIPT_MIN 6450000
#define BOT_NPC_IDLE_SCRIPT_MAX 6459999

inline bool BotNpc_IsIdleScriptId(uint32 id)
{
    return id >= BOT_NPC_IDLE_SCRIPT_MIN && id <= BOT_NPC_IDLE_SCRIPT_MAX;
}

enum BotNpcIdleTrigger
{
    BOT_NPC_IDLE_LOOP       = 0,                            // every `period` seconds
    BOT_NPC_IDLE_NEAR       = 1,                            // a real player crosses into `radius`
    BOT_NPC_IDLE_AFTER_TALK = 2,                            // a conversation with it ends

    /*
     * AND THE ONE THAT IS NOT A TRIGGER AT ALL.
     *
     * The three above fire a timeline on a moment the server decides. `custom`
     * hands the whole question to the author: it is a Lua scene holding its own
     * loop, its own waits and its own conditions, started ONCE when the NPC
     * comes into the world and never restarted on a clock.
     *
     * So it reads `sceneId` rather than `scriptId`, and `period` and `radius`
     * mean nothing to it.
     */
    BOT_NPC_IDLE_CUSTOM     = 3,

    BOT_NPC_IDLE_TRIGGERS   = 4
};

struct BotNpcIdleRule
{
    bool   enabled;
    // loop: seconds between runs. near and after_talk: the cooldown before it
    // may fire again, which is what stops somebody hopping in and out of the
    // radius from turning one wave into a seizure. `custom` has no clock.
    uint32 period;
    float  radius;                                          // `near` only
    uint32 scriptId;                                        // generic_scripts, the three timelines
    uint32 sceneId;                                         // dialog_lua, `custom` only

    BotNpcIdleRule() : enabled(false), period(60), radius(15.0f), scriptId(0), sceneId(0) {}

    /*
     * A rule that is switched off, or points at nothing, is not a rule. Every
     * caller asks this rather than the fields, so a default-constructed one is
     * a safe answer to "what does this design do on that trigger".
     *
     * EITHER ID, NOT THE ONE THAT MATCHES THE TRIGGER, because a rule does not
     * carry its own trigger -- it is indexed by one. The loader only ever fills
     * the field its trigger means, so exactly one of the two can be set.
     */
    bool Runs() const { return enabled && (scriptId != 0 || sceneId != 0); }
};

// INDEXED BY TRIGGER, not a list. There is at most one rule per trigger, the
// database says so, and an array means a caller never writes a find loop.
typedef std::array<BotNpcIdleRule, BOT_NPC_IDLE_TRIGGERS> BotNpcIdleRules;

struct BotNpcEntry
{
    uint32      id;
    std::string name;
    uint32      race;
    uint32      gender;
    // The <bracket> line, implemented as a guild of this name -- a creature's
    // subname is not available to a player. Empty means no bracket.
    std::string subname;
    std::string look;           // the dressing room's query string
    // The outfit actually ON the character. Dressing is skipped outright while
    // this equals `look` -- see sql/custom/087 for why the character itself
    // cannot be asked instead.
    std::string lookApplied;
    uint32      gossipMenuId;

    // npc_vendor_template.entry -- the shop it sells. 0 sells nothing, which is
    // every bot NPC until somebody links one on the website. NOT a creature
    // entry: a bot NPC has none, which is why shops are built on the template
    // table at all. sql/custom/093.
    uint32      vendorTemplateId;

    // The id its quests hang off, in BOT_NPC_QUEST_ID_MIN..MAX. 0 gives out
    // nothing, which is every bot NPC until somebody links one. Several
    // designs may share one id, which is how two guards offer the same quest.
    uint32      questGiverId;
    uint32      npcFlags;

    // 0 while it is only a design. The core only ever acts on a placed one, but
    // it loads them all so `.npcbot place` can find a design by name.
    uint32      characterGuid;

    // Where it stands. NOT characters.position_*, which is IGNORED for a bot
    // NPC -- Player::LoadFromDB overrides the saved coordinates with these
    // before the map is resolved, so it arrives on its mark rather than being
    // teleported there afterwards where everyone can watch.
    uint32 mapId;
    float  x, y, z, o;

    BotNpcEntry() : id(0), race(1), gender(0), gossipMenuId(0), vendorTemplateId(0),
                    questGiverId(0), npcFlags(0), characterGuid(0), mapId(0),
                    x(0.0f), y(0.0f), z(0.0f), o(0.0f) {}

    bool IsPlaced() const { return characterGuid != 0; }
};

class BotNpcMgr
{
    public:
        BotNpcMgr() {}
        ~BotNpcMgr() {}

        void Load();

        // BY CHARACTER GUID, which is what every hot caller has: LoadFromDB and
        // Player::IsBotNpc both start from a character. nullptr for the
        // overwhelming majority of characters, which are not NPCs -- callers
        // treat that as "an ordinary player" rather than an error.
        BotNpcEntry const* Get(uint32 characterGuid) const;

        bool IsBotNpc(uint32 characterGuid) const { return Get(characterGuid) != nullptr; }

        // By the name on the design, placed or not. This is how `.npcbot place`
        // finds something with no character yet, so it deliberately does NOT go
        // through the character index.
        BotNpcEntry const* FindByName(std::string const& name) const;

        // Re-reads the table and re-applies flags to everyone already in world,
        // so a design edited on the website lands without a restart and without
        // bouncing the bot. `reload bot_npc`.
        void Reload();

        uint32 Count() const { return uint32(m_entries.size()); }

        /*
         * WHAT THIS DESIGN DOES UNPROMPTED, or nullptr if it does nothing.
         *
         * Loaded from `bot_npc_idle` by Load(), so `reload bot_npc` covers idle
         * rules for free and there is no second command to remember. The SCRIPT
         * behind a rule is world data and reloads on its own -- `reload
         * generic_scripts`, and that one FIRST, because a rule names a script id
         * and the script has to be in memory before a rule can start it.
         *
         * A design with no rule that Runs() gets no entry at all, which is what
         * makes AnyIdleRules() a meaningful gate: on a server that has never
         * used this, no map allocates a driver.
         */
        BotNpcIdleRules const* IdleRules(uint32 designId) const;
        bool AnyIdleRules() const { return !m_idle.empty(); }

        /*
         * BUMPED BY EVERY Load(), AND THAT IS WHAT RESTARTS A `custom` SCENE.
         *
         * A custom behaviour is started once and never put on a clock, so
         * without this, editing one would land in the table and change nothing
         * anybody can see until the server bounced. The driver keeps the
         * generation it started under and starts again when the two disagree,
         * which makes "save on the website, watch it happen" true for a scene
         * exactly as it is for a timeline.
         *
         * Every custom scene on the server restarts on any `reload bot_npc`.
         * That is the intended blast radius: they are a handful, a restart
         * costs a loop going back to its first line, and the alternative is a
         * reload that silently half-applies.
         */
        uint32 Generation() const { return m_generation; }

        // Write-through: the row and the in-memory copy move together, so a
        // command never has to remember to do both. The website writes the row
        // directly and calls `reload bot_npc`, which is the other direction.
        void Save(BotNpcEntry const& entry);

        // Records that a design's outfit is now on its character. Separate from
        // Save() because the dressing happens in the module, which has no
        // business rewriting the rest of the row.
        void MarkLookApplied(uint32 id, std::string const& look);
        void Remove(uint32 id);

        std::map<uint32, BotNpcEntry> const& All() const { return m_entries; }

    private:
        // Puts (or takes off) UNIT_NPC_FLAGS for every bot NPC currently logged
        // in. Split out because Load() must NOT do it -- see BotNpc.cpp.
        void ApplyToLoggedIn();

        void Reindex();

        void LoadIdleRules();

        std::map<uint32 /*design id*/, BotNpcEntry> m_entries;
        // characterGuid -> design id, for the placed ones only.
        std::map<uint32, uint32> m_byCharacter;
        // design id -> its idle rules. Only designs that actually do something
        // are in here; see IdleRules above.
        std::map<uint32, BotNpcIdleRules> m_idle;
        uint32 m_generation = 0;
};

#define sBotNpcMgr MaNGOS::Singleton<BotNpcMgr>::Instance()

#endif
