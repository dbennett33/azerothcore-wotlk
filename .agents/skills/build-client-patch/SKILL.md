---
name: build-client-patch
description: >-
  Ship a WoW 3.3.5a client patch (MPQ) together with the matching AzerothCore
  server data (dbc/maps/vmaps/mmaps) through this fork's client-patches bundle,
  VPS store and deploy-vps overlay. Use when packing patch-4.MPQ or a locale
  patch-enUS-N.MPQ, editing DBC files, running map_extractor / vmap4_extractor /
  vmap4_assembler / mmaps_generator, staging sources/, running build-bundle,
  publish-to-vps, update-client, bumping manifest.json, or when asked how MPQs
  are built on Windows vs Linux.
---

# Build and ship a client patch (AzerothCore 3.3.5a, this fork)

Read `.agents/docs/systems/client-data.md` first: it defines which side (client MPQ, server
`data/`, world DB) each change belongs to and why. This skill is the procedure. OS-specific tool
commands: [reference-windows-linux.md](reference-windows-linux.md). Human overview:
`docs/client-patches.md` and `docs/custom-content.md`.

Related skills: dungeons → `build-dungeon`; talents → `edit-talents`; ADT → `edit-terrain`.

## Non-negotiables

- One `Data/patch-4.MPQ` holds **every** custom world file of this realm; DBC edits go in
  `Data/enUS/patch-enUS-4.MPQ`. Never introduce `patch-6+` or lettered patches: `map_extractor`
  stops at `patch-5` and reads DBCs from locale archives only.
- Archives are MPQ **v2** (extractors use libmpq: v1/v2 only). `smpq` defaults to v4 — pass `-M 2`.
- Binaries never enter git. Only `client-patches/manifest.json` is committed, in the **same
  commit** as the SQL/C++ that needs the data.
- Close every `Wow.exe` before writing into a client `Data/` (exclusive lock; silent stale reads).
- Extraction runs on a dev machine with the **patched** client. The VPS has no extractors
  (`-DTOOLS_BUILD=none`).
- Ship only the files for the maps/tiles you changed. The server overlay is additive and would
  otherwise replace every continent file with bytes from a different extraction.
- `manifest.version` bumps on every release; `client_cache_version` bumps only when existing
  template rows changed (it clears the client WDB cache, not DBCs).

## Workflow

```
Task progress:
- [ ] Change classified (client-only / server-only / both) per client-data.md
- [ ] Loose files staged with exact MPQ-internal paths
- [ ] Archive(s) packed as MPQ v2, listed back, installed into the dev client, Wow restarted
- [ ] Server data extracted from the patched client; only changed maps/tiles kept
- [ ] DBC server copy decided: `*_dbc` SQL overlay (small) or `sources/server/dbc/` (large)
- [ ] Bundle built; install_path fixed for Data/ archives; manifest copied to client-patches/
- [ ] Bundle published to the VPS store (debian@ SSH)
- [ ] manifest.json committed with the SQL/C++; pushed to dev; test realm verified
- [ ] Players told to run update-client before login
```

### 1. Classify

| You changed | Client archive | Server data | World DB |
|---|---|---|---|
| WDT/ADT/WMO/M2/BLP (geometry, models) | `Data/patch-4.MPQ` | `maps/` (ADT maps), `vmaps/`, `mmaps/` for that map | spawns etc. |
| `Map.dbc`, `MapDifficulty.dbc`, `AreaTable.dbc`, `Talent*.dbc`, `Spell.dbc`, … | `Data/enUS/patch-enUS-4.MPQ` | `dbc/` **or** `*_dbc` overlay row | overlay row if chosen |
| Icons, UI, sounds, loading screens | `Data/patch-4.MPQ` | none | none |
| Templates, loot, scripts, spawns | none | none | `pending_db_world` |

### 2. Stage loose files

```
client-patches/sources/client/loose/
  World/Maps/<Dir>/<Dir>.wdt                   (+ <Dir>_<gx>_<gy>.adt for ADT maps)
  World/wmo/Dungeon/<Dir>/<Name>.wmo, <Name>_000.wmo, …
  World/wmo/.../*.blp, World/.../*.m2 *.skin (only files not already in Blizzard MPQs)
  DBFilesClient/Map.dbc, MapDifficulty.dbc, …  → these go into the LOCALE archive, not patch-4
```

Paths inside the archive are case-insensitive but must use the exact Blizzard folder names. Keep
the previous release's loose set (the archive is rebuilt whole each time). Waxworks source of truth
for its WMO/WDT set: `build-dungeon/reference-mesh.md` "Custom instance — minimum files".

### 3. Pack

Windows: MPQEditor console script (ASCII, no BOM) or GUI, compatibility "WoW: WotLK". Linux:
`smpq -M 2 -c`. Exact commands and the listing check are in
[reference-windows-linux.md](reference-windows-linux.md). Output goes to
`client-patches/sources/client/mpq/patch-4.MPQ` (and `patch-enUS-4.MPQ` when DBCs changed).

Install a copy into the dev client (`<client>/Data/patch-4.MPQ`, `<client>/Data/enUS/…`), start
`Wow.exe`, and confirm the client sees it (new map loads, new talent renders) **before** extracting.

