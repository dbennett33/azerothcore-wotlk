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

#ifndef MODULE_WAXWORKS_H
#define MODULE_WAXWORKS_H

#include "Position.h"

class Creature;
class Player;

enum WaxworksCreatures
{
    NPC_WICKWORKS_SCAMP         = 9000001,
    NPC_WICKWORKS_TUNNELER      = 9000002,
    NPC_WICKWORKS_WICKMAGE      = 9000003,
    NPC_WICKWORKS_HAULER        = 9000004,
    NPC_CANDLE_CART             = 9000005,
    NPC_GUG_NIGHT_SHIFT         = 9000006,
    NPC_LINE_COOK               = 9000007,
    NPC_DISHWASHER              = 9000008,
    NPC_FRY_ORACLE              = 9000009,
    NPC_GREASE_PATROL           = 9000010,
    NPC_MURLOC_CONSULTANT       = 9000011,
    NPC_SHOP_STEWARD            = 9000012,
    NPC_CONTRACT_MAGE           = 9000013,
    NPC_CLERK_OF_GRIEVANCES     = 9000014,
    NPC_VOSS_BODYGUARD          = 9000015,
    NPC_GREASE_BOAR             = 9000016,
    NPC_DRIPPING_WAX            = 9000017,
    NPC_VAT_TENDER              = 9000018,
    NPC_WICKWORKS_ACOLYTE       = 9000019,
    NPC_KING_WICK               = 9000020,
    NPC_WAX_DUMMY               = 9000021,
    NPC_CHEF_SNARLROAST         = 9000030,
    NPC_FIRE_TRAIL              = 9000031,
    NPC_FOREMAN_VOSS            = 9000040,
    NPC_PRINCESS                = 9000045,
    NPC_SIR_OINKSWORTH          = 9000046,
    NPC_UNIT_07                 = 9000047,
    NPC_LADY_CRACKLING          = 9000048,
    NPC_HONOURABLE_HAM           = 9000049,
    NPC_SERGEANT_WICKHAM        = 9000050
};

enum WaxworksGameObjects
{
    GO_WAX_CANDLE               = 9000001,
    GO_COMMISSARY_CHEESE        = 9000002,
    GO_PUMPKIN_STY              = 9000003,
    GO_VOSS_CHALKBOARD          = 9000004,
    GO_WICK_BARRICADE           = 9000005,
    GO_DECOR_CANDLE             = 9000006,
    GO_DECOR_CASK               = 9000007,
    GO_DECOR_CART               = 9000008,
    GO_DECOR_LANTERN            = 9000009,
    GO_DECOR_CANDLE_TALL        = 9000010,
    GO_DECOR_CANDLE_PILLAR      = 9000011,
    GO_VOSS_CRATE               = 9000012,
    GO_PORTAL_DARK              = 9000013,
    GO_PORTAL_PARTICLES         = 9000014,
    GO_PORTAL_SWIRL             = 9000015,
    GO_PORTAL_ENTRANCE          = 9000016,
    GO_PORTAL_EXIT              = 9000017,
    GO_TALLOW_VAT               = 9000018,
    GO_COOKPOT                  = 9000019,
    GO_MEAT_RACK                = 9000020,
    GO_FOOD_CRATE               = 9000021,
    GO_UNION_NOTICE             = 9000022,
    GO_BRAZIER                  = 9000023,
    GO_CANDLE_STUB              = 9000024,
    GO_CANDLE_MED               = 9000025,
    GO_CANDLE_TALL              = 9000026,
    GO_CANDLE_RED               = 9000027,
    GO_CANDLE_RED_HUGE          = 9000028,
    GO_SHRINE_ALTAR             = 9000029,
    GO_WAX_EFFIGY               = 9000030,
    GO_CHAPEL_ALTAR             = 9000031,
    GO_CHAPEL_CANDELABRA        = 9000032
};

enum WaxworksMaps
{
    // Unused client dungeon (Map.dbc Directory "Monastery"). Hosts Waxworks.wmo
    // after patch-4.MPQ replaces leftover Scarlet Monastery.wdt.
    MAP_WAXWORKS                = 44
};

enum WaxworksQuests
{
    QUEST_WAX_EMERGENCY         = 9000000,
    QUEST_BREAK_COOPERATIVE     = 9000001,
    QUEST_FIRST_PRIZE           = 9000003
};

