# Client patches

This document explains how to ship custom WoW 3.3.5a client MPQ patches **and** the matching AzerothCore server data, using the tooling in `client-patches/` and `apps/deploy/debian12/client-patches/`.

## Why two sides?

| Change | Server only? | Client MPQ needed? |
|--------|--------------|-------------------|
| NPCs, quests, scripts on existing maps | Yes | No |
| New terrain / map geometry | No | Yes |
| Talent tree / DBC UI changes | No | Yes (same DBC on both sides) |
| Custom models / spell icons | No | Yes |

When both sides are needed, this system keeps them on the **same version** and deploys them together.

## Storage policy

**All patch binaries (MPQs, server data archives) live on the VPS.** Git tracks only `manifest.json` — version numbers, checksums, and changelog.

| Location | In git? | Role |
|----------|---------|------|
| `client-patches/manifest.json` | Yes | Release metadata |
| `client-patches/sources/` | Structure only | Local dev-machine staging; binaries are gitignored |
| `client-patches/bundles/` | No | Local build output before upload |
| `/home/acore/client-patches/` on VPS | No | **Canonical store** for all releases |

Back up the VPS patch store offsite (`backup-client-patches.sh`). If the VPS is lost without a backup, custom map work is gone even though git still has the manifest.

## Repository layout

```
client-patches/
  manifest.json              # Current release metadata (commit this)
  manifest.schema.json       # JSON schema for validation
  sources/
    client/mpq/              # Local staging: finished MPQs (gitignored)
    client/loose/            # Local staging before packing MPQ (gitignored)
    server/dbc/              # Local staging: server DBC overlay (gitignored)
    server/maps/             # Local staging (gitignored)
    server/vmaps/            # Local staging (gitignored)
    server/mmaps/            # Local staging (gitignored)
  scripts/                   # Build, publish, update helpers
  bundles/                   # Local build output (gitignored)

/home/acore/client-patches/   # VPS canonical binary store (not in git)
  releases/<version>/
  current -> releases/<version>          # latest published
  current-test -> releases/<version>     # last Test deploy
  current-live -> releases/<version>     # last Live deploy
```

## Creating client MPQ files

The client loads `Data/patch-N.MPQ` (world files) and `Data/enUS/patch-enUS-N.MPQ` (DBCs). This fork ships **one** `Data/patch-4.MPQ` for every custom world file and `Data/enUS/patch-enUS-4.MPQ` for DBC edits. Do not use lettered `patch-A.MPQ` or `patch-6+`: `map_extractor` stops at `patch-5` and lettered archives are invisible to it. Pack as MPQ **v2**.

