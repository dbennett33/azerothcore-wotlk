# Worked example: the Tallow Warden

Back to [`README.md`](README.md). A Waxworks trash-boss built with path **B + D**
([`appearance-paths.md`](appearance-paths.md)): a kobold M2 with a new wax-drenched skin, a
hidden candle geoset, its own voice set, six phrase groups, and a 20 % line with audio. Every id
below is a **placeholder in the fork's blocks** — check the registries (`README.md`, dungeons.md)
before reusing them. `<donor …>` values come from the Blizzard rows you copy.

## 1. Brief and phrase sheet

Tallow Warden: kobold, 1.15× scale, faction 14, level 12 elite, guards the Wickworks vat. Voice:
gravelly kobold, wet. Phrases:

| Group | Trigger | Line | Type | Emote | Sound |
|---|---|---|---|---|---|
| 0 | aggro | "You no take *tallow*!" | 14 | 15 | 90020 |
| 1 | HP 50 %, once | "Vat is boiling! Vat is *mine*!" | 14 | 25 | 90021 |
| 2 | HP 20 %, once, whole map | "Wick… burning… low…" | 14 | 5 | 90022 |
| 3 | player kill, 15 s cd | "Dip you next." / "More candle for Warden." | 12 | 0 | 90023 |
| 4 | death | "…dark…" | 12 | 0 | 90024 |
| 5 | OOC every 60–120 s | "Stir. Stir. Never stop stir." ×3 variants | 12 | 1 | 0 |

## 2. Ids

| Thing | Id |
|---|---|
| `creature_template.entry` | `9000080` (Waxworks block, unused sub-range) |
| `CreatureDisplayInfo` | `60020` |
| `CreatureModelData` | `<donor kobold ModelID>` (unchanged: same M2) |
| `CreatureSoundData` | `60020` |
| `SoundEntries` | `90020–90024` |

Find the donor: `.npc info` on a Kobold Vermin (entry `6`) prints its DisplayID; open the client's
`CreatureDisplayInfo.dbc` in WDBX, read that row's `ModelID`, `SoundID`, `TextureVariation_1`,
`BloodID`; note the M2 folder from `CreatureModelData.ModelName` (`Creature\Kobold\…`).

## 3. Texture

Extract the donor skin BLP (`Creature\Kobold\<TextureVariation_1>.blp`) → PNG; paint the tallow
version (pale yellow drips over the fur, darker wet fur underneath, orange wick glow on the
candle) at 512², downsample to the donor's size, export **DXT1** with mips as
`client-patches/sources/client/loose/Creature/Kobold/KoboldTallow.blp`. Rules: [`textures-blp.md`](textures-blp.md).

## 4. Client DBC rows (`DBFilesClient/` → `patch-enUS-4.MPQ`)

`CreatureDisplayInfo.dbc`, copy the donor row and change:

| Column | Value |
|---|---|
| `ID` | `60020` |
| `ModelID` | donor |
| `SoundID` | `60020` (our `CreatureSoundData`) |
| `ExtendedDisplayInfoID` | `0` |
| `CreatureModelScale` | `1.15` |
| `CreatureModelAlpha` | `255` |
| `TextureVariation_1` | `KoboldTallow` |
| `TextureVariation_2/3`, `PortraitTextureName` | donor / empty |
| `BloodID`, `ParticleColorID`, `ObjectEffectPackageID` | donor |
| `CreatureGeosetData` | donor with the candle group nibble changed (check in WMV which nibble hides the candle) |
| `NPCSoundID` | `0` (no gossip) |

`SoundEntries.dbc`, five rows (`SoundType 10`, `DirectoryBase 'Sound\Creature\TallowWarden\'`,
`Volumefloat 1`, `MinDistance 8`, `DistanceCutoff 45`, flags from a donor voice row):

| ID | Name | Files |
|---|---|---|
| 90020 | TallowWarden Aggro | `TallowWarden_Aggro01.wav`, `TallowWarden_Aggro02.wav` |
| 90021 | TallowWarden Vat | `TallowWarden_Vat01.wav` |
| 90022 | TallowWarden Low | `TallowWarden_Low01.wav` |
| 90023 | TallowWarden Slay | `TallowWarden_Slay01.wav`, `TallowWarden_Slay02.wav` |
| 90024 | TallowWarden Death | `TallowWarden_Death01.wav` |

