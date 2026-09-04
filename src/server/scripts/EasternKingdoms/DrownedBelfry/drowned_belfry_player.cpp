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
#include "AreaDefines.h"
#include "GameTime.h"
#include "Group.h"
#include "Player.h"
#include "PlayerScript.h"
#include <unordered_map>
#include <unordered_set>

namespace
{
    std::unordered_set<ObjectGuid> sBelfryPendingLand;
    std::unordered_map<ObjectGuid, uint32> sBelfryEnteredMs;
}

bool DrownedBelfryJustEntered(Player const* player)
{
    if (!player)
        return false;

    auto const it = sBelfryEnteredMs.find(player->GetGUID());
    if (it == sBelfryEnteredMs.end())
        return false;

    return GameTime::GetGameTimeMS().count() - it->second < uint32(BELFRY_ENTER_GRACE_MS);
}

static void DrownedBelfryMarkEntered(Player* player)
{
    if (!player)
        return;

    sBelfryEnteredMs[player->GetGUID()] = uint32(GameTime::GetGameTimeMS().count());
}

static void DrownedBelfryQueueMember(Player* player)
{
    if (!player || !player->IsAlive() || player->IsInCombat())
        return;

    sBelfryPendingLand.insert(player->GetGUID());
    if (player->TeleportTo(MAP_DROWNED_BELFRY, DrownedBelfryMouthDestPos.GetPositionX(),
        DrownedBelfryMouthDestPos.GetPositionY(), DrownedBelfryMouthDestPos.GetPositionZ(),
        DrownedBelfryMouthDestPos.GetOrientation()))
        return;

    sBelfryPendingLand.erase(player->GetGUID());
}

void DrownedBelfrySendIntoDungeon(Player* player)
{
    DrownedBelfryQueueMember(player);
}

void DrownedBelfrySendIntoDungeonForGroup(Player* player)
{
    if (!player)
        return;

    DrownedBelfryQueueMember(player);

    Group* group = player->GetGroup();
    if (!group)
        return;

    for (GroupReference* ref = group->GetFirstMember(); ref; ref = ref->next())
    {
        Player* member = ref->GetSource();
        if (!member || member == player || !member->IsInWorld())
            continue;

        if (member->GetMap() != player->GetMap())
            continue;

        if (member->GetDistance(player) > 80.f)
            continue;

        DrownedBelfryQueueMember(member);
    }
}

void DrownedBelfrySendToPlaza(Player* player)
{
    if (!player)
        return;

    sBelfryPendingLand.erase(player->GetGUID());
    sBelfryEnteredMs.erase(player->GetGUID());
    player->TeleportTo(MAP_EASTERN_KINGDOMS, DrownedBelfryPlazaPos.GetPositionX(),
        DrownedBelfryPlazaPos.GetPositionY(), DrownedBelfryPlazaPos.GetPositionZ(),
        DrownedBelfryPlazaPos.GetOrientation());
}

void DrownedBelfryHandleLoadingMapChanged(Player* player)
{
    if (!player)
        return;

    if (!sBelfryPendingLand.count(player->GetGUID()))
        return;

    if (player->GetMapId() != MAP_DROWNED_BELFRY)
        return;

    sBelfryPendingLand.erase(player->GetGUID());
    DrownedBelfryMarkEntered(player);
}

void DrownedBelfryHandleLoadingLogin(Player* player)
{
    if (!player)
        return;

    sBelfryPendingLand.erase(player->GetGUID());

    if (player->GetMapId() == MAP_DROWNED_BELFRY)
        DrownedBelfryMarkEntered(player);
}

class drowned_belfry_player : public PlayerScript
{
public:
    drowned_belfry_player() : PlayerScript("drowned_belfry_player", {
        PLAYERHOOK_ON_BEFORE_TELEPORT,
        PLAYERHOOK_ON_LOGIN,
        PLAYERHOOK_ON_MAP_CHANGED
    })
    {
    }

    void OnPlayerLogin(Player* player) override
    {
        DrownedBelfryHandleLoadingLogin(player);
    }

    void OnPlayerMapChanged(Player* player) override
    {
        DrownedBelfryHandleLoadingMapChanged(player);
    }

    bool OnPlayerBeforeTeleport(Player* player, uint32 mapid, float /*x*/, float /*y*/, float /*z*/, float /*orientation*/,
        uint32 /*options*/, Unit* /*target*/) override
    {
        if (!player)
            return true;

        if (sBelfryPendingLand.count(player->GetGUID()) && mapid == MAP_DROWNED_BELFRY)
        {
            sBelfryPendingLand.erase(player->GetGUID());
            DrownedBelfryMarkEntered(player);
        }

        return true;
    }
};

void AddSC_drowned_belfry_player()
{
    new drowned_belfry_player();
}
