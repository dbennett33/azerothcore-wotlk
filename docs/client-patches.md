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
  current -> releases/<version>
```

## Creating client MPQ files

WoW loads patch archives from `Data/<locale>/patch-*.MPQ`. Custom patches should use letters **after** Blizzard's `patch-4.MPQ` (e.g. `patch-A.MPQ`, `patch-B.MPQ`).

1. Edit DBCs, interface XML, models, etc. with your tools of choice.
2. Pack them into an MPQ using an editor such as [Ladik's MPQ Editor](https://github.com/ladislav-zezula/StormLib) or similar.
3. Place the finished archive in `client-patches/sources/client/mpq/` on your **dev machine** (local staging — not committed to git).

Loose files can be staged under `sources/client/loose/`; `build-bundle.sh` expects finished MPQs in `sources/client/mpq/`. After building, publish to the VPS — that is where binaries are kept long-term.

## Creating server data

### From a modified WoW client (new terrain)

After editing maps in Noggit (or similar) and updating your WoW install:

```bash
WOW_CLIENT=/path/to/WoW \
AC_TOOLS_BIN=/path/to/ac/build/bin \
client-patches/scripts/extract-server-data.sh
```

This runs the standard AzerothCore extractors (`map_extractor`, `vmap4_extractor`, `vmap4_assembler`, `mmaps_generator`) and syncs outputs into `sources/server/`.

You can also use `apps/extractor/extractor.sh` from the WoW folder and manually rsync `dbc/`, `maps/`, `vmaps/`, `mmaps/` into `sources/server/`.

### DBC-only changes

Copy edited `.dbc` files into `sources/server/dbc/`. Players need the same DBCs in their MPQ patch.

## Building a release

```bash
client-patches/scripts/build-bundle.sh 1.0.0 \
  --cache-version 42 \
  --changelog "Add eastern valley prototype" \
  --changelog "Talent tab experiment"
```

This produces:

- `client-patches/bundles/1.0.0/client/*.MPQ`
- `client-patches/bundles/1.0.0/server/server-data.tar.gz`
- `client-patches/bundles/1.0.0/manifest.json` (copied to `client-patches/manifest.json`)

Commit **`manifest.json` only**. Do not commit `bundles/`, MPQs, or extracted server data — those belong on the VPS.

## Publishing to the VPS

From your dev machine:

```bash
VPS_HOST=acore@your.vps \
client-patches/scripts/publish-to-vps.sh client-patches/bundles/1.0.0
```

On the VPS directly:

```bash
apps/deploy/debian12/client-patches/publish-client-patches.sh client-patches/bundles/1.0.0
```

This stores the release under `/home/acore/client-patches/releases/<version>/` and updates the `current` symlink. This directory is the **single source of truth** for patch binaries.

### Optional HTTP downloads

To let `update-client.sh` use HTTP instead of SCP, serve `/home/acore/client-patches/current` with nginx or Caddy and set:

```bash
PATCHES_BASE_URL=https://your.domain/client-patches/current
```

## Deploying server data

### GitHub Actions (recommended)

1. Publish the bundle to the VPS (above).
2. Run **Actions → deploy-client-patches**.
3. Choose **live** or **test**, optionally pin a **version**, then run.

The workflow applies the server data overlay, sets `ClientCacheVersion` in `worldserver.conf`, and restarts worldserver.

### Manual (on VPS)

```bash
ACORE_PREFIX=/home/acore/server \
apps/deploy/debian12/client-patches/apply-server-data.sh 1.0.0
/home/acore/deploy/restart-acore.sh restart live
```

For test:

```bash
ACORE_PREFIX=/home/acore/server-test \
apps/deploy/debian12/client-patches/apply-server-data.sh 1.0.0
/home/acore/deploy/restart-acore.sh restart test
```

`apply-server-data.sh`:

- Verifies checksums from `manifest.json`
- Extracts `server-data.tar.gz` as an **overlay** into `<prefix>/data/` (does not wipe existing data)
- Sets `ClientCacheVersion` so clients refresh cached DBC data
- Records the applied version in `etc/.client-patch-version`

## Player client updates

```bash
WOW_DIR=/path/to/ChromieCraft \
FROM_VPS=acore@your.vps \
client-patches/scripts/update-client.sh
```

Or over HTTP:

```bash
WOW_DIR=/path/to/ChromieCraft \
PATCHES_BASE_URL=https://your.domain/client-patches/current \
client-patches/scripts/update-client.sh
```

The script:

1. Downloads `manifest.json` and client MPQs
2. Verifies SHA-256 checksums
3. Installs MPQs to the paths listed in the manifest (e.g. `Data/enUS/patch-A.MPQ`)
4. Writes `.acore-client-patch-version` in the WoW folder

Players must run this **before** logging in when a new client bundle is required.

## Versioning rules

- Use semver for `manifest.version` (`1.0.0`, `1.1.0`, …).
- Increment `client_cache_version` whenever DBC data changes (build-bundle does this automatically).
- Keep `blizzard_build` at `12340` for WotLK 3.3.5a unless you ship a custom client executable.
- Server code deploys (`deploy-vps`) and client patch deploys (`deploy-client-patches`) are independent, but **DBC/map releases should be deployed together**.

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
| Client sees wrong talents / map | Player ran `update-client.sh`? `ClientCacheVersion` bumped? |
| Server won't load map | `sources/server/maps` included in bundle? Extracted for correct map ID? |
| `validate-manifest.sh` fails | Re-run `build-bundle.sh`; checksums must match files |
| Release already exists on VPS | Publish a new version or remove old `releases/<version>/` |

## Related server docs

- [`apps/deploy/README.md`](../apps/deploy/README.md) — server binary deploy
- [`apps/deploy/debian12/bootstrap.md`](../apps/deploy/debian12/bootstrap.md) — VPS setup
- [`apps/deploy/debian12/MULTI-REALM.md`](../apps/deploy/debian12/MULTI-REALM.md) — live vs test realms
