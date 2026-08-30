# Build runner pool (local PC + VPS)

Both machines register with label **`acore-build`**. GitHub assigns the compile job to any
online idle runner with that label.

- **Local PC** → fast compile check only (artifacts under `~/.cache/azerothcore/`)
- **VPS** (`acore-vps` label) → stages **deployable** binaries after a local compile, or builds directly when the VPS takes the compile job

Local PC binaries **cannot** be deployed to Debian 12 (glibc/Boost mismatch). Never rsync them.

Deploy (`deploy-vps`, including auto test deploy) always runs on **`acore-vps`** only.

## Labels

| Runner | Required labels | Role |
|--------|-----------------|------|
| Local PC | `self-hosted`, `linux`, `X64`, `acore-build` | compile pool |
| VPS | `self-hosted`, `linux`, `acore-vps`, **`acore-build`** | compile pool + deploy |

Add `acore-build` to the existing VPS runner: **Settings → Actions → Runners → your VPS runner → Add label `acore-build`**.

## Install local runner

```bash
export RUNNER_TOKEN='...'   # registration token from GitHub
bash apps/deploy/debian12/install-local-runner.sh
cd ~/actions-runner && ./svc.sh install && ./svc.sh start
```

## GitHub secret (required for local builds)

Repo **Settings → Secrets → Actions**:

| Secret | Value |
|--------|--------|
| `VPS_RUNNER_SSH_KEY` | Private SSH key for VPS rsync (dedicated key recommended) |

Repo **variable** or **secret** (required for local builds):

| Name | Value |
|------|--------|
| `VPS_SSH_HOST` | SSH target (`user@host`) |

## When both runners are online

GitHub may assign the **compile** job to either machine. If your PC compiles first, a
**stage-on-vps** job still runs on the VPS to produce deployable binaries.

If you want **only VPS builds** (no duplicate compile), stop the local runner while developing,
or stop the VPS `acore-build` listener while the PC is on for compile-only feedback.

## Local output paths

All under **`~/.cache/azerothcore/`**:

| Branch | Staging | Build tree | Prefix (CONF_DIR) |
|--------|---------|------------|-------------------|
| `Playerbot` | `staging/` | `build/live/` | `prefix-live/` |
| `dev` | `staging-test/` | `build/test/` | `prefix-test/` |

Safe to delete old leftovers in `$HOME` if you still have
`azerothcore-staging*`, `azerothcore-build/`, or `azerothcore-prefix-*`.
