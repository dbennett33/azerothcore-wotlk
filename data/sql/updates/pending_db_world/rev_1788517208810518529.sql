-- Stormwind Vault 5-man (map 35). Custom ids 9000200-9000399 / guids 9000500-9000999.
-- Entrance: unused canal swirl between Trade District and Old Town (not The Stockade).

DELETE FROM `instance_template` WHERE `map` = 35;
INSERT INTO `instance_template` (`map`, `parent`, `script`, `allowMount`) VALUES
(35, 0, 'instance_stormwind_vault', 0);

DELETE FROM `dungeon_access_template` WHERE `id` = 123;
INSERT INTO `dungeon_access_template` (`id`, `map_id`, `difficulty`, `min_level`, `max_level`,
 `min_avg_item_level`, `comment`) VALUES
(123, 35, 0, 1, 0, 0, 'Stormwind Vault');

DELETE FROM `mapdifficulty_dbc` WHERE `ID` = 9000035;
INSERT INTO `mapdifficulty_dbc` (`ID`, `MapID`, `Difficulty`, `Message_Lang_enUS`, `Message_Lang_Mask`,
 `RaidDuration`, `MaxPlayers`, `Difficultystring`) VALUES
(9000035, 35, 0, '', 16712190, 0, 5, '');

-- Exit from the vault returns to the unused canal swirl, not the Stockade.
DELETE FROM `areatrigger_teleport` WHERE `ID` = 109;
INSERT INTO `areatrigger_teleport` (`ID`, `Name`, `target_map`, `target_position_x`, `target_position_y`,
 `target_position_z`, `target_orientation`) VALUES
(109, 'Stormwind Vault Instance', 0, -8822.07, 518.022, 98.7826, 5.5);

DELETE FROM `creature_template` WHERE `entry` = 9000200;
INSERT INTO `creature_template` (`entry`, `name`, `subname`, `minlevel`, `maxlevel`, `faction`,
 `npcflag`, `gossip_menu_id`, `speed_walk`, `speed_run`, `detection_range`, `rank`,
 `DamageModifier`, `BaseAttackTime`, `RangeAttackTime`, `unit_class`, `unit_flags`,
 `unit_flags2`, `type`, `lootid`, `mingold`, `maxgold`, `AIName`, `HealthModifier`, `ManaModifier`,
 `RegenHealth`, `flags_extra`, `ScriptName`, `VerifiedBuild`) VALUES
(9000200, 'Vault Warden', 'Stormwind Vault', 30, 30, 12, 3, 9000200, 1, 1.42857, 18, 0, 1, 2000, 2000, 1, 512, 2048, 7, 0, 0, 0, '', 1.5, 1, 1, 0, '', 0);

DELETE FROM `creature_template_model` WHERE `CreatureID` = 9000200;
INSERT INTO `creature_template_model` (`CreatureID`, `Idx`, `CreatureDisplayID`, `DisplayScale`, `Probability`, `VerifiedBuild`) VALUES
(9000200, 0, 3167, 1, 1, 0);

DELETE FROM `npc_text` WHERE `ID` = 9000200;
INSERT INTO `npc_text` (`ID`, `text0_0`, `text0_1`, `Probability0`) VALUES
(9000200, 'The Vault was sealed for years. Something opened the last cell from the inside.$B$BGarrow still holds the cellblock. Sister Cinder took the interrogation rooms. Blackiron will not leave the last cell alive.$B$BWalk back the way you entered to return to Stormwind.', '', 1);

DELETE FROM `gossip_menu` WHERE `MenuID` = 9000200;
INSERT INTO `gossip_menu` (`MenuID`, `TextID`) VALUES
(9000200, 9000200);

DELETE FROM `creature` WHERE `guid` = 9000500;
INSERT INTO `creature` (`guid`, `id`, `map`, `spawnMask`, `phaseMask`, `equipment_id`,
 `position_x`, `position_y`, `position_z`, `orientation`, `spawntimesecs`,
 `wander_distance`, `curhealth`, `curmana`, `MovementType`, `Comment`) VALUES
(9000500, 9000200, 35, 1, 1, 0, 4, 40.57, -24.23, 3.1416, 120, 0, 1, 0, 0, 'Vault Warden mouth');

-- Invisible walk-through on the unused canal swirl (WMO visual already exists).
DELETE FROM `gameobject_template` WHERE `entry` = 9000201;
INSERT INTO `gameobject_template` (`entry`, `type`, `displayId`, `name`, `size`, `Data0`, `Data3`,
 `AIName`, `ScriptName`, `VerifiedBuild`) VALUES
(9000201, 5, 1327, 'Stormwind Vault', 0.1, 0, 0, '', 'go_stormwind_vault_entrance', 0);

DELETE FROM `gameobject_template_addon` WHERE `entry` = 9000201;
INSERT INTO `gameobject_template_addon` (`entry`, `faction`, `flags`, `mingold`, `maxgold`) VALUES
(9000201, 0, 16, 0, 0);

-- ori 0 (east, through the bars). Quaternion: rot2 = sin(0) = 0, rot3 = cos(0) = 1.
DELETE FROM `gameobject` WHERE `guid` = 9000501;
INSERT INTO `gameobject` (`guid`, `id`, `map`, `spawnMask`, `phaseMask`, `position_x`,
 `position_y`, `position_z`, `orientation`, `rotation0`, `rotation1`, `rotation2`, `rotation3`,
 `spawntimesecs`, `animprogress`, `state`, `Comment`) VALUES
(9000501, 9000201, 0, 1, 1, -8792, 495, 90, 0, 0, 0, 0, 1, 180, 100, 1, 'Vault unused canal swirl');

DELETE FROM `game_tele` WHERE `id` IN (9000060, 9000061) OR `name` IN ('swvault', 'swvault_canal');
INSERT INTO `game_tele` (`id`, `position_x`, `position_y`, `position_z`, `orientation`, `map`, `name`) VALUES
(9000060, -0.91, 40.57, -24.23, 0, 35, 'swvault'),
(9000061, -8822.07, 518.022, 98.7826, 5.5, 0, 'swvault_canal');

-- Stormwind Vault interior. Floor Z copied from AT dest (-24.23). Layout is +X from the mouth.

DELETE FROM `creature_template` WHERE `entry` BETWEEN 9000202 AND 9000213;
INSERT INTO `creature_template` (`entry`, `name`, `subname`, `minlevel`, `maxlevel`, `faction`,
 `npcflag`, `gossip_menu_id`, `speed_walk`, `speed_run`, `detection_range`, `rank`,
 `DamageModifier`, `BaseAttackTime`, `RangeAttackTime`, `unit_class`, `unit_flags`,
 `unit_flags2`, `type`, `lootid`, `mingold`, `maxgold`, `AIName`, `HealthModifier`, `ManaModifier`,
 `RegenHealth`, `flags_extra`, `ScriptName`, `VerifiedBuild`) VALUES
