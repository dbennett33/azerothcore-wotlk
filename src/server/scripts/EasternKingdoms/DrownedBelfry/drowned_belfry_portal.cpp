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
#include "GameObjectAI.h"
#include "GameObjectScript.h"
#include "Map.h"
#include "Player.h"

static bool BelfryPlayerInGate(GameObject const* gate, Player const* player,
    float halfDepth, float halfWidth, float halfHeight)
{
    if (!gate || !player)
        return false;

    return player->IsWithinBox(*gate, halfDepth, halfWidth, halfHeight);
}

struct go_drowned_belfry_entrance_ai : public GameObjectAI
{
    explicit go_drowned_belfry_entrance_ai(GameObject* go) : GameObjectAI(go)
    {
        _checkTimer = 0;
    }

    void UpdateAI(uint32 diff) override
    {
        _checkTimer += diff;
        if (_checkTimer < BELFRY_PORTAL_CHECK_MS)
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

            if (player->GetMapId() == MAP_DROWNED_BELFRY)
                continue;

            if (!player->IsInDist2d(me, 20.f))
                continue;

            if (!BelfryPlayerInGate(me, player, float(BELFRY_GATE_HALF_DEPTH),
                    float(BELFRY_GATE_HALF_WIDTH), float(BELFRY_GATE_HALF_HEIGHT)))
                continue;

            DrownedBelfrySendIntoDungeonForGroup(player);
            return;
        }
    }

private:
    uint32 _checkTimer;
};

struct go_drowned_belfry_exit_ai : public GameObjectAI
{
    explicit go_drowned_belfry_exit_ai(GameObject* go) : GameObjectAI(go)
    {
        _checkTimer = 0;
    }

    void UpdateAI(uint32 diff) override
    {
        _checkTimer += diff;
        if (_checkTimer < BELFRY_PORTAL_CHECK_MS)
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

            if (player->GetMapId() != MAP_DROWNED_BELFRY || DrownedBelfryJustEntered(player))
                continue;

            if (!player->IsInDist2d(me, 20.f))
                continue;

            if (!BelfryPlayerInGate(me, player, float(BELFRY_EXIT_HALF_DEPTH),
                    float(BELFRY_EXIT_HALF_WIDTH), float(BELFRY_EXIT_HALF_HEIGHT)))
                continue;

            DrownedBelfrySendToPlaza(player);
            return;
        }
    }

private:
    uint32 _checkTimer;
};

class go_drowned_belfry_entrance : public GameObjectScript
{
public:
    go_drowned_belfry_entrance() : GameObjectScript("go_drowned_belfry_entrance") { }

    GameObjectAI* GetAI(GameObject* go) const override
    {
        return new go_drowned_belfry_entrance_ai(go);
    }
};

class go_drowned_belfry_exit : public GameObjectScript
{
public:
    go_drowned_belfry_exit() : GameObjectScript("go_drowned_belfry_exit") { }

    GameObjectAI* GetAI(GameObject* go) const override
    {
        return new go_drowned_belfry_exit_ai(go);
    }
};

void AddSC_drowned_belfry_portal()
{
    new go_drowned_belfry_entrance();
    new go_drowned_belfry_exit();
}
