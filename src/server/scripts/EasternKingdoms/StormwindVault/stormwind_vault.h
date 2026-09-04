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

#ifndef STORMWIND_VAULT_H
#define STORMWIND_VAULT_H

#include "AreaDefines.h"
#include "Position.h"

class Creature;
class Player;

// Unused vanilla 5-man (Map.dbc Directory StormwindPrison / "Stormwind Vault").
// Entrance is the unused canal swirl between Trade District and Old Town (no AreaTrigger.dbc
// volume — walk-through GameObjectAI). Exit is vanilla areatrigger 109.
static_assert(MAP_STORMWIND_VAULT == 35, "MAP_STORMWIND_VAULT must stay map 35");

enum StormwindVaultCreatures
{
    NPC_VAULT_WARDEN            = 9000200,
    NPC_VAULT_INMATE            = 9000202,
    NPC_VAULT_TURNKEY           = 9000203,
    NPC_VAULT_SHADOWMAGE        = 9000204,
    NPC_VAULT_RIOTER            = 9000205,
    NPC_CELL_RAT                = 9000206,
    NPC_VAULT_ACOLYTE           = 9000207,
    NPC_SHACKLED_HORROR         = 9000208,
    NPC_VAULT_ENFORCER          = 9000209,
    NPC_TURNKEY_GARROW          = 9000210,
    NPC_SISTER_CINDER           = 9000211,
    NPC_WARDEN_BLACKIRON        = 9000212,
    NPC_CONFESSION_DUMMY        = 9000213
};

enum StormwindVaultGameObjects
{
    GO_CANAL_ENTRANCE           = 9000201,
    GO_VAULT_BRAZIER            = 9000215,
    GO_VAULT_LANTERN            = 9000216,
    GO_VAULT_CAGE               = 9000217,
    GO_VAULT_CRATE              = 9000218,
    GO_VAULT_CANDLE             = 9000219,
    GO_VAULT_CANDLE_RED         = 9000220,
    GO_VAULT_SHRINE             = 9000221,
    GO_CELL_LEVER               = 9000222,
    GO_INTERROGATION_RACK       = 9000223,
    GO_GREAT_BRAZIER            = 9000224,
    GO_VAULT_WHEEL              = 9000225,
    GO_VAULT_NOTICE             = 9000226,
    GO_WEAPON_RACK              = 9000227,
    GO_VAULT_CANDLE_TALL        = 9000228
};

enum StormwindVaultItems
{
    ITEM_EPIC_WARRIOR_CLAYMORE  = 9000250,
    ITEM_EPIC_PALADIN_MACE      = 9000251,
    ITEM_EPIC_HUNTER_AXE        = 9000252,
    ITEM_EPIC_ROGUE_DAGGER      = 9000253,
    ITEM_EPIC_PRIEST_STAFF      = 9000254,
    ITEM_EPIC_DK_GREATSWORD     = 9000255,
    ITEM_EPIC_SHAMAN_MAUL       = 9000256,
    ITEM_EPIC_MAGE_STAFF        = 9000257,
    ITEM_EPIC_WARLOCK_STAFF     = 9000258,
    ITEM_EPIC_DRUID_STAFF       = 9000259
};

enum StormwindVaultQuests
{
    QUEST_LAST_CELL             = 9000260
};

enum StormwindVaultSpells
{
    SPELL_NET                   = 6533,
    SPELL_SHADOW_BOLT           = 7641,
    SPELL_PSYCHIC_SCREAM        = 8122,
    SPELL_ENRAGE                = 8599,
    SPELL_SNAP_KICK             = 8646,
    SPELL_BATTLE_SHOUT          = 9128,
    SPELL_FIRE_NOVA_SMALL       = 11969,
    SPELL_FROST_ARMOR           = 12544,
    SPELL_KNOCKDOWN             = 11428,
    SPELL_DEMORALIZING_SHOUT    = 13730,
    SPELL_MORTAL_STRIKE         = 13737,
    SPELL_SHADOW_WORD_PAIN      = 14032,
    SPELL_THUNDER_CLAP          = 15548,
    SPELL_PIERCE_ARMOR          = 6016,
    SPELL_RUSHING_CHARGE        = 6268,
    SPELL_HEAD_BUTT             = 6730,
    SPELL_GOUGE                 = 1776
};

