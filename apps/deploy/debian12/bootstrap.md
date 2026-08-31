# Debian 12 VPS bootstrap (AzerothCore)

One-time setup. Do **not** put MySQL install or package setup in GitHub Actions.
The deploy workflow ([`.github/workflows/deploy-vps.yml`](../../../.github/workflows/deploy-vps.yml))
only builds, swaps `bin/`, and restarts systemd user units.

**Self-hosted runner security:** `vps-build` runs on **push to `Playerbot` or `dev`** (not on
pull requests). `deploy-vps` is **`workflow_dispatch`** with target **live** or **test**. Fork PRs
never touch the VPS runner. Use branch protection on deploy branches so only you merge deployable commits.

Paths used below (keep in sync with the workflows):

- User: `acore`
- **Live** (`Playerbot`): prefix `/home/acore/server`, staging `/home/acore/server-staging`, build `/home/acore/build/live`
- **Test** (`dev`): prefix `/home/acore/server-test`, staging `/home/acore/server-staging-test`, build `/home/acore/build/test`
- Client data: separate `server/data` and `server-test/data` (test copies from live on first init)
- systemd user units: `auth.service`, `world.service`, `world-test.service`

For live + test on one VPS (shared auth, separate world DBs), see [`MULTI-REALM.md`](MULTI-REALM.md).

You need roughly **8 GB RAM** (plus swap) to compile on this machine.

**Shortcut:** on a fresh VPS, clone this repo and run as root:

```bash
sudo bash apps/deploy/debian12/bootstrap.sh
```

That covers sections 1–2 and `loginctl enable-linger`. MySQL `deb` install may still need
attention if `dpkg` reports configuration errors — see section 3.

## 1. User and directories

```bash
sudo adduser --disabled-password --gecos "" acore
sudo mkdir -p /home/acore/server/{bin,etc,data,logs} /home/acore/server-staging
sudo chown -R acore:acore /home/acore/server /home/acore/server-staging
```

## 2. Build and runtime packages

Same set as [`apps/installer/includes/os_configs/debian.sh`](../../installer/includes/os_configs/debian.sh),
plus `rsync` for deploys.

```bash
sudo apt-get update -y
sudo apt-get install -y lsb-release gdbserver gdb unzip curl \
  libncurses-dev libreadline-dev clang g++ gcc git cmake make ccache \
  libssl-dev libbz2-dev libboost-all-dev gnupg wget jq screen tmux expect rsync
```

## 3. MySQL 8 (Oracle apt, matching debian.sh)

```bash
MYSQL_APT_CONFIG_VERSION=0.8.36-1
wget "https://dev.mysql.com/get/mysql-apt-config_${MYSQL_APT_CONFIG_VERSION}_all.deb"
sudo DEBIAN_FRONTEND=noninteractive dpkg -i "./mysql-apt-config_${MYSQL_APT_CONFIG_VERSION}_all.deb"
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-server libmysqlclient-dev
rm -f "./mysql-apt-config_${MYSQL_APT_CONFIG_VERSION}_all.deb"
sudo systemctl enable --now mysql
```

Create empty databases and a dedicated user (change the password):

```sql
CREATE DATABASE acore_auth DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE acore_characters DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE acore_world DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE acore_playerbots DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'acore'@'localhost' IDENTIFIED BY 'CHANGE_ME';
GRANT ALL PRIVILEGES ON acore_auth.* TO 'acore'@'localhost';
GRANT ALL PRIVILEGES ON acore_characters.* TO 'acore'@'localhost';
GRANT ALL PRIVILEGES ON acore_world.* TO 'acore'@'localhost';
GRANT ALL PRIVILEGES ON acore_playerbots.* TO 'acore'@'localhost';
FLUSH PRIVILEGES;
```

First successful auth/world start applies SQL updates automatically. Take a dump before later
deploys that include schema changes.

## 4. Client data (once)

Copy maps, dbc, vmaps, and mmaps into `/home/acore/server/data`. Do **not** download this in CI.

```bash
sudo chown -R acore:acore /home/acore/server/data
```

## 5. Config files (once, never overwritten by deploy)

After the first `cmake --install` (or the first GitHub deploy), copy dist configs if missing:

```bash
# as acore, after bin/etc exist under the live prefix
for dist in /home/acore/server/etc/*.conf.dist; do
  conf="${dist%.dist}"
  if [ ! -f "$conf" ]; then
    cp -v "$dist" "$conf"
  fi
done
for dist in /home/acore/server/etc/modules/*.conf.dist; do
  conf="${dist%.dist}"
  if [ ! -f "$conf" ]; then
    cp -v "$dist" "$conf"
  fi
done
```

Edit `/home/acore/server/etc/authserver.conf` and `worldserver.conf`:

- `LoginDatabaseInfo` / `WorldDatabaseInfo` / `CharacterDatabaseInfo` — MySQL DSN
  (`127.0.0.1;3306;acore;CHANGE_ME;acore_auth` and the matching DB names)
- `DataDir = "/home/acore/server/data"`
- `LogsDir = "/home/acore/server/logs"`

**Playerbots** (this branch builds with `mod-playerbots`):

- `PlayerbotsDatabaseInfo` lives in `/home/acore/server/etc/modules/playerbots.conf`
  (copy from `playerbots.conf.dist`; defaults to `acore_playerbots`).
