# Client patches

Versioned MPQ patches for players and matching server data overlays (maps, vmaps, mmaps, DBC) for AzerothCore.

## Storage policy

| What | Git | VPS (`/home/acore/client-patches/`) |
|------|-----|-------------------------------------|
| `manifest.json` (version, checksums, changelog) | Yes | Copy of each release |
| MPQ files, server data tarballs | **No** | **Yes — canonical store** |
| `sources/` on your dev machine | Local staging only (gitignored binaries) | — |

**All patch binaries live on the VPS.** Git tracks only the manifest so you know what was released. Back up `/home/acore/client-patches/` offsite regularly (see `apps/deploy/debian12/RECOVERY.md`).

## Quick links

- Full guide: [`docs/client-patches.md`](../docs/client-patches.md)
- Manifest (tracked in git): [`manifest.json`](manifest.json)
- Local staging: [`sources/`](sources/) (MPQs and server data are gitignored)
- Build output (local, gitignored): `bundles/<version>/`

## Typical workflow

```bash
# 1. Stage on your dev machine (not committed to git)
#    sources/client/mpq/patch-A.MPQ
#    sources/server/{dbc,maps,vmaps,mmaps}/

# 2. Build a release bundle locally
client-patches/scripts/build-bundle.sh 1.0.0 --changelog "First custom area"

# 3. Publish binaries to the VPS (canonical store)
VPS_HOST=acore@your.vps client-patches/scripts/publish-to-vps.sh client-patches/bundles/1.0.0

# 4. Commit manifest.json only
git add client-patches/manifest.json
git commit -m "chore(ClientPatches): release 1.0.0 manifest"

# 5. Deploy server data (GitHub Actions -> deploy-client-patches)
# 6. Players update: client-patches/scripts/update-client.sh
```

## VPS storage layout

```
/home/acore/client-patches/
  releases/<version>/
    manifest.json
    client/*.MPQ
    server/server-data.tar.gz
  current -> releases/<version>
```

## Scripts

| Script | Where | Purpose |
|--------|-------|---------|
| `scripts/build-bundle.sh` | dev machine | Build bundle from local `sources/` staging |
| `scripts/update-client.sh` | player PC | Install client MPQs from VPS |
| `scripts/extract-server-data.sh` | dev machine | Run AC extractors into `sources/server/` |
| `scripts/publish-to-vps.sh` | dev machine | Upload bundle + publish on VPS |
| `apps/deploy/debian12/client-patches/apply-server-data.sh` | VPS | Overlay server data + bump cache version |
| `apps/deploy/debian12/client-patches/publish-client-patches.sh` | VPS | Move bundle into canonical store |
| `apps/deploy/debian12/backup-client-patches.sh` | VPS | Offsite backup of patch releases |
