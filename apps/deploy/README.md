# Deploy

| Path | Purpose |
|------|---------|
| [`debian12/bootstrap.md`](debian12/bootstrap.md) | One-time VPS setup (MySQL, data, configs, runner) |
| [`debian12/bootstrap.sh`](debian12/bootstrap.sh) | Automated host prep (packages, user, MySQL apt, linger) |
| [`debian12/restart-acore.sh`](debian12/restart-acore.sh) | Stop/start `auth.service` / `world.service` |
| [`debian12/setup-systemd-units.sh`](debian12/setup-systemd-units.sh) | Create units after first binary install |
| [`debian12/backup-acore.sh`](debian12/backup-acore.sh) | Offsite snapshot: `etc/`, MySQL, run-engine configs |
| [`debian12/restore-acore.sh`](debian12/restore-acore.sh) | Restore snapshot on a fresh VPS |
| [`debian12/RECOVERY.md`](debian12/RECOVERY.md) | Disaster recovery checklist |
| [`../../docs/client-patches.md`](../../docs/client-patches.md) | MPQ + server data patch workflow |
| [`debian12/client-patches/`](debian12/client-patches/) | VPS helpers to publish/apply client patch bundles |
| [`.github/workflows/vps-build.yml`](../../.github/workflows/vps-build.yml) | **Push to `Playerbot`** → compile to `server-staging` on the VPS (no GitHub artifacts) |
| [`.github/workflows/deploy-vps.yml`](../../.github/workflows/deploy-vps.yml) | **Manual** → promote staging to live and restart |
| [`.github/workflows/deploy-client-patches.yml`](../../.github/workflows/deploy-client-patches.yml) | **Manual** → apply client patch server data to live/test |

**CI flow:** merge to `Playerbot` runs `vps-build` (no PR builds). When ready, run `deploy-vps` manually.

**Order:** bootstrap → register runner → merge triggers `vps-build` → `deploy-vps` → `setup-systemd-units.sh` → start services.

**Backups:** see [`debian12/RECOVERY.md`](debian12/RECOVERY.md). Run `backup-acore.sh` regularly and store the tarball off the VPS.
