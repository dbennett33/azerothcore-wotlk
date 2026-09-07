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

#include "waxworks.h"
#include "AreaDefines.h"
#include "GameTime.h"
#include "Group.h"
#include "Player.h"
#include "PlayerScript.h"
#include <unordered_map>
#include <unordered_set>

namespace
{
    std::unordered_set<ObjectGuid> sWaxworksPendingLand;
    std::unordered_map<ObjectGuid, uint32> sWaxworksEnteredMs;
}

bool WaxworksJustEntered(Player const* player)
{
    if (!player)
        return false;

    auto const it = sWaxworksEnteredMs.find(player->GetGUID());
    if (it == sWaxworksEnteredMs.end())
        return false;

    return GameTime::GetGameTimeMS().count() - it->second < uint32(WAXWORKS_ENTER_GRACE_MS);
}

static void WaxworksMarkEntered(Player* player)
{
    if (!player)
        return;

    sWaxworksEnteredMs[player->GetGUID()] = uint32(GameTime::GetGameTimeMS().count());
}

static void WaxworksQueueMember(Player* player)
{
    if (!player || !player->IsAlive() || player->IsInCombat())
        return;

    sWaxworksPendingLand.insert(player->GetGUID());
    if (player->TeleportTo(MAP_WAXWORKS, WaxworksMouthDestPos.GetPositionX(),
        WaxworksMouthDestPos.GetPositionY(), WaxworksMouthDestPos.GetPositionZ(),
        WaxworksMouthDestPos.GetOrientation()))
        return;

    sWaxworksPendingLand.erase(player->GetGUID());
}

void WaxworksSendIntoDungeon(Player* player)
{
    WaxworksQueueMember(player);
}

void WaxworksSendIntoDungeonForGroup(Player* player)
{
    if (!player)
        return;

    WaxworksQueueMember(player);

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

        WaxworksQueueMember(member);
    }
}

void WaxworksSendToPlaza(Player* player)
{
    if (!player)
        return;

    sWaxworksPendingLand.erase(player->GetGUID());
    sWaxworksEnteredMs.erase(player->GetGUID());
    player->TeleportTo(MAP_EASTERN_KINGDOMS, WaxworksPortalPlazaPos.GetPositionX(),
        WaxworksPortalPlazaPos.GetPositionY(), WaxworksPortalPlazaPos.GetPositionZ(),
        WaxworksPortalPlazaPos.GetOrientation());
}

void WaxworksHandleLoadingMapChanged(Player* player)
{
    if (!player)
        return;

    if (!sWaxworksPendingLand.count(player->GetGUID()))
        return;

    if (player->GetMapId() != MAP_WAXWORKS)
        return;

    sWaxworksPendingLand.erase(player->GetGUID());
    WaxworksMarkEntered(player);
}

void WaxworksHandleLoadingLogin(Player* player)
{
    if (!player)
        return;

    sWaxworksPendingLand.erase(player->GetGUID());

    if (player->GetMapId() == MAP_WAXWORKS)
        WaxworksMarkEntered(player);
}

class waxworks_player : public PlayerScript
{
public:
    waxworks_player() : PlayerScript("waxworks_player", {
        PLAYERHOOK_ON_BEFORE_TELEPORT,
        PLAYERHOOK_ON_LOGIN,
        PLAYERHOOK_ON_MAP_CHANGED
    })
    {
    }

    void OnPlayerLogin(Player* player) override
    {
        WaxworksHandleLoadingLogin(player);
    }

    void OnPlayerMapChanged(Player* player) override
    {
        WaxworksHandleLoadingMapChanged(player);
    }

    bool OnPlayerBeforeTeleport(Player* player, uint32 mapid, float /*x*/, float /*y*/, float /*z*/, float /*orientation*/,
        uint32 /*options*/, Unit* /*target*/) override
    {
        if (!player)
            return true;

        if (sWaxworksPendingLand.count(player->GetGUID()) && mapid == MAP_WAXWORKS)
        {
            sWaxworksPendingLand.erase(player->GetGUID());
            WaxworksMarkEntered(player);
        }

        return true;
    }
};

void AddSC_waxworks_player()
{
    new waxworks_player();
}
