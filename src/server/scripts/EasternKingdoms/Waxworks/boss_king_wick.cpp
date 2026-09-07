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
#include "SpellAuras.h"
#include "SpellInfo.h"
#include "TemporarySummon.h"

struct boss_king_wick : public ScriptedAI
{
    boss_king_wick(Creature* creature) : ScriptedAI(creature), _summons(creature)
    {
        _wave66 = false;
        _wave33 = false;
    }

    void Reset() override
    {
        events.Reset();
        _summons.DespawnAll();
        DespawnCandles();
        _wave66 = false;
        _wave33 = false;
        _waxDummy.Clear();
        me->SetStandState(UNIT_STAND_STATE_SIT);
    }

    void JustEngagedWith(Unit* /*who*/) override
    {
        me->SetStandState(UNIT_STAND_STATE_STAND);
        Talk(SAY_WICK_AGGRO);
        SpawnCandles();
        events.ScheduleEvent(EVENT_WICK_FIREBALL, 3s);
        events.ScheduleEvent(EVENT_WICK_HOT_WAX, 20s);
        events.ScheduleEvent(EVENT_WICK_HEAD_BUTT, 20s, 25s);
        events.ScheduleEvent(EVENT_WICK_PIERCE, 30s);
    }

    void JustSummoned(Creature* summon) override
    {
        _summons.Summon(summon);
        uint32 const entry = summon->GetEntry();
        if (entry == NPC_WAX_DUMMY || entry == NPC_CANDLE_CART)
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
        Talk(SAY_WICK_DEATH);
        _summons.DespawnAll();
        DespawnCandles();
        if (GameObject* bar = me->FindNearestGameObject(GO_WICK_BARRICADE, 80.f))
            bar->Delete();
    }

    void SpellHit(Unit* /*caster*/, SpellInfo const* spellInfo) override
    {
        if (spellInfo && spellInfo->Id == SPELL_ENRAGE)
            Talk(SAY_WICK_STEAL);
    }

    void DamageTaken(Unit* /*attacker*/, uint32& /*damage*/, DamageEffectType /*type*/,
        SpellSchoolMask /*mask*/) override
    {
        if (!_wave66 && me->HealthBelowPct(66))
        {
            _wave66 = true;
            SummonCartWave();
        }

        if (!_wave33 && me->HealthBelowPct(33))
        {
            _wave33 = true;
            SummonCartWave();
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
                case EVENT_WICK_FIREBALL:
                    DoCastVictim(SPELL_FIREBALL);
                    if (me->HealthAbovePct(66))
                        events.ScheduleEvent(EVENT_WICK_FIREBALL_RANDOM, 1s);
                    events.ScheduleEvent(EVENT_WICK_FIREBALL, 3s);
                    break;
                case EVENT_WICK_FIREBALL_RANDOM:
                    if (Unit* target = SelectTarget(SelectTargetMethod::Random, 0, 40.f, true, false))
                        DoCast(target, SPELL_FIREBALL);
                    break;
                case EVENT_WICK_HOT_WAX:
                    if (Creature* dummy = me->SummonCreature(NPC_WAX_DUMMY, me->GetRandomNearPosition(4.f),
                        TEMPSUMMON_TIMED_DESPAWN, 15000))
                    {
                        _waxDummy = dummy->GetGUID();
                        events.ScheduleEvent(EVENT_WICK_WAX_NOVA, 6s);
                    }
                    events.ScheduleEvent(EVENT_WICK_HOT_WAX, 20s);
                    break;
                case EVENT_WICK_WAX_NOVA:
                    if (Creature* dummy = ObjectAccessor::GetCreature(*me, _waxDummy))
                        dummy->CastSpell(dummy, SPELL_FIRE_NOVA_SMALL, false);
                    break;
                case EVENT_WICK_HEAD_BUTT:
                    DoCastVictim(SPELL_HEAD_BUTT);
                    events.ScheduleEvent(EVENT_WICK_HEAD_BUTT, 20s, 25s);
                    break;
                case EVENT_WICK_PIERCE:
                    DoCastVictim(SPELL_PIERCE_ARMOR);
                    events.ScheduleEvent(EVENT_WICK_PIERCE, 30s);
                    break;
                default:
                    break;
            }
        }

        DoMeleeAttackIfReady();
    }

private:
    SummonList _summons;
    GuidVector _candleGuids;
    ObjectGuid _waxDummy;
    bool _wave66;
    bool _wave33;

    void SpawnCandles()
    {
        Position const left = { me->GetPositionX() + 4.f, me->GetPositionY() + 2.f, me->GetPositionZ(), 0.f };
        Position const right = { me->GetPositionX() - 4.f, me->GetPositionY() - 2.f, me->GetPositionZ(), 0.f };
        SummonCandle(left);
        SummonCandle(right);
    }

    void SummonCandle(Position const& pos)
    {
        if (GameObject* go = me->SummonGameObject(GO_WAX_CANDLE, pos.GetPositionX(), pos.GetPositionY(),
            pos.GetPositionZ(), 0.f, 0.f, 0.f, 0.f, 0.f, 300))
            _candleGuids.push_back(go->GetGUID());
    }

    void DespawnCandles()
    {
        for (ObjectGuid const& guid : _candleGuids)
            if (GameObject* go = ObjectAccessor::GetGameObject(*me, guid))
                go->Delete();

        _candleGuids.clear();
    }

    void SummonCartWave()
    {
        Talk(SAY_WICK_CART);
        me->SummonCreature(NPC_WICKWORKS_SCAMP, me->GetRandomNearPosition(6.f),
            TEMPSUMMON_CORPSE_TIMED_DESPAWN, 30000);
        me->SummonCreature(NPC_WICKWORKS_SCAMP, me->GetRandomNearPosition(6.f),
            TEMPSUMMON_CORPSE_TIMED_DESPAWN, 30000);
        me->SummonCreature(NPC_CANDLE_CART, me->GetRandomNearPosition(5.f),
            TEMPSUMMON_CORPSE_TIMED_DESPAWN, 45000);
    }
};

class go_waxworks_candle : public GameObjectScript
{
public:
    go_waxworks_candle() : GameObjectScript("go_waxworks_candle") { }

    bool OnGossipHello(Player* /*player*/, GameObject* go) override
    {
        if (!go)
            return true;

        if (Creature* wick = go->FindNearestCreature(NPC_KING_WICK, 40.f))
        {
            wick->CastSpell(wick, SPELL_ENRAGE, true);
            if (Aura* aura = wick->GetAura(SPELL_ENRAGE))
            {
                aura->SetMaxDuration(WAXWORKS_ENRAGE_MS);
                aura->SetDuration(WAXWORKS_ENRAGE_MS);
            }
        }

        return true;
    }
};

void AddSC_boss_king_wick()
{
    RegisterCreatureAI(boss_king_wick);
    new go_waxworks_candle();
}
