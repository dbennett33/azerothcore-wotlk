# Disaster recovery

If the VPS is lost, you can rebuild from **git + one offsite backup** + client data.

## What lives in git (push `Playerbot` branch)

| Item | Location |
|------|----------|
| Build & deploy pipelines | `.github/workflows/vps-build.yml`, `deploy-vps.yml` |
| WotLK tier-13 gameplay settings (re-applied every deploy) | `configure-realm.sh` |
| Bootstrap / units / restart | `bootstrap.md`, `setup-systemd-units.sh`, `restart-acore.sh` |
| Backup & restore scripts | `backup-acore.sh`, `restore-acore.sh` |

After deploy, **WotLK tier-13 settings** (expansion 2, cap 80, IP tier 13 start/limit, DK enabled,
SOAP on localhost, 1000 live bots with ~10% at 80, etc.) are enforced from `configure-realm.sh` —
you do not need to remember every knob.

## What is **not** in git (must backup or redo once)

| Item | Size | Notes |
|------|------|--------|
| **MySQL** (characters, bots, progress) | Medium | `backup-acore.sh` |
| **Live `etc/`** (DB passwords in DSN, any custom edits) | Small | `backup-acore.sh` |
| **run-engine service configs** | Tiny | `backup-acore.sh` |
| **Client data** (`data/maps`, `vmaps`, `mmaps`, base `dbc`) | Large | Re-download once per [bootstrap §4](bootstrap.md); optional `INCLUDE_DATA_DBC=1` for patched `dbc/` |
| **GitHub Actions runner** | — | Re-register runner on new VPS |
| **Binaries** | — | Rebuild via `vps-build` or restore from staging |

## Routine backup (on VPS)

```bash
# Once: copy example and set the real MySQL password
cp /home/acore/src/azerothcore-wotlk/apps/deploy/debian12/.acore-backup.env.example \
  /home/acore/.acore-backup.env
chmod 600 /home/acore/.acore-backup.env
# edit MYSQL_PASS

# Snapshot (as acore)
bash /home/acore/deploy/backup-acore.sh

# Optional: include server DBC overrides (Map.dbc, Spell.dbc, …)
INCLUDE_DATA_DBC=1 bash /home/acore/deploy/backup-acore.sh
```

Output: `/home/acore/backups/acore-backup-<timestamp>.tar.gz` — **copy off the server** (rsync, S3, etc.).

Suggested schedule: daily or before each `deploy-vps`.

## Restore on a fresh VPS

1. Follow [bootstrap.md](bootstrap.md) §1–4 (user, packages, MySQL empty DBs, **client data**).
2. Copy `.acore-backup.env` and your latest `acore-backup-*.tar.gz` to the new host.
3. Register GitHub Actions self-hosted runner (§7).
4. Push/merge to `Playerbot` and wait for **vps-build** (or restore `server-staging/bin` from backup if you kept one).
5. As `acore`:

   ```bash
   bash /home/acore/deploy/restore-acore.sh /path/to/acore-backup-....tar.gz
   ```

6. GitHub **Actions → deploy-vps** (installs bin from staging, runs configure + optional patches).
7. `setup-systemd-units.sh` + `restart-acore.sh start` if units are new (§6).

## What deploy does **not** wipe

- Restored `etc/` stays until you replace it; deploy only adds missing files from staging `etc/` (`rsync --ignore-existing`).
- `configure-realm.sh` updates **listed keys only** (WotLK tier 13 + bot policy).
- `data/`, MySQL, and optional-patch marker survive deploy when already present.

## Secrets

- Do **not** commit `/home/acore/.acore-backup.env` or live `etc/` with real passwords.
- Keep `.acore-backup.env` next to your offsite backups (password manager, encrypted storage).
