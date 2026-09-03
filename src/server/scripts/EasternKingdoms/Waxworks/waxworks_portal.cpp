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
#include "GameObjectAI.h"
#include "GameObjectScript.h"
#include "Map.h"
#include "Player.h"

// Thin tall box through the stone arch — same idea as TBC Dark Portal AT 4352.
static bool WaxworksPlayerInGate(GameObject const* gate, Player const* player, float halfDepth, float halfWidth, float halfHeight)
{
    if (!gate || !player)
        return false;

    return player->IsWithinBox(*gate, halfDepth, halfWidth, halfHeight);
}

struct go_waxworks_entrance_ai : public GameObjectAI
{
    explicit go_waxworks_entrance_ai(GameObject* go) : GameObjectAI(go)
    {
        _checkTimer = 0;
    }

    void UpdateAI(uint32 diff) override
    {
        _checkTimer += diff;
        if (_checkTimer < WAXWORKS_PORTAL_CHECK_MS)
            return;

        _checkTimer = 0;
        Map* map = me->GetMap();
        if (!map)
            return;

        Map::PlayerList const& players = map->GetPlayers();
        for (Map::PlayerList::const_iterator itr = players.begin(); itr != players.end(); ++itr)
        {
            Player* player = itr->GetSource();
            if (!player || !player->IsInWorld() || !player->IsAlive())
                continue;

            if (player->GetMapId() == MAP_WAXWORKS)
                continue;

            if (!player->IsInDist2d(me, 20.f))
                continue;

            if (!WaxworksPlayerInGate(me, player, float(WAXWORKS_GATE_HALF_DEPTH),
                float(WAXWORKS_GATE_HALF_WIDTH), float(WAXWORKS_GATE_HALF_HEIGHT)))
                continue;

            WaxworksSendIntoDungeonForGroup(player);
            return;
        }
    }

private:
    uint32 _checkTimer;
};

struct go_waxworks_exit_ai : public GameObjectAI
{
    explicit go_waxworks_exit_ai(GameObject* go) : GameObjectAI(go)
    {
        _checkTimer = 0;
    }

    void UpdateAI(uint32 diff) override
    {
        _checkTimer += diff;
        if (_checkTimer < WAXWORKS_PORTAL_CHECK_MS)
            return;

        _checkTimer = 0;
        Map* map = me->GetMap();
        if (!map)
            return;

        Map::PlayerList const& players = map->GetPlayers();
        for (Map::PlayerList::const_iterator itr = players.begin(); itr != players.end(); ++itr)
        {
            Player* player = itr->GetSource();
            if (!player || !player->IsInWorld() || !player->IsAlive())
                continue;

            if (player->GetMapId() != MAP_WAXWORKS || WaxworksJustEntered(player))
                continue;

            if (!player->IsInDist2d(me, 20.f))
                continue;

            if (!WaxworksPlayerInGate(me, player, float(WAXWORKS_EXIT_HALF_DEPTH),
                float(WAXWORKS_EXIT_HALF_WIDTH), float(WAXWORKS_EXIT_HALF_HEIGHT)))
                continue;

            WaxworksSendToPlaza(player);
            return;
        }
    }

private:
    uint32 _checkTimer;
};

class go_waxworks_entrance : public GameObjectScript
{
public:
    go_waxworks_entrance() : GameObjectScript("go_waxworks_entrance") { }

    GameObjectAI* GetAI(GameObject* go) const override
    {
        return new go_waxworks_entrance_ai(go);
    }
};

class go_waxworks_exit : public GameObjectScript
{
public:
    go_waxworks_exit() : GameObjectScript("go_waxworks_exit") { }

    GameObjectAI* GetAI(GameObject* go) const override
    {
        return new go_waxworks_exit_ai(go);
    }
};

void AddSC_waxworks_portal()
{
    new go_waxworks_entrance();
    new go_waxworks_exit();
}
