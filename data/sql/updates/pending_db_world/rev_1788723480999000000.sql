-- The Waxworks (map 44): Candelabrus, a walking candle boss (round 6).
-- Body: a NEW creature model, Creature\WaxCandle\WaxCandle.m2 (rig transplant
-- onto the Kobold skeleton: wax cylinder with a face, two arms, two legs, wick
-- and one flame). Client files ship in patch-4.MPQ; CreatureModelData 60000 +
-- CreatureDisplayInfo 60000 ship in patch-enUS-4.MPQ and are mirrored here as
-- *_dbc overlay rows (client-data contract). CDI scale 1.3 = 6 ft base;
-- creature_template_model DisplayScale 3 makes the boss a ~18 ft giant.
-- The North Shrine is now the Tallow Cathedral: a 64x100x28 yard hall in the
-- Waxworks WMO (world x -78..-14, y -125..-25, floor z 1.0) with a four-tier
-- dais at the north end. The boss stands on the dais top (z 3.0) at (-46,-106)
-- facing the nave and fights like a normal melee boss (ground movement).
-- SmartAI only. Guid 9000212, game_tele 9000053 wax44_candle (nave entrance)
-- and 9000054 wax44_dais (foot of the dais).
-- GO 9000071 (old floating Great Red Candle) and 9000177 (wax effigy) are
-- deleted; the old shrine GOs and acolytes are re-laid around the altar at the
-- foot of the dais and at the hall entrance.
-- WaxCandle model: server copies of the DBC rows shipped in patch-enUS-4 (client-data contract).
DELETE FROM `creaturemodeldata_dbc` WHERE `ID` = 60000;
INSERT INTO `creaturemodeldata_dbc` (
  `ID`, `Flags`, `ModelName`, `SizeClass`, `ModelScale`, `BloodID`, `FootprintTextureID`, `FootprintTextureLength`,
  `FootprintTextureWidth`, `FootprintParticleScale`, `FoleyMaterialID`, `FootstepShakeSize`, `DeathThudShakeSize`,
  `SoundID`, `CollisionWidth`, `CollisionHeight`, `MountHeight`, `GeoBoxMinX`, `GeoBoxMinY`, `GeoBoxMinZ`,
  `GeoBoxMaxX`, `GeoBoxMaxY`, `GeoBoxMaxZ`, `WorldEffectScale`, `AttachedEffectScale`, `MissileCollisionRadius`,
  `MissileCollisionPush`, `MissileCollisionRaise`) VALUES
(60000, 0, 'Creature\\WaxCandle\\WaxCandle.mdx', 1, 1.0, 1, 1, 18.0, 12.0, 1.0, 0, 0.0, 0.0, 26, 0.7, 1.95, 0.0, -0.35,
-0.45, 0.0, 0.35, 0.45, 1.95, 1.0, 1.0, 0.0, 0.0, 0.0);

DELETE FROM `creaturedisplayinfo_dbc` WHERE `ID` = 60000;
INSERT INTO `creaturedisplayinfo_dbc` (
  `ID`, `ModelID`, `SoundID`, `ExtendedDisplayInfoID`, `CreatureModelScale`, `CreatureModelAlpha`,
  `TextureVariation_1`, `TextureVariation_2`, `TextureVariation_3`, `PortraitTextureName`, `BloodLevel`, `BloodID`,
  `NPCSoundID`, `ParticleColorID`, `CreatureGeosetData`, `ObjectEffectPackageID`) VALUES
(60000, 60000, 26, 0, 1.3, 255, 'WaxCandleSkin', '', '', '', 0, 0, 0, 0, 0, 0);

DELETE FROM `creature_model_info` WHERE `DisplayID` = 60000;
INSERT INTO `creature_model_info` (`DisplayID`, `BoundingRadius`, `CombatReach`, `Gender`, `DisplayID_Other_Gender`,
 `VerifiedBuild`) VALUES
