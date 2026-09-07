/*
 * This file is part of the AzerothCore Project. See AUTHORS file for Copyright information
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Affero General Public License as published by the
 * Free Software Foundation; either version 3 of the License, or (at your
 * option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License
 * for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program. If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef DROWNED_BELFRY_H
#define DROWNED_BELFRY_H

#include "AreaDefines.h"
#include "Position.h"

class Creature;
class Player;

static_assert(MAP_DROWNED_BELFRY == 900, "MAP_DROWNED_BELFRY must stay map 900");

enum DrownedBelfryCreatures
{
    NPC_KEEPER_MARROW           = 9000400,
    NPC_DROWNED_PARISHIONER     = 9000401,
    NPC_TIDEBORN_MURLOC         = 9000402,
    NPC_BRINE_ACOLYTE           = 9000403,
    NPC_DROWNED_SAILOR          = 9000404,
    NPC_BELL_ATTENDANT          = 9000405,
    NPC_SISTER_BRINE            = 9000406,
    NPC_CAPTAIN_WHELM           = 9000407,
    NPC_TOLL_BELLKEEPER         = 9000408,
    NPC_BRINE_DUMMY             = 9000409
};

enum DrownedBelfryGameObjects
{
    GO_BELFRY_ENTRANCE          = 9000410,
    GO_BELFRY_EXIT              = 9000411,
    GO_BELFRY_LANTERN           = 9000412,
    GO_BELFRY_BRAZIER           = 9000413,
    GO_BELFRY_CANDLE            = 9000414,
    GO_BELFRY_CANDLE_RED        = 9000415,
    GO_BELFRY_CANDLE_TALL       = 9000416,
    GO_BELFRY_ALTAR             = 9000417,
    GO_BELFRY_CRATE             = 9000418,
    GO_CRACKED_BELL             = 9000419,
    GO_BELFRY_NOTICE            = 9000420,
    GO_BELFRY_CANDELABRA        = 9000421,
    GO_BELFRY_GREAT_BRAZIER     = 9000422,
    GO_BELFRY_ARCH              = 9000423,
    GO_BELFRY_BARREL            = 9000424
};

enum DrownedBelfryItems
{
    ITEM_EPIC_WARRIOR_CLAYMORE  = 9000450,
    ITEM_EPIC_PALADIN_MACE      = 9000451,
    ITEM_EPIC_HUNTER_AXE        = 9000452,
    ITEM_EPIC_ROGUE_DAGGER      = 9000453,
    ITEM_EPIC_PRIEST_STAFF      = 9000454,
    ITEM_EPIC_DK_GREATSWORD     = 9000455,
    ITEM_EPIC_SHAMAN_MAUL       = 9000456,
    ITEM_EPIC_MAGE_STAFF        = 9000457,
    ITEM_EPIC_WARLOCK_STAFF     = 9000458,
    ITEM_EPIC_DRUID_STAFF       = 9000459
};

enum DrownedBelfryQuests
{
    QUEST_CRACKED_BELL          = 9000460
};

enum DrownedBelfrySpells
{
    SPELL_GOUGE                 = 1776,
    SPELL_FROST_NOVA            = 122,
    SPELL_FROSTBOLT             = 13322,
    SPELL_HEAD_BUTT             = 6730,
    SPELL_RUSHING_CHARGE        = 6268,
    SPELL_ENRAGE                = 8599,
    SPELL_PIERCE_ARMOR          = 6016,
    SPELL_SNAP_KICK             = 8646,
    SPELL_BATTLE_SHOUT          = 9128,
    SPELL_SHADOW_BOLT           = 7641,
    SPELL_PSYCHIC_SCREAM        = 8122,
    SPELL_FROST_ARMOR           = 12544,
    SPELL_KNOCKDOWN             = 11428,
    SPELL_SHADOW_WORD_PAIN      = 14032,
    SPELL_THUNDER_CLAP          = 15548,
    SPELL_FIRE_NOVA_SMALL       = 11969,
    SPELL_CLEAVE                = 15496
};

enum DrownedBelfryGossipMenus
{
    GOSSIP_MENU_MARROW          = 9000400
};

enum DrownedBelfryNpcText
{
    NPC_TEXT_MARROW             = 9000400
};

enum DrownedBelfryWhelmEvents
{
    EVENT_WHELM_CHARGE          = 1,
    EVENT_WHELM_KNOCKDOWN,
    EVENT_WHELM_CLEAVE,
    EVENT_WHELM_ADDS
};

enum DrownedBelfryWhelmText
{
    SAY_WHELM_AGGRO             = 0,
    SAY_WHELM_ADDS,
    SAY_WHELM_DEATH
};

enum DrownedBelfryBrineEvents
{
    EVENT_BRINE_BOLT            = 1,
    EVENT_BRINE_PAIN,
    EVENT_BRINE_NOVA,
    EVENT_BRINE_SCREAM,
    EVENT_BRINE_ADDS
};

enum DrownedBelfryBrineText
{
    SAY_BRINE_AGGRO             = 0,
    SAY_BRINE_NOVA,
    SAY_BRINE_SCREAM,
    SAY_BRINE_DEATH
};

enum DrownedBelfryTollEvents
{
    EVENT_TOLL_CLAP             = 1,
    EVENT_TOLL_KNOCKDOWN,
    EVENT_TOLL_BELL,
    EVENT_TOLL_SHOUT
};

enum DrownedBelfryTollText
{
    SAY_TOLL_AGGRO              = 0,
    SAY_TOLL_BELL,
    SAY_TOLL_ENRAGE,
    SAY_TOLL_DEATH
};

enum DrownedBelfryMisc
{
    BELFRY_PORTAL_CHECK_MS      = 800,
    BELFRY_ENTER_GRACE_MS       = 4000,
    BELFRY_GATE_HALF_DEPTH      = 5,
    BELFRY_GATE_HALF_WIDTH      = 8,
    BELFRY_GATE_HALF_HEIGHT     = 8,
    BELFRY_EXIT_HALF_DEPTH      = 3,
    BELFRY_EXIT_HALF_WIDTH      = 4,
    BELFRY_EXIT_HALF_HEIGHT     = 6
};

// Tide Porch — world xyz (=-Blender XY). Facing into the nave (-X).
inline Position const DrownedBelfryMouthDestPos = { -16.0f, 0.0f, 0.2f, 3.1416f };
// Darkshire GY road, east of graveyard id 3. Z from that GY (33.15) interpolated toward town.
inline Position const DrownedBelfryGatePos      = { -10740.0f, -1189.67f, 32.8f, 0.0f };
// Darkshire inn plaza (game_tele Darkshire). Outside the gate box.
inline Position const DrownedBelfryPlazaPos     = { -10573.0f, -1182.51f, 28.0148f, 0.309f };

void DrownedBelfrySendIntoDungeon(Player* player);
void DrownedBelfrySendIntoDungeonForGroup(Player* player);
void DrownedBelfrySendToPlaza(Player* player);
void DrownedBelfryHandleLoadingMapChanged(Player* player);
void DrownedBelfryHandleLoadingLogin(Player* player);
bool DrownedBelfryJustEntered(Player const* player);
uint32 DrownedBelfryEpicWeaponForClass(uint8 playerClass);
void DrownedBelfryGrantEndBossWeapons(Creature* boss);

inline bool DrownedBelfryIsPathingCombatNpc(uint32 entry)
{
    switch (entry)
    {
        case NPC_KEEPER_MARROW:
        case NPC_BRINE_DUMMY:
            return false;
        default:
            return entry >= NPC_DROWNED_PARISHIONER && entry <= NPC_TOLL_BELLKEEPER;
    }
}

#endif
