# Client patches

Versioned MPQ patches for players and matching server data overlays (maps, vmaps, mmaps, DBC) for AzerothCore.

## Storage policy

| What | Git | VPS (`/home/acore/client-patches/`) |
|------|-----|-------------------------------------|
| `manifest.json` (version, checksums, changelog) | Yes | Copy of each release |
| MPQ files, server data tarballs | **No** | **Yes — canonical store** |
| `sources/` on your dev machine | Local staging only (gitignored binaries) | — |

**All patch binaries live on the VPS.** Git tracks only the manifest so you know what was released. Back up `/home/acore/client-patches/` offsite regularly (see [`docs/recovery.md`](../docs/recovery.md)).

## Quick links

- Full guide: [`docs/client-patches.md`](../docs/client-patches.md)
- Manifest (tracked in git): [`manifest.json`](manifest.json)
- Local staging: [`sources/`](sources/) (MPQs and server data are gitignored)
- Build output (local, gitignored): `bundles/<version>/`

## Typical workflow

```bash
# 1. Stage on your dev machine (not committed to git)
#    sources/client/mpq/patch-4.MPQ
#    sources/client/mpq/patch-enUS-4.MPQ   # only if DBCs changed
#    sources/server/{dbc,maps,vmaps,mmaps}/

# 2. Build a release bundle locally
client-patches/scripts/build-bundle.sh 1.0.0 --changelog "First custom area"
# Windows: .\client-patches\scripts\build-bundle.ps1 1.0.0 -Changelog 'First custom area'

# 3. Publish binaries to the VPS store (does not apply to Live or Test)
VPS_HOST=debian@your.vps client-patches/scripts/publish-to-vps.sh client-patches/bundles/1.0.0
# Windows: .\client-patches\scripts\publish-to-vps.ps1 -BundleDir .\client-patches\bundles\1.0.0 -VpsHost debian@your.vps

# 4. Commit manifest.json with the matching C++/SQL
git add client-patches/manifest.json
git commit -m "chore(ClientPatches): release 1.0.0 manifest"

# 5. Push the branch that owns the realm
#    git push origin dev         → vps-build auto-deploys Test (SQL + overlay)
#    merge to Playerbot          → vps-build; then Actions → deploy-vps → live
# 6. Players update the version that realm deployed:
#    client-patches/scripts/update-client.sh --from-vps debian@your.vps --target test
#    Windows: .\client-patches\scripts\update-client.ps1 -WowDir C:\Games\ChromieCraft -FromVps debian@your.vps -Target test
```

## VPS storage layout

```
/home/acore/client-patches/
  releases/<version>/
    manifest.json
    client/*.MPQ
    server/server-data.tar.gz
  current -> releases/<version>          # latest published (not necessarily deployed)
  current-test -> releases/<version>     # last overlay applied to Test
  current-live -> releases/<version>     # last overlay applied to Live
```

## Scripts

| Script | Where | Purpose |
|--------|-------|---------|
| `scripts/build-bundle.sh` / `.ps1` | dev machine | Build bundle from local `sources/` staging |
| `scripts/update-client.sh` / `.ps1` | player PC | Install client MPQs from VPS (`--target test` / `--target live`) |
| `scripts/extract-server-data.sh` | dev machine | Run AC extractors into `sources/server/` (Linux) |
| `scripts/publish-to-vps.sh` / `.ps1` | dev machine | Upload bundle + publish on VPS |
| `apps/deploy/debian12/client-patches/apply-server-data.sh` | VPS | Overlay server data + bump cache version (**called by deploy-vps**) |
| `apps/deploy/debian12/client-patches/publish-client-patches.sh` | VPS | Move bundle into canonical store |
| `apps/deploy/debian12/backup-client-patches.sh` | VPS | Offsite backup of patch releases |