(9000202, 'Vault Inmate', 'Stormwind Vault', 13, 14, 17, 0, 0, 1, 1.14286, 14, 1, 1.5, 2000, 2000, 1, 0, 2048, 7, 9000202, 18, 42, 'SmartAI', 2.5, 1, 1, 0, '', 0),
(9000203, 'Vault Turnkey', 'Stormwind Vault', 14, 14, 14, 0, 0, 1, 1.14286, 14, 1, 1.55, 2000, 2000, 1, 0, 2048, 7, 9000203, 22, 48, 'SmartAI', 2.6, 1, 1, 0, '', 0),
(9000204, 'Vault Shadowmage', 'Stormwind Vault', 14, 15, 14, 0, 0, 1, 1.14286, 14, 1, 1.45, 2000, 2000, 8, 0, 2048, 7, 9000204, 24, 52, 'SmartAI', 2.4, 2, 1, 0, '', 0),
(9000205, 'Vault Rioter', 'Stormwind Vault', 13, 14, 17, 0, 0, 1, 1.19048, 14, 1, 1.5, 2000, 2000, 1, 0, 2048, 7, 9000205, 18, 42, 'SmartAI', 2.5, 1, 1, 0, '', 0),
(9000206, 'Cell Rat', 'Stormwind Vault', 12, 13, 14, 0, 0, 1, 1.14286, 12, 1, 1.4, 2000, 2000, 1, 0, 2048, 1, 9000206, 8, 20, 'SmartAI', 2.3, 1, 1, 0, '', 0),
(9000207, 'Vault Acolyte', 'Stormwind Vault', 13, 14, 14, 0, 0, 1, 1.14286, 10, 1, 1.4, 2000, 2000, 2, 0, 2048, 7, 9000207, 16, 38, 'SmartAI', 2.4, 2, 1, 0, '', 0),
(9000208, 'Shackled Horror', 'Stormwind Vault', 14, 14, 14, 0, 0, 1, 1.14286, 14, 1, 1.55, 2000, 2000, 1, 0, 2048, 6, 9000208, 20, 46, 'SmartAI', 2.6, 1, 1, 0, '', 0),
(9000209, 'Vault Enforcer', 'Stormwind Vault', 15, 15, 14, 0, 0, 1, 1.14286, 14, 1, 1.6, 2000, 2000, 1, 0, 2048, 7, 9000209, 28, 55, 'SmartAI', 2.8, 1, 1, 0, '', 0),
(9000210, 'Turnkey Garrow', 'The Cellblock', 15, 15, 14, 0, 0, 1, 1.14286, 16, 1, 2.1, 2000, 2000, 1, 0, 2048, 7, 9000210, 80, 140, '', 6.5, 1, 1, 0, 'boss_turnkey_garrow', 0),
(9000211, 'Sister Cinder', 'Confessor of the Vault', 16, 16, 14, 0, 0, 1, 1.14286, 16, 1, 2.0, 2000, 2000, 8, 0, 2048, 7, 9000211, 90, 150, '', 6, 3, 1, 0, 'boss_sister_cinder', 0),
(9000212, 'Warden Blackiron', 'Keeper of the Last Cell', 16, 16, 14, 0, 0, 1, 1.14286, 16, 1, 2.3, 2000, 2000, 1, 0, 2048, 7, 9000212, 110, 180, '', 7.5, 1, 1, 0, 'boss_warden_blackiron', 0),
(9000213, 'Confession', '', 1, 1, 14, 0, 0, 1, 1, 1, 0, 1, 2000, 2000, 1, 768, 0, 10, 0, 0, 0, '', 0.1, 1, 1, 128, '', 0);

DELETE FROM `creature_template_model` WHERE `CreatureID` BETWEEN 9000202 AND 9000213;
INSERT INTO `creature_template_model` (`CreatureID`, `Idx`, `CreatureDisplayID`, `DisplayScale`, `Probability`, `VerifiedBuild`) VALUES
(9000202, 0, 2144, 1, 1, 0),
(9000203, 0, 2148, 1, 1, 0),
(9000204, 0, 2603, 1, 1, 0),
(9000205, 0, 2147, 1, 1, 0),
(9000206, 0, 1141, 1, 1, 0),
(9000207, 0, 2604, 1, 1, 0),
(9000208, 0, 200, 1.1, 1, 0),
(9000209, 0, 2149, 1.1, 1, 0),
(9000210, 0, 2149, 1.35, 1, 0),
(9000211, 0, 2473, 1.2, 1, 0),
(9000212, 0, 1621, 1.4, 1, 0),
(9000213, 0, 11686, 1, 1, 0);

DELETE FROM `creature_equip_template` WHERE `CreatureID` IN (9000203, 9000209, 9000210, 9000211, 9000212);
INSERT INTO `creature_equip_template` (`CreatureID`, `ID`, `ItemID1`, `ItemID2`, `ItemID3`, `VerifiedBuild`) VALUES
(9000203, 1, 1896, 0, 0, 0),
(9000209, 1, 1899, 0, 0, 0),
(9000210, 1, 1899, 0, 0, 0),
(9000211, 1, 2176, 0, 0, 0),
(9000212, 1, 1812, 0, 0, 0);

UPDATE `creature_template` SET `flags_extra` = `flags_extra` | 536870912
 WHERE `entry` BETWEEN 9000202 AND 9000212;

DELETE FROM `gameobject_template` WHERE `entry` BETWEEN 9000215 AND 9000228;
INSERT INTO `gameobject_template` (`entry`, `type`, `displayId`, `name`, `size`, `Data0`, `Data3`,
 `AIName`, `ScriptName`, `VerifiedBuild`) VALUES
(9000215, 5, 201, 'Vault Brazier', 1, 0, 0, '', '', 0),
(9000216, 5, 6038, 'Vault Lantern', 1, 0, 0, '', '', 0),
(9000217, 5, 411, 'Cell Bars', 1, 0, 0, '', '', 0),
(9000218, 5, 31, 'Vault Crate', 1, 0, 0, '', '', 0),
(9000219, 5, 100, 'Vault Candle', 1, 0, 0, '', '', 0),
(9000220, 5, 4152, 'Red Ritual Candle', 2.8, 0, 0, '', '', 0),
(9000221, 5, 328, 'Vault Shrine', 0.85, 0, 0, '', '', 0),
(9000222, 10, 128, 'Cell Lever', 1, 0, 3000, '', 'go_vault_cell_lever', 0),
(9000223, 5, 409, 'Interrogation Rack', 1, 0, 0, '', '', 0),
(9000224, 5, 201, 'Great Vault Brazier', 1.8, 0, 0, '', '', 0),
(9000225, 10, 128, 'Cell Wheel', 1.8, 0, 3000, '', 'go_vault_wheel', 0),
(9000226, 5, 6412, 'Sealed Notice', 1, 0, 0, '', '', 0),
(9000227, 5, 409, 'Vault Weapon Rack', 1, 0, 0, '', '', 0),
(9000228, 5, 6364, 'Tall Vault Candle', 2.3, 0, 0, '', '', 0);

