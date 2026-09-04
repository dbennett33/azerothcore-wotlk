-- The Drowned Belfry 5-man (map 900). Custom ids 9000400-9000599 / guids 9001000-9001499.
-- Entrance: Darkshire graveyard road (walk-through veil). New Map.dbc Directory DrownedBelfry.

DELETE FROM `map_dbc` WHERE `ID` = 900;
INSERT INTO `map_dbc` (`ID`, `Directory`, `InstanceType`, `Flags`, `PVP`, `MapName_Lang_enUS`,
 `MapName_Lang_Mask`, `AreaTableID`, `LoadingScreenID`, `MinimapIconScale`, `CorpseMapID`,
 `CorpseX`, `CorpseY`, `TimeOfDayOverride`, `ExpansionID`, `RaidOffset`, `MaxPlayers`) VALUES
(900, 'DrownedBelfry', 1, 0, 0, 'The Drowned Belfry', 16712190, 9000, 15, 1, 0, -10740, -1189.67, -1, 0, 0, 5);

DELETE FROM `mapdifficulty_dbc` WHERE `ID` = 9000900;
INSERT INTO `mapdifficulty_dbc` (`ID`, `MapID`, `Difficulty`, `Message_Lang_enUS`, `Message_Lang_Mask`,
 `RaidDuration`, `MaxPlayers`, `Difficultystring`) VALUES
(9000900, 900, 0, '', 16712190, 0, 5, '');

DELETE FROM `areatable_dbc` WHERE `ID` = 9000;
INSERT INTO `areatable_dbc` (`ID`, `ContinentID`, `ParentAreaID`, `AreaBit`, `Flags`, `ExplorationLevel`,
 `AreaName_Lang_enUS`, `AreaName_Lang_Mask`, `FactionGroupMask`) VALUES
(9000, 900, 0, 3990, 0, 22, 'The Drowned Belfry', 16712190, 0);

DELETE FROM `instance_template` WHERE `map` = 900;
INSERT INTO `instance_template` (`map`, `parent`, `script`, `allowMount`) VALUES
(900, 0, 'instance_drowned_belfry', 0);

DELETE FROM `dungeon_access_template` WHERE `id` = 124;
INSERT INTO `dungeon_access_template` (`id`, `map_id`, `difficulty`, `min_level`, `max_level`,
 `min_avg_item_level`, `comment`) VALUES
(124, 900, 0, 18, 0, 0, 'The Drowned Belfry');

DELETE FROM `graveyard_zone` WHERE `GhostZone` = 9000;
INSERT INTO `graveyard_zone` (`ID`, `GhostZone`, `Faction`, `Comment`) VALUES
(3, 9000, 0, 'The Drowned Belfry -> Darkshire');

DELETE FROM `creature_template` WHERE `entry` = 9000400;
INSERT INTO `creature_template` (`entry`, `name`, `subname`, `minlevel`, `maxlevel`, `faction`,
 `npcflag`, `gossip_menu_id`, `speed_walk`, `speed_run`, `detection_range`, `rank`,
 `DamageModifier`, `BaseAttackTime`, `RangeAttackTime`, `unit_class`, `unit_flags`,
 `unit_flags2`, `type`, `lootid`, `mingold`, `maxgold`, `AIName`, `HealthModifier`, `ManaModifier`,
 `RegenHealth`, `flags_extra`, `ScriptName`, `VerifiedBuild`) VALUES
(9000400, 'Keeper Marrow', 'The Drowned Belfry', 24, 24, 12, 3, 9000400, 1, 1.42857, 18, 0, 1, 2000, 2000, 1, 512, 2048, 7, 0, 0, 0, '', 1.5, 1, 1, 0, '', 0);

DELETE FROM `creature_template_model` WHERE `CreatureID` = 9000400;
INSERT INTO `creature_template_model` (`CreatureID`, `Idx`, `CreatureDisplayID`, `DisplayScale`, `Probability`, `VerifiedBuild`) VALUES
(9000400, 0, 2381, 1, 1, 0);

DELETE FROM `npc_text` WHERE `ID` = 9000400;
INSERT INTO `npc_text` (`ID`, `text0_0`, `text0_1`, `Probability0`) VALUES
(9000400, 'The bell cracked in a storm nobody remembers. The tide came in and did not leave.$B$BWhelm still walks the crypt. Sister Brine keeps the sacristy. Toll will not let the well go quiet.$B$BWalk back the way you entered to return to Darkshire.', '', 1);

DELETE FROM `gossip_menu` WHERE `MenuID` = 9000400;
INSERT INTO `gossip_menu` (`MenuID`, `TextID`) VALUES
(9000400, 9000400);

DELETE FROM `creature` WHERE `guid` = 9001000;
INSERT INTO `creature` (`guid`, `id`, `map`, `spawnMask`, `phaseMask`, `equipment_id`,
 `position_x`, `position_y`, `position_z`, `orientation`, `spawntimesecs`,
 `wander_distance`, `curhealth`, `curmana`, `MovementType`, `Comment`) VALUES
(9001000, 9000400, 900, 1, 1, 0, -14, 2, 0.2, 0, 120, 0, 1, 0, 0, 'Keeper Marrow porch');

DELETE FROM `gameobject_template` WHERE `entry` IN (9000410, 9000411);
INSERT INTO `gameobject_template` (`entry`, `type`, `displayId`, `name`, `size`, `Data0`, `Data3`,
 `AIName`, `ScriptName`, `VerifiedBuild`) VALUES
(9000410, 5, 1327, 'The Drowned Belfry', 8, 0, 0, '', 'go_drowned_belfry_entrance', 0),
(9000411, 5, 1327, 'Belfry Exit', 4, 0, 0, '', 'go_drowned_belfry_exit', 0);

DELETE FROM `gameobject_template_addon` WHERE `entry` IN (9000410, 9000411);
INSERT INTO `gameobject_template_addon` (`entry`, `faction`, `flags`, `mingold`, `maxgold`) VALUES
(9000410, 0, 16, 0, 0),
(9000411, 0, 16, 0, 0);

