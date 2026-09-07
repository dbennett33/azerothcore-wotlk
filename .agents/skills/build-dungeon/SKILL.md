---
name: build-dungeon
description: >-
  Design and implement AzerothCore 3.3.5a 5-man dungeons (phase overlay or real
  instance mesh). Covers WMO/ADT/DBC/extract pipeline, hosting choices, loot,
  lighting, pulls, and walk-through entrances. Use when building a dungeon,
  custom instance, cave mesh, WMO, ADT tiles, Map.dbc row, overlay of an
  existing mine, The Waxworks, Fargodeep, or when a dungeon feels empty,
  reused, or has no trash loot.
---

# Build a dungeon (AzerothCore 3.3.5a)

Read this skill before adding or reshaping a 5-man. Then read the matching
reference only if you need it:

- Mesh / client / extract → [reference-mesh.md](reference-mesh.md)
- **Blender / WBS kitbash** (the art path for a distinct cave) →
  [reference-blender-wmo.md](reference-blender-wmo.md)
- Content that feels like a real dungeon → [reference-content.md](reference-content.md)
- **Dungeon #3+** (new `Map.dbc` id, DBC rows, graveyard, access) →
  [reference-new-map.md](reference-new-map.md)

Also read `.agents/docs/systems/dungeons.md` (id registry, what Waxworks did that does not
repeat), `.agents/docs/systems/client-data.md`, `.agents/docs/cpp-guidelines.md`,
`.agents/docs/cpp-scripts.md`, `.agents/docs/sql-guidelines.md`. Any `.go` / SOAP / spawn xyz →
`.agents/skills/wow-coordinates/SKILL.md` first. Packing / extracting / publishing →
`.agents/skills/build-client-patch/SKILL.md`.

This fork ships custom 5-mans as **world content**, not a module. The Waxworks
is `src/server/scripts/EasternKingdoms/Waxworks/` plus pending world SQL.
Do **not** put it in `modules/` or `src/server/scripts/Custom/` (gitignored).
Never edit `data/sql/base/`, `data/sql/archive/`, or `data/sql/updates/db_*`.

## Hosting decision (pick one, do not mix)

| Model | Distinct cave? | Isolation | Needs client patch + extract |
|---|---|---|---|
| **Phase overlay** on map 0 | No — Fargodeep walls | Shared world | No |
| **Type-14 cave GOs** on map 0 | Glued vanilla caves | Shared world | No (existing display ids) |
| **Kitbash WMO on map 44** | Yes, if you ship tiles | Real instance | Yes (`Monastery.wdt` + WMO) — **taken by The Waxworks** |
| **Unused vanilla instance (map 35)** | Yes — existing WMO | Real instance | SQL + C++ (client already has `StormwindPrison`) — **taken by Stormwind Vault** |
| **New `Map.dbc` id + patch** | Yes | Real instance | Yes (client **and** `map_dbc`) — **the path for dungeon #3+** |

- Maps **44** (Waxworks) and **35** (Stormwind Vault) are taken. Do **not** hunt leftover
  Blizzard instance ids: remaining unused ids are test/junk that `mmaps_generator` skips,
  and even a leftover WMO with client geometry is closed as a hosting choice. Dungeon #3+
  is a new `Map.dbc` row on both sides — [reference-new-map.md](reference-new-map.md).
- Overlay **cannot** enlarge caves or delete ADT trees. Dress the existing shaft
  or change hosting.
- Map **44** already has a leftover Scarlet `Monastery.wdt` (not a blank
  cave). Reuse it only after `patch-4.MPQ` **replaces** that WDT with
  `Waxworks.wmo`, extractors emit `044*` **and** `vmaps/Waxworks.wmo.vmo`,
  and the client restarts. Copying only `044.vmtree` (even a valid 143-byte
  GOBJ tree) leaves no floor. Hopping as-shipped = cathedral water then fall.
- Custom `areatrigger` rows whose id is missing from `AreaTrigger.dbc` never fire.
  Walk-in = `GameObjectAI` + `Player::IsWithinBox`, or a **vanilla** AT id.

