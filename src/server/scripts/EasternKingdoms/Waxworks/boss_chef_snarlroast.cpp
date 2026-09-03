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
#include "Map.h"
#include "MotionMaster.h"
#include "ObjectAccessor.h"
#include "Player.h"
#include "ScriptedCreature.h"
#include "SpellInfo.h"
#include "TemporarySummon.h"

struct boss_chef_snarlroast : public ScriptedAI
{
    boss_chef_snarlroast(Creature* creature) : ScriptedAI(creature), _summons(creature)
    {
        _wellDoneStacks = 0;
        _trailCount = 0;
        _cook75 = false;
        _cook50 = false;
        _reduction = false;
        _toStove = false;
    }

    void Reset() override
    {
        events.Reset();
        _summons.DespawnAll();
        ClearWellDone();
        _wellDoneStacks = 0;
        _trailCount = 0;
        _cook75 = false;
        _cook50 = false;
        _reduction = false;
        _toStove = false;
        _storedVictim.Clear();
        me->RemoveUnitFlag(UNIT_FLAG_PACIFIED);
        me->SetReactState(REACT_AGGRESSIVE);
    }

    void EnterEvadeMode(EvadeReason why) override
    {
        ClearWellDone();
        ScriptedAI::EnterEvadeMode(why);
    }

    void JustEngagedWith(Unit* /*who*/) override
    {
        Talk(SAY_SNARL_AGGRO);
        events.ScheduleEvent(EVENT_SNARL_WELL_DONE, 4s);
        events.ScheduleEvent(EVENT_SNARL_UPPERCUT, 15s);
        events.ScheduleEvent(EVENT_SNARL_HOT_SAUCE, 20s);
    }

    void JustSummoned(Creature* summon) override
    {
        _summons.Summon(summon);
        if (summon->GetEntry() == NPC_FIRE_TRAIL)
            return;

        CreatureAI* ai = summon->AI();
        if (!ai)
            return;

        Unit* victim = me->GetVictim();
        if (!victim)
            victim = ObjectAccessor::GetUnit(*me, _storedVictim);
        if (!victim || !victim->IsAlive())
            victim = me->SelectNearestPlayer(50.f);
        if (victim)
            ai->AttackStart(victim);
    }

    void JustDied(Unit* /*killer*/) override
    {
        Talk(SAY_SNARL_DEATH);
        _summons.DespawnAll();
        ClearWellDone();
    }

    void SpellHitTarget(Unit* target, SpellInfo const* spellInfo) override
    {
        if (!spellInfo || spellInfo->Id != SPELL_WELL_DONE || !target || !target->IsPlayer())
            return;

        ++_wellDoneStacks;
        if (_wellDoneStacks == 1)
            Talk(SAY_SNARL_RARE);
        else if (_wellDoneStacks == 2)
            Talk(SAY_SNARL_MEDIUM);
        else if (_wellDoneStacks >= 3)
        {
            Talk(SAY_SNARL_WELL_DONE);
            _trailCount = 0;
            events.ScheduleEvent(EVENT_SNARL_FIRE_TRAIL, 0s);
        }
    }

    void DamageTaken(Unit* /*attacker*/, uint32& /*damage*/, DamageEffectType /*type*/,
        SpellSchoolMask /*mask*/) override
    {
        if (!_cook75 && me->HealthBelowPct(75))
        {
            _cook75 = true;
            me->SummonCreature(NPC_LINE_COOK, me->GetRandomNearPosition(6.f),
                TEMPSUMMON_CORPSE_TIMED_DESPAWN, 30000);
        }

        if (!_cook50 && me->HealthBelowPct(50))
        {
            _cook50 = true;
            me->SummonCreature(NPC_LINE_COOK, me->GetRandomNearPosition(6.f),
                TEMPSUMMON_CORPSE_TIMED_DESPAWN, 30000);
        }

        if (!_reduction && me->HealthBelowPct(40))
        {
            _reduction = true;
            Talk(SAY_SNARL_REDUCTION);
            if (Unit* victim = me->GetVictim())
                _storedVictim = victim->GetGUID();

            _toStove = true;
            me->SetUnitFlag(UNIT_FLAG_PACIFIED);
            me->SetReactState(REACT_PASSIVE);
            me->AttackStop();
            me->GetMotionMaster()->Clear();
            me->GetMotionMaster()->MovePoint(POINT_SNARL_STOVE, SnarlroastStovePos);
            events.DelayEvents(Milliseconds(WAXWORKS_SNARL_STOVE_MS + 1000));
            events.ScheduleEvent(EVENT_SNARL_STOVE_TIMEOUT, Milliseconds(WAXWORKS_SNARL_STOVE_MS));
        }
    }