DELETE FROM `gameobject_template_addon` WHERE `entry` BETWEEN 9000215 AND 9000228;
INSERT INTO `gameobject_template_addon` (`entry`, `faction`, `flags`, `mingold`, `maxgold`) VALUES
(9000215, 0, 0, 0, 0),
(9000216, 0, 0, 0, 0),
(9000217, 0, 0, 0, 0),
(9000218, 0, 0, 0, 0),
(9000219, 0, 0, 0, 0),
(9000220, 0, 0, 0, 0),
(9000221, 0, 0, 0, 0),
(9000222, 0, 0, 0, 0),
(9000223, 0, 0, 0, 0),
(9000224, 0, 0, 0, 0),
(9000225, 0, 0, 0, 0),
(9000226, 0, 0, 0, 0),
(9000227, 0, 0, 0, 0),
(9000228, 0, 0, 0, 0);

DELETE FROM `item_template` WHERE `entry` BETWEEN 9000230 AND 9000259;
INSERT INTO `item_template` (`entry`, `class`, `subclass`, `SoundOverrideSubclass`, `name`, `displayid`,
 `Quality`, `Flags`, `BuyCount`, `BuyPrice`, `SellPrice`, `InventoryType`, `AllowableClass`,
 `AllowableRace`, `ItemLevel`, `RequiredLevel`, `bonding`, `MaxDurability`, `armor`,
 `stat_type1`, `stat_value1`, `stat_type2`, `stat_value2`, `stat_type3`, `stat_value3`,
 `dmg_min1`, `dmg_max1`, `delay`) VALUES
