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

DELETE FROM `creature_loot_template` WHERE `Entry` IN (
 9000001,9000002,9000003,9000004,9000005,9000006,9000007,9000008,9000009,
 9000010,9000011,9000012,9000013,9000014,9000015,9000016,9000017,9000018,
 9000020,9000030,9000040,9000045,9000046,9000047,9000048,9000049);
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
