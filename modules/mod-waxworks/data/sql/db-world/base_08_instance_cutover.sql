-- Cut The Waxworks over to map 44 (custom cave WMO). Live DB already has overlay rows.

UPDATE `instance_template` SET `script` = 'instance_waxworks' WHERE `map` = 44;

DELETE FROM `dungeon_access_template` WHERE `id` = 122;
INSERT INTO `dungeon_access_template` (`id`, `map_id`, `difficulty`, `min_level`, `max_level`, `min_avg_item_level`, `comment`) VALUES
(122, 44, 0, 7, 0, 0, 'The Waxworks');

DELETE FROM `mapdifficulty_dbc` WHERE `ID` = 9000044;
INSERT INTO `mapdifficulty_dbc` (`ID`, `MapID`, `Difficulty`, `Message_Lang_enUS`, `Message_Lang_Mask`, `RaidDuration`, `MaxPlayers`, `Difficultystring`) VALUES
(9000044, 44, 0, '', 16712190, 0, 5, '');

-- Mouth stand: Blender (12, 0, 0.15) -> world (-12, 0, 0.15) facing inbound (-X).
DELETE FROM `game_tele` WHERE `id` = 9000044 OR `name` = 'wax44_mouth';
INSERT INTO `game_tele` (`id`, `position_x`, `position_y`, `position_z`, `orientation`, `map`, `name`) VALUES
(9000044, -12, 0, 0.15, 3.1416, 44, 'wax44_mouth');

-- Wickworks stand: Blender (46, 0, 0.15) -> world (-46, 0, 0.15). Same facing.
DELETE FROM `game_tele` WHERE `id` = 9000045 OR `name` = 'wax44_wickworks';
INSERT INTO `game_tele` (`id`, `position_x`, `position_y`, `position_z`, `orientation`, `map`, `name`) VALUES
(9000045, -46, 0, 0.15, 3.1416, 44, 'wax44_wickworks');

-- NorthShrine stand: Blender (46, 32, 1.15) -> world (-46, -32, 1.15). Same facing.
DELETE FROM `game_tele` WHERE `id` = 9000046 OR `name` = 'wax44_northshrine';
INSERT INTO `game_tele` (`id`, `position_x`, `position_y`, `position_z`, `orientation`, `map`, `name`) VALUES
(9000046, -46, -32, 1.15, 3.1416, 44, 'wax44_northshrine');

-- WestShrine stand: Blender (22, -28, 0.15) -> world (-22, 28, 0.15). Same facing.
DELETE FROM `game_tele` WHERE `id` = 9000047 OR `name` = 'wax44_westshrine';
INSERT INTO `game_tele` (`id`, `position_x`, `position_y`, `position_z`, `orientation`, `map`, `name`) VALUES
(9000047, -22, 28, 0.15, 3.1416, 44, 'wax44_westshrine');

-- KingWick stand: gps-verified world (-88, 0, 0.50) facing inbound (π). FloorZ 0.5.
DELETE FROM `game_tele` WHERE `id` = 9000048 OR `name` = 'wax44_kingwick';
INSERT INTO `game_tele` (`id`, `position_x`, `position_y`, `position_z`, `orientation`, `map`, `name`) VALUES
(9000048, -88, 0, 0.50, 3.1416, 44, 'wax44_kingwick');

-- Commissary stand: gps-verified world (-88, 32, -7) facing inbound (π). FloorZ -7.
DELETE FROM `game_tele` WHERE `id` = 9000049 OR `name` = 'wax44_commissary';
INSERT INTO `game_tele` (`id`, `position_x`, `position_y`, `position_z`, `orientation`, `map`, `name`) VALUES
(9000049, -88, 32, -7, 3.1416, 44, 'wax44_commissary');

-- MurlocAlcove stand: gps-verified world (-88, 52, -6.5) facing inbound (π). FloorZ -6.5.
DELETE FROM `game_tele` WHERE `id` = 9000050 OR `name` = 'wax44_murlocalcove';
INSERT INTO `game_tele` (`id`, `position_x`, `position_y`, `position_z`, `orientation`, `map`, `name`) VALUES
(9000050, -88, 52, -6.5, 3.1416, 44, 'wax44_murlocalcove');

-- BargainingTable stand: gps-verified world (-136, 0, 0.50) facing inbound (π). FloorZ 0.5.
DELETE FROM `game_tele` WHERE `id` = 9000051 OR `name` = 'wax44_bargaining';
INSERT INTO `game_tele` (`id`, `position_x`, `position_y`, `position_z`, `orientation`, `map`, `name`) VALUES
(9000051, -136, 0, 0.50, 3.1416, 44, 'wax44_bargaining');

-- PumpkinSty stand: gps-verified world (-88, -32, 9.50) facing inbound (π). FloorZ 9.5.
DELETE FROM `game_tele` WHERE `id` = 9000052 OR `name` = 'wax44_pumpkinsty';
INSERT INTO `game_tele` (`id`, `position_x`, `position_y`, `position_z`, `orientation`, `map`, `name`) VALUES
(9000052, -88, -32, 9.50, 3.1416, 44, 'wax44_pumpkinsty');
