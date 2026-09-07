---
name: build-creature-model
description: >-
  Build a genuinely new, animated 3.3.5a creature model (M2 + skins + BLP) in code by transplanting
  a procedurally generated or Blender-authored mesh onto a Blizzard skeleton, then ship it through
  CreatureModelData/CreatureDisplayInfo rows and the client patch. Use when asked for a creature
  shape that no existing display id gives (new body, new limbs, new texture), when editing M2/skin
  bytes, writing BLP2/DXT1, appending DBC rows, or when M2Mod/WBS M2 export are not an option.
---

# Build a new creature model (code-only rig transplant)

Read `docs/custom-npc-skills/models-m2.md` and `model-chain.md` first (format facts, DBC chain,
crash rules). This skill is the working procedure and its scripts; the worked case is the Waxworks
candle boss (`Creature\WaxCandle\WaxCandle.m2`, display 60000).

Shipping the result: pack MPQs into `client-patches/sources/client/mpq/`, overlay map-44
vmaps/mmaps into `sources/server/`, then `build-bundle.ps1` per `docs/client-patches.md`.
Git gets **`manifest.json` only**. Visual proof: `walk-instance`.

## Why bytes instead of Blender export

WBS M2 export is broken for animated models and M2Mod is a GUI round trip with version pairing.
Blizzard animation data is the hard part; geometry is not. So: keep every byte of a donor M2
(bones, tracks, sequences, particles, attachments, events, cameras), append new geometry arrays at
the end of the file and repoint the header. Skins are pure geometry and are rewritten from scratch.
Verified on the donor and in game (client did not crash, all sequences play):

- M2 v264 header field offsets used by `12_splice_m2.py` (name 8 … particles 296, 304 bytes when
  flags lacks 0x8). Arrays may live anywhere in the file; appended 16-byte-aligned arrays work.
- `M2Vertex.bone_indices` are **direct bone ids**. Skin `bones[ubyte4]` are **palette indices** into
  `bone_lookup_table[submesh.boneComboIndex : +boneCount]`. Both must agree.
- Triangles are wound counter-clockwise seen from outside (543/564 on the kobold).
- Particle `position` and attachment `position` are model space (equal to the bone pivot when
  "on the bone"); the bone only transforms them.
- A bone with zero keys can be cloned into a new bone (change parent/flags/pivot); flag `0x8` makes
  it a spherical billboard (used for the flame quad), `0x200` = transformed.
- `M2Sequence` is 64 bytes, bounds at +32; per-sequence bounds are used for culling: widen them for
  taller/longer meshes or the model pops out when it rotates. DisplayScale 3 still culls in **model
  space** — keep sequence bounds and SKIN submesh radii fat (radius×3+2).
- Sequence flag `0x20` means keys live **in the M2** (not `<Name>%04d-%02d.anim`). Clone Stand, set
  `id` to the AnimationData id (Dance = **69**), keep `0x20`, extend every per-sequence track (bones
  **and** `$events`) by cloning the Stand slot, then overwrite Dance keys. `sequence_lookup` is
  indexed by animation id; grow it (`0xFFFF` = missing) and set `lookup[69]`. Kobold's table is only
  31 long, so 69 is missing until you grow it.
- Rotation keys are `M2CompQuat` int16; identity on disk is `(32767,32767,32767,-1)`. Decode is
  `(s<0 ? s+32768 : s-32767)/32767`. pywowlib stores x negated and writes `y,-x,z,w`.
- `EMOTE_STATE_DANCE = 10` (SmartAI 17) / `EMOTE_ONESHOT_DANCE = 94` (SmartAI 5) only look like a
  dance if the M2 lookup maps 69. `EmoteCry` is AnimationData **77** (`EMOTE_ONESHOT_CRY = 18`).
- External `.anim` files are looked up by the **M2 file name**: `<Name>%04d-%02d.anim` must be
  copied/renamed with the model.
- Texture type 11 needs no path in the M2: `CreatureDisplayInfo.TextureVariation_1` names the BLP in
  the model's folder. Texture flags 0 = clamp, so keep UVs inside [0, 1] and put wrap seams at the
  back of the body.
- Blizzard creature skins are BLP2 DXT1 with a full mip chain (`blp.py` writes that; 512² → 10 mips).
- WDBC rows can be appended by rewriting header counts and extending the string block (`dbc.py`);
  ids 60000+ are accepted by client and server (fork registry: `docs/custom-npc-skills/README.md`).

## Toolchain (this machine)