enum WaxworksItems
{
    ITEM_UNDER_CROFT_LEGGINGS   = 9000050,
    ITEM_UNDER_CROFT_TUNIC      = 9000051,
    ITEM_UNDER_CROFT_STICK      = 9000052,
    ITEM_OVERTIME_VEST          = 9000053,
    ITEM_CANDLE_OF_ELUNE        = 772,
    // Foreman Voss personal loot: one BoP epic per living party member, by class.
    // Duplicates are intentional (four warriors → four claymores).
    ITEM_EPIC_WARRIOR_CLAYMORE  = 9000070,
    ITEM_EPIC_PALADIN_MACE      = 9000071,
    ITEM_EPIC_HUNTER_AXE        = 9000072,
    ITEM_EPIC_ROGUE_DAGGER      = 9000073,
    ITEM_EPIC_PRIEST_STAFF      = 9000074,
    ITEM_EPIC_DK_GREATSWORD     = 9000075,
    ITEM_EPIC_SHAMAN_MAUL       = 9000076,
    ITEM_EPIC_MAGE_STAFF        = 9000077,
    ITEM_EPIC_WARLOCK_STAFF     = 9000078,
    ITEM_EPIC_DRUID_STAFF       = 9000079
};

enum WaxworksSpells
{
    SPELL_FIREBALL              = 20793,
    SPELL_FROSTBOLT             = 13322,
    SPELL_FROST_ARMOR           = 12544,
    SPELL_LIGHTNING_BOLT        = 9532,
    SPELL_HEALING_WAVE          = 913,
    SPELL_PIERCE_ARMOR          = 6016,
    SPELL_RUSHING_CHARGE        = 6268,
    SPELL_HEAD_BUTT             = 6730,
    SPELL_ENRAGE                = 8599,
    SPELL_SMOKE_BOMB            = 7964,
    SPELL_THROW_DYNAMITE        = 7978,
    SPELL_BATTLE_SHOUT          = 9128,
    SPELL_SNAP_KICK             = 8646,
    SPELL_DEMORALIZING_SHOUT    = 13730,
    SPELL_SPIRIT_DECAY          = 8016,
    SPELL_TETANUS               = 8014,
    SPELL_WIDE_SLASH            = 7342,
    SPELL_FIXATE                = 12021,
    SPELL_FIRE_NOVA_SMALL       = 11969,
    SPELL_UPPERCUT              = 18072,
    SPELL_COOKIES_COOKING       = 5174,
    SPELL_ACID_SPLASH           = 6306,
    SPELL_SMITE_STOMP           = 6432,
    SPELL_SMITE_SLAM            = 6435,
    SPELL_WELL_DONE             = 20800,
    SPELL_GOUGE                 = 1776,
    SPELL_DRINK_MINOR_POTION    = 3368
};

enum WaxworksGossipMenus
{
    GOSSIP_MENU_WICKHAM         = 9000000,
    GOSSIP_MENU_VOSS            = 9000010,
    GOSSIP_MENU_VOSS_DEMANDS    = 9000011
};

enum WaxworksNpcText
{
    NPC_TEXT_WICKHAM            = 9000000,
    NPC_TEXT_VOSS               = 9000010,
    NPC_TEXT_VOSS_DEMANDS       = 9000011
};

enum WaxworksGossipActions
{
    GOSSIP_ACTION_WICKHAM_ENTER = 1001,
    GOSSIP_ACTION_WICKHAM_LEAVE = 1002,
    GOSSIP_ACTION_VOSS_NO       = 1003,
    GOSSIP_ACTION_VOSS_DEMANDS  = 1004,
    GOSSIP_ACTION_VOSS_YES      = 1005
};

enum WaxworksEquipment
{
    EQUIP_VOSS_CLIPBOARD        = 1,
    EQUIP_VOSS_KNUCKLES         = 2
};

enum WaxworksKingWickEvents
{
    EVENT_WICK_FIREBALL         = 1,
    EVENT_WICK_FIREBALL_RANDOM,
    EVENT_WICK_HOT_WAX,
    EVENT_WICK_WAX_NOVA,
    EVENT_WICK_HEAD_BUTT,
    EVENT_WICK_PIERCE
};

enum WaxworksKingWickText
{
    SAY_WICK_AGGRO              = 0,
    SAY_WICK_STEAL,
    SAY_WICK_CART,
    SAY_WICK_DEATH
};

enum WaxworksSnarlEvents
{
    EVENT_SNARL_WELL_DONE       = 1,
    EVENT_SNARL_UPPERCUT,
    EVENT_SNARL_HOT_SAUCE,
    EVENT_SNARL_FIRE_TRAIL,
    EVENT_SNARL_COOK,
    EVENT_SNARL_STOVE_TIMEOUT
};

