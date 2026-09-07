# Coordinate spaces and tile math

Read [SKILL.md](SKILL.md) first. This file is lookup only.

## ADT tile index

AzerothCore:

- `gx = 32 - y / 533.333`
- `gy = 32 - x / 533.333`

Tile file is `Azeroth_<gx>_<gy>`. Noggit sometimes prints these swapped.
`Azeroth_50_31` was inverted numbering and does not exist.
Fargodeep WMO `MD_Goldmine` lives on `Azeroth_32_48`.

## Spaces (do not mix)

| Space | Used by | `.go` dest? |
|---|---|---|
| World xyz | `.go xyz`, spawn position, `TeleportTo` | Yes, if floor-proven |
| WMO local | Blender / WMO verts, group origins | No — transform first |
| ADT MODF | WMO placement on a tile | No — not world xyz |

## Liquid and sky (not safe dests)

| Pocket | xyz | Why it kills |
|---|---|---|
| Ocean (Westfall sea) | `-12360, 2120, -92` | ADT water ignores type-14 GOs; breath + fatigue |
| Sky | `-10200, -600, 280` | No ADT floor; `.go` origin is beside/above the mesh |

Westfall west of about `-11200` with `Y > 1600` is sea. Do not list either
pocket as a fallback.

## Same-map teleport

`Player::TeleportTo` on the current map relocates, then packets still describe
the *old* position. `GetPosition()` immediately after the call is the
pre-teleport xyz. Derive phase and enter/exit volumes from the **destination**
argument, not `GetPosition()`.

## Facing

| Field | Consumer |
|---|---|
| `orientation` | Server `IsWithinBox`, movement |
| `rotation2` / `rotation3` | Client render (`sin(o/2)`, `cos(o/2)`) |

If they disagree, the walk box and the visible door point different ways. Set
both from the same `o`.

## Map 44

Leftover Scarlet `Monastery.wdt` until `patch-4` replaces it. Never `.go` there
until realm `data/` has `vmaps/<Wmo>.wmo.vmo` and the client restarted.
WMO-only dest = `(−blenderX, −blenderY, blenderZ)`. MAG `liquid_type` 0 is
water (use 15). Pad MODF AABB on all axes — extractor `fixCoords` maps WDT Z
to vmap X. Real instance work: [build-dungeon](../build-dungeon/SKILL.md).
