# Dungeon #3+: a new `Map.dbc` id

Read [SKILL.md](SKILL.md), [reference-mesh.md](reference-mesh.md), and
[reference-blender-wmo.md](reference-blender-wmo.md) (art path) first. This file adds the
steps The Waxworks and Stormwind Vault **skipped** because they reused leftover maps (44 and 35).
Do not hunt leftover Blizzard instance ids. Every later dungeon follows this path. Data contract:
`.agents/docs/systems/client-data.md`. Shipping: `.agents/skills/build-client-patch/SKILL.md`.
Policy: `.agents/docs/systems/dungeons.md` § Map ids.

## Decide the ids first

| Thing | Rule | Example (dungeon #3) |
|---|---|---|
| Map id | 3-digit, unused in `Map.dbc` (Blizzard max is 724). Keep `< 1000` so `{:03}` file names stay 3 digits. | `900` |
| `Directory` | New, unique, ASCII, no spaces. Becomes `World/Maps/<Dir>/<Dir>.wdt` and the extractor's folder name. | `Tannery` |
| `AreaTable` zone id | Unused (Blizzard max ~4400). One zone row; optional sub-areas. `AreaBit` unused and `< 4096`. | `9000` / bit `3990` |
| `MapDifficulty` id | Unused; this fork uses `90000MM`. | `9000900` |
| World DB block | Next block in `systems/dungeons.md` registry. | `9000400–9000599` |
| `dungeon_access_template.id` | Next after 123. | `124` |

Write them into `<dungeon>.h` as the enum (source of truth) before any SQL or DBC edit.

## Client side (locale MPQ + base MPQ)

1. **`Map.dbc`** (goes to `Data/enUS/patch-enUS-4.MPQ`): copy Ragefire's row (389) and set
   `ID`, `Directory`, `InstanceType = 1`, `Flags = 0`, `PVP = 0`, `MapName_Lang_enUS`,
   `MapName_Lang_Mask = 16712190`, `AreaTableID = <zone>`, `LoadingScreenID` (reuse a vanilla
   dungeon screen id or add `LoadingScreens.dbc` + BLP), `MinimapIconScale = 1`,
   `CorpseMapID = 0`, `CorpseX/Y` = the entrance plaza (ghost run target), `TimeOfDayOverride = -1`,
   `ExpansionID = 0`, `RaidOffset = 0`, `MaxPlayers = 5`.
2. **`MapDifficulty.dbc`**: `ID`, `MapID`, `Difficulty = 0`, empty message, mask `16712190`,
   `RaidDuration = 0`, `MaxPlayers = 5`, `Difficultystring = ''`. Without it the client cannot pick
   a difficulty and the server aborts with `TRANSFER_ABORT_DIFFICULTY` for non-GMs.
3. **`AreaTable.dbc`**: copy a vanilla 5-man zone (Ragefire `2437`), set `ID`, `ContinentID =
   <map>`, `ParentAreaID = 0`, `AreaBit`, `Flags` as copied, `ExplorationLevel`, name. Optional
   `WMOAreaTable.dbc` rows give room names from `(rootId, groupId)` of your WMO.
4. Optional and skippable for a first ship: `WorldMapArea`/`DungeonMap` (map UI), `LFGDungeons`
   (RDF — also needs `lfgdungeons_dbc` and LFG rewards), `Achievement*`.
5. **World files** (go to `Data/patch-4.MPQ`): `World/Maps/<Dir>/<Dir>.wdt` (WMO-only: MPHD flag
   `0x1`, `MWMO` = your root WMO path, one `MODF` with a padded AABB, empty `MAIN`), the WMO root +
   groups, textures, M2s not already in Blizzard archives. Rules for MODF-at-origin WMO-only maps
   (negated XY, `liquid_type 15`, AABB padding, capsule Z) are in reference-mesh.md.

Rebuild both archives whole; the Waxworks files stay in them.

## Server side

`pending_db_world` (one file, DELETE+INSERT per block, ids from the registry):

```sql
-- Map.dbc mirror. Column list = data/sql/base/db_world/map_dbc.sql. Strings not shown stay NULL.
DELETE FROM `map_dbc` WHERE `ID` = 900;
INSERT INTO `map_dbc` (`ID`, `Directory`, `InstanceType`, `Flags`, `PVP`, `MapName_Lang_enUS`,
  `MapName_Lang_Mask`, `AreaTableID`, `LoadingScreenID`, `MinimapIconScale`, `CorpseMapID`,
  `CorpseX`, `CorpseY`, `TimeOfDayOverride`, `ExpansionID`, `RaidOffset`, `MaxPlayers`) VALUES
(900, 'Tannery', 1, 0, 0, 'The Tannery', 16712190, 9000, <LoadingScreens.dbc id>, 1, 0, -9432, 62, -1, 0, 0, 5);

DELETE FROM `mapdifficulty_dbc` WHERE `ID` = 9000900;
INSERT INTO `mapdifficulty_dbc` (`ID`, `MapID`, `Difficulty`, `Message_Lang_enUS`, `Message_Lang_Mask`,
  `RaidDuration`, `MaxPlayers`, `Difficultystring`) VALUES
(9000900, 900, 0, '', 16712190, 0, 5, '');

DELETE FROM `areatable_dbc` WHERE `ID` = 9000;
INSERT INTO `areatable_dbc` (`ID`, `ContinentID`, `ParentAreaID`, `AreaBit`, `Flags`, `ExplorationLevel`,
  `AreaName_Lang_enUS`, `AreaName_Lang_Mask`, `FactionGroupMask`) VALUES
(9000, 900, 0, 3990, 0, 10, 'The Tannery', 16712190, 0);

DELETE FROM `instance_template` WHERE `map` = 900;
INSERT INTO `instance_template` (`map`, `parent`, `script`, `allowMount`) VALUES
(900, 0, 'instance_tannery', 0);

DELETE FROM `dungeon_access_template` WHERE `id` = 124;
INSERT INTO `dungeon_access_template` (`id`, `map_id`, `difficulty`, `min_level`, `max_level`,
  `min_avg_item_level`, `comment`) VALUES
(124, 900, 0, 12, 0, 0, 'The Tannery');

-- Ghosts: link the new zone to an existing graveyard on the entrance map, or releases fall back to
-- the faction default graveyard with a `graveyard_zone incomplete` error in the log.
DELETE FROM `graveyard_zone` WHERE `GhostZone` = 9000;
INSERT INTO `graveyard_zone` (`ID`, `GhostZone`, `Faction`, `Comment`) VALUES
(<goldshire game_graveyard id>, 9000, 0, 'The Tannery -> Goldshire');
```

The `*_dbc` overlay must agree byte-for-byte in meaning with the client DBC rows; keep the SQL
and the WDBX edit in the same change. Alternatively ship `dbc/Map.dbc` etc. in the server bundle
(`sources/server/dbc/`) — then do **not** also write the overlay row, one source per file.

Data: `vmaps/900.vmtree`, `vmaps/<Wmo>.wmo.vmo`, `mmaps/900*` via the extract pipeline. No
`maps/900*.map` for WMO-only. The extractors only see the map if the `Map.dbc` row is in the
**locale** archive (`vmap4_extractor` reads locale `Map.dbc`).

C++: `EasternKingdoms/<Dungeon>/` with `instance_<name>` (`InstanceMapScript(name, 900)`), bosses,
and either a copy of the existing portal scripts with the new map/positions, or a shared
table-driven portal script (preferred — Waxworks and Vault already each have a portal file;
do not add a third `PlayerScript` that fights them for the same hooks).
Register `AddSC_*` in `eastern_kingdoms_script_loader.cpp`.

## Order of operations (do not reorder)

1. Reserve ids; write the header enum; update the registry table in `systems/dungeons.md`.
2. Mesh: WBS kitbash ([reference-blender-wmo.md](reference-blender-wmo.md)) or the Python hull
   for a first load. WMO + WDT → `patch-4.MPQ`; DBC rows → `patch-enUS-4.MPQ`. Install into the
   dev client, **fully quit** Wow, `.go xyz 0 0 5 900` as GM: client must load the map (black
   screen / disconnect = client-side DBC or WDT missing). Visible room + falling = client hull,
   not spawn Z.
3. Extract with the patched client; confirm `vmaps/900.vmtree` and the `.vmo` exist and `mmaps/900*`
   were generated (map not in the junk list).
4. SQL block above + spawns + templates + scripts; `git commit` with `manifest.json` from the bundle.
5. Publish bundle → push `dev` → test realm. Verify per `build-client-patch` §7, then
   `walk-instance`.

## Failure signatures

| Symptom | Cause |
|---|---|
| `.go` works for GM, client disconnects on load | client `Map.dbc` lacks the row or the WDT path is wrong |
| `CANNOT_ENTER_NO_ENTRY` | server lacks `map_dbc` row / `dbc/Map.dbc` |
| `CANNOT_ENTER_UNINSTANCED_DUNGEON` | no `instance_template` row |
| `TRANSFER_ABORT_DIFFICULTY` (non-GM only) | no `MapDifficulty` for difficulty 0 |
| Vmaps extract prints every map but not 900 | `Map.dbc` row only in `Data/patch-4`, not the locale patch |
| Map loads, ground is water, then fall | leftover liquid / missing `.wmo.vmo` (reference-mesh.md) |
| Release spirit sends players to Stormwind | no `graveyard_zone` for the new zone |
| Room name blank / "Unknown" | no `AreaTable` row or `WMOAreaTable` mapping; harmless |
