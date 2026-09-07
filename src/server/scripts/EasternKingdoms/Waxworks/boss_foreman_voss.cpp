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
#include "Map.h"
#include "MotionMaster.h"
#include "ObjectAccessor.h"
#include "Player.h"
#include "ScriptedCreature.h"
#include "ScriptedGossip.h"
#include "TemporarySummon.h"

struct boss_foreman_vossAI : public ScriptedAI
{
    boss_foreman_vossAI(Creature* creature) : ScriptedAI(creature), _summons(creature)
    {
        _choice = VOSS_CHOICE_NONE;
        _secondTalk = false;
        _negotiating = false;
        _adds50 = false;
    }

    void Reset() override
    {
        events.Reset();
        _summons.DespawnAll();
        _choice = VOSS_CHOICE_NONE;
        _secondTalk = false;
        _negotiating = false;
        _adds50 = false;
        _storedVictim.Clear();
        me->LoadEquipment(EQUIP_VOSS_CLIPBOARD);
        me->RemoveUnitFlag(UNIT_FLAG_PACIFIED);
        me->SetReactState(REACT_AGGRESSIVE);
        me->ResetLootMode();
    }

    void JustEngagedWith(Unit* who) override
    {
        Talk(SAY_VOSS_AGGRO);
        if (who)
            _storedVictim = who->GetGUID();

        events.ScheduleEvent(EVENT_VOSS_NEGOTIATE, 2s);
        events.ScheduleEvent(EVENT_VOSS_SMOKE, 15s, 25s);
        events.ScheduleEvent(EVENT_VOSS_SNAP_KICK, 8s, 12s);
        events.ScheduleEvent(EVENT_VOSS_SLAM, 1s);
    }

    void JustSummoned(Creature* summon) override
    {
        _summons.Summon(summon);
        summon->CastSpell(summon, SPELL_BATTLE_SHOUT, true);

        CreatureAI* ai = summon->AI();
        if (!ai)
            return;

        Unit* victim = me->GetVictim();
        if (!victim || !victim->IsAlive())
            victim = ObjectAccessor::GetUnit(*me, _storedVictim);
        if (!victim || !victim->IsAlive())
            victim = me->SelectNearestPlayer(50.f);
        if (victim)
            ai->AttackStart(victim);
    }

    void JustDied(Unit* /*killer*/) override
    {
        Talk(SAY_VOSS_DEATH);
        _summons.DespawnAll();
        _negotiating = false;
        me->RemoveUnitFlag(UNIT_FLAG_PACIFIED);
        WaxworksGrantEndBossWeapons(me);
    }

    uint32 GetData(uint32 id) const override
    {
        if (id == DATA_VOSS_IS_NEGOTIATING)
            return _negotiating ? 1 : 0;
        if (id == DATA_VOSS_NEGOTIATION)
            return _choice;
        return 0;
    }

    void SetData(uint32 id, uint32 value) override
    {
        if (id != DATA_VOSS_NEGOTIATION)
            return;

        events.CancelEvent(EVENT_VOSS_NEGOTIATE_TIMEOUT);

        if (_choice == VOSS_CHOICE_NONE)
        {
            if (value == VOSS_CHOICE_HARD)
                ApplyHard();
            else if (value == VOSS_CHOICE_SOFT)
                ApplySoft();
        }

        ResumeCombat();
    }

    void DamageTaken(Unit* /*attacker*/, uint32& /*damage*/, DamageEffectType /*type*/,
        SpellSchoolMask /*mask*/) override
    {
        if (!_secondTalk && me->HealthBelowPct(60))
        {
            _secondTalk = true;
            events.ScheduleEvent(EVENT_VOSS_NEGOTIATE, 0s);
        }

        if (!_adds50 && me->HealthBelowPct(50))
        {
            _adds50 = true;
            uint8 const count = (_choice == VOSS_CHOICE_SOFT) ? 1 : 2;
            for (uint8 i = 0; i < count; ++i)
                me->SummonCreature(NPC_VOSS_BODYGUARD, me->GetRandomNearPosition(6.f),
                    TEMPSUMMON_CORPSE_TIMED_DESPAWN, 30000);
        }
    }

