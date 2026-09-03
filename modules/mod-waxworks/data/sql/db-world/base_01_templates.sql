-- The Waxworks templates. Custom ids 9000000-9000199 only.
-- Do not touch Goldtooth guid 80644 at -9745.84, 87.57, 12.77.

DELETE FROM `creature_template` WHERE `entry` BETWEEN 9000001 AND 9000050;
INSERT INTO `creature_template` (`entry`, `name`, `subname`, `minlevel`, `maxlevel`, `faction`,
 `npcflag`, `gossip_menu_id`, `speed_walk`, `speed_run`, `detection_range`, `rank`,
 `DamageModifier`, `BaseAttackTime`, `RangeAttackTime`, `unit_class`, `unit_flags`,
 `unit_flags2`, `type`, `lootid`, `mingold`, `maxgold`, `AIName`, `HealthModifier`, `ManaModifier`,
 `RegenHealth`, `flags_extra`, `ScriptName`, `VerifiedBuild`) VALUES
(9000001, 'Wickworks Scamp', 'The Waxworks', 7, 8, 26, 0, 0, 1, 0.85714, 18, 1, 1.45, 2000, 2000, 1, 0, 2048, 7, 9000001, 8, 22, 'SmartAI', 2.4, 1, 1, 0, '', 0),
(9000002, 'Wickworks Tunneler', 'The Waxworks', 8, 8, 26, 0, 0, 1, 0.85714, 18, 1, 1.5, 2000, 2000, 1, 0, 2048, 7, 9000002, 10, 24, 'SmartAI', 2.5, 1, 1, 0, '', 0),
(9000003, 'Wickworks Wickmage', 'The Waxworks', 8, 9, 26, 0, 0, 1, 0.85714, 18, 1, 1.4, 2000, 2000, 8, 0, 2048, 7, 9000003, 12, 28, 'SmartAI', 2.3, 2, 1, 0, '', 0),
(9000004, 'Wickworks Hauler', 'The Waxworks', 8, 8, 26, 0, 0, 1, 0.85714, 18, 1, 1.5, 2000, 2000, 1, 0, 2048, 7, 9000004, 10, 24, 'SmartAI', 2.5, 1, 1, 0, '', 0),
(9000005, 'Candle Cart', 'The Waxworks', 8, 8, 26, 0, 0, 1, 0.85714, 12, 1, 1.3, 2000, 2000, 1, 512, 2048, 9, 9000005, 20, 40, 'SmartAI', 2.2, 1, 1, 0, '', 0),
(9000006, 'Gug the Night Shift', 'The Waxworks', 9, 9, 26, 0, 0, 1, 0.85714, 18, 1, 1.8, 2000, 2000, 1, 0, 2048, 7, 9000006, 28, 55, 'SmartAI', 3.5, 1, 1, 0, '', 0),
(9000007, 'Line Cook', 'The Waxworks', 9, 9, 20, 0, 0, 1.2, 1.14286, 18, 1, 1.5, 2000, 2000, 1, 0, 2048, 7, 9000007, 14, 32, 'SmartAI', 2.6, 1, 1, 0, '', 0),
(9000008, 'Dishwasher', 'The Waxworks', 9, 10, 20, 0, 0, 1.2, 1.14286, 18, 1, 1.5, 2000, 2000, 1, 0, 2048, 7, 9000008, 14, 32, 'SmartAI', 2.6, 1, 1, 0, '', 0),
(9000009, 'Fry-Oracle', 'The Waxworks', 10, 10, 20, 0, 0, 1, 1.14286, 18, 1, 1.45, 2000, 2000, 2, 0, 2048, 7, 9000009, 16, 36, 'SmartAI', 2.5, 2, 1, 0, '', 0),
(9000010, 'Grease Patrol', 'The Waxworks', 9, 9, 20, 0, 0, 1, 1.19048, 18, 1, 1.55, 2000, 2000, 1, 0, 2048, 7, 9000010, 14, 32, 'SmartAI', 2.6, 1, 1, 0, '', 0),
(9000011, 'Murloc Consultant', 'The Waxworks', 9, 9, 18, 0, 0, 1, 0.85714, 18, 1, 1.5, 2000, 2000, 1, 0, 2048, 7, 9000011, 12, 30, 'SmartAI', 2.5, 1, 1, 0, '', 0),
(9000012, 'Shop Steward', 'The Waxworks', 10, 10, 17, 0, 0, 1, 0.85714, 18, 1, 1.55, 2000, 2000, 1, 0, 2048, 7, 9000012, 18, 40, 'SmartAI', 2.7, 1, 1, 0, '', 0),
(9000013, 'Contract Mage', 'The Waxworks', 10, 10, 17, 0, 0, 1, 0.85714, 18, 1, 1.45, 2000, 2000, 8, 0, 2048, 7, 9000013, 18, 40, 'SmartAI', 2.5, 2, 1, 0, '', 0),
(9000014, 'Clerk of Grievances', 'The Waxworks', 11, 11, 17, 0, 0, 1, 0.85714, 18, 1, 1.8, 2000, 2000, 1, 0, 2048, 7, 9000014, 32, 60, 'SmartAI', 3.5, 1, 1, 0, '', 0),
(9000015, 'Union Bodyguard', 'The Waxworks', 10, 10, 17, 0, 0, 1, 1.14286, 18, 1, 1.6, 2000, 2000, 1, 0, 2048, 7, 9000015, 18, 40, 'SmartAI', 2.8, 1, 1, 0, '', 0),
(9000016, 'Grease Boar', 'The Waxworks', 9, 9, 14, 0, 0, 1, 0.85714, 18, 1, 1.5, 2000, 2000, 1, 0, 2048, 1, 9000016, 8, 20, 'SmartAI', 2.4, 1, 1, 0, '', 0),
(9000017, 'Dripping Wax', 'The Waxworks', 8, 8, 26, 0, 0, 1, 0.85714, 16, 1, 1.4, 2000, 2000, 1, 0, 2048, 4, 9000017, 10, 22, 'SmartAI', 2.3, 1, 1, 0, '', 0),
(9000018, 'Vat Tender', 'The Waxworks', 8, 9, 26, 0, 0, 1, 0.85714, 18, 1, 1.5, 2000, 2000, 1, 0, 2048, 7, 9000018, 12, 26, 'SmartAI', 2.5, 1, 1, 0, '', 0),
(9000019, 'Wickworks Acolyte', 'The Waxworks', 7, 8, 26, 0, 0, 1, 0.85714, 10, 1, 1.35, 2000, 2000, 1, 0, 2048, 7, 9000001, 8, 22, 'SmartAI', 2.2, 1, 1, 0, '', 0),
(9000020, 'King Wick', 'Candle King', 10, 10, 26, 0, 0, 1, 0.85714, 16, 1, 2.2, 2000, 2000, 8, 0, 2048, 7, 9000020, 55, 95, '', 7, 3, 1, 0, 'boss_king_wick', 0),
(9000021, 'Hot Wax', '', 1, 1, 14, 0, 0, 1, 1, 1, 0, 1, 2000, 2000, 1, 768, 0, 10, 0, 0, 0, '', 0.1, 1, 1, 128, '', 0),
(9000030, 'Chef Snarlroast', 'Riverpaw Executive Chef', 11, 11, 20, 0, 0, 1, 1.19048, 16, 1, 2.1, 2000, 2000, 1, 0, 2048, 7, 9000030, 65, 110, '', 6, 1, 1, 0, 'boss_chef_snarlroast', 0),
(9000031, 'Fire Trail', '', 1, 1, 14, 0, 0, 1, 1, 1, 0, 1, 2000, 2000, 1, 768, 0, 10, 0, 0, 0, 'SmartAI', 0.1, 1, 1, 128, '', 0),
(9000040, 'Foreman Overtime Voss', 'Brotherhood Local 12', 12, 12, 17, 1, 9000010, 1, 1.14286, 16, 1, 2.3, 2000, 2000, 1, 0, 2048, 7, 9000040, 80, 140, '', 7, 1, 1, 0, 'boss_foreman_voss', 0),
(9000045, 'H.R.H. Princess', 'First Prize, Self-Appointed', 11, 11, 14, 0, 0, 1, 0.85714, 16, 1, 1.9, 2000, 2000, 1, 0, 2048, 1, 9000045, 40, 75, '', 5, 1, 1, 0, 'boss_princess', 0),
(9000046, 'Sir Oinksworth', 'The Waxworks', 9, 9, 14, 0, 0, 1, 0.85714, 18, 1, 1.5, 2000, 2000, 1, 0, 2048, 1, 9000046, 8, 20, 'SmartAI', 2.4, 1, 1, 0, '', 0),
(9000047, 'Unit 07', 'The Waxworks', 11, 11, 14, 0, 0, 1, 1.14286, 16, 1, 1.8, 2000, 2000, 1, 0, 2048, 9, 9000047, 20, 45, '', 3.5, 1, 1, 0, 'npc_unit_07', 0),
(9000048, 'Lady Crackling', 'The Waxworks', 9, 9, 14, 0, 0, 1, 0.85714, 18, 1, 1.5, 2000, 2000, 1, 0, 2048, 1, 9000048, 8, 20, 'SmartAI', 2.4, 1, 1, 0, '', 0),
(9000049, 'The Honourable Ham', 'The Waxworks', 9, 9, 14, 0, 0, 1, 0.85714, 18, 1, 1.5, 2000, 2000, 1, 0, 2048, 1, 9000049, 8, 20, 'SmartAI', 2.4, 1, 1, 0, '', 0),
(9000050, 'Sergeant Wickham', 'Stormwind Survey Corps', 30, 30, 12, 3, 9000000, 1, 1.42857, 18, 0, 1, 2000, 2000, 1, 32768, 2048, 7, 0, 0, 0, '', 1.5, 1, 1, 0, 'npc_sergeant_wickham', 0);