Do not start a WMO/ADT project unless the user asked for a distinct cave **and**
accepted Blender **3.4.1** + WoW Blender Studio (not distro Blender 4.x) +
`patch-4.MPQ` + extract. Procedure: [reference-blender-wmo.md](reference-blender-wmo.md).
The Python box generator is a hull/scaffold only. Type-14 GOs are the only
distinct walkable space an agent can place without those tools.

## What “good” means (fail the PR if these are missing)

1. **Rooms have identity.** A player can name each space without a map marker
   (vat floor, kitchen, union hall, shrine). Empty tunnel + 2 candles is a
   reused mine, not a dungeon.
2. **Trash drops.** Every combat `creature_template` has `lootid = entry`,
   `mingold`/`maxgold` > 0, and a `creature_loot_template` of themed junk plus a
   small green chance. `lootid = 0` is an empty corpse.
3. **Clone name/faction/type/model only.** Never copy a vanilla `lootid`,
   `pickpocketloot`, `skinloot`, or `KillCredit`. New items, new tables.
   End-boss **personal** loot (one epic per party member, stacked by class:
   four warriors → four 2H swords) is C++ `AddItem` on `JustDied`, not a
   shared `creature_loot_template` group — group rolls would collapse copies.
4. **WMO-only instances need `IGNORE_PATHFINDING`.** Map 44 has no reliable
   mmaps. Failed chase marks `CannotReachTarget`; on any **non-raid** the
   core then `RegenerateHealth()` in combat (`NpcRegenHPIfTargetIsUnreachable`).
   That looks like every mob auto-heals. Set `flags_extra |= 0x20000000` on
   combat NPCs (not Wickham / trigger helpers).
5. **5-man trash is elite, not outdoor.** Rank 1 + `HealthModifier` ~2.4–2.8
   and `DamageModifier` ~1.4–1.6 for a level 7–12 5-man (RFC trash is HM 3 /
   DM 1.7 at 13–15). Outdoor HM 1 / rank 0 is a Goldshire miner — a five-player
   group one-shots it. Hostile faction (26 kobold / 20 gnoll / 17 Defias /
   14 monster). `flags_extra` must not be `0x80` civilian. Beast clones on
   faction 7 often fail to aggro — use 14.
6. **Entrance is walk-through**, TBC Dark Portal style — not a type-10 “click
   the swirl.” Type 5 stone/veil + oriented box. Exit landing **outside** that
   box or you yo-yo.
7. **Do not sit on vanilla quest geometry.** Fargodeep: Goldtooth guid `80644`
   at `-9745.84, 87.57, 12.77` — keep ≥15y. Do not edit quests 62/60/87/47/88/132/176.
8. **IDs are 9,000,000+.** Header enum is the source of truth; the block is reserved in the
   registry table of `.agents/docs/systems/dungeons.md` before the first SQL line.

## Workflow

```
Task progress:
- [ ] Hosting model chosen (overlay vs real instance); new map id reserved if real
- [ ] Id block reserved in systems/dungeons.md registry; header enum written
- [ ] Layout on real xyz (or WMO local space), rooms named
- [ ] Templates: creatures, GOs, items, quests (`pending_db_world`)
- [ ] Spawns + lighting + at least one set-piece pull
- [ ] Loot + gold on every combat NPC
- [ ] SmartAI / C++ bosses; ScriptName = exact class name
- [ ] Entrance/exit path (no empty map-44 hop, no AT-not-in-DBC)
- [ ] If real instance: VPS data has `vmaps/<Wmo>.wmo.vmo` (not only `044.vmtree`); client restarted after patch-4
- [ ] Walk it **visually** ([walk-instance](../walk-instance/SKILL.md)): one PNG per
      named room with `.gps` in frame; cave vs Scarlet vs swim vs void. SOAP is not a screenshot.
```

