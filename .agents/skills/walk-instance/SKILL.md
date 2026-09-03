---
name: walk-instance
description: >-
  Visually walk and screenshot-verify an AzerothCore 3.3.5a instance with a
  dedicated scout client. Use when hopping rooms, SOAP-moving, capturing
  Wow.exe, checking leftover Scarlet vs cave vs underwater vs void, or the
  user asks to see the dungeon. SOAP alone is not verification.
---

# Walk an instance (visual)

Read this before any in-game room checklist. Teleports:
[wow-coordinates](../wow-coordinates/SKILL.md). Mesh gates:
[build-dungeon](../build-dungeon/SKILL.md). Scripts live in `scripts/`.

SOAP cannot see the client. `browser_take_screenshot` is **web only**. A
playerbot is **not a camera** — it has no Wow.exe. The eyes must be a real
logged-in client that is **not Gonzalez (guid 652)**.

## Whose eyes

| Actor | Role |
|---|---|
| Scout account `SCOUT` / toon `Walky` | Camera. Windowed 1024×768 at `C:\dev\wow-335\scout\` |
| Gonzalez guid 652 | User's live toon. Never SOAP `.go` / `tele` / `revive` |
| Playerbots (`RNDBOT*`) | Props in the scout's view only |

## Quality loop (long horizon)

SOAP + one mouth hop is not a dungeon review. After the mesh no longer
kills (no swim, no fall, no Scarlet), keep walking **every named room**
until each PNG is a **PASS indoor cave** with identity (vat, kitchen, shrine,
not a blank tube). Fail the walk if a room looks reused-vanilla, unlit, or
empty of props.

Per pass: screenshot → Read → if FAIL, hand the PNG + `.gps` line to a
rebuild subagent → redeploy (patch-4 / vmaps / worldserver as needed) →
**re-capture that room** before moving on. Never Z-nudge. Never SOAP Gonzalez.

Named Waxworks stands (Blender → world `.go`, map 44). GPS-verified FloorZ:

| Room | Blender | `.go xyz` / `game_tele` |
|---|---|---|
| Mouth | 12, 0, 0.15 | `-12 0 0.15 44` `wax44_mouth` |
| Wickworks | 46, 0, 0.15 | `-46 0 0.15 44` `wax44_wickworks` |
| NorthShrine | 46, 32, 1.15 | `-46 -32 1.15 44` `wax44_northshrine` |
| WestShrine | 22, -28, 0.15 | `-22 28 0.15 44` `wax44_westshrine` |
| KingWick | 88, 0, 0.50 | `-88 0 0.50 44` `wax44_kingwick` |
| Commissary | 88, -32, -7 | `-88 32 -7 44` `wax44_commissary` |
| MurlocAlcove | 88, -52, -6.5 | `-88 52 -6.5 44` `wax44_murlocalcove` |
| BargainingTable | 136, 0, 0.50 | `-136 0 0.50 44` `wax44_bargaining` |
| PumpkinSty | 88, 32, 9.50 | `-88 -32 9.50 44` `wax44_pumpkinsty` |

If `C:\dev\wow-335\scout\` does not exist yet, **ask the user** to allow
creating the second client + `account create SCOUT` — do not kick ADMIN's
session (logging a second character on ADMIN disconnects Gonzalez).

The user asking to **run the visual walk** is consent to boot the scout and
SendKeys `.go` / `.gps` on **Walky only**.

- Do **not** SendKeys `{ESC}` on the login or character-select screen — that
  **quits Wow.exe**. ESC only after Walky is in the world, and only on the scout PID.

## Preflight (hard stop)

```
- [ ] Realm data has vmaps/044.vmtree AND vmaps/<Wmo>.wmo.vmo (>10KB)
      (live `/home/acore/server/data`, test `/home/acore/server-test/data`)
- [ ] Scout client started AFTER patch-4.MPQ was packed
- [ ] SOAP answers `server info` (scripts/scout-soap.ps1)
- [ ] User's fullscreen Wow is minimized or closed (exclusive D3D blanks captures)
- [ ] Scout is windowed 1024×768 (gxWindow=1), restored, not minimized
- [ ] Scout toon level >= `dungeon_access_template.min_level` (Waxworks is **7**).
      SOAP `character level Walky 10` before the first hop. Level 1 = transfer abort, not water.
- [ ] Combat filming: scout-say `.cheat god on` (not only `.gm on`). GM is not
      damage-immune; cart nova and boss AoE kill Walky, and teleports can drop GM.
