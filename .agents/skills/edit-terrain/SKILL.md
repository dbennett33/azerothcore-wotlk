---
name: edit-terrain
description: >-
  Change overworld terrain in WoW 3.3.5a on AzerothCore: raise or lower ground,
  add or remove buildings, trees, caves and water, change area ids, on Eastern
  Kingdoms / Kalimdor / Outland / Northrend ADT tiles with Noggit, then re-extract
  maps, vmaps and mmaps for those tiles. Use when asked to edit an ADT, use
  Noggit, add a WMO to the world, remove doodads, fix a hole, or when players
  fall through or float over the ground after a patch.
---

# Edit overworld terrain (AzerothCore 3.3.5a, this fork)

Read `.agents/docs/systems/terrain.md` (what a tile is, rules) and
`.agents/docs/systems/client-data.md` (contract) first. Delivery:
`.agents/skills/build-client-patch/SKILL.md`; OS commands in its `reference-windows-linux.md`.
Coordinates and tile math: `.agents/skills/wow-coordinates/SKILL.md`. Instances are
`build-dungeon`, not this skill.

## Before you open Noggit

- Confirm the change cannot be done server-side. Spawns, phases, gameobject props, and
  `game_tele` need no terrain edit. Only ground shape, ADT doodads, WMO placements, water, holes,
  area ids and textures do.
- Compute the tile(s): `gx = 32 - y/533.333`, `gy = 32 - x/533.333` → `Azeroth_<gx>_<gy>` (map 0),
  `Kalimdor_…` (1), `Expansion01_…` (530), `Northrend_…` (571). Edits near a tile edge involve
  both tiles. Write the list down; it drives every later step.
- Check vanilla content on those tiles (quests, area triggers, graveyards, taxi paths) and list
  what must stay untouched (`systems/terrain.md` rules; Fargodeep example).

## Workflow

```
Task progress:
- [ ] Tile list (map, gx, gy) fixed; protected vanilla objects listed
- [ ] Noggit project on a COPY of the client; edits saved; only listed tiles changed
- [ ] New WMO/M2/BLP (if any) collected with their exact internal paths
- [ ] patch-4.MPQ rebuilt with the ADTs (+ models); AreaTable.dbc → patch-enUS-4.MPQ if areas changed
- [ ] Client restarted; visual check in the dev client at the edit spot
- [ ] Extracted; kept only the listed tiles' maps/vmaps/mmaps (+ new .vmo)
- [ ] areatable_dbc / spawn zoneId fixes / graveyard_zone SQL if areas changed
- [ ] Bundle → publish → commit manifest+SQL → push dev → .gps + creature pathing verified on Test
```

### 1. Noggit session

- Point Noggit at a **copy** of the client (`Data/` read). Set the project path to a scratch dir;
  Noggit writes `World/Maps/<Dir>/<Dir>_<gx>_<gy>.adt` (and `.wdt`/`.wdl` if asked) there.
- Load the map, jump to the tile (Noggit shows tile coords; it may print them swapped versus the
  `gx_gy` file name — trust the file name it writes).
- Do the edit. Typical tools: terrain raise/lower/flatten, texture paint, object editor (place WMO/
  M2 from the asset browser; delete doodads), water editor (`MH2O`), area-id painter, hole tool.
- Save. Copy only the ADTs you intended from the project dir into
  `client-patches/sources/client/loose/World/Maps/<Dir>/`. If Noggit rewrote a neighbour you did not
  touch, do not ship it.
- New models: every WMO/M2/BLP that is **not** already in Blizzard's archives goes into `loose/`
  under its exact internal path; vanilla assets referenced by path need nothing.

### 2. Client archive

Rebuild `Data/patch-4.MPQ` whole (previous release's loose set + your files), MPQ v2, install into
the dev client, restart Wow, walk to the spot. Fix seams/holes now; server extraction is expensive
to repeat. New areas: `AreaTable.dbc` row into `patch-enUS-4.MPQ`.

### 3. Extract only what changed

Run `map_extractor -e 1` (maps only, unless DBC changed), `vmap4_extractor` + `vmap4_assembler`
(slim client copy: the four base archives, locale archives, your patches; wipe `Buildings/`),
then `mmaps_generator <map> --tile <gx>,<gy>` per tile. Keep:

```
maps/<map:03><gx:02><gy:02>.map
vmaps/<map:03>_<gx:02>_<gy:02>.vmtile        (only if the tile has WMO/M2 collision)
vmaps/<NewModel>.vmo                          (only for models new to the server)
mmaps/<map:03><gx:02><gy:02>.mmtile
```

The `.vmtree` of a continent changes only when a **new model name** is introduced; if you placed a
vanilla WMO already used elsewhere on that map, the existing tree already lists it and the new
`.vmtile` is enough. When a new model is added, ship the updated `vmaps/<map:03>.vmtree` too.
Never ship the whole `maps/` or `vmaps/` output of a continent.

### 4. World DB follow-ups

- Area ids changed: `areatable_dbc` row(s), `graveyard_zone` link, `Calculate.Creature.Zone.Area.Data
  = 1` for one restart or explicit `UPDATE creature SET zoneId=…, areaId=… WHERE guid IN (…)`.
- Ground moved under spawns: fix `position_z` of `creature`/`gameobject` rows on the tile (probe
  with `.gps` after deploy; do not guess).
- Removed a building players used (vendor, mailbox, flight master): move or remove its spawns.

### 5. Ship and verify

build-client-patch §5–§7. On Test with a patched client: `.gps` at three points on the tile shows
the new Z and area; a summoned creature (`.npc add`) walks to you over the new ground (mmaps);
`.debug los`-style checks pass through removed walls and fail through new ones (vmaps). Unpatched
client must visibly float/sink at the edit — that confirms the release depends on the MPQ.

## Pitfalls

- Editing the live client's `Data/` in place — you lose the pristine copy and lock files.
- Shipping every tile Noggit touched — Noggit resaves neighbours; diff the project dir against the
  Blizzard ADT (`smpq -x` / wow.export) and keep only real changes.
- Forgetting `.wdt` when adding a tile that did not exist (MAIN flag) — client shows void.
- Full re-extract overlaid on the VPS — replaces every continent file; if the extraction differed
  (locale, patch set), unrelated zones change height.
- Area id painted but no `AreaTable` row → zone name blank, graveyard fallback errors in the log.
- Holes in `.map` vs vmaps disagreeing → fall-through at cave mouths (re-extract both together).
- ADT water is global: you cannot hide it with phases; move the pocket or edit `MH2O`.
