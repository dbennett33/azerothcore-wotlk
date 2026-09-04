# Blender → 3.3.5 WMO (kitbash)

Read [SKILL.md](SKILL.md) and [reference-mesh.md](reference-mesh.md) first. This file is the
**art path** for a distinct cave: import vanilla WMO groups, compose rooms, export WotLK v17,
write a Ragefire-style WDT, then the existing pack → extract → bundle pipeline.

Dungeon #3+ still needs a **new `Map.dbc` id** ([reference-new-map.md](reference-new-map.md)).
This file does not change hosting.

This fork's authored process is **Linux** (paths and commands below). A contributor also
kitbashes on Windows: same Blender **3.4.1** + WBS + WMO v17 + MPQ v2 rules apply; they pick
their packer/GUI. Do not block Linux work on Windows tool paths.

## Which path to use

| Path | When | Output |
|---|---|---|
| **WBS kitbash** (this file) | Real rooms, reused vanilla art, dungeon #4+ or replacing Belfry boxes | WMO v17 + WDT |
| Python box generator | First-load hull / collision scaffold only | `gen-drowned-belfry-mesh.py` |
| Unused vanilla instance WMO | Closed | Maps 35 and 44 are taken |
| Type-14 cave GOs | Agent-speed space on map 0, no new mesh | [reference-mesh.md](reference-mesh.md) path 2 |
| From-scratch sculpt in WBS | Same export as kitbash; more time | Same files |

Do **not** treat the Belfry Python chapel as finished art. Do **not** `pacman -S blender`
(CachyOS/Arch is 4.x; WBS loads on **3.4 only**).

## Pinned versions

| Tool | Version | Why |
|---|---|---|
| Blender | **3.4.1** official Linux tarball | WBS supports Blender **3.4** only |
| WoW Blender Studio | GitLab `skarnproject/blender-wow-studio` | WMO **v17**. Tag in the paragraph below |
| wow.export | Kruithne Linux portable | **Open Legacy Installation**, not CASC |
| Packer (this machine) | `/home/dan/dev/tools/pack-mpq` | StormLib, MPQ **v2**, spec `disk=archivepath` |
| Extractors | `build-tools/src/tools/` in this repo | `extract-server-data.sh --map <id>` |
| Playable client | `/home/dan/dev/wow-3.3.5/` | Proton. Close Wow **fully** after replacing MPQs |

WBS tag: `3.4-1.1.0_Experimental` (or `3.4-1.0.3` if that build fails). It must be **built**
(`python3 build.py` with Python matching Blender 3.4, which is 3.10) **or** a precompiled zip
from <https://gitlab.com/skarnproject/blender-wow-studio/-/jobs>. Enabling the source tree without
`build.py` fails. Discord: <https://discord.gg/SBEDRXrSnd>.

**Do not export M2 from WBS.** Animated M2 is broken; static is unstable. Reuse vanilla M2s from
the client (doodad paths already in imported groups, or MODD entries pointing at existing files).

## Install on this Linux box (done 2026-09-04)

Tools live under `/home/dan/dev/tools/`. Distro Blender is still 4.x — do not use it.

1. **Blender 3.4.1** — `/home/dan/dev/tools/blender-3.4.1-linux-x64/blender`
2. **WBS** — built zip at `/home/dan/dev/tools/wbs-dist/io_scene_wmo`, installed to
   `~/.config/blender/3.4/scripts/addons/io_scene_wmo`. Addon **WoW** is enabled.
3. **WBS paths** (project `belfry` already created):
   - WoW Client = `/home/dan/dev/wow-3.3.5`
   - Project = `/home/dan/dev/wmo-projects/belfry/`
   - Cache = `/home/dan/dev/wmo-projects/_cache/`
   - WMV log = `/home/dan/dev/wmo-projects/wmv-log.txt`
4. **wow.export 0.2.19** — `/home/dan/dev/tools/wow-export/wow.export`. Open
   **Legacy Installation** → `/home/dan/dev/wow-3.3.5`. Native WMO bytes for WBS import
   come from `extract-wmo-family.py`, not from wow.export OBJ.

`smpq` is optional; this machine packs with `pack-mpq`.

## Dump source WMOs

WBS imports **native WMO** (root + `_000`, `_001`, …), not OBJ. Textures resolve from the client
path in the addon, so do not dump the whole `DUNGEONS\TEXTURES` tree.

