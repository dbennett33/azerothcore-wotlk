# Model chain: template → display → model data → files

Back to [`README.md`](README.md). Verified against `src/server/game/Globals/ObjectMgr.cpp`
(`LoadCreatureTemplateModels`, `LoadCreatureModelInfo`), `DataStores/DBCStores.cpp`,
`shared/DataStores/DBCStructure.h`, `Entities/Unit/Unit.cpp`, and the overlay table schemas in
`data/sql/base/db_world/*_dbc.sql`.

## The chain

| Step | Table / file | Key columns for us | Who reads it |
|---|---|---|---|
| 1 | `creature_template` (world DB) | `entry`, `name`, `subname`, level/faction/stats, `unit_class`, `type`, `family`, `HoverHeight`, `AIName`/`ScriptName`, `flags_extra`, `movementId` | server; client caches name/subname/type via query (WDB) |
| 2 | `creature_template_model` | `CreatureID`, `Idx` (0–3), `CreatureDisplayID`, `DisplayScale`, `Probability` | server picks one at spawn |
| 3 | `creature_model_info` | `DisplayID`, `BoundingRadius`, `CombatReach`, `Gender`, `DisplayID_Other_Gender` | server (melee range, gender for texts) |
| 4 | `CreatureDisplayInfo.dbc` | `ID`, `ModelID`, `SoundID`, `ExtendedDisplayInfoID`, `CreatureModelScale`, `CreatureModelAlpha`, `TextureVariation_1..3`, `BloodID`, `NPCSoundID`, `ParticleColorID`, `CreatureGeosetData` | client renders; server checks id, uses `ModelID`, `scale`, `ExtendedDisplayInfoID` |
| 5 | `CreatureModelData.dbc` | `ID`, `Flags`, `ModelName`, `ModelScale`, `CollisionWidth`, `CollisionHeight`, `MountHeight`, `GeoBox*`, `SoundID`, `BloodID`, `FoleyMaterialID` | client loads the M2; server uses scale + collision |
| 6 | `CreatureDisplayInfoExtra.dbc` (humanoids) | `ID`, `DisplayRaceID`, `DisplaySexID`, skin/face/hair ids, `NPCItemDisplay1..11`, `Flags`, `BakeName` | client composes body; server reads race |
| 7 | MPQ files | `Creature\<Dir>\<Name>.m2`, `<Name>00.skin`…`03.skin`, `*.blp`; `Textures\BakedNpcTextures\*.blp` | client only |

Blizzard rows write `ModelName` with the old `.mdx` extension (`Creature\Kobold\Kobold.mdx`); the
client maps it to `.m2`. Copy that convention.

## Server-side validation you will hit

- `creature_template_model.CreatureDisplayID` not in `sCreatureDisplayInfoStore` → the model row is
  **dropped** with `Creature (Entry: N) lists non-existing CreatureDisplayID id (X), this can crash
  the client.` The creature then spawns with whatever other model rows survive, or none.
- No `creature_model_info` row → `No model data exist for CreatureDisplayID = X` and defaults
  (`CombatReach` 1.5, radius default). Add the row.
- `creature_model_info.DisplayID_Other_Gender` must also exist as a display id.
- `Unit::GetCollisionWidth/Height` call `sCreatureModelDataStore.AssertEntry(displayInfo->ModelId)`:
  a display row whose `ModelID` has no server-side `CreatureModelData` entry **asserts the
  worldserver** the first time the unit's collision is asked for. Always ship the CMD overlay row
  with the CDI overlay row.
- `creature_addon.mount` / `creature_template_addon.mount` are validated against the display store
  as well.
- `Emotes.dbc`, `SoundEntries.dbc` lookups protect `creature_text` (see
  [`phrases-and-triggers.md`](phrases-and-triggers.md), [`sounds.md`](sounds.md)).

## Server copy of the DBC rows: overlay SQL (preferred) or `data/dbc`

`LOAD_DBC(store, "X.dbc", "x_dbc")` reads the file and then `SELECT * FROM x_dbc`; a SQL row with a
new id **adds** a record, an existing id **replaces** it. Column order and count must match
`DBCfmt.h`; the base tables in `data/sql/base/db_world/` are the reference. Overlay tables that
matter here (all exist in this repo):

