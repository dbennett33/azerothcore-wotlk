# Dungeon mesh pipeline (3.3.5a / AzerothCore)

Read this when the dungeon needs a **distinct cave**, not a phase overlay.
Overlay work stays in [SKILL.md](SKILL.md).

SQL and C++ only spawn things **on** a mesh the client already has. Phase
overlay of Fargodeep will always look like Fargodeep.

## Two hosting models

| Kind | Map.dbc | Geometry | Examples |
|---|---|---|---|
| **Instance map** | Own id, `InstanceType=1` | Own `World/Maps/<Directory>/` | RFC 389, DM 36, Stockades 34, SFK 33, WC 43 |
| **Continent cave** | Map 0 or 1 | WMO/M2 on an ADT (holes into the hill) | Fargodeep 57, Jasperlode |

Ragefire is the clean **WDT** template: WMO-only, no ADT tiles. Client folder
is `World/Maps/OrgrimmarInstance/` (there is **no** `Ragefire\`). MWMO:
`World/wmo/Dungeon/KL_OrgrimmarLavaDungeon/LavaDungeon.wmo` + `_000`…`_011`,
MODF at origin. Dumped from this client's `common-2.MPQ`.

| Map | Id | WDT directory | WMO family (this client) |
|---|---|---|---|
| Deadmines | 36 | `DeadminesInstance` (ADT tiles) | `AZ_Deadmines/AZ_Deadmines_A.wmo` (+ `_B` `_C` `_D`) — **not** `KL_Deadmines` |
| Ragefire | 389 | `OrgrimmarInstance` | `KL_OrgrimmarLavaDungeon/LavaDungeon.wmo` |
| Scarlet Monastery | 189 | `MonasteryInstances` | monastery instance WMOs |
| Unused map 44 | 44 | `Monastery` | leftover `Monestary/Scarlet_Monestary_Interior.wmo` — **Waxworks** (replaced WDT) |
| Unused map 35 | 35 | `StormwindPrison` | unused `StormwindPrison.wmo` — **Stormwind Vault** |

## File pipeline

```
Map.dbc (id, Directory, type, maxPlayers, LoadingScreen, corpse entrance)
 └─ World/Maps/<Directory>/<Directory>.wdt
    ├─ MWMO + MODF → one global WMO (Ragefire pattern)
    └─ and/or MAIN → <Directory>_X_Y.adt → more MODF WMOs
 World/wmo/.../Name.wmo          (root: textures, doodads, groups)
 World/wmo/.../Name_000.wmo      (group: verts, collision, indoor)
 + .blp + M2 doodads
```

WMO groups with `SMOGroup::INTERIOR` (`0x2000`) get indoor light / no mount.
Collision is group `MOPY` / `MOVI` / `MOVT`.

### DBC roles

| DBC | Need for a new 5-man |
|---|---|
| `Map.dbc` | Id, `Directory`, type 1, maxPlayers 5 |
| `MapDifficulty.dbc` | Difficulty 0 + maxPlayers 5. Missing → `TRANSFER_ABORT_DIFFICULTY` (non-GM) |
| `AreaTable.dbc` | Optional zone name / flags |
| `WMOAreaTable.dbc` | Indoor room names from (rootId, adtId, groupId) |
| `AreaTrigger.dbc` | Walk-in volumes — SQL-only ids **never fire** |
| `LoadingScreens.dbc` / `DungeonMap.dbc` / `LFGDungeons.dbc` | Optional; skip LFG unless you patch the client |

## Fargodeep (not an instance)

Map **0**, area **57**. AC grid is `gx = 32 - y/SIZE_OF_GRIDS`,
`gy = 32 - x/SIZE_OF_GRIDS` (`GridTerrainData.cpp`). Goldtooth
`(-9745.84, 87.57)` → `Azeroth_31_50` neighbours. **`Azeroth_50_31` is
inverted Noggit numbering and does not exist** in `common-2.MPQ`.

Placed cave WMO (from `Azeroth_32_48.adt` MWMO/MODF):

`World/wmo/Dungeon/MD_Goldmine/MD_Goldmine.wmo`

Same ADT also places `MD_SpiderMine` (Jasperlode family). Variants
`_variantA`…`F` exist; use the **placed** root unless a patch overlay
says otherwise. Cata’s Fargodeep micro-dungeon **does not exist in 3.3.5**.
Vanilla quests 62/47/60/87 and Goldtooth stay on this mesh, phase 1.

Dump commands per OS: `../build-client-patch/reference-windows-linux.md`. Close
`Wow.exe` before re-reading live MPQs (exclusive lock).

## Server load path

1. `LoadDBCStores` reads `data/dbc/Map.dbc`, then **`map_dbc` SQL overlays**
   (`LOAD_DBC(sMapStore, "Map.dbc", "map_dbc")`). `map_dbc.sql` in this repo
   is empty; vanilla ids come from the extracted client DBC.
2. `instance_template` required or `CANNOT_ENTER_UNINSTANCED_DUNGEON`.
3. Height: `maps/{map:03}{gx:02}{gy:02}.map` **or** vmaps. WMO-only instances
   (RFC 389, Waxworks 44) have **no** `.map` tiles — height is 100% vmaps.
4. Collision: `vmaps/{map}.vmtree` names a GOBJ; mesh is `vmaps/<Name>.wmo.vmo`.
   A doodad-less WMO-only tree can be ~143 bytes (RFC is ~16KB because of
   doodads). Gate on the **`.vmo` existing and >10KB**, not on vmtree vs RFC.
   Missing `.vmo` → `WorldModelStore: could not load` → fall through.
5. Pathing: `mmaps/`. Missing → `PATHFIND_NOT_USING_PATH`.

| Situation | Result |
|---|---|
| Server `map_dbc` has id, client `Map.dbc` does not | `.go` works; client error / disconnect |
| Client has id, server DBC does not | `CANNOT_ENTER_NO_ENTRY` |
| Both have id, **no WDT/WMO** | Client crash (map **451** today) |
| Map 44 as shipped | Leftover Scarlet interior WDT — **not** blank, **not** Waxworks |
| `044.vmtree` copied, `.wmo.vmo` not | Server has placement, **no mesh** — underwater then fall |
| Client still running leftover Scarlet | Fountain water at origin; server has no Scarlet collision |
| WMO-only, no `maps/044*.map` | Expected. Do not invent `.map` files. |
| Maps+vmaps, no mmaps | Players walk; creatures path badly |

## Map 44 (`<unused> Monastery`)

`instance_template` `(44, 0, '', 0)` exists. `Map.dbc` Directory is
`Monastery`. This client **already has** `World/Maps/Monastery/Monastery.wdt`
(WMO-only). MWMO is leftover Scarlet:

`World/wmo/Dungeon/Monestary/Scarlet_Monestary_Interior.wmo`

(+ groups `_000`…`_045`). Live Scarlet 5-mans use map **189** /
`MonasteryInstances`. Hopping to 44 **without a patch** loads that leftover
cathedral (or fails server-side if `044*` were never extracted).

**Reuse 44** only after `patch-4.MPQ` **replaces** `Monastery.wdt` to point
at `Waxworks.wmo`, extractors emit `vmaps/044.vmtree` + `vmaps/Waxworks.wmo.vmo`
(+ `mmaps/044*`), realm `data/` has that **`.vmo`**, and Wow is restarted.
No `maps/044*.map` (WMO-only). No `map_dbc` row if Directory stays `Monastery`.

Do not use leftover maps 13/25/29/37/42/169/451 as a 5-man cave. Map **35** is taken by
Stormwind Vault. Dungeon #3+ is a **new `Map.dbc` id** (path 3 below), not more scrap.

## Ranked build paths

### 1 — Kitbash WMO on map 44 (real distinct 5-man)

Copy Ragefire’s **WDT pattern only** (WMO-only, MODF at origin) — not its
lava halls. Point MWMO at a kitbashed `World/wmo/Dungeon/Waxworks/Waxworks.wmo`.

Waxworks families (the ART-SOURCES catalog was a gitignored plan; re-derive
with wow.export if needed): `AZ_Deadmines_A` foundry/Cookie, `MD_Goldmine`
shafts, crypt chapels, candle/cauldron/cart M2s. Optional: one WC wet
group; farm M2s for the sty.

Do **not** start from RFC lava rooms, leftover map-44 Scarlet interior,
Stockades, SFK, SM cathedral, Cata Fargodeep, or other servers’ instance
MPQs. Pack `patch-4.MPQ` (**must overwrite** `Monastery.wdt`). Extract map
44 only. `map_extractor` common list stops at `patch-5.MPQ` — do not use
`patch-6+` for the WDT. Tools are on disk under `C:/dev/tools/`.

### 2 — Type-14 cave GOs (agent-speed distinct space)

Spawn existing `GAMEOBJECT_TYPE_MAPOBJECT` caves (collision from
`GameObjectDisplayInfo.dbc` / `ExtractGameobjectModels`). No new map id.
Seams may have no floor; outdoor light; two parties share the space. Test
every piece with `.go xyz` inside the AABB.

| Entry | Display | Name |
|---|---|---|
| 19146–19149 | 9147–9150 | Tunnel Cave to Cave |
| 19152–19158 | 9153–9159 | Crypt / School / Simple Entrance |
| 19189–19190 | 9190–9191 | Horde Mine / Horde Mine 2 |
| 19200–19207 | 9202–9209 | Mountain Cave Medium 1–8 |
| 19219–19220 | 9221–9222 | Warm Cave / Warm Cave Medium |
| 19234 | 9236 | Crypt Instance |
| 19345 | 9346 | Undead Cave |

Place **offset or below** Fargodeep, not on Goldtooth. Keep Wickham as the
teleporter. Do not edit Elwynn ADT.

### 3 — New Map.dbc id (900+) — required for dungeon #3+

Same as (1) plus a **new** map id and a clean `Directory` (not `Monastery`, not
`StormwindPrison`). Client patched `Map.dbc` + `MapDifficulty.dbc` **in the locale
MPQ**, and a matching `map_dbc` INSERT. Extractor only emits maps it sees in
**client** Map.dbc. Full steps: [reference-new-map.md](reference-new-map.md).

## Custom instance — minimum files

**Client** (`Data/patch-4.MPQ`; DBC in `Data/enUS/patch-enUS-4.MPQ`):

```
World/Maps/Monastery/Monastery.wdt
World/wmo/Dungeon/Waxworks/Waxworks.wmo
World/wmo/Dungeon/Waxworks/Waxworks_000.wmo
… + .blp + reused vanilla M2s
```

Put DBC in the **locale** patch. `vmap4_extractor` reads locale Map.dbc; if
the row lives only in the non-locale MPQ, **vmaps skip your map**
(azerothcore/azerothcore-wotlk#16740). Numeric patches through **-9** win;
lettered `patch-A` is **not** in this repo’s extractor. Later `patch-N`
hides an earlier Map.dbc that lacks your row.

**Server:**

```
map_extractor -i <client>
vmap4_extractor -d <client>/Data/
vmap4_assembler Buildings vmaps
mmaps_generator --threads 8 44
```

Stage `vmaps/044*`, **`vmaps/Waxworks.wmo.vmo`**, `mmaps/044*` under
`client-patches/sources/server/`, then `build-bundle` + `publish-to-vps`
(`VPS_HOST=debian@…`). Do **not** copy only `044*` and do **not** commit
binaries. Canonical store: `/home/acore/client-patches/`. Overlay applies on
**deploy-vps** (`dev` → test `/home/acore/server-test/data`, `Playerbot` →
live `/home/acore/server/data`). WMO-only maps have no `maps/044*.map`.
Then `dungeon_access_template`, scripted veil/Wickham teleport, creatures
on map 44.

Prefer an **isolated** vmap extract: slim `Data/` with `enUS/locale-enUS.MPQ`
+ `patch-4.MPQ` so other maps' WDTs are missing and skip. Wipe `Buildings/`
first — `ExtractSingleWmo` returns success if `Buildings/<plain_name>` already
exists (stale 0-vertex file poisons dir_bin). Do not kill a full-client extract
and assemble a 31MB continent `dir_bin`.

Never hop until worldserver log has **no** `could not load '...Waxworks.wmo.vmo'`
and the client has been restarted after packing `patch-4`. Underwater+fall on
an instance = leftover Scarlet liquid and/or missing `.vmo`. Abort; do not
Z-nudge. ROOM-FLOORS Z is a guess until `.gps`. Prove the view with
[walk-instance](../walk-instance/SKILL.md) (scout PNG + `.gps` in frame), not SOAP.

Extract on the machine that has the packed client + AC tools (commands in
`../build-client-patch/reference-windows-linux.md`; run the tools by hand,
`extract-server-data.sh` assumes they sit in the WoW dir). This
fork's playable client is often
`/home/dan/Downloads/ChromieCraft_3.3.5a/` (Linux) or
`C:\dev\wow-335\ChromieCraft_3.3.5a\` (Windows scout). Do not assume a
Docker `./var/client` data volume.

**Elwynn ADT edit** (custom WMO on map 0): Noggit MODF on `Azeroth_32_48` /
`Azeroth_31_50` / `Azeroth_31_49`, then re-extract **those** tiles. High
risk of Goldshire holes. Goldtooth and quest AT 88 stay.

## Tools (this machine, 2026-08-30)

Full table and pack/extract commands for Windows and Linux:
`../build-client-patch/reference-windows-linux.md` (the original planning notes were gitignored).

| Tool | Path | Notes |
|---|---|---|
| Noggit3 `test-3580` | `C:/dev/tools/noggit3/noggit.exe` | GUI |
| wow.export 0.2.19 | `C:/dev/tools/wow-export/wow.export.exe` | **Open Legacy Installation** (not CASC) |
| MPQEditor 4.0.0.963 | `C:/dev/tools/mpqeditor/x64/MPQEditor.exe` | Agents: always `/console` |
| Blender 3.4.1 + WBS | `C:/dev/tools/blender/blender-3.4.1-windows-x64/blender.exe` | Enable addon in Preferences |
| WDBX Editor | `C:/dev/tools/wdbxeditor/` | Only if adding a new Map.dbc id |
| Client | `C:/dev/wow-335/ChromieCraft_3.3.5a/` | Close `Wow.exe` before MPQ writes |

New geometry in Blender is weeks of 3.3.5 WMO export. Kitbash vanilla groups
(Deadmines, RFC, WC, crypt, Horde Mine) if the user accepts reused art.

## Pitfalls

- Map 44 as shipped → leftover Scarlet interior (fountains at origin). Replace
  WDT in `patch-4`, copy **`.wmo.vmo`**, restart Wow **and** worldserver before
  any hop. `instance_template` is not geometry.
- Copying only `vmaps/044*` → tree without mesh. `044.vmtree` ~143 bytes is OK.
- `ExtractSingleWmo` skip-if-exists: wipe `Buildings/` before re-extract.
- Killing a full extract then assembling continents' `dir_bin` wastes hours;
  isolate locale + `patch-4`.
- Cloned RFC `MODF` bounds/uniqueId are for LavaDungeon. Rewrite bounds from
  the custom WMO AABB before packing, or BIH culling can miss the mesh.
  Pad **all three axes** (not just mesh height): extractor `fixCoords` maps
  WDT Z → vmap X, so a short Z extent culls world X past the mouth.
- World dest = `(−blenderX, −blenderY, blenderZ)` for MODF-at-origin WMO-only.
  Client verts are not inverted. Origin-symmetric mesh, or client/server split.
  Spawn SQL on the **playable** world −X; the unused +X copy is not the run.
- MAG `liquid_type` **0 is water**. Indoor cave groups use **15** (extractor →
  vmap groupLiquid 0). No MLIQ. MOHD `0x2`, no UseLiquidTypeDBCId.
- Tunnel capsule center Z = floor + radius. Room-mid Z leaves an air gap under
  the tube; corridor `.go` at FloorZ 0 falls. Named-room hops miss this.
- Server `map_dbc` without client Map.dbc → client dies on teleport.
- Map.dbc in the wrong MPQ → extractors never see the id.
- Custom AT id → never fires.
- Elwynn ADT edit without re-extract → fall through / blocked road.
- Phase overlay cannot hide trees (ADT doodads have no `phaseMask`).
- Type-14 caves are not rooms with guaranteed floors.
- Missing WMO indoor `0x2000` → outdoor light, mounts, rain.
- Missing mmap → bosses walk through kitbashed walls.
- New maps are **data** (client-patches overlay); new C++ bosses need a
  worldserver rebuild (`vps-build`), not a data-only restart.
- MPQEditor `/console` scripts must be ASCII (UTF-8 BOM makes `new` silently fail).
