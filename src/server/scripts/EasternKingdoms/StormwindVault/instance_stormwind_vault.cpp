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

#include "stormwind_vault.h"
#include "Creature.h"
#include "InstanceMapScript.h"
#include "InstanceScript.h"
#include "UnitDefines.h"

class instance_stormwind_vault : public InstanceMapScript
{
public:
    instance_stormwind_vault() : InstanceMapScript("instance_stormwind_vault", MAP_STORMWIND_VAULT) { }

    InstanceScript* GetInstanceScript(InstanceMap* map) const override
    {
        return new instance_stormwind_vault_InstanceMapScript(map);
    }

    struct instance_stormwind_vault_InstanceMapScript : public InstanceScript
    {
        instance_stormwind_vault_InstanceMapScript(Map* map) : InstanceScript(map) { }

        // Map 35 is a leftover vanilla WMO. Navmesh on unused instances is unreliable;
        // failed chase then regenerates HP in combat on every non-raid.
        void OnCreatureCreate(Creature* creature) override
        {
            InstanceScript::OnCreatureCreate(creature);
            if (!creature || !StormwindVaultIsPathingCombatNpc(creature->GetEntry()))
                return;

            creature->AddUnitState(UNIT_STATE_IGNORE_PATHFINDING);
        }
    };
};

void AddSC_instance_stormwind_vault()
{
    new instance_stormwind_vault();
}
