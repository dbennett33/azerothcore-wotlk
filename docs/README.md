# This fork's documentation

Everything written **for this fork** — the live/test VPS, the CI, the client-patch pipeline, the
custom content (The Waxworks, Stormwind Vault, and what comes after), and the agent skills that
do the work — is indexed here. Upstream AzerothCore docs are not: they live on
[the wiki](https://www.azerothcore.org/wiki/) and in `doc/`.

Human prose lives in this directory. Two kinds of files stay where their tooling needs them and
are only linked from here: agent docs and skills under `.agents/` (routed by `AGENTS.md`, symlinked
from `.claude/skills/`), and one-screen `README.md` files next to the scripts they describe.

## The fork in one screen

| | |
|---|---|
| What | Private AzerothCore 3.3.5a fork: one live realm and one test realm on a Debian 12 VPS, mod-playerbots compiled in, mod-individual-progression pinned to tier 13 (WotLK phase 1), custom client patches, custom 5-mans The Waxworks (map 44) and Stormwind Vault (map 35). |
| Branches | `dev` → test realm (auto build + deploy on push). `Playerbot` → live (build on push, **manual** `deploy-vps` target `live`). Flow `dev → PR → Playerbot`; `branch-protection.yml` rejects any other PR source. |
| Host | User `acore`. Live prefix `/home/acore/server` (realm 1, port 8085), test `/home/acore/server-test` (realm 2, port 8086), one authserver on 3724. systemd user units `auth`, `world`, `world-test`. Patch store `/home/acore/client-patches/`. |
| CI | `vps-build` compiles on the Debian build VM when online, else on the VPS; `deploy-vps` promotes staging, applies SQL, overlays client-patch server data, restarts. Runner labels `acore-build-vm` / `acore-vps`. |
| Custom content | Regular trees, not `Custom/` or `modules/`: `src/server/scripts/EasternKingdoms/{Waxworks,StormwindVault}/`, `data/sql/updates/pending_db_world/`, ids `9000000+` (registry in `.agents/docs/systems/dungeons.md`). |
| Client patches | Custom world files in `Data/patch-4.MPQ`, DBCs in `Data/enUS/patch-enUS-4.MPQ` (MPQ v2, never past `patch-5`). Server gets the same change as `data/` files or `*_dbc` SQL. Only `client-patches/manifest.json` is in git. |
| Tooling split | Mesh/DBC/MPQ/extraction/visual checks on a Windows dev box; publish and deploy from any shell; the VPS has no extractors. |
| Agents | `AGENTS.md` § "This fork" is loaded automatically by Cursor, Claude Code (`CLAUDE.md`), Copilot and Codex and routes here. Skills live in `.agents/skills/`. |

## Start here

| Read this | When |
|---|---|
| [`custom-content.md`](custom-content.md) | You want the big picture of how the 3.3.5a client and the server are changed together: dungeons, talents, terrain, MPQs, Windows vs Linux, and whether more dungeons can be built after Stormwind Vault (yes, with a new `Map.dbc` id; see §3). |
| [`branching.md`](branching.md) | You are about to push or merge. Branch roles (`dev` = test realm, `Playerbot` = live), what CI runs on each, branch protection, the cross-repo PAT. |
| [`multi-realm.md`](multi-realm.md) | You need to know how live and test share one VPS (one authserver, two worldservers, ports, DBs, units). |

## Server, deploy, and CI

| Doc | Contents |
|---|---|
| [`vps-bootstrap.md`](vps-bootstrap.md) | One-time Debian 12 VPS setup: user, packages, MySQL 8, client data, configs, systemd user units, Actions runner, first deploy, tier-13 realm settings, backups. |
| [`multi-realm.md`](multi-realm.md) | Live + test on one host: CI flow, MySQL per realm, host layout, units, client realmlist, deploy/restart, backups. |
| [`recovery.md`](recovery.md) | Disaster recovery: what is in git, what must be backed up (`backup-acore.sh`, `backup-client-patches.sh`), restore order on a fresh VPS. |
| [`branching.md`](branching.md) | Branches and CI triggers, concurrency, branch protection, `ACORE_WORKFLOW_PAT`, extra modules compiled on every build, optional deploy warning. |
| [`build-runners.md`](build-runners.md) | Self-hosted runners: the Debian build VM (`acore-build-vm`) versus the VPS (`acore-vps`), how `pick-runner` chooses, installing either runner, rsync secrets. |
| [`../apps/deploy/README.md`](../apps/deploy/README.md) | Script-by-script table for `apps/deploy/debian12/` (bootstrap, restart, units, backup/restore, promote, client-patch helpers). |

Workflows added by this fork (`.github/workflows/`):

| Workflow | Trigger | Does |
|---|---|---|
| `vps-build.yml` | push to `Playerbot` or `dev`; manual | Compile on the build VM if online, else on the VPS (`.github/actions/vps-build`); stage to `server-staging[-test]`; `dev` auto-deploys the test realm. |
| `deploy-vps.yml` | manual (`live`/`test`); called by `vps-build` | Promote staging → prefix, apply SQL `SourceDirectory`, overlay the commit's client-patch server data, point `current-test`/`current-live`, restart units. |
| `deploy-client-patches.yml` | manual, emergency only | Apply a client-patch store release without a code deploy. |
| `branch-protection.yml` | PRs to `Playerbot` | Fails any PR whose head branch is not `dev`. |
| `core-build.yml`, `core-build-playerbots.yml` | push/PR to `Playerbot`, `test-staging` | GitHub-hosted Ubuntu compile checks; the second also checks out `mod-playerbots` (`master` for `Playerbot`, else `test-staging`). |

## Custom content and client patches

| Doc | Contents |
|---|---|
| [`custom-content.md`](custom-content.md) | The client–server data contract; The Waxworks case study (what repeats, what was a shortcut); Stormwind Vault; the path for dungeon #3+ (new `Map.dbc`, no leftover scrap); talents; terrain; MPQ/extractor facts; release pipeline; Windows vs Linux matrix; known gaps. |
| [`client-patches.md`](client-patches.md) | The release mechanics: `manifest.json`, `sources/`, bundles, `publish-to-vps`, `apply-server-data.sh`, `update-client.*`, CI hooks, backups. |
| [`../client-patches/README.md`](../client-patches/README.md) | Quick start for the `client-patches/` directory and storage policy (binaries on the VPS, manifest in git). |

Shipped content:

| Item | Where |
|---|---|
| The Waxworks (map 44, 5-man, Elwynn entrance) | C++ `src/server/scripts/EasternKingdoms/Waxworks/`; SQL `data/sql/updates/pending_db_world/rev_1788471101263218298.sql`; client `Data/patch-4.MPQ` v1.0.1 per `client-patches/manifest.json` |
| Stormwind Vault (map 35, 5-man, Stormwind canal swirl) | C++ `src/server/scripts/EasternKingdoms/StormwindVault/`; SQL `data/sql/updates/pending_db_world/rev_1788517208810518529.sql`; uses the unused vanilla `StormwindPrison` WMO (no new MPQ) |
| Custom id blocks (`9000000+`) | Registry table in [`../.agents/docs/systems/dungeons.md`](../.agents/docs/systems/dungeons.md) — reserve before writing SQL |

## Agent docs (`.agents/docs/systems/`, fork-specific)

Compact models and hard rules an agent must read before touching the subsystem. `AGENTS.md`
routes to them; they assume the reader will then follow a skill.

| Doc | Subsystem |
|---|---|
| [`client-data.md`](../.agents/docs/systems/client-data.md) | Client MPQ vs server `data/`: load order, what each extractor actually opens (`patch-5` cap, locale-only DBC, MPQ v1/v2), `*_dbc` SQL overlays, `ClientCacheVersion`, this fork's shipping model. |
| [`dungeons.md`](../.agents/docs/systems/dungeons.md) | Dungeon rules, **map-id policy** (dungeon #3+ = new `Map.dbc`; leftover scrap is closed), Waxworks/Vault retrospective, id registry, extensibility status. |
| [`talents.md`](../.agents/docs/systems/talents.md) | Talent/TalentTab/Spell DBC model, server validation, hard limits, `character_talent`, reset rules. |
| [`terrain.md`](../.agents/docs/systems/terrain.md) | ADT/WDT tiles, Noggit constraints, per-tile re-extraction, area id and graveyard ripple effects. |
| [`coordinates.md`](../.agents/docs/systems/coordinates.md) | Router only: sends every `.go` / teleport / xyz-placement task to the `wow-coordinates` skill. |

## Agent skills (`.agents/skills/`, fork-specific)

Step-by-step procedures with checklists. Each `SKILL.md` names the docs to read first.

| Skill | Use when | Extra files |
|---|---|---|
| [`build-client-patch`](../.agents/skills/build-client-patch/SKILL.md) | Anything ships an MPQ or server `data/` files: stage → pack (MPQ v2) → extract → bundle → publish → deploy → verify. | [`reference-windows-linux.md`](../.agents/skills/build-client-patch/reference-windows-linux.md) — tool and command matrix for both operating systems. |
| [`build-dungeon`](../.agents/skills/build-dungeon/SKILL.md) | Designing or implementing a 5-man: hosting choice, mesh, content density, loot, entrance. | [`reference-mesh.md`](../.agents/skills/build-dungeon/reference-mesh.md) (Blender/WMO/WDT pipeline), [`reference-content.md`](../.agents/skills/build-dungeon/reference-content.md) (what a finished dungeon contains), [`reference-new-map.md`](../.agents/skills/build-dungeon/reference-new-map.md) (**dungeon #3+**: new `Map.dbc` id on client and server; do not reuse leftover instance maps). |
| [`edit-talents`](../.agents/skills/edit-talents/SKILL.md) | Changing talent trees: smallest change, DBC + overlay edit, reset policy, verification. | — |
| [`edit-terrain`](../.agents/skills/edit-terrain/SKILL.md) | Overworld ADT edits with Noggit: tile list, per-tile extraction, DB follow-ups. | — |
| [`walk-instance`](../.agents/skills/walk-instance/SKILL.md) | Visually verifying an instance with the scout client (screenshots, not SOAP alone). | `scripts/scout-*.ps1` (Windows only). |
| [`wow-coordinates`](../.agents/skills/wow-coordinates/SKILL.md) | Any `.go`, SOAP teleport, or spawn placement by xyz. | [`reference.md`](../.agents/skills/wow-coordinates/reference.md). |

## Agent entry points and rules

| File | Role |
|---|---|
| `AGENTS.md` | Loaded automatically by Cursor, Codex and Copilot. § "This fork" gives the context above and the hard rules; "Mandatory reading per task" routes fork tasks to the docs and skills on this page. |
| `CLAUDE.md`, `GEMINI.md` | Import `AGENTS.md` for Claude Code and Gemini CLI. |
| `.claude/skills/*` | Relative symlinks to `.agents/skills/*` (needs `git config core.symlinks true` on Windows). |
| `.cursor/rules/fork-context.mdc` | Always-on Cursor rule: read `AGENTS.md` § "This fork" and this index; branch safety. |
| `.cursor/rules/{client-content,dungeons,deploy-ci}.mdc` | Path-scoped Cursor rules that name the doc and skill for files under `client-patches/`, `src/tools/`, DataStores, `pending_db_world/`, instance scripts, `apps/deploy/`, `.github/workflows/`, `docs/`. |
| `.github/copilot-instructions.md`, `.github/agents/pr-reviewer.md` | Copilot code review: review against `AGENTS.md` routing and this index. |
| `.agents/README.md`, `.agents/docs/README.md` | How skills/docs are organised and how to hook up another agent (upstream files; any new agent gets an entry file that points at `AGENTS.md`). |
| [`apps/codestyle/codestyle-docs.py`](../apps/codestyle/codestyle-docs.py), `.github/workflows/docs-check.yml` | CI guard for all of the above: fails a PR when a doc or skill is missing from this index, a system doc or skill has no `AGENTS.md` routing, a `.claude/skills` symlink is missing or a plain file, a Cursor rule can never load, `AGENTS.md` lost its "This fork" section, or a relative link is broken. Run locally with `python3 apps/codestyle/codestyle-docs.py`. |

## Where things are **not**

- Patch binaries (MPQs, `server-data.tar.gz`) — VPS `/home/acore/client-patches/`, never git.
- Planning notes (`.agents/plans/`) — gitignored; anything durable has been folded into the docs
  and skills above. The Waxworks mesh notes (TOOLCHAIN, ART-SOURCES, ROOM-SPEC) were lost this
  way; do not rely on them.
- Server configs (`conf/*.conf`), custom SQL (`data/sql/custom/`), `src/server/scripts/Custom/` —
  gitignored by upstream policy; this fork keeps its content in the regional script tree and
  `pending_db_world` instead.

## Adding a doc

- Human prose about this fork → a new file in `docs/`, one row in the matching table above.
- Agent model/rules → `.agents/docs/systems/<subsystem>.md` plus a routing bullet in `AGENTS.md`
  and a row here.
- Procedure → `.agents/skills/<name>/SKILL.md`, symlink from `.claude/skills/`, row here.
- Directory `README.md` files stay one screen long and link back to the full doc in `docs/`.
- Run `python3 apps/codestyle/codestyle-docs.py` before pushing; `docs-check` runs it on the PR.
