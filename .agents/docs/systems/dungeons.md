# Dungeons

When designing or implementing a 5-man (overlay or real instance), follow
`.agents/skills/build-dungeon/SKILL.md` before writing SQL or C++. Data model
(MPQ / DBC / extractors / overlays): `systems/client-data.md`.

Short rules:

- Overlay on map 0 cannot grow caves or delete ADT doodads (trees).
- Never teleport to map 44 unless `patch-4` **replaced** the leftover Scarlet
  `Monastery.wdt`, the client was **restarted**, and realm `data/` has both
  `vmaps/044.vmtree` **and** the WMO mesh `vmaps/<Name>.wmo.vmo`. WMO-only maps
  have no `maps/044*.map`; a tiny vmtree is normal. Missing `.vmo` = underwater
  then fall. As shipped, map 44 is unused Scarlet interior, not a blank cave.
  WMO-only dest = −Blender XY; `liquid_type` 15; pad MODF AABB on all axes.
- Custom areatrigger ids not in `AreaTrigger.dbc` never fire.
- Trash needs `lootid` + gold or corpses are empty. 5-man trash is rank 1
  with HealthModifier ~2.4+, not outdoor HM 1.
- End-boss personal class weapons: C++ `AddItem` per player, not a shared
  loot group (copies of the same class must not collapse into one roll).
- WMO-only caves without mmaps: `IGNORE_PATHFINDING` on combat NPCs or they
  heal in combat (non-raid cannot-reach regen).
- Custom content: `pending_db_world` SQL + `EasternKingdoms/<Dungeon>/` scripts,
  ids `9000000+`, clone appearance only. Not a module.
- Dungeon #3+: **new `Map.dbc` id**. Maps 44 and 35 are taken. Do not hunt leftover
  Blizzard instance ids (see Map ids below).

Mesh / extract / DBC details: `.agents/skills/build-dungeon/reference-mesh.md`.
Content bar (rooms, loot, shrines): `.agents/skills/build-dungeon/reference-content.md`.
Visual walk (screenshots, scout client, not SOAP-only): `.agents/skills/walk-instance/SKILL.md`.
Dungeon #3+ (new `Map.dbc` id): `.agents/skills/build-dungeon/reference-new-map.md`.

## Map ids

Do **not** hunt leftover Blizzard instance maps. Create our own. Dungeon #3 and later
get a **new** `Map.dbc` id (client locale MPQ + `map_dbc` SQL). Procedure:
`.agents/skills/build-dungeon/reference-new-map.md`.

