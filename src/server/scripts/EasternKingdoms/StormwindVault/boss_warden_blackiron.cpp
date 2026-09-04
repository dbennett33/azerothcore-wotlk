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
#include "Player.h"
#include "ScriptedCreature.h"
#include "SpellAuras.h"
#include "TemporarySummon.h"

struct boss_warden_blackiron : public ScriptedAI
{
    boss_warden_blackiron(Creature* creature) : ScriptedAI(creature), _summons(creature)
    {
        _lockdown = false;
        _enraged = false;
        _wheelStun = false;
        _wheelUsed = false;
    }

    void Reset() override
    {
        events.Reset();
        _summons.DespawnAll();
        _lockdown = false;
        _enraged = false;
        _wheelStun = false;
        _wheelUsed = false;
        me->RemoveAurasDueToSpell(SPELL_ENRAGE);
        me->RemoveUnitFlag(UNIT_FLAG_PACIFIED);
        me->SetReactState(REACT_AGGRESSIVE);
    }

    void JustEngagedWith(Unit* /*who*/) override
    {
        Talk(SAY_BLACKIRON_AGGRO);
        events.ScheduleEvent(EVENT_BLACKIRON_CLEAVE, 6s);
        events.ScheduleEvent(EVENT_BLACKIRON_STRIKE, 10s);
        events.ScheduleEvent(EVENT_BLACKIRON_KNOCKDOWN, 14s);
        events.ScheduleEvent(EVENT_BLACKIRON_SHOUT, 3s);
    }

    void JustSummoned(Creature* summon) override
    {
        _summons.Summon(summon);
        summon->CastSpell(summon, SPELL_BATTLE_SHOUT, true);

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
        Talk(SAY_BLACKIRON_DEATH);
        _summons.DespawnAll();
        me->RemoveUnitFlag(UNIT_FLAG_PACIFIED);
        StormwindVaultGrantEndBossWeapons(me);
    }

    void DoAction(int32 action) override
    {
        if (action != ACTION_BLACKIRON_WHEEL || !_enraged || _wheelUsed || _wheelStun)
            return;

        Talk(SAY_BLACKIRON_WHEEL);
        me->RemoveAurasDueToSpell(SPELL_ENRAGE);
        _wheelUsed = true;
        _wheelStun = true;
        me->SetUnitFlag(UNIT_FLAG_PACIFIED);
        me->SetReactState(REACT_PASSIVE);
        me->AttackStop();
        events.DelayEvents(Milliseconds(VAULT_WHEEL_STUN_MS + 500));
        events.ScheduleEvent(EVENT_BLACKIRON_WHEEL_END, Milliseconds(VAULT_WHEEL_STUN_MS));
    }

    void DamageTaken(Unit* /*attacker*/, uint32& /*damage*/, DamageEffectType /*type*/,
        SpellSchoolMask /*mask*/) override
    {
        if (!_lockdown && me->HealthBelowPct(60))
        {
            _lockdown = true;
            Talk(SAY_BLACKIRON_LOCKDOWN);
            me->SummonCreature(NPC_VAULT_ENFORCER, me->GetRandomNearPosition(6.f),
                TEMPSUMMON_CORPSE_TIMED_DESPAWN, 30000);
            me->SummonCreature(NPC_VAULT_ENFORCER, me->GetRandomNearPosition(6.f),
                TEMPSUMMON_CORPSE_TIMED_DESPAWN, 30000);
        }

        if (!_enraged && me->HealthBelowPct(30))
        {
            _enraged = true;
            Talk(SAY_BLACKIRON_ENRAGE);
            me->CastSpell(me, SPELL_ENRAGE, true);
        }
    }

    void UpdateAI(uint32 diff) override
    {
        if (_wheelStun)
        {
            events.Update(diff);
            if (events.ExecuteEvent() == EVENT_BLACKIRON_WHEEL_END)
                FinishWheelStun();
            return;
        }

        if (!UpdateVictim())
            return;

        events.Update(diff);

        if (me->HasUnitState(UNIT_STATE_CASTING))
            return;

        while (uint32 const eventId = events.ExecuteEvent())
        {
            switch (eventId)
            {
                case EVENT_BLACKIRON_CLEAVE:
                    DoCast(me, SPELL_THUNDER_CLAP);
                    events.ScheduleEvent(EVENT_BLACKIRON_CLEAVE, 12s, 16s);
                    break;
                case EVENT_BLACKIRON_STRIKE:
                    DoCastVictim(SPELL_MORTAL_STRIKE);
                    events.ScheduleEvent(EVENT_BLACKIRON_STRIKE, 10s, 14s);
                    break;
                case EVENT_BLACKIRON_KNOCKDOWN:
                    DoCastVictim(SPELL_KNOCKDOWN);
                    events.ScheduleEvent(EVENT_BLACKIRON_KNOCKDOWN, 16s, 20s);
                    break;
                case EVENT_BLACKIRON_SHOUT:
                    DoCast(me, SPELL_DEMORALIZING_SHOUT);
                    events.ScheduleEvent(EVENT_BLACKIRON_SHOUT, 22s);
                    break;
                default:
                    break;
            }
        }

        DoMeleeAttackIfReady();
    }

private:
    SummonList _summons;
    bool _lockdown;
    bool _enraged;
    bool _wheelStun;
    bool _wheelUsed;

    void FinishWheelStun()
    {
        if (!_wheelStun)
            return;

        _wheelStun = false;
        events.CancelEvent(EVENT_BLACKIRON_WHEEL_END);
        me->RemoveUnitFlag(UNIT_FLAG_PACIFIED);
        me->SetReactState(REACT_AGGRESSIVE);

        Unit* victim = me->GetVictim();
        if (!victim || !victim->IsAlive())
            victim = me->SelectNearestPlayer(50.f);
        if (victim)
            AttackStart(victim);
    }
};

class go_vault_wheel : public GameObjectScript
{
public:
    go_vault_wheel() : GameObjectScript("go_vault_wheel") { }

    bool OnGossipHello(Player* player, GameObject* go) override
    {
        if (!go)
            return true;

        Creature* boss = go->FindNearestCreature(NPC_WARDEN_BLACKIRON, 40.f);
        if (!boss || !boss->IsAlive() || !boss->IsInCombat() || !boss->AI())
            return true;

        if (!boss->HasAura(SPELL_ENRAGE))
            return true;

        boss->AI()->DoAction(ACTION_BLACKIRON_WHEEL);
        if (player)
            player->TextEmote("heaves the cell wheel. The locks scream.", player);

        return true;
    }
};

void AddSC_boss_warden_blackiron()
{
    RegisterCreatureAI(boss_warden_blackiron);
    new go_vault_wheel();
}
