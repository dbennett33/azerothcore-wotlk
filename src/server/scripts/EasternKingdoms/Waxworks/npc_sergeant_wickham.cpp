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
#include "CreatureScript.h"
#include "Player.h"
#include "ScriptedGossip.h"

class npc_sergeant_wickham : public CreatureScript
{
public:
    npc_sergeant_wickham() : CreatureScript("npc_sergeant_wickham") { }

    bool OnGossipHello(Player* player, Creature* creature) override
    {
        if (!player || !creature)
            return true;

        if (creature->IsQuestGiver())
            player->PrepareQuestMenu(creature->GetGUID());

        if (player->GetMapId() == MAP_WAXWORKS)
            AddGossipItemFor(player, GOSSIP_ICON_CHAT, "Return to the surface.",
                GOSSIP_SENDER_MAIN, GOSSIP_ACTION_WICKHAM_LEAVE);
        else
            AddGossipItemFor(player, GOSSIP_ICON_CHAT, "We will enter the Waxworks.",
                GOSSIP_SENDER_MAIN, GOSSIP_ACTION_WICKHAM_ENTER);

        SendGossipMenuFor(player, NPC_TEXT_WICKHAM, creature->GetGUID());
        return true;
    }

    bool OnGossipSelect(Player* player, Creature* creature, uint32 /*sender*/, uint32 action) override
    {
        if (!player || !creature)
            return true;

        ClearGossipMenuFor(player);

        switch (action)
        {
            case GOSSIP_ACTION_WICKHAM_ENTER:
                WaxworksSendIntoDungeonForGroup(player);
                player->TalkedToCreature(NPC_SERGEANT_WICKHAM, creature->GetGUID());
                CloseGossipMenuFor(player);
                break;
            case GOSSIP_ACTION_WICKHAM_LEAVE:
                WaxworksSendToPlaza(player);
                CloseGossipMenuFor(player);
                break;
            default:
                break;
        }

        return true;
    }
};

void AddSC_npc_sergeant_wickham()
{
    new npc_sergeant_wickham();
}