(60000, 0.45, 1.5, 2, 0, 0);

DELETE FROM `creature_template` WHERE `entry` IN (9000081, 9000082);
INSERT INTO `creature_template` (`entry`, `name`, `subname`, `minlevel`, `maxlevel`, `faction`,
 `npcflag`, `gossip_menu_id`, `speed_walk`, `speed_run`, `detection_range`, `rank`,
 `DamageModifier`, `BaseAttackTime`, `RangeAttackTime`, `unit_class`, `unit_flags`,
 `unit_flags2`, `type`, `lootid`, `mingold`, `maxgold`, `AIName`, `HealthModifier`, `ManaModifier`,
 `RegenHealth`, `flags_extra`, `CreatureImmunitiesId`, `ScriptName`, `VerifiedBuild`) VALUES
(9000081, 'Candelabrus', 'His Waxcellency, the Tallow Tyrant', 12, 12, 26, 0, 0, 1, 0.85714, 16, 1,
 2.2, 2000, 2000, 8, 0, 2048, 4, 9000081, 70, 120, 'SmartAI', 7.5, 3, 1, 536870912, -273, '', 0),
(9000082, 'Wickling', 'Tea-Light', 8, 8, 26, 0, 0, 1, 1, 18, 1, 1.35, 2000, 2000, 1, 0, 2048, 7,
 9000082, 8, 20, '', 1.6, 1, 1, 536870912, 0, '', 0);

DELETE FROM `creature_template_model` WHERE `CreatureID` IN (9000081, 9000082);
INSERT INTO `creature_template_model` (`CreatureID`, `Idx`, `CreatureDisplayID`, `DisplayScale`,
 `Probability`, `VerifiedBuild`) VALUES
(9000081, 0, 60000, 3, 1, 0),
(9000082, 0, 10913, 0.55, 1, 0);

-- Default ground movement (the round-5 hovering/rooted row is removed).
DELETE FROM `creature_template_movement` WHERE `CreatureId` = 9000081;

DELETE FROM `creature_template_addon` WHERE `entry` IN (9000081, 9000082);
INSERT INTO `creature_template_addon` (`entry`, `path_id`, `mount`, `bytes1`, `bytes2`, `emote`,
 `visibilityDistanceType`, `auras`) VALUES
(9000081, 0, 0, 0, 1, 0, 0, NULL),
(9000082, 0, 0, 0, 1, 0, 0, NULL);

DELETE FROM `creature` WHERE `guid` = 9000212;
INSERT INTO `creature` (`guid`, `id`, `map`, `spawnMask`, `phaseMask`, `equipment_id`,
 `position_x`, `position_y`, `position_z`, `orientation`, `spawntimesecs`,
 `wander_distance`, `curhealth`, `curmana`, `MovementType`, `Comment`) VALUES
(9000212, 9000081, 44, 1, 1, 0, -46, -106, 3.0, 1.5708, 600, 0, 1, 0, 0,
 'Candelabrus on the Tallow Cathedral dais top, facing the nave / hall entrance');

-- The WMO mother candle behind the dais is the backdrop; the GOs that sat inside
-- the old pillar are gone.
DELETE FROM `gameobject` WHERE `guid` IN (9000071, 9000177);

-- Acolyte arc at the foot of the dais, around the altar, facing the boss (-Y).
UPDATE `creature` SET `position_x` = -46, `position_y` = -88.5, `orientation` = 4.7124
 WHERE `guid` = 9000085;
UPDATE `creature` SET `position_x` = -41, `position_y` = -89.5, `orientation` = 4.7124
 WHERE `guid` = 9000086;
UPDATE `creature` SET `position_x` = -51, `position_y` = -89.5, `orientation` = 4.7124
 WHERE `guid` = 9000087;
UPDATE `creature` SET `position_x` = -37, `position_y` = -91.5, `orientation` = 4.7124
 WHERE `guid` = 9000088;
