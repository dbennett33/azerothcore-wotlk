# AGENTS.md

AzerothCore is a C++ MMORPG server emulator for World of Warcraft 3.3.5a (WotLK), built with CMake, backed by MySQL.

## This fork (read before anything else)

This checkout is a **private fork** that runs one live and one test realm on a Debian 12 VPS with
mod-playerbots, ships custom client patches, and contains custom content (The Waxworks 5-man). It is
not vanilla upstream. Every fork-specific doc and skill is indexed in **`docs/README.md`**; when a
task touches deploy, CI, branches, client patches, custom content, or agent docs, open that index
first and read the doc it names for the task.

Facts that change how you work here:

- Branches: `dev` = **test** realm (every push auto-builds and auto-deploys it), `Playerbot` =
  **live**. Flow is `dev → PR → Playerbot`. Never push to `Playerbot` directly, never trigger a live
  deploy, and never merge unless asked. Details: `docs/branching.md`.
- Custom content goes in the normal trees, not `Custom/` or `modules/`: C++ under
  `src/server/scripts/<Region>/<Dungeon>/`, SQL under `data/sql/updates/pending_db_world/`, ids in
  the `9000000+` blocks reserved in the registry table of `.agents/docs/systems/dungeons.md`.
- Anything the client renders or validates (maps, WMO, DBC, talents, terrain) needs the **same
  change on client and server**: client MPQ + server `data/` or `*_dbc` SQL, shipped through
  `client-patches/`. Binaries never enter git; only `client-patches/manifest.json` does. Model:
  `.agents/docs/systems/client-data.md`.
- The Waxworks reused map 44; every later dungeon needs a new `Map.dbc` id on both sides
  (`.agents/skills/build-dungeon/reference-new-map.md`).
- Fork skills in `.agents/skills/`: `build-client-patch`, `build-dungeon`, `edit-talents`,
  `edit-terrain`, `walk-instance`, `wow-coordinates`. They are symlinked into `.claude/skills/` and
  pointed to by `.cursor/rules/`.

## Agent rules

- **Do not configure or build unless explicitly asked.** Builds are slow and rarely needed for code changes.
- **Never edit SQL files outside `data/sql/updates/pending_db_*/` unless explicitly requested.** `data/sql/base/`, `data/sql/archive/`, and `data/sql/updates/db_*/` are immutable.
- Formatting follows `.editorconfig`: UTF-8, LF, max 120 cols, trailing newline, no trailing whitespace; 4-space indent for C++ (tabs forbidden), 2-space for JSON/YAML/sh/ts/js.
- Planning docs go in `.agents/plans/<task-slug>/` (gitignored), named `<task-slug>.<TYPE>.md` (`PLAN`, `REQUIREMENTS`, `ANALYSIS`, …).

## Mandatory reading per task

Read the matching doc(s) BEFORE starting the task:

- Compiling, configuring, or running tests → `.agents/docs/build.md`
- Writing or modifying C++ → `.agents/docs/cpp-guidelines.md`
  - Script work (under `src/server/scripts/`) → also `.agents/docs/cpp-scripts.md`
- Creating or modifying SQL → `.agents/docs/sql-guidelines.md`
  - SmartAI work (`smart_scripts` data) → also `.agents/docs/cpp-scripts.md`
- Reviewing a changeset or PR → `.agents/docs/code-review.md`
- Self-reviewing a changeset before submission → also `.agents/docs/self-review-rules.md`
- Touching a subsystem that has a doc in `.agents/docs/systems/` → read that doc too
- Capturing a lesson or adding/updating agent docs → `.agents/docs/README.md`

Fork-specific tasks (index: `docs/README.md`; human overview: `docs/custom-content.md`):

- Deploy, VPS, systemd units, backups, realms, CI workflows, self-hosted runners, branch policy →
  `docs/branching.md`, `docs/multi-realm.md`, `docs/vps-bootstrap.md`, `docs/build-runners.md`,
  `docs/recovery.md`; scripts are tabled in `apps/deploy/README.md`
- Client MPQ/DBC files, server `data/` (maps, vmaps, mmaps, dbc), `client-patches/`, `*_dbc` tables
  → `.agents/docs/systems/client-data.md`, then skill `.agents/skills/build-client-patch/`
  (release mechanics: `docs/client-patches.md`)
- Dungeons and instances (new map, WMO, cave mesh, entrance, bosses, 5-man overlay) →
  `.agents/docs/systems/dungeons.md`, then skill `.agents/skills/build-dungeon/`
  (`reference-new-map.md` for any dungeon after The Waxworks)
- Talent trees (`Talent.dbc`, `TalentTab.dbc`, talent spells) → `.agents/docs/systems/talents.md`,
  then skill `.agents/skills/edit-talents/`
- Overworld terrain (ADT/WDT, Noggit, doodads, water, area ids) → `.agents/docs/systems/terrain.md`,
  then skill `.agents/skills/edit-terrain/`
- `.go` / teleport / SOAP player move / placing spawns by xyz → `.agents/docs/systems/coordinates.md`
  and `.agents/skills/wow-coordinates/SKILL.md`
- Visual instance walk / Wow.exe screenshot / scout client → `.agents/skills/walk-instance/SKILL.md`
- Adding a doc or skill → `docs/README.md` "Adding a doc" (index row + routing bullet here)

## Repository layout

- `src/common/` — networking (Asio), crypto, config, logging, shared utilities.
- `src/server/game/` — core gameplay; compiled into worldserver.
- `src/server/scripts/` — content scripts grouped by region (`EasternKingdoms/`, `Northrend/`, …), class (`Spells/spell_mage.cpp`, …), and domain (`Commands/`, `Pet/`, `OutdoorPvP/`, `World/`).
- `src/server/database/` — DB abstraction and schema updater.
- `src/server/shared/` — code shared by auth and world servers.
- `src/server/apps/{authserver,worldserver}/` — entry points (ports 3724 and 8085).
- `src/test/` — unit tests + mocks.
- `data/sql/` — `base/` (historical schema), `updates/db_*/` (merged), `updates/pending_db_*/` (in-flight), `custom/` (gitignored).
- `modules/` — external modules (see below).
- `apps/` — helper scripts; `apps/codestyle/` holds the lint scripts.
- `conf/dist/` — distributed config templates; `conf/*.conf` is gitignored.
- `deps/` — vendored third-party dependencies.

## Modules

External modules live in `modules/`, each a subdir with its own `CMakeLists.txt`. Disable with `-DDISABLED_AC_MODULES="mod1;mod2"`. See `modules/how_to_make_a_module.md`.

## Persisting lessons

When a user correction reveals a lesson that generalizes, offer to persist it into these docs (placement per `.agents/docs/README.md`): use the `/self-improve` skill if installed, otherwise suggest the user to install it and read this page: https://www.azerothcore.org/wiki/agentic-engineering
