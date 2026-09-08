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

#ifndef AZEROTHCORE_WHISPER_TRICKS_H
#define AZEROTHCORE_WHISPER_TRICKS_H

#include <cctype>
#include <string>
#include <string_view>

enum class TricksWhisperCommand
{
    None,
    Cast,
    EnableHold,
    DisableHold
};

// Whisper aliases that request Tricks of the Trade from a grouped rogue bot.
inline std::string NormalizeTricksWhisper(std::string_view text)
{
    std::string out;
    out.reserve(text.size());
    for (unsigned char const ch : text)
    {
        if (std::isspace(ch) && out.empty())
            continue;

        out.push_back(static_cast<char>(std::tolower(ch)));
    }

    while (!out.empty())
    {
        unsigned char const last = static_cast<unsigned char>(out.back());
        if (std::isspace(last) || last == '!' || last == '.' || last == '?')
            out.pop_back();
        else
            break;
    }

    return out;
}

inline TricksWhisperCommand ParseTricksWhisper(std::string_view text)
{
    std::string const normalized = NormalizeTricksWhisper(text);
    if (normalized == "tricks" || normalized == "tot" || normalized == "tricks of the trade")
        return TricksWhisperCommand::Cast;
    if (normalized == "tricks-whisper" || normalized == "tricks whisper" ||
        normalized == "co +tricks-whisper" || normalized == "+tricks-whisper")
        return TricksWhisperCommand::EnableHold;
    if (normalized == "co -tricks-whisper" || normalized == "-tricks-whisper" ||
        normalized == "tricks-whisper off")
        return TricksWhisperCommand::DisableHold;
    return TricksWhisperCommand::None;
}

inline bool IsTricksOfTheTradeWhisper(std::string_view text)
{
    return ParseTricksWhisper(text) == TricksWhisperCommand::Cast;
}

#endif
