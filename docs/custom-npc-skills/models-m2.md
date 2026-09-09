# Models: M2 facts, Blender round trip, new shapes

Back to [`README.md`](README.md). Which path you need: [`appearance-paths.md`](appearance-paths.md).
Textures: [`textures-blp.md`](textures-blp.md). DBC rows for the new model: [`model-chain.md`](model-chain.md).

Tool facts in this file come from the community WotLK modding toolchain (M2Mod, blender-m2i-scripts,
WoW Model Viewer, MultiConverter, wowdev.wiki) and from this fork's own WBS notes; they are not
verified by this repo's code. Re-check versions before a long job.

## What a 3.3.5 creature model is

| File | Content |
|---|---|
| `Creature\<Dir>\<Name>.m2` (M2 version **264**) | Header, vertices (position, 4 bone indices + 4 weights, normal, 2 UV sets), bones with parent tree and animation tracks, sequences (animation list), texture definitions (type + path), materials/render flags, attachments (weapon hands, head, breath), events (footsteps, sounds), particle emitters, ribbons, cameras, bounding boxes |
| `<Name>00.skin` … `<Name>03.skin` | Four **skin profiles** (LODs). Each lists the vertex subset, submeshes (geosets: id, bone lookup), and texture units (which texture/material renders which submesh). The client picks by distance; `00` is the full-detail one |
| `*.blp` in the same folder | Textures (type-0 paths are inside the M2; types 11–13 come from `CreatureDisplayInfo.TextureVariation`) |
| `*.anim` | External animation data for some sequences (Blizzard offloads rarely played animations). M2Mod keeps them with the donor; not something you author |

Numbers to respect: `uint16` indices everywhere → at most **65 535 vertices** per model and
**≈21 845 triangles** per skin profile (65 535 indices / 3). Up to **4 bone influences** per vertex.
Bone count in a skin's bone lookup table is limited per submesh (keep a submesh ≤ ~50 bones).
Blizzard 3.3.5 creatures: 800–3 000 triangles for trash, 5 000–8 000 for a raid boss.

Texture types in the M2 texture block: `0` hardcoded path, `1` player skin, `2` object skin
(items, capes), `6` hair, `7` facial hair, `8` skin extra, `11`/`12`/`13` monster skin 1–3
(replaced by `TextureVariation_1..3`), `14` item icon.

Animation sequences are keyed by `AnimationData.dbc` ids. The client expects at least: Stand `0`,
Death `1`, Spell `2`, Stop `3`, Walk `4`, Run `5`, Dead `6`, Rise `7`, StandWound `8`,
CombatWound `9`, CombatCritical `10`, AttackUnarmed `16`, Attack1H `17`, Attack2H `18`,
ReadyUnarmed `27`, Ready1H `28`, SpellPrecast `37`, SpellCast `38`, EmoteTalk `60`. Missing ones
fall back to Stand (T-pose if `0` is missing too). Borrow the skeleton and you get all of them.

## Toolchain (Windows dev box)

| Tool | Role | Version pairing |
|---|---|---|
| **M2Mod** ("M2Mod Redux") | M2 + skins ↔ `.m2i` (intermediate). Rebuilds an M2 from the **original M2 as base** + edited `.m2i`; copies bones, sequences, particles, attachments through | Classic pairing for 3.3.5: M2Mod Redux **4.5 / 4.6.1** with the Blender 2.7x `blender-m2i-scripts`. Newer M2Mod (8.x–10.x, "Shadowlands/DF" models) reads modern M2 and writes an `.m2i` the newer scripts understand; both directions must use the **same** M2Mod ↔ script tag |
| **blender-m2i-scripts** | Blender add-on: import/export `.m2i`, bone/submesh panels | bitbucket `suncurio/blender-m2i-scripts` (Blender 2.77–2.79b); `LunNova/blender-m2i-scripts` fork for Blender 2.93+/3.x |
| **Blender** | Mesh editing, weight painting, UV export | 2.79b for the classic scripts; 3.x for the fork. This is separate from the **3.4.1 + WBS** install used for WMOs — do not mix add-ons |
| **WoW Model Viewer** 0.7.0.x / 0.8 | Preview model + animations + `TextureVariation` from the patched client folder | Point it at the client with `patch-4` installed |
| **010 Editor** + M2/skin binary templates | Inspect/patch header fields (skin profile count, texture types, bounding box) | Optional; M2Mod handles the common cases |
| **MultiConverter** | Down-convert Legion+/Shadowlands M2 to WotLK 264 | Retro-porting only |
| **WoW Blender Studio** M2 exporter | Writes M2 from scratch incl. animations | Broken for animated, unstable for static per this fork's notes; not on the path |

## Procedure A: kitbash on an existing skeleton

1. Extract the donor: `Creature\<Donor>\<Donor>.m2`, `<Donor>0[0-3].skin`, its BLPs (MPQEditor from
   `common.MPQ`/`common-2.MPQ`/`expansion.MPQ`/`lichking.MPQ`; wow.export "Legacy" shows which archive).
