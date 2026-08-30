# Branching and CI (dbennett33/azerothcore-wotlk)

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
