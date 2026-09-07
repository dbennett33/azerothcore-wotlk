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
#include "CreatureScript.h"
#include "GameObject.h"
#include "GameObjectScript.h"
#include "Map.h"
#include "Player.h"
#include "ScriptedCreature.h"
#include "TemporarySummon.h"

struct boss_turnkey_garrow : public ScriptedAI
{
    boss_turnkey_garrow(Creature* creature) : ScriptedAI(creature), _summons(creature)
    {
        _cells66 = false;
        _cells33 = false;
    }

    void Reset() override
    {
        events.Reset();
        _summons.DespawnAll();
        _cells66 = false;
        _cells33 = false;
    }

    void JustEngagedWith(Unit* /*who*/) override
    {
        Talk(SAY_GARROW_AGGRO);
        events.ScheduleEvent(EVENT_GARROW_NET, 8s);
        events.ScheduleEvent(EVENT_GARROW_PIERCE, 6s);
        events.ScheduleEvent(EVENT_GARROW_KICK, 12s);
        events.ScheduleEvent(EVENT_GARROW_SHOUT, 4s);
    }

    void JustSummoned(Creature* summon) override
    {
        _summons.Summon(summon);

        CreatureAI* ai = summon->AI();
        if (!ai)
            return;

        Unit* victim = me->GetVictim();
        if (!victim)
            victim = me->SelectNearestPlayer(50.f);
        if (victim)
            ai->AttackStart(victim);
    }

    void JustDied(Unit* /*killer*/) override
    {
        Talk(SAY_GARROW_DEATH);
        _summons.DespawnAll();
    }

    void DoAction(int32 action) override
    {
        if (action != ACTION_GARROW_LEVER)
            return;

        Talk(SAY_GARROW_LEVER);
        if (Map* map = me->GetMap())
        {
            map->DoForAllPlayers([&](Player* player)
            {
                if (player && player->IsAlive() && player->IsWithinDistInMap(me, 40.f))
                    player->RemoveAurasDueToSpell(SPELL_NET);
            });
        }

        me->SummonCreature(NPC_VAULT_INMATE, me->GetRandomNearPosition(5.f),
            TEMPSUMMON_CORPSE_TIMED_DESPAWN, 30000);
    }

    void DamageTaken(Unit* /*attacker*/, uint32& /*damage*/, DamageEffectType /*type*/,
        SpellSchoolMask /*mask*/) override
    {
        if (!_cells66 && me->HealthBelowPct(66))
        {
            _cells66 = true;
            OpenCells();
        }

        if (!_cells33 && me->HealthBelowPct(33))
        {
            _cells33 = true;
            OpenCells();
        }
    }

    void UpdateAI(uint32 diff) override
    {
        if (!UpdateVictim())
            return;

        events.Update(diff);

        if (me->HasUnitState(UNIT_STATE_CASTING))
            return;

        while (uint32 const eventId = events.ExecuteEvent())
        {
            switch (eventId)
            {
                case EVENT_GARROW_NET:
                    if (Unit* target = SelectTarget(SelectTargetMethod::Random, 0, 30.f, true, false))
                        DoCast(target, SPELL_NET);
                    events.ScheduleEvent(EVENT_GARROW_NET, 16s, 22s);
                    break;
                case EVENT_GARROW_PIERCE:
                    DoCastVictim(SPELL_PIERCE_ARMOR);
                    events.ScheduleEvent(EVENT_GARROW_PIERCE, 18s);
                    break;
                case EVENT_GARROW_KICK:
                    DoCastVictim(SPELL_SNAP_KICK);
                    events.ScheduleEvent(EVENT_GARROW_KICK, 12s, 16s);
                    break;
                case EVENT_GARROW_SHOUT:
                    DoCast(me, SPELL_BATTLE_SHOUT);
                    events.ScheduleEvent(EVENT_GARROW_SHOUT, 25s);
                    break;
                default:
                    break;
            }
        }

        DoMeleeAttackIfReady();
    }

private:
    SummonList _summons;
    bool _cells66;
    bool _cells33;

    void OpenCells()
    {
        Talk(SAY_GARROW_CELLS);
        me->SummonCreature(NPC_VAULT_INMATE, me->GetRandomNearPosition(6.f),
            TEMPSUMMON_CORPSE_TIMED_DESPAWN, 30000);
        me->SummonCreature(NPC_VAULT_RIOTER, me->GetRandomNearPosition(6.f),
            TEMPSUMMON_CORPSE_TIMED_DESPAWN, 30000);
    }
};

class go_vault_cell_lever : public GameObjectScript
{
public:
    go_vault_cell_lever() : GameObjectScript("go_vault_cell_lever") { }

    bool OnGossipHello(Player* /*player*/, GameObject* go) override
    {
        if (!go)
            return true;

        Creature* garrow = go->FindNearestCreature(NPC_TURNKEY_GARROW, 40.f);
        if (!garrow || !garrow->IsAlive() || !garrow->IsInCombat() || !garrow->AI())
            return true;

        garrow->AI()->DoAction(ACTION_GARROW_LEVER);
        return true;
    }
};

void AddSC_boss_turnkey_garrow()
{
    RegisterCreatureAI(boss_turnkey_garrow);
    new go_vault_cell_lever();
}
