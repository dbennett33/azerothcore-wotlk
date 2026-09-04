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

struct boss_captain_whelm : public ScriptedAI
{
    boss_captain_whelm(Creature* creature) : ScriptedAI(creature), _summons(creature)
    {
        _adds50 = false;
    }

    void Reset() override
    {
        events.Reset();
        _summons.DespawnAll();
        _adds50 = false;
        me->RemoveAurasDueToSpell(SPELL_ENRAGE);
    }

    void JustEngagedWith(Unit* /*who*/) override
    {
        Talk(SAY_WHELM_AGGRO);
        events.ScheduleEvent(EVENT_WHELM_CHARGE, 4s);
        events.ScheduleEvent(EVENT_WHELM_KNOCKDOWN, 8s);
        events.ScheduleEvent(EVENT_WHELM_CLEAVE, 6s);
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
        Talk(SAY_WHELM_DEATH);
        _summons.DespawnAll();
    }

    void DamageTaken(Unit* /*attacker*/, uint32& /*damage*/, DamageEffectType /*type*/,
        SpellSchoolMask /*mask*/) override
    {
        if (!_adds50 && me->HealthBelowPct(50))
        {
            _adds50 = true;
            Talk(SAY_WHELM_ADDS);
            events.ScheduleEvent(EVENT_WHELM_ADDS, 0s);
        }

        if (me->HealthBelowPct(30) && !me->HasAura(SPELL_ENRAGE))
            DoCast(me, SPELL_ENRAGE, true);
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
                case EVENT_WHELM_CHARGE:
                    if (Unit* target = SelectTarget(SelectTargetMethod::MaxDistance, 0, 30.f, true))
                        DoCast(target, SPELL_RUSHING_CHARGE);
                    events.ScheduleEvent(EVENT_WHELM_CHARGE, 14s, 18s);
                    break;
                case EVENT_WHELM_KNOCKDOWN:
                    DoCastVictim(SPELL_KNOCKDOWN);
                    events.ScheduleEvent(EVENT_WHELM_KNOCKDOWN, 12s, 16s);
                    break;
                case EVENT_WHELM_CLEAVE:
                    DoCastVictim(SPELL_CLEAVE);
                    events.ScheduleEvent(EVENT_WHELM_CLEAVE, 8s, 12s);
                    break;
                case EVENT_WHELM_ADDS:
                    me->SummonCreature(NPC_TIDEBORN_MURLOC, me->GetRandomNearPosition(6.f),
                        TEMPSUMMON_CORPSE_TIMED_DESPAWN, 30000);
                    me->SummonCreature(NPC_DROWNED_SAILOR, me->GetRandomNearPosition(6.f),
                        TEMPSUMMON_CORPSE_TIMED_DESPAWN, 30000);
                    break;
                default:
                    break;
            }
        }

        DoMeleeAttackIfReady();
    }

private:
    SummonList _summons;
    bool _adds50;
};

void AddSC_boss_captain_whelm()
{
    RegisterCreatureAI(boss_captain_whelm);
}