UPDATE `creature` SET `position_x` = -55, `position_y` = -91.5, `orientation` = 4.7124
 WHERE `guid` = 9000089;

-- Shrine GOs re-laid in the cathedral. Hall floor z 1.0 (stand 1.15); dais tier 1
-- starts at y -95. Originals (restore if needed):
-- 9000077 (-52.6,-32,1.15), 9000078 (-48.4,-34.4,1.15), 9000079 (-48.4,-29.6,1.15),
-- 9000182 (-50,-35.8,1.15), 9000180 (-51.6,-30.2,1.15), 9000181 (-49.2,-28.4,1.15),
-- 9000178 (-48,-29.2,2.15), 9000179 (-52.4,-34.6,2.15), 9000176 (-50,-32,1.15),
-- 9000107 (-43,-25), 9000108 (-43,-37), 9000109 (-51,-39), 9000110 (-53,-36),
-- 9000111 (-55,-32), 9000112 (-53,-27), 9000113 (-41,-30), 9000114 (-44,-35).
-- Altar on the nave axis at the dais foot.
UPDATE `gameobject` SET `position_x` = -46, `position_y` = -92.5 WHERE `guid` = 9000176;
-- Lanterns beside the altar (z 2.15).
UPDATE `gameobject` SET `position_x` = -43, `position_y` = -93.5 WHERE `guid` = 9000178;
UPDATE `gameobject` SET `position_x` = -49, `position_y` = -93.5 WHERE `guid` = 9000179;
-- Red ritual candles: two at the dais riser, two behind the acolyte arc.
UPDATE `gameobject` SET `position_x` = -38, `position_y` = -94.3 WHERE `guid` = 9000077;
UPDATE `gameobject` SET `position_x` = -54, `position_y` = -94.3 WHERE `guid` = 9000078;
UPDATE `gameobject` SET `position_x` = -40, `position_y` = -86.5 WHERE `guid` = 9000079;
UPDATE `gameobject` SET `position_x` = -52, `position_y` = -86.5 WHERE `guid` = 9000182;
-- Small candles around the dais foot corners.
UPDATE `gameobject` SET `position_x` = -33, `position_y` = -94 WHERE `guid` = 9000107;
UPDATE `gameobject` SET `position_x` = -59, `position_y` = -94 WHERE `guid` = 9000108;
UPDATE `gameobject` SET `position_x` = -30, `position_y` = -91 WHERE `guid` = 9000109;
UPDATE `gameobject` SET `position_x` = -62, `position_y` = -91 WHERE `guid` = 9000110;
UPDATE `gameobject` SET `position_x` = -34, `position_y` = -88 WHERE `guid` = 9000113;
UPDATE `gameobject` SET `position_x` = -58, `position_y` = -88 WHERE `guid` = 9000114;
-- Entrance: brazier + tall candle flank the nave mouth, small candles between.
UPDATE `gameobject` SET `position_x` = -36, `position_y` = -31 WHERE `guid` = 9000180;
UPDATE `gameobject` SET `position_x` = -56, `position_y` = -31 WHERE `guid` = 9000181;
UPDATE `gameobject` SET `position_x` = -44, `position_y` = -30.5 WHERE `guid` = 9000111;
UPDATE `gameobject` SET `position_x` = -48, `position_y` = -30.5 WHERE `guid` = 9000112;

DELETE FROM `game_tele` WHERE `id` IN (9000053, 9000054) OR `name` IN ('wax44_candle', 'wax44_dais');
INSERT INTO `game_tele` (`id`, `position_x`, `position_y`, `position_z`, `orientation`, `map`,
 `name`) VALUES
(9000053, -46, -31, 1.15, 4.7124, 44, 'wax44_candle'),
(9000054, -46, -88, 1.15, 4.7124, 44, 'wax44_dais');