    void MovementInform(uint32 type, uint32 pointId) override
    {
        if (type != POINT_MOTION_TYPE || pointId != POINT_SNARL_STOVE)
            return;

        FinishStoveWalk();
    }

    void UpdateAI(uint32 diff) override
    {
        if (_toStove)
        {
            events.Update(diff);
            if (events.ExecuteEvent() == EVENT_SNARL_STOVE_TIMEOUT)
                FinishStoveWalk();
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
                case EVENT_SNARL_WELL_DONE:
                    DoCastVictim(SPELL_WELL_DONE);
                    events.ScheduleEvent(EVENT_SNARL_WELL_DONE, 8s, 12s);
                    break;
                case EVENT_SNARL_UPPERCUT:
                    DoCastVictim(SPELL_UPPERCUT);
                    events.ScheduleEvent(EVENT_SNARL_UPPERCUT, 15s);
                    break;
                case EVENT_SNARL_HOT_SAUCE:
                    if (Unit* target = SelectTarget(SelectTargetMethod::Random, 0, 30.f, true))
                        DoCast(target, SPELL_ACID_SPLASH);
                    events.ScheduleEvent(EVENT_SNARL_HOT_SAUCE, 20s);
                    break;
                case EVENT_SNARL_FIRE_TRAIL:
                    if (_trailCount < 4)
                    {
                        if (Unit* victim = me->GetVictim())
                            me->SummonCreature(NPC_FIRE_TRAIL, victim->GetPosition(),
                                TEMPSUMMON_TIMED_DESPAWN, 5000);
                        ++_trailCount;
                        events.ScheduleEvent(EVENT_SNARL_FIRE_TRAIL, 1s);
                    }
                    break;
                case EVENT_SNARL_COOK:
                    DoCast(me, SPELL_COOKIES_COOKING);
                    events.ScheduleEvent(EVENT_SNARL_COOK, 20s);
                    break;
                default:
                    break;
            }
        }

        DoMeleeAttackIfReady();
    }

private:
    SummonList _summons;
    ObjectGuid _storedVictim;
    uint8 _wellDoneStacks;
    uint8 _trailCount;
    bool _cook75;
    bool _cook50;
    bool _reduction;
    bool _toStove;

    void FinishStoveWalk()
    {
        if (!_toStove)
            return;

        _toStove = false;
        events.CancelEvent(EVENT_SNARL_STOVE_TIMEOUT);
        me->RemoveUnitFlag(UNIT_FLAG_PACIFIED);
        me->SetReactState(REACT_AGGRESSIVE);

        Unit* victim = ObjectAccessor::GetUnit(*me, _storedVictim);
        if (!victim || !victim->IsAlive())
            victim = me->SelectNearestPlayer(50.f);
        if (victim)
            AttackStart(victim);

        DoCast(me, SPELL_COOKIES_COOKING);
        me->SummonCreature(NPC_DISHWASHER, me->GetRandomNearPosition(5.f),
            TEMPSUMMON_CORPSE_TIMED_DESPAWN, 30000);
        me->SummonCreature(NPC_DISHWASHER, me->GetRandomNearPosition(5.f),
            TEMPSUMMON_CORPSE_TIMED_DESPAWN, 30000);
        events.ScheduleEvent(EVENT_SNARL_COOK, 20s);
    }

    void ClearWellDone()
    {
        if (Map* map = me->GetMap())
        {
            map->DoForAllPlayers([&](Player* player)
            {
                if (player && player->IsInDist(me, 80.f))
                    player->RemoveAurasDueToSpell(SPELL_WELL_DONE);
            });
        }
    }
};

class go_waxworks_cheese : public GameObjectScript
{
public:
    go_waxworks_cheese() : GameObjectScript("go_waxworks_cheese") { }

    bool OnGossipHello(Player* player, GameObject* go) override
    {
        if (!go)
            return true;

        if (Creature* cook = go->FindNearestCreature(NPC_LINE_COOK, 40.f))
        {
            if (cook->IsAlive())
            {
                cook->CastSpell(cook, SPELL_ENRAGE, true);
                return true;
            }
        }

        if (player)
            player->TextEmote("nibbles the leftover cheese. Filling, if undignified.", player);

        return true;
    }
};

void AddSC_boss_chef_snarlroast()
{
    RegisterCreatureAI(boss_chef_snarlroast);
    new go_waxworks_cheese();
}
