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

#include "AllSpellScript.h"
#include "Player.h"
#include "PlayerScript.h"
#include "SharedDefines.h"
#include "Spell.h"
#include "SpellDefines.h"
#include "SpellInfo.h"
#include "WhisperTricks.h"
#include "WorldSession.h"
#include <mutex>
#include <unordered_set>

enum WhisperTricksSpells
{
    SPELL_WHISPER_TRICKS_OF_THE_TRADE = 57934
};

namespace
{
    std::mutex sTricksWhisperMutex;
    std::unordered_set<ObjectGuid> sHoldTankTricks;
    std::unordered_set<ObjectGuid> sWhisperCastsInFlight;

    void TellRequester(Player* rogue, Player* requester, std::string_view text)
    {
        rogue->Whisper(text, LANG_UNIVERSAL, requester);
    }

    bool IsEligibleRogueBot(Player* requester, Player* rogue, bool requireSameGroup)
    {
        if (!requester || !rogue || requester == rogue)
            return false;

        WorldSession const* session = rogue->GetSession();
        if (!session || !session->IsBot())
            return false;

        if (!rogue->IsClass(CLASS_ROGUE))
            return false;

        if (requireSameGroup && !requester->IsInSameRaidWith(rogue))
            return false;

        return true;
    }

    bool IsHoldingTankTricks(ObjectGuid const& guid)
    {
        std::lock_guard lock(sTricksWhisperMutex);
        return sHoldTankTricks.find(guid) != sHoldTankTricks.end();
    }

    void SetHoldingTankTricks(ObjectGuid const& guid, bool hold)
    {
        std::lock_guard lock(sTricksWhisperMutex);
        if (hold)
            sHoldTankTricks.insert(guid);
        else
            sHoldTankTricks.erase(guid);
    }

    void ClearTricksWhisperState(ObjectGuid const& guid)
    {
        std::lock_guard lock(sTricksWhisperMutex);
        sHoldTankTricks.erase(guid);
        sWhisperCastsInFlight.erase(guid);
    }

    class WhisperTricksCastGuard
    {
    public:
        explicit WhisperTricksCastGuard(ObjectGuid const& guid) : _guid(guid)
        {
            std::lock_guard lock(sTricksWhisperMutex);
            sWhisperCastsInFlight.insert(_guid);
        }

        ~WhisperTricksCastGuard()
        {
            std::lock_guard lock(sTricksWhisperMutex);
            sWhisperCastsInFlight.erase(_guid);
        }

    private:
        ObjectGuid _guid;
    };

    char const* TricksCastFailReason(SpellCastResult result)
    {
        switch (result)
        {
            case SPELL_FAILED_OUT_OF_RANGE:
                return "You're too far away for Tricks of the Trade.";
            case SPELL_FAILED_NOT_READY:
            case SPELL_FAILED_TRY_AGAIN:
                return "Tricks of the Trade is on cooldown.";
            case SPELL_FAILED_LINE_OF_SIGHT:
                return "I don't have line of sight for Tricks of the Trade.";
            case SPELL_FAILED_CASTER_DEAD:
                return "I can't cast Tricks of the Trade while dead.";
            case SPELL_FAILED_NOT_KNOWN:
                return "I don't know Tricks of the Trade yet.";
            default:
                return "I couldn't cast Tricks of the Trade.";
        }
    }

    bool HandleTricksHoldToggle(Player* requester, Player* rogue, bool enable)
    {
        if (!IsEligibleRogueBot(requester, rogue, false))
            return false;

        SetHoldingTankTricks(rogue->GetGUID(), enable);
        if (enable)
            TellRequester(rogue, requester, "I'll hold Tricks of the Trade for your whisper.");
        else
            TellRequester(rogue, requester, "I'll put Tricks of the Trade back on the tank.");
        return true;
    }

    // Returns true when the whisper was a tricks request to an eligible rogue bot.
    bool HandleTricksWhisper(Player* requester, Player* rogue)
    {
        if (!IsEligibleRogueBot(requester, rogue, true))
            return false;

        if (!rogue->IsAlive())
        {
            TellRequester(rogue, requester, "I can't cast Tricks of the Trade while dead.");
            return true;
        }

        if (!requester->IsAlive())
        {
            TellRequester(rogue, requester, "I can't put Tricks of the Trade on you while you're dead.");
            return true;
        }

        if (!rogue->HasSpell(SPELL_WHISPER_TRICKS_OF_THE_TRADE))
        {
            TellRequester(rogue, requester, "I don't know Tricks of the Trade yet.");
            return true;
        }

        WhisperTricksCastGuard allowCast(rogue->GetGUID());
        rogue->CastStop();
        SpellCastResult const result = rogue->CastSpell(requester, SPELL_WHISPER_TRICKS_OF_THE_TRADE,
            TriggerCastFlags(TRIGGERED_IGNORE_GCD | TRIGGERED_IGNORE_CAST_IN_PROGRESS | TRIGGERED_IGNORE_SET_FACING));
        if (result != SPELL_CAST_OK)
            TellRequester(rogue, requester, TricksCastFailReason(result));

        return true;
    }
}

class WhisperTricksOfTheTradeScript : public PlayerScript
{
public:
    WhisperTricksOfTheTradeScript()
        : PlayerScript("WhisperTricksOfTheTradeScript",
            { PLAYERHOOK_CAN_PLAYER_USE_PRIVATE_CHAT, PLAYERHOOK_ON_LOGOUT })
    {
    }

    bool OnPlayerCanUseChat(Player* player, uint32 /*type*/, uint32 language, std::string& msg, Player* receiver) override
    {
        if (language == LANG_ADDON)
            return true;

        switch (ParseTricksWhisper(msg))
        {
            case TricksWhisperCommand::Cast:
                return !HandleTricksWhisper(player, receiver);
            case TricksWhisperCommand::EnableHold:
                return !HandleTricksHoldToggle(player, receiver, true);
            case TricksWhisperCommand::DisableHold:
                return !HandleTricksHoldToggle(player, receiver, false);
            default:
                return true;
        }
    }

    void OnPlayerLogout(Player* player) override
    {
        if (player)
            ClearTricksWhisperState(player->GetGUID());
    }
};

class WhisperTricksOfTheTradeSpellScript : public AllSpellScript
{
public:
    WhisperTricksOfTheTradeSpellScript()
        : AllSpellScript("WhisperTricksOfTheTradeSpellScript", { ALLSPELLHOOK_ON_SPELL_CHECK_CAST })
    {
    }

    void OnSpellCheckCast(Spell* spell, bool /*strict*/, SpellCastResult& res) override
    {
        if (res != SPELL_CAST_OK || !spell)
            return;

        SpellInfo const* info = spell->GetSpellInfo();
        if (!info || info->Id != SPELL_WHISPER_TRICKS_OF_THE_TRADE)
            return;

        Unit* caster = spell->GetCaster();
        if (!caster || !caster->IsPlayer())
            return;

        ObjectGuid const guid = caster->GetGUID();
        std::lock_guard lock(sTricksWhisperMutex);
        if (sHoldTankTricks.find(guid) == sHoldTankTricks.end())
            return;
        if (sWhisperCastsInFlight.find(guid) != sWhisperCastsInFlight.end())
            return;

        res = SPELL_FAILED_DONT_REPORT;
    }
};

void AddSC_whisper_tricks()
{
    new WhisperTricksOfTheTradeScript();
    new WhisperTricksOfTheTradeSpellScript();
}