| Overlay table | Columns (in order) |
|---|---|
| `creaturedisplayinfo_dbc` | `ID, ModelID, SoundID, ExtendedDisplayInfoID, CreatureModelScale, CreatureModelAlpha, TextureVariation_1, TextureVariation_2, TextureVariation_3, PortraitTextureName, BloodLevel, BloodID, NPCSoundID, ParticleColorID, CreatureGeosetData, ObjectEffectPackageID` |
| `creaturemodeldata_dbc` | `ID, Flags, ModelName, SizeClass, ModelScale, BloodID, FootprintTextureID, FootprintTextureLength, FootprintTextureWidth, FootprintParticleScale, FoleyMaterialID, FootstepShakeSize, DeathThudShakeSize, SoundID, CollisionWidth, CollisionHeight, MountHeight, GeoBoxMinX, GeoBoxMinY, GeoBoxMinZ, GeoBoxMaxX, GeoBoxMaxY, GeoBoxMaxZ, WorldEffectScale, AttachedEffectScale, MissileCollisionRadius, MissileCollisionPush, MissileCollisionRaise` |
| `creaturedisplayinfoextra_dbc` | `ID, DisplayRaceID, DisplaySexID, SkinID, FaceID, HairStyleID, HairColorID, FacialHairID, NPCItemDisplay1..11, Flags, BakeName` |
| `soundentries_dbc` | `ID, SoundType, Name, File_1..10, Freq_1..10, DirectoryBase, Volumefloat, Flags, MinDistance, DistanceCutoff, EAXDef, SoundEntriesAdvancedID` |
| `emotes_dbc` | only if you add emotes; normally not needed |

The server only *uses* a handful of columns (see `DBCStructure.h`: CDI `ModelId`,
`ExtendedDisplayInfoID`, `scale`; CMD `Flags`, `Scale`, `CollisionWidth/Height`, `MountHeight`;
SoundEntries `Id`), but every column must be present because the loader maps by format string.
Copy the whole row you wrote into the client DBC — same bytes both sides, same as talents.

`CreatureSoundData.dbc` and `NPCSounds.dbc` are **not** loaded by the server; they are client-only.

## Writing the client DBC rows

Tooling on the Windows box: WDBX Editor (`C:/dev/tools/wdbxeditor/`). Open the enUS
`CreatureDisplayInfo.dbc` extracted from the client (`map_extractor -e 2` output or the loose file
pulled from `lichking-locale-enUS.MPQ` with MPQEditor), copy a similar Blizzard row, change id and
fields, save, stage at `client-patches/sources/client/loose/DBFilesClient/CreatureDisplayInfo.dbc`,
pack into `patch-enUS-4.MPQ`. Same for `CreatureModelData.dbc`, `CreatureDisplayInfoExtra.dbc`,
`SoundEntries.dbc`, `CreatureSoundData.dbc`, `NPCSounds.dbc` as needed. DBCs live **only** in the
locale archive; a DBC in `patch-4` is invisible to the client and to `map_extractor`.

Good donor rows: a creature of the same size class and skeleton (kobold → kobold, human → any
`Character\Human` NPC). Keep `SizeClass`, `BloodID`, `FoleyMaterialID`, footstep fields from the
donor; change `ID`, `ModelID`, textures, sounds.

## Collision and reach: which number does what

| Value | Where | Effect |
|---|---|---|
| `creature_template_model.DisplayScale` × `CreatureDisplayInfo.CreatureModelScale` × `CreatureModelData.ModelScale` | client render and server collision maths | Visual size |
| `CreatureModelData.CollisionWidth/Height` | `Unit::GetCollisionWidth/Height` | Hitbox sent to the client (`UNIT_FIELD_BOUNDINGRADIUS`, combat reach checks), floor probing on mounts |
| `creature_model_info.BoundingRadius`, `CombatReach` | `Creature::SetDisplayId` | Melee range, "too far away" — the values players feel |
| `creature_template.HoverHeight` | server | Float offset for hover-flag creatures |
| `GeoBox*` | client | Selection/culling box; copy donor and scale |

When you scale a donor mesh in Blender, scale `CollisionHeight/Width`, `GeoBox` and
`creature_model_info` by the same factor. A 2× kobold with 1× reach cannot be hit by melee from
where the player expects.

## `creature_template` fields that change the read of a model

`unit_class` (1 warrior, 2 paladin, 4 rogue, 8 mage: base stats/power), `type` (7 humanoid, 1 beast,
3 demon, 6 undead, 9 mechanical, 10 not specified for triggers), `family` (pets/beast tracking),
`rank` (0 normal, 1 elite, 3 boss, 4 rare), `speed_walk/run`, `BaseAttackTime`, `movementId`
(`CreatureMovementInfo.dbc`: ground/swim/fly behaviour), `flags_extra` (`0x80` trigger no threat,
`0x20000000` ignore pathfinding on WMO-only maps), `IconName` (`Speak`, `Buy`, `Taxi` cursor).
The fork's SQL column list for new creatures is in the Belfry update
(`rev_1788521934180453083.sql` on `Playerbot`); copy its `INSERT` header.