**SQL.** `data/sql/updates/pending_db_world/` — `./create_sql.sh`, then `DELETE`+`INSERT`
per block. `smart_scripts`: full rewrite of the `(entryorguid, source_type)` pair.
Worldserver applies pending files on start after a `dev` (test) or `Playerbot` (live)
deploy. `deploy-vps` syncs `data/sql` from that commit into the realm's
`SourceDirectory` first — a stale clone on the VPS will not pick up pending files.

**C++.** `src/server/scripts/EasternKingdoms/<Dungeon>/`, register `AddSC_*` in
`eastern_kingdoms_script_loader.cpp`. Allman, `Type const*`, `auto const&`.
PlayerScript constructor **must** list every hook used (`PLAYERHOOK_ON_MAP_CHANGED`
if you teleport maps). Do not store `Player*` across ticks. Do not build
worldserver unless C++ changed. Push `dev` auto-deploys **test**; live is
`deploy-vps` after merge to `Playerbot`.

**Same-map teleport + phase.** `TeleportTo` on map 0 relocates then broadcasts
the old position. `GetPosition()` after the call is not the destination. Set
phase in `OnPlayerBeforeTeleport` when the dest is inside the dungeon AABB, and
keep a short enter-grace so the exit volume does not fire.

**GO facing.** `gameobject.orientation` drives server `IsWithinBox`. Client
renders the quaternion (`rotation2 = sin(o/2)`, `rotation3 = cos(o/2)`). If they
disagree, the walk box and the stone arch point different ways.

## Overlay-only reminder

Phase `2` hides **all** phase-1 units on map 0 for that player (Goldshire
vendors, miners, spirit healer). Scope phase with an AABB; reset on death,
ghost, login, area, and teleport-out. Wickham (enter+leave) is `phaseMask = 3`.
Terrain, ADT doodads, and **ADT water** are not phased. A pocket under the
sea is an ocean swim — raise it inland / above sea level.

## Custom mesh reminder

Client and server must agree. Server `map_dbc` without a client `Map.dbc` row
= `.go` works, client blackscreens. Client row without server DBC =
`CANNOT_ENTER_NO_ENTRY`. Map 44 as shipped is leftover Scarlet, not a void.
WMO-only maps have **no** `maps/044*.map`; height is 100% vmaps. A tiny
`044.vmtree` is normal — the mesh is `vmaps/<Name>.wmo.vmo`. Missing that
file = `WorldModelStore: could not load` and the player falls. Full pipeline: [reference-mesh.md](reference-mesh.md). Authoring a real cave:
[reference-blender-wmo.md](reference-blender-wmo.md). Tool paths and pack/extract
commands (Windows and Linux): `../build-client-patch/reference-windows-linux.md`.

WMO-only + MODF at origin (Ragefire pattern) has three extra traps:

1. **World dest = (−Blender X, −Blender Y, Blender Z).** Extractor
   `fixCoords` and `VMapMgr2::convertPositionToInternalRep` negate XY. The
   client draws WMO verts with **no** invert. Either origin-symmetric mesh
   (`vert` + `(−x,−y,z)`) or the player stands outside a hull the server
   thinks is floor. Spawn SQL must use **world** xyz, not leftover Blender
   +X — the unused +X copy is not the run.
2. **`liquid_type = 15` (no liquid).** MAG `0` is water. Indoor groups with
   `0` swim. No MLIQ. MOHD flag `0x2`; do not set UseLiquidTypeDBCId.
3. **Pad the WDT MODF AABB on all three axes** (Waxworks: ≥±155). Extractor
   `fixCoords` maps WDT **Z → vmap X**. A short mesh-height Z extent culls
   world X past the mouth. BIH miss = outdoor + FloorZ −100000.

Tunnel capsules: center Z = `floorZ + radius − overlap`, not the room mid-height.
A flying tube is invisible to named-room hops and drops the player on an 8y
corridor walk (Mouth→Wickworks at world −24, FloorZ −100000).

Visual proof: [walk-instance](../walk-instance/SKILL.md). Never Z-nudge.
