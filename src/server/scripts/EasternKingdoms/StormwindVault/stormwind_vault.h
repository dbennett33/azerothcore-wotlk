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

class Player;

// Unused vanilla 5-man (Map.dbc Directory StormwindPrison / "Stormwind Vault").
// Entrance is the unused canal swirl between Trade District and Old Town (no AreaTrigger.dbc
// volume — walk-through GameObjectAI). Exit is vanilla areatrigger 109.
static_assert(MAP_STORMWIND_VAULT == 35, "MAP_STORMWIND_VAULT must stay map 35");

enum StormwindVaultCreatures
{
    NPC_VAULT_WARDEN            = 9000200
};

enum StormwindVaultGameObjects
{
    GO_CANAL_ENTRANCE           = 9000201
};

enum StormwindVaultGossipMenus
{
    GOSSIP_MENU_VAULT_WARDEN    = 9000200
};

enum StormwindVaultNpcText
{
    NPC_TEXT_VAULT_WARDEN       = 9000200
};

enum StormwindVaultMisc
{
    VAULT_PORTAL_CHECK_MS       = 800,
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

#endif
