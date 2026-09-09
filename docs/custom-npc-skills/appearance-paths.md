# Appearance paths: how far to go for a new look

Back to [`README.md`](README.md). Data details: [`model-chain.md`](model-chain.md).

Six ways to make an NPC look new, ordered by cost. Each row says what you author, what ships on
the client, and what the result can and cannot be. Pick the lowest row that meets the brief.

## A. Reuse a Blizzard display id

`creature_template_model.CreatureDisplayID = <existing id>`. Nothing ships. Every fork NPC so far
(Waxworks, Vault, Belfry) is this path with a new name, level, stats, equipment and phrases. Use
`creature_equip_template` (weapon item ids) and `creature_addon` (`bytes1` stand state, `emote`,
`mount`, `auras`) to change the read of a borrowed model. Combine with `DisplayScale` on the
`creature_template_model` row for size.

Limits: shape, skin and sounds are the original's. Players recognise the model instantly.

## B. Re-skin: same M2, new texture

A new `CreatureDisplayInfo` row that points at the **existing** `ModelId` but names new textures in
`TextureVariation_1..3`. The client looks the names up in the **M2's own folder**
(`Creature\<Model>\`), without path and without `.blp`. So the archive carries
`Creature\Kobold\KoboldTallow.blp` and the row says `TextureVariation_1 = 'KoboldTallow'`.

Only geometry with M2 texture type **11/12/13** (monster skin 1–3) is replaceable this way; a
model with a hardcoded (type 0) texture ignores `TextureVariation` for that unit. Check with WoW
Model Viewer (Textures tab) or an M2 template before painting. Most beasts, humanoid monsters and
demons are type 11; many "prop" M2s are type 0.

What you author: one BLP per variation slot ([`textures-blp.md`](textures-blp.md)). New DBC rows:
CDI on client and server overlay, `creature_model_info`. Cost: hours. This is the path that looks
most native, because the mesh, UVs and animations are Blizzard's.

## C. New person: `CreatureDisplayInfoExtra`

Humanoid NPCs built on a **player race** body (`Character\Human\Male\HumanMale.m2` etc.) get
their appearance from `CreatureDisplayInfoExtra`: race, sex, skin/face/hair/facial-hair indices
(from `CharSections.dbc`), eleven `NPCItemDisplay` slots (ItemDisplayInfo ids: head, shoulder,
shirt, chest, belt, legs, boots, wrist, gloves, tabard, cape) and `BakeName`, a pre-composited body
texture under `Textures\BakedNpcTextures\`.

Two sub-paths:

- **DBC-only person**: pick race/sex/face/hair and armour display ids, set `BakeName` to an
  existing Blizzard bake for that race/sex/skin (copy from a similar NPC's row). No client file.
  Ships as two DBC rows (CDI with `ExtendedDisplayInfoID`, CDIExtra).
- **Custom bake**: paint your own body texture (tattoos, scars, uniform painted onto skin) and ship
  it as `Textures\BakedNpcTextures\<BakeName>.blp`. Same UV layout as the race's skin sections.

The server reads `DisplayRaceID` only (`Unit::GetDisplayRace`-style lookups). Weapons still come
from `creature_equip_template`, not from CDIExtra. `BakeName` must never be empty (client crash).

## D. Tweaks on the display row

Without new files, a CDI row can change: `CreatureModelScale` (stacks with template scale),
`CreatureModelAlpha` (0–255 opacity; ghosts), `CreatureGeosetData` (which geoset groups render; the
meaning is per model, packed as hex nibbles), `ParticleColorID` (recolours particle emitters that
opt in), `BloodID`, `SoundID` / `NPCSoundID` (new voice set, see [`sounds.md`](sounds.md)).

Useful with B and C: a re-skinned kobold with a different candle geoset and a new voice reads as
a new creature.

## E. New shape on an existing skeleton (kitbash / rig transplant)

The practical "any creature" path. Tooling and procedure: [`models-m2.md`](models-m2.md).

- **Kitbash**: export a Blizzard M2 to `.m2i` (M2Mod), import in Blender, delete/merge/move
  submeshes, sculpt proportions while keeping bone weights, add props as new submeshes weighted
  to a bone, export `.m2i`, rebuild the M2 with M2Mod using the original as the base (skeleton and
  animation sequences are copied through untouched).
- **Rig transplant**: model a brand-new mesh in Blender, then bind it to the imported skeleton of
  the closest Blizzard creature (same limb count and stance), transfer weights, export as above.
  Result: your silhouette, Blizzard's walk/attack/death.

Ships as `Creature\<New>\<New>.m2` + `<New>00.skin`…`03.skin` + BLPs, a new `CreatureModelData`
row (path, collision box, scale) and a CDI row. Days of work per creature, mostly texture painting.
Whatever skeleton you borrow also fixes the animation vocabulary: a kobold rig cannot fly.

## F. New skeleton and animations

Authoring bones, keyframes and the full sequence list (`AnimationData.dbc` ids the client expects:
Stand 0, Death 1, Walk 4, Run 5, wound, attacks, spell casts, emotes) in a tool that writes WotLK M2
animation blocks. In 2026 that is WoW Blender Studio's M2 exporter, which this fork's own notes
describe as broken for animated models and unstable for static ones
(`.agents/skills/build-dungeon/reference-blender-wmo.md`). Retro-porting a newer Blizzard model
with MultiConverter is the only reliable "new skeleton" route and produces Blizzard art, not ours.
Treat F as research, not a plan; every brief so far is satisfiable with B–E.

## Choosing

| Brief says | Path |
|---|---|
| "A tallow-covered kobold" | B (+D geoset) |
| "The wax foreman, a scarred human in a leather apron" | C with custom bake, or A + equip |
| "A candle golem, humanoid, made of wax" | E rig transplant onto a golem or abomination skeleton, new BLP |
| "A six-legged wax spider" | E kitbash on the spider skeleton (spiders have eight legs; hide two geosets or merge) |
| "A serpent with wings" | E is a stretch (no serpent+wings rig); reconsider or accept a drake skeleton |