```bash
python3 client-patches/scripts/extract-wmo-family.py \
  --mpq /home/dan/dev/wow-3.3.5/Data/common-2.MPQ \
  --prefix 'World/wmo/Dungeon/AZ_Deadmines/AZ_Deadmines_A' \
  --out /home/dan/dev/wmo-sources/AZ_Deadmines_A
```

Some families live in `expansion.MPQ` / `lichking.MPQ`. If the prefix is missing, pass that archive
instead. wow.export Legacy is the visual picker; copy the path it shows into `--prefix`.

**Use these families** (Waxworks kitbash set; re-derive with wow.export if a room needs a new look):

- `World/wmo/Dungeon/AZ_Deadmines/AZ_Deadmines_A` foundry / Cookie (groups `_000`–`_037` in `common-2.MPQ`)
- `World/wmo/Dungeon/MD_Goldmine/MD_Goldmine` shafts (`_variantA`…`F` exist; prefer the placed root)
- Crypts in `common-2.MPQ`: `MD_Crypt/MD_Crypt` (`_B` `_C` `_D`), `MD_CryptOneRm`,
  `MD_CryptSchool`, `MD_CryptSimpleEnt`, `MD_Ruinedkeep/Ruinedkeep_crypt`
- Candle / cauldron / cart **M2s** already in the client (place as doodads, do not re-export)

**Do not start from** RFC lava rooms, leftover map-44 Scarlet interior, Stockades, SFK, SM
cathedral, Cata Fargodeep, or another server's instance MPQ.

## Compose in WBS

1. File → Import → WoW WMO → the extracted root (`….wmo`). Repeat per source family.
2. One WMO **root** per instance. Groups = rooms (or one group for a first ship).
3. Build the playable run on **−X** in Blender when you can, so world dest matches SQL without a
   second mirror. The Python generator emitted origin-symmetric verts as a hack; kitbash should
   not need that if you model on the playable side.
4. Origin near `(0,0,0)`. Keep the mesh AABB compact; the WDT MODF still gets ±200 pad.
5. Do **not** duplicate an overworld chapel (`Ext` / `Stairs05`) along the spawn spine, and do
   **not** overlay a second WMO family in the same XY. Stacked floors draw as a horizontal
   slice (coffins cut in half). Keep one source WMO's indoor groups together.
6. Keep **portals** when you keep every group of that WMO. Wiping them (or setting AlwaysDraw)
   makes indoor groups draw through each other. Only wipe Portal collections after you
   **delete** groups, or WBS `save_portals` crashes. AlwaysDraw (`flags` `'2'`) is for
   portal-less hulls only.
7. Leave vanilla Indoor/Outdoor when portals stay. If you did strip portals, move playable
   rooms into the WBS **Indoor** collection (MOGP `0x2000`) or they rain/sky. Then Quick
   collision (`scene.wow_quick_collision`) so MOPY is `0x20`. `liquid_type` **15**. No MLIQ.
   MOHD flag `0x2`.
8. At least one MOLT on the root and MOLR on interior groups (or HAS_LIGHTS unset — unlit interior
   groups can look black / be skipped). Match a working group if unsure: Waxworks `_000` MOGP
   `0x2a05`.
9. Materials keep BLP paths the client already has, or new BLPs staged into `patch-4` at the
   exact MOTX path. One MOBA batch per material.
10. Floors need thickness or a two-sided pair. A paper-thin axis-aligned quad **renders and still
   drops the player** (3.3.5 walk is client-authoritative; see reference-mesh pitfalls).
11. File → Export → WoW WMO, **version 17**. Writes `Name.wmo` + `Name_000.wmo` ….

## WDT (WBS does not replace this)

Ragefire / Waxworks / Belfry pattern: WMO-only, MODF at origin, `uniqueId = 0xFFFFFFFF`, AABB
padded **±200 on all three axes** (extractor `fixCoords` maps WDT Z → vmap X). Chunk tags on
disk are Blizzard-reversed (`REVM` / `OMWM` / `FDOM`) — ASCII `MVER` is skipped by
`vmap4_extractor` (`flipcc`) and the map never gets a `.vmo`.

```bash
python3 client-patches/scripts/write-wmo-only-wdt.py \
  --root-wmo /path/to/Name.wmo \
  --wmo-path 'World\wmo\Dungeon\<Dir>\<Name>.wmo' \
  --out client-patches/sources/client/loose/World/Maps/<Dir>/<Dir>.wdt
```

`--wmo-path` is the MWMO string inside the WDT (backslashes, matches the MPQ internal path).

## Coordinates (MODF at origin)