-- ori 0 (east, toward Darkshire). Quaternion: rot2 = sin(0) = 0, rot3 = cos(0) = 1.
DELETE FROM `gameobject` WHERE `guid` IN (9001001, 9001002);
INSERT INTO `gameobject` (`guid`, `id`, `map`, `spawnMask`, `phaseMask`, `position_x`,
 `position_y`, `position_z`, `orientation`, `rotation0`, `rotation1`, `rotation2`, `rotation3`,
 `spawntimesecs`, `animprogress`, `state`, `Comment`) VALUES
(9001001, 9000410, 0, 1, 1, -10740, -1189.67, 32.8, 0, 0, 0, 0, 1, 180, 100, 1, 'Belfry Darkshire GY road'),
(9001002, 9000411, 900, 1, 1, -8, 0, 0.2, 0, 0, 0, 0, 1, 180, 100, 1, 'Belfry exit behind porch');

DELETE FROM `game_tele` WHERE `id` IN (9000070, 9000071) OR `name` IN ('belfry', 'belfry_plaza');
INSERT INTO `game_tele` (`id`, `position_x`, `position_y`, `position_z`, `orientation`, `map`, `name`) VALUES
(9000070, -16, 0, 0.2, 3.1416, 900, 'belfry'),
(9000071, -10573, -1182.51, 28.0148, 0.309, 0, 'belfry_plaza');

DELETE FROM `creature_template` WHERE `entry` BETWEEN 9000401 AND 9000409;
INSERT INTO `creature_template` (`entry`, `name`, `subname`, `minlevel`, `maxlevel`, `faction`,
 `npcflag`, `gossip_menu_id`, `speed_walk`, `speed_run`, `detection_range`, `rank`,
 `DamageModifier`, `BaseAttackTime`, `RangeAttackTime`, `unit_class`, `unit_flags`,
 `unit_flags2`, `type`, `lootid`, `mingold`, `maxgold`, `AIName`, `HealthModifier`, `ManaModifier`,
 `RegenHealth`, `flags_extra`, `ScriptName`, `VerifiedBuild`) VALUES
(9000401, 'Drowned Parishioner', 'The Drowned Belfry', 21, 22, 14, 0, 0, 1, 1.14286, 14, 1, 1.5, 2000, 2000, 1, 0, 2048, 6, 9000401, 35, 70, 'SmartAI', 2.5, 1, 1, 0, '', 0),
(9000402, 'Tideborn Murloc', 'The Drowned Belfry', 21, 22, 14, 0, 0, 1, 1.14286, 14, 1, 1.45, 2000, 2000, 8, 0, 2048, 7, 9000402, 32, 64, 'SmartAI', 2.4, 2, 1, 0, '', 0),
(9000403, 'Brine Acolyte', 'The Drowned Belfry', 22, 23, 14, 0, 0, 1, 1.14286, 10, 1, 1.45, 2000, 2000, 2, 0, 2048, 7, 9000403, 38, 72, 'SmartAI', 2.5, 2, 1, 0, '', 0),
(9000404, 'Drowned Sailor', 'The Drowned Belfry', 22, 23, 14, 0, 0, 1, 1.19048, 14, 1, 1.55, 2000, 2000, 1, 0, 2048, 7, 9000404, 40, 80, 'SmartAI', 2.6, 1, 1, 0, '', 0),
(9000405, 'Bell Attendant', 'The Drowned Belfry', 23, 23, 14, 0, 0, 1, 1.14286, 14, 1, 1.6, 2000, 2000, 1, 0, 2048, 6, 9000405, 42, 84, 'SmartAI', 2.7, 1, 1, 0, '', 0),
(9000406, 'Sister Brine', 'Cantor of the Tide', 25, 25, 14, 0, 0, 1, 1.14286, 16, 1, 2.0, 2000, 2000, 8, 0, 2048, 7, 9000406, 180, 280, '', 6.2, 3, 1, 0, 'boss_sister_brine', 0),
(9000407, 'Captain Whelm', 'The Last Watch', 24, 24, 14, 0, 0, 1, 1.14286, 16, 1, 2.1, 2000, 2000, 1, 0, 2048, 7, 9000407, 160, 260, '', 6.5, 1, 1, 0, 'boss_captain_whelm', 0),
(9000408, 'Toll', 'The Bellkeeper', 26, 26, 14, 0, 0, 1, 1.14286, 16, 1, 2.3, 2000, 2000, 1, 0, 2048, 6, 9000408, 220, 340, '', 7.5, 1, 1, 0, 'boss_toll_the_bellkeeper', 0),
(9000409, 'Brine Echo', '', 1, 1, 14, 0, 0, 1, 1, 1, 0, 1, 2000, 2000, 1, 768, 0, 10, 0, 0, 0, '', 0.1, 1, 1, 128, '', 0);

DELETE FROM `creature_template_model` WHERE `CreatureID` BETWEEN 9000401 AND 9000409;
INSERT INTO `creature_template_model` (`CreatureID`, `Idx`, `CreatureDisplayID`, `DisplayScale`, `Probability`, `VerifiedBuild`) VALUES
(9000401, 0, 322, 1, 1, 0),
(9000402, 0, 476, 1, 1, 0),
(9000403, 0, 2604, 1, 1, 0),
(9000404, 0, 2344, 1, 1, 0),
(9000405, 0, 200, 1.1, 1, 0),
(9000406, 0, 608, 1.25, 1, 0),
(9000407, 0, 2349, 1.3, 1, 0),
(9000408, 0, 200, 1.55, 1, 0),
(9000409, 0, 11686, 1, 1, 0);

DELETE FROM `creature_equip_template` WHERE `CreatureID` IN (9000403, 9000404, 9000406, 9000407, 9000408);
INSERT INTO `creature_equip_template` (`CreatureID`, `ID`, `ItemID1`, `ItemID2`, `ItemID3`, `VerifiedBuild`) VALUES
(9000403, 1, 2176, 0, 0, 0),
(9000404, 1, 1896, 0, 0, 0),
(9000406, 1, 2176, 0, 0, 0),
(9000407, 1, 1899, 0, 0, 0),
(9000408, 1, 1812, 0, 0, 0);

UPDATE `creature_template` SET `flags_extra` = `flags_extra` | 536870912
 WHERE `entry` BETWEEN 9000401 AND 9000408;

