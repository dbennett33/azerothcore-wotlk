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