World dest = `(−BlenderX, −BlenderY, BlenderZ)`. Client verts are **not** inverted. Spawn SQL and
`.go` use **world** xyz. Skill: `wow-coordinates`.

## Stage → pack → extract → ship

Same as any custom WMO. Details: `build-client-patch` skill + [reference-mesh.md](reference-mesh.md).

1. Copy root + groups + new BLPs into `client-patches/sources/client/loose/` at the **exact** MPQ
   paths (`World/wmo/Dungeon/<Dir>/…`, `World/Maps/<Dir>/<Dir>.wdt`). Keep **every** existing
   custom file (Waxworks, Belfry) in that tree — `patch-4.MPQ` is rebuilt **whole**.
2. Pack MPQ **v2** with `/home/dan/dev/tools/pack-mpq` (`disk=World\\…`). Not v3/v4. `smpq -M 2`
   is the distro alternative if installed.
3. Install into `/home/dan/dev/wow-3.3.5/Data/`. **Fully quit** Wow (Proton too). `Wow.exe` keeps
   MPQs mapped; a replace-on-disk without quit is a silent stale mesh.
4. Extract **only this map** from the slim `client-patches/extract-client/` (locale + `patch-4`).
   Hide `dbc/.gitkeep` before `build-bundle` or it becomes a fake dbc component. Do not ship a
   full continent `dbc/` dump or an empty `GameObjectModels.dtree`.
5. Stage changed `vmaps/` + `mmaps/` (and `maps/` only if ADTs exist). Gate on
   `vmaps/<Name>.wmo.vmo` **>10KB**, not on a tiny `.vmtree`.
6. `build-bundle` → publish → commit `manifest.json` with the SQL/C++ → push `dev` when asked.

## Export QA (before anyone hops)

Compare a group against Waxworks `_000` if the room is visible and the player falls:

| Check | Fail look |
|---|---|
| Walkable MOPY after WBS export | `0x24` = incomplete Collision VG (run Quick collision). `0x20` is WBS default, not `0x28` |
| Real MONR (not stub `(0,0,1)` on every vert) | Same |
| Thick or two-sided floors | Same |
| MOBA per material | Lighting / batch bugs |
| Indoor collection (MOGP `0x2000`) + a light (MOLT/MOLR) | Outdoor light / rain / black; vanilla crypt imports Outdoor |
| `liquid_type` 15, no MLIQ, MOHD `0x2` | Indoor swim |
| MODF AABB padded all axes | BIH miss past the mouth |
| worldserver: no `WorldModelStore: could not load` | Server has no `.vmo` |

Proof is a PNG of the floor with `.gps` in frame (Proton client is fine), not SOAP. Do not
Z-nudge. Windows scout scripts (`walk-instance`) are another contributor's; not required here.

## First-install smoke (2026-09-04)

- [x] Blender 3.4.1 at `/home/dan/dev/tools/blender-3.4.1-linux-x64/blender`
- [x] Add-on **WoW** enabled; client path `/home/dan/dev/wow-3.3.5`
- [x] Import `MD_CryptOneRm` (5 groups, 17 materials, textures loaded — not magenta).
      `AZ_Deadmines_A` family dumped at `/home/dan/dev/wmo-sources/AZ_Deadmines_A` for kitbash
- [x] Export v17 + `write-wmo-only-wdt.py` (64-byte MODF, pad 200). Naive dump:
      `/home/dan/dev/wmo-projects/belfry/smoke-crypt/` (Outdoor, some `0x24`)
- [x] Quick collision + Indoor: `/home/dan/dev/wmo-projects/belfry/smoke-crypt-qc/`
      (`_000` all MOPY `0x20`, MOGP indoor `0x2805` / `0x2a05`, MOLR on stair groups)
- [ ] Pack + extract is for a **real** map ship (Belfry / dungeon #4), not this smoke dump
- [ ] Fully quit Wow, hop, walk. PNG of the floor, not a void

WBS roundtrip note: source Crypt `_000` MOPY was mostly `0x60` / Outdoor `0x809`. Naive
re-export dropped `0x60` → `0x20`/`0x24` and kept Outdoor. **Quick collision** + move
`Ext` into Indoor → all `_000` faces `0x20`, MOGP `0x2805`/`0x2a05` (Waxworks indoor
shape). WBS still does not write Python-hull `0x28` on visible faces. Inspect with
`inspect-wmo-group.py`. Do not pack this smoke dump into `patch-4.MPQ` (it would clobber
Waxworks + Belfry). Proof of walk is a hop.
