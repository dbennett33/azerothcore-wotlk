# Client patches

Versioned MPQ patches for players and matching server data overlays (maps, vmaps, mmaps, DBC) for AzerothCore.

## Quick links

- Full guide: [`docs/client-patches.md`](../docs/client-patches.md)
- Manifest (tracked in git): [`manifest.json`](manifest.json)
- Sources (your edits): [`sources/`](sources/)
- Built bundles (local only, gitignored): `bundles/<version>/`

## Typical workflow

```bash
# 1. Add or edit content
#    - client MPQ files -> sources/client/mpq/
#    - server data        -> sources/server/{dbc,maps,vmaps,mmaps}/

# 2. Build a release bundle
client-patches/scripts/build-bundle.sh 1.0.0 --changelog "First custom area"

# 3. Commit manifest.json (not bundles/)
git add client-patches/manifest.json
git commit -m "chore(ClientPatches): release 1.0.0 manifest"

# 4. Publish binaries to the VPS
VPS_HOST=acore@your.vps client-patches/scripts/publish-to-vps.sh client-patches/bundles/1.0.0

# 5. Deploy server data (GitHub Actions -> deploy-client-patches, or on VPS)
ACORE_PREFIX=/home/acore/server apps/deploy/debian12/client-patches/apply-server-data.sh 1.0.0

# 6. Players update locally
WOW_DIR=/path/to/WoW FROM_VPS=acore@your.vps client-patches/scripts/update-client.sh
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
| `scripts/build-bundle.sh` | dev machine | Build bundle from `sources/` |
| `scripts/update-client.sh` | player PC | Install client MPQs |
| `scripts/extract-server-data.sh` | dev machine | Run AC extractors into `sources/server/` |
| `scripts/publish-to-vps.sh` | dev machine | Upload bundle + publish on VPS |
| `apps/deploy/debian12/client-patches/apply-server-data.sh` | VPS | Overlay server data + bump cache version |
| `apps/deploy/debian12/client-patches/publish-client-patches.sh` | VPS | Move bundle into canonical store |
