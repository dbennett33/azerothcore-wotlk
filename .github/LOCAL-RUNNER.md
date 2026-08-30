# Build runner pool (local PC + VPS)

Both machines register with label **`acore-build`**. GitHub assigns `vps-build` jobs to any
**online idle** runner with that label:

- **Local PC on** → often builds here (faster), then **rsyncs staging to the VPS**
- **Local off** → VPS builds in place (no rsync)

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
| `VPS_RUNNER_SSH_KEY` | Private key that can `ssh debian@57.128.183.99` (e.g. `~/.ssh/id_ed25519_vps`) |

Optional repo **variable** `VPS_SSH_HOST` (default `debian@57.128.183.99`).

## When both runners are online

GitHub picks whichever idle runner matches — not guaranteed to prefer local. If you always want local while your PC is on, stop the VPS build listener temporarily:

```bash
# on VPS as acore
cd ~/actions-runner && ./svc.sh stop
# start again when PC is off
./svc.sh start
```

## Local output paths

| Branch | Staging on PC |
|--------|----------------|
| `Playerbot` | `~/azerothcore-staging/` |
| `dev` | `~/azerothcore-staging-test/` |

Build trees: `~/azerothcore-build/live` and `~/azerothcore-build/test`.
