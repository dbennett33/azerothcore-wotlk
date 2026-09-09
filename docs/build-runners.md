# Build runners (Debian 12 VM + VPS)

Compiles run on your **Debian 12 build VM** when it is online; otherwise on the **VPS**.
Deploy always runs on the VPS (`acore-vps`).

## Labels

| Runner | Labels | Role |
|--------|--------|------|
| Debian build VM | `self-hosted`, `linux`, `X64`, **`acore-build-vm`** | fast compile when VM is on |
| VPS | `self-hosted`, `linux`, **`acore-vps`** | compile fallback + deploy |

Do **not** put `acore-build` on both machines. The workflow picks the target before compile:

1. `pick-runner` (GitHub-hosted) lists runners and **fails** if neither is online (does not queue forever)
2. If `acore-build-vm` is online → `compile-and-stage` runs on the VM, then rsyncs staging to the VPS
3. Else if `acore-vps` is online → compile on the VPS
4. `dev` then checks that `acore-vps` is still online before queueing `deploy-test`

Optional repo **variable** `BUILD_VM_RUNNER_LABEL` if you use a different VM label
(default `acore-build-vm`).

Repo **secret** `ACORE_WORKFLOW_PAT` (classic PAT with `repo` scope, or fine-grained with Actions
read on this repo) lets `pick-runner` list self-hosted runner status. Without it the picker
**fails** instead of guessing.

## Install build VM runner

```bash
export RUNNER_TOKEN='...'
bash apps/deploy/debian12/install-build-vm-runner.sh
cd ~/actions-runner && sudo ./svc.sh install dan && sudo ./svc.sh start
```

Or add label **`acore-build-vm`** to an existing runner in GitHub → Settings → Actions → Runners.

## VPS runner

Keep **`acore-vps`** only (remove `acore-build` if still present). Compile falls back here when
the VM is offline.

If **promote-test** or compile sits in `queued` for more than a minute, the VPS runner is offline.
Staging from a VM compile is already on the VPS; start the runner so the queued job can pick up
(or run **Actions → deploy-vps → test**):

```bash
# SSH as debian
sudo -u acore bash -lc 'cd /home/acore/actions-runner && ./svc.sh status'
sudo -u acore bash -lc 'cd /home/acore/actions-runner && ./svc.sh start'
```

GitHub → Settings → Actions → Runners should show `vps-…` as **Idle** (not Offline).

## Bootstrap Debian 12 VM

```bash
sudo bash apps/deploy/debian12/bootstrap-build-vm.sh
```

## Secrets (rsync from VM to VPS)

| Name | Purpose |
|------|---------|
| `VPS_RUNNER_SSH_KEY` | SSH key for rsync staging to VPS |
| `VPS_SSH_HOST` | SSH target (variable or secret) |

## Local output paths (build VM)

Under **`~/.cache/azerothcore/`**:

| Branch | Staging | Build tree |
|--------|---------|------------|
| `Playerbot` | `staging/` | `build/live/` |
| `dev` | `staging-test/` | `build/test/` |