Blender 3.4.1's Python (`C:\dev\tools\blender\blender-3.4.1-windows-x64\3.4\python\bin\python.exe`)
with `pip install bidict pillow`, plus pywowlib from the WBS add-on
(`C:\dev\tools\blender-wow-studio\io_scene_wmo`, env `WBS_ROOT`): StormLib MPQ reading, M2/skin
parsing for inspection. MPQEditor for packing. No M2Mod, no WMV needed. Face/flame art came from
image generation (`assets/waxcandle/`); everything else is procedural.

## Procedure

```
Task progress:
- [ ] Donor chosen by stance/limb count; extracted (01) and inspected (02, 03)
- [ ] Mesh generated/exported with UVs + ≤4 weights per vertex onto donor bone ids (10)
- [ ] Texture sheet composed and encoded BLP2 DXT1 (11); layout matches the mesh UVs
- [ ] M2 spliced + skins written + .anim copied (12); parses back with pywowlib
- [ ] Blender preview renders look right (20) BEFORE any client test
- [ ] DBC rows appended + overlay SQL emitted (13); SQL added to pending_db_world
- [ ] Packed into patch-4 (+Creature\) and patch-enUS-4 (DBFilesClient\) and installed (30)
- [ ] Worldserver restarted: "Loaded N Creature Model Based Info" grew by one, no display errors
- [ ] Scout: .morph <display> / spawn; stand, walk, attack, death, no crash; screenshots reviewed
```

Scripts (`scripts/`, run in order; all paths configurable via `WBS_ROOT`, `WOW_CLIENT`, `CREATURE_OUT`):

| Step | Script | Output |
|---|---|---|
| 1 | `01_extract_donor.py` | `out/donor/Creature/<Donor>/*`, `out/donor/DBFilesClient/*.dbc` |
| 2 | `02_inspect_donor.py`, `03_skin_raw.py` | bone tree with pivots (pick bones to bind to), sequences, palette proof |
| 3 | `10_build_mesh.py` | `out/mesh.json` — edit the geometry/weights here (or replace with a Blender exporter that writes the same JSON) |
| 4 | `11_texture.py` (+`blp.py`) | `out/WaxCandleSkin.blp` + `.png`; UV regions documented at the top of the script |
| 5 | `12_splice_m2.py` | `out/Creature/<New>/<New>.m2`, `<New>0N.skin`, `.anim`, `.blp` |
| 6 | `20_preview_blender.py` | `out/preview_{front,side,back}.png` via `blender -b --python … -- <scripts dir>` |
| 7 | `13_dbc.py` (+`dbc.py`) | `out/DBFilesClient/*.dbc`, `out/dbc_overlay.sql` |
| 8 | `30_pack_and_install.ps1` | repacked `patch-4.MPQ` / `patch-enUS-4.MPQ`, installed, WDB cleared |

Then: paste `dbc_overlay.sql` into the feature's `pending_db_world` file, point
`creature_template_model` at the new display id, restart worldserver, verify with the scout.

## Designing the mesh against a donor rig

- Model in donor units and let `CreatureDisplayInfo.CreatureModelScale` (or `DisplayScale`) size it;
  bones cannot be moved without rewriting tracks. Kobold body top 1.42 × 1.3 ≈ 6 ft.
- Weight by chain, not by nearest bone: body rings blend waist→spine-lo→spine-up by height; tubes
  blend segment start/end bones by parameter. Keep hips/shoulders inside the body so joints stay hidden.
- Hunched donors (kobold head pivot 0.34 vs spine-up 0.07) **shear a vertical mesh** if the crown/face
  is weighted to bone 14: the lid yaws off the body on turn/walk. Bind cylinder top, dish, wick and
  the flame parent to **spine-up (4)**. Billboard/particle bones must follow that parent.
- Triangle budget 800–3 000; uint16 indices; sort submeshes: opaque body first, blended flame last.
- Additive flame: unlit | two-sided | no-depth-write material, blend 4, sprite on **black** with a
  margin inside its UV region (mips bleed neighbours).

## Pitfalls met

- pywowlib's `Array` type is not iterable/subscriptable: use `struct` for skin per-vertex bones.
- `import io_scene_wmo` needs `bpy`; add `…\io_scene_wmo` itself to `sys.path` and import `pywowlib`.
- PowerShell `Get-Process | Select-Object` after an error prints nothing — check `Wow.exe` with
  `ForEach-Object` before concluding the client crashed.
- `Bitmap.Save` needs an absolute path (GDI+ "generic error" otherwise).
- SendKeys automation types into whatever window has focus: never run it while the user is typing.
- The scout's `Data\` is a junction to the main client's `Data\` — installing there patches both.