| Id | What the client has | Status |
|---|---|---|
| **44** | Leftover Scarlet `Monastery.wdt` | Taken: The Waxworks (kitbashed WMO behind that Directory) |
| **35** | Unused `StormwindPrison.wmo` | Taken: Stormwind Vault |
| **900** | New `Directory` `DrownedBelfry` | Taken: The Drowned Belfry (dungeon #3) |
| 13, 25, 29, 42, 169, 451, 573, 597, 605, 606 | Test / junk | `mmaps_generator` `skipJunkMaps` — never a 5-man |
| 37 | Unused battleground | Do not use |
| 582+ | Transports | Do not use |

Pick a 3-digit id unused in `Map.dbc` (Blizzard max is 724), keep it `< 1000` so `{:03}`
file names stay 3 digits. Example: **900**. Own `Directory`. Phase overlays and type-14
cave GOs stay on map 0/1 and do not consume a map id.

Waxworks (44) and Vault (35) were one-off reuses of unused vanilla entries. That path is
**closed**, even if another unused instance WMO still exists in the client.

## What The Waxworks did, and which parts repeat

| Piece | Waxworks | Repeatable? |
|---|---|---|
| Map id | Reused unused **44** (`Monastery`), no `map_dbc` row, no client `Map.dbc` edit | **No.** Map **35** was the last unused real 5-man (Stormwind Vault). Dungeon #3+ = **new `Map.dbc` row**. Do not hunt scrap. |
| Geometry | Kitbashed `Waxworks.wmo` behind the existing `World/Maps/Monastery/Monastery.wdt` path, packed into `Data/patch-4.MPQ` | Pattern yes, files no. New map = new `World/Maps/<Dir>/<Dir>.wdt` + `World/wmo/Dungeon/<Dir>/…`, added to the **same** `patch-4.MPQ`. |
| Server mesh | `vmaps/044.vmtree`, `vmaps/Waxworks.wmo.vmo`, `mmaps/044*` in the bundle | Yes, same pipeline (`reference-mesh.md`, `build-client-patch` skill). |
| Difficulty gate | `mapdifficulty_dbc` id `9000044` (server overlay only) | Yes; allocate the next `90000MM` id. New map also needs the **client** `MapDifficulty.dbc` row or the client shows no difficulty and may refuse the portal UI. |
| Access | `instance_template` row already existed for 44; `dungeon_access_template` id 122 | Map 35 had **no** `instance_template` (AT 107 at the vault island refused entry). The unused Trade/Old Town canal swirl has no `AreaTrigger.dbc` volume — that entrance is a `GameObjectAI` box. |
| Entrance | Walk-through `GameObjectAI` box on the Goldshire green → `TeleportTo(44, …)` | Yes. Vault uses the same pattern on the unused Trade/Old Town **canal** swirl (not The Stockade). No second `PlayerScript` — vanilla AT 109 is the exit. Generalise before dungeon #3. |
| Scripts | `EasternKingdoms/Waxworks/*.cpp`, loader `AddSC_*` | Yes: `EasternKingdoms/<Dungeon>/`, own header enum, own `AddSC_*` lines. |
| SQL | One `pending_db_world` file, ids `9000000–9000211` | Yes, with the **next id block** (registry below). |
| Client delivery | `patch-4.MPQ` v1.0.1, `install_path` `Data/patch-4.MPQ` | Yes; rebuild the one archive, bump manifest version, re-publish. |

Knowledge that was only in gitignored `.agents/plans/waxworks-mesh/*` (TOOLCHAIN, ART-SOURCES,
ROOM-SPEC) is **not** in the repo. Anything a future dungeon needs from it must be re-derived or
copied into the tracked skills; treat those references as hints, not sources.

## Custom id registry (world DB, `9000000+`)

One block of **200** template ids and **500** spawn guids per dungeon. Reserve the block here
**before** writing SQL; the header enum of the dungeon is the source of truth for the members.

| Dungeon | creature/GO/item/quest/gossip templates | `creature` / `gameobject` guids | `mapdifficulty_dbc` | `game_tele` | `dungeon_access_template` | `reference_loot_template` |
|---|---|---|---|---|---|---|
| The Waxworks (map 44) | `9000000–9000199` (used: creatures 1–50, GOs 1–32, items 50–79, quests 0/1/3, gossip/npc_text 0–11) | `9000001–9000211` | `9000044` | `9000044–9000052` | `122` | `9000101` |
| Stormwind Vault (map 35) | `9000200–9000399` (used: creatures 200, 202–213; GOs 201, 215–228; items 230–235, 237–244, 250–259; quest 260; gossip/npc_text 200) | `9000500–9000999` (used: 500–540) | `9000035` | `9000060–9000061` | `123` | `9000102` |
| The Drowned Belfry (map 900) | `9000400–9000599` (used: creatures 400–409; GOs 410–424; items 430–443, 450–459; quest 460; gossip/npc_text 400) | `9001000–9001499` (used: 1000–1060) | `9000900` | `9000070–9000071` | `124` | `9000103` |
| next dungeon | `9000600–9000799` | `9001500–9001999` | `90000MM` (MM = new map id mod 100, or next free) | `9000080+` | `125` | `9000104` |

Items and creatures share the numeric space by convention only (different tables); keep them in the
dungeon's block anyway so a grep for the block finds everything.

## Extensibility status (2026-09)

Working and reusable as-is: script layout, SQL layout, walk-through entrance pattern, the bundle →
publish → `deploy-vps` overlay path, the scout walk, `build-bundle` install paths, `extract-server-data.sh`.
Maps 44, 35, and 900 are taken. Blocking dungeon #4 until done:

1. A new `Map.dbc` id (every dungeon after Vault). Follow `reference-new-map.md` end to end.
2. Entrance/portal C++ is still per-dungeon. Prefer a shared table-driven portal before adding more
   `PlayerScript`s that share the same hooks.