1. Edit DBCs, interface XML, models, etc. with your tools of choice.
2. Pack them into an MPQ using an editor such as [Ladik's MPQ Editor](https://github.com/ladislav-zezula/StormLib) (compatibility "WoW: WotLK") or `smpq -M 2`.
3. Place the finished archive in `client-patches/sources/client/mpq/` on your **dev machine** (`patch-4.MPQ` and, if DBCs changed, `patch-enUS-4.MPQ`). Binaries are gitignored.

Loose files can be staged under `sources/client/loose/`; `build-bundle.sh` / `build-bundle.ps1` expect finished MPQs in `sources/client/mpq/`. World archives get `install_path = Data/<file>`; locale archives get `Data/<locale>/<file>`. After building, publish to the VPS — that is where binaries are kept long-term.

## Creating server data

### From a modified WoW client (new terrain)

After editing maps in Noggit (or similar) and updating your WoW install:

```bash
WOW_CLIENT=/path/to/WoW \
AC_TOOLS_BIN=/path/to/ac/build/bin \
client-patches/scripts/extract-server-data.sh --map 44
```

This runs the AzerothCore extractors from `AC_TOOLS_BIN` (not from the WoW folder) into a temp dir, then syncs `dbc/`, `maps/`, `vmaps/`, `mmaps/` into `sources/server/`. Pass `--map ID` (repeatable) so mmaps are generated only for those maps; `--skip-mmaps` skips them. Use a slim client copy so unchanged continents are not extracted. The VPS overlay is additive — ship only the files you changed.

You can also run the four tools by hand (see `.agents/skills/build-client-patch/reference-windows-linux.md`) and rsync outputs into `sources/server/`.

### DBC-only changes

Copy edited `.dbc` files into `sources/server/dbc/`. Players need the same DBCs in their MPQ patch.

## Building a release

```bash
client-patches/scripts/build-bundle.sh 1.0.0 \
  --cache-version 42 \
  --changelog "Add eastern valley prototype" \
  --changelog "Talent tab experiment"
```

Windows (after packing MPQs with an editor such as Ladik's):

```powershell
.\client-patches\scripts\build-bundle.ps1 1.0.0 `
  -CacheVersion 42 `
  -Changelog 'Add eastern valley prototype','Talent tab experiment'
```

This produces:

- `client-patches/bundles/1.0.0/client/*.MPQ`
- `client-patches/bundles/1.0.0/server/server-data.tar.gz`
- `client-patches/bundles/1.0.0/manifest.json` (copied to `client-patches/manifest.json`)

Commit **`manifest.json` only**, **after** publishing the bundle so `deploy-vps` can find the binaries. Do not commit `bundles/`, MPQs, or extracted server data — those belong on the VPS.

## Publishing to the VPS

From your dev machine:

```bash
VPS_HOST=debian@your.vps \
client-patches/scripts/publish-to-vps.sh client-patches/bundles/1.0.0
```

SSH as **debian** (the VPS login). The script writes into `/home/acore/client-patches/` and runs the publish helper as `acore` via sudo.

```powershell
.\client-patches\scripts\publish-to-vps.ps1 `
  -BundleDir '.\client-patches\bundles\1.0.0' `
  -VpsHost 'debian@your.vps'
```

On the VPS directly:

```bash
apps/deploy/debian12/client-patches/publish-client-patches.sh client-patches/bundles/1.0.0
```

This stores the release under `/home/acore/client-patches/releases/<version>/` and updates the `current` (latest published) symlink. **Publishing does not overlay Live or Test.** The matching git commit's `manifest.json` is applied the next time that realm's `deploy-vps` runs; that apply also points `current-test` or `current-live` at the release.

### Optional HTTP downloads

To let the player updater use HTTP instead of SCP, serve `/home/acore/client-patches/current-test` (or `current-live`) with nginx or Caddy and set:

```bash
PATCHES_BASE_URL=https://your.domain/client-patches/current
```

## Deploying server data

Server overlay is applied by **`deploy-vps`**, using the `client-patches/manifest.json` of the commit that was **built** for that realm:

| Branch | Realm | When overlay applies |
|--------|-------|----------------------|
| `dev` | Test (`/home/acore/server-test`) | Auto after `vps-build` on push |
| `Playerbot` | Live (`/home/acore/server`) | Manual `deploy-vps` target `live` after `vps-build` |

If that commit's manifest is placeholder `0.0.0`, deploy skips the overlay. If the version is real but missing from `/home/acore/client-patches/releases/`, or the git checksums do not match the store copy, deploy **fails** (publish the matching bundle first).

SQL is the same story: `deploy-vps` rsyncs `data/sql` from that commit into a **per-realm** `SourceDirectory` (`azerothcore-wotlk` for Live, `azerothcore-wotlk-test` for Test) and clones `mod-playerbots` / `mod-individual-progression` under `modules/`. Worldserver then applies `pending_db_*` on start. Do not share one stale clone between realms.

### Manual override (emergency only)

**Actions → deploy-client-patches** applies a store release immediately and restarts that world. Default target is Test. Prefer `deploy-vps` so C++, SQL, and the MPQ overlay stay on the same SHA.

### Manual (on VPS)

Only when `deploy-vps` cannot run. This still does **not** apply pending SQL.

```bash
ACORE_PREFIX=/home/acore/server-test \
apps/deploy/debian12/client-patches/apply-server-data.sh --from-manifest /path/to/manifest.json
/home/acore/deploy/restart-acore.sh restart test
```

`apply-server-data.sh`:

- Verifies checksums from `manifest.json`
- Extracts `server-data.tar.gz` as an **overlay** into `<prefix>/data/` (does not wipe existing data)
- Sets `ClientCacheVersion` so clients refresh cached DBC data
- Records the applied version in `etc/.client-patch-version`

## Player client updates

Quit WoW completely before installing patches.

### Linux / macOS / Git Bash / WSL

```bash
WOW_DIR=/path/to/ChromieCraft \
FROM_VPS=debian@your.vps \
client-patches/scripts/update-client.sh --target test
```

### Windows (PowerShell)

Needs OpenSSH Client (Settings → Apps → Optional features). If scripts are blocked:

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

```powershell
cd path\to\azerothcore-wotlk
.\client-patches\scripts\update-client.ps1 `
  -WowDir 'C:\Games\ChromieCraft' `
  -FromVps 'debian@your.vps' `
  -Target test
```

`-Target live` pulls the version Live last deployed. Omit `-Target` / `--target` to fetch `current` (latest **published**, which may be ahead of Live). `-DryRun` prints destinations without writing. `-Version 1.0.0` pulls that release instead of a symlink. Delete `.acore-client-patch-version` in the WoW folder to force a reinstall.

### HTTP (any OS)

Serve `/home/acore/client-patches/current` with nginx or Caddy, then:

```bash
WOW_DIR=/path/to/ChromieCraft \
PATCHES_BASE_URL=https://your.domain/client-patches/current \
client-patches/scripts/update-client.sh
```

```powershell
.\client-patches\scripts\update-client.ps1 `
  -WowDir 'C:\Games\ChromieCraft' `
  -PatchesUrl 'https://your.domain/client-patches/current'
```

The updater:

1. Downloads `manifest.json` and client MPQs
2. Verifies SHA-256 checksums
3. Installs MPQs to the paths listed in the manifest (e.g. `Data/patch-4.MPQ`, `Data/enUS/patch-enUS-4.MPQ`)
4. Writes `.acore-client-patch-version` in the WoW folder

Players must run this **before** logging in when a new client bundle is required.

## Versioning rules

- Use semver for `manifest.version` (`1.0.0`, `1.1.0`, …).
- Increment `client_cache_version` whenever DBC data changes (build-bundle does this automatically).
- Keep `blizzard_build` at `12340` for WotLK 3.3.5a unless you ship a custom client executable.
- Server code deploys (`deploy-vps`) apply C++, pending SQL, and the git `manifest.json` overlay together. Publishing binaries to the VPS store is not a realm deploy.

## Manifest reference

See [`client-patches/manifest.schema.json`](../client-patches/manifest.schema.json) and the placeholder [`client-patches/manifest.json`](../client-patches/manifest.json).

Key fields:

| Field | Purpose |
|-------|---------|
| `version` | Release identifier |
| `client_cache_version` | Written to `worldserver.conf` on deploy |
| `client.patches[]` | MPQ filename, checksum, install path |
| `server.archive` | Tarball overlay for `data/` |
| `server.components` | Which of `dbc`, `maps`, `vmaps`, `mmaps` are included |

## Troubleshooting

| Symptom | Check |
|---------|-------|
| Client sees wrong talents / map | Player ran `update-client`? `ClientCacheVersion` bumped? |
| Server won't load map | `sources/server/maps` included in bundle? Extracted for correct map ID? |
| `validate-manifest.sh` fails | Re-run `build-bundle.sh`; checksums and `install_path` must match files |
| Deploy fails: git ≠ store | Publish the bundle that matches this commit's `manifest.json` |
| Client on Test sees Live (or vice versa) | Testers: `--target test`. Live players: `--target live`. `current` is latest published, not a realm. |
| Release already exists on VPS | Publish a new version or remove old `releases/<version>/` |

## Related server docs

- [`apps/deploy/README.md`](../apps/deploy/README.md) — server binary deploy
- [`vps-bootstrap.md`](vps-bootstrap.md) — VPS setup
- [`multi-realm.md`](multi-realm.md) — live vs test realms
