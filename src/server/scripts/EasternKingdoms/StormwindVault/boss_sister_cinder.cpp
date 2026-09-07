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
#include "ObjectAccessor.h"
#include "ScriptedCreature.h"
#include "TemporarySummon.h"

struct boss_sister_cinder : public ScriptedAI
{
    boss_sister_cinder(Creature* creature) : ScriptedAI(creature), _summons(creature)
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
        _confessionDummy.Clear();
    }

    void JustEngagedWith(Unit* /*who*/) override
    {
        Talk(SAY_CINDER_AGGRO);
        me->CastSpell(me, SPELL_FROST_ARMOR, true);
        events.ScheduleEvent(EVENT_CINDER_BOLT, 2s);
        events.ScheduleEvent(EVENT_CINDER_PAIN, 8s);
        events.ScheduleEvent(EVENT_CINDER_CONFESSION, 14s);
    }

    void JustSummoned(Creature* summon) override
    {
        _summons.Summon(summon);
        if (summon->GetEntry() == NPC_CONFESSION_DUMMY)
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
        Talk(SAY_CINDER_DEATH);
        _summons.DespawnAll();
    }

    void DamageTaken(Unit* /*attacker*/, uint32& /*damage*/, DamageEffectType /*type*/,
        SpellSchoolMask /*mask*/) override
    {
        if (!_scream && me->HealthBelowPct(50))
        {
            _scream = true;
            events.ScheduleEvent(EVENT_CINDER_SCREAM, 0s);
        }

        if (!_adds33 && me->HealthBelowPct(33))
        {
            _adds33 = true;
            me->SummonCreature(NPC_VAULT_ACOLYTE, me->GetRandomNearPosition(5.f),
                TEMPSUMMON_CORPSE_TIMED_DESPAWN, 30000);
            me->SummonCreature(NPC_SHACKLED_HORROR, me->GetRandomNearPosition(5.f),
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
                case EVENT_CINDER_BOLT:
                    DoCastVictim(SPELL_SHADOW_BOLT);
                    events.ScheduleEvent(EVENT_CINDER_BOLT, 3s);
                    break;
                case EVENT_CINDER_PAIN:
                    if (Unit* target = SelectTarget(SelectTargetMethod::Random, 0, 30.f, true))
                        DoCast(target, SPELL_SHADOW_WORD_PAIN);
                    events.ScheduleEvent(EVENT_CINDER_PAIN, 12s, 16s);
                    break;
                case EVENT_CINDER_CONFESSION:
                    Talk(SAY_CINDER_CONFESS);
                    if (Unit* target = SelectTarget(SelectTargetMethod::Random, 0, 30.f, true))
                    {
                        if (Creature* dummy = me->SummonCreature(NPC_CONFESSION_DUMMY, *target,
                            TEMPSUMMON_TIMED_DESPAWN, 12000))
                        {
                            _confessionDummy = dummy->GetGUID();
                            events.ScheduleEvent(EVENT_CINDER_CONFESSION_NOVA, 6s);
                        }
                    }
                    events.ScheduleEvent(EVENT_CINDER_CONFESSION, 20s);
                    break;
                case EVENT_CINDER_CONFESSION_NOVA:
                    if (Creature* dummy = ObjectAccessor::GetCreature(*me, _confessionDummy))
                        dummy->CastSpell(dummy, SPELL_FIRE_NOVA_SMALL, false);
                    break;
                case EVENT_CINDER_SCREAM:
                    Talk(SAY_CINDER_SCREAM);
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
    ObjectGuid _confessionDummy;
    bool _scream;
    bool _adds33;
};

void AddSC_boss_sister_cinder()
{
    RegisterCreatureAI(boss_sister_cinder);
}