DELETE FROM `creature_text` WHERE `CreatureID` = 9000081;
INSERT INTO `creature_text` (`CreatureID`, `GroupID`, `ID`, `Text`, `Type`, `Language`,
 `Probability`, `Emote`, `Duration`, `Sound`, `BroadcastTextId`, `TextRange`, `comment`) VALUES
(9000081, 0, 0, 'YOU NO TAKE THIS CANDLE. THIS CANDLE TAKE YOU.', 14, 0, 100, 0, 0, 0, 0, 0,
 'Candelabrus aggro'),
(9000081, 1, 0, 'Wax on. You stay.', 14, 0, 100, 0, 1800, 0, 0, 0, 'Candelabrus Wax Seal'),
(9000081, 1, 1, 'Boots stay. You stay with boots.', 14, 0, 100, 0, 1800, 0, 0, 0,
 'Candelabrus Wax Seal'),
(9000081, 1, 2, 'The floor is lava. No -- the floor is WAX.', 14, 0, 100, 0, 1800, 0, 0, 0,
 'Candelabrus Wax Seal'),
(9000081, 2, 0, '%s pours molten wax over the floor -- your boots are stuck!', 16, 0, 100, 0, 0, 0,
 0, 0, 'Candelabrus Wax Seal emote'),
(9000081, 3, 0, 'Make a wish. I dare you.', 14, 0, 50, 0, 0, 0, 0, 0, 'Candelabrus Molten Tallow'),
(9000081, 3, 1, 'Happy birthday. The cake is you.', 14, 0, 50, 0, 0, 0, 0, 0,
 'Candelabrus Molten Tallow'),
(9000081, 9, 0, 'DISCO INFERNO. WAX ON THE FLOOR.', 14, 0, 100, 0, 0, 0, 0, 0,
 'Candelabrus dance'),
(9000081, 4, 0, 'Rise, my little tea-lights!', 14, 0, 100, 0, 0, 0, 0, 0, 'Candelabrus Wicklings'),
(9000081, 5, 0, 'They are trying to SNUFF me. RUDE.', 14, 0, 100, 0, 0, 0, 0, 0,
 'Candelabrus Snuff Out'),
(9000081, 6, 0, 'Blown out.', 14, 0, 50, 0, 0, 0, 0, 0, 'Candelabrus slay'),
(9000081, 6, 1, 'Another drip for the puddle.', 14, 0, 50, 0, 0, 0, 0, 0, 'Candelabrus slay'),
(9000081, 7, 0, 'Snuffed... by AMATEURS.', 14, 0, 100, 0, 0, 0, 0, 0, 'Candelabrus death'),
(9000081, 8, 0, 'You no take candle. Candle take YOU.', 12, 0, 50, 0, 0, 0, 0, 0,
 'Candelabrus idle'),
(9000081, 8, 1, 'Worship harder. The wick is listening.', 12, 0, 50, 0, 0, 0, 0, 0,
 'Candelabrus idle');

