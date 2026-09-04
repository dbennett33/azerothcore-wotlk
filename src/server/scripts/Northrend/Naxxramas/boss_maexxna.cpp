/*
 * This file is part of the AzerothCore Project. See AUTHORS file for Copyright information
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
 * more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program. If not, see <http://www.gnu.org/licenses/>.
 */

#include "CreatureScript.h"
#include "MotionMaster.h"
#include "PassiveAI.h"
#include "Player.h"
#include "ScriptedCreature.h"
#include "SpellAuraEffects.h"
#include "SpellScript.h"
#include "SpellScriptLoader.h"
#include "naxxramas.h"

enum Spells
{
    SPELL_WEB_SPRAY                     = 29484,
    SPELL_POISON_SHOCK                  = 28741,
    SPELL_NECROTIC_POISON               = 54121,
    SPELL_FRENZY                        = 54123,
    SPELL_WEB_WRAP_STUN                 = 28622,
    SPELL_WEB_WRAP_SUMMON               = 28627,
    SPELL_WEB_WRAP_KILL_WEBS            = 52512
};

enum Events
{
    EVENT_WEB_SPRAY                     = 1,
    EVENT_POISON_SHOCK                  = 2,
    EVENT_NECROTIC_POISON               = 3,
    EVENT_WEB_WRAP                      = 4,
    EVENT_HEALTH_CHECK                  = 5,
    EVENT_SUMMON_SPIDERLINGS            = 6
};

enum Emotes
{
    EMOTE_SPIDERS                       = 0,
    EMOTE_WEB_WRAP                      = 1,
    EMOTE_WEB_SPRAY                     = 2
};

enum Misc
{
    NPC_WEB_WRAP                        = 16486,
    NPC_MAEXXNA_SPIDERLING              = 17055
};

// Sniffed ledge positions (Z ~298-308). Z ~320 is inside the wall mesh and drops
// players into the void. KnockbackFrom is a client packet — playerbots never fly.
constexpr uint8 MAX_WRAP_POSITION = 7;
constexpr float WEB_WRAP_MOVE_SPEED = 20.0f;
const Position PosWrap[MAX_WRAP_POSITION] =
{
    {3453.818f, -3854.651f, 308.7581f, 4.362833f},
    {3535.042f, -3842.383f, 300.795f,  3.179324f},
    {3538.399f, -3846.088f, 299.964f,  4.310297f},
    {3548.464f, -3854.676f, 298.6075f, 4.546609f},
    {3557.663f, -3870.123f, 297.5027f, 3.756433f},
    {3560.546f, -3879.353f, 297.4843f, 2.508937f},
    {3562.535f, -3892.507f, 298.532f,  6.022466f}
};

struct WebTargetSelector
{
    WebTargetSelector(Unit* maexxna) : _maexxna(maexxna) {}
    bool operator()(Unit const* target) const
    {
        if (!target->IsPlayer()) // never web nonplayers (pets, guardians, etc.)
            return false;
        if (_maexxna->GetVictim() == target) // never target tank
            return false;
        if (target->HasAura(SPELL_WEB_WRAP_STUN)) // never target targets that are already webbed
            return false;
        return true;
    }

    private:
        Unit const* _maexxna;
};

class boss_maexxna : public CreatureScript
{
public:
    boss_maexxna() : CreatureScript("boss_maexxna") { }

    CreatureAI* GetAI(Creature* pCreature) const override
    {
        return GetNaxxramasAI<boss_maexxnaAI>(pCreature);
    }

    struct boss_maexxnaAI : public BossAI
    {
        explicit boss_maexxnaAI(Creature* c) : BossAI(c, BOSS_MAEXXNA)
        {}

        void Reset() override
        {
            BossAI::Reset();
            instance->DoRemoveAurasDueToSpellOnPlayers(SPELL_WEB_WRAP_STUN);
            instance->DoRemoveAurasDueToSpellOnPlayers(SPELL_WEB_WRAP_SUMMON);
        }

        bool IsInRoom()
        {
            if (me->GetExactDist(3486.6f, -3890.6f, 291.8f) > 100.0f)
            {
                EnterEvadeMode();
                return false;
            }
            return true;
        }

        void JustEngagedWith(Unit* who) override
        {
            BossAI::JustEngagedWith(who);
            me->SetInCombatWithZone();
            events.ScheduleEvent(EVENT_WEB_WRAP, 20s);
            events.ScheduleEvent(EVENT_WEB_SPRAY, 40s);
            events.ScheduleEvent(EVENT_POISON_SHOCK, 10s);
            events.ScheduleEvent(EVENT_NECROTIC_POISON, 5s);
            events.ScheduleEvent(EVENT_HEALTH_CHECK, 1s);
            events.ScheduleEvent(EVENT_SUMMON_SPIDERLINGS, 30s);
        }

        void JustSummoned(Creature* cr) override
        {
            if (cr->GetEntry() == NPC_MAEXXNA_SPIDERLING)
            {
                cr->SetInCombatWithZone();
                if (Unit* target = SelectTarget(SelectTargetMethod::Random, 0))
                {
                    cr->AI()->AttackStart(target);
                }
            }
            summons.Summon(cr);
        }

        void KilledUnit(Unit* who) override
        {
            if (who->IsPlayer())
                instance->StorePersistentData(PERSISTENT_DATA_IMMORTAL_FAIL, 1);
        }

