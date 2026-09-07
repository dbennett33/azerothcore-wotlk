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
#include "GameObject.h"
#include "GameObjectScript.h"
#include "ObjectAccessor.h"
#include "Player.h"
#include "ScriptedCreature.h"
#include "TemporarySummon.h"

struct boss_princess : public ScriptedAI
{
    boss_princess(Creature* creature) : ScriptedAI(creature)
    {
        _fixate = false;
    }

    void Reset() override
    {
        events.Reset();
        _fixate = false;
    }

    void JustEngagedWith(Unit* /*who*/) override
    {
        events.ScheduleEvent(EVENT_PRINCESS_CHARGE, 5s);
        events.ScheduleEvent(EVENT_PRINCESS_HEAD_BUTT, 12s);
        events.ScheduleEvent(EVENT_PRINCESS_PIERCE, 18s);
    }

    void JustDied(Unit* /*killer*/) override
    {
        Talk(SAY_PRINCESS_DEATH);
    }

    void DamageTaken(Unit* /*attacker*/, uint32& /*damage*/, DamageEffectType /*type*/,
        SpellSchoolMask /*mask*/) override
    {
        if (_fixate || !me->HealthBelowPct(50))
            return;

        _fixate = true;
        if (Creature* unit07 = me->FindNearestCreature(NPC_UNIT_07, 50.f))
            if (CreatureAI* ai = unit07->AI())
                ai->DoAction(ACTION_UNIT07_FIXATE);
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
                case EVENT_PRINCESS_CHARGE:
                    if (Unit* target = SelectTarget(SelectTargetMethod::MaxDistance, 0, 40.f, true))
                        DoCast(target, SPELL_RUSHING_CHARGE);
                    events.ScheduleEvent(EVENT_PRINCESS_CHARGE, 15s);
                    break;
                case EVENT_PRINCESS_HEAD_BUTT:
                    DoCastVictim(SPELL_HEAD_BUTT);
                    events.ScheduleEvent(EVENT_PRINCESS_HEAD_BUTT, 20s);
                    break;
                case EVENT_PRINCESS_PIERCE:
                    DoCastVictim(SPELL_PIERCE_ARMOR);
                    events.ScheduleEvent(EVENT_PRINCESS_PIERCE, 30s);
                    break;
                default:
                    break;
            }
        }

        DoMeleeAttackIfReady();
    }

private:
    bool _fixate;
};

struct npc_unit_07 : public ScriptedAI
{
    npc_unit_07(Creature* creature) : ScriptedAI(creature)
    {
        _fixateGuid.Clear();
    }

    void Reset() override
    {
        events.Reset();
        _fixateGuid.Clear();
        me->SetReactState(REACT_PASSIVE);
    }

    void JustEngagedWith(Unit* /*who*/) override
    {
        events.ScheduleEvent(EVENT_UNIT07_TETANUS, 8s);
        events.ScheduleEvent(EVENT_UNIT07_WIDE_SLASH, 6s);
    }

    void DoAction(int32 action) override
    {
        if (action != ACTION_UNIT07_FIXATE)
            return;

        me->SetReactState(REACT_AGGRESSIVE);

        Unit* healer = SelectTarget(SelectTargetMethod::Random, 0, [](Unit* target) -> bool
        {
            return target && target->IsPlayer() && target->getPowerType() == POWER_MANA;
        });

        if (!healer)
            healer = SelectTarget(SelectTargetMethod::Random, 0, 40.f, true);
        if (!healer)
            healer = me->SelectNearestPlayer(40.f);

        if (!healer)
            return;

        _fixateGuid = healer->GetGUID();
        AttackStart(healer);
        DoCast(healer, SPELL_FIXATE);
        events.ScheduleEvent(EVENT_UNIT07_FIXATE_END, Milliseconds(WAXWORKS_FIXATE_MS));
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
                case EVENT_UNIT07_TETANUS:
                    DoCastVictim(SPELL_TETANUS);
                    events.ScheduleEvent(EVENT_UNIT07_TETANUS, 12s);
                    break;
                case EVENT_UNIT07_WIDE_SLASH:
                    DoCastVictim(SPELL_WIDE_SLASH);
                    events.ScheduleEvent(EVENT_UNIT07_WIDE_SLASH, 10s);
                    break;
                case EVENT_UNIT07_FIXATE_END:
                    if (Unit* target = ObjectAccessor::GetUnit(*me, _fixateGuid))
                        target->RemoveAurasDueToSpell(SPELL_FIXATE);
                    _fixateGuid.Clear();
                    break;
                default:
                    break;
            }
        }

        DoMeleeAttackIfReady();
    }

private:
    ObjectGuid _fixateGuid;
};

class go_waxworks_pumpkin : public GameObjectScript
{
public:
    go_waxworks_pumpkin() : GameObjectScript("go_waxworks_pumpkin") { }

    bool OnGossipHello(Player* player, GameObject* go) override
    {
        if (!go)
            return true;

        if (player)
            player->TextEmote("jams the pumpkin onto the nearest metal skull.", player);

        if (Creature* unit07 = go->FindNearestCreature(NPC_UNIT_07, 40.f))
            unit07->GetThreatMgr().ResetAllThreat();

        if (Creature* princess = go->FindNearestCreature(NPC_PRINCESS, 40.f))
            princess->GetThreatMgr().ResetAllThreat();

        return true;
    }
};

void AddSC_boss_princess()
{
    RegisterCreatureAI(boss_princess);
    RegisterCreatureAI(npc_unit_07);
    new go_waxworks_pumpkin();
}
