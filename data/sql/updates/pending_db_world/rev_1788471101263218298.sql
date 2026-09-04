-- The Waxworks 5-man (map 44). Custom ids 9000000-9000199 only.
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

DELETE FROM `gameobject_template` WHERE `entry` BETWEEN 9000001 AND 9000012 OR `entry` BETWEEN 9000018 AND 9000032;
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

DELETE FROM `gameobject_template_addon` WHERE `entry` BETWEEN 9000001 AND 9000012 OR `entry` BETWEEN 9000018 AND 9000032;
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
-- The Waxworks spawns. Map 44 world xyz (=-Blender XY). Plaza Wickham stays on map 0.
-- Goldtooth guid 80644 at -9745.84, 87.57, 12.77: keep >=15 yards clear. Do not spawn there.
-- This tree's creature table uses `id` (not upstream `id1`).

DELETE FROM `creature` WHERE `guid` BETWEEN 9000001 AND 9000040;
INSERT INTO `creature` (`guid`, `id`, `map`, `spawnMask`, `phaseMask`, `equipment_id`,
 `position_x`, `position_y`, `position_z`, `orientation`, `spawntimesecs`,
 `wander_distance`, `curhealth`, `curmana`, `MovementType`, `Comment`) VALUES
(9000001, 9000050, 44, 1, 1, 1, -10, -2, 0.15, 3.1416, 120, 0, 1, 0, 0, 'Wickham mouth'),
(9000032, 9000050, 0, 1, 1, 1, -9445, 66, 56.8, 3.1416, 120, 0, 1, 0, 0, 'Wickham plaza'),
(9000002, 9000001, 44, 1, 1, 0, -37, 6, 0.15, -0.6416, 86400, 3, 1, 0, 1, 'Wickworks pack1 scamp'),
(9000003, 9000001, 44, 1, 1, 0, -40, 4, 0.15, -0.6416, 86400, 3, 1, 0, 1, 'Wickworks pack1 scamp'),
(9000004, 9000002, 44, 1, 1, 0, -53, 18, 0.15, -1.3416, 86400, 2, 1, 0, 1, 'Wickworks pack2 tunneler'),
(9000005, 9000003, 44, 1, 1, 0, -35, 8, 0.15, -0.6416, 86400, 0, 1, 0, 0, 'Wickworks pack1 wickmage'),
(9000006, 9000005, 44, 1, 1, 0, -56, 20, 0.15, 3.5416, 86400, 0, 1, 0, 0, 'Candle cart beside pack2'),
(9000007, 9000004, 44, 1, 1, 0, -52, 20, 0.15, 3.5416, 86400, 0, 1, 0, 2, 'Wickworks hauler waypoint'),
(9000008, 9000006, 44, 1, 1, 0, -63, -10, 0.15, 0.3584, 86400, 2, 1, 0, 1, 'Gug optional pack'),
(9000009, 9000020, 44, 1, 1, 0, -96, 0, 1.2, 0, 600, 0, 1, 0, 0, 'King Wick'),
(9000010, 9000007, 44, 1, 1, 0, -80, 24, -6.85, 1.0584, 86400, 3, 1, 0, 1, 'Kitchen pack line cook'),
(9000011, 9000008, 44, 1, 1, 0, -84, 24, -6.85, 0.8584, 86400, 3, 1, 0, 1, 'Kitchen pack dishwasher'),
(9000012, 9000009, 44, 1, 1, 0, -82, 26, -6.85, 0.9584, 86400, 0, 1, 0, 0, 'Kitchen pack Fry-Oracle'),
(9000013, 9000010, 44, 1, 1, 0, -100, 28, -6.85, 5.9416, 86400, 3, 1, 0, 1, 'Grease patrol pack'),
(9000014, 9000016, 44, 1, 1, 0, -101, 30, -6.85, 5.9416, 86400, 3, 1, 0, 1, 'Grease boar pack'),
(9000015, 9000030, 44, 1, 1, 1, -88, 40, -6.85, 4.5416, 600, 0, 1, 0, 0, 'Chef Snarlroast'),
(9000033, 9000011, 44, 1, 1, 0, -92.8, 50, -6.35, 3.4, 86400, 2, 1, 0, 1, 'Murloc alcove world'),
(9000034, 9000011, 44, 1, 1, 0, -91.6, 54.2, -6.35, 2.8, 86400, 2, 1, 0, 1, 'Murloc alcove world'),
(9000035, 9000011, 44, 1, 1, 0, -90.6, 51.4, -6.35, 3, 86400, 1, 1, 0, 1, 'Murloc alcove world'),
(9000018, 9000014, 44, 1, 1, 0, -134, -10, 0.65, 1.5584, 86400, 2, 1, 0, 1, 'Union trash clerk'),
(9000019, 9000012, 44, 1, 1, 1, -132, -9, 0.65, 1.6584, 86400, 3, 1, 0, 1, 'Union trash steward'),
(9000020, 9000013, 44, 1, 1, 0, -138, -9, 0.65, 1.4584, 86400, 0, 1, 0, 0, 'Union trash mage'),
(9000021, 9000040, 44, 1, 1, 1, -136, 8, 0.65, 4.7116, 600, 0, 1, 0, 0, 'Foreman Voss'),
(9000022, 9000045, 44, 1, 1, 0, -94, -32, 9.65, 5.6416, 600, 0, 1, 0, 0, 'Princess'),
(9000023, 9000047, 44, 1, 1, 0, -94, -37, 9.65, 0.6584, 600, 0, 1, 0, 0, 'Unit 07 corner'),
(9000024, 9000046, 44, 1, 1, 0, -84, -30, 9.65, 4.1416, 86400, 2, 1, 0, 1, 'Sir Oinksworth'),
(9000025, 9000048, 44, 1, 1, 0, -88, -36, 9.65, 1.0584, 86400, 2, 1, 0, 1, 'Lady Crackling'),
(9000026, 9000049, 44, 1, 1, 0, -92, -30, 9.65, 5.3416, 86400, 2, 1, 0, 1, 'Honourable Ham'),
(9000027, 9000001, 44, 1, 1, 0, -61, -12, 0.15, 0.4584, 86400, 3, 1, 0, 1, 'Gug pack scamp'),
(9000028, 9000018, 44, 1, 1, 0, -51, 2, 0.15, 1.0584, 86400, 0, 1, 0, 0, 'Vat tender at the dip'),
(9000029, 9000017, 44, 1, 1, 0, -53, 4, 0.15, -0.3416, 86400, 4, 1, 0, 1, 'Dripping wax south of vat'),
(9000030, 9000017, 44, 1, 1, 0, -49, 0, 0.15, 2.3584, 86400, 4, 1, 0, 1, 'Dripping wax west of vat'),
(9000031, 9000017, 44, 1, 1, 0, -54, -1, 0.15, 0.7584, 86400, 3, 1, 0, 1, 'Dripping wax north of vat');

DELETE FROM `creature_addon` WHERE `guid` BETWEEN 9000001 AND 9000040;
INSERT INTO `creature_addon` (`guid`, `path_id`, `mount`, `bytes1`, `bytes2`, `emote`,
 `visibilityDistanceType`, `auras`) VALUES
(9000001, 0, 0, 0, 1, 101, 0, NULL),
(9000032, 0, 0, 0, 1, 101, 0, NULL),
(9000007, 9000007, 0, 0, 1, 0, 0, NULL),
(9000009, 0, 0, 1, 1, 0, 0, NULL),
(9000028, 0, 0, 0, 1, 173, 0, NULL);

DELETE FROM `waypoint_data` WHERE `id` = 9000007;
INSERT INTO `waypoint_data` (`id`, `point`, `position_x`, `position_y`, `position_z`,
 `orientation`, `velocity`, `delay`, `smoothTransition`, `move_type`, `action`,
 `action_chance`, `wpguid`) VALUES
(9000007, 1, -52, 20, 0.15, NULL, 0, 0, 0, 0, 0, 100, 0),
(9000007, 2, -58, 24, 0.15, NULL, 0, 1000, 0, 0, 0, 100, 0),
(9000007, 3, -50, 24, 0.15, NULL, 0, 0, 0, 0, 0, 100, 0);

-- 9000034–9000035 are the Goldshire stone + particles (base_05). Do not delete them.
DELETE FROM `gameobject` WHERE `guid` BETWEEN 9000001 AND 9000033;
INSERT INTO `gameobject` (`guid`, `id`, `map`, `spawnMask`, `phaseMask`, `position_x`,
 `position_y`, `position_z`, `orientation`, `rotation2`, `rotation3`, `spawntimesecs`,
 `animprogress`, `state`, `Comment`) VALUES
