# Overworld terrain (ADT / WDT edits on maps 0, 1, 530, 571)

Read this before reshaping ground, adding or removing buildings/trees/water, or changing area ids
on an existing continent. Procedure: `.agents/skills/edit-terrain/SKILL.md`. Data contract:
`systems/client-data.md`. Instances/caves: `systems/dungeons.md`.

## What a tile is

A continent is a 64×64 grid of ADT tiles, 533.333 yards each, listed in
`World/Maps/<Dir>/<Dir>.wdt` (MAIN flags say which tiles exist). One 3.3.5a tile is a **single**
`World/Maps/<Dir>/<Dir>_<gx>_<gy>.adt` (no `_obj0`/`_tex0` split — that is Cataclysm). Inside:

| Chunk | Holds | Server consumer |
|---|---|---|
| `MCNK` ×256 (16×16) | height map `MCVT`, normals, `areaid`, holes, layers `MCLY`, shadows, liquid (`MH2O` at tile level) | `map_extractor` → `maps/<map:03><gx:02><gy:02>.map` (height, area, liquid, holes) |
| `MDDF` | M2 doodad placements (trees, rocks, props) | `vmap4_extractor` → collision only if the M2 has one; `Phase` cannot hide them |
| `MODF` | WMO placements (buildings, caves) | `vmap4_extractor` → `vmaps/<map>_<gx>_<gy>.vmtile` + `<Wmo>.vmo` |
| `MTEX` | tileset textures | none |

`<Dir>.wdl` is the low-res horizon; `textures/Minimap/md5translate.trs` maps tiles to minimap
BLPs. Tile index math: `gx = 32 - y/533.333`, `gy = 32 - x/533.333` (`wow-coordinates/reference.md`).

## The edit loop

1. Edit the tile(s) in Noggit against a **copy** of the client (`Data/` read, project dir write).
   Noggit rewrites whole ADT files; never hand-merge two Noggit outputs of the same tile.
2. Pack changed `World/Maps/<Dir>/*.adt` (+ any new WMO/M2/BLP) into `Data/patch-4.MPQ`
   (rebuild the whole archive; MPQ v2). New/changed `AreaTable.dbc` goes in the **locale** patch.
3. Re-extract on the dev machine with the patched client, then keep **only the touched tiles**:
   `maps/000<gx><gy>.map`, `vmaps/000_<gx>_<gy>.vmtile`, any new `vmaps/<Model>.vmo`, and
   `mmaps/000<gx><gy>.mmtile` (`mmaps_generator 0 --tile <gx>,<gy>`). Do not ship a full re-extract:
   the overlay tarball would replace every continent file with bytes from a different extraction.
4. Stage under `client-patches/sources/server/{maps,vmaps,mmaps,dbc}`, bundle, publish, deploy
   (`build-client-patch` skill). Restart worldserver; `.gps` in the changed spot must report the new
   area/height; a creature must path over the new ground.

## Rules

- Phasing hides units and gameobjects only. Terrain, ADT doodads, ADT water, and WMO placements are
  the same for every player. If a tree must go, edit the ADT; there is no server-only path.
- Never re-extract into a running realm's `data/` and never overlay untouched tiles.
- Each edited tile is one 533-yard square. Neighbouring tiles share edge vertices; Noggit handles
  seams only when both tiles are in the same project. Edit them together or accept a seam.
- Area ids: new `AreaTable.dbc` rows need `areatable_dbc` (server) + locale MPQ (client), and the
  chunk `areaid` written by Noggit. `WorldMapArea.dbc`/`WorldMapOverlay.dbc` are optional (world map
  highlight); `exploreFlag` drives exploration XP/achievements — reuse 0 for none.
- Spawn rows cache `zoneId`/`areaId` (`creature`, `gameobject`). After area changes, set
  `Calculate.Creature.Zone.Area.Data = 1` (and `Gameoject`) for one restart or fix the rows in SQL.
- Graveyards (`game_graveyard_zone`), weather, taxi nodes, `areatrigger_teleport`, and quest POIs key
  on zone/area ids — re-check them when an area boundary moves.
- Water: `MH2O` in the ADT is what players swim in; `LiquidType.dbc` id per layer. Server liquid
  flags come from the `.map` tile — re-extract or the server thinks it is still land (or sea).
- Roads/holes: `.map` holes and vmap holes must agree or players fall through Goldshire (seen
  during Waxworks planning: "high risk of Goldshire holes" for `Azeroth_32_48`).
- Client and server must both get the change in the same release. A player without the MPQ sees
  the old terrain but the server uses the new heights → they float or sink. This is why
  `update-client` is mandatory before login when `manifest.version` changes.
- Keep vanilla quest geometry intact (Fargodeep: Goldtooth guid `80644`, quest AT 88).

## Windows vs Linux

Noggit is Windows-first (a Linux build exists but is unsupported); Blender + WBS for new WMO/M2
runs on both; MPQ packing is MPQEditor (Windows) or `smpq -M 2` (Linux); the AC extractors build on
both from this repo with `-DTOOLS_BUILD=all`. Details: `build-client-patch/reference-windows-linux.md`.
