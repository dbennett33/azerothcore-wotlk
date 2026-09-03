# Custom content: editing the 3.3.5a world and client

This is the human overview of how this fork changes what the WoW 3.3.5a client shows and what the
AzerothCore worldserver enforces: new dungeons, talent trees, overworld terrain, and the MPQ / server
data pipeline that ships them. It answers "can we build another dungeon after The Waxworks?" and
points to the agent-readable procedures that do the work.

Agent entry points (read these when doing the work, they are the source of truth):

| Task | Model doc | Procedure (skill) |
|---|---|---|
| Anything touching MPQs, DBCs, `data/` | `.agents/docs/systems/client-data.md` | `.agents/skills/build-client-patch/` |
| New dungeon / instance | `.agents/docs/systems/dungeons.md` | `.agents/skills/build-dungeon/` (+ `reference-new-map.md` for dungeon #2+) |
| Talent trees | `.agents/docs/systems/talents.md` | `.agents/skills/edit-talents/` |
| Overworld ADT edits | `.agents/docs/systems/terrain.md` | `.agents/skills/edit-terrain/` |
| Coordinates, tiles, teleports | `.agents/docs/systems/coordinates.md` | `.agents/skills/wow-coordinates/` |
| Visual check of an instance | — | `.agents/skills/walk-instance/` |
| Release mechanics (bundle, VPS, CI) | `docs/client-patches.md` | `client-patches/README.md` |

## 1. The one idea everything rests on

WoW 3.3.5a is two programs reading two copies of the same data.

- The **client** reads MPQ archives from `Data/` and `Data/enUS/`. It renders geometry from
  `World\...` files, and validates UI-level rules (which talents exist, which maps exist, zone
  names) from `DBFilesClient\*.dbc`.
- The **worldserver** never opens an MPQ. It reads `data/dbc`, `data/maps`, `data/vmaps`,
  `data/mmaps`, all produced by the extractors in `src/tools/` **from a client that already has the
  custom MPQs installed**, plus the world database, which can override DBC rows through the `*_dbc`
  tables.

So every change falls into one of three buckets:

| Bucket | Examples | Ships as |
|---|---|---|
| Server only | creatures, quests, loot, SmartAI, C++ scripts, spawns, phases, `game_tele` | SQL in `data/sql/updates/pending_db_world/` + C++; `ClientCacheVersion` bump if existing templates changed |
| Client and server, same DBC bytes | talents, spells, `Map.dbc`, `AreaTable.dbc`, `MapDifficulty.dbc` | DBC in `Data/enUS/patch-enUS-4.MPQ` **and** matching `*_dbc` SQL (or `data/dbc` in the server bundle) |
| Client geometry plus server derivatives | WDT/ADT/WMO/M2, textures | files in `Data/patch-4.MPQ` **and** re-extracted `maps/vmaps/mmaps` in the server bundle |

If a change exists on only one side the player sees a bug: black screen or disconnect (client lacks
a map), `CANNOT_ENTER_NO_ENTRY` (server lacks it), talents that refuse to learn (DBC mismatch),
floating or falling (client geometry without server vmaps).

## 2. Case study: The Waxworks (commit `055d930bd`)

What was built: a 5-man WMO-only instance kitbashed in Blender, hosted on map id **44** (the unused
`Monastery` entry Blizzard left in `Map.dbc`), with a walk-through portal from Elwynn, 50 creature
templates, 32 gameobjects, 30 items, three quests, 211 spawns, C++ bosses and an instance script
under `src/server/scripts/EasternKingdoms/Waxworks/`, SQL in
`data/sql/updates/pending_db_world/rev_1788471101263218298.sql`, and one shipped client archive
`Data/patch-4.MPQ` (manifest version `1.0.1`, `client_cache_version` 2).

What went right and is reusable verbatim for the next dungeon:

- Script and SQL layout (header enum as id source of truth, DELETE+INSERT blocks, `9000000+` ids).
- Walk-through entrance pattern (portal GameObject + `PlayerScript` teleport, no `AreaTrigger.dbc`).
- Bundle → publish to VPS → `deploy-vps` overlays `server-data.tar.gz` onto `<prefix>/data/`.
- `mapdifficulty_dbc` SQL overlay instead of redistributing `data/dbc/MapDifficulty.dbc`.
- The scout walk (`walk-instance`) for visual verification.

What was a shortcut that does **not** repeat:

- Reusing map 44 avoided editing `Map.dbc` on the client. There is no second unused *real* instance
  id: the remaining gaps (13, 25, 29, 42, 169, 451, …) are test maps that `mmaps_generator` skips as
  junk. Every further dungeon needs a **new `Map.dbc` row** in the client locale patch and in
  `map_dbc`.
- `build-bundle.sh/.ps1` write `install_path = Data/enUS/<file>`; the manifest was hand-edited to
  `Data/patch-4.MPQ`. Until the scripts learn base-vs-locale, edit the manifest after building.
- `client-patches/scripts/extract-server-data.sh` runs `./map_extractor` from the WoW directory,
  where the tools are not. Run the four extractors by hand.
- The portal and player scripts hard-code `MAP_WAXWORKS` and Waxworks positions.
- Planning notes for the mesh (`.agents/plans/`) are gitignored; the durable knowledge has been
  folded into `build-dungeon/reference-mesh.md` and `systems/dungeons.md`.

## 3. Can we build more dungeons? Yes, with these additions

Dungeon #2 and later follow `build-dungeon/reference-new-map.md`. Compared with Waxworks the extra
work is:

1. **Ids**: pick a 3-digit unused map id (e.g. `900`), a `Directory` name, an unused `AreaTable`
   id and `AreaBit`, a `MapDifficulty` id (`90000MM`), and the next `9000200–9000399` block from the
   registry in `systems/dungeons.md`.
2. **Client DBCs** in `Data/enUS/patch-enUS-4.MPQ`: `Map.dbc`, `MapDifficulty.dbc`, `AreaTable.dbc`
   rows (WDBX Editor on Windows; WDBX under Wine or a scripted writer on Linux).
3. **Client world files** in `Data/patch-4.MPQ` (rebuilt whole, Waxworks files included):
   `World/Maps/<Dir>/<Dir>.wdt` plus the WMO and any new textures/M2s.
4. **Server mirrors**: `map_dbc`, `mapdifficulty_dbc`, `areatable_dbc`, `instance_template`,
   `dungeon_access_template`, `graveyard_zone` SQL.
5. **Extraction** with the patched client: `vmaps/<id>.vmtree`, `.wmo.vmo`, `mmaps/<id>*`. The
   `Map.dbc` row must be in the **locale** archive or `vmap4_extractor` never sees the map.
6. **C++**: a new `InstanceMapScript(name, <id>)` and either a copy of the portal scripts or a
   shared table-driven one.

Everything else (content density, loot, pulls, lighting, the walk) is the existing skill.

## 4. Talents

Talent trees are the pure "same DBC on both sides" case. `Talent.dbc` (tree layout),
`TalentTab.dbc` (tabs), and `Spell.dbc` (what a rank does) must be identical in the client's
`patch-enUS-4.MPQ` and in the server's `data/dbc` or `talent_dbc` / `talenttab_dbc` / `spell_dbc`
overlays. The server computes points (`level − 9`, `Rate.Talent`, `OnPlayerCalculateTalentsPoints`)
and stores learned **rank spell ids** in `acore_characters.character_talent`.

Hard limits (`MAX_TALENT_RANK = 5` ranks per talent, `MAX_TALENT_TABS = 3` tabs per class, rows
0–10 and columns 0–3 in the client frame, 5 points per tier gate, `level − 9` points) are shared by
client and server. Anything within them is a data change; beyond them means patching `Wow.exe` and
the core together, which this fork does not do. Moving or removing ranks requires
`AT_LOGIN_RESET_TALENTS` for the affected class. Details: `systems/talents.md`, procedure:
`edit-talents`.

## 5. Overworld terrain

Continents are grids of 64×64 ADT tiles (`Azeroth_<gx>_<gy>.adt`). Editing them is a Noggit job
on Windows (or Wine). The rules that matter:

- Ship only the tiles you meant to change; Noggit resaves neighbours.
- Re-extract `maps`, `vmaps`, `mmaps` **for those tiles only** and overlay them; never overlay a
  whole continent extraction.
- ADT water and area ids are global: phases cannot hide them.
- New area ids need `AreaTable.dbc` on the client, `areatable_dbc` on the server, and a
  `graveyard_zone` link, or ghosts fall back to the faction graveyard with a log error.

Details: `systems/terrain.md`, procedure: `edit-terrain`.

## 6. Building and shipping: MPQs, extractors, bundles

Archive facts that bite:

- The client loads `Data/common*`, `expansion`, `lichking`, then locale archives, then
  `Data/enUS/patch-enUS-N`, then `Data/patch-N` (N = 2..9, then A..Z). Later wins.
- Blizzard ships `patch`, `-2`, `-3`. Custom content is `patch-4` (world files) and
  `patch-enUS-4` (DBCs). Never go past `patch-5`: `map_extractor` stops there, and it reads DBCs
  from **locale archives only**.
- Archives must be MPQ **v2**. `smpq` defaults to v4 (pass `-M 2`); MPQEditor must be set to the
  WotLK compatibility mode. v4 archives are silently ignored by the extractors.
- One `patch-4.MPQ` carries every custom world file. Each release rebuilds it whole.

Pipeline per release (`build-client-patch` skill, §1–§7):

1. Stage loose files under `client-patches/sources/client/loose/` with exact internal paths.
2. Pack `patch-4.MPQ` and `patch-enUS-4.MPQ`; install into a dev client; check in game.
3. Extract with that client: `map_extractor`, `vmap4_extractor`, `vmap4_assembler`,
   `mmaps_generator <map>`; keep only the new/changed files under `sources/server/`.
4. `build-bundle` → `bundles/<version>/` with `manifest.json` (sha256, install paths,
   `client_cache_version`). Fix `install_path` for `Data/` archives.
5. `publish-to-vps` → `/home/acore/client-patches/releases/<version>/`, `current` symlink.
6. Commit `client-patches/manifest.json` + SQL + C++; push `dev`; `deploy-vps` builds the core and
   overlays `server-data.tar.gz`, `apply-server-data.sh` sets `ClientCacheVersion`.
7. Players run `update-client.sh/.ps1`; verify on Test with a patched and an unpatched client.

Git tracks the manifest only. Binaries live on the VPS; back them up offsite
(`backup-client-patches.sh`), or a lost VPS loses the map work.

## 7. Windows vs Linux

| Task | Windows | Linux |
|---|---|---|
| Terrain (Noggit) | Native | Build from source or Wine; unsupported |
| WMO / M2 (Blender + WoW Blender Studio) | Yes | Yes |
| Browse Blizzard MPQs | wow.export (Legacy mode), MPQEditor | `smpq -l/-x`, wow.export |
| Pack MPQ | MPQEditor (GUI or `/console`) | `smpq -M 2 -c` |
| Edit DBC | WDBX Editor | WDBX under Wine/Mono, or SQL overlay + scripted writer |
| Extractors | Build this repo with `-DTOOLS_BUILD=all` | Same |
| Bundle | `build-bundle.ps1` | `build-bundle.sh` (`python3`, `jq`, `tar`) |
| Publish | `publish-to-vps.ps1` (OpenSSH client) | `publish-to-vps.sh` (`ssh`, `rsync`) |
| Player update | `update-client.ps1` | `update-client.sh` |
| In-game scouting / screenshots | `walk-instance` PowerShell scripts | Not available |
| SOAP GM commands | `scout-soap.ps1` | `curl` with the same XML |

Practical split used so far: mesh, DBC, MPQ, extraction and visual checks on the Windows dev box;
publishing and deployment from any shell; the VPS (Debian 12) runs the servers and has no
extractors. Exact commands for both operating systems are in
`.agents/skills/build-client-patch/reference-windows-linux.md`.

## 8. Known gaps to fix before dungeon #2 (tracked in `systems/dungeons.md`)

- `build-bundle.*`: no way to declare a `Data/` (non-locale) install path.
- `extract-server-data.sh`: wrong working directory assumption for the tools.
- Waxworks portal scripts are not table-driven.
- No `LFGDungeons` / `WorldMapArea` rows for Waxworks (Dungeon Finder and map UI); optional.
