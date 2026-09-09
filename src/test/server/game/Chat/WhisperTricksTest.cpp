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

#include "WhisperTricks.h"
#include "gtest/gtest.h"

TEST(WhisperTricksTest, MatchesKnownAliases)
{
    EXPECT_TRUE(IsTricksOfTheTradeWhisper("tricks"));
    EXPECT_TRUE(IsTricksOfTheTradeWhisper("Tricks"));
    EXPECT_TRUE(IsTricksOfTheTradeWhisper("TRICKS"));
    EXPECT_TRUE(IsTricksOfTheTradeWhisper(" tot "));
    EXPECT_TRUE(IsTricksOfTheTradeWhisper("ToT!"));
    EXPECT_TRUE(IsTricksOfTheTradeWhisper("tricks of the trade"));
    EXPECT_TRUE(IsTricksOfTheTradeWhisper("Tricks of the Trade."));
}

TEST(WhisperTricksTest, RejectsUnrelatedWhispers)
{
    EXPECT_FALSE(IsTricksOfTheTradeWhisper(""));
    EXPECT_FALSE(IsTricksOfTheTradeWhisper("trick"));
    EXPECT_FALSE(IsTricksOfTheTradeWhisper("tricksy"));
    EXPECT_FALSE(IsTricksOfTheTradeWhisper("please tricks"));
    EXPECT_FALSE(IsTricksOfTheTradeWhisper("cast tricks"));
    EXPECT_FALSE(IsTricksOfTheTradeWhisper("follow"));
}
