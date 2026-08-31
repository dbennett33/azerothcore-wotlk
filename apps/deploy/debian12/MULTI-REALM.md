# Live + test on one VPS (shared auth)

One **authserver** (port **3724**). Two **worldservers** on different branches:

| | Branch | Prefix | Staging | Realm | World port | Client name |
|---|--------|--------|---------|-------|------------|-------------|
| **Live** | `Playerbot` | `/home/acore/server` | `server-staging` | 1 | 8085 | Live |
| **Test** | `dev` | `/home/acore/server-test` | `server-staging-test` | 2 | 8086 | Test |

Players use the **same accounts** (`acore_auth`). Characters and world data are **separate per realm** (different MySQL DBs).

## CI flow

```
dev  → PR → Playerbot   (no direct push to Playerbot)

push Playerbot  → vps-build  → server-staging        (no deploy)
push dev        → vps-build  → server-staging-test → auto deploy test realm

manual deploy-vps (target=live)  → promote staging → server + restart auth + world
```

`vps-build` checks out your **mod-playerbots** fork (`master` on `Playerbot`, `dev` on `dev`).
Override with repo variable `MOD_PLAYERBOTS_REPO` if the module lives under another owner.
Module-only changes: push to `mod-playerbots` triggers `vps-build` via `ACORE_WORKFLOW_PAT` (see `.github/BRANCHING.md`).

Builds use isolated cmake trees: `/home/acore/build/live` and `/home/acore/build/test`.

Each world binary is compiled with `CONF_DIR` pointing at **its** `etc/` (see `vps-build` action).

## MySQL (one-time)

Shared auth:

- `acore_auth`

Live (`RealmID = 1` in `worldserver.conf`):

- `acore_characters`, `acore_world`, `acore_playerbots`

Test (`RealmID = 2`):

- `acore_characters_test`, `acore_world_test`, `acore_playerbots_test`

Create test DBs (same user/password as live):

```sql
CREATE DATABASE acore_characters_test DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE acore_world_test DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE acore_playerbots_test DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
GRANT ALL ON acore_characters_test.* TO 'acore'@'localhost';
GRANT ALL ON acore_world_test.* TO 'acore'@'localhost';
GRANT ALL ON acore_playerbots_test.* TO 'acore'@'localhost';
FLUSH PRIVILEGES;
```

First start of each worldserver applies SQL updates to its DBs automatically.

## Host layout

```text
/home/acore/server/           live bin, etc, logs, data (auth + world live)
/home/acore/server-test/      test bin, etc, logs, data (world only)
/home/acore/build/live|test/  persistent cmake build dirs
```

`init-test-prefix.sh` creates **separate** `server-test/data/` (not a symlink). On first run it
`rsync`s from live so test starts with the same maps/dbc/vmaps; after that each prefix owns its
own files. Re-copy live data into test: `FORCE_DATA_SYNC=1 bash init-test-prefix.sh`.

Run once after live exists:

```bash
bash /home/acore/deploy/init-test-prefix.sh
```

## systemd units

| Unit | Binary | Config |
|------|--------|--------|
| `auth.service` | `server/bin/authserver` | `server/etc/authserver.conf` |
| `world.service` | `server/bin/worldserver` | `server/etc/worldserver.conf` |
| `world-test.service` | `server-test/bin/worldserver` | `server-test/etc/worldserver.conf` |

```bash
bash /home/acore/deploy/setup-systemd-units.sh
/home/acore/deploy/restart-acore.sh start    # auth + both worlds
/home/acore/deploy/restart-acore.sh restart test
```

## Client

Realmlist at login shows **Live** and **Test** (same host IP, ports 8085 / 8086). ChromieCraft: set realmlist to server IP; pick realm at character screen.

## Deploy / restart

`deploy-vps` and `restart-acore.sh` **gracefully stop worldserver** (SIGTERM to the
`worldserver` process, wait up to 120s for saves) before `systemctl stop`. That avoids
rollback from killing the bash/run-engine wrapper only.

If you stop manually, use:

```bash
ACORE_PREFIX=/home/acore/server /home/acore/deploy/graceful-stop-world.sh
# or for test:
ACORE_PREFIX=/home/acore/server-test /home/acore/deploy/graceful-stop-world.sh
```

**Player saves:** default `PlayerSaveInterval = 900000` (15 minutes). Even with a clean
shutdown you only lose progress since the last periodic save if shutdown fails. For less
rollback on crashes, lower it in `worldserver.conf` (e.g. `300000` = 5 min).

`configure-realm.sh` runs on **both** deploys (WotLK defaults; live vs test bot counts differ by RealmID).

## Backups

Extend `backup-acore.sh` later to dump test DBs, or run a second backup with `CHARACTER_DB`/`WORLD_DB` env vars. Live backup remains the priority.
