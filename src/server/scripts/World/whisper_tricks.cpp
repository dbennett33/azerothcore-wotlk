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

#include "Player.h"
#include "PlayerScript.h"
#include "SharedDefines.h"
#include "WhisperTricks.h"
#include "WorldSession.h"

enum WhisperTricksSpells
{
    SPELL_WHISPER_TRICKS_OF_THE_TRADE = 57934
};

namespace
{
    void TellRequester(Player* rogue, Player* requester, std::string_view text)
    {
        rogue->Whisper(text, LANG_UNIVERSAL, requester);
    }

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

    // Returns true when the whisper was a tricks request to an eligible rogue bot.
    bool HandleTricksWhisper(Player* requester, Player* rogue)
    {
        if (!requester || !rogue || requester == rogue)
            return false;

        WorldSession const* session = rogue->GetSession();
        if (!session || !session->IsBot())
            return false;

        if (!rogue->IsClass(CLASS_ROGUE) || !requester->IsInSameRaidWith(rogue))
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

        // 57934's dummy aura sits on the rogue. If explicit targeting drops the
        // unit target, Spell::InitExplicitTargets falls back to GetTarget() —
        // the mob or tank the bot is on — so the 15% buff (57933) never hits
        // the whisperer. Playerbots SetSelection before every real ToT cast.
        ObjectGuid const oldSel = rogue->GetTarget();
        rogue->SetSelection(requester->GetGUID());
        rogue->CastStop();
        SpellCastResult const result = rogue->CastSpell(requester, SPELL_WHISPER_TRICKS_OF_THE_TRADE);
        if (oldSel)
            rogue->SetSelection(oldSel);

        if (result != SPELL_CAST_OK)
            TellRequester(rogue, requester, TricksCastFailReason(result));
        else
            TellRequester(rogue, requester, "Tricks of the Trade is on you.");

        return true;
    }
}

class WhisperTricksOfTheTradeScript : public PlayerScript
{
public:
    WhisperTricksOfTheTradeScript()
        : PlayerScript("WhisperTricksOfTheTradeScript", { PLAYERHOOK_CAN_PLAYER_USE_PRIVATE_CHAT })
    {
    }

    bool OnPlayerCanUseChat(Player* player, uint32 /*type*/, uint32 language, std::string& msg, Player* receiver) override
    {
        if (language == LANG_ADDON || !IsTricksOfTheTradeWhisper(msg))
            return true;

        // Swallow handled whispers so playerbots does not treat "tricks" as an unknown command.
        return !HandleTricksWhisper(player, receiver);
    }
};

void AddSC_whisper_tricks()
{
    new WhisperTricksOfTheTradeScript();
}