DELETE FROM `creature_template_model` WHERE `CreatureID` BETWEEN 9000001 AND 9000050;
INSERT INTO `creature_template_model` (`CreatureID`, `Idx`, `CreatureDisplayID`, `DisplayScale`, `Probability`, `VerifiedBuild`) VALUES
(9000001, 0, 10913, 1, 1, 0),
(9000002, 0, 373, 1, 1, 0),
(9000003, 0, 163, 1, 1, 0),
(9000004, 0, 365, 1, 1, 0),
(9000005, 0, 365, 1, 1, 0),
(9000006, 0, 26, 1.15, 1, 0),
(9000007, 0, 175, 1, 1, 0),
(9000008, 0, 175, 1, 1, 0),
(9000009, 0, 204, 1, 1, 0),
(9000010, 0, 374, 1, 1, 0),
(9000011, 0, 441, 1, 1, 0),
(9000012, 0, 2357, 1, 1, 0),
(9000013, 0, 2359, 1, 1, 0),
(9000014, 0, 2074, 1, 1, 0),
(9000015, 0, 2340, 1, 1, 0),
(9000016, 0, 503, 1, 1, 0),
(9000017, 0, 1306, 0.75, 1, 0),
(9000018, 0, 373, 1, 1, 0),
(9000019, 0, 10913, 1, 1, 0),
(9000020, 0, 26, 1.7, 1, 0),
(9000021, 0, 11686, 1, 1, 0),
(9000030, 0, 10790, 1.4, 1, 0),
(9000031, 0, 11686, 1, 1, 0),
(9000040, 0, 2312, 1.35, 1, 0),
(9000045, 0, 8871, 1.5, 1, 0),
(9000046, 0, 377, 1, 1, 0),
(9000047, 0, 378, 1.1, 1, 0),
(9000048, 0, 377, 1, 1, 0),
(9000049, 0, 377, 1, 1, 0),
(9000050, 0, 3167, 1, 1, 0);