DELETE FROM `gameobject_template` WHERE `entry` BETWEEN 9000412 AND 9000424;
INSERT INTO `gameobject_template` (`entry`, `type`, `displayId`, `name`, `size`, `Data0`, `Data3`,
 `AIName`, `ScriptName`, `VerifiedBuild`) VALUES
(9000412, 5, 6038, 'Belfry Lantern', 1, 0, 0, '', '', 0),
(9000413, 5, 201, 'Belfry Brazier', 1, 0, 0, '', '', 0),
(9000414, 5, 100, 'Belfry Candle', 1, 0, 0, '', '', 0),
(9000415, 5, 4152, 'Red Ritual Candle', 2.8, 0, 0, '', '', 0),
(9000416, 5, 6364, 'Tall Belfry Candle', 2.3, 0, 0, '', '', 0),
(9000417, 5, 328, 'Tide Altar', 0.9, 0, 0, '', '', 0),
(9000418, 5, 31, 'Salt Crate', 1, 0, 0, '', '', 0),
(9000419, 5, 201, 'Cracked Bell', 2.2, 0, 0, '', '', 0),
(9000420, 5, 6412, 'Salt-Stained Notice', 1, 0, 0, '', '', 0),
(9000421, 5, 6364, 'Chapel Candelabra', 1.6, 0, 0, '', '', 0),
(9000422, 5, 201, 'Great Tide Brazier', 1.8, 0, 0, '', '', 0),
(9000423, 5, 328, 'Belfry Arch', 1.4, 0, 0, '', '', 0),
(9000424, 5, 32, 'Brine Barrel', 1, 0, 0, '', '', 0);

DELETE FROM `gameobject_template_addon` WHERE `entry` BETWEEN 9000412 AND 9000424;
INSERT INTO `gameobject_template_addon` (`entry`, `faction`, `flags`, `mingold`, `maxgold`) VALUES
(9000412, 0, 0, 0, 0),
(9000413, 0, 0, 0, 0),
(9000414, 0, 0, 0, 0),
(9000415, 0, 0, 0, 0),
(9000416, 0, 0, 0, 0),
(9000417, 0, 0, 0, 0),
(9000418, 0, 0, 0, 0),
(9000419, 0, 0, 0, 0),
(9000420, 0, 0, 0, 0),
(9000421, 0, 0, 0, 0),
(9000422, 0, 0, 0, 0),
(9000423, 0, 0, 0, 0),
(9000424, 0, 0, 0, 0);

DELETE FROM `item_template` WHERE `entry` BETWEEN 9000430 AND 9000459;
INSERT INTO `item_template` (`entry`, `class`, `subclass`, `SoundOverrideSubclass`, `name`, `displayid`,
 `Quality`, `Flags`, `BuyCount`, `BuyPrice`, `SellPrice`, `InventoryType`, `AllowableClass`,
 `AllowableRace`, `ItemLevel`, `RequiredLevel`, `bonding`, `MaxDurability`, `armor`,
 `stat_type1`, `stat_value1`, `stat_type2`, `stat_value2`, `stat_type3`, `stat_value3`,
 `dmg_min1`, `dmg_max1`, `delay`) VALUES