(9000001, 9000002, 44, 1, 1, -90, 32, -6.85, 3.6416, 0.9689, -0.2474, 68, 100, 1, 'Commissary cheese'),
(9000002, 9000003, 44, 1, 1, -92, -32, 9.65, 3.3416, 0.995, -0.0998, 68, 100, 1, 'Sty pumpkin'),
(9000003, 9000003, 44, 1, 1, -96, -38, 9.65, 5.2416, 0.4976, -0.8674, 68, 100, 1, 'Sty pumpkin Unit 07'),
(9000004, 9000004, 44, 1, 1, -136, 5, 0.65, 4.7116, 0.7074, -0.7068, 68, 100, 1, 'Voss chalkboard'),
(9000005, 9000005, 44, 1, 1, -80, 0, 0.65, 0, 0, 1, 68, 100, 1, 'Wick barricade'),
(9000006, 9000006, 44, 1, 1, -94, 2.2, 1.2, 0.8, 0.3894, 0.9211, 180, 100, 1, 'Wick throne candle'),
(9000007, 9000010, 44, 1, 1, -94, -2.2, 1.2, 2.4, 0.932, 0.3624, 180, 100, 1, 'Wick throne taper'),
(9000008, 9000011, 44, 1, 1, -97, 3.6, 1.2, 5.1, 0.5577, -0.8301, 180, 100, 1, 'Wick throne pillar'),
(9000009, 9000006, 44, 1, 1, -97, -3.6, 1.2, 1.2, 0.5646, 0.8253, 180, 100, 1, 'Wick throne candle'),
(9000010, 9000010, 44, 1, 1, -92, 0, 1.2, 4, 0.9093, -0.4161, 180, 100, 1, 'Wick throne taper'),
(9000011, 9000006, 44, 1, 1, -80, 0, 0.65, 0, 0, 1, 180, 100, 1, 'Wick approach candle'),
(9000012, 9000011, 44, 1, 1, -78, -1, 0.65, 0, 0, 1, 180, 100, 1, 'Wick approach pillar'),
(9000013, 9000008, 44, 1, 1, -56, 20, 0.15, 3.5416, 0.9801, -0.1987, 180, 100, 1, 'Cart doodad'),
(9000014, 9000006, 44, 1, 1, -45, 3, 0.15, 3.9416, 0.9211, -0.3894, 180, 100, 1, 'Wickworks pack1 candle'),
(9000015, 9000010, 44, 1, 1, -53, 9, 0.15, 5.3416, 0.4536, -0.8912, 180, 100, 1, 'Wickworks pack2 candle'),
(9000016, 9000006, 44, 1, 1, -60, -5, 0.15, 4.2416, 0.8525, -0.5227, 180, 100, 1, 'Wickworks Gug candle'),
(9000017, 9000007, 44, 1, 1, -82, 38, -6.85, 4.3416, 0.8253, -0.5646, 180, 100, 1, 'Wine offset SW'),
(9000018, 9000007, 44, 1, 1, -94, 38, -6.85, 0.8584, 0.4161, 0.9093, 180, 100, 1, 'Wine offset SE'),
(9000019, 9000007, 44, 1, 1, -80, 30, -6.85, 3.4416, 0.9888, -0.1494, 180, 100, 1, 'Wine offset west wall'),
(9000020, 9000006, 44, 1, 1, -11, 2.2, 0.15, 2.2, 0.8912, 0.4536, 180, 100, 1, 'Mouth candle'),
(9000021, 9000006, 44, 1, 1, -88, 52, -6.35, 0.4584, 0.2272, 0.9738, 180, 100, 1, 'Alcove candle'),
(9000022, 9000006, 44, 1, 1, -134, 10, 0.65, 3.1416, 1, 0, 180, 100, 1, 'Voss candle'),
(9000023, 9000010, 44, 1, 1, -138, 10, 0.65, 4.2416, 0.8525, -0.5227, 180, 100, 1, 'Voss taper'),
(9000024, 9000009, 44, 1, 1, -132, 6, 1.65, 3.5416, 0.9801, -0.1987, 180, 100, 1, 'Voss lantern'),
(9000025, 9000009, 44, 1, 1, -140, 6, 1.65, 2.3584, 0.9243, 0.3817, 180, 100, 1, 'Voss lantern'),
(9000026, 9000012, 44, 1, 1, -134.5, 6, 0.65, 4.5416, 0.7648, -0.6442, 68, 100, 1, 'Voss crate'),
(9000027, 9000006, 44, 1, 1, -87, -30, 9.65, 4.8416, 0.66, -0.7513, 180, 100, 1, 'Sty candle'),
(9000028, 9000009, 44, 1, 1, -10.5, 3, 1.15, 4.7, 0.7115, -0.7027, 180, 100, 1, 'Mouth lantern'),
(9000029, 9000009, 44, 1, 1, -46, 0, 2.15, 3.3416, 0.995, -0.0998, 180, 100, 1, 'Wickworks lantern'),
(9000030, 9000009, 44, 1, 1, -88, 36, -4.85, 3.9416, 0.9211, -0.3894, 180, 100, 1, 'Commissary lantern'),
(9000031, 9000012, 44, 1, 1, -84, 34, -6.85, 3.3416, 0.995, -0.0998, 68, 100, 1, 'Snarlroast stove crate'),
(9000032, 9000006, 44, 1, 1, -136, 12, 0.65, 5.9416, 0.17, -0.9854, 180, 100, 1, 'Voss rear candle'),
(9000033, 9000011, 44, 1, 1, -86, -33, 9.65, 3.7416, 0.9553, -0.2955, 180, 100, 1, 'Sty pillar candle');

DELETE FROM `gameobject` WHERE `guid` BETWEEN 9000056 AND 9000066;
INSERT INTO `gameobject` (`guid`, `id`, `map`, `spawnMask`, `phaseMask`, `position_x`,
 `position_y`, `position_z`, `orientation`, `rotation2`, `rotation3`, `spawntimesecs`,
 `animprogress`, `state`, `Comment`) VALUES
(9000056, 9000018, 44, 1, 1, -51, 1, 0.15, 3.5416, 0.9801, -0.1987, 180, 100, 1, 'Tallow vat'),
(9000057, 9000023, 44, 1, 1, -52, 2.5, 0.15, 5.2416, 0.4976, -0.8674, 180, 100, 1, 'Vat brazier'),
(9000058, 9000006, 44, 1, 1, -50, 3, 0.15, 1.8584, 0.8011, 0.5985, 180, 100, 1, 'Vat candle'),
(9000059, 9000019, 44, 1, 1, -84, 32, -6.85, 4.2416, 0.8525, -0.5227, 180, 100, 1, 'Commissary cookpot'),
(9000060, 9000020, 44, 1, 1, -94, 30, -6.85, 0.8584, 0.4161, 0.9093, 180, 100, 1, 'Commissary meat rack'),
(9000061, 9000021, 44, 1, 1, -92, 34, -6.85, 3.7416, 0.9553, -0.2955, 180, 100, 1, 'Stolen larder crate'),
(9000062, 9000023, 44, 1, 1, -86, 34, -6.85, 5.9416, 0.17, -0.9854, 180, 100, 1, 'Commissary brazier'),
(9000063, 9000022, 44, 1, 1, -136, 2, 1.05, 4.7116, 0.7074, -0.7068, 180, 100, 1, 'Local 12 notice'),
(9000064, 9000021, 44, 1, 1, -131, -2, 0.65, 1.6584, 0.7374, 0.6755, 180, 100, 1, 'Union supply crate'),
(9000065, 9000023, 44, 1, 1, -80, 0, 0.65, 6.2816, 0.0008, -1, 180, 100, 1, 'Wick approach brazier'),
(9000066, 9000011, 44, 1, 1, -51, -1.5, 0.15, 4.5416, 0.7648, -0.6442, 180, 100, 1, 'Vat pillar candle');
-- The Waxworks SmartAI. Full-block rewrite per (entryorguid, source_type).