DELETE FROM `creature_equip_template` WHERE `CreatureID` IN (9000012, 9000030, 9000040, 9000050);
INSERT INTO `creature_equip_template` (`CreatureID`, `ID`, `ItemID1`, `ItemID2`, `ItemID3`, `VerifiedBuild`) VALUES
(9000012, 1, 1896, 0, 0, 0),
(9000030, 1, 3351, 0, 0, 0),
(9000040, 1, 5281, 0, 0, 0),
(9000040, 2, 2942, 0, 0, 0),
(9000050, 1, 1899, 143, 2551, 0);

DELETE FROM `gameobject_template` WHERE `entry` BETWEEN 9000001 AND 9000012
 OR `entry` BETWEEN 9000018 AND 9000032;
INSERT INTO `gameobject_template` (`entry`, `type`, `displayId`, `name`, `size`, `Data0`, `Data3`,
 `AIName`, `ScriptName`, `VerifiedBuild`) VALUES
(9000001, 10, 100, 'Stolen Candle', 1, 0, 3000, '', 'go_waxworks_candle', 0),
(9000002, 10, 14, 'Commissary Cheese', 1, 0, 3000, '', 'go_waxworks_cheese', 0),
(9000003, 10, 6351, 'Sty Pumpkin', 1, 0, 3000, '', 'go_waxworks_pumpkin', 0),
(9000004, 5, 4, 'Union Chalkboard', 1, 0, 0, '', '', 0),
(9000005, 5, 411, 'Timber Barricade', 1, 0, 0, '', '', 0),
(9000006, 5, 100, 'Waxworks Candle', 1, 0, 0, '', '', 0),
(9000007, 5, 170, 'Wine Cask', 1, 0, 0, '', '', 0),
(9000008, 5, 9419, 'Candle Wagon', 1, 0, 0, '', '', 0),
(9000009, 5, 6038, 'Waxworks Lantern', 1, 0, 0, '', '', 0),
(9000010, 5, 6363, 'Waxworks Taper', 1, 0, 0, '', '', 0),
(9000011, 5, 6364, 'Waxworks Pillar Candle', 1, 0, 0, '', '', 0),
(9000012, 5, 31, 'Union Dispatch Crate', 1, 0, 0, '', '', 0),
(9000018, 5, 216, 'Tallow Vat', 1.15, 0, 0, '', '', 0),
(9000019, 5, 216, 'Commissary Cookpot', 1, 0, 0, '', '', 0),
(9000020, 5, 409, 'Smoked Meat Rack', 1, 0, 0, '', '', 0),
(9000021, 5, 336, 'Stolen Larder Crate', 1, 0, 0, '', '', 0),
(9000022, 5, 6412, 'Local 12 Notice', 1, 0, 0, '', '', 0),
(9000023, 5, 201, 'Waxworks Brazier', 1, 0, 0, '', '', 0),
(9000024, 5, 100, 'Waxworks Stub Candle', 0.45, 0, 0, '', '', 0),
(9000025, 5, 6363, 'Waxworks Medium Taper', 1.55, 0, 0, '', '', 0),
(9000026, 5, 6364, 'Waxworks Tall Candle', 2.3, 0, 0, '', '', 0),
(9000027, 5, 4152, 'Red Ritual Candle', 2.8, 0, 0, '', '', 0),
(9000028, 5, 5872, 'Great Red Candle', 4.1, 0, 0, '', '', 0),
(9000029, 5, 328, 'Waxworks Shrine Altar', 0.85, 0, 0, '', '', 0),
(9000030, 5, 9519, 'Wax Effigy', 0.55, 0, 0, '', '', 0),
(9000031, 5, 9622, 'West Chapel Altar', 0.72, 0, 0, '', '', 0),
(9000032, 5, 240, 'West Chapel Candelabra', 1.35, 0, 0, '', '', 0);

