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