`CreatureSoundData.dbc` row `60020`: copy the donor kobold row (keeps footsteps, wound grunts,
exertion), set `SoundAggroID = 90020`, `SoundDeathID = 90024`. Client-only; no server row.

Audio files staged at `loose/Sound/Creature/TallowWarden/*.wav` (mono 22 050 Hz 16-bit).

## 5. Server SQL (`pending_db_world`, one file)

```sql
-- DBC overlays: same values as the client rows
DELETE FROM `creaturedisplayinfo_dbc` WHERE `ID` = 60020;
INSERT INTO `creaturedisplayinfo_dbc` (`ID`, `ModelID`, `SoundID`, `ExtendedDisplayInfoID`, `CreatureModelScale`,
 `CreatureModelAlpha`, `TextureVariation_1`, `TextureVariation_2`, `TextureVariation_3`, `PortraitTextureName`,
 `BloodLevel`, `BloodID`, `NPCSoundID`, `ParticleColorID`, `CreatureGeosetData`, `ObjectEffectPackageID`) VALUES
(60020, <donorModelId>, 60020, 0, 1.15, 255, 'KoboldTallow', '', '', '', 0, <donorBloodId>, 0, 0, <geosetData>, 0);

-- Only needed when the ModelID is new; the kobold ModelID already exists in data/dbc.
-- DELETE FROM `creaturemodeldata_dbc` WHERE `ID` = 60020; INSERT INTO `creaturemodeldata_dbc` (...) VALUES (...);

DELETE FROM `soundentries_dbc` WHERE `ID` BETWEEN 90020 AND 90024;
INSERT INTO `soundentries_dbc` (`ID`, `SoundType`, `Name`, `File_1`, `File_2`, `File_3`, `File_4`, `File_5`,
 `File_6`, `File_7`, `File_8`, `File_9`, `File_10`, `Freq_1`, `Freq_2`, `Freq_3`, `Freq_4`, `Freq_5`, `Freq_6`,
 `Freq_7`, `Freq_8`, `Freq_9`, `Freq_10`, `DirectoryBase`, `Volumefloat`, `Flags`, `MinDistance`,
 `DistanceCutoff`, `EAXDef`, `SoundEntriesAdvancedID`) VALUES
(90020, 10, 'TallowWarden Aggro', 'TallowWarden_Aggro01.wav', 'TallowWarden_Aggro02.wav', '', '', '', '', '', '', '', '',
 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Sound\\Creature\\TallowWarden\\', 1, 0, 8, 45, 0, 0),
(90021, 10, 'TallowWarden Vat',   'TallowWarden_Vat01.wav',   '', '', '', '', '', '', '', '', '',
 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'Sound\\Creature\\TallowWarden\\', 1, 0, 8, 45, 0, 0),
(90022, 10, 'TallowWarden Low',   'TallowWarden_Low01.wav',   '', '', '', '', '', '', '', '', '',
 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'Sound\\Creature\\TallowWarden\\', 1, 0, 15, 100, 0, 0),
(90023, 10, 'TallowWarden Slay',  'TallowWarden_Slay01.wav',  'TallowWarden_Slay02.wav', '', '', '', '', '', '', '', '',
 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Sound\\Creature\\TallowWarden\\', 1, 0, 8, 45, 0, 0),
(90024, 10, 'TallowWarden Death', 'TallowWarden_Death01.wav', '', '', '', '', '', '', '', '', '',
 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'Sound\\Creature\\TallowWarden\\', 1, 0, 8, 45, 0, 0);

-- Creature
DELETE FROM `creature_template` WHERE `entry` = 9000080;
INSERT INTO `creature_template` (`entry`, `name`, `subname`, `minlevel`, `maxlevel`, `faction`,
 `npcflag`, `gossip_menu_id`, `speed_walk`, `speed_run`, `detection_range`, `rank`,
 `DamageModifier`, `BaseAttackTime`, `RangeAttackTime`, `unit_class`, `unit_flags`,
 `unit_flags2`, `type`, `lootid`, `mingold`, `maxgold`, `AIName`, `HealthModifier`, `ManaModifier`,
 `RegenHealth`, `flags_extra`, `ScriptName`, `VerifiedBuild`) VALUES
(9000080, 'Tallow Warden', 'Keeper of the Vat', 12, 12, 14, 0, 0, 1, 1.14286, 14, 1, 1.6, 2000, 2000, 1, 0, 2048, 7,
 9000080, 60, 120, 'SmartAI', 3.0, 1, 1, 0, '', 0);

DELETE FROM `creature_template_model` WHERE `CreatureID` = 9000080;
INSERT INTO `creature_template_model` (`CreatureID`, `Idx`, `CreatureDisplayID`, `DisplayScale`, `Probability`, `VerifiedBuild`) VALUES
(9000080, 0, 60020, 1, 1, 0);

DELETE FROM `creature_model_info` WHERE `DisplayID` = 60020;
INSERT INTO `creature_model_info` (`DisplayID`, `BoundingRadius`, `CombatReach`, `Gender`, `DisplayID_Other_Gender`, `VerifiedBuild`) VALUES
(60020, <donorRadius*1.15>, <donorReach*1.15>, 0, 0, 0);

DELETE FROM `creature_equip_template` WHERE `CreatureID` = 9000080;
INSERT INTO `creature_equip_template` (`CreatureID`, `ID`, `ItemID1`, `ItemID2`, `ItemID3`, `VerifiedBuild`) VALUES
(9000080, 1, 2176, 0, 0, 0);  -- a torch / ladle-looking 1H

-- Phrases
DELETE FROM `creature_text` WHERE `CreatureID` = 9000080;
INSERT INTO `creature_text` (`CreatureID`, `GroupID`, `ID`, `Text`, `Type`, `Language`,
 `Probability`, `Emote`, `Duration`, `Sound`, `BroadcastTextId`, `TextRange`, `comment`) VALUES
(9000080, 0, 0, 'You no take tallow!',                14, 0, 100, 15, 0, 90020, 0, 0, 'Warden aggro'),
(9000080, 1, 0, 'Vat is boiling! Vat is mine!',       14, 0, 100, 25, 0, 90021, 0, 0, 'Warden 50%'),
(9000080, 2, 0, 'Wick... burning... low...',          14, 0, 100,  5, 0, 90022, 0, 3, 'Warden 20% (map)'),
(9000080, 3, 0, 'Dip you next.',                      12, 0,  50,  0, 0, 90023, 0, 0, 'Warden slay'),
(9000080, 3, 1, 'More candle for Warden.',            12, 0,  50,  0, 0, 90023, 0, 0, 'Warden slay'),
(9000080, 4, 0, '...dark...',                         12, 0, 100,  0, 0, 90024, 0, 0, 'Warden death'),
(9000080, 5, 0, 'Stir. Stir. Never stop stir.',       12, 0,  34,  1, 0,     0, 0, 0, 'Warden idle'),
(9000080, 5, 1, 'Wax not hot enough. Never enough.',  12, 0,  33,  1, 0,     0, 0, 0, 'Warden idle'),
(9000080, 5, 2, 'Foreman say stir. Warden stir.',     12, 0,  33,  1, 0,     0, 0, 0, 'Warden idle');

-- Triggers
DELETE FROM `smart_scripts` WHERE `entryorguid` = 9000080 AND `source_type` = 0;
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`,
 `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`,
 `event_param3`, `event_param4`, `event_param5`, `event_param6`, `action_type`,
 `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`,
 `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`,
 `target_param4`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(9000080, 0, 0, 0,  4, 0, 100, 0,     0,      0,     0,      0, 0, 0,  1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Warden - Aggro - Talk 0'),
(9000080, 0, 1, 2,  2, 0, 100, 1,     0,     50,     0,      0, 0, 0,  1, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Warden - 50% - Talk 1'),
(9000080, 0, 2, 0, 61, 0, 100, 0,     0,      0,     0,      0, 0, 0, 12, 9000003, 2, 30000, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Warden - 50% link - Summon Wickmage'),
(9000080, 0, 3, 4,  2, 0, 100, 1,     0,     20,     0,      0, 0, 0,  1, 2, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Warden - 20% - Talk 2'),
(9000080, 0, 4, 0, 61, 0, 100, 0,     0,      0,     0,      0, 0, 0, 11, 8599, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Warden - 20% link - Enrage'),
(9000080, 0, 5, 0,  5, 0, 100, 0, 15000,  15000,     1,      0, 0, 0,  1, 3, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Warden - Kill player - Talk 3'),
(9000080, 0, 6, 0,  6, 0, 100, 0,     0,      0,     0,      0, 0, 0,  1, 4, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Warden - Death - Talk 4'),
(9000080, 0, 7, 0,  1, 0,  75, 0, 30000,  60000, 60000, 120000, 0, 0,  1, 5, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Warden - OOC - Talk 5'),
(9000080, 0, 8, 0,  0, 0, 100, 0,  5000,   8000, 12000,  16000, 0, 0, 11, 11969, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Warden - IC - Fire Nova');
```

Backslashes in `DirectoryBase` are doubled because MySQL string literals escape `\`; the stored
value is `Sound\Creature\TallowWarden\`. Summon type `2` = timed-or-corpse despawn.

Loot (`creature_loot_template` for `9000080`, gold set above) follows
`.agents/skills/build-dungeon/reference-content.md`. Spawn row in `creature` with the Waxworks
map/phase and a `9000xxx` guid from the block.

## 6. Pack, test, ship

1. Rebuild `patch-4.MPQ` with the `Creature\` and `Sound\` roots added, and `patch-enUS-4.MPQ` with
   the three DBCs ([`ship-and-verify.md`](ship-and-verify.md)). Install in the dev client, restart Wow.
2. Apply the SQL locally; restart worldserver; log must be silent for `9000080` / `60020` / `9002x`.
3. `.morph 60020` → you are a pale kobold with no candle. `.npc add 9000080` → it idles and talks
   every minute or two. Pull: yell + voice. `.damage` to 50 %: line + Wickmage add. 20 %: line heard
   across the instance + enrage. Die to it once (`.die` on yourself is not a kill; use a bot):
   slay line. Kill it: death line + death grunt.
4. `build-bundle.ps1 1.2.0 -Changelog 'Tallow Warden: new kobold skin, voice set'`, publish,
   commit `manifest.json` with the SQL, push `dev`.
5. Registry: add `60020` / `90020–90024` to `README.md`, `9000080` to the Waxworks row in
   `.agents/docs/systems/dungeons.md`.

## What to change for the other paths

- **New person (C)**: `ModelID` = a `Character\<Race>\<Sex>\…` model's `CreatureModelData` id
  (copy from any humanoid NPC), `ExtendedDisplayInfoID = 60020`, a `CreatureDisplayInfoExtra` row
  `60020` with race/sex/face/hair/`NPCItemDisplay*` and a non-empty `BakeName`; overlay row in
  `creaturedisplayinfoextra_dbc`; `TextureVariation` empty.
- **New shape (E)**: a `CreatureModelData` row `60020` (`ModelName 'Creature\TallowWarden\TallowWarden.mdx'`,
  collision from the donor × scale) on **both** sides, the M2 + four skins + BLPs under
  `loose/Creature/TallowWarden/`, CDI `ModelID = 60020`, and a `CreatureSoundData` row that still
  reuses the donor's footstep/wound ids.
- **C++ boss instead of SmartAI**: `AIName ''`, `ScriptName 'boss_tallow_warden'`, `SAY_WARDEN_*`
  enum = the `GroupID`s above, health thresholds via `ScheduleHealthCheckEvent` or the
  `DamageTaken` flag pattern ([`phrases-and-triggers.md`](phrases-and-triggers.md)); the
  `creature_text` and `soundentries_dbc` rows stay identical.