DELETE FROM `gameobject_template_addon` WHERE `entry` BETWEEN 9000001 AND 9000012
 OR `entry` BETWEEN 9000018 AND 9000032;
INSERT INTO `gameobject_template_addon` (`entry`, `faction`, `flags`, `mingold`, `maxgold`) VALUES
(9000001, 0, 0, 0, 0),
(9000002, 0, 0, 0, 0),
(9000003, 0, 0, 0, 0),
(9000004, 0, 0, 0, 0),
(9000005, 0, 0, 0, 0),
(9000006, 0, 0, 0, 0),
(9000007, 0, 0, 0, 0),
(9000008, 0, 0, 0, 0),
(9000009, 0, 0, 0, 0),
(9000010, 0, 0, 0, 0),
(9000011, 0, 0, 0, 0),
(9000012, 0, 0, 0, 0),
(9000018, 0, 0, 0, 0),
(9000019, 0, 0, 0, 0),
(9000020, 0, 0, 0, 0),
(9000021, 0, 0, 0, 0),
(9000022, 0, 0, 0, 0),
(9000023, 0, 0, 0, 0),
(9000024, 0, 0, 0, 0),
(9000025, 0, 0, 0, 0),
(9000026, 0, 0, 0, 0),
(9000027, 0, 0, 0, 0),
(9000028, 0, 0, 0, 0),
(9000029, 0, 0, 0, 0),
(9000030, 0, 0, 0, 0),
(9000031, 0, 0, 0, 0),
(9000032, 0, 0, 0, 0);