```

Missing `.vmo` or leftover Scarlet WDT → do not hop. Underwater+fall → **abort**,
no Z-nudge.

## Movement (two channels)

`.go xyz` is **`Console::No`**. SOAP prefix-matches it to `.gobject`. Do not send
`.go` over SOAP.

| Need | Channel |
|---|---|
| Named, already-`.gps`'d stand | SOAP `tele name Walky <game_tele>` |
| First-pass / unproven xyz | SendKeys `.go xyz x y z <map>` into the **scout** chat (`scripts/scout-say.ps1`) |
| Support | SOAP `server info`, `revive Walky`, `character level Walky N` only |

WMO-local (Blender) is not `.go` world. For a WDT MODF at origin:

`.go xyz ≈ (-blenderX) (-blenderY) blenderZ <map>`

Z is a guess until `.gps` is in the screenshot.

## Per-room loop

1. Move (named `tele` or scout-chat `.go`).
2. Wait: same-map 2s; cross-map (0→44) 8s.
3. `scout-say.ps1 ".gps"` then 400ms.
4. `scout-capture.ps1` → `.agents/plans/<slug>/shots/walk-<map>/NN_<room>.png`
5. **Read the PNG** (vision). Score the table below. Read the `.gps` chat line
   in the same frame (map / xyz / zone / phase).
6. One room, then stop if FAIL. No hop chains.

```powershell
# SOAP (named tele only)
.agents/skills/walk-instance/scripts/scout-soap.ps1 -Command "tele name Walky wax44_mouth"

# Chat into the scout client (exploration + .gps)
.agents/skills/walk-instance/scripts/scout-say.ps1 -Text ".gps"

# Capture the scout window
.agents/skills/walk-instance/scripts/scout-capture.ps1 -OutFile ".agents/plans/waxworks-mesh/shots/walk-44/01_mouth.png"
```

## Vision rubric

| Verdict | Frame |
|---|---|
| **PASS** indoor cave | Rock walls on 3+ sides, dark ceiling, dim warm light, ground in the bottom half, no sky |
| FAIL leftover Scarlet | Pews, pillars, red carpet, arched windows, fountain; zone "Scarlet Monastery" |
| FAIL underwater | Blue-green wash, breath bar, swim pose |
| FAIL void/fall | Cyan/white void, skybox, "You have died", `.gps` Z collapsing |
| FAIL outdoor | Sky, trees, grass, Elwynn daylight |
| FAIL capture | Near-black PNG — fullscreen/minimized/occluded. Recapture once, then stop |

## Scout client config (`C:\dev\wow-335\scout\WTF\Config.wtf`)

```
SET gxWindow "1"
SET gxMaximize "0"
SET gxResolution "1024x768"
SET screenshotFormat "jpg"
SET screenshotQuality "10"
```

Leave the user's `ChromieCraft_3.3.5a` config alone. Junction `Data\` and
`Interface\` from the main client; real dirs for `WTF`, `Cache`, `Screenshots`.
Close **both** clients before packing `patch-4.MPQ`.

## Corridor walk (E2E navigability)

Named-room hops prove stands, not the tunnels between them. When the user
asks to walk start→finish, hop **along the corridor** at ~8y (scout-chat
`.go xyz`, not SOAP) and screenshot each hop. Fail if outdoor, swim, void,
or a wall blocks the tube. Keep |Y| inside the tunnel radius (~2.8y on the
main shaft). Suggested spine (map 44):

`-12 0 0.15` → `-24 0 0.15` → `-36 0 0.15` → `-46 0 0.15` → `-70 0 0.15`
→ `-88 0 0.50` → `-112 0 0.50` → `-136 0 0.50`

Wings from King Wick: commissary `-88 16 -3` then `-88 32 -7`; alcove
`-88 44 -6.5`; sty `-88 -16 5` then `-88 -32 9.5`; north `-46 -16 0.5`;
west `-18 14 0.15`.

## Not this skill

LoS chains, mmap coverage, loot tables, gossip, boss timers. Those stay
SQL / logs / PLAYTEST. Corridor floor **is** this skill when the user asks
for an E2E walk. A **playerbot 5-man** is combat/loot proof, not a camera —
Walky still has to be in the instance. `.playerbots bot addclass` is
`Console::No` (scout-say, not SOAP). Keep Walky on `.cheat god on`; skip her
from personal boss loot via `IsGameMaster()`.

## Setup (ask first)

One-time, with user consent:

1. Junctioned second client at `C:\dev\wow-335\scout\`.
2. SOAP `account create SCOUT <password>` and `account set gmlevel SCOUT 3 -1`.
3. User creates toon `Walky` (or SendKeys the char-create UI).
4. Add `game_tele` rows only after a stand is `.gps`-verified in a PNG.