DELETE FROM `smart_scripts` WHERE `entryorguid` = 9000081 AND `source_type` = 0;
DELETE FROM `smart_scripts` WHERE `entryorguid` = 900008100 AND `source_type` = 9;
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`,
 `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`,
 `event_param3`, `event_param4`, `event_param5`, `event_param6`, `action_type`,
 `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`,
 `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`,
 `target_param4`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(9000081, 0, 0, 0, 4, 0, 100, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0,
 'Candelabrus - Aggro - Talk 0'),
(9000081, 0, 2, 0, 0, 0, 100, 0, 1000, 2500, 3000, 4000, 0, 0, 11, 20793, 0, 0, 0, 0, 0, 2, 0, 0, 0,
 0, 0, 0, 0, 0, 'Candelabrus - IC - Fireball 20793'),
(9000081, 0, 3, 4, 0, 0, 100, 0, 15000, 18000, 16000, 20000, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0,
 0, 0, 0, 0, 'Candelabrus - IC - Talk Wax Seal'),
(9000081, 0, 4, 0, 61, 0, 100, 0, 0, 0, 0, 0, 0, 0, 11, 745, 0, 0, 0, 0, 0, 5, 0, 1, 0, 0, 0, 0, 0, 0,
 'Candelabrus - Link - Web 745 Wax Seal'),
(9000081, 0, 5, 0, 52, 0, 100, 0, 1, 9000081, 0, 0, 0, 0, 1, 2, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0,
 0, 'Candelabrus - Text Over 1 - Talk Wax Seal emote'),
(9000081, 0, 6, 7, 0, 0, 100, 0, 8000, 10000, 20000, 25000, 0, 0, 1, 3, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0,
 0, 0, 0, 0, 'Candelabrus - IC - Talk Molten Tallow'),
(9000081, 0, 7, 21, 61, 0, 100, 0, 0, 0, 0, 0, 0, 0, 11, 11969, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0,
 0, 'Candelabrus - Link - Fire Nova 11969'),
(9000081, 0, 21, 22, 61, 0, 100, 0, 0, 0, 0, 0, 0, 0, 1, 9, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0,
 'Candelabrus - Link - Talk disco'),
(9000081, 0, 22, 24, 61, 0, 100, 0, 0, 0, 0, 0, 0, 0, 17, 10, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0,
 'Candelabrus - Link - Emote STATE_DANCE 10'),
(9000081, 0, 24, 25, 61, 0, 100, 0, 0, 0, 0, 0, 0, 0, 8, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0,
 'Candelabrus - Link - React passive (dance)'),
(9000081, 0, 25, 26, 61, 0, 100, 0, 0, 0, 0, 0, 0, 0, 224, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0,
 'Candelabrus - Link - Attack stop'),
(9000081, 0, 26, 0, 61, 0, 100, 0, 0, 0, 0, 0, 0, 0, 80, 900008100, 2, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0,
 0, 0, 'Candelabrus - Link - Dance timed list'),
(900008100, 9, 0, 1, 0, 0, 100, 0, 3800, 3800, 0, 0, 0, 0, 17, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0,
 0, 'Candelabrus dance - Clear emote'),
(900008100, 9, 1, 0, 61, 0, 100, 0, 0, 0, 0, 0, 0, 0, 8, 2, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0,
 'Candelabrus dance - React aggressive'),
(9000081, 0, 8, 9, 2, 0, 100, 1, 0, 66, 0, 0, 0, 0, 1, 4, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0,
 'Candelabrus - HP 66% - Talk Wicklings'),
(9000081, 0, 9, 10, 61, 0, 100, 0, 0, 0, 0, 0, 0, 0, 12, 9000082, 2, 60000, 1, 0, 0, 8, 0, 0, 0, 0,
 -40, -102, 3.0, 0, 'Candelabrus - Link - Summon Wickling E'),
(9000081, 0, 10, 11, 61, 0, 100, 0, 0, 0, 0, 0, 0, 0, 12, 9000082, 2, 60000, 1, 0, 0, 8, 0, 0, 0, 0,
 -52, -102, 3.0, 0, 'Candelabrus - Link - Summon Wickling W'),
(9000081, 0, 11, 0, 61, 0, 100, 0, 0, 0, 0, 0, 0, 0, 12, 9000082, 2, 60000, 1, 0, 0, 8, 0, 0, 0, 0,
 -46, -101, 3.0, 0, 'Candelabrus - Link - Summon Wickling N'),
(9000081, 0, 12, 13, 2, 0, 100, 1, 0, 33, 0, 0, 0, 0, 1, 4, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0,
 'Candelabrus - HP 33% - Talk Wicklings'),
(9000081, 0, 13, 14, 61, 0, 100, 0, 0, 0, 0, 0, 0, 0, 12, 9000082, 2, 60000, 1, 0, 0, 8, 0, 0, 0, 0,
 -40, -109, 3.0, 0, 'Candelabrus - Link - Summon Wickling SE'),
(9000081, 0, 14, 15, 61, 0, 100, 0, 0, 0, 0, 0, 0, 0, 12, 9000082, 2, 60000, 1, 0, 0, 8, 0, 0, 0, 0,
 -52, -109, 3.0, 0, 'Candelabrus - Link - Summon Wickling SW'),
(9000081, 0, 15, 0, 61, 0, 100, 0, 0, 0, 0, 0, 0, 0, 12, 9000082, 2, 60000, 1, 0, 0, 8, 0, 0, 0, 0,
 -37, -106, 3.0, 0, 'Candelabrus - Link - Summon Wickling NW'),
(9000081, 0, 16, 17, 2, 0, 100, 1, 0, 20, 0, 0, 0, 0, 1, 5, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0,
 'Candelabrus - HP 20% - Talk Snuff Out'),
(9000081, 0, 17, 27, 61, 0, 100, 0, 0, 0, 0, 0, 0, 0, 11, 8599, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0,
 0, 'Candelabrus - Link - Enrage 8599'),
(9000081, 0, 27, 0, 61, 0, 100, 0, 0, 0, 0, 0, 0, 0, 5, 18, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0,
 'Candelabrus - Link - Play emote CRY 18 (snuff)'),
(9000081, 0, 18, 0, 5, 0, 100, 0, 10000, 20000, 1, 0, 0, 0, 1, 6, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0,
 0, 0, 'Candelabrus - Kill Player - Talk 6'),
(9000081, 0, 19, 23, 6, 0, 100, 0, 0, 0, 0, 0, 0, 0, 1, 7, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0,
 'Candelabrus - Death - Talk 7'),
(9000081, 0, 20, 0, 1, 0, 75, 0, 45000, 70000, 45000, 90000, 0, 0, 1, 8, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0,
 0, 0, 0, 0, 'Candelabrus - OOC - Talk idle'),
(9000081, 0, 23, 0, 61, 0, 100, 0, 0, 0, 0, 0, 0, 0, 41, 0, 0, 0, 0, 0, 0, 9, 9000082, 0, 60, 0, 0, 0,
 0, 0, 'Candelabrus - Death link - Despawn Wicklings');

DELETE FROM `creature_loot_template` WHERE `Entry` IN (9000081, 9000082);
INSERT INTO `creature_loot_template` (`Entry`, `Item`, `Reference`, `Chance`, `QuestRequired`,
 `LootMode`, `GroupId`, `MinCount`, `MaxCount`, `Comment`) VALUES
(9000081, 9000054, 0, 100, 0, 1, 0, 2, 3, 'Candelabrus - Lump of Tallow'),
(9000081, 9000055, 0, 60, 0, 1, 0, 1, 2, 'Candelabrus - Stolen Taper'),
(9000081, 772, 0, 40, 0, 1, 0, 1, 2, 'Candelabrus - Large Candle'),
(9000081, 9000061, 0, 22, 0, 1, 1, 1, 1, 'Candelabrus - Wick-Snuffer Cowl'),
(9000081, 9000050, 0, 14, 0, 1, 1, 1, 1, 'Candelabrus - Undercroft Leggings'),
(9000081, 9000051, 0, 14, 0, 1, 1, 1, 1, 'Candelabrus - Undercroft Tunic'),
(9000081, 9000052, 0, 14, 0, 1, 1, 1, 1, 'Candelabrus - Undercroft Stick'),
(9000081, 9000063, 0, 14, 0, 1, 1, 1, 1, 'Candelabrus - Dipper Mallet'),
(9000082, 9000054, 0, 40, 0, 1, 0, 1, 1, 'Wickling - Lump of Tallow'),
(9000082, 2589, 0, 25, 0, 1, 0, 1, 1, 'Wickling - Linen Cloth'),
(9000082, 0, 9000101, 5, 0, 1, 0, 1, 1, 'Wickling - Waxworks green');
