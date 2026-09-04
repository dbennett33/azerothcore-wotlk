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

#include "drowned_belfry.h"
#include "Creature.h"
#include "Log.h"
#include "Map.h"
#include "Player.h"
#include "SharedDefines.h"

uint32 DrownedBelfryEpicWeaponForClass(uint8 playerClass)
{
    switch (playerClass)
    {
        case CLASS_WARRIOR:
            return ITEM_EPIC_WARRIOR_CLAYMORE;
        case CLASS_PALADIN:
            return ITEM_EPIC_PALADIN_MACE;
        case CLASS_HUNTER:
            return ITEM_EPIC_HUNTER_AXE;
        case CLASS_ROGUE:
            return ITEM_EPIC_ROGUE_DAGGER;
        case CLASS_PRIEST:
            return ITEM_EPIC_PRIEST_STAFF;
        case CLASS_DEATH_KNIGHT:
            return ITEM_EPIC_DK_GREATSWORD;
        case CLASS_SHAMAN:
            return ITEM_EPIC_SHAMAN_MAUL;
        case CLASS_MAGE:
            return ITEM_EPIC_MAGE_STAFF;
        case CLASS_WARLOCK:
            return ITEM_EPIC_WARLOCK_STAFF;
        case CLASS_DRUID:
            return ITEM_EPIC_DRUID_STAFF;
        default:
            return 0;
    }
}

void DrownedBelfryGrantEndBossWeapons(Creature* boss)
{
    if (!boss)
        return;

    Map* map = boss->GetMap();
    if (!map)
        return;

    map->DoForAllPlayers([&](Player* player)
    {
        if (!player || !player->IsInWorld() || player->IsGameMaster())
            return;

        uint32 const itemId = DrownedBelfryEpicWeaponForClass(player->getClass());
        if (!itemId)
            return;

        if (player->AddItem(itemId, 1))
        {
            LOG_INFO("scripts.drownedbelfry", "Toll: granted item {} to {}",
                itemId, player->GetName());
            return;
        }

        player->SendItemRetrievalMail(itemId, 1);
        LOG_INFO("scripts.drownedbelfry", "Toll: mailed item {} to {} (bags full)",
            itemId, player->GetName());
    });
}
