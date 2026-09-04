# Client data (MPQ / DBC / maps) and the client–server contract

Read this before changing anything the 3.3.5a client renders or validates: maps, WMO/ADT geometry,
DBC rows (talents, spells, areas, Map.dbc), models, or the server's `data/` folder. Procedures live
in `.agents/skills/build-client-patch/SKILL.md`; this doc is the model those procedures assume.

## The contract

WoW 3.3.5a is two programs reading two copies of the same data. The client reads MPQ archives; the
worldserver reads files the AzerothCore extractors derived **from those same MPQs**. Anything that
exists on only one side is a bug the player sees.

| Change | Server side | Client side |
|---|---|---|
| Creatures, GOs, items, quests, loot, SmartAI, C++ scripts | world DB SQL / C++ | none (WDB cache; see `ClientCacheVersion`) |
| Spawn positions, phases, `game_tele`, `instance_template` | world DB SQL | none |
| New map id, map type, max players, difficulty | `map_dbc` / `mapdifficulty_dbc` SQL **or** `data/dbc` | `Map.dbc`, `MapDifficulty.dbc` in a locale MPQ |
| Geometry (WDT/ADT/WMO/M2), collision, navmesh | `data/maps`, `data/vmaps`, `data/mmaps` (re-extract) | WDT/ADT/WMO/M2/BLP in a `Data/patch-N.MPQ` |
| Talents, spells, skills, area names/levels, area triggers | matching `*_dbc` SQL or `data/dbc` | same DBC in a locale MPQ |
| Icons, textures, sounds, UI/Lua, loading screens | none | MPQ |

Rules that follow from the contract:

- Server has a map id the client lacks → `.go` works, client disconnects/blackscreens.
- Client has the id, server does not → `CANNOT_ENTER_NO_ENTRY`.
- Both have the id, no WDT/WMO behind it → client crash.
- Same-id DBC rows that differ (talents, spells) → desyncs: talent points refused, inspect garbage,
  wrong tooltips. Ship the **same bytes** on both sides.
- A server-only `areatrigger` row never fires: the client decides when it entered an
  `AreaTrigger.dbc` volume and tells the server. Use a vanilla AT id or a `GameObjectAI` box check.

## Where the client reads from

Archive load order (enUS client; later = higher priority, wins on duplicate paths):

1. `Data/common.MPQ`, `common-2.MPQ`, `expansion.MPQ`, `lichking.MPQ`
2. `Data/enUS/locale-enUS.MPQ`, `expansion-locale-enUS.MPQ`, `lichking-locale-enUS.MPQ`
3. `Data/enUS/patch-enUS.MPQ`, `patch-enUS-2.MPQ`, `patch-enUS-3.MPQ`, … `-9`, then `-A`…`-Z`
4. `Data/patch.MPQ`, `patch-2.MPQ`, `patch-3.MPQ`, … `patch-9.MPQ`, then `patch-A.MPQ`…`patch-Z.MPQ`

Blizzard ships `patch`, `-2`, `-3` (and the locale equivalents). Everything from `-4` up is free
for custom content. Non-English clients flip the order so locale archives win; this fork is enUS.