        void DoCastWebWrap()
        {
            std::list<Unit*> targets;
            SelectTargetList(targets, RAID_MODE(1, 2), SelectTargetMethod::Random, 0, WebTargetSelector(me));
            if (targets.empty())
                return;

            int8 wrapPos = -1;
            for (Unit* target : targets)
            {
                if (wrapPos == -1)
                    wrapPos = urand(0, MAX_WRAP_POSITION - 1);
                else
                    wrapPos = (wrapPos + urand(1, MAX_WRAP_POSITION - 1)) % MAX_WRAP_POSITION;

                target->RemoveAurasDueToSpell(SPELL_WEB_SPRAY);
                if (Creature* wrap = DoSummon(NPC_WEB_WRAP, PosWrap[wrapPos], 70 * IN_MILLISECONDS, TEMPSUMMON_TIMED_DESPAWN))
                {
                    wrap->AI()->SetGUID(target->GetGUID());
                    // Server-side jump so bots (no client knockback physics) land on the ledge.
                    target->GetMotionMaster()->MoveJump(PosWrap[wrapPos], WEB_WRAP_MOVE_SPEED, WEB_WRAP_MOVE_SPEED);
                }
            }
        }

        void UpdateAI(uint32 diff) override
        {
            if (!IsInRoom())
                return;

            if (!UpdateVictim())
                return;

            events.Update(diff);
            if (me->HasUnitState(UNIT_STATE_CASTING))
                return;

            switch (events.ExecuteEvent())
            {
                case EVENT_WEB_SPRAY:
                    Talk(EMOTE_WEB_SPRAY);
                    me->CastSpell(me, SPELL_WEB_SPRAY, true);
                    events.Repeat(40s);
                    break;
                case EVENT_POISON_SHOCK:
                    me->CastSpell(me->GetVictim(), SPELL_POISON_SHOCK, false);
                    events.Repeat(10s);
                    break;
                case EVENT_NECROTIC_POISON:
                    me->CastSpell(me->GetVictim(), SPELL_NECROTIC_POISON, false);
                    events.Repeat(30s);
                    break;
                case EVENT_SUMMON_SPIDERLINGS:
                    Talk(EMOTE_SPIDERS);
                    for (uint8 i = 0; i < 8; ++i)
                    {
                        me->SummonCreature(NPC_MAEXXNA_SPIDERLING, me->GetPositionX(), me->GetPositionY(), me->GetPositionZ(), me->GetOrientation());
                    }
                    events.Repeat(40s);
                    break;
                case EVENT_HEALTH_CHECK:
                    if (me->GetHealthPct() < 30)
                    {
                        me->CastSpell(me, SPELL_FRENZY, true);
                        break;
                    }
                    events.Repeat(1s);
                    break;
                case EVENT_WEB_WRAP:
                    Talk(EMOTE_WEB_WRAP);
                    DoCastWebWrap();
                    events.Repeat(40s);
                    break;
            }
            DoMeleeAttackIfReady();
        }
    };
};

class boss_maexxna_webwrap : public CreatureScript
{
public:
    boss_maexxna_webwrap() : CreatureScript("boss_maexxna_webwrap") { }

    CreatureAI* GetAI(Creature* pCreature) const override
    {
        return GetNaxxramasAI<boss_maexxna_webwrapAI>(pCreature);
    }

    struct boss_maexxna_webwrapAI : public NullCreatureAI
    {
        explicit boss_maexxna_webwrapAI(Creature* c) : NullCreatureAI(c) { }

        ObjectGuid victimGUID;

        void SetGUID(ObjectGuid const& guid, int32 /*id*/) override
        {
            if (!guid)
                return;

            victimGUID = guid;
            if (Unit* victim = ObjectAccessor::GetUnit(*me, victimGUID))
                victim->CastSpell(victim, SPELL_WEB_WRAP_STUN, true);
        }

        void JustDied(Unit* /*killer*/) override
        {
            if (victimGUID)
            {
                if (Unit* victim = ObjectAccessor::GetUnit(*me, victimGUID))
                {
                    if (victim->IsAlive())
                    {
                        victim->RemoveAurasDueToSpell(SPELL_WEB_WRAP_STUN);
                        victim->RemoveAurasDueToSpell(SPELL_WEB_WRAP_SUMMON);
                    }
                }
            }
            me->DespawnOrUnsummon(5s);
        }

        void UpdateAI(uint32 /*diff*/) override
        {
            if (!victimGUID)
                return;

            if (Unit* victim = ObjectAccessor::GetUnit(*me, victimGUID))
            {
                if (!victim->IsAlive())
                    me->CastSpell(me, SPELL_WEB_WRAP_KILL_WEBS, true);
            }
        }
    };
};

class spell_web_wrap_damage : public AuraScript
{
public:
    PrepareAuraScript(spell_web_wrap_damage);

    bool Validate(SpellInfo const* /*spellInfo*/) override
    {
        return ValidateSpellInfo({ SPELL_WEB_WRAP_SUMMON });
    }

    void OnPeriodic(AuraEffect const* /*aurEff*/)
    {
        // Wrap NPC is summoned at the wall by Maexxna. Do not spawn a second cocoon on the player.
    }

    void Register() override
    {
        OnEffectPeriodic += AuraEffectPeriodicFn(spell_web_wrap_damage::OnPeriodic, EFFECT_1, SPELL_AURA_PERIODIC_DAMAGE);
    }
};

void AddSC_boss_maexxna()
{
    new boss_maexxna();
    new boss_maexxna_webwrap();
    RegisterSpellScript(spell_web_wrap_damage);
}