enum WaxworksSnarlText
{
    SAY_SNARL_AGGRO             = 0,
    SAY_SNARL_RARE,
    SAY_SNARL_MEDIUM,
    SAY_SNARL_WELL_DONE,
    SAY_SNARL_REDUCTION,
    SAY_SNARL_DEATH
};

enum WaxworksSnarlPoints
{
    POINT_SNARL_STOVE           = 1
};

enum WaxworksVossEvents
{
    EVENT_VOSS_NEGOTIATE        = 1,
    EVENT_VOSS_NEGOTIATE_TIMEOUT,
    EVENT_VOSS_SMOKE,
    EVENT_VOSS_SNAP_KICK,
    EVENT_VOSS_SLAM
};

enum WaxworksVossText
{
    SAY_VOSS_AGGRO              = 0,
    SAY_VOSS_YES,
    SAY_VOSS_NO,
    SAY_VOSS_DEATH
};

enum WaxworksVossData
{
    DATA_VOSS_NEGOTIATION       = 1,
    DATA_VOSS_IS_NEGOTIATING
};

enum WaxworksVossChoice
{
    VOSS_CHOICE_NONE            = 0,
    VOSS_CHOICE_HARD,
    VOSS_CHOICE_SOFT
};

enum WaxworksVossPoints
{
    POINT_VOSS_BOARD            = 1
};

enum WaxworksPrincessEvents
{
    EVENT_PRINCESS_CHARGE       = 1,
    EVENT_PRINCESS_HEAD_BUTT,
    EVENT_PRINCESS_PIERCE
};

enum WaxworksPrincessText
{
    SAY_PRINCESS_DEATH          = 0
};

enum WaxworksUnit07Events
{
    EVENT_UNIT07_TETANUS        = 1,
    EVENT_UNIT07_WIDE_SLASH,
    EVENT_UNIT07_FIXATE_END
};

enum WaxworksActions
{
    ACTION_UNIT07_FIXATE        = 1
};

enum WaxworksMisc
{
    WAXWORKS_FIXATE_MS          = 8000,
    WAXWORKS_VOSS_TIMEOUT_MS    = 12000,
    WAXWORKS_ENRAGE_MS          = 10000,
    WAXWORKS_SNARL_STOVE_MS     = 4000,
    WAXWORKS_PORTAL_CHECK_MS    = 800,
    WAXWORKS_ENTER_GRACE_MS     = 4000,
    // Oriented box on the Goldshire pink veil (local X = through the arch).
    WAXWORKS_GATE_HALF_DEPTH    = 5,
    WAXWORKS_GATE_HALF_WIDTH    = 8,
    WAXWORKS_GATE_HALF_HEIGHT   = 8,
    WAXWORKS_EXIT_HALF_DEPTH    = 3,
    WAXWORKS_EXIT_HALF_WIDTH    = 4,
    WAXWORKS_EXIT_HALF_HEIGHT   = 6
};

// Commissary stove — world xyz (=-Blender XY). Stand wax44_commissary (-88, 32, -7).
inline Position const SnarlroastStovePos = { -84.0f, 34.0f, -6.85f, 3.1416f };
// Chalkboard in front of Voss (toward the incoming trash pack from King Wick).
inline Position const VossBoardPos       = { -136.0f, 5.0f, 0.65f, 4.7124f };
// East of the Goldshire green, behind the gate so the walk-through volume does not retrigger.
inline Position const WaxworksPortalPlazaPos = { -9432.0f, 62.0f, 56.8f, 3.1416f };
// World XY = -WMO/Blender XY for a WDT MODF at origin (vmap pModel = -worldXY).
// Scout .gps 2026-08-31: world (-12, 0, 0.15) ori pi, FloorZ 0. Do not Z-nudge.
inline Position const WaxworksMouthDestPos   = { -12.0f, 0.0f, 0.15f, 3.1416f };

void WaxworksSendIntoDungeon(Player* player);
void WaxworksSendIntoDungeonForGroup(Player* player);
void WaxworksSendToPlaza(Player* player);
void WaxworksHandleLoadingMapChanged(Player* player);
void WaxworksHandleLoadingLogin(Player* player);
bool WaxworksJustEntered(Player const* player);
uint32 WaxworksEpicWeaponForClass(uint8 playerClass);
void WaxworksGrantEndBossWeapons(Creature* boss);

inline bool WaxworksIsPathingCombatNpc(uint32 entry)
{
    switch (entry)
    {
        case NPC_WAX_DUMMY:
        case NPC_FIRE_TRAIL:
        case NPC_SERGEANT_WICKHAM:
            return false;
        default:
            return entry >= NPC_WICKWORKS_SCAMP && entry <= NPC_SERGEANT_WICKHAM;
    }
}

#endif