enum StormwindVaultGossipMenus
{
    GOSSIP_MENU_VAULT_WARDEN    = 9000200
};

enum StormwindVaultNpcText
{
    NPC_TEXT_VAULT_WARDEN       = 9000200
};

enum StormwindVaultGarrowEvents
{
    EVENT_GARROW_NET            = 1,
    EVENT_GARROW_PIERCE,
    EVENT_GARROW_KICK,
    EVENT_GARROW_SHOUT
};

enum StormwindVaultGarrowText
{
    SAY_GARROW_AGGRO            = 0,
    SAY_GARROW_CELLS,
    SAY_GARROW_LEVER,
    SAY_GARROW_DEATH
};

enum StormwindVaultGarrowActions
{
    ACTION_GARROW_LEVER         = 1
};

enum StormwindVaultCinderEvents
{
    EVENT_CINDER_BOLT           = 1,
    EVENT_CINDER_PAIN,
    EVENT_CINDER_CONFESSION,
    EVENT_CINDER_CONFESSION_NOVA,
    EVENT_CINDER_SCREAM
};

enum StormwindVaultCinderText
{
    SAY_CINDER_AGGRO            = 0,
    SAY_CINDER_CONFESS,
    SAY_CINDER_SCREAM,
    SAY_CINDER_DEATH
};

enum StormwindVaultBlackironEvents
{
    EVENT_BLACKIRON_CLEAVE      = 1,
    EVENT_BLACKIRON_STRIKE,
    EVENT_BLACKIRON_KNOCKDOWN,
    EVENT_BLACKIRON_SHOUT,
    EVENT_BLACKIRON_WHEEL_END
};

enum StormwindVaultBlackironText
{
    SAY_BLACKIRON_AGGRO         = 0,
    SAY_BLACKIRON_LOCKDOWN,
    SAY_BLACKIRON_ENRAGE,
    SAY_BLACKIRON_WHEEL,
    SAY_BLACKIRON_DEATH
};

enum StormwindVaultBlackironActions
{
    ACTION_BLACKIRON_WHEEL      = 1
};

enum StormwindVaultMisc
{
    VAULT_PORTAL_CHECK_MS       = 800,
    VAULT_WHEEL_STUN_MS         = 4000,
    // Oriented box on the unused canal swirl. Local X = through the bars into the alcove.
    VAULT_GATE_HALF_DEPTH       = 8,
    VAULT_GATE_HALF_WIDTH       = 10,
    VAULT_GATE_HALF_HEIGHT      = 10
};

// areatrigger_teleport 107 dest (inside the vault). AT 109 is at y=16; this landing does not yo-yo.
inline Position const StormwindVaultMouthDestPos = { -0.91f, 40.57f, -24.23f, 0.0f };
// Unused canal swirl between Trade District and Old Town. Z spans the barred opening (canal
// water ~86) and the west walkway (~97). Nearby vanilla ground: rat guid 120812 at
// -8803.54, 491.175, 97.0508 and Sewer Beast guid 86301 at -8783.6, 487.416, 85.9915.
inline Position const StormwindVaultCanalGatePos = { -8792.0f, 495.0f, 90.0f, 0.0f };
// Exit plaza on the Trade-side canal walkway (vanilla NPC 1303 guid 79659). Outside the gate box.
inline Position const StormwindVaultCanalPlazaPos = { -8822.07f, 518.022f, 98.7826f, 5.5f };

void StormwindVaultSendIntoDungeon(Player* player);
uint32 StormwindVaultEpicWeaponForClass(uint8 playerClass);
void StormwindVaultGrantEndBossWeapons(Creature* boss);

inline bool StormwindVaultIsPathingCombatNpc(uint32 entry)
{
    switch (entry)
    {
        case NPC_VAULT_WARDEN:
        case NPC_CONFESSION_DUMMY:
            return false;
        default:
            return entry >= NPC_VAULT_INMATE && entry <= NPC_WARDEN_BLACKIRON;
    }
}

#endif