- Binaries load module configs from the **live** `etc/` path (`CONF_DIR` is set at
  compile time to `/home/acore/server/etc` in `vps-build`, not staging).
- First world start populates `acore_playerbots` from SQL updates automatically.

The deploy job rsyncs **`bin/` only**. It will not replace these files.

## 6. systemd user units (after binaries exist)

Enable lingering so user units survive logout and work under the Actions runner:

```bash
sudo loginctl enable-linger acore
```

After `/home/acore/server/bin/authserver` and `worldserver` exist (first deploy or a local
install), as `acore`, from a source checkout that still has `apps/startup-scripts` **or** from
the installed `bin/` scripts:

```bash
# Example using scripts from a git checkout:
cd /path/to/azerothcore-wotlk
/home/acore/deploy/setup-systemd-units.sh

# Or manually (type name, unit name — yields auth.service / world.service):
./apps/startup-scripts/src/service-manager.sh create auth auth \
  --provider systemd --user --restart-policy on-failure \
  --bin-path /home/acore/server/bin \
  --server-config /home/acore/server/etc/authserver.conf \
  --no-start

./apps/startup-scripts/src/service-manager.sh create world world \
  --provider systemd --user --restart-policy on-failure \
  --bin-path /home/acore/server/bin \
  --server-config /home/acore/server/etc/worldserver.conf \
  --no-start
```

Unit names are `auth.service` and `world.service`. Restart order is stop world then auth, start
auth then world — `/home/acore/deploy/restart-acore.sh` (installed by deploy-vps).

## 7. GitHub Actions runner (as `acore`)

Use a **private** repository, or restrict who can run `workflow_dispatch`. A public repo with a
self-hosted runner is unsafe if untrusted workflows can execute.

1. GitHub → repo **Settings** → **Actions** → **Runners** → **New self-hosted runner** → Linux x64.
2. As `acore`, download and configure in e.g. `/home/acore/actions-runner`.
3. Labels: `self-hosted`, `linux`, `acore-vps`, and **`acore-build`** (shared compile pool with local PC).
4. Install the runner as a user service: `./svc.sh install` then `./svc.sh start` (still as `acore`).

Confirm `XDG_RUNTIME_DIR` is `/run/user/<acore-uid>` so `systemctl --user` works in jobs.

## 8. First deploy

On GitHub:

- **Actions** → **vps-build** runs automatically on push to `Playerbot` or `dev`.
- **Actions** → **deploy-vps** → **Run workflow** → choose **live** or **test**.

If units are not created yet, the job still installs `bin/` and skips restart. Then run section 6
and start the services once.

After the first deploy, as `acore`:

```bash
/home/acore/deploy/setup-systemd-units.sh
/home/acore/deploy/restart-acore.sh start
```

The deploy workflow copies helpers to `/home/acore/deploy/` and startup-scripts to
`/home/acore/src/azerothcore/` on each run.

## 9. WotLK realm settings (tier 13)

After deploy, `configure-realm.sh` sets:

- `Expansion = 2`, `MaxPlayerLevel = 80`, `MinDualSpecLevel = 40`
- `mod-individual-progression`: server-wide **tier 13** (WotLK phase 1 — Naxx 80, Eye of Eternity, Obsidian Sanctum)
- Death Knight enabled; dual spec at 40; RDF available; new DKs skip Ebon Hold (`mod-skip-dk-starting-area`)
- Live playerbots: 1000 bots, ~10% at level 80, 90% starting at level 1
- Test playerbots: 50 bots, same level distribution

**Client:** use a clean 3.3.5a client (ChromieCraft). Remove any old `patch-V.mpq` / vanilla MPQ
patches from `Data/` if previously installed.

**Migrating from vanilla progression** (one-time, before first WotLK deploy of each realm):

1. Backup MySQL (`backup-acore.sh` plus test DB dumps).
2. Stop that realm's worldserver, then drop/recreate `acore_world[_test]`,
   `acore_characters[_test]`, and `acore_playerbots[_test]` (leave `acore_auth`).
3. Restore stock WotLK `Map.dbc` (vanilla cutover set Naxxramas expansion to 0).
   Remove `etc/.vanilla-optional-applied`.
4. `UPDATE acore_auth.account SET expansion = 2;`
5. Merge to `dev` (auto-deploys test), then PR `dev` → `Playerbot` and run `deploy-vps` for live.

`mod-individual-progression` stays enabled with tier 13 as both start and cap.
Client: remove `patch-V.mpq` / vanilla MPQ patches from `Data/` if they were installed.

## 10. Backups and disaster recovery

Gameplay tuning is in git (`configure-realm.sh`, deploy workflows). **Secrets,
characters, and full `etc/`** are on the VPS — snapshot them regularly:

```bash
cp apps/deploy/debian12/.acore-backup.env.example /home/acore/.acore-backup.env
# edit MYSQL_PASS, chmod 600
bash /home/acore/deploy/backup-acore.sh
# copy /home/acore/backups/acore-backup-*.tar.gz off the server
```

Full restore procedure: [`RECOVERY.md`](RECOVERY.md).

`deploy-vps` installs `backup-acore.sh` and `restore-acore.sh` to `/home/acore/deploy/` alongside
the other helpers.