### 4. Extract server data

Build the tools once from this repo (`-DTOOLS_BUILD=all`, or `maps-only`). Then, in a **slim copy**
of the client `Data/` (Blizzard base + locale archives + your patches; other maps' WDTs absent so
they are skipped):

```
map_extractor  -i <client> -o <out> -e 3        # maps (1) + dbc (2); skip cameras
vmap4_extractor -d <client>/Data/                # wipe ./Buildings first (skip-if-exists trap)
vmap4_assembler Buildings vmaps
mmaps_generator <mapid> [--tile gx,gy] --threads N   # needs mmaps-config.yaml in cwd
```

Keep only:

- new/changed map: `maps/<id:03>*.map` (ADT maps only), `vmaps/<id:03>.vmtree`,
  `vmaps/<id:03>_*.vmtile`, every new `vmaps/<Model>.vmo`, `mmaps/<id:03>*`;
- edited continent tile: the single `maps/000<gx><gy>.map`, `vmaps/000_<gx>_<gy>.vmtile`, new
  `.vmo`s, `mmaps/000<gx><gy>.mmtile`;
- edited DBCs: the files from `<out>/dbc/` you edited — or skip them and write `*_dbc` SQL rows.

Move them into `client-patches/sources/server/{maps,vmaps,mmaps,dbc}/` (gitignored). WMO-only
instance maps produce **no** `.map` files; do not invent them. `extract-server-data.sh` currently
calls `./map_extractor` from the WoW dir and fails unless the binaries are copied there — run the
four tools by hand as above.

### 5. Bundle

```bash
client-patches/scripts/build-bundle.sh 1.1.0 --changelog "…"        # Linux / Git Bash / WSL
.\client-patches\scripts\build-bundle.ps1 1.1.0 -Changelog '…'     # Windows PowerShell
```

Both scripts write `install_path = Data/<locale>/<file>`. For `patch-4.MPQ` (a **base** archive)
edit `client-patches/bundles/<version>/manifest.json` → `"install_path": "Data/patch-4.MPQ"`, then
copy that manifest over `client-patches/manifest.json` (validate-manifest checks checksums, not
paths; `update-client.*` installs to whatever `install_path` says). Locale archives keep the
default. Semver: patch bump for data-only fixes, minor for a new map/tree, major when players must
reinstall.

### 6. Publish, commit, deploy

```bash
VPS_HOST=debian@<vps> client-patches/scripts/publish-to-vps.sh client-patches/bundles/1.1.0
git add client-patches/manifest.json data/sql/updates/pending_db_world/… src/…
git commit && git push -u origin dev        # vps-build → deploy-vps test applies SQL + overlay
```

Publishing only fills `/home/acore/client-patches/releases/<version>/` (and `current`). Nothing
reaches a realm until `deploy-vps` runs for a commit whose manifest names that version; a version
missing from the store fails the deploy on purpose. Live = merge `dev → Playerbot`, then Actions →
`deploy-vps` target `live`. `deploy-client-patches` is the emergency override only.

Players: `update-client.sh` / `update-client.ps1` (`-FromVps debian@<vps>` or `PATCHES_BASE_URL`),
Wow closed, before logging in.

### 7. Verify

- worldserver log (test prefix `/home/acore/server-test/logs`): `>> Initialized N Data Stores`
  with no "Size of '…dbc' set by format string" error; no `WorldModelStore: could not load '…vmo'`;
  no `MMAP:loadMap: Could not load …mmtile` for the map (mmap load lines are `LOG_DEBUG("maps")`,
  raise that logger to see successes).
- `ls <prefix>/data/vmaps/<id:03>.vmtree <prefix>/data/vmaps/<Model>.vmo` (>10 KB) and
  `etc/.client-patch-version` equals the manifest version.
- In game with a client that ran `update-client`: `.gps` at the new spot shows the expected map/
  area/Z; a creature walks to you (mmaps). Visual proof: `walk-instance` skill.
- A client **without** the patch must fail the way client-data.md predicts (blackscreen /
  `CANNOT_ENTER`), proving the release actually depends on the MPQ.

## Rollback

Revert the commit that bumped `manifest.json` and redeploy; `apply-server-data.sh` re-applies the
older release (state file differs). Files added by the newer release stay on disk — delete stray
`maps/vmaps/mmaps` for an abandoned map id by hand on the VPS. Players re-run `update-client
--version <old>` or delete the archive.

## Pitfalls seen on this fork

- Manifest `install_path` left as `Data/enUS/patch-4.MPQ` → client never loads the world files.
- `Buildings/` not wiped → 0-vertex `.vmo` poisons `dir_bin`; assemble looks fine, players fall.
- Full-client vmap extract killed midway, then assembled → 31 MB continent `dir_bin`, hours lost.
- `Map.dbc` row only in `Data/patch-4` → client happy, vmap extractor never sees the map.
- MPQEditor script saved as UTF-8 with BOM → `new` silently no-ops (PowerShell 5.1 default).
- Publishing as `acore@` instead of `debian@` → permission errors; helpers `sudo -u acore` for you.
- Copying only `044.vmtree` (no `.wmo.vmo`) → underwater then fall. Gate on the `.vmo`.
