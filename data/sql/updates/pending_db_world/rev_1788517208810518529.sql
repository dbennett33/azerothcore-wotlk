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
(9000200, 'Vault Warden', 'Stormwind Vault', 30, 30, 12, 1, 9000200, 1, 1.42857, 18, 0, 1, 2000, 2000, 1, 512, 2048, 7, 0, 0, 0, '', 1.5, 1, 1, 0, '', 0);

DELETE FROM `creature_template_model` WHERE `CreatureID` = 9000200;
INSERT INTO `creature_template_model` (`CreatureID`, `Idx`, `CreatureDisplayID`, `DisplayScale`, `Probability`, `VerifiedBuild`) VALUES
(9000200, 0, 3167, 1, 1, 0);

DELETE FROM `npc_text` WHERE `ID` = 9000200;
INSERT INTO `npc_text` (`ID`, `text0_0`, `text0_1`, `Probability0`) VALUES
(9000200, 'The Vault has been sealed for years. You came through the canal gate — walk back the way you entered to return to Stormwind.$B$BThe cells are empty. For now.', '', 1);

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