(9000430, 15, 0, -1, 'Salt-Crusted Hymnal', 1093, 0, 0, 5, 22, 5, 0, -1, -1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(9000431, 15, 0, -1, 'Cracked Bell Shard', 6677, 0, 0, 5, 18, 4, 0, -1, -1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(9000432, 15, 0, -1, 'Brine-Soaked Ration', 6348, 0, 0, 5, 14, 3, 0, -1, -1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(9000433, 15, 0, -1, 'Tide-Worn Rosary', 2207, 0, 0, 5, 16, 4, 0, -1, -1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(9000434, 15, 0, -1, 'Murloc Scale Scrap', 6677, 0, 0, 5, 12, 3, 0, -1, -1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(9000435, 15, 0, -1, 'Sextant Without a Sea', 1093, 0, 0, 5, 20, 5, 0, -1, -1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(9000436, 4, 3, -1, 'Saltwake Mail Leggings', 9738, 2, 0, 1, 2400, 480, 7, -1, -1, 24, 0, 1, 60, 148, 4, 6, 7, 4, 0, 0, 0, 0, 0),
(9000437, 4, 2, -1, 'Choir-Leather Tunic', 11368, 2, 0, 1, 2100, 420, 5, -1, -1, 24, 0, 1, 70, 86, 7, 5, 3, 3, 0, 0, 0, 0, 0),
(9000438, 2, 10, -1, 'Hymnal Staff', 10654, 2, 0, 1, 4800, 960, 17, -1, -1, 24, 0, 1, 60, 0, 5, 6, 7, 4, 0, 0, 28, 42, 2700),
(9000439, 4, 2, -1, 'Brinewrap Gloves', 14536, 2, 0, 1, 820, 164, 10, -1, -1, 23, 0, 1, 35, 46, 5, 4, 7, 3, 0, 0, 0, 0, 0),
(9000440, 4, 1, -1, 'Cantor''s Cowl', 15290, 2, 0, 1, 900, 180, 1, -1, -1, 23, 0, 1, 45, 28, 5, 5, 7, 4, 0, 0, 0, 0, 0),
(9000441, 4, 2, -1, 'Bellwell Treads', 16980, 2, 0, 1, 860, 172, 8, -1, -1, 23, 0, 1, 40, 52, 7, 4, 4, 3, 0, 0, 0, 0, 0),
(9000442, 2, 4, -1, 'Whelm''s Belaying Pin', 8575, 2, 0, 1, 2600, 520, 21, -1, -1, 23, 0, 1, 50, 0, 4, 5, 7, 3, 0, 0, 18, 32, 2300),
(9000443, 2, 15, -1, 'Choir Shiv', 6442, 2, 0, 1, 2200, 440, 13, -1, -1, 22, 0, 1, 40, 0, 3, 4, 7, 3, 0, 0, 12, 22, 1600),
(9000450, 2, 8, -1, 'Tide-Crack Claymore', 20174, 4, 0, 1, 18600, 3720, 17, 1, -1, 34, 18, 1, 95, 0, 4, 16, 7, 15, 0, 0, 58, 88, 3300),
(9000451, 2, 5, -1, 'Sentence of the Bell', 19610, 4, 0, 1, 18600, 3720, 17, 2, -1, 34, 18, 1, 95, 0, 4, 15, 7, 16, 5, 12, 64, 96, 3500),
(9000452, 2, 1, -1, 'Saltwake Reaver', 28804, 4, 0, 1, 18600, 3720, 17, 4, -1, 34, 18, 1, 95, 0, 3, 16, 7, 15, 0, 0, 54, 84, 2900),
(9000453, 2, 15, -1, 'Cracked-Bell Shiv', 20471, 4, 0, 1, 14200, 2840, 13, 8, -1, 34, 18, 1, 60, 0, 3, 15, 7, 14, 0, 0, 28, 52, 1600),
(9000454, 2, 10, -1, 'Cantor''s Crook', 20346, 4, 0, 1, 18600, 3720, 17, 16, -1, 34, 18, 1, 95, 0, 5, 16, 6, 15, 7, 14, 58, 88, 3200),
(9000455, 2, 8, -1, 'Rune-Tide Greatsword', 20167, 4, 0, 1, 18600, 3720, 17, 32, -1, 34, 18, 1, 95, 0, 4, 16, 7, 15, 0, 0, 62, 94, 3400),
(9000456, 2, 5, -1, 'Hullbreaker Maul', 8600, 4, 0, 1, 18600, 3720, 17, 64, -1, 34, 18, 1, 95, 0, 4, 14, 5, 15, 7, 14, 60, 90, 3200),
(9000457, 2, 10, -1, 'Brine''s Frost Rod', 20386, 4, 0, 1, 18600, 3720, 17, 128, -1, 34, 18, 1, 95, 0, 5, 17, 7, 14, 6, 12, 58, 88, 3200),
(9000458, 2, 10, -1, 'Hymnal of the Last Tide', 20330, 4, 0, 1, 18600, 3720, 17, 256, -1, 34, 18, 1, 95, 0, 5, 17, 7, 14, 6, 12, 58, 88, 3200),
(9000459, 2, 10, -1, 'Staff of the Cracked Bell', 20336, 4, 0, 1, 18600, 3720, 17, 1024, -1, 34, 18, 1, 95, 0, 5, 16, 7, 15, 6, 12, 58, 88, 3200);

UPDATE `item_template` SET `stackable` = 20 WHERE `entry` BETWEEN 9000430 AND 9000435;
UPDATE `item_template` SET `description` = 'The last verse is just the sound of water.' WHERE `entry` = 9000430;
UPDATE `item_template` SET `description` = 'It still wants to ring.' WHERE `entry` = 9000431;
UPDATE `item_template` SET `description` = 'Sealed for a voyage that never made port.' WHERE `entry` = 9000432;
UPDATE `item_template` SET `description` = 'Every bead is a name the tide kept.' WHERE `entry` = 9000433;
UPDATE `item_template` SET `description` = 'Still wet. The crypt has no puddles.' WHERE `entry` = 9000434;
UPDATE `item_template` SET `description` = 'Whelm kept looking at it. The needle does not move.' WHERE `entry` = 9000435;
UPDATE `item_template` SET `description` = 'Four copies if four warriors walked the well.' WHERE `entry` = 9000450;
UPDATE `item_template` SET `description` = 'The sentence is the peal. The head of the mallet agrees.' WHERE `entry` = 9000451;
UPDATE `item_template` SET `description` = 'Used to cut hawsers. Now it cuts whatever stands in the nave.' WHERE `entry` = 9000452;
UPDATE `item_template` SET `description` = 'A second note was always in the hymn.' WHERE `entry` = 9000453;
UPDATE `item_template` SET `description` = 'A two-handed hymn. Brine remembers every name.' WHERE `entry` = 9000454;
UPDATE `item_template` SET `description` = 'Runes cut into bronze, then into steel. The well still sings.' WHERE `entry` = 9000455;
UPDATE `item_template` SET `description` = 'Break the hull. Then whoever launched it.' WHERE `entry` = 9000456;
UPDATE `item_template` SET `description` = 'The rod was never meant to freeze a chapel. It does now.' WHERE `entry` = 9000457;
UPDATE `item_template` SET `description` = 'A book that sang you. You did not sing back.' WHERE `entry` = 9000458;
UPDATE `item_template` SET `description` = 'Harvest wood from the cracked bell. It still thinks it is whole.' WHERE `entry` = 9000459;

DELETE FROM `quest_template` WHERE `ID` = 9000460;
INSERT INTO `quest_template` (`ID`, `QuestType`, `QuestLevel`, `MinLevel`, `QuestSortID`,
 `SuggestedGroupNum`, `RewardNextQuest`, `RewardXPDifficulty`, `RewardMoney`, `Flags`,
 `RewardChoiceItemID1`, `RewardChoiceItemQuantity1`, `RewardChoiceItemID2`,
 `RewardChoiceItemQuantity2`, `RewardChoiceItemID3`, `RewardChoiceItemQuantity3`,
 `RewardFactionID1`, `RewardFactionValue1`, `AllowableRaces`, `LogTitle`, `LogDescription`,
 `QuestDescription`, `QuestCompletionLog`, `RequiredNpcOrGo1`, `RequiredNpcOrGo2`,
 `RequiredNpcOrGo3`, `RequiredNpcOrGoCount1`, `RequiredNpcOrGoCount2`,
 `RequiredNpcOrGoCount3`, `ObjectiveText1`, `ObjectiveText2`, `ObjectiveText3`) VALUES
(9000460, 2, 24, 18, 10, 5, 0, 6, 850, 8, 9000436, 1, 9000437, 1, 9000438, 1, 72, 5, 1101,
 'The Cracked Bell',
 'Slay Captain Whelm, Sister Brine, and Toll in the Drowned Belfry.',
 'The chapel west of Darkshire rang the drowned home until the bell cracked. Whelm walks the crypt. Brine keeps the sacristy. Toll will not let the well go quiet.$B$BFive volunteers. Kill the three keepers and report back. Walk back the way you entered when you are done.',
 'Return to Keeper Marrow in the Drowned Belfry.',
 9000407, 9000406, 9000408, 1, 1, 1, 'Captain Whelm slain', 'Sister Brine slain',
 'Toll slain');

DELETE FROM `quest_template_addon` WHERE `ID` = 9000460;
INSERT INTO `quest_template_addon` (`ID`, `PrevQuestID`, `NextQuestID`, `SpecialFlags`) VALUES
(9000460, 0, 0, 0);

-- Named rooms. Packs 12y+ apart. Casters wander_distance 0.
DELETE FROM `creature` WHERE `guid` BETWEEN 9001003 AND 9001024;
INSERT INTO `creature` (`guid`, `id`, `map`, `spawnMask`, `phaseMask`, `equipment_id`,
 `position_x`, `position_y`, `position_z`, `orientation`, `spawntimesecs`,
 `wander_distance`, `curhealth`, `curmana`, `MovementType`, `Comment`) VALUES
(9001003, 9000401, 900, 1, 1, 0, -28, 3, 0.2, 3.1416, 86400, 3, 1, 0, 1, 'Porch parishioner'),
(9001004, 9000401, 900, 1, 1, 0, -28, -3, 0.2, 3.1416, 86400, 3, 1, 0, 1, 'Porch parishioner'),
(9001005, 9000403, 900, 1, 1, 1, -50, 4, 0.2, 4.7124, 86400, 0, 1, 0, 0, 'Nave acolyte north'),
(9001006, 9000403, 900, 1, 1, 1, -50, -4, 0.2, 1.5708, 86400, 0, 1, 0, 0, 'Nave acolyte south'),
(9001007, 9000403, 900, 1, 1, 1, -46, 0, 0.2, 3.1416, 86400, 0, 1, 0, 0, 'Nave acolyte east'),
(9001008, 9000403, 900, 1, 1, 1, -54, 0, 0.2, 0, 86400, 0, 1, 0, 0, 'Nave acolyte west'),
(9001009, 9000403, 900, 1, 1, 1, -50, -22, 1.2, 4.7124, 86400, 0, 1, 0, 0, 'Choir acolyte'),
(9001010, 9000401, 900, 1, 1, 0, -48, -26, 1.2, 4.7124, 86400, 2, 1, 0, 1, 'Choir parishioner'),
(9001011, 9000401, 900, 1, 1, 0, -52, -26, 1.2, 4.7124, 86400, 2, 1, 0, 1, 'Choir parishioner'),
(9001012, 9000402, 900, 1, 1, 0, -48, 20, -6.8, 1.5708, 86400, 3, 1, 0, 1, 'Crypt murloc'),
(9001013, 9000402, 900, 1, 1, 0, -52, 20, -6.8, 1.5708, 86400, 3, 1, 0, 1, 'Crypt murloc'),
(9001014, 9000404, 900, 1, 1, 1, -50, 22, -6.8, 1.5708, 86400, 2, 1, 0, 1, 'Crypt sailor'),
(9001015, 9000407, 900, 1, 1, 1, -50, 30, -6.8, 4.7124, 600, 0, 1, 0, 0, 'Captain Whelm'),
(9001016, 9000403, 900, 1, 1, 1, -68, 4, 0.2, 3.1416, 86400, 0, 1, 0, 0, 'Sacristy acolyte'),
(9001017, 9000403, 900, 1, 1, 1, -68, -4, 0.2, 3.1416, 86400, 0, 1, 0, 0, 'Sacristy acolyte'),
(9001018, 9000406, 900, 1, 1, 1, -82, 0, 0.2, 0, 600, 0, 1, 0, 0, 'Sister Brine'),
(9001019, 9000405, 900, 1, 1, 0, -100, 14, 0.2, 4.7124, 86400, 2, 1, 0, 1, 'Bell attendant north'),
(9001020, 9000405, 900, 1, 1, 0, -100, -14, 0.2, 1.5708, 86400, 2, 1, 0, 1, 'Bell attendant south'),
(9001021, 9000404, 900, 1, 1, 1, -96, 0, 0.2, 3.1416, 86400, 2, 1, 0, 1, 'Bell well sailor'),
(9001022, 9000408, 900, 1, 1, 1, -108, 0, 0.2, 0, 600, 0, 1, 0, 0, 'Toll the Bellkeeper'),
(9001023, 9000401, 900, 1, 1, 0, -38, 2, 0.2, 3.1416, 86400, 3, 1, 0, 1, 'Hall parishioner'),
(9001024, 9000402, 900, 1, 1, 0, -50, 12, -3, 1.5708, 86400, 2, 1, 0, 1, 'Crypt stair murloc');

DELETE FROM `creature_addon` WHERE `guid` BETWEEN 9001005 AND 9001008;
INSERT INTO `creature_addon` (`guid`, `path_id`, `mount`, `bytes1`, `bytes2`, `emote`,
 `visibilityDistanceType`, `auras`) VALUES
(9001005, 0, 0, 8, 1, 68, 0, NULL),
(9001006, 0, 0, 8, 1, 68, 0, NULL),
(9001007, 0, 0, 8, 1, 68, 0, NULL),
(9001008, 0, 0, 8, 1, 68, 0, NULL);

DELETE FROM `gameobject` WHERE `guid` BETWEEN 9001003 AND 9001040;
INSERT INTO `gameobject` (`guid`, `id`, `map`, `spawnMask`, `phaseMask`, `position_x`,
 `position_y`, `position_z`, `orientation`, `rotation0`, `rotation1`, `rotation2`, `rotation3`,
 `spawntimesecs`, `animprogress`, `state`, `Comment`) VALUES
(9001003, 9000412, 0, 1, 1, -10736, -1186, 32.8, 0, 0, 0, 0, 1, 180, 100, 1, 'Road lantern north'),
(9001004, 9000412, 0, 1, 1, -10736, -1194, 32.8, 0, 0, 0, 0, 1, 180, 100, 1, 'Road lantern south'),
(9001005, 9000423, 0, 1, 1, -10742, -1189.67, 32.8, 0, 0, 0, 0, 1, 180, 100, 1, 'Road stone arch'),
(9001006, 9000420, 0, 1, 1, -10738, -1185, 32.8, 4.7124, 0, 0, 0.7071, -0.7071, 180, 100, 1, 'Road notice'),
(9001007, 9000412, 900, 1, 1, -12, 4, 0.2, 3.1416, 0, 0, 1, 0, 180, 100, 1, 'Porch lantern'),
(9001008, 9000412, 900, 1, 1, -12, -4, 0.2, 3.1416, 0, 0, 1, 0, 180, 100, 1, 'Porch lantern'),
(9001009, 9000413, 900, 1, 1, -18, 0, 0.2, 0, 0, 0, 0, 1, 180, 100, 1, 'Porch brazier'),
(9001010, 9000420, 900, 1, 1, -14, 5, 0.2, 4.7124, 0, 0, 0.7071, -0.7071, 180, 100, 1, 'Porch notice'),
(9001011, 9000418, 900, 1, 1, -20, -4, 0.2, 0.8, 0, 0, 0.3894, 0.9211, 180, 100, 1, 'Porch crate'),
(9001012, 9000417, 900, 1, 1, -50, 0, 0.2, 0, 0, 0, 0, 1, 180, 100, 1, 'Nave altar'),
(9001013, 9000415, 900, 1, 1, -48, 3, 0.2, 0.8, 0, 0, 0.3894, 0.9211, 180, 100, 1, 'Nave red candle'),
(9001014, 9000415, 900, 1, 1, -52, 3, 0.2, 5.4, 0, 0, 0.4274, -0.904, 180, 100, 1, 'Nave red candle'),
(9001015, 9000415, 900, 1, 1, -48, -3, 0.2, 2.4, 0, 0, 0.932, 0.3624, 180, 100, 1, 'Nave red candle'),
(9001016, 9000415, 900, 1, 1, -52, -3, 0.2, 3.8, 0, 0, 0.949, -0.3153, 180, 100, 1, 'Nave red candle'),
(9001017, 9000416, 900, 1, 1, -50, 6, 0.2, 4.7124, 0, 0, 0.7071, -0.7071, 180, 100, 1, 'Nave tall candle'),
(9001018, 9000421, 900, 1, 1, -50, -20, 1.2, 4.7124, 0, 0, 0.7071, -0.7071, 180, 100, 1, 'Choir candelabra'),
(9001019, 9000416, 900, 1, 1, -47, -24, 1.2, 0, 0, 0, 0, 1, 180, 100, 1, 'Choir tall candle'),
(9001020, 9000416, 900, 1, 1, -53, -24, 1.2, 3.1416, 0, 0, 1, 0, 180, 100, 1, 'Choir tall candle'),
(9001021, 9000414, 900, 1, 1, -50, -27, 1.2, 4.7124, 0, 0, 0.7071, -0.7071, 180, 100, 1, 'Choir candle'),
(9001022, 9000424, 900, 1, 1, -47, 22, -6.8, 0.5, 0, 0, 0.2474, 0.9689, 180, 100, 1, 'Crypt barrel'),
(9001023, 9000418, 900, 1, 1, -53, 22, -6.8, 2.2, 0, 0, 0.8912, 0.4536, 180, 100, 1, 'Crypt crate'),
(9001024, 9000412, 900, 1, 1, -50, 26, -6.8, 1.5708, 0, 0, 0.7071, 0.7071, 180, 100, 1, 'Crypt lantern'),
(9001025, 9000413, 900, 1, 1, -46, 30, -6.8, 0, 0, 0, 0, 1, 180, 100, 1, 'Whelm brazier'),
(9001026, 9000422, 900, 1, 1, -82, 4, 0.2, 0, 0, 0, 0, 1, 180, 100, 1, 'Brine brazier north'),
(9001027, 9000422, 900, 1, 1, -82, -4, 0.2, 3.1416, 0, 0, 1, 0, 180, 100, 1, 'Brine brazier south'),
(9001028, 9000415, 900, 1, 1, -79, 0, 0.2, 0.4, 0, 0, 0.1987, 0.9801, 180, 100, 1, 'Brine red candle'),
(9001029, 9000416, 900, 1, 1, -85, 0, 0.2, 3.1416, 0, 0, 1, 0, 180, 100, 1, 'Brine tall candle'),
(9001030, 9000417, 900, 1, 1, -84, 0, 0.2, 0, 0, 0, 0, 1, 180, 100, 1, 'Brine altar'),
(9001031, 9000419, 900, 1, 1, -110, 0, 0.2, 0, 0, 0, 0, 1, 180, 100, 1, 'Cracked bell'),
(9001032, 9000422, 900, 1, 1, -108, 6, 0.2, 0, 0, 0, 0, 1, 180, 100, 1, 'Toll brazier north'),
(9001033, 9000422, 900, 1, 1, -108, -6, 0.2, 3.1416, 0, 0, 1, 0, 180, 100, 1, 'Toll brazier south'),
(9001034, 9000416, 900, 1, 1, -104, 0, 0.2, 3.1416, 0, 0, 1, 0, 180, 100, 1, 'Toll tall candle'),
(9001035, 9000420, 900, 1, 1, -106, 4, 0.2, 4.7124, 0, 0, 0.7071, -0.7071, 180, 100, 1, 'Toll notice'),
(9001036, 9000415, 900, 1, 1, -106, -3, 0.2, 5.1, 0, 0, 0.5577, -0.8301, 180, 100, 1, 'Toll red candle'),
(9001037, 9000412, 900, 1, 1, -96, 4, 0.2, 3.1416, 0, 0, 1, 0, 180, 100, 1, 'Well lantern'),
(9001038, 9000412, 900, 1, 1, -96, -4, 0.2, 3.1416, 0, 0, 1, 0, 180, 100, 1, 'Well lantern'),
(9001039, 9000414, 900, 1, 1, -72, 0, 0.2, 0, 0, 0, 0, 1, 180, 100, 1, 'Sacristy hall candle'),
(9001040, 9000424, 900, 1, 1, -16, -5, 0.2, 1.1, 0, 0, 0.5225, 0.8526, 180, 100, 1, 'Porch barrel');

DELETE FROM `smart_scripts` WHERE `entryorguid` = 9000401 AND `source_type` = 0;
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`,
 `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`,
 `event_param3`, `event_param4`, `event_param5`, `event_param6`, `action_type`,
 `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`,
 `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`,
 `target_param4`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(9000401, 0, 0, 0, 4, 0, 100, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Parishioner - On Aggro - Talk'),
(9000401, 0, 1, 0, 0, 0, 100, 0, 3000, 6000, 10000, 14000, 0, 0, 11, 1776, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Parishioner - IC - Gouge');
DELETE FROM `smart_scripts` WHERE `entryorguid` = 9000402 AND `source_type` = 0;
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`,
 `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`,
 `event_param3`, `event_param4`, `event_param5`, `event_param6`, `action_type`,
 `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`,
 `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`,
 `target_param4`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(9000402, 0, 0, 0, 0, 0, 100, 0, 0, 0, 2400, 3800, 0, 0, 11, 13322, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Murloc - IC CMC - Frostbolt'),
(9000402, 0, 1, 0, 0, 0, 100, 0, 8000, 12000, 16000, 22000, 0, 0, 11, 122, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Murloc - IC - Frost Nova');
DELETE FROM `smart_scripts` WHERE `entryorguid` = 9000403 AND `source_type` = 0;
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`,
 `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`,
 `event_param3`, `event_param4`, `event_param5`, `event_param6`, `action_type`,
 `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`,
 `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`,
 `target_param4`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(9000403, 0, 0, 1, 25, 0, 100, 0, 0, 0, 0, 0, 0, 0, 90, 8, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Acolyte - Reset - Kneel standstate'),
(9000403, 0, 1, 0, 61, 0, 100, 0, 0, 0, 0, 0, 0, 0, 17, 68, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Acolyte - Link - Kneel emote'),
(9000403, 0, 2, 3, 4, 0, 100, 0, 0, 0, 0, 0, 0, 0, 91, 8, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Acolyte - On Aggro - Stand'),
(9000403, 0, 3, 4, 61, 0, 100, 0, 0, 0, 0, 0, 0, 0, 17, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Acolyte - Link - Clear emote'),
(9000403, 0, 4, 0, 61, 0, 100, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Acolyte - Link - Talk'),
(9000403, 0, 5, 0, 0, 0, 100, 0, 0, 0, 2400, 3800, 0, 0, 11, 7641, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Acolyte - IC CMC - Shadow Bolt');
DELETE FROM `smart_scripts` WHERE `entryorguid` = 9000404 AND `source_type` = 0;
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`,
 `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`,
 `event_param3`, `event_param4`, `event_param5`, `event_param6`, `action_type`,
 `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`,
 `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`,
 `target_param4`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(9000404, 0, 0, 0, 0, 0, 100, 0, 1000, 3000, 15000, 18000, 0, 0, 11, 6268, 0, 0, 0, 0, 0, 28, 30, 1, 0, 0, 0, 0, 0, 0, 'Sailor - IC - Rushing Charge farthest'),
(9000404, 0, 1, 0, 2, 0, 100, 1, 0, 30, 0, 0, 0, 0, 11, 8599, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Sailor - 30% - Enrage');
DELETE FROM `smart_scripts` WHERE `entryorguid` = 9000405 AND `source_type` = 0;
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`,
 `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`,
 `event_param3`, `event_param4`, `event_param5`, `event_param6`, `action_type`,
 `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`,
 `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`,
 `target_param4`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(9000405, 0, 0, 0, 0, 0, 100, 0, 4000, 7000, 16000, 22000, 0, 0, 11, 6016, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Attendant - IC - Pierce Armor'),
(9000405, 0, 1, 0, 2, 0, 100, 1, 0, 30, 0, 0, 0, 0, 11, 8599, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Attendant - 30% - Enrage');

DELETE FROM `reference_loot_template` WHERE `Entry` = 9000103;
INSERT INTO `reference_loot_template` (`Entry`, `Item`, `Reference`, `Chance`, `QuestRequired`,
 `LootMode`, `GroupId`, `MinCount`, `MaxCount`, `Comment`) VALUES
(9000103, 9000436, 0, 0, 0, 1, 1, 1, 1, 'Belfry green - Saltwake Leggings'),
(9000103, 9000437, 0, 0, 0, 1, 1, 1, 1, 'Belfry green - Choir Tunic'),
(9000103, 9000438, 0, 0, 0, 1, 1, 1, 1, 'Belfry green - Hymnal Staff'),
(9000103, 9000439, 0, 0, 0, 1, 1, 1, 1, 'Belfry green - Brinewrap Gloves'),
(9000103, 9000440, 0, 0, 0, 1, 1, 1, 1, 'Belfry green - Cantor Cowl'),
(9000103, 9000441, 0, 0, 0, 1, 1, 1, 1, 'Belfry green - Bellwell Treads'),
(9000103, 9000442, 0, 0, 0, 1, 1, 1, 1, 'Belfry green - Belaying Pin'),
(9000103, 9000443, 0, 0, 0, 1, 1, 1, 1, 'Belfry green - Choir Shiv');

DELETE FROM `creature_loot_template` WHERE `Entry` IN (9000401,9000402,9000403,9000404,9000405,9000406,9000407,9000408);
INSERT INTO `creature_loot_template` (`Entry`, `Item`, `Reference`, `Chance`, `QuestRequired`,
 `LootMode`, `GroupId`, `MinCount`, `MaxCount`, `Comment`) VALUES
(9000401, 9000430, 0, 45, 0, 1, 0, 1, 1, 'Parishioner - Hymnal'),
(9000401, 2589, 0, 30, 0, 1, 0, 1, 2, 'Parishioner - Linen Cloth'),
(9000401, 0, 9000103, 6, 0, 1, 0, 1, 1, 'Parishioner - Belfry green'),
(9000402, 9000434, 0, 50, 0, 1, 0, 1, 1, 'Murloc - Scale Scrap'),
(9000402, 2589, 0, 20, 0, 1, 0, 1, 2, 'Murloc - Linen Cloth'),
(9000402, 0, 9000103, 6, 0, 1, 0, 1, 1, 'Murloc - Belfry green'),
(9000403, 9000433, 0, 50, 0, 1, 0, 1, 1, 'Acolyte - Rosary'),
(9000403, 2589, 0, 25, 0, 1, 0, 1, 2, 'Acolyte - Linen Cloth'),
(9000403, 0, 9000103, 7, 0, 1, 0, 1, 1, 'Acolyte - Belfry green'),
(9000404, 9000435, 0, 40, 0, 1, 0, 1, 1, 'Sailor - Sextant'),
(9000404, 9000432, 0, 30, 0, 1, 0, 1, 1, 'Sailor - Ration'),
(9000404, 2589, 0, 30, 0, 1, 0, 1, 2, 'Sailor - Linen Cloth'),
(9000404, 0, 9000103, 6, 0, 1, 0, 1, 1, 'Sailor - Belfry green'),
(9000405, 9000431, 0, 50, 0, 1, 0, 1, 1, 'Attendant - Bell Shard'),
(9000405, 2589, 0, 30, 0, 1, 0, 1, 2, 'Attendant - Linen Cloth'),
(9000405, 0, 9000103, 8, 0, 1, 0, 1, 1, 'Attendant - Belfry green'),
(9000407, 9000435, 0, 100, 0, 1, 0, 1, 1, 'Whelm - Sextant'),
(9000407, 9000442, 0, 22, 0, 1, 1, 1, 1, 'Whelm - Belaying Pin'),
(9000407, 9000436, 0, 14, 0, 1, 1, 1, 1, 'Whelm - Saltwake Leggings'),
(9000407, 9000437, 0, 14, 0, 1, 1, 1, 1, 'Whelm - Choir Tunic'),
(9000407, 9000443, 0, 14, 0, 1, 1, 1, 1, 'Whelm - Choir Shiv'),
(9000406, 9000433, 0, 100, 0, 1, 0, 1, 2, 'Brine - Rosary'),
(9000406, 9000440, 0, 22, 0, 1, 1, 1, 1, 'Brine - Cantor Cowl'),
(9000406, 9000439, 0, 14, 0, 1, 1, 1, 1, 'Brine - Brinewrap Gloves'),
(9000406, 9000436, 0, 14, 0, 1, 1, 1, 1, 'Brine - Saltwake Leggings'),
(9000406, 9000438, 0, 14, 0, 1, 1, 1, 1, 'Brine - Hymnal Staff'),
(9000408, 9000431, 0, 100, 0, 1, 0, 1, 2, 'Toll - Bell Shard'),
(9000408, 9000441, 0, 22, 0, 1, 1, 1, 1, 'Toll - Bellwell Treads'),
(9000408, 9000436, 0, 12, 0, 1, 1, 1, 1, 'Toll - Saltwake Leggings'),
(9000408, 9000437, 0, 12, 0, 1, 1, 1, 1, 'Toll - Choir Tunic'),
(9000408, 9000438, 0, 12, 0, 1, 1, 1, 1, 'Toll - Hymnal Staff'),
(9000408, 9000442, 0, 12, 0, 1, 1, 1, 1, 'Toll - Belaying Pin');

DELETE FROM `creature_text` WHERE `CreatureID` IN (9000401, 9000403, 9000406, 9000407, 9000408);
INSERT INTO `creature_text` (`CreatureID`, `GroupID`, `ID`, `Text`, `Type`, `Language`,
 `Probability`, `Emote`, `Duration`, `Sound`, `BroadcastTextId`, `TextRange`, `comment`) VALUES
(9000401, 0, 0, 'The bell still owes us a ringing.', 12, 0, 50, 0, 0, 0, 0, 0, 'Parishioner aggro'),
(9000401, 0, 1, 'Kneel. The tide is listening.', 12, 0, 50, 0, 0, 0, 0, 0, 'Parishioner aggro'),
(9000403, 0, 0, 'Sing. The well takes testimony.', 12, 0, 100, 0, 0, 0, 0, 0, 'Acolyte aggro'),
(9000407, 0, 0, 'Nobody makes port. That is the rule.', 14, 0, 100, 0, 0, 0, 0, 0, 'Whelm aggro'),
(9000407, 1, 0, 'All hands! The crypt is not empty!', 14, 0, 100, 0, 0, 0, 0, 0, 'Whelm adds'),
(9000407, 2, 0, 'Tell the shore... we were coming home...', 14, 0, 100, 0, 0, 0, 0, 0, 'Whelm death'),
(9000406, 0, 0, 'Kneel. The hymn is not finished.', 14, 0, 100, 0, 0, 0, 0, 0, 'Brine aggro'),
(9000406, 1, 0, 'The water remembers every name.', 14, 0, 100, 0, 0, 0, 0, 0, 'Brine nova'),
(9000406, 2, 0, 'Your secrets are loud.', 14, 0, 100, 0, 0, 0, 0, 0, 'Brine scream'),
(9000406, 3, 0, 'The last verse... is silence...', 14, 0, 100, 0, 0, 0, 0, 0, 'Brine death'),
(9000408, 0, 0, 'I kept this well shut for twenty years. You will not open it.', 14, 0, 100, 0, 0, 0, 0, 0, 'Toll aggro'),
(9000408, 1, 0, 'Hear the crack. That is the only hymn left.', 14, 0, 100, 0, 0, 0, 0, 0, 'Toll bell'),
(9000408, 2, 0, 'The bronze still turns. So do I.', 14, 0, 100, 0, 0, 0, 0, 0, 'Toll enrage'),
(9000408, 3, 0, 'Tell Darkshire... the bell... was never empty...', 14, 0, 100, 0, 0, 0, 0, 0, 'Toll death');

DELETE FROM `creature_queststarter` WHERE `id` = 9000400 AND `quest` = 9000460;
INSERT INTO `creature_queststarter` (`id`, `quest`) VALUES
(9000400, 9000460);

DELETE FROM `creature_questender` WHERE `id` = 9000400 AND `quest` = 9000460;
INSERT INTO `creature_questender` (`id`, `quest`) VALUES
(9000400, 9000460);

DELETE FROM `quest_request_items` WHERE `ID` = 9000460;
INSERT INTO `quest_request_items` (`ID`, `EmoteOnComplete`, `EmoteOnIncomplete`, `CompletionText`) VALUES
(9000460, 0, 0, 'The well is still singing. Get back in there.');

DELETE FROM `quest_offer_reward` WHERE `ID` = 9000460;
INSERT INTO `quest_offer_reward` (`ID`, `Emote1`, `Emote2`, `Emote3`, `Emote4`, `EmoteDelay1`,
 `EmoteDelay2`, `EmoteDelay3`, `EmoteDelay4`, `RewardText`) VALUES
(9000460, 0, 0, 0, 0, 0, 0, 0, 0, 'Darkshire will not mention this. Walk back the way you came. I will still be here.');