    void MovementInform(uint32 type, uint32 pointId) override
    {
        if (type != POINT_MOTION_TYPE || pointId != POINT_VOSS_BOARD)
            return;

        DoCast(me, SPELL_SMITE_STOMP);
        OpenGossipToPlayers();
        events.CancelEvent(EVENT_VOSS_NEGOTIATE_TIMEOUT);
        events.ScheduleEvent(EVENT_VOSS_NEGOTIATE_TIMEOUT, Milliseconds(WAXWORKS_VOSS_TIMEOUT_MS));
    }

    void UpdateAI(uint32 diff) override
    {
        if (_negotiating)
        {
            events.Update(diff);
            while (uint32 const eventId = events.ExecuteEvent())
            {
                if (eventId == EVENT_VOSS_NEGOTIATE_TIMEOUT)
                {
                    if (_choice == VOSS_CHOICE_NONE)
                        ApplyHard();
                    ResumeCombat();
                    return;
                }
                if (eventId == EVENT_VOSS_NEGOTIATE)
                    events.ScheduleEvent(EVENT_VOSS_NEGOTIATE, 1s);
            }
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
                case EVENT_VOSS_NEGOTIATE:
                    StartNegotiation();
                    break;
                case EVENT_VOSS_SMOKE:
                    DoCast(me, SPELL_SMOKE_BOMB);
                    events.ScheduleEvent(EVENT_VOSS_SMOKE, 15s, 25s);
                    break;
                case EVENT_VOSS_SNAP_KICK:
                    if (Unit* target = SelectTarget(SelectTargetMethod::Random, 0, 8.f, true))
                        DoCast(target, SPELL_SNAP_KICK);
                    events.ScheduleEvent(EVENT_VOSS_SNAP_KICK, 8s, 14s);
                    break;
                case EVENT_VOSS_SLAM:
                    if (_secondTalk && me->GetVictim() && me->GetVictim()->HealthBelowPct(33))
                        DoCastVictim(SPELL_SMITE_SLAM);
                    events.ScheduleEvent(EVENT_VOSS_SLAM, 6s);
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
    uint32 _choice;
    bool _secondTalk;
    bool _negotiating;
    bool _adds50;

    void StartNegotiation()
    {
        if (_negotiating)
            return;

        _negotiating = true;
        if (Unit* victim = me->GetVictim())
            _storedVictim = victim->GetGUID();

        me->SetUnitFlag(UNIT_FLAG_PACIFIED);
        me->SetReactState(REACT_PASSIVE);
        me->AttackStop();
        me->GetMotionMaster()->Clear();
        me->GetMotionMaster()->MovePoint(POINT_VOSS_BOARD, VossBoardPos);
        events.DelayEvents(Milliseconds(WAXWORKS_VOSS_TIMEOUT_MS + 2000));
        events.ScheduleEvent(EVENT_VOSS_NEGOTIATE_TIMEOUT, Milliseconds(WAXWORKS_VOSS_TIMEOUT_MS));
    }

    void OpenGossipToPlayers()
    {
        if (Map* map = me->GetMap())
        {
            map->DoForAllPlayers([&](Player* player)
            {
                if (!player || !player->IsAlive() || !player->IsWithinDistInMap(me, 40.f))
                    return;

                ClearGossipMenuFor(player);
                AddGossipItemFor(player, GOSSIP_ICON_CHAT, "No.",
                    GOSSIP_SENDER_MAIN, GOSSIP_ACTION_VOSS_NO);
                AddGossipItemFor(player, GOSSIP_ICON_CHAT, "What are your demands?",
                    GOSSIP_SENDER_MAIN, GOSSIP_ACTION_VOSS_DEMANDS);
                AddGossipItemFor(player, GOSSIP_ICON_CHAT, "Yes, we accept.",
                    GOSSIP_SENDER_MAIN, GOSSIP_ACTION_VOSS_YES);
                SendGossipMenuFor(player, NPC_TEXT_VOSS, me);
            });
        }
    }

    void ApplyHard()
    {
        Talk(SAY_VOSS_NO);
        _choice = VOSS_CHOICE_HARD;
        me->CastSpell(me, SPELL_ENRAGE, true);
        me->AddLootMode(2);
        me->SummonCreature(NPC_VOSS_BODYGUARD, me->GetRandomNearPosition(5.f),
            TEMPSUMMON_CORPSE_TIMED_DESPAWN, 30000);
        me->SummonCreature(NPC_VOSS_BODYGUARD, me->GetRandomNearPosition(5.f),
            TEMPSUMMON_CORPSE_TIMED_DESPAWN, 30000);
        if (_secondTalk)
            me->LoadEquipment(EQUIP_VOSS_KNUCKLES);
    }

    void ApplySoft()
    {
        Talk(SAY_VOSS_YES);
        _choice = VOSS_CHOICE_SOFT;
        me->ModifyHealth(-int32(me->CountPctFromCurHealth(20)));
        if (_secondTalk)
            me->LoadEquipment(EQUIP_VOSS_KNUCKLES);
    }

    void CloseGossipForPlayers()
    {
        if (Map* map = me->GetMap())
        {
            map->DoForAllPlayers([&](Player* player)
            {
                if (player && player->IsWithinDistInMap(me, 40.f))
                    CloseGossipMenuFor(player);
            });
        }
    }

    void ResumeCombat()
    {
        _negotiating = false;
        events.CancelEvent(EVENT_VOSS_NEGOTIATE_TIMEOUT);
        me->RemoveUnitFlag(UNIT_FLAG_PACIFIED);
        me->SetReactState(REACT_AGGRESSIVE);
        CloseGossipForPlayers();

        Unit* victim = ObjectAccessor::GetUnit(*me, _storedVictim);
        if (!victim || !victim->IsAlive())
            victim = me->SelectNearestPlayer(50.f);

        if (victim)
            AttackStart(victim);
    }
};

class boss_foreman_voss : public CreatureScript
{
public:
    boss_foreman_voss() : CreatureScript("boss_foreman_voss") { }

    CreatureAI* GetAI(Creature* creature) const override
    {
        return new boss_foreman_vossAI(creature);
    }

    bool OnGossipHello(Player* player, Creature* creature) override
    {
        if (!player || !creature || !creature->AI())
            return true;

        if (!creature->AI()->GetData(DATA_VOSS_IS_NEGOTIATING))
        {
            CloseGossipMenuFor(player);
            return true;
        }

        AddGossipItemFor(player, GOSSIP_ICON_CHAT, "No.",
            GOSSIP_SENDER_MAIN, GOSSIP_ACTION_VOSS_NO);
        AddGossipItemFor(player, GOSSIP_ICON_CHAT, "What are your demands?",
            GOSSIP_SENDER_MAIN, GOSSIP_ACTION_VOSS_DEMANDS);
        AddGossipItemFor(player, GOSSIP_ICON_CHAT, "Yes, we accept.",
            GOSSIP_SENDER_MAIN, GOSSIP_ACTION_VOSS_YES);
        SendGossipMenuFor(player, NPC_TEXT_VOSS, creature);
        return true;
    }

    bool OnGossipSelect(Player* player, Creature* creature, uint32 /*sender*/, uint32 action) override
    {
        if (!player || !creature || !creature->AI())
            return true;

        if (!creature->AI()->GetData(DATA_VOSS_IS_NEGOTIATING))
        {
            CloseGossipMenuFor(player);
            return true;
        }

        ClearGossipMenuFor(player);

        switch (action)
        {
            case GOSSIP_ACTION_VOSS_NO:
                creature->AI()->SetData(DATA_VOSS_NEGOTIATION, VOSS_CHOICE_HARD);
                CloseGossipMenuFor(player);
                break;
            case GOSSIP_ACTION_VOSS_YES:
                creature->AI()->SetData(DATA_VOSS_NEGOTIATION, VOSS_CHOICE_SOFT);
                CloseGossipMenuFor(player);
                break;
            case GOSSIP_ACTION_VOSS_DEMANDS:
                AddGossipItemFor(player, GOSSIP_ICON_CHAT, "No.",
                    GOSSIP_SENDER_MAIN, GOSSIP_ACTION_VOSS_NO);
                AddGossipItemFor(player, GOSSIP_ICON_CHAT, "Yes, we accept.",
                    GOSSIP_SENDER_MAIN, GOSSIP_ACTION_VOSS_YES);
                SendGossipMenuFor(player, NPC_TEXT_VOSS_DEMANDS, creature);
                break;
            default:
                break;
        }

        return true;
    }
};

void AddSC_boss_foreman_voss()
{
    new boss_foreman_voss();
}