2. M2Mod → **Export**: input `<Donor>.m2` → `<Donor>.m2i`.
3. Blender → Import `.m2i`. You get submeshes (one object per geoset), an armature, UVs, weights.
4. Edit: delete geosets you do not want, merge others, move/scale vertices **in weight-painted
   mode** so weights follow, sculpt with Grab/Inflate (topology unchanged), add props as new
   objects: give them a material, UV them into free texture space, weight them 100% to one bone
   (e.g. head bone for a hat). Keep the triangle budget and 4 influences (Blender: Limit Total).
5. Export `.m2i`. M2Mod → **Import**: base `<Donor>.m2` + your `.m2i` → `Export\<New>.m2` and skins.
   Tick options to keep the original skeleton/animations/particles/attachments.
6. Rename to your model name if you want a separate `CreatureModelData` row (`<New>.m2`, `<New>00.skin`…).
   M2Mod writes skins with matching names; the M2 does not store its own file name.
7. Fix textures: type-0 paths inside the M2 still point at `Creature\<Donor>\…`. Either keep the
   donor folder for your BLPs, or edit the paths (M2Mod texture remap or 010). For types 11–13 leave
   them and set `TextureVariation` on the CDI row.
8. Preview in WMV: every animation in the list plays, no exploding vertices (bad weights), no
   missing submesh at LOD 1–3 (copy skin `00` over `01–03` when in doubt: set the same file four times).
9. Stage: `client-patches/sources/client/loose/Creature/<Dir>/…`. Pack, restart Wow, `.morph`.

## Procedure B: rig transplant (new shape, borrowed animations)

Same as A, but after step 3 delete **all** donor geometry, keep the armature, bring in your own mesh
(modelled in Blender or elsewhere, triangulated, ≤ budget), parent it to the armature, Weight
Paint → **Transfer Weights** from a hidden copy of the donor mesh (nearest face interpolated), then
clean up (Limit Total 4, Normalize All). Test with the donor's Walk and Attack sequences inside
Blender before exporting. Attachments (weapon in right hand, helmet) are bone-relative and survive.
Choose the donor by stance and limb count: bipedal upright → human/orc/kobold; hulking → ogre/
abomination; quadruped → wolf/boar; multi-leg → spider/crab; serpentine → naga/worm; flying →
bat/drake. What you cannot borrow: a different gait or a new emote.

## Procedure D: code-only rig transplant (proven on this fork)

No M2Mod, no WBS export: keep the donor M2 bytes (bones, tracks, sequences, particles), append a
new vertex array, bone lookup, materials and bones, repoint the header, and rewrite the skins from
scratch. Mesh, weights, texture (BLP2 DXT1) and DBC rows are all generated by scripts run with
Blender's Python + pywowlib. Procedure, format facts verified in game and the scripts:
[`.agents/skills/build-creature-model/SKILL.md`](../../.agents/skills/build-creature-model/SKILL.md).
First result: `Creature\WaxCandle\WaxCandle.m2` (display 60000), a walking candle on the kobold rig.

## Procedure C: Blizzard variants without Blender

Some "new" creatures are pure data on an existing M2: `CreatureGeosetData` on the CDI row toggles
geoset groups (helmets, tails, extra spikes — the meaning is per model, nibble per group, read the
model in WMV); `CreatureModelScale`/`CreatureModelAlpha`; `ParticleColorID` recolours emitters that
have the "use particle colour" flag. Combine with a re-skin for a quick second boss variant.

## Collision and hitbox for a new/edited model

`CreatureModelData`: `CollisionWidth/Height` (server hitbox, see model-chain.md), `GeoBoxMin/Max`
(client selection box), `ModelScale`. Start from the donor's values times your scale factor. The M2
also stores a bounding box/radius used by the client for culling; check it after an M2Mod rebuild
(WMV shows a model that pops in late or disappears when the camera is close if it is too small).

## QA before shipping

- WMV: Stand/Walk/Run/Attack/Death play; no missing geoset at any LOD; textures resolve (no white).
- In game (`.morph <id>` on your own character, then `.npc add`): no client crash when it enters
  view, correct size, selection circle matches feet, melee reach feels right, death pose lands on
  the floor (Death sequence keeps bone 0 sensible), no z-fighting between kitbashed shells.
- worldserver log: none of the display/model errors in model-chain.md.
- Second machine with a clean client + `update-client.ps1`: proves the files are in the archive,
  not lingering loose in your dev `Data\`.

## Pitfalls

- Editing the `.m2i` with a different M2Mod version than the one that exported it → garbage import.
- Forgetting the three lower LOD skins → creature disappears at 20–40 yards.
- Texture type 0 path still pointing at the donor folder after renaming → white model unless the
  donor BLPs are present.
- Over 4 bone influences or unnormalized weights → stretched vertices in animation.
- Triangle count above the uint16 limit → client crash on load.
- Scaling the mesh without scaling collision/GeoBox/model_info → hitbox and selection mismatch.
- Loose files in `<client>\Data\Creature\...` during iteration are handy (client reads them before
  MPQs) but must not be left behind, or your tests pass while players see nothing.
