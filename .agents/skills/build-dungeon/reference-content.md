# Dungeon content (how it feels like a place)

Lessons from **The Waxworks** (`modules/mod-waxworks/`). Apply the same bar to
any overlay or instance.

## Layout

Name rooms and pin them to **real coordinates** before spawning.

Live Waxworks (map 44 WMO cave). World xyz = −Blender XY. Floors from scout
`.gps`. Full grid: `.agents/plans/waxworks-mesh/ROOM-SPEC.md`.

| Room | World xyz | Must read as |
|---|---|---|
| Mouth | `-12, 0, 0.15` | Greeter + first tunnel |
| Wickworks | `-46, 0, 0.15` | Factory (vat, cart, wax) |
| North / west wings | `-46, -32, 1.15` / `-22, 28, 0.15` | Candle shrine / chapel |
| King Wick | `-88, 0, 0.50` | Isolated boss, ≥10y clear, facing inbound |
| Commissary | `-88, 32, -7` | Kitchen (cookpot, rack, crates) |
| Bargaining Table | `-136, 0, 0.50` | Union hall (board, notice, lanterns) |
| Sty | `-88, -32, 9.50` | Optional loft off the boss |
| Murloc alcove | `-88, 52, -6.5` | Dry camp — no water |

Never place a type-14 pocket under ocean liquid or at sky Z. Cave GOs do not
make a floor. Z must match nearby vanilla NPC ground (~48 here). Ocean
`-12360, 2120, -92` and sky `z=280` are retired.

Do **not** put dungeon furniture back on Fargodeep (`-98xx, 1xx`). Keep ≥15y
from Goldtooth (`-9745.84, 87.57, 12.77`). Quest AT 88 is not phased.

Pack spacing: trash **12y+** from the next pack and from the boss. Casters
`wander_distance = 0`. One visible patrol is enough.

## Lighting and set pieces

- Vary GO **templates** for size (stub 0.45, taper 1.55, tall 2.3, ritual 2.8,
  great red 4.1). Size is on `gameobject_template`, not the spawn row.
- “Candles everywhere within reason” ≈ tens per wing, not hundreds (client
  spawn cap / visual noise).
- **Prayer circles:** 4–5 mobs, radius ~4y, `orientation` + π (face center),
  `wander_distance = 0`. `creature_addon`: `bytes1 = 8` (kneel) + emote `68`
  (`EMOTE_STATE_KNEEL`). SmartAI: reset → emote 68; aggro → emote 0 + yell.
- Red shrine: display `4152` (ritual) / `5872` (doomsday). Do not use a
  type-10 clicky as the shrine.

## Loot

`lootid = 0` means the corpse is empty. Every combat NPC:

```
creature_template.lootid   = its entry (or a shared trash table)
creature_template.mingold  / maxgold  = copper in the RFC range (≈5–40 trash)
creature_loot_template     = themed poor junk + linen/food + 5–8% green ref
```

Bosses: higher gold, a **group-1** unique green (one of several), optional
`LootMode` 2 for a hard-mode item (`AddLootMode(2)` in C++).

End-boss **guaranteed class weapons** (Waxworks Voss, items `9000070`–`9000079`):
do **not** put them on the corpse loot table. Group loot / Need-Greed would
let one warrior win four claymores. `JustDied` walks `Map::DoForAllPlayers`,
skips GMs, `AddItem`s the class row (mail if bags are full). Four warriors +
a priest → four 2H swords + one 2H staff. Rogues get a 1H dagger — they cannot
use 2H. Rebuild worldserver after changing this C++; SQL alone is not enough.
Verified 2026-08-31: four warriors each received `9000070`, priest `9000074`;
GM Walky skipped. Voss timeout (No / 12s) is the hard path (enrage + two
guards + Overtime Vest) — green-geared level 10 bots needed revives; that is
intended, not a spawn bug. `.gm on` alone does not keep the scout camera
alive through cart nova / boss AoE — `.cheat god on`.

Junk is **new items** (class 15, stack 20) with a one-line `description`.
Do not dump vanilla kobold tables onto clones.

Reference table pattern: `reference_loot_template` entry `9000101`,
`Chance = 0`, `GroupId = 1`; creatures reference it at 5–8%.

## Combat and scripts

- Trash: `AIName = 'SmartAI'`, empty `ScriptName`.
- Bosses: empty `AIName`, `ScriptName` = **exact** C++ class name.
- Gossip NPCs (Wickham, Voss): full `CreatureScript`, not `RegisterCreatureAI`
  alone.
- Cart / hazardous props: visible (`flags_extra` not `0x80`). SAI event **32**
  with `minDmg = 1`. Nova is `11969`, not `11970`. Never spell `5200` on Voss.
- Clear `CREATURE_FLAG_EXTRA_CIVILIAN` on clones or they will not aggro.
- Do not clone VanCleef `639`, Cookie’s murloc, or Hogger display `384`.
- Rank 1 + HealthModifier ~2.4–2.8 on 5-man trash (not outdoor HM 1). Beasts
  on faction **14**, not 7. After a WMO invert, C++ `MovePoint` dests
  (`SnarlroastStovePos`, `VossBoardPos`) must be **world** xyz too.
- WMO-only + missing mmaps: `flags_extra |= 0x20000000` (IGNORE_PATHFINDING)
  or trash cannot-reach-regens HP in combat on every non-raid.

## Entrance / exit

- Walk-through volume: `Player::IsWithinBox(*gate, halfDepth, halfWidth, halfHeight)`
  — local X is through the veil, Y along the arch (TBC AT 4352 is the idea:
  wide, thin, tall).
- Type **5** visuals; no gossip hello on the gate.
- Exit GO `phaseMask` must be visible in dungeon phase (`3` if Wickham is `3`).
- Land **past** the exit box; keep a 3–4s enter grace (`WaxworksJustEntered`).
- Overlay exit plaza: same map, **outside** the entrance box (check
  `IsWithinBox` against the plaza xyz before shipping).

## Live Docker quirks (this machine)

- World `8086→8085`, SOAP `7878`, auth `3724`. SOAP user `ADMIN` / `password`.
- Some volumes still have `creature.id` (not `id1`). Hand-apply: rewrite
  `` `id1` `` → `` `id` ``. Module files stay on `id1` for current AC.
- Apply module SQL then `docker compose restart ac-worldserver` for data-only.
  Rebuild the image only when C++ in `modules/` changed
  (`CTOOLS_BUILD=none` is fine for script-only).

## Models that failed (do not repeat)

- “Dungeon load screen” via empty map 44 → crash or bounce. Tiles + extract
  first; see [reference-mesh.md](reference-mesh.md).
- Clickable pink vortex in front of a huge stone frame → players click a
  postage stamp instead of walking the arch.
- Plaza wildlife hide via `phaseMask` does **not** remove Elwynn trees.
- Boss loot only, trash `lootid = 0` → “mobs drop nothing.”
- Same xyz for landing and exit GO → instant return to plaza.
