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
#include "CreatureScript.h"
#include "ScriptedCreature.h"
#include "TemporarySummon.h"

struct boss_sister_brine : public ScriptedAI
{
    boss_sister_brine(Creature* creature) : ScriptedAI(creature), _summons(creature)
    {
        _scream = false;
        _adds33 = false;
    }

    void Reset() override
    {
        events.Reset();
        _summons.DespawnAll();
        _scream = false;
        _adds33 = false;
        _novaDummy.Clear();
    }

    void JustEngagedWith(Unit* /*who*/) override
    {
        Talk(SAY_BRINE_AGGRO);
        me->CastSpell(me, SPELL_FROST_ARMOR, true);
        events.ScheduleEvent(EVENT_BRINE_BOLT, 2s);
        events.ScheduleEvent(EVENT_BRINE_PAIN, 8s);
        events.ScheduleEvent(EVENT_BRINE_NOVA, 12s);
    }

    void JustSummoned(Creature* summon) override
    {
        _summons.Summon(summon);
        if (summon->GetEntry() == NPC_BRINE_DUMMY)
            return;

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
        Talk(SAY_BRINE_DEATH);
        _summons.DespawnAll();
    }

    void DamageTaken(Unit* /*attacker*/, uint32& /*damage*/, DamageEffectType /*type*/,
        SpellSchoolMask /*mask*/) override
    {
        if (!_scream && me->HealthBelowPct(50))
        {
            _scream = true;
            events.ScheduleEvent(EVENT_BRINE_SCREAM, 0s);
        }

        if (!_adds33 && me->HealthBelowPct(33))
        {
            _adds33 = true;
            me->SummonCreature(NPC_BRINE_ACOLYTE, me->GetRandomNearPosition(5.f),
                TEMPSUMMON_CORPSE_TIMED_DESPAWN, 30000);
            me->SummonCreature(NPC_BRINE_ACOLYTE, me->GetRandomNearPosition(5.f),
                TEMPSUMMON_CORPSE_TIMED_DESPAWN, 30000);
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
                case EVENT_BRINE_BOLT:
                    DoCastVictim(SPELL_FROSTBOLT);
                    events.ScheduleEvent(EVENT_BRINE_BOLT, 3s);
                    break;
                case EVENT_BRINE_PAIN:
                    if (Unit* target = SelectTarget(SelectTargetMethod::Random, 0, 30.f, true))
                        DoCast(target, SPELL_SHADOW_WORD_PAIN);
                    events.ScheduleEvent(EVENT_BRINE_PAIN, 12s, 16s);
                    break;
                case EVENT_BRINE_NOVA:
                    Talk(SAY_BRINE_NOVA);
                    DoCast(me, SPELL_FROST_NOVA);
                    if (Unit* target = SelectTarget(SelectTargetMethod::Random, 0, 30.f, true))
                    {
                        if (Creature* dummy = me->SummonCreature(NPC_BRINE_DUMMY, *target,
                            TEMPSUMMON_TIMED_DESPAWN, 8000))
                        {
                            _novaDummy = dummy->GetGUID();
                            dummy->CastSpell(dummy, SPELL_FIRE_NOVA_SMALL, false);
                        }
                    }
                    events.ScheduleEvent(EVENT_BRINE_NOVA, 18s, 22s);
                    break;
                case EVENT_BRINE_SCREAM:
                    Talk(SAY_BRINE_SCREAM);
                    DoCast(me, SPELL_PSYCHIC_SCREAM);
                    break;
                default:
                    break;
            }
        }

        DoMeleeAttackIfReady();
    }

private:
    SummonList _summons;
    ObjectGuid _novaDummy;
    bool _scream;
    bool _adds33;
};

void AddSC_boss_sister_brine()
{
    RegisterCreatureAI(boss_sister_brine);
}