DELETE FROM `smart_scripts` WHERE `entryorguid` = 9000001 AND `source_type` = 0;
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`,
 `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`,
 `event_param3`, `event_param4`, `event_param5`, `event_param6`, `action_type`,
 `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`,
 `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`,
 `target_param4`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(9000001, 0, 0, 0, 4, 0, 100, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Scamp - On Aggro - Talk');

DELETE FROM `smart_scripts` WHERE `entryorguid` = 9000002 AND `source_type` = 0;
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`,
 `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`,
 `event_param3`, `event_param4`, `event_param5`, `event_param6`, `action_type`,
 `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`,
 `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`,
 `target_param4`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(9000002, 0, 0, 0, 0, 0, 100, 0, 4000, 7000, 18000, 24000, 0, 0, 11, 6016, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Tunneler - IC - Pierce Armor');

DELETE FROM `smart_scripts` WHERE `entryorguid` = 9000003 AND `source_type` = 0;
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`,
 `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`,
 `event_param3`, `event_param4`, `event_param5`, `event_param6`, `action_type`,
 `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`,
 `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`,
 `target_param4`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(9000003, 0, 0, 0, 1, 0, 100, 0, 1000, 1000, 1800000, 1800000, 0, 0, 11, 12544, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Wickmage - OOC - Frost Armor'),
(9000003, 0, 1, 0, 0, 0, 100, 0, 0, 0, 2300, 3900, 0, 0, 11, 20793, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Wickmage - IC CMC - Fireball'),
(9000003, 0, 2, 0, 4, 0, 100, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Wickmage - On Aggro - Talk');

DELETE FROM `smart_scripts` WHERE `entryorguid` = 9000005 AND `source_type` = 0;
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`,
 `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`,
 `event_param3`, `event_param4`, `event_param5`, `event_param6`, `action_type`,
 `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`,
 `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`,
 `target_param4`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(9000005, 0, 0, 0, 32, 0, 100, 1, 1, 1000000, 0, 0, 0, 0, 67, 1, 2000, 2000, 0, 0, 100, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Cart - Damaged minDmg 1 max 1000000 - Timed Event'),
(9000005, 0, 1, 2, 59, 0, 100, 0, 1, 0, 0, 0, 0, 0, 11, 11969, 2, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Cart - Timed - Fire Nova'),
(9000005, 0, 2, 3, 61, 0, 100, 0, 0, 0, 0, 0, 0, 0, 11, 7978, 2, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Cart - Link - Throw Dynamite'),
(9000005, 0, 3, 4, 61, 0, 100, 0, 0, 0, 0, 0, 0, 0, 75, 8599, 0, 0, 0, 0, 0, 9, 9000001, 0, 20, 1, 0, 0, 0, 0, 'Cart - Link - Enrage Scamps'),
(9000005, 0, 4, 5, 61, 0, 100, 0, 0, 0, 0, 0, 0, 0, 75, 8599, 0, 0, 0, 0, 0, 9, 9000002, 0, 20, 1, 0, 0, 0, 0, 'Cart - Link - Enrage Tunnelers'),
(9000005, 0, 5, 6, 61, 0, 100, 0, 0, 0, 0, 0, 0, 0, 75, 8599, 0, 0, 0, 0, 0, 9, 9000003, 0, 20, 1, 0, 0, 0, 0, 'Cart - Link - Enrage Wickmages'),
(9000005, 0, 6, 7, 61, 0, 100, 0, 0, 0, 0, 0, 0, 0, 75, 8599, 0, 0, 0, 0, 0, 9, 9000004, 0, 20, 1, 0, 0, 0, 0, 'Cart - Link - Enrage Haulers'),
(9000005, 0, 7, 0, 61, 0, 100, 0, 0, 0, 0, 0, 0, 0, 75, 8599, 0, 0, 0, 0, 0, 9, 9000006, 0, 20, 1, 0, 0, 0, 0, 'Cart - Link - Enrage Gug');

DELETE FROM `smart_scripts` WHERE `entryorguid` = 9000006 AND `source_type` = 0;
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`,
 `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`,
 `event_param3`, `event_param4`, `event_param5`, `event_param6`, `action_type`,
 `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`,
 `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`,
 `target_param4`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(9000006, 0, 0, 0, 0, 0, 100, 0, 2000, 4000, 20000, 30000, 0, 0, 11, 9128, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Gug - IC - Battle Shout'),
(9000006, 0, 1, 0, 2, 0, 100, 1, 0, 30, 0, 0, 0, 0, 11, 8599, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Gug - 30% - Enrage');

DELETE FROM `smart_scripts` WHERE `entryorguid` = 9000007 AND `source_type` = 0;
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`,
 `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`,
 `event_param3`, `event_param4`, `event_param5`, `event_param6`, `action_type`,
 `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`,
 `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`,
 `target_param4`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(9000007, 0, 0, 0, 0, 0, 100, 0, 3000, 6000, 14000, 18000, 0, 0, 11, 8016, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Line Cook - IC - Spirit Decay'),
(9000007, 0, 1, 0, 2, 0, 100, 1, 0, 15, 0, 0, 0, 0, 25, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Line Cook - 15% - Flee'),
(9000007, 0, 2, 0, 4, 0, 100, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Line Cook - On Aggro - Talk');

DELETE FROM `smart_scripts` WHERE `entryorguid` = 9000008 AND `source_type` = 0;
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`,
 `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`,
 `event_param3`, `event_param4`, `event_param5`, `event_param6`, `action_type`,
 `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`,
 `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`,
 `target_param4`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(9000008, 0, 0, 0, 0, 0, 100, 0, 2000, 5000, 18000, 25000, 0, 0, 11, 13730, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Dishwasher - IC - Demo Shout');

DELETE FROM `smart_scripts` WHERE `entryorguid` = 9000009 AND `source_type` = 0;
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`,
 `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`,
 `event_param3`, `event_param4`, `event_param5`, `event_param6`, `action_type`,
 `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`,
 `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`,
 `target_param4`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(9000009, 0, 0, 0, 0, 0, 100, 0, 0, 0, 2400, 3800, 0, 0, 11, 9532, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Fry-Oracle - IC CMC - Lightning Bolt'),
(9000009, 0, 1, 0, 74, 0, 100, 0, 0, 0, 8000, 12000, 40, 20, 11, 913, 64, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, 'Fry-Oracle - Ally <40% - Healing Wave');

DELETE FROM `smart_scripts` WHERE `entryorguid` = 9000010 AND `source_type` = 0;
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`,
 `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`,
 `event_param3`, `event_param4`, `event_param5`, `event_param6`, `action_type`,
 `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`,
 `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`,
 `target_param4`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(9000010, 0, 0, 0, 0, 0, 100, 0, 1000, 3000, 15000, 18000, 0, 0, 11, 6268, 0, 0, 0, 0, 0, 28, 30, 1, 0, 0, 0, 0, 0, 0, 'Grease Patrol - IC - Rushing Charge farthest');

DELETE FROM `smart_scripts` WHERE `entryorguid` = 9000011 AND `source_type` = 0;
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`,
 `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`,
 `event_param3`, `event_param4`, `event_param5`, `event_param6`, `action_type`,
 `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`,
 `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`,
 `target_param4`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(9000011, 0, 0, 0, 2, 0, 100, 1, 0, 40, 0, 0, 0, 0, 11, 3368, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Murloc - 40% - Drink Potion');

DELETE FROM `smart_scripts` WHERE `entryorguid` = 9000012 AND `source_type` = 0;
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`,
 `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`,
 `event_param3`, `event_param4`, `event_param5`, `event_param6`, `action_type`,
 `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`,
 `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`,
 `target_param4`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(9000012, 0, 0, 0, 4, 0, 100, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Steward - On Aggro - Talk'),
(9000012, 0, 1, 0, 0, 0, 100, 0, 3000, 6000, 10000, 14000, 0, 0, 11, 8646, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Steward - IC - Snap Kick');

DELETE FROM `smart_scripts` WHERE `entryorguid` = 9000013 AND `source_type` = 0;
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`,
 `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`,
 `event_param3`, `event_param4`, `event_param5`, `event_param6`, `action_type`,
 `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`,
 `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`,
 `target_param4`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(9000013, 0, 0, 0, 1, 0, 100, 0, 1000, 1000, 1800000, 1800000, 0, 0, 11, 12544, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Contract Mage - OOC - Frost Armor'),
(9000013, 0, 1, 0, 0, 0, 100, 0, 0, 0, 2400, 3800, 0, 0, 11, 13322, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Contract Mage - IC CMC - Frostbolt');

DELETE FROM `smart_scripts` WHERE `entryorguid` = 9000014 AND `source_type` = 0;
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`,
 `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`,
 `event_param3`, `event_param4`, `event_param5`, `event_param6`, `action_type`,
 `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`,
 `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`,
 `target_param4`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(9000014, 0, 0, 0, 0, 0, 100, 0, 4000, 7000, 12000, 16000, 0, 0, 11, 1776, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Clerk - IC - Gouge');

DELETE FROM `smart_scripts` WHERE `entryorguid` = 9000015 AND `source_type` = 0;
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`,
 `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`,
 `event_param3`, `event_param4`, `event_param5`, `event_param6`, `action_type`,
 `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`,
 `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`,
 `target_param4`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(9000015, 0, 0, 0, 0, 0, 100, 0, 3000, 6000, 10000, 14000, 0, 0, 11, 8646, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Bodyguard - IC - Snap Kick');

DELETE FROM `smart_scripts` WHERE `entryorguid` = 9000016 AND `source_type` = 0;
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`,
 `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`,
 `event_param3`, `event_param4`, `event_param5`, `event_param6`, `action_type`,
 `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`,
 `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`,
 `target_param4`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(9000016, 0, 0, 0, 0, 0, 100, 0, 1000, 3000, 15000, 18000, 0, 0, 11, 6268, 0, 0, 0, 0, 0, 28, 30, 1, 0, 0, 0, 0, 0, 0, 'Boar - IC - Rushing Charge farthest');

DELETE FROM `smart_scripts` WHERE `entryorguid` = 9000017 AND `source_type` = 0;
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`,
 `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`,
 `event_param3`, `event_param4`, `event_param5`, `event_param6`, `action_type`,
 `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`,
 `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`,
 `target_param4`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(9000017, 0, 0, 0, 4, 0, 100, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Dripping Wax - On Aggro - Talk'),
(9000017, 0, 1, 0, 0, 0, 100, 0, 2000, 5000, 8000, 12000, 0, 0, 11, 6306, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Dripping Wax - IC - Acid Splash');

DELETE FROM `smart_scripts` WHERE `entryorguid` = 9000018 AND `source_type` = 0;
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`,
 `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`,
 `event_param3`, `event_param4`, `event_param5`, `event_param6`, `action_type`,
 `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`,
 `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`,
 `target_param4`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(9000018, 0, 0, 0, 4, 0, 100, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Vat Tender - On Aggro - Talk'),
(9000018, 0, 1, 0, 0, 0, 100, 0, 4000, 7000, 16000, 22000, 0, 0, 11, 6016, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Vat Tender - IC - Pierce Armor');

DELETE FROM `smart_scripts` WHERE `entryorguid` = 9000019 AND `source_type` = 0;
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`,
 `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`,
 `event_param3`, `event_param4`, `event_param5`, `event_param6`, `action_type`,
 `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`,
 `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`,
 `target_param4`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(9000019, 0, 0, 1, 25, 0, 100, 0, 0, 0, 0, 0, 0, 0, 90, 8, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Acolyte - Reset - Kneel standstate'),
(9000019, 0, 1, 0, 61, 0, 100, 0, 0, 0, 0, 0, 0, 0, 17, 68, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Acolyte - Link - Kneel emote'),
(9000019, 0, 2, 3, 4, 0, 100, 0, 0, 0, 0, 0, 0, 0, 91, 8, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Acolyte - On Aggro - Stand'),
(9000019, 0, 3, 4, 61, 0, 100, 0, 0, 0, 0, 0, 0, 0, 17, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Acolyte - Link - Clear emote'),
(9000019, 0, 4, 0, 61, 0, 100, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Acolyte - Link - Talk');

DELETE FROM `smart_scripts` WHERE `entryorguid` = 9000031 AND `source_type` = 0;
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`,
 `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`,
 `event_param3`, `event_param4`, `event_param5`, `event_param6`, `action_type`,
 `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`,
 `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`,
 `target_param4`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(9000031, 0, 0, 0, 63, 0, 100, 0, 0, 0, 0, 0, 0, 0, 11, 11969, 2, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Fire Trail - On Create - Fire Nova');
-- The Waxworks loot, text, gossip, and quest hooks.

DELETE FROM `reference_loot_template` WHERE `Entry` = 9000101;
INSERT INTO `reference_loot_template` (`Entry`, `Item`, `Reference`, `Chance`, `QuestRequired`,
 `LootMode`, `GroupId`, `MinCount`, `MaxCount`, `Comment`) VALUES
(9000101, 9000050, 0, 0, 0, 1, 1, 1, 1, 'Waxworks green - Undercroft Leggings'),
(9000101, 9000051, 0, 0, 0, 1, 1, 1, 1, 'Waxworks green - Undercroft Tunic'),
(9000101, 9000052, 0, 0, 0, 1, 1, 1, 1, 'Waxworks green - Undercroft Stick'),
(9000101, 9000060, 0, 0, 0, 1, 1, 1, 1, 'Waxworks green - Tallow Gloves'),
(9000101, 9000061, 0, 0, 0, 1, 1, 1, 1, 'Waxworks green - Wick-Snuffer Cowl'),
(9000101, 9000062, 0, 0, 0, 1, 1, 1, 1, 'Waxworks green - Grease-Proof Treads'),
(9000101, 9000063, 0, 0, 0, 1, 1, 1, 1, 'Waxworks green - Dipper Mallet'),
(9000101, 9000064, 0, 0, 0, 1, 1, 1, 1, 'Waxworks green - Consultant Shiv');

DELETE FROM `creature_loot_template` WHERE `Entry` IN ( 9000001,9000002,9000003,9000004,9000005,9000006,9000007,9000008,9000009, 9000010,9000011,9000012,9000013,9000014,9000015,9000016,9000017,9000018, 9000020,9000030,9000040,9000045,9000046,9000047,9000048,9000049);
INSERT INTO `creature_loot_template` (`Entry`, `Item`, `Reference`, `Chance`, `QuestRequired`,
 `LootMode`, `GroupId`, `MinCount`, `MaxCount`, `Comment`) VALUES
(9000001, 9000054, 0, 45, 0, 1, 0, 1, 2, 'Scamp - Lump of Tallow'),
(9000001, 9000055, 0, 25, 0, 1, 0, 1, 1, 'Scamp - Stolen Taper'),
(9000001, 2589, 0, 30, 0, 1, 0, 1, 2, 'Scamp - Linen Cloth'),
(9000001, 0, 9000101, 6, 0, 1, 0, 1, 1, 'Scamp - Waxworks green'),
(9000002, 9000054, 0, 45, 0, 1, 0, 1, 2, 'Tunneler - Lump of Tallow'),
(9000002, 9000055, 0, 25, 0, 1, 0, 1, 1, 'Tunneler - Stolen Taper'),
(9000002, 2589, 0, 30, 0, 1, 0, 1, 2, 'Tunneler - Linen Cloth'),
(9000002, 0, 9000101, 6, 0, 1, 0, 1, 1, 'Tunneler - Waxworks green'),
(9000003, 9000054, 0, 40, 0, 1, 0, 1, 2, 'Wickmage - Lump of Tallow'),
(9000003, 9000055, 0, 30, 0, 1, 0, 1, 1, 'Wickmage - Stolen Taper'),
(9000003, 2589, 0, 25, 0, 1, 0, 1, 2, 'Wickmage - Linen Cloth'),
(9000003, 0, 9000101, 8, 0, 1, 0, 1, 1, 'Wickmage - Waxworks green'),
(9000004, 9000054, 0, 45, 0, 1, 0, 1, 2, 'Hauler - Lump of Tallow'),
(9000004, 9000055, 0, 25, 0, 1, 0, 1, 1, 'Hauler - Stolen Taper'),
(9000004, 2589, 0, 30, 0, 1, 0, 1, 2, 'Hauler - Linen Cloth'),
(9000004, 0, 9000101, 6, 0, 1, 0, 1, 1, 'Hauler - Waxworks green'),
(9000005, 9000054, 0, 100, 0, 1, 0, 2, 4, 'Cart - Lump of Tallow'),
(9000005, 9000055, 0, 80, 0, 1, 0, 1, 3, 'Cart - Stolen Taper'),
(9000005, 772, 0, 100, 0, 1, 0, 1, 3, 'Cart - Large Candle'),
(9000006, 9000054, 0, 60, 0, 1, 0, 1, 3, 'Gug - Lump of Tallow'),
(9000006, 9000055, 0, 40, 0, 1, 0, 1, 2, 'Gug - Stolen Taper'),
(9000006, 0, 9000101, 18, 0, 1, 0, 1, 1, 'Gug - Waxworks green'),
(9000007, 9000058, 0, 50, 0, 1, 0, 1, 2, 'Line Cook - Greasy Rib'),
(9000007, 9000056, 0, 35, 0, 1, 0, 1, 1, 'Line Cook - Menu Scrap'),
(9000007, 117, 0, 20, 0, 1, 0, 1, 1, 'Line Cook - Tough Jerky'),
(9000007, 0, 9000101, 7, 0, 1, 0, 1, 1, 'Line Cook - Waxworks green'),
(9000008, 9000058, 0, 50, 0, 1, 0, 1, 2, 'Dishwasher - Greasy Rib'),
(9000008, 9000056, 0, 35, 0, 1, 0, 1, 1, 'Dishwasher - Menu Scrap'),
(9000008, 0, 9000101, 7, 0, 1, 0, 1, 1, 'Dishwasher - Waxworks green'),
(9000009, 9000056, 0, 40, 0, 1, 0, 1, 1, 'Fry-Oracle - Menu Scrap'),
(9000009, 1179, 0, 20, 0, 1, 0, 1, 1, 'Fry-Oracle - Ice Cold Milk'),
(9000009, 0, 9000101, 9, 0, 1, 0, 1, 1, 'Fry-Oracle - Waxworks green'),
(9000010, 9000058, 0, 45, 0, 1, 0, 1, 2, 'Grease Patrol - Greasy Rib'),
(9000010, 9000056, 0, 30, 0, 1, 0, 1, 1, 'Grease Patrol - Menu Scrap'),
(9000010, 0, 9000101, 7, 0, 1, 0, 1, 1, 'Grease Patrol - Waxworks green'),
(9000011, 9000064, 0, 4, 0, 1, 0, 1, 1, 'Consultant - Shiv'),
(9000011, 730, 0, 35, 0, 1, 0, 1, 1, 'Consultant - Murloc Eye'),
(9000011, 0, 9000101, 6, 0, 1, 0, 1, 1, 'Consultant - Waxworks green'),
(9000012, 9000057, 0, 50, 0, 1, 0, 1, 1, 'Steward - Leaflet'),
(9000012, 2589, 0, 30, 0, 1, 0, 1, 2, 'Steward - Linen Cloth'),
(9000012, 0, 9000101, 8, 0, 1, 0, 1, 1, 'Steward - Waxworks green'),
(9000013, 9000057, 0, 45, 0, 1, 0, 1, 1, 'Contract Mage - Leaflet'),
(9000013, 2589, 0, 25, 0, 1, 0, 1, 2, 'Contract Mage - Linen Cloth'),
(9000013, 0, 9000101, 8, 0, 1, 0, 1, 1, 'Contract Mage - Waxworks green'),
(9000014, 9000057, 0, 55, 0, 1, 0, 1, 2, 'Clerk - Leaflet'),
(9000014, 0, 9000101, 16, 0, 1, 0, 1, 1, 'Clerk - Waxworks green'),
(9000015, 9000057, 0, 45, 0, 1, 0, 1, 1, 'Bodyguard - Leaflet'),
(9000015, 2589, 0, 30, 0, 1, 0, 1, 2, 'Bodyguard - Linen Cloth'),
(9000015, 0, 9000101, 8, 0, 1, 0, 1, 1, 'Bodyguard - Waxworks green'),
(9000016, 769, 0, 55, 0, 1, 0, 1, 2, 'Grease Boar - Boar Meat'),
(9000016, 9000058, 0, 25, 0, 1, 0, 1, 1, 'Grease Boar - Greasy Rib'),
(9000016, 0, 9000101, 4, 0, 1, 0, 1, 1, 'Grease Boar - Waxworks green'),
(9000017, 9000059, 0, 80, 0, 1, 0, 1, 2, 'Dripping Wax - Wax Nodule'),
(9000017, 9000054, 0, 30, 0, 1, 0, 1, 1, 'Dripping Wax - Lump of Tallow'),
(9000017, 0, 9000101, 5, 0, 1, 0, 1, 1, 'Dripping Wax - Waxworks green'),
(9000018, 9000054, 0, 50, 0, 1, 0, 1, 2, 'Vat Tender - Lump of Tallow'),
(9000018, 9000059, 0, 35, 0, 1, 0, 1, 1, 'Vat Tender - Wax Nodule'),
(9000018, 0, 9000101, 8, 0, 1, 0, 1, 1, 'Vat Tender - Waxworks green'),
(9000020, 9000054, 0, 100, 0, 1, 0, 2, 3, 'King Wick - Lump of Tallow'),
(9000020, 9000055, 0, 60, 0, 1, 0, 1, 2, 'King Wick - Stolen Taper'),
(9000020, 772, 0, 40, 0, 1, 0, 1, 2, 'King Wick - Large Candle'),
(9000020, 9000061, 0, 22, 0, 1, 1, 1, 1, 'King Wick - Wick-Snuffer Cowl'),
(9000020, 9000050, 0, 14, 0, 1, 1, 1, 1, 'King Wick - Undercroft Leggings'),
(9000020, 9000051, 0, 14, 0, 1, 1, 1, 1, 'King Wick - Undercroft Tunic'),
(9000020, 9000052, 0, 14, 0, 1, 1, 1, 1, 'King Wick - Undercroft Stick'),
(9000020, 9000063, 0, 14, 0, 1, 1, 1, 1, 'King Wick - Dipper Mallet'),
(9000030, 9000058, 0, 100, 0, 1, 0, 1, 2, 'Snarlroast - Greasy Rib'),
(9000030, 9000056, 0, 50, 0, 1, 0, 1, 1, 'Snarlroast - Menu Scrap'),
(9000030, 9000062, 0, 22, 0, 1, 1, 1, 1, 'Snarlroast - Grease-Proof Treads'),
(9000030, 9000050, 0, 14, 0, 1, 1, 1, 1, 'Snarlroast - Undercroft Leggings'),
(9000030, 9000051, 0, 14, 0, 1, 1, 1, 1, 'Snarlroast - Undercroft Tunic'),
(9000030, 9000052, 0, 14, 0, 1, 1, 1, 1, 'Snarlroast - Undercroft Stick'),
(9000030, 9000060, 0, 14, 0, 1, 1, 1, 1, 'Snarlroast - Tallow Gloves'),
(9000040, 9000057, 0, 100, 0, 1, 0, 1, 2, 'Voss - Leaflet'),
(9000040, 9000050, 0, 12, 0, 1, 1, 1, 1, 'Voss - Undercroft Leggings'),
(9000040, 9000051, 0, 12, 0, 1, 1, 1, 1, 'Voss - Undercroft Tunic'),
(9000040, 9000052, 0, 12, 0, 1, 1, 1, 1, 'Voss - Undercroft Stick'),
(9000040, 9000060, 0, 12, 0, 1, 1, 1, 1, 'Voss - Tallow Gloves'),
(9000040, 9000063, 0, 12, 0, 1, 1, 1, 1, 'Voss - Dipper Mallet'),
(9000040, 9000053, 0, 100, 0, 2, 0, 1, 1, 'Voss hard - Overtime Vest'),
(9000045, 769, 0, 80, 0, 1, 0, 1, 2, 'Princess - Boar Meat'),
(9000045, 9000051, 0, 20, 0, 1, 1, 1, 1, 'Princess - Undercroft Tunic'),
(9000045, 9000062, 0, 16, 0, 1, 1, 1, 1, 'Princess - Grease-Proof Treads'),
(9000046, 769, 0, 50, 0, 1, 0, 1, 1, 'Oinksworth - Boar Meat'),
(9000046, 9000058, 0, 20, 0, 1, 0, 1, 1, 'Oinksworth - Greasy Rib'),
(9000046, 0, 9000101, 5, 0, 1, 0, 1, 1, 'Oinksworth - Waxworks green'),
(9000047, 2589, 0, 40, 0, 1, 0, 1, 2, 'Unit 07 - Linen Cloth'),
(9000047, 0, 9000101, 10, 0, 1, 0, 1, 1, 'Unit 07 - Waxworks green'),
(9000048, 769, 0, 50, 0, 1, 0, 1, 1, 'Lady Crackling - Boar Meat'),
(9000048, 0, 9000101, 5, 0, 1, 0, 1, 1, 'Lady Crackling - Waxworks green'),
(9000049, 769, 0, 50, 0, 1, 0, 1, 1, 'Honourable Ham - Boar Meat'),
(9000049, 0, 9000101, 5, 0, 1, 0, 1, 1, 'Honourable Ham - Waxworks green');

DELETE FROM `creature_text` WHERE `CreatureID` IN (9000001, 9000003, 9000007, 9000012, 9000017, 9000018, 9000019, 9000020, 9000030, 9000040, 9000045);
INSERT INTO `creature_text` (`CreatureID`, `GroupID`, `ID`, `Text`, `Type`, `Language`,
 `Probability`, `Emote`, `Duration`, `Sound`, `BroadcastTextId`, `TextRange`, `comment`) VALUES
(9000001, 0, 0, 'You no take candle!', 12, 0, 100, 0, 0, 0, 16658, 0, 'Scamp aggro'),
(9000003, 0, 0, 'Hot wax! Hot wax coming!', 12, 0, 100, 0, 0, 0, 0, 0, 'Wickmage aggro'),
(9000007, 0, 0, 'Kitchen closed. You are the special.', 12, 0, 100, 0, 0, 0, 0, 0, 'Line Cook aggro'),
(9000012, 0, 0, 'The Brotherhood has a contract on this shaft.', 12, 0, 50, 0, 0, 0, 1865, 0, 'Steward'),
(9000012, 0, 1, 'You picked the wrong union meeting.', 12, 0, 50, 0, 0, 0, 1866, 0, 'Steward'),
(9000017, 0, 0, 'The wax peels itself off the floor.', 16, 0, 100, 0, 0, 0, 0, 0, 'Dripping Wax aggro'),
(9000018, 0, 0, 'Dip! Dip! More dip!', 12, 0, 100, 0, 0, 0, 0, 0, 'Vat Tender aggro'),
(9000019, 0, 0, 'The wick... the wick remembers...', 12, 0, 100, 0, 0, 0, 0, 0, 'Acolyte aggro'),
(9000020, 0, 0, 'YOU NO TAKE KING CANDLE.', 14, 0, 100, 0, 0, 0, 0, 0, 'Wick aggro'),
(9000020, 1, 0, 'GIVE BACK. GIVE BACK NOW.', 14, 0, 100, 0, 0, 0, 0, 0, 'Wick steal'),
(9000020, 2, 0, 'MORE WAX.', 14, 0, 100, 0, 0, 0, 0, 0, 'Wick cart'),
(9000020, 3, 0, 'Yiieeeee! Me... dim...', 14, 0, 100, 0, 0, 0, 0, 0, 'Wick death'),
(9000030, 0, 0, 'Sit. Menu tonight is adventurer.', 14, 0, 100, 0, 0, 0, 0, 0, 'Snarl aggro'),
(9000030, 1, 0, 'Rare?', 14, 0, 100, 0, 0, 0, 0, 0, 'Snarl rare'),
(9000030, 2, 0, 'Medium.', 14, 0, 100, 0, 0, 0, 0, 0, 'Snarl medium'),
(9000030, 3, 0, 'WELL DONE.', 14, 0, 100, 0, 0, 0, 0, 0, 'Snarl well done'),
(9000030, 4, 0, 'Need a minute. Reduction.', 14, 0, 100, 0, 0, 0, 0, 0, 'Snarl 40%'),
(9000030, 5, 0, 'Tell Hogger... the stew... was for him...', 14, 0, 100, 0, 0, 0, 0, 0, 'Snarl death'),
(9000040, 0, 0, 'Hold it. You got a permit for that sword?', 14, 0, 100, 0, 0, 0, 0, 0, 'Voss aggro'),
(9000040, 1, 0, 'I still have to stab you a little. Contract''s binding.', 14, 0, 100, 0, 0, 0, 0, 0, 'Voss yes'),
(9000040, 2, 0, 'Grievance filed. With my fists.', 14, 0, 100, 0, 0, 0, 0, 0, 'Voss no'),
(9000040, 3, 0, 'Tell VanCleef... we need... a better dental plan...', 14, 0, 100, 0, 0, 0, 0, 0, 'Voss death'),
(9000045, 0, 0, '%s is... dethroned.', 16, 0, 100, 0, 0, 0, 0, 0, 'Princess death');

DELETE FROM `npc_text` WHERE `ID` IN (9000000, 9000010, 9000011);
INSERT INTO `npc_text` (`ID`, `text0_0`, `text0_1`, `Probability0`) VALUES
(9000000, 'Keep your voice down. Dughan cannot spare a patrol — Hogger, murlocs, two mines. Pestle''s candles walked into Fargodeep. Tomas''s larder followed.$B$BWiley already said it: the Defias are working with kobolds and gnolls. Westfall gets the big job. We get the pilot.$B$BTalk to me when you are ready to go below. I will still be here when you come back up.', '', 1),
(9000010, 'Hold it. You got a permit for that sword? Management is prepared to negotiate. You have twelve seconds.', '', 1),
(9000011, 'Demands: the candles stay ours. Tips are not optional. VanCleef gets his cut. The union gets dental.$B$BAccept the contract and I still have to stab you a little. Refuse and I file a grievance. With my fists.', '', 1);

DELETE FROM `gossip_menu` WHERE `MenuID` IN (9000000, 9000010, 9000011);
INSERT INTO `gossip_menu` (`MenuID`, `TextID`) VALUES
(9000000, 9000000),
(9000010, 9000010),
(9000011, 9000011);

DELETE FROM `gossip_menu_option` WHERE `MenuID` IN (9000000, 9000010, 9000011);
INSERT INTO `gossip_menu_option` (`MenuID`, `OptionID`, `OptionIcon`, `OptionText`,
 `OptionBroadcastTextID`, `OptionType`, `OptionNpcFlag`, `ActionMenuID`) VALUES
(9000000, 0, 0, 'We will enter the Waxworks.', 0, 1, 1, 0),
(9000000, 1, 0, 'Return to the surface.', 0, 1, 1, 0),
(9000010, 0, 0, 'No.', 0, 1, 1, 0),
(9000010, 1, 0, 'What are your demands?', 0, 1, 1, 9000011),
(9000010, 2, 0, 'Yes, we accept.', 0, 1, 1, 0),
(9000011, 0, 0, 'No.', 0, 1, 1, 0),
(9000011, 1, 0, 'Yes, we accept.', 0, 1, 1, 0);

DELETE FROM `creature_queststarter` WHERE `id` = 9000050 AND `quest` IN (9000000, 9000001, 9000003);
INSERT INTO `creature_queststarter` (`id`, `quest`) VALUES
(9000050, 9000000),
(9000050, 9000001),
(9000050, 9000003);

DELETE FROM `creature_questender` WHERE `id` = 9000050 AND `quest` IN (9000000, 9000001, 9000003);
INSERT INTO `creature_questender` (`id`, `quest`) VALUES
(9000050, 9000000),
(9000050, 9000001),
(9000050, 9000003);

DELETE FROM `quest_request_items` WHERE `ID` IN (9000000, 9000001, 9000003);
INSERT INTO `quest_request_items` (`ID`, `EmoteOnComplete`, `EmoteOnIncomplete`, `CompletionText`) VALUES
(9000000, 0, 0, 'Still standing around? The shaft is that way.'),
(9000001, 0, 0, 'The cooperative still stands. Get back in there.'),
(9000003, 0, 0, 'The pig still wears a crown. Optional, I said. Not imaginary.');

DELETE FROM `quest_offer_reward` WHERE `ID` IN (9000000, 9000001, 9000003);
INSERT INTO `quest_offer_reward` (`ID`, `Emote1`, `Emote2`, `Emote3`, `Emote4`, `EmoteDelay1`,
 `EmoteDelay2`, `EmoteDelay3`, `EmoteDelay4`, `RewardText`) VALUES
(9000000, 0, 0, 0, 0, 0, 0, 0, 0, 'Good. Stay in the lower shaft. If you die, the Goldshire spirit healer will not see you until you release.'),
(9000001, 0, 0, 0, 0, 0, 0, 0, 0, 'Dughan will never know. The candles go back to Pestle. Tell Tomas the stew was a loss.'),
(9000003, 0, 0, 0, 0, 0, 0, 0, 0, 'Eastvale will want that watcher back. The pumpkin is yours to forget.');
-- The Waxworks entrance: Dark Portal on the Goldshire green.
-- Walk through the pink veil. Instance hop is map 44 (custom cave WMO).

DELETE FROM `gameobject_template` WHERE `entry` BETWEEN 9000013 AND 9000017;
DELETE FROM `gameobject_template` WHERE `entry` = 9000029;
INSERT INTO `gameobject_template` (`entry`, `type`, `displayId`, `name`, `size`, `Data0`, `Data3`,
 `AIName`, `ScriptName`, `VerifiedBuild`) VALUES
(9000013, 5, 7267, 'The Waxworks Portal', 0.87, 0, 0, '', '', 0),
(9000014, 5, 9500, 'Waxworks Portal Particles', 4.8, 0, 0, '', '', 0),
(9000015, 5, 9503, 'Waxworks Portal Vortex', 7.2, 0, 0, '', '', 0),
(9000016, 5, 1327, 'The Waxworks', 9.5, 0, 0, '', 'go_waxworks_entrance', 0),
(9000017, 5, 1327, 'Portal to Elwynn Forest', 2.4, 0, 0, '', 'go_waxworks_exit', 0),
(9000029, 5, 1327, 'The Waxworks Veil', 9.5, 0, 0, '', '', 0);

DELETE FROM `gameobject_template_addon` WHERE `entry` BETWEEN 9000013 AND 9000017;
DELETE FROM `gameobject_template_addon` WHERE `entry` = 9000029;
INSERT INTO `gameobject_template_addon` (`entry`, `faction`, `flags`, `mingold`, `maxgold`) VALUES
(9000013, 0, 0, 0, 0),
(9000014, 0, 0, 0, 0),
(9000015, 0, 0, 0, 0),
(9000016, 0, 0, 0, 0),
(9000017, 0, 0, 0, 0),
(9000029, 0, 0, 0, 0);

-- ori 3.1416 (west). Quaternion: rot2 = sin(o/2) = 1, rot3 = cos(o/2) = 0.
DELETE FROM `gameobject` WHERE `guid` BETWEEN 9000034 AND 9000055;
INSERT INTO `gameobject` (`guid`, `id`, `map`, `spawnMask`, `phaseMask`, `position_x`,
 `position_y`, `position_z`, `orientation`, `rotation0`, `rotation1`, `rotation2`, `rotation3`,
 `spawntimesecs`, `animprogress`, `state`, `Comment`) VALUES
(9000034, 9000013, 0, 1, 1, -9462, 62, 56.7, 3.1416, 0, 0, 1, 0, 180, 100, 1, 'Waxworks dark portal'),
(9000035, 9000014, 0, 1, 1, -9462, 62, 58.2, 3.1416, 0, 0, 1, 0, 180, 100, 1, 'Waxworks portal particles'),
(9000036, 9000016, 0, 1, 1, -9462, 62, 57.4, 3.1416, 0, 0, 1, 0, 180, 100, 1, 'Waxworks pink veil'),
(9000037, 9000015, 0, 1, 1, -9462, 62, 57.6, 3.1416, 0, 0, 1, 0, 180, 100, 1, 'Waxworks CoT swirl'),
(9000038, 9000029, 0, 1, 1, -9462, 58.5, 57.4, 3.1416, 0, 0, 1, 0, 180, 100, 1, 'Waxworks pink veil south'),
(9000040, 9000029, 0, 1, 1, -9462, 65.5, 57.4, 3.1416, 0, 0, 1, 0, 180, 100, 1, 'Waxworks pink veil north'),
(9000041, 9000029, 0, 1, 1, -9462, 62, 61.8, 3.1416, 0, 0, 1, 0, 180, 100, 1, 'Waxworks pink veil high'),
(9000039, 9000017, 44, 1, 1, 2, 0, 0.15, 3.14, 0, 0, 1, 0, 180, 100, 1, 'Waxworks exit at mouth');

DELETE FROM `areatrigger` WHERE `entry` = 9000001;
DELETE FROM `areatrigger_scripts` WHERE `entry` = 9000001;

-- Restore ridge wildlife hidden for the old plaza. Never touch Goldtooth 80644.
UPDATE `creature` SET `phaseMask` = 1 WHERE `guid` IN (
 80316,80323,80372,80373,80374,80375,80376,80377,80378,80379,
 80413,80414,80415,80416,
 241245,241257,241260,241315,241329,241330,241334,241338,
 241357,241358,241361,241380,241394,241422,241432);
UPDATE `gameobject` SET `phaseMask` = 1 WHERE `guid` IN (26814,206471,206477,206540);
-- Candle carpet + unused-gallery shrines inside the map-44 cave.
-- Goldtooth guid 80644 at -9745.84, 87.57, 12.77: keep >=15 yards clear.

DELETE FROM `creature` WHERE `guid` BETWEEN 9000080 AND 9000099;
INSERT INTO `creature` (`guid`, `id`, `map`, `spawnMask`, `phaseMask`, `equipment_id`,
 `position_x`, `position_y`, `position_z`, `orientation`, `spawntimesecs`,
 `wander_distance`, `curhealth`, `curmana`, `MovementType`, `Comment`) VALUES
-- Mouth shrine (north of landing so enter does not instantly pull)
(9000080, 9000019, 44, 1, 1, 0, -24.5, 1.2, 0.15, 3.14, 86400, 0, 1, 0, 0, 'Mouth acolyte E'),
(9000081, 9000019, 44, 1, 1, 0, -26.8, 1.8, 0.15, 4.4, 86400, 0, 1, 0, 0, 'Mouth acolyte NE'),
(9000082, 9000019, 44, 1, 1, 0, -27.4, 0, 0.15, 0, 86400, 0, 1, 0, 0, 'Mouth acolyte NW'),
(9000083, 9000019, 44, 1, 1, 0, -26.8, -1.8, 0.15, 1.88, 86400, 0, 1, 0, 0, 'Mouth acolyte SW'),
(9000084, 9000019, 44, 1, 1, 0, -24.5, -1.2, 0.15, 2.5, 86400, 0, 1, 0, 0, 'Mouth acolyte SE'),
-- North gallery shrine (world stand -46,-32 facing π; set piece in front at -50,-32)
(9000085, 9000019, 44, 1, 1, 0, -50, -28.6, 1.15, 4.71, 86400, 0, 1, 0, 0, 'North acolyte N'),
(9000086, 9000019, 44, 1, 1, 0, -53.4, -32, 1.15, 0, 86400, 0, 1, 0, 0, 'North acolyte W'),
(9000087, 9000019, 44, 1, 1, 0, -50, -35.4, 1.15, 1.57, 86400, 0, 1, 0, 0, 'North acolyte S'),
(9000088, 9000019, 44, 1, 1, 0, -47.4, -34.2, 1.15, 2.36, 86400, 0, 1, 0, 0, 'North acolyte SE'),
(9000089, 9000019, 44, 1, 1, 0, -47.4, -29.8, 1.15, 3.93, 86400, 0, 1, 0, 0, 'North acolyte NE'),
-- West chapel shrine (world stand -22,28 facing π; set piece in front at -26,28)
(9000090, 9000019, 44, 1, 1, 0, -26, 31.2, 0.15, 4.71, 86400, 0, 1, 0, 0, 'West acolyte N'),
(9000091, 9000019, 44, 1, 1, 0, -29.2, 28, 0.15, 0, 86400, 0, 1, 0, 0, 'West acolyte W'),
(9000092, 9000019, 44, 1, 1, 0, -26, 24.8, 0.15, 1.57, 86400, 0, 1, 0, 0, 'West acolyte S'),
(9000093, 9000019, 44, 1, 1, 0, -23.4, 25.6, 0.15, 2.36, 86400, 0, 1, 0, 0, 'West acolyte SE'),
(9000094, 9000019, 44, 1, 1, 0, -23.4, 30.4, 0.15, 3.93, 86400, 0, 1, 0, 0, 'West acolyte NE'),
-- King Wick approach shrine (tunnel side of stand, >=12y from boss at -96)
(9000095, 9000019, 44, 1, 1, 0, -80, 0, 0.65, 3.14, 86400, 0, 1, 0, 0, 'Wick acolyte E'),
(9000096, 9000019, 44, 1, 1, 0, -80, 4, 0.65, 4.4, 86400, 0, 1, 0, 0, 'Wick acolyte NE'),
(9000097, 9000019, 44, 1, 1, 0, -82, 2.5, 0.65, 5.65, 86400, 0, 1, 0, 0, 'Wick acolyte NW'),
(9000098, 9000019, 44, 1, 1, 0, -82, -2.5, 0.65, 0.63, 86400, 0, 1, 0, 0, 'Wick acolyte SW'),
(9000099, 9000019, 44, 1, 1, 0, -80, -4, 0.65, 1.88, 86400, 0, 1, 0, 0, 'Wick acolyte SE');

DELETE FROM `creature_addon` WHERE `guid` BETWEEN 9000080 AND 9000099;
INSERT INTO `creature_addon` (`guid`, `path_id`, `mount`, `bytes1`, `bytes2`, `emote`,
 `visibilityDistanceType`, `auras`) VALUES
(9000080, 0, 0, 8, 1, 68, 0, NULL),
(9000081, 0, 0, 8, 1, 68, 0, NULL),
(9000082, 0, 0, 8, 1, 68, 0, NULL),
(9000083, 0, 0, 8, 1, 68, 0, NULL),
(9000084, 0, 0, 8, 1, 68, 0, NULL),
(9000085, 0, 0, 8, 1, 68, 0, NULL),
(9000086, 0, 0, 8, 1, 68, 0, NULL),
(9000087, 0, 0, 8, 1, 68, 0, NULL),
(9000088, 0, 0, 8, 1, 68, 0, NULL),
(9000089, 0, 0, 8, 1, 68, 0, NULL),
(9000090, 0, 0, 8, 1, 68, 0, NULL),
(9000091, 0, 0, 8, 1, 68, 0, NULL),
(9000092, 0, 0, 8, 1, 68, 0, NULL),
(9000093, 0, 0, 8, 1, 68, 0, NULL),
(9000094, 0, 0, 8, 1, 68, 0, NULL),
(9000095, 0, 0, 8, 1, 68, 0, NULL),
(9000096, 0, 0, 8, 1, 68, 0, NULL),
(9000097, 0, 0, 8, 1, 68, 0, NULL),
(9000098, 0, 0, 8, 1, 68, 0, NULL),
(9000099, 0, 0, 8, 1, 68, 0, NULL);

DELETE FROM `gameobject` WHERE `guid` BETWEEN 9000070 AND 9000190;
INSERT INTO `gameobject` (`guid`, `id`, `map`, `spawnMask`, `phaseMask`, `position_x`,
 `position_y`, `position_z`, `orientation`, `rotation2`, `rotation3`, `spawntimesecs`,
 `animprogress`, `state`, `Comment`) VALUES
-- Great red shrine candles
(9000070, 9000028, 44, 1, 1, -22, 0, 0.15, 0.4, 0.1987, 0.9801, 180, 100, 1, 'Mouth great red candle'),
(9000071, 9000028, 44, 1, 1, -50, -32, 1.15, 1.2, 0.5646, 0.8253, 180, 100, 1, 'North great red candle'),
(9000072, 9000031, 44, 1, 1, -26, 28, 0.15, 3.1416, 1, -0, 180, 100, 1, 'West chapel altar'),
(9000073, 9000023, 44, 1, 1, -81, 0, 0.65, 0, 0, 1, 180, 100, 1, 'Wick approach brazier'),
-- Small red ring around each shrine
(9000074, 9000027, 44, 1, 1, -24.2, 1.6, 0.15, 0.2, 0.0998, 0.995, 180, 100, 1, 'Mouth red ring'),
(9000075, 9000027, 44, 1, 1, -27.2, 1.4, 0.15, 1.8, 0.7833, 0.6216, 180, 100, 1, 'Mouth red ring'),
(9000076, 9000027, 44, 1, 1, -27.2, -1.4, 0.15, 4, 0.9093, -0.4161, 180, 100, 1, 'Mouth red ring'),
(9000077, 9000027, 44, 1, 1, -52.6, -32, 1.15, 0.5, 0.2474, 0.9689, 180, 100, 1, 'North red ring'),
(9000078, 9000027, 44, 1, 1, -48.4, -34.4, 1.15, 2.2, 0.8912, 0.4536, 180, 100, 1, 'North red ring'),
(9000079, 9000027, 44, 1, 1, -48.4, -29.6, 1.15, 5, 0.5985, -0.8011, 180, 100, 1, 'North red ring'),
(9000080, 9000032, 44, 1, 1, -26, 25, 0.15, 0.8, 0.3894, 0.9211, 180, 100, 1, 'West chapel candelabra S'),
(9000081, 9000032, 44, 1, 1, -26, 31, 0.15, 2.6, 0.9636, 0.2675, 180, 100, 1, 'West chapel candelabra N'),
(9000082, 9000009, 44, 1, 1, -24.4, 28, 1.15, 4.4, 0.8085, -0.5885, 180, 100, 1, 'West chapel lantern'),
(9000083, 9000009, 44, 1, 1, -94, 5.4, 1.2, 1.1, 0.5227, 0.8525, 180, 100, 1, 'Wick throne lantern'),
(9000084, 9000009, 44, 1, 1, -94, -5.4, 1.2, 3, 0.9975, 0.0707, 180, 100, 1, 'Wick throne lantern'),
(9000085, 9000011, 44, 1, 1, -92, 6.5, 0.65, 5.4, 0.4274, -0.9041, 180, 100, 1, 'Wick throne pillar'),
-- Mouth / entry carpet (scatter around pocket origin)
(9000086, 9000024, 44, 1, 1, -9, -2.4, 0.15, 0.3, 0.1494, 0.9888, 180, 100, 1, 'Mouth stub'),
(9000087, 9000025, 44, 1, 1, -14, -3.2, 0.15, 2.1, 0.8674, 0.4976, 180, 100, 1, 'Mouth taper'),
(9000088, 9000026, 44, 1, 1, -17, -2, 0.15, 4.7, 0.7115, -0.7027, 180, 100, 1, 'Mouth tall'),
(9000089, 9000024, 44, 1, 1, -15, 2.4, 0.15, 1.4, 0.6442, 0.7648, 180, 100, 1, 'Mouth stub'),
(9000090, 9000006, 44, 1, 1, -13, 3.2, 0.15, 5.8, 0.2392, -0.971, 180, 100, 1, 'Mouth candle'),
(9000091, 9000025, 44, 1, 1, -19, 2, 0.15, 0.9, 0.435, 0.9004, 180, 100, 1, 'Mouth taper'),
(9000092, 9000024, 44, 1, 1, -18, -2.8, 0.15, 3.3, 0.9969, -0.0791, 180, 100, 1, 'Mouth stub'),
(9000093, 9000026, 44, 1, 1, -20.5, 1.6, 0.15, 2.6, 0.9636, 0.2675, 180, 100, 1, 'Mouth tall'),
-- Wickworks floor
(9000094, 9000024, 44, 1, 1, -35, -10, 0.15, 3.3416, 0.995, -0.0998, 180, 100, 1, 'Wickworks stub'),
(9000095, 9000025, 44, 1, 1, -43, -12, 0.15, 4.8416, 0.66, -0.7513, 180, 100, 1, 'Wickworks taper'),
(9000096, 9000026, 44, 1, 1, -48, -6, 0.15, 0.9584, 0.4611, 0.8874, 180, 100, 1, 'Wickworks tall'),
(9000097, 9000024, 44, 1, 1, -51, -1, 0.15, 2.3584, 0.9243, 0.3817, 180, 100, 1, 'Wickworks stub'),
(9000098, 9000027, 44, 1, 1, -46, 3, 0.15, 5.9416, 0.17, -0.9854, 180, 100, 1, 'Wickworks red'),
(9000099, 9000024, 44, 1, 1, -41, 8, 0.15, 3.7416, 0.9553, -0.2955, 180, 100, 1, 'Wickworks stub'),
(9000100, 9000025, 44, 1, 1, -55, 6, 0.15, 0.7584, 0.3702, 0.929, 180, 100, 1, 'Wickworks taper'),
(9000101, 9000026, 44, 1, 1, -61, 0, 0.15, 4.2416, 0.8525, -0.5227, 180, 100, 1, 'Wickworks tall'),
(9000102, 9000024, 44, 1, 1, -60, -9, 0.15, 1.6584, 0.7374, 0.6755, 180, 100, 1, 'Wickworks stub'),
(9000103, 9000006, 44, 1, 1, -63, -8, 0.15, 5.3416, 0.4536, -0.8912, 180, 100, 1, 'Wickworks candle'),
(9000104, 9000024, 44, 1, 1, -50, 14, 0.15, 3.5416, 0.9801, -0.1987, 180, 100, 1, 'Cart stub'),
(9000105, 9000024, 44, 1, 1, -56, 12.5, 0.15, 2.0584, 0.8569, 0.5155, 180, 100, 1, 'Cart stub'),
(9000106, 9000025, 44, 1, 1, -51, 11, 0.15, 4.7416, 0.6967, -0.7174, 180, 100, 1, 'Cart taper'),
-- North gallery wing (world -46,-32 stand; dress in front toward -X)
(9000107, 9000024, 44, 1, 1, -43, -25, 1.15, 0.8, 0.3894, 0.9211, 180, 100, 1, 'North stub'),
(9000108, 9000025, 44, 1, 1, -43, -37, 1.15, 2.4, 0.932, 0.3624, 180, 100, 1, 'North taper'),
(9000109, 9000026, 44, 1, 1, -51, -39, 1.15, 4, 0.9093, -0.4161, 180, 100, 1, 'North tall'),
(9000110, 9000024, 44, 1, 1, -53, -36, 1.15, 5.7, 0.2875, -0.9578, 180, 100, 1, 'North stub'),
(9000111, 9000025, 44, 1, 1, -55, -32, 1.15, 1.3, 0.6052, 0.7961, 180, 100, 1, 'North taper'),
(9000112, 9000024, 44, 1, 1, -53, -27, 1.15, 3.1, 0.9998, 0.0208, 180, 100, 1, 'North stub'),
(9000113, 9000026, 44, 1, 1, -41, -30, 1.15, 4.6, 0.7457, -0.6663, 180, 100, 1, 'North tall'),
(9000114, 9000006, 44, 1, 1, -44, -35, 1.15, 0.5, 0.2474, 0.9689, 180, 100, 1, 'North candle'),
-- West chapel wing (world -22,28 stand; dress in front toward -X)
(9000115, 9000024, 44, 1, 1, -24, 32, 0.15, 1, 0.4794, 0.8776, 180, 100, 1, 'West stub'),
(9000116, 9000025, 44, 1, 1, -28, 32, 0.15, 2.7, 0.9757, 0.219, 180, 100, 1, 'West taper'),
(9000117, 9000026, 44, 1, 1, -29, 28, 0.15, 4.3, 0.8369, -0.5474, 180, 100, 1, 'West tall'),
(9000118, 9000024, 44, 1, 1, -28, 24, 0.15, 5.9, 0.1904, -0.9817, 180, 100, 1, 'West stub'),
(9000119, 9000025, 44, 1, 1, -24, 24, 0.15, 0.7, 0.3429, 0.9394, 180, 100, 1, 'West taper'),
(9000120, 9000024, 44, 1, 1, -23, 31, 0.15, 3.5, 0.984, -0.1782, 180, 100, 1, 'West stub'),
(9000121, 9000006, 44, 1, 1, -23, 25, 0.15, 1.9, 0.8134, 0.5817, 180, 100, 1, 'West candle'),
-- King Wick gallery (world -88,0 stand; throne dress toward -X)
(9000122, 9000024, 44, 1, 1, -84, 4, 0.65, 0.3, 0.1494, 0.9888, 180, 100, 1, 'Wick stub'),
(9000123, 9000025, 44, 1, 1, -84, -4, 0.65, 2, 0.8415, 0.5403, 180, 100, 1, 'Wick taper'),
(9000124, 9000026, 44, 1, 1, -94, 4, 1.2, 4.4, 0.8085, -0.5885, 180, 100, 1, 'Wick tall'),
(9000125, 9000024, 44, 1, 1, -94, -2, 1.2, 5.6, 0.335, -0.9422, 180, 100, 1, 'Wick stub'),
(9000126, 9000009, 44, 1, 1, -90, 7, 0.65, 1.4, 0.6442, 0.7648, 180, 100, 1, 'Wick lantern'),
(9000127, 9000025, 44, 1, 1, -92, -4, 1.2, 3.2, 0.9996, -0.0292, 180, 100, 1, 'Wick taper'),
(9000128, 9000024, 44, 1, 1, -86, 6, 0.65, 0.8, 0.3894, 0.9211, 180, 100, 1, 'Wick stub'),
(9000129, 9000026, 44, 1, 1, -86, -6, 0.65, 2.9, 0.9927, 0.1205, 180, 100, 1, 'Wick tall'),
-- Drop toward commissary
(9000130, 9000024, 44, 1, 1, -66, 10, -3.35, 4.3416, 0.8253, -0.5646, 180, 100, 1, 'Lower stub'),
(9000131, 9000025, 44, 1, 1, -73, 17, -4.85, 6.1416, 0.0707, -0.9975, 180, 100, 1, 'Lower taper'),
(9000132, 9000026, 44, 1, 1, -80, 24, -6.85, 1.6584, 0.7374, 0.6755, 180, 100, 1, 'Lower tall'),
(9000133, 9000024, 44, 1, 1, -84, 49, -6.35, 3.5416, 0.9801, -0.1987, 180, 100, 1, 'Alcove stub'),
(9000134, 9000027, 44, 1, 1, -90, 49, -6.35, 5.2416, 0.4976, -0.8674, 180, 100, 1, 'Alcove red'),
(9000135, 9000024, 44, 1, 1, -82, 30, -6.85, 2.1584, 0.8816, 0.472, 180, 100, 1, 'Kitchen stub'),
(9000136, 9000025, 44, 1, 1, -94, 38, -6.85, 4.7416, 0.6967, -0.7174, 180, 100, 1, 'Kitchen taper'),
(9000137, 9000026, 44, 1, 1, -96, 32, -6.85, 0.6584, 0.3233, 0.9463, 180, 100, 1, 'Kitchen tall'),
(9000138, 9000024, 44, 1, 1, -84, 38, -6.85, 4.0416, 0.9004, -0.435, 180, 100, 1, 'Kitchen stub'),
(9000139, 9000027, 44, 1, 1, -92, 45, -6.35, 1.3584, 0.6282, 0.7781, 180, 100, 1, 'Kitchen red'),
(9000140, 9000024, 44, 1, 1, -98, 36, -6.85, 5.5416, 0.3624, -0.932, 180, 100, 1, 'Kitchen stub'),
-- Voss hall
(9000141, 9000024, 44, 1, 1, -130, -8, 0.65, 3.7416, 0.9553, -0.2955, 180, 100, 1, 'Union stub'),
(9000142, 9000025, 44, 1, 1, -142, -8, 0.65, 5.9416, 0.17, -0.9854, 180, 100, 1, 'Union taper'),
(9000143, 9000026, 44, 1, 1, -132, -2, 0.65, 1.0584, 0.5048, 0.8632, 180, 100, 1, 'Union tall'),
(9000144, 9000024, 44, 1, 1, -140, 2, 0.65, 2.7584, 0.9817, 0.1904, 180, 100, 1, 'Union stub'),
(9000145, 9000027, 44, 1, 1, -130, 12, 0.65, 4.6416, 0.7317, -0.6816, 180, 100, 1, 'Union red'),
(9000146, 9000024, 44, 1, 1, -138, 14, 0.65, 0.4584, 0.2272, 0.9738, 180, 100, 1, 'Union stub'),
-- Pumpkin sty
(9000147, 9000024, 44, 1, 1, -82, -35, 9.65, 3.8416, 0.9394, -0.3429, 180, 100, 1, 'Sty stub'),
(9000148, 9000025, 44, 1, 1, -92, -37, 9.65, 5.4416, 0.4085, -0.9128, 180, 100, 1, 'Sty taper'),
(9000149, 9000026, 44, 1, 1, -94, -27, 9.65, 1.7584, 0.7702, 0.6378, 180, 100, 1, 'Sty tall'),
(9000150, 9000024, 44, 1, 1, -84, -25, 9.65, 4.9416, 0.6216, -0.7833, 180, 100, 1, 'Sty stub'),
(9000151, 9000027, 44, 1, 1, -88, -34, 9.65, 0.2584, 0.1288, 0.9917, 180, 100, 1, 'Sty red'),
-- NorthShrine altar / wax figure / lanterns (in front of stand -46,-32)
(9000176, 9000029, 44, 1, 1, -50, -32, 1.15, 3.1416, 1, -0, 180, 100, 1, 'North shrine altar'),
(9000177, 9000030, 44, 1, 1, -50, -32, 1.85, 3.1416, 1, -0, 180, 100, 1, 'North wax effigy'),
(9000178, 9000009, 44, 1, 1, -48, -29.2, 2.15, 4, 0.9093, -0.4161, 180, 100, 1, 'North shrine lantern'),
(9000179, 9000009, 44, 1, 1, -52.4, -34.6, 2.15, 1.1, 0.5227, 0.8525, 180, 100, 1, 'North shrine lantern'),
(9000180, 9000023, 44, 1, 1, -51.6, -30.2, 1.15, 5.4, 0.4274, -0.9041, 180, 100, 1, 'North shrine brazier'),
(9000181, 9000026, 44, 1, 1, -49.2, -28.4, 1.15, 0.3, 0.1494, 0.9888, 180, 100, 1, 'North shrine tall'),
(9000182, 9000027, 44, 1, 1, -50, -35.8, 1.15, 2.8, 0.9854, 0.17, 180, 100, 1, 'North shrine ritual'),
-- WestShrine chapel altar / wax saint / candelabra (in front of stand -22,28)
(9000183, 9000030, 44, 1, 1, -26, 28, 0.85, 3.1416, 1, -0, 180, 100, 1, 'West wax saint'),
(9000184, 9000032, 44, 1, 1, -24.4, 28, 0.15, 1.57, 0.7068, 0.7074, 180, 100, 1, 'West aisle candelabra'),
(9000185, 9000026, 44, 1, 1, -27.6, 31.4, 0.15, 0.3, 0.1494, 0.9888, 180, 100, 1, 'West chapel tall N'),
(9000186, 9000026, 44, 1, 1, -27.6, 24.6, 0.15, 5.9, 0.1904, -0.9817, 180, 100, 1, 'West chapel tall S'),
(9000187, 9000009, 44, 1, 1, -28.4, 30.6, 1.15, 4, 0.9093, -0.4161, 180, 100, 1, 'West chapel lantern N'),
(9000188, 9000009, 44, 1, 1, -28.4, 25.4, 1.15, 2.2, 0.8912, 0.4536, 180, 100, 1, 'West chapel lantern S'),
(9000189, 9000025, 44, 1, 1, -20.4, 32.2, 0.15, 5.4, 0.4274, -0.9041, 180, 100, 1, 'West pew taper N'),
(9000190, 9000025, 44, 1, 1, -20.4, 23.8, 0.15, 1.1, 0.5227, 0.8525, 180, 100, 1, 'West pew taper S');
-- Type-14 cave kit removed: The Waxworks is a real map-44 instance (Waxworks.wmo).

DELETE FROM `gameobject` WHERE `guid` BETWEEN 9000200 AND 9000211;
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
