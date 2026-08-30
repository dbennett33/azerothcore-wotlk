# Deploy

| Path | Purpose |
|------|---------|
| [`debian12/bootstrap.md`](debian12/bootstrap.md) | One-time VPS setup (MySQL, data, configs, runner) |
| [`debian12/bootstrap.sh`](debian12/bootstrap.sh) | Automated host prep (packages, user, MySQL apt, linger) |
| [`debian12/restart-acore.sh`](debian12/restart-acore.sh) | Stop/start `auth.service` / `world.service` |
| [`debian12/setup-systemd-units.sh`](debian12/setup-systemd-units.sh) | Create units after first binary install |
| [`.github/workflows/vps-build.yml`](../../.github/workflows/vps-build.yml) | **Push to `Playerbot`** → compile to `server-staging` + GitHub artifact |
| [`.github/workflows/deploy-vps.yml`](../../.github/workflows/deploy-vps.yml) | **Manual** → promote staging to live and restart |

**CI flow:** merge to `Playerbot` runs `vps-build` (no PR builds). When ready, run `deploy-vps` manually.

**Order:** bootstrap → register runner → merge triggers `vps-build` → `deploy-vps` → `setup-systemd-units.sh` → start services.