(9000230, 15, 0, -1, 'Rusted Cell Key', 2207, 0, 0, 5, 20, 5, 0, -1, -1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(9000231, 15, 0, -1, 'Torn Sentence', 1093, 0, 0, 5, 14, 3, 0, -1, -1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(9000232, 15, 0, -1, 'Mouldy Ration', 6348, 0, 0, 5, 12, 3, 0, -1, -1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(9000233, 15, 0, -1, 'Shackle Fragment', 6677, 0, 0, 5, 16, 4, 0, -1, -1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(9000234, 15, 0, -1, 'Confessor''s Note', 1093, 0, 0, 5, 14, 3, 0, -1, -1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(9000235, 15, 0, -1, 'Vault Ledger Page', 1093, 0, 0, 5, 18, 4, 0, -1, -1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(9000237, 4, 3, -1, 'Turnkey''s Mail Leggings', 9738, 2, 0, 1, 1850, 370, 7, -1, -1, 18, 0, 1, 55, 128, 4, 4, 7, 3, 0, 0, 0, 0, 0),
(9000238, 4, 2, -1, 'Inmate''s Leather Tunic', 11368, 2, 0, 1, 1620, 324, 5, -1, -1, 18, 0, 1, 65, 72, 7, 3, 3, 2, 0, 0, 0, 0, 0),
(9000239, 2, 10, -1, 'Vault-Issue Staff', 10654, 2, 0, 1, 3820, 764, 17, -1, -1, 18, 0, 1, 55, 0, 5, 4, 7, 3, 0, 0, 22, 28, 2300),
(9000240, 4, 2, -1, 'Cinderwrap Gloves', 14536, 2, 0, 1, 620, 124, 10, -1, -1, 17, 0, 1, 30, 38, 5, 3, 7, 2, 0, 0, 0, 0, 0),
(9000241, 4, 1, -1, 'Shadow-Soot Cowl', 15290, 2, 0, 1, 680, 136, 1, -1, -1, 17, 0, 1, 40, 22, 5, 4, 7, 3, 0, 0, 0, 0, 0),
(9000242, 4, 2, -1, 'Blackiron Treads', 16980, 2, 0, 1, 640, 128, 8, -1, -1, 17, 0, 1, 35, 44, 7, 3, 4, 2, 0, 0, 0, 0, 0),
(9000243, 2, 4, -1, 'Garrow''s Cudgel', 8575, 2, 0, 1, 1980, 396, 21, -1, -1, 17, 0, 1, 45, 0, 4, 3, 7, 2, 0, 0, 12, 22, 2200),
(9000244, 2, 15, -1, 'Shiv of the Last Cell', 6442, 2, 0, 1, 1760, 352, 13, -1, -1, 16, 0, 1, 35, 0, 3, 3, 7, 2, 0, 0, 8, 16, 1600),
(9000250, 2, 8, -1, 'Blackiron Claymore', 20174, 4, 0, 1, 14800, 2960, 17, 1, -1, 28, 12, 1, 90, 0, 4, 14, 7, 13, 0, 0, 48, 72, 3200),
(9000251, 2, 5, -1, 'Sentence of the Vault', 19610, 4, 0, 1, 14800, 2960, 17, 2, -1, 28, 12, 1, 90, 0, 4, 13, 7, 14, 5, 10, 54, 82, 3500),
(9000252, 2, 1, -1, 'Turnkey''s Reaver', 28804, 4, 0, 1, 14800, 2960, 17, 4, -1, 28, 12, 1, 90, 0, 3, 14, 7, 13, 0, 0, 46, 70, 2900),
(9000253, 2, 15, -1, 'Last-Cell Shiv', 20471, 4, 0, 1, 11200, 2240, 13, 8, -1, 28, 12, 1, 55, 0, 3, 13, 7, 12, 0, 0, 22, 42, 1600),
(9000254, 2, 10, -1, 'Confessor''s Crook', 20346, 4, 0, 1, 14800, 2960, 17, 16, -1, 28, 12, 1, 90, 0, 5, 14, 6, 13, 7, 12, 50, 76, 3200),
(9000255, 2, 8, -1, 'Rune-Cell Greatsword', 20167, 4, 0, 1, 14800, 2960, 17, 32, -1, 28, 12, 1, 90, 0, 4, 14, 7, 13, 0, 0, 52, 78, 3400),
(9000256, 2, 5, -1, 'Shacklebreaker Maul', 8600, 4, 0, 1, 14800, 2960, 17, 64, -1, 28, 12, 1, 90, 0, 4, 12, 5, 13, 7, 12, 51, 77, 3200),
(9000257, 2, 10, -1, 'Cinder''s Shadow Rod', 20386, 4, 0, 1, 14800, 2960, 17, 128, -1, 28, 12, 1, 90, 0, 5, 15, 7, 12, 6, 10, 50, 76, 3200),
(9000258, 2, 10, -1, 'Ledger of Binding', 20330, 4, 0, 1, 14800, 2960, 17, 256, -1, 28, 12, 1, 90, 0, 5, 15, 7, 12, 6, 10, 50, 76, 3200),
(9000259, 2, 10, -1, 'Staff of the Last Cell', 20336, 4, 0, 1, 14800, 2960, 17, 1024, -1, 28, 12, 1, 90, 0, 5, 14, 7, 13, 6, 10, 50, 76, 3200);

UPDATE `item_template` SET `stackable` = 20 WHERE `entry` BETWEEN 9000230 AND 9000235;
UPDATE `item_template` SET `description` = 'It does not fit any lock still in use.' WHERE `entry` = 9000230;
UPDATE `item_template` SET `description` = 'The name is scratched out. The sentence is not.' WHERE `entry` = 9000231;
UPDATE `item_template` SET `description` = 'Sealed-in rations. Best not to ask how old.' WHERE `entry` = 9000232;
UPDATE `item_template` SET `description` = 'The chain remembers every wrist.' WHERE `entry` = 9000233;
UPDATE `item_template` SET `description` = 'She wrote until the ink ran. Then she used soot.' WHERE `entry` = 9000234;
UPDATE `item_template` SET `description` = 'Blackiron kept a book. This page crawled out.' WHERE `entry` = 9000235;
UPDATE `item_template` SET `description` = 'Four copies if four warriors walked the last cell.' WHERE `entry` = 9000250;
UPDATE `item_template` SET `description` = 'The sentence is binding. So is the head of the mallet.' WHERE `entry` = 9000251;
UPDATE `item_template` SET `description` = 'Used to haul cell doors. Now it hauls whatever stands in the hall.' WHERE `entry` = 9000252;
UPDATE `item_template` SET `description` = 'A second stab was always in the sentence.' WHERE `entry` = 9000253;
UPDATE `item_template` SET `description` = 'A two-handed confession. Cinder remembers every name.' WHERE `entry` = 9000254;
UPDATE `item_template` SET `description` = 'Runes cut into iron, then into steel. The vault still weeps.' WHERE `entry` = 9000255;
UPDATE `item_template` SET `description` = 'Break the shackle. Then whoever forged it.' WHERE `entry` = 9000256;
UPDATE `item_template` SET `description` = 'The rod was never meant to channel anything. It does now.' WHERE `entry` = 9000257;
UPDATE `item_template` SET `description` = 'A ledger that signed you. You did not sign back.' WHERE `entry` = 9000258;
UPDATE `item_template` SET `description` = 'Harvest wood from the last cell. The door still thinks it is shut.' WHERE `entry` = 9000259;

DELETE FROM `quest_template` WHERE `ID` = 9000260;
INSERT INTO `quest_template` (`ID`, `QuestType`, `QuestLevel`, `MinLevel`, `QuestSortID`,
 `SuggestedGroupNum`, `RewardNextQuest`, `RewardXPDifficulty`, `RewardMoney`, `Flags`,
 `RewardChoiceItemID1`, `RewardChoiceItemQuantity1`, `RewardChoiceItemID2`,
 `RewardChoiceItemQuantity2`, `RewardChoiceItemID3`, `RewardChoiceItemQuantity3`,
 `RewardFactionID1`, `RewardFactionValue1`, `AllowableRaces`, `LogTitle`, `LogDescription`,
 `QuestDescription`, `QuestCompletionLog`, `RequiredNpcOrGo1`, `RequiredNpcOrGo2`,
 `RequiredNpcOrGo3`, `RequiredNpcOrGoCount1`, `RequiredNpcOrGoCount2`,
 `RequiredNpcOrGoCount3`, `ObjectiveText1`, `ObjectiveText2`, `ObjectiveText3`) VALUES
(9000260, 2, 16, 10, 1519, 5, 0, 6, 450, 8, 9000237, 1, 9000238, 1, 9000239, 1, 72, 5, 1101,
 'The Last Cell',
 'Slay Turnkey Garrow, Sister Cinder, and Warden Blackiron in Stormwind Vault.',
 'The canal gate was never meant to open again. Garrow holds the cellblock. Cinder took the interrogation rooms. Blackiron will not leave the last cell.$B$BFive volunteers. Kill the three keepers and report back. Walk back the way you entered when you are done.',
 'Return to the Vault Warden in Stormwind Vault.',
 9000210, 9000211, 9000212, 1, 1, 1, 'Turnkey Garrow slain', 'Sister Cinder slain',
 'Warden Blackiron slain');

DELETE FROM `quest_template_addon` WHERE `ID` = 9000260;
INSERT INTO `quest_template_addon` (`ID`, `PrevQuestID`, `NextQuestID`, `SpecialFlags`) VALUES
(9000260, 0, 0, 0);

-- Named rooms on the AT-dest floor. Packs 12y+ apart. Casters wander_distance 0.
DELETE FROM `creature` WHERE `guid` BETWEEN 9000502 AND 9000519;
INSERT INTO `creature` (`guid`, `id`, `map`, `spawnMask`, `phaseMask`, `equipment_id`,
 `position_x`, `position_y`, `position_z`, `orientation`, `spawntimesecs`,
 `wander_distance`, `curhealth`, `curmana`, `MovementType`, `Comment`) VALUES
(9000502, 9000202, 35, 1, 1, 0, 22, 42.57, -24.23, 3.1416, 86400, 3, 1, 0, 1, 'Cellblock inmate'),
(9000503, 9000202, 35, 1, 1, 0, 22, 38.57, -24.23, 3.1416, 86400, 3, 1, 0, 1, 'Cellblock inmate'),
(9000504, 9000203, 35, 1, 1, 1, 24, 40.57, -24.23, 3.1416, 86400, 3, 1, 0, 1, 'Cellblock turnkey patrol'),
(9000505, 9000206, 35, 1, 1, 0, 20, 43.57, -24.23, 0.5, 86400, 4, 1, 0, 1, 'Cellblock rat'),
(9000506, 9000206, 35, 1, 1, 0, 20, 37.57, -24.23, 5.5, 86400, 4, 1, 0, 1, 'Cellblock rat'),
(9000507, 9000207, 35, 1, 1, 0, 26, 58.57, -24.23, 3.1416, 86400, 0, 1, 0, 0, 'Chapel acolyte east'),
(9000508, 9000207, 35, 1, 1, 0, 18, 58.57, -24.23, 0, 86400, 0, 1, 0, 0, 'Chapel acolyte west'),
(9000509, 9000207, 35, 1, 1, 0, 22, 62.57, -24.23, 4.7124, 86400, 0, 1, 0, 0, 'Chapel acolyte north'),
(9000510, 9000207, 35, 1, 1, 0, 22, 54.57, -24.23, 1.5708, 86400, 0, 1, 0, 0, 'Chapel acolyte south'),
(9000511, 9000210, 35, 1, 1, 1, 38, 40.57, -24.23, 3.1416, 600, 0, 1, 0, 0, 'Turnkey Garrow'),
(9000512, 9000204, 35, 1, 1, 0, 38, 24.57, -24.23, 1.5708, 86400, 0, 1, 0, 0, 'Interrogation shadowmage'),
(9000513, 9000202, 35, 1, 1, 0, 36, 24.57, -24.23, 1.5708, 86400, 2, 1, 0, 1, 'Interrogation inmate'),
(9000514, 9000208, 35, 1, 1, 0, 40, 24.57, -24.23, 1.5708, 86400, 2, 1, 0, 1, 'Interrogation horror'),
(9000515, 9000211, 35, 1, 1, 1, 54, 40.57, -24.23, 3.1416, 600, 0, 1, 0, 0, 'Sister Cinder'),
(9000516, 9000209, 35, 1, 1, 1, 54, 58.57, -24.23, 4.7124, 86400, 2, 1, 0, 1, 'Last-cell enforcer'),
(9000517, 9000205, 35, 1, 1, 0, 52, 58.57, -24.23, 4.7124, 86400, 3, 1, 0, 1, 'Last-cell rioter'),
(9000518, 9000205, 35, 1, 1, 0, 56, 58.57, -24.23, 4.7124, 86400, 3, 1, 0, 1, 'Last-cell rioter'),
(9000519, 9000212, 35, 1, 1, 1, 70, 40.57, -24.23, 3.1416, 600, 0, 1, 0, 0, 'Warden Blackiron');

DELETE FROM `creature_addon` WHERE `guid` BETWEEN 9000507 AND 9000510;
INSERT INTO `creature_addon` (`guid`, `path_id`, `mount`, `bytes1`, `bytes2`, `emote`,
 `visibilityDistanceType`, `auras`) VALUES
(9000507, 0, 0, 8, 1, 68, 0, NULL),
(9000508, 0, 0, 8, 1, 68, 0, NULL),
(9000509, 0, 0, 8, 1, 68, 0, NULL),
(9000510, 0, 0, 8, 1, 68, 0, NULL);

DELETE FROM `gameobject` WHERE `guid` BETWEEN 9000502 AND 9000540;
INSERT INTO `gameobject` (`guid`, `id`, `map`, `spawnMask`, `phaseMask`, `position_x`,
 `position_y`, `position_z`, `orientation`, `rotation0`, `rotation1`, `rotation2`, `rotation3`,
 `spawntimesecs`, `animprogress`, `state`, `Comment`) VALUES
(9000502, 9000216, 35, 1, 1, 2, 42.57, -24.23, 3.1416, 0, 0, 1, 0, 180, 100, 1, 'Intake lantern'),
(9000503, 9000216, 35, 1, 1, 2, 38.57, -24.23, 3.1416, 0, 0, 1, 0, 180, 100, 1, 'Intake lantern'),
(9000504, 9000215, 35, 1, 1, 6, 40.57, -24.23, 0, 0, 0, 0, 1, 180, 100, 1, 'Intake brazier'),
(9000505, 9000226, 35, 1, 1, 3, 44.57, -24.23, 4.7124, 0, 0, 0.7071, -0.7071, 180, 100, 1, 'Intake notice'),
(9000506, 9000218, 35, 1, 1, 8, 38.57, -24.23, 0.8584, 0, 0, 0.4161, 0.9093, 180, 100, 1, 'Intake crate'),
(9000507, 9000217, 35, 1, 1, 20, 44.57, -24.23, 0, 0, 0, 0, 1, 180, 100, 1, 'Cellblock bars'),
(9000508, 9000217, 35, 1, 1, 20, 36.57, -24.23, 3.1416, 0, 0, 1, 0, 180, 100, 1, 'Cellblock bars'),
(9000509, 9000218, 35, 1, 1, 24, 38.57, -24.23, 3.5416, 0, 0, 0.9801, -0.1987, 180, 100, 1, 'Cellblock crate'),
(9000510, 9000219, 35, 1, 1, 22, 40.57, -24.23, 0, 0, 0, 0, 1, 180, 100, 1, 'Cellblock candle'),
(9000511, 9000216, 35, 1, 1, 26, 40.57, -24.23, 3.1416, 0, 0, 1, 0, 180, 100, 1, 'Cellblock lantern'),
(9000512, 9000221, 35, 1, 1, 22, 58.57, -24.23, 4.7124, 0, 0, 0.7071, -0.7071, 180, 100, 1, 'Chapel shrine'),
(9000513, 9000220, 35, 1, 1, 24, 60.57, -24.23, 5.2416, 0, 0, 0.4976, -0.8674, 180, 100, 1, 'Chapel red candle'),
(9000514, 9000220, 35, 1, 1, 20, 60.57, -24.23, 4.2416, 0, 0, 0.8525, -0.5227, 180, 100, 1, 'Chapel red candle'),
(9000515, 9000220, 35, 1, 1, 24, 56.57, -24.23, 0.8584, 0, 0, 0.4161, 0.9093, 180, 100, 1, 'Chapel red candle'),
(9000516, 9000220, 35, 1, 1, 20, 56.57, -24.23, 2.2, 0, 0, 0.8912, 0.4536, 180, 100, 1, 'Chapel red candle'),
(9000517, 9000228, 35, 1, 1, 22, 61.57, -24.23, 4.7124, 0, 0, 0.7071, -0.7071, 180, 100, 1, 'Chapel tall candle'),
(9000518, 9000222, 35, 1, 1, 38, 44.57, -24.23, 4.7124, 0, 0, 0.7071, -0.7071, 68, 100, 1, 'Garrow lever north'),
(9000519, 9000222, 35, 1, 1, 38, 36.57, -24.23, 1.5708, 0, 0, 0.7071, 0.7071, 68, 100, 1, 'Garrow lever south'),
(9000520, 9000222, 35, 1, 1, 42, 40.57, -24.23, 3.1416, 0, 0, 1, 0, 68, 100, 1, 'Garrow lever east'),
(9000521, 9000227, 35, 1, 1, 40, 38.57, -24.23, 3.7416, 0, 0, 0.9553, -0.2955, 180, 100, 1, 'Garrow weapon rack'),
(9000522, 9000215, 35, 1, 1, 36, 40.57, -24.23, 0, 0, 0, 0, 1, 180, 100, 1, 'Garrow brazier'),
(9000523, 9000217, 35, 1, 1, 34, 44.57, -24.23, 0, 0, 0, 0, 1, 180, 100, 1, 'Garrow cell bars'),
(9000524, 9000223, 35, 1, 1, 38, 22.57, -24.23, 1.5708, 0, 0, 0.7071, 0.7071, 180, 100, 1, 'Interrogation rack'),
(9000525, 9000224, 35, 1, 1, 36, 22.57, -24.23, 5.9416, 0, 0, 0.17, -0.9855, 180, 100, 1, 'Interrogation brazier'),
(9000526, 9000218, 35, 1, 1, 40, 22.57, -24.23, 3.7416, 0, 0, 0.9553, -0.2955, 180, 100, 1, 'Interrogation crate'),
(9000527, 9000216, 35, 1, 1, 38, 26.57, -24.23, 1.5708, 0, 0, 0.7071, 0.7071, 180, 100, 1, 'Interrogation lantern'),
(9000528, 9000224, 35, 1, 1, 54, 44.57, -24.23, 0, 0, 0, 0, 1, 180, 100, 1, 'Cinder brazier north'),
(9000529, 9000224, 35, 1, 1, 54, 37.57, -24.23, 3.1416, 0, 0, 1, 0, 180, 100, 1, 'Cinder brazier south'),
(9000530, 9000220, 35, 1, 1, 52, 40.57, -24.23, 4.2416, 0, 0, 0.8525, -0.5227, 180, 100, 1, 'Cinder red candle'),
(9000531, 9000228, 35, 1, 1, 56, 40.57, -24.23, 3.1416, 0, 0, 1, 0, 180, 100, 1, 'Cinder tall candle'),
(9000532, 9000217, 35, 1, 1, 54, 60.57, -24.23, 4.7124, 0, 0, 0.7071, -0.7071, 180, 100, 1, 'Last-cell bars'),
(9000533, 9000218, 35, 1, 1, 52, 56.57, -24.23, 0.4584, 0, 0, 0.2272, 0.9738, 180, 100, 1, 'Last-cell crate'),
(9000534, 9000216, 35, 1, 1, 56, 56.57, -24.23, 5.9416, 0, 0, 0.17, -0.9855, 180, 100, 1, 'Last-cell lantern'),
(9000535, 9000225, 35, 1, 1, 66, 40.57, -24.23, 3.1416, 0, 0, 1, 0, 68, 100, 1, 'Blackiron cell wheel'),
(9000536, 9000227, 35, 1, 1, 70, 44.57, -24.23, 4.7124, 0, 0, 0.7071, -0.7071, 180, 100, 1, 'Blackiron weapon rack'),
(9000537, 9000224, 35, 1, 1, 70, 37.57, -24.23, 0, 0, 0, 0, 1, 180, 100, 1, 'Blackiron brazier'),
(9000538, 9000226, 35, 1, 1, 68, 42.57, -24.23, 4.7124, 0, 0, 0.7071, -0.7071, 180, 100, 1, 'Blackiron notice'),
(9000539, 9000228, 35, 1, 1, 72, 40.57, -24.23, 3.1416, 0, 0, 1, 0, 180, 100, 1, 'Blackiron tall candle'),
(9000540, 9000220, 35, 1, 1, 68, 38.57, -24.23, 5.1, 0, 0, 0.5577, -0.8301, 180, 100, 1, 'Blackiron red candle');

-- Stormwind Vault SmartAI. Full-block rewrite per (entryorguid, source_type).

DELETE FROM `smart_scripts` WHERE `entryorguid` = 9000202 AND `source_type` = 0;
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`,
 `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`,
 `event_param3`, `event_param4`, `event_param5`, `event_param6`, `action_type`,
 `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`,
 `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`,
 `target_param4`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(9000202, 0, 0, 0, 4, 0, 100, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Inmate - On Aggro - Talk'),
(9000202, 0, 1, 0, 0, 0, 100, 0, 3000, 6000, 10000, 14000, 0, 0, 11, 1776, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Inmate - IC - Gouge');
DELETE FROM `smart_scripts` WHERE `entryorguid` = 9000203 AND `source_type` = 0;
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`,
 `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`,
 `event_param3`, `event_param4`, `event_param5`, `event_param6`, `action_type`,
 `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`,
 `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`,
 `target_param4`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(9000203, 0, 0, 0, 0, 0, 100, 0, 4000, 7000, 18000, 24000, 0, 0, 11, 6016, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Turnkey - IC - Pierce Armor'),
(9000203, 0, 1, 0, 0, 0, 100, 0, 3000, 6000, 10000, 14000, 0, 0, 11, 8646, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Turnkey - IC - Snap Kick');
DELETE FROM `smart_scripts` WHERE `entryorguid` = 9000204 AND `source_type` = 0;
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`,
 `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`,
 `event_param3`, `event_param4`, `event_param5`, `event_param6`, `action_type`,
 `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`,
 `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`,
 `target_param4`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(9000204, 0, 0, 0, 1, 0, 100, 0, 1000, 1000, 1800000, 1800000, 0, 0, 11, 12544, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Shadowmage - OOC - Frost Armor'),
(9000204, 0, 1, 0, 0, 0, 100, 0, 0, 0, 2400, 3800, 0, 0, 11, 7641, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Shadowmage - IC CMC - Shadow Bolt'),
(9000204, 0, 2, 0, 0, 0, 100, 0, 8000, 12000, 16000, 22000, 0, 0, 11, 14032, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 'Shadowmage - IC - SW:P random');
DELETE FROM `smart_scripts` WHERE `entryorguid` = 9000205 AND `source_type` = 0;
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`,
 `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`,
 `event_param3`, `event_param4`, `event_param5`, `event_param6`, `action_type`,
 `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`,
 `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`,
 `target_param4`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(9000205, 0, 0, 0, 0, 0, 100, 0, 1000, 3000, 15000, 18000, 0, 0, 11, 6268, 0, 0, 0, 0, 0, 28, 30, 1, 0, 0, 0, 0, 0, 0, 'Rioter - IC - Rushing Charge farthest'),
(9000205, 0, 1, 0, 2, 0, 100, 1, 0, 30, 0, 0, 0, 0, 11, 8599, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Rioter - 30% - Enrage');
DELETE FROM `smart_scripts` WHERE `entryorguid` = 9000206 AND `source_type` = 0;
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`,
 `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`,
 `event_param3`, `event_param4`, `event_param5`, `event_param6`, `action_type`,
 `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`,
 `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`,
 `target_param4`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(9000206, 0, 0, 0, 0, 0, 100, 0, 2000, 5000, 12000, 16000, 0, 0, 11, 6730, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Rat - IC - Head Butt');
DELETE FROM `smart_scripts` WHERE `entryorguid` = 9000207 AND `source_type` = 0;
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`,
 `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`,
 `event_param3`, `event_param4`, `event_param5`, `event_param6`, `action_type`,
 `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`,
 `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`,
 `target_param4`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(9000207, 0, 0, 1, 25, 0, 100, 0, 0, 0, 0, 0, 0, 0, 90, 8, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Acolyte - Reset - Kneel standstate'),
(9000207, 0, 1, 0, 61, 0, 100, 0, 0, 0, 0, 0, 0, 0, 17, 68, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Acolyte - Link - Kneel emote'),
(9000207, 0, 2, 3, 4, 0, 100, 0, 0, 0, 0, 0, 0, 0, 91, 8, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Acolyte - On Aggro - Stand'),
(9000207, 0, 3, 4, 61, 0, 100, 0, 0, 0, 0, 0, 0, 0, 17, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Acolyte - Link - Clear emote'),
(9000207, 0, 4, 0, 61, 0, 100, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Acolyte - Link - Talk'),
(9000207, 0, 5, 0, 0, 0, 100, 0, 0, 0, 2400, 3800, 0, 0, 11, 7641, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Acolyte - IC CMC - Shadow Bolt');
DELETE FROM `smart_scripts` WHERE `entryorguid` = 9000208 AND `source_type` = 0;
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`,
 `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`,
 `event_param3`, `event_param4`, `event_param5`, `event_param6`, `action_type`,
 `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`,
 `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`,
 `target_param4`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(9000208, 0, 0, 0, 0, 0, 100, 0, 4000, 7000, 16000, 22000, 0, 0, 11, 6016, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Horror - IC - Pierce Armor'),
(9000208, 0, 1, 0, 2, 0, 100, 1, 0, 30, 0, 0, 0, 0, 11, 8599, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Horror - 30% - Enrage');
DELETE FROM `smart_scripts` WHERE `entryorguid` = 9000209 AND `source_type` = 0;
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`,
 `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`,
 `event_param3`, `event_param4`, `event_param5`, `event_param6`, `action_type`,
 `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`,
 `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`,
 `target_param4`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(9000209, 0, 0, 0, 0, 0, 100, 0, 2000, 4000, 20000, 30000, 0, 0, 11, 9128, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Enforcer - IC - Battle Shout'),
(9000209, 0, 1, 0, 0, 0, 100, 0, 6000, 10000, 14000, 18000, 0, 0, 11, 11428, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Enforcer - IC - Knockdown');

DELETE FROM `reference_loot_template` WHERE `Entry` = 9000102;
INSERT INTO `reference_loot_template` (`Entry`, `Item`, `Reference`, `Chance`, `QuestRequired`,
 `LootMode`, `GroupId`, `MinCount`, `MaxCount`, `Comment`) VALUES
(9000102, 9000237, 0, 0, 0, 1, 1, 1, 1, 'Vault green - Turnkey Leggings'),
(9000102, 9000238, 0, 0, 0, 1, 1, 1, 1, 'Vault green - Inmate Tunic'),
(9000102, 9000239, 0, 0, 0, 1, 1, 1, 1, 'Vault green - Vault-Issue Staff'),
(9000102, 9000240, 0, 0, 0, 1, 1, 1, 1, 'Vault green - Cinderwrap Gloves'),
(9000102, 9000241, 0, 0, 0, 1, 1, 1, 1, 'Vault green - Shadow-Soot Cowl'),
(9000102, 9000242, 0, 0, 0, 1, 1, 1, 1, 'Vault green - Blackiron Treads'),
(9000102, 9000243, 0, 0, 0, 1, 1, 1, 1, 'Vault green - Garrow Cudgel'),
(9000102, 9000244, 0, 0, 0, 1, 1, 1, 1, 'Vault green - Last Cell Shiv');

DELETE FROM `creature_loot_template` WHERE `Entry` IN (9000202,9000203,9000204,9000205,9000206,9000207,9000208,9000209,9000210,9000211,9000212);
INSERT INTO `creature_loot_template` (`Entry`, `Item`, `Reference`, `Chance`, `QuestRequired`,
 `LootMode`, `GroupId`, `MinCount`, `MaxCount`, `Comment`) VALUES
(9000202, 9000231, 0, 45, 0, 1, 0, 1, 1, 'Inmate - Torn Sentence'),
(9000202, 9000232, 0, 30, 0, 1, 0, 1, 1, 'Inmate - Mouldy Ration'),
(9000202, 2589, 0, 30, 0, 1, 0, 1, 2, 'Inmate - Linen Cloth'),
(9000202, 0, 9000102, 6, 0, 1, 0, 1, 1, 'Inmate - Vault green'),
(9000203, 9000230, 0, 50, 0, 1, 0, 1, 1, 'Turnkey - Rusted Cell Key'),
(9000203, 2589, 0, 30, 0, 1, 0, 1, 2, 'Turnkey - Linen Cloth'),
(9000203, 0, 9000102, 7, 0, 1, 0, 1, 1, 'Turnkey - Vault green'),
(9000204, 9000234, 0, 45, 0, 1, 0, 1, 1, 'Shadowmage - Confessor Note'),
(9000204, 2589, 0, 25, 0, 1, 0, 1, 2, 'Shadowmage - Linen Cloth'),
(9000204, 0, 9000102, 8, 0, 1, 0, 1, 1, 'Shadowmage - Vault green'),
(9000205, 9000231, 0, 40, 0, 1, 0, 1, 1, 'Rioter - Torn Sentence'),
(9000205, 2589, 0, 30, 0, 1, 0, 1, 2, 'Rioter - Linen Cloth'),
(9000205, 0, 9000102, 6, 0, 1, 0, 1, 1, 'Rioter - Vault green'),
(9000206, 9000232, 0, 40, 0, 1, 0, 1, 1, 'Rat - Mouldy Ration'),
(9000206, 0, 9000102, 4, 0, 1, 0, 1, 1, 'Rat - Vault green'),
(9000207, 9000234, 0, 50, 0, 1, 0, 1, 1, 'Acolyte - Confessor Note'),
(9000207, 2589, 0, 25, 0, 1, 0, 1, 2, 'Acolyte - Linen Cloth'),
(9000207, 0, 9000102, 7, 0, 1, 0, 1, 1, 'Acolyte - Vault green'),
(9000208, 9000233, 0, 60, 0, 1, 0, 1, 2, 'Horror - Shackle Fragment'),
(9000208, 0, 9000102, 6, 0, 1, 0, 1, 1, 'Horror - Vault green'),
(9000209, 9000230, 0, 45, 0, 1, 0, 1, 1, 'Enforcer - Rusted Cell Key'),
(9000209, 2589, 0, 30, 0, 1, 0, 1, 2, 'Enforcer - Linen Cloth'),
(9000209, 0, 9000102, 8, 0, 1, 0, 1, 1, 'Enforcer - Vault green'),
(9000210, 9000230, 0, 100, 0, 1, 0, 1, 2, 'Garrow - Rusted Cell Key'),
(9000210, 9000235, 0, 60, 0, 1, 0, 1, 1, 'Garrow - Ledger Page'),
(9000210, 9000243, 0, 22, 0, 1, 1, 1, 1, 'Garrow - Cudgel'),
(9000210, 9000237, 0, 14, 0, 1, 1, 1, 1, 'Garrow - Turnkey Leggings'),
(9000210, 9000238, 0, 14, 0, 1, 1, 1, 1, 'Garrow - Inmate Tunic'),
(9000210, 9000244, 0, 14, 0, 1, 1, 1, 1, 'Garrow - Last Cell Shiv'),
(9000210, 9000239, 0, 14, 0, 1, 1, 1, 1, 'Garrow - Vault-Issue Staff'),
(9000211, 9000234, 0, 100, 0, 1, 0, 1, 2, 'Cinder - Confessor Note'),
(9000211, 9000241, 0, 22, 0, 1, 1, 1, 1, 'Cinder - Shadow-Soot Cowl'),
(9000211, 9000240, 0, 14, 0, 1, 1, 1, 1, 'Cinder - Cinderwrap Gloves'),
(9000211, 9000237, 0, 14, 0, 1, 1, 1, 1, 'Cinder - Turnkey Leggings'),
(9000211, 9000238, 0, 14, 0, 1, 1, 1, 1, 'Cinder - Inmate Tunic'),
(9000211, 9000239, 0, 14, 0, 1, 1, 1, 1, 'Cinder - Vault-Issue Staff'),
(9000212, 9000235, 0, 100, 0, 1, 0, 1, 2, 'Blackiron - Ledger Page'),
(9000212, 9000242, 0, 22, 0, 1, 1, 1, 1, 'Blackiron - Treads'),
(9000212, 9000237, 0, 12, 0, 1, 1, 1, 1, 'Blackiron - Turnkey Leggings'),
(9000212, 9000238, 0, 12, 0, 1, 1, 1, 1, 'Blackiron - Inmate Tunic'),
(9000212, 9000239, 0, 12, 0, 1, 1, 1, 1, 'Blackiron - Vault-Issue Staff'),
(9000212, 9000243, 0, 12, 0, 1, 1, 1, 1, 'Blackiron - Cudgel');

DELETE FROM `creature_text` WHERE `CreatureID` IN (9000202, 9000207, 9000210, 9000211, 9000212);
INSERT INTO `creature_text` (`CreatureID`, `GroupID`, `ID`, `Text`, `Type`, `Language`,
 `Probability`, `Emote`, `Duration`, `Sound`, `BroadcastTextId`, `TextRange`, `comment`) VALUES
(9000202, 0, 0, 'The last cell opened. You opened nothing.', 12, 0, 50, 0, 0, 0, 0, 0, 'Inmate aggro'),
(9000202, 0, 1, 'Garrow said nobody leaves!', 12, 0, 50, 0, 0, 0, 0, 0, 'Inmate aggro'),
(9000207, 0, 0, 'Confess. The vault is listening.', 12, 0, 100, 0, 0, 0, 0, 0, 'Acolyte aggro'),
(9000210, 0, 0, 'Nobody leaves. That is the rule.', 14, 0, 100, 0, 0, 0, 0, 0, 'Garrow aggro'),
(9000210, 1, 0, 'Cells open! Let them earn their keep!', 14, 0, 100, 0, 0, 0, 0, 0, 'Garrow cells'),
(9000210, 2, 0, 'You pulled a lever. Now you share a cell.', 14, 0, 100, 0, 0, 0, 0, 0, 'Garrow lever'),
(9000210, 3, 0, 'The last cell... stay out...', 14, 0, 100, 0, 0, 0, 0, 0, 'Garrow death'),
(9000211, 0, 0, 'Kneel. The vault takes testimony.', 14, 0, 100, 0, 0, 0, 0, 0, 'Cinder aggro'),
(9000211, 1, 0, 'Speak. The fire already knows.', 14, 0, 100, 0, 0, 0, 0, 0, 'Cinder confess'),
(9000211, 2, 0, 'Your secrets are loud.', 14, 0, 100, 0, 0, 0, 0, 0, 'Cinder scream'),
(9000211, 3, 0, 'The book... still... open...', 14, 0, 100, 0, 0, 0, 0, 0, 'Cinder death'),
(9000212, 0, 0, 'I kept this door shut for twenty years. You will not open it.', 14, 0, 100, 0, 0, 0, 0, 0, 'Blackiron aggro'),
(9000212, 1, 0, 'Lockdown. Enforcers, to me.', 14, 0, 100, 0, 0, 0, 0, 0, 'Blackiron lockdown'),
(9000212, 2, 0, 'The wheel still turns. So do I.', 14, 0, 100, 0, 0, 0, 0, 0, 'Blackiron enrage'),
(9000212, 3, 0, 'The locks... they remember...', 14, 0, 100, 0, 0, 0, 0, 0, 'Blackiron wheel'),
(9000212, 4, 0, 'Tell the canal... the vault... was never empty...', 14, 0, 100, 0, 0, 0, 0, 0, 'Blackiron death');

DELETE FROM `creature_queststarter` WHERE `id` = 9000200 AND `quest` = 9000260;
INSERT INTO `creature_queststarter` (`id`, `quest`) VALUES
(9000200, 9000260);

DELETE FROM `creature_questender` WHERE `id` = 9000200 AND `quest` = 9000260;
INSERT INTO `creature_questender` (`id`, `quest`) VALUES
(9000200, 9000260);

DELETE FROM `quest_request_items` WHERE `ID` = 9000260;
INSERT INTO `quest_request_items` (`ID`, `EmoteOnComplete`, `EmoteOnIncomplete`, `CompletionText`) VALUES
(9000260, 0, 0, 'The last cell is still shut. Get back in there.');

DELETE FROM `quest_offer_reward` WHERE `ID` = 9000260;
INSERT INTO `quest_offer_reward` (`ID`, `Emote1`, `Emote2`, `Emote3`, `Emote4`, `EmoteDelay1`,
 `EmoteDelay2`, `EmoteDelay3`, `EmoteDelay4`, `RewardText`) VALUES
(9000260, 0, 0, 0, 0, 0, 0, 0, 0, 'The canal will not mention this. Walk back the way you came. I will still be here.');