DBC files live under `DBFilesClient\` and Blizzard ships them **only in locale archives**. World
geometry lives under `World\` in the base archives.

## Where the extractors read from (this repo, `src/tools/`)

The extractors do **not** mirror the client's full search. Verified against the source:

| Tool | Archives it opens | Consequence |
|---|---|---|
| `map_extractor` (maps + dbc) | `Data/`: `common`, `common-2`, `lichking`, `expansion`, `patch`, `patch-2`…**`patch-5`** only. Locale: `locale-XX`, `patch-XX`, `patch-XX-2`…**`-9`**. **DBCs are read with only the locale archives open.** | World files must be in `Data/patch-4.MPQ` or `patch-5.MPQ`. DBC edits must be in `Data/enUS/patch-enUS-4.MPQ`…`-9`, never in `Data/patch-N`. Lettered patches are invisible. |
| `vmap4_extractor` | Locale base, `Data/` base, then `Data/patch*.MPQ` scanned `patch`, `-2`…`-99`, then locale `patch-XX*` `-2`…`-99` | Numeric only; no letters. Reads `Map.dbc` from whatever locale archive wins, so a `Map.dbc` row missing from the locale patch means **no vmaps for that map** (azerothcore#16740). |
| `vmap4_assembler` | none (reads `Buildings/`) | `Buildings/` must be wiped between runs: `ExtractSingleWmo` skips a WMO whose output already exists. |
| `mmaps_generator` | none (reads `maps/` + `vmaps/`, needs `mmaps-config.yaml` in cwd) | Takes a map id argument; `skipJunkMaps` drops 13/25/29/42/169/451/573/597/605/606 and transport maps. |

Both extractors' MPQ reader (`deps/libmpq`) understands **MPQ format v1 and v2 only**. Pack custom
archives as v2 (`smpq -M 2`, or MPQEditor "WoW: WotLK" compatibility). A v4 archive is silently
skipped by the extractors and ignored by the client.

Within one extractor the **last opened archive wins** (`gOpenArchives.push_front`). For
`map_extractor` that means `Data/patch-5` > `patch-4` > … > locale; for `vmap4_extractor` locale
patches beat `Data/` patches. Do not depend on that ordering: keep one copy of each custom file.

## Server `data/` layout and how it is consumed

```
data/dbc/<File>.dbc          LoadDBCStores(): DBC row + optional SQL overlay
data/dbc/<locale>/           string columns per locale (optional)
data/maps/MMMXXYY.map        terrain height/area/liquid per ADT tile (map, gx, gy)
data/vmaps/MMM.vmtree        BIH of models placed on map MMM
data/vmaps/MMM_XX_YY.vmtile  per-tile placement (ADT maps only)
data/vmaps/<Model>.vmo       collision mesh of one WMO/M2 (shared by every map that places it)
data/mmaps/MMM.mmap + MMMXXYY.mmtile   Recast navmesh for creature pathing
```

- Tile index: `gx = 32 - y / 533.333`, `gy = 32 - x / 533.333` (`GridTerrainData.cpp`).
  File name is `Azeroth_<gx>_<gy>` / `000<gx><gy>.map`. Noggit sometimes prints them swapped.
- WMO-only maps (Ragefire 389, Waxworks 44) have **no** `.map` tiles; height and floor come from
  vmaps. A doodad-less `.vmtree` can be ~143 bytes. Gate on the `.wmo.vmo` existing (>10 KB).
- The server addresses everything by **map id**; `Map.dbc` `Directory` is ignored server-side
  (`MapEntry` comments it out). Directory matters only to the client and the extractors.
- `vmap.enableHeight`, `vmap.enableLOS`, `vmap.enableIndoorCheck`, `MoveMaps.Enable` in
  `worldserver.conf` toggle consumption; missing mmaps for a map degrade to
  `PATHFIND_NOT_USING_PATH` / cannot-reach HP regen, not a crash.

## `*_dbc` SQL overlays (world DB)

`LOAD_DBC(store, "X.dbc", "x_dbc")` loads the file, then `SELECT * FROM x_dbc ORDER BY ID DESC`.
A SQL row with an ID that exists in the file **replaces** that record; a new ID **adds** one. Empty
string columns keep the file's strings. Coverage: every store listed in
`src/server/game/DataStores/DBCStores.cpp` (`map_dbc`, `mapdifficulty_dbc`, `talent_dbc`,
`talenttab_dbc`, `spell_dbc`, `areatable_dbc`, `skilllineability_dbc`, …). `AreaTrigger.dbc` has
**no** overlay. Column order and count must match the DBC format string exactly; the base tables
in `data/sql/base/db_world/*_dbc.sql` are the schema reference.

Use the overlay for **server-side truth without redistributing `data/dbc`** (this fork does that
for Waxworks: `mapdifficulty_dbc` id `9000044`). It never removes the need for the client copy.

## `ClientCacheVersion` is not a DBC cache

The client caches **query responses** (creature/gameobject/item/quest/npc_text/page_text names and
stats) under `Cache/WDB/enUS/*.wdb`. `ClientCacheVersion` (`worldserver.conf`, set on deploy by
`apply-server-data.sh` from `manifest.client_cache_version`) invalidates those. Bump it when you
**change** existing template rows the client already saw. New entries need no bump. DBC contents are
read straight from MPQs and are unaffected — a new `Talent.dbc` needs a new MPQ on the player's
disk, full stop.

## This fork's shipping model (summary)

- Binaries never enter git. `client-patches/manifest.json` (version, sha256, install paths,
  `client_cache_version`) is the only tracked artefact. Bundles live on the VPS under
  `/home/acore/client-patches/releases/<version>/`; `current` is a symlink.
- The server overlay (`server-data.tar.gz` with `dbc/ maps/ vmaps/ mmaps/`) is untarred **over**
  `<prefix>/data/` by `deploy-vps` for the commit that was built. It adds/replaces files; it never
  deletes. Removing a map means deleting its files on the VPS by hand.
- One `Data/patch-4.MPQ` carries **all** custom world files for this realm; each release rebuilds
  and re-publishes the whole archive (the manifest's sha256 changes). Do not split future dungeons
  into `patch-5`, `-6`, …: `map_extractor` stops at `-5` and players would need N installs.
- `build-bundle.sh` / `.ps1` set `install_path` from the filename: `patch-4.MPQ` → `Data/patch-4.MPQ`, `patch-enUS-4.MPQ` → `Data/enUS/patch-enUS-4.MPQ`. `validate-manifest.sh` rejects a locale path on a world archive. `update-client.*` honours `install_path`.
- Extractors are **not** built on the VPS (`-DTOOLS_BUILD=none`). Extraction happens on a dev
  machine with the packed client; see the skill for Windows vs Linux specifics.