DELETE FROM `item_template` WHERE `entry` BETWEEN 9000050 AND 9000079;
INSERT INTO `item_template` (`entry`, `class`, `subclass`, `SoundOverrideSubclass`, `name`, `displayid`,
 `Quality`, `Flags`, `BuyCount`, `BuyPrice`, `SellPrice`, `InventoryType`, `AllowableClass`,
 `AllowableRace`, `ItemLevel`, `RequiredLevel`, `bonding`, `MaxDurability`, `armor`,
 `stat_type1`, `stat_value1`, `stat_type2`, `stat_value2`, `stat_type3`, `stat_value3`,
 `dmg_min1`, `dmg_max1`, `delay`) VALUES
(9000050, 4, 3, -1, 'Undercroft Guard Leggings', 9738, 2, 0, 1, 1455, 291, 7, -1, -1, 13, 0, 1, 50, 113, 4, 3, 0, 0, 0, 0, 0, 0, 0),
(9000051, 4, 2, -1, 'Undercroft Footman Tunic', 11368, 2, 0, 1, 1217, 243, 5, -1, -1, 13, 0, 1, 60, 65, 7, 2, 3, 1, 0, 0, 0, 0, 0),
(9000052, 2, 10, -1, 'Undercroft Fighting Stick', 10654, 2, 0, 1, 3010, 602, 17, -1, -1, 13, 0, 1, 50, 0, 3, 2, 7, 2, 0, 0, 18, 21, 2200),
(9000053, 4, 2, -1, 'Overtime Vest', 11368, 2, 0, 1, 1217, 243, 5, -1, -1, 13, 0, 1, 60, 65, 7, 3, 4, 2, 0, 0, 0, 0, 0),
(9000054, 15, 0, -1, 'Lump of Tallow', 6677, 0, 0, 5, 20, 5, 0, -1, -1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(9000055, 15, 0, -1, 'Stolen Taper', 7066, 0, 0, 5, 16, 4, 0, -1, -1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(9000056, 15, 0, -1, 'Riverpaw Menu Scrap', 1093, 0, 0, 5, 12, 3, 0, -1, -1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(9000057, 15, 0, -1, 'Local 12 Leaflet', 1093, 0, 0, 5, 14, 3, 0, -1, -1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(9000058, 15, 0, -1, 'Greasy Rib', 6348, 0, 0, 5, 10, 2, 0, -1, -1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(9000059, 15, 0, -1, 'Hardened Wax Nodule', 6383, 0, 0, 5, 18, 4, 0, -1, -1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(9000060, 4, 2, -1, 'Tallow-Stained Gloves', 14536, 2, 0, 1, 486, 97, 10, -1, -1, 12, 0, 1, 25, 32, 3, 2, 7, 1, 0, 0, 0, 0, 0),
(9000061, 4, 1, -1, 'Wick-Snuffer Cowl', 15290, 2, 0, 1, 512, 102, 1, -1, -1, 12, 0, 1, 35, 18, 5, 3, 7, 2, 0, 0, 0, 0, 0),
(9000062, 4, 2, -1, 'Grease-Proof Treads', 16980, 2, 0, 1, 498, 99, 8, -1, -1, 12, 0, 1, 30, 38, 7, 2, 3, 1, 0, 0, 0, 0, 0),
(9000063, 2, 4, -1, 'Dipper''s Mallet', 8575, 2, 0, 1, 1450, 290, 21, -1, -1, 12, 0, 1, 40, 0, 4, 2, 7, 1, 0, 0, 9, 17, 2100),
(9000064, 2, 15, -1, 'Consultant''s Shiv', 6442, 2, 0, 1, 1320, 264, 13, -1, -1, 11, 0, 1, 30, 0, 3, 2, 7, 1, 0, 0, 6, 12, 1600),
(9000070, 2, 8, -1, 'Overtime Claymore', 20174, 4, 0, 1, 12500, 2500, 17, 1, -1, 25, 10, 1, 90, 0, 4, 12, 7, 11, 0, 0, 42, 64, 3200),
(9000071, 2, 5, -1, 'Last Rites Contract', 19610, 4, 0, 1, 12500, 2500, 17, 2, -1, 25, 10, 1, 90, 0, 4, 11, 7, 12, 5, 8, 48, 73, 3500),
(9000072, 2, 1, -1, 'Vat-Hook Reaver', 28804, 4, 0, 1, 12500, 2500, 17, 4, -1, 25, 10, 1, 90, 0, 3, 12, 7, 11, 0, 0, 40, 61, 2900),
(9000073, 2, 15, -1, 'Overtime Shiv', 20471, 4, 0, 1, 9800, 1960, 13, 8, -1, 25, 10, 1, 55, 0, 3, 11, 7, 10, 0, 0, 19, 36, 1600),
(9000074, 2, 10, -1, 'Wick-Snuffer''s Sermon', 20346, 4, 0, 1, 12500, 2500, 17, 16, -1, 25, 10, 1, 90, 0, 5, 12, 6, 11, 7, 10, 44, 67, 3200),
(9000075, 2, 8, -1, 'Tallow-Rune Greatsword', 20167, 4, 0, 1, 12500, 2500, 17, 32, -1, 25, 10, 1, 90, 0, 4, 12, 7, 11, 0, 0, 46, 70, 3400),
(9000076, 2, 5, -1, 'Grease-Totem Maul', 8600, 4, 0, 1, 12500, 2500, 17, 64, -1, 25, 10, 1, 90, 0, 4, 10, 5, 11, 7, 10, 45, 68, 3200),
(9000077, 2, 10, -1, 'Dipper''s Arcane Rod', 20386, 4, 0, 1, 12500, 2500, 17, 128, -1, 25, 10, 1, 90, 0, 5, 13, 7, 10, 6, 8, 44, 67, 3200),
(9000078, 2, 10, -1, 'Candle of Binding', 20330, 4, 0, 1, 12500, 2500, 17, 256, -1, 25, 10, 1, 90, 0, 5, 13, 7, 10, 6, 8, 44, 67, 3200),
(9000079, 2, 10, -1, 'Pumpkin-Grove Staff', 20336, 4, 0, 1, 12500, 2500, 17, 1024, -1, 25, 10, 1, 90, 0, 5, 12, 7, 11, 6, 8, 44, 67, 3200);

UPDATE `item_template` SET `stackable` = 20 WHERE `entry` BETWEEN 9000054 AND 9000059;
UPDATE `item_template` SET `description` = 'Still warm. The factory floor weeps this.' WHERE `entry` = 9000054;
UPDATE `item_template` SET `description` = 'Pestle''s mark is stamped on the wick.' WHERE `entry` = 9000055;
UPDATE `item_template` SET `description` = 'Tonight: adventurer. Sides extra.' WHERE `entry` = 9000056;
UPDATE `item_template` SET `description` = 'Dental is non-negotiable. VanCleef gets his cut.' WHERE `entry` = 9000057;
UPDATE `item_template` SET `description` = 'A leftover from the commissary line.' WHERE `entry` = 9000058;
UPDATE `item_template` SET `description` = 'It used to be a miner. Then a candle. Now this.' WHERE `entry` = 9000059;
UPDATE `item_template` SET `description` = 'Four copies if four warriors signed the overtime sheet. Voss always paid in steel.' WHERE `entry` = 9000070;
UPDATE `item_template` SET `description` = 'The contract is binding. So is the head of the mallet.' WHERE `entry` = 9000071;
UPDATE `item_template` SET `description` = 'Used to haul vats. Now it hauls whatever stands in the shaft.' WHERE `entry` = 9000072;
UPDATE `item_template` SET `description` = 'Dental is non-negotiable. So is the second stab.' WHERE `entry` = 9000073;
UPDATE `item_template` SET `description` = 'A two-handed sermon. The wick remembers every name on the list.' WHERE `entry` = 9000074;
UPDATE `item_template` SET `description` = 'Runes cut into tallow, then into steel. The factory floor still weeps.' WHERE `entry` = 9000075;
UPDATE `item_template` SET `description` = 'Grease first. Then the spirits. Then whoever skipped the tip jar.' WHERE `entry` = 9000076;
UPDATE `item_template` SET `description` = 'The dipper was never meant to channel anything. It does now.' WHERE `entry` = 9000077;
UPDATE `item_template` SET `description` = 'A candle that signed you. You did not sign back.' WHERE `entry` = 9000078;
UPDATE `item_template` SET `description` = 'Harvest wood from the sty loft. The pumpkin still thinks it is a crown.' WHERE `entry` = 9000079;

DELETE FROM `quest_template` WHERE `ID` IN (9000000, 9000001, 9000003);
INSERT INTO `quest_template` (`ID`, `QuestType`, `QuestLevel`, `MinLevel`, `QuestSortID`,
 `SuggestedGroupNum`, `RewardNextQuest`, `RewardXPDifficulty`, `RewardMoney`, `Flags`,
 `RewardChoiceItemID1`, `RewardChoiceItemQuantity1`, `RewardChoiceItemID2`,
 `RewardChoiceItemQuantity2`, `RewardChoiceItemID3`, `RewardChoiceItemQuantity3`,
 `RewardFactionID1`, `RewardFactionValue1`, `AllowableRaces`, `LogTitle`, `LogDescription`,
 `QuestDescription`, `QuestCompletionLog`, `RequiredNpcOrGo1`, `RequiredNpcOrGo2`,
 `RequiredNpcOrGo3`, `RequiredNpcOrGoCount1`, `RequiredNpcOrGoCount2`,
 `RequiredNpcOrGoCount3`, `ObjectiveText1`, `ObjectiveText2`, `ObjectiveText3`) VALUES
(9000000, 2, 8, 6, 12, 0, 9000001, 4, 50, 8, 0, 0, 0, 0, 0, 0, 72, 3, 1101,
 'The Wax Emergency',
 'Speak with Sergeant Wickham and enter the Waxworks beneath Fargodeep Mine.',
 'Pestle is missing a crate of candles. Tomas swears the larder walked off. Dughan cannot spare the garrison — Hogger, murlocs, two mines. Wiley already said it: the Defias are working with kobolds and gnolls.$B$BFive volunteers can finish this before the Keep notices. Talk to me when you are ready to go below.',
 'Return to Sergeant Wickham at the mouth of Fargodeep Mine.',
 0, 0, 0, 0, 0, 0, '', '', ''),
(9000001, 2, 12, 7, 12, 5, 0, 6, 350, 8, 9000050, 1, 9000051, 1, 9000052, 1, 72, 5, 1101,
 'Break the Cooperative',
 'Slay King Wick, Chef Snarlroast, and Foreman Voss in the Waxworks.',
 'A kobold candle-king, a Riverpaw kitchen, and a Defias organizer signed a mutual-aid pact in the lower shaft. Break the cooperative. Kill the three ringleaders and report back.$B$BDo not linger near Goldtooth. He is not our problem today.',
 'Return to Sergeant Wickham at the mouth of Fargodeep Mine.',
 9000020, 9000030, 9000040, 1, 1, 1, 'King Wick slain', 'Chef Snarlroast slain',
 'Foreman Voss slain'),
(9000003, 2, 11, 7, 12, 0, 0, 5, 150, 8, 9000051, 1, 0, 0, 0, 0, 72, 3, 1101,
 'First Prize',
 'Deal with H.R.H. Princess in the Pumpkin Sty.',
 'They stole an Eastvale harvest watcher and crowned a prize pig. Optional. Ugly. If you have time, dethrone her.',
 'Return to Sergeant Wickham at the mouth of Fargodeep Mine.',
 9000045, 0, 0, 1, 0, 0, 'H.R.H. Princess slain', '', '');

-- WMO-only map 44 has no usable navmesh. IGNORE_PATHFINDING (0x20000000) stops
-- chase path fails from triggering in-combat HP regen on every non-raid.
UPDATE `creature_template` SET `flags_extra` = `flags_extra` | 536870912
 WHERE `entry` BETWEEN 9000001 AND 9000049
   AND `entry` NOT IN (9000021, 9000031);

DELETE FROM `quest_template_addon` WHERE `ID` IN (9000000, 9000001, 9000003);
INSERT INTO `quest_template_addon` (`ID`, `PrevQuestID`, `NextQuestID`, `SpecialFlags`) VALUES
(9000000, 0, 9000001, 0),
(9000001, 9000000, 0, 0),
(9000003, 9000000, 0, 0);
