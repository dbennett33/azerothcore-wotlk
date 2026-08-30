# Branching and CI

## Branches

| Branch | Role | VPS path | Realm | mod-playerbots ref |
|--------|------|----------|-------|-------------------|
| `Playerbot` | Live / production | `/home/acore/server` | Live (8085) | `master` |
| `dev` | Test / integration | `/home/acore/server-test` | Test (8086) | `dev` |

Work flows **dev → PR → Playerbot**. Do not push directly to `Playerbot`.

## CI (`vps-build`)

| Event | Branch | Build | Deploy |
|-------|--------|-------|--------|
| push | `Playerbot` | yes → `server-staging` | no |
| push | `dev` | yes → `server-staging-test` | yes → test realm |
| `workflow_dispatch` | either | yes | test only if ref is `dev` |

Concurrency: **`Playerbot` builds queue** (running compile is not cancelled). **`dev` builds cancel in progress** (only latest commit matters for test).

Manual live promote: **Actions → deploy-vps → Run workflow → target `live`**
(after a successful `Playerbot` build).

## GitHub branch protection (configure in repo Settings)

**`Playerbot`**

- Require pull request before merging
- Restrict direct pushes
- **Require status check:** `Validate PR source` (from `branch-protection.yml`)

GitHub has no “source branch must be dev” setting; the workflow enforces `dev → Playerbot` only.

**`dev`**

- Allow direct push for day-to-day work, or require PRs from feature branches

## Secret for cross-repo triggers

`mod-playerbots` can re-run this workflow when only the module changes. Add repo secret:

- `ACORE_WORKFLOW_PAT` — fine-scoped PAT with `workflow` scope on this repo

See `mod-playerbots` `.github/BRANCHING.md`.

Optional repo **variable** `MOD_PLAYERBOTS_REPO` if mod-playerbots is not `{owner}/mod-playerbots`.

## Extra modules (compiled on every vps-build)

Checked out by `apps/deploy/debian12/clone-extra-modules.sh`:

| Module | Repo | Notes |
|--------|------|--------|
| `mod-npc-enchanter` | azerothcore/mod-npc-enchanter | Template only; spawn with `.npc add 601015` |
| `mod-npc-services` | azerothcore/mod-npc-services | Template only; spawn with `.npc add 55002` |

World SQL for the NPC modules is applied on worldserver start from `SourceDirectory/modules/` (synced on deploy).

## Deploy player warning (optional)

`deploy-vps` warns players **60 seconds** before stopping worldserver (chat announce + in-game shutdown timer).

Set repo secrets (or `SOAP_USER` / `SOAP_PASS` in `/home/acore/.acore-backup.env` on the VPS):

| Secret | Value |
|--------|--------|
| `ACORE_SOAP_USER` | In-game GM account name (Administrator / GM level 3) |
| `ACORE_SOAP_PASS` | That account's password |

Without SOAP credentials, deploy still waits 60 seconds before stopping.
