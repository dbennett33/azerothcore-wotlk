---
name: wow-coordinates
description: >-
  Places and teleports AzerothCore 3.3.5a players using verified ground
  coordinates. Stops fatal `.go` / `.go xyz` / SOAP teleports that cause
  fatigue, swim, fall, or void death — especially type-14 pockets and
  Gonzalez. Use when issuing `.go`, `.go xyz`, teleport, SOAP, coordinates,
  xyz, Z height, or placing spawns by world position.
---

# WoW coordinates and teleports (AzerothCore 3.3.5a)

Read this skill before any `.go`, SOAP teleport, `TeleportTo`, or spawn xyz.
Dungeon mesh / overlay hosting is [build-dungeon](../build-dungeon/SKILL.md).
Tile math and coordinate spaces: [reference.md](reference.md).

## Fail the move (hard rules)

1. **ADT water ignores gameobjects.** Type-14 cave GOs do not displace liquid.
   Origin `-12360, 2120, -92` (Westfall sea) = breath + fatigue. "Hide it under
   the ocean" is not a cave.
2. **Sky Z has no ADT floor.** Moving the pocket to `-10200, -600, 280` escaped
   water but `.go` to that xyz lands *beside/above* the GO mesh → fall 280 yards
   → die. Type-14 collision is the display mesh, not a room you can `.go` to the
   spawn origin and stand.
3. **`.go xyz` origin ≠ standable floor.** GO/creature spawn xyz is often the
   model center or a seam. Agents "walk ±10, drop 2 Z" as a test and yeet the
   player into void.
4. **Wrong Z because no ground probe.** Agents invent Z from a spreadsheet. Safe
   method: copy Z from a nearby *vanilla* creature at that XY, or `.gps` on a
   known-good inn/town. If no vanilla spawn exists at that XY, assume
   void/water/sky until proven.
5. **Tile math inversion.** AC grid is `gx = 32 - y/533.333`,
   `gy = 32 - x/533.333`. `Azeroth_50_31` was inverted Noggit numbering and does
   not exist. Fargodeep WMO is `MD_Goldmine` on `Azeroth_32_48`.
6. **World vs WMO-local vs ADT MODF space.** Do not treat WMO MODF placement
   coords as `.go` world xyz.
7. **Map 44 / custom instance.** Leftover Scarlet until `patch-4` replaces
   `Monastery.wdt` **and** the player **restarts Wow**. Even then, do not hop
   until the data volume has `vmaps/<Wmo>.wmo.vmo` (collision). `044.vmtree`
   can be ~143 bytes on a doodad-less WMO-only map — that is not “empty.”
   Missing `.vmo` or leftover Scarlet client water = **underwater then fall**.
   Abort. Do not Z-nudge. ROOM-FLOORS Z is a guess until `.gps`.
   WMO-only dest = `(−blenderX, −blenderY, blenderZ)`. MAG `liquid_type` 0 is
   water (use 15). MODF AABB must cover extractor `fixCoords` (pad all axes).
8. **Same-map `TeleportTo`.** `GetPosition()` after the call is the *old* xyz.
   Phase/dest from destination, not current pos.
9. **`.go xyz x y z` without map** uses the player's current map.
   `.go xyz x y z 0` when you mean Eastern Kingdoms.
10. **The live character is not a dummy.** Gonzalez guid 652 is the user's
    playing toon. SOAP `.go` / `.tele name Gonzalez` / UPDATE `characters`
    position without asking = you just killed their session. Use a playerbot, or
    ask, or only send them to a **named** safe tele (`Elwynn`, `Goldshire`,
    Stormwind).
11. **Fallback chains make it worse.** "If ocean fails, try Z=-130" is deeper
    ocean. Do not encode panicked Z-nudges as the next `.go`.
12. **Orientation vs quaternion.** Server `IsWithinBox` uses `orientation`;
    client render uses rot2/rot3. Mismatch = walk box ≠ visible door.
13. **SOAP cannot `.go xyz`.** It is `Console::No` and matches `.gobject`.
    SOAP moves = `tele name` + a verified `game_tele` row. Exploration `.go`
    is typed into the **scout** client. `revive` is a move — scout only.
    Visual proof: [walk-instance](../walk-instance/SKILL.md), never Gonzalez.

## Safe protocol

Copy this checklist. Do not `.go` / SOAP until every box is true.

```
Before any player teleport:
- [ ] Dest is a named .tele OR a coord where a vanilla creature already stands
- [ ] Map id is explicit
- [ ] Z came from ground (vanilla spawn / .gps), not a plan file guess
- [ ] XY is not open ocean (Westfall west of about -11200 with Y > 1600 is sea)
- [ ] If dest is a type-14 / custom GO, do NOT .go the GO origin — go to a mob already inside it, or don't go
- [ ] If dest is a custom instance: volume has `vmaps/<Wmo>.wmo.vmo`, client restarted after patch-4, no leftover Scarlet water
- [ ] Never SOAP the user's logged-in character through a room checklist
- [ ] Visual check uses the walk-instance scout, not Gonzalez
- [ ] One move, then wait for the human. No loops. Underwater+fall → stop, do not Z-nudge.
```

## Known-good `.go` (this realm)

- Plaza / safe: `.go xyz -9432 62 56.8 0`
- Goldshire stone (look, don't stand in the veil box): `-9462 62 56.7 0` — plaza is east of this
- Old Fargodeep mouth (vanilla mine, phase 1): `.go xyz -9852.19 179.62 20.92 0`

Do **not** list these as safe: ocean `-12360, 2120, -92`; sky `-10200, -600, 280`;
under-hill `-10200, -600, 48` (client GroundZ at that XY is **~112** — z=48
falls through the world). Pocket land is `-10196, -600, 113`. Still outdoor
woods + cave GOs. Map 44 Blender mouth `(12, 0, 0.15)` is **`.go xyz -12 0 0.15 44`**
(WMO-local XY is negated). Still not safe until the `.vmo` is in the volume,
the client restarted after `patch-4`, and a scout PNG shows cave not Scarlet.

## Who you may move

| Target | Allowed |
|---|---|
| Named `.tele` (`Elwynn`, `Goldshire`, Stormwind) | Yes — after asking, or if the user requested a safe recall |
| Vanilla creature xyz (map explicit) | Yes — after the checklist |
| Type-14 / custom GO origin | Never |
| Gonzalez (guid 652) as a room-walker | Never — playerbot, ask, or named safe tele only |
| Fallback Z nudge after a failed `.go` | Never |

## Placing spawns

- Standable floor first, then write xyz. Probe Z from a vanilla creature at that
  XY, or `.gps`. No vanilla spawn at that XY → assume void/water/sky.
- Type-14 GO spawn origin is not a stand point unless a mob already lives inside
  that mesh.
- Never encode ocean / sky pocket xyz as content destinations.

This skill is coordinates and teleports only. Cave mesh, overlay hosting, loot,
and walk-through entrances stay in [build-dungeon](../build-dungeon/SKILL.md).
