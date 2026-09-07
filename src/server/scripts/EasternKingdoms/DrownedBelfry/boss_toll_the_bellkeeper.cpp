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

struct boss_toll_the_bellkeeper : public ScriptedAI
{
    boss_toll_the_bellkeeper(Creature* creature) : ScriptedAI(creature), _summons(creature)
    {
        _enraged = false;
    }

    void Reset() override
    {
        events.Reset();
        _summons.DespawnAll();
        _enraged = false;
        me->RemoveAurasDueToSpell(SPELL_ENRAGE);
    }

    void JustEngagedWith(Unit* /*who*/) override
    {
        Talk(SAY_TOLL_AGGRO);
        events.ScheduleEvent(EVENT_TOLL_CLAP, 5s);
        events.ScheduleEvent(EVENT_TOLL_KNOCKDOWN, 10s);
        events.ScheduleEvent(EVENT_TOLL_BELL, 14s);
        events.ScheduleEvent(EVENT_TOLL_SHOUT, 3s);
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
        Talk(SAY_TOLL_DEATH);
        _summons.DespawnAll();
        DrownedBelfryGrantEndBossWeapons(me);
    }

    void DamageTaken(Unit* /*attacker*/, uint32& /*damage*/, DamageEffectType /*type*/,
        SpellSchoolMask /*mask*/) override
    {
        if (_enraged || !me->HealthBelowPct(30))
            return;

        _enraged = true;
        Talk(SAY_TOLL_ENRAGE);
        DoCast(me, SPELL_ENRAGE, true);
        me->SummonCreature(NPC_BELL_ATTENDANT, me->GetRandomNearPosition(6.f),
            TEMPSUMMON_CORPSE_TIMED_DESPAWN, 30000);
        me->SummonCreature(NPC_BELL_ATTENDANT, me->GetRandomNearPosition(6.f),
            TEMPSUMMON_CORPSE_TIMED_DESPAWN, 30000);
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
                case EVENT_TOLL_CLAP:
                    DoCast(me, SPELL_THUNDER_CLAP);
                    events.ScheduleEvent(EVENT_TOLL_CLAP, 10s, 14s);
                    break;
                case EVENT_TOLL_KNOCKDOWN:
                    DoCastVictim(SPELL_KNOCKDOWN);
                    events.ScheduleEvent(EVENT_TOLL_KNOCKDOWN, 12s, 16s);
                    break;
                case EVENT_TOLL_BELL:
                    Talk(SAY_TOLL_BELL);
                    DoCast(me, SPELL_FIRE_NOVA_SMALL);
                    events.ScheduleEvent(EVENT_TOLL_BELL, 18s, 22s);
                    break;
                case EVENT_TOLL_SHOUT:
                    DoCast(me, SPELL_BATTLE_SHOUT);
                    events.ScheduleEvent(EVENT_TOLL_SHOUT, 25s);
                    break;
                default:
                    break;
            }
        }

        DoMeleeAttackIfReady();
    }

private:
    SummonList _summons;
    bool _enraged;
};

void AddSC_boss_toll_the_bellkeeper()
{
    RegisterCreatureAI(boss_toll_the_bellkeeper);
}
