# Custom NPC skills (this fork)

How to put a **new person or creature** into the 3.3.5a client and this AzerothCore fork: a new
shape, new textures, new voice lines, and phrases that fire on scripted scenarios ("boss at 20%:
say this"). Everything here was checked against this repo's source (`ObjectMgr.cpp`,
`DBCStores.cpp`, `CreatureTextMgr.cpp`, `SmartScriptMgr.h`, `Unit.cpp`) and the fork's shipped
dungeons; external tool notes say so where they rely on community tooling.

Read the fork context first (`AGENTS.md` § "This fork", [`../README.md`](../README.md)), then
[`../../.agents/docs/systems/client-data.md`](../../.agents/docs/systems/client-data.md): an NPC
is the same client–server contract as a map. Whatever the client renders or plays (M2, BLP, DBC
rows, sound files) ships in `patch-4.MPQ` / `patch-enUS-4.MPQ`; whatever the server validates
(display ids, model data, sound ids, texts) ships as world-DB SQL in `pending_db_world/`.

## The four layers of an NPC

```
world DB                         client + server DBC                      client files (MPQ)
creature_template
 └ creature_template_model.CreatureDisplayID
    └► CreatureDisplayInfo.dbc
        ├ ModelID ──────────────► CreatureModelData.dbc.ModelName ──────► Creature\X\X.m2 + X0N.skin
        ├ TextureVariation_1..3 ────────────────────────────────────────► Creature\X\<name>.blp
        ├ ExtendedDisplayInfoID ► CreatureDisplayInfoExtra.dbc.BakeName ► Textures\BakedNpcTextures\<Bake>.blp
        ├ SoundID ──────────────► CreatureSoundData.dbc ► SoundEntries ► Sound\Creature\X\*.wav|mp3
        └ NPCSoundID ───────────► NPCSounds.dbc ────────► SoundEntries
creature_text (phrase groups; Sound = SoundEntries id)  ◄── smart_scripts (SmartAI) or C++ Talk()
```

| Layer | Doc | Ships as |
|---|---|---|
| Template, display id, model data, collision, server checks | [`model-chain.md`](model-chain.md) | SQL (`creature_template*`, `creature_model_info`, `*_dbc` overlays) + DBC rows in `patch-enUS-4` |
| Which way to a new look (re-skin → kitbash → new rig) | [`appearance-paths.md`](appearance-paths.md) | decision only |
| Textures: BLP format, style rules, tools | [`textures-blp.md`](textures-blp.md) | BLP files in `patch-4` |
| Models: M2/skin facts, Blender + M2Mod, animations | [`models-m2.md`](models-m2.md) | M2 + `.skin` files in `patch-4` |
| Voice lines and creature sounds | [`sounds.md`](sounds.md) | wav/mp3 in `patch-4`, `SoundEntries.dbc` + overlay |
| Phrases and the scenarios that trigger them | [`phrases-and-triggers.md`](phrases-and-triggers.md) | `creature_text` + `smart_scripts` or C++ |
| Pack, publish, deploy, verify | [`ship-and-verify.md`](ship-and-verify.md) | bundle + `manifest.json` |
| One NPC end to end | [`worked-example.md`](worked-example.md) | example SQL/DBC/files |

## Decision ladder (cheapest that satisfies the brief wins)

| Want | Path | New client files | New DBC rows | Effort |
|---|---|---|---|---|
| Same look as an existing NPC | reuse a Blizzard display id | none | none | minutes |
| Same shape, **new skin/colours** | new `CreatureDisplayInfo` row, new BLP via `TextureVariation` | BLP | CDI (+ server overlay) | hours |
| New **person** (human, orc, …) with custom face/hair/gear | `CreatureDisplayInfoExtra` row (+ optional baked BLP) | optional BLP | CDI + CDIExtra | hours |
| Different size, opacity, hidden/shown parts, particle colour | CDI `CreatureModelScale` / `CreatureModelAlpha` / `CreatureGeosetData` / `ParticleColorID` | none | CDI | hours |
| **New shape**, existing animations | kitbash or rig-transplant in Blender via M2Mod, new BLP | M2 + skins + BLP | CDI + CMD | days |
| New shape **and** new animations | new M2 with own skeleton and sequences | M2 + skins + BLP | CDI + CMD | weeks; toolchain unstable |
| Custom **voice lines** | wav/mp3 + `SoundEntries.dbc` + `creature_text.Sound` | audio | SoundEntries (+ overlay) | hours per NPC |
| Automatic grunts (aggro/wound/death) | `CreatureSoundData.dbc` + CDI `SoundID` | audio | CSD + SoundEntries | hours |

Rule of thumb from the art side: Blizzard's 3.3.5 creatures are a low-poly mesh (1–8k triangles)
with one hand-painted 256²–512² diffuse and no normal/specular maps. A **re-skin or a kitbash on an
existing skeleton** already looks native; a new rig almost never does. Spend the effort on the
texture and the silhouette, not on a new skeleton.

## Hard rules (server-crash and client-crash class)

- Every `CreatureDisplayID` a creature can use must exist in **both** the client `CreatureDisplayInfo.dbc`
  and the server's copy (file or `creaturedisplayinfo_dbc` overlay). Server missing it → row rejected
  with "lists non-existing CreatureDisplayID … this can crash the client". Client missing it → the
  client crashes when the creature comes into view.
- Every `ModelId` referenced by a display row must exist in the server's `CreatureModelData`:
  `Unit::GetCollisionWidth/Height` uses `AssertEntry` → **worldserver assert** otherwise.
  Ship `creaturemodeldata_dbc` in the same SQL as the display row.
- `CreatureDisplayInfoExtra.BakeName` must not be empty or the client crashes (wowdev).
- `creature_text.Sound` and `.Emote` are validated at load against `SoundEntries.dbc` / `Emotes.dbc`
  and silently zeroed when missing → ship the `soundentries_dbc` overlay row with the text.
- `creature_model_info` needs a row per new display id or bounding radius / combat reach fall back
  to defaults with a load error.
- Client files go in the **one** `Data/patch-4.MPQ` (world files: `Creature\`, `Textures\`,
  `Sound\`) and `Data/enUS/patch-enUS-4.MPQ` (DBCs). Binaries never enter git.
- Changing rows the client already cached (name, subname, display of an existing entry) needs a
  `client_cache_version` bump in `manifest.json`; brand-new entries do not.

## Custom id registry (DBC side)

World-DB ids for creatures/items/texts come from the dungeon's `9000000+` block in
[`../../.agents/docs/systems/dungeons.md`](../../.agents/docs/systems/dungeons.md). DBC ids are a
separate space; reserve here before writing rows. Keep display ids below 65536 so `.morph`
and every uint16 client path stay safe.

| DBC | Blizzard max (3.3.5) | Fork block | Reserved |
|---|---|---|---|
| `CreatureDisplayInfo` | ~31 000 | `60000–60999`, 20 per NPC set | — |
| `CreatureModelData` | ~3 300 | `60000–60999` (same number as its first display id) | — |
| `CreatureDisplayInfoExtra` | ~13 000 | `60000–60999` (same number as the display id) | — |
| `CreatureSoundData`, `NPCSounds` | ~3 000 / ~600 | `60000–60999` | — |
| `SoundEntries` | ~17 000 | `90000–90999`, 10 per NPC (1 row = 1 phrase, up to 10 files) | — |

## Master checklist

```
- [ ] Brief: species/shape, size class, faction/role, 3–6 phrases with their triggers, voice yes/no
- [ ] Path chosen from the ladder; source M2/skeleton named if kitbashing
- [ ] Ids reserved: world-DB block (dungeons.md) and DBC block (table above)
- [ ] Textures painted as BLP at the exact MPQ path (textures-blp.md)
- [ ] Model exported + previewed in WoW Model Viewer, all needed animations play (models-m2.md)
- [ ] DBC rows: CDI (+CMD, +CDIExtra) in patch-enUS-4 and the same rows as *_dbc overlay SQL
- [ ] creature_template + creature_template_model + creature_model_info (+ equip, addon) SQL
- [ ] creature_text groups per scenario; SmartAI or C++ trigger per group (phrases-and-triggers.md)
- [ ] Audio files + SoundEntries rows + soundentries_dbc overlay; Sound set on the text rows
- [ ] Packed as MPQ v2, installed in the dev client, Wow restarted, `.npc add` shows it
- [ ] Bundle built, published, manifest committed with the SQL; test realm verified (ship-and-verify.md)
```

## Where this sits in the fork's docs

Human prose: this folder. Agent model for the data contract: `.agents/docs/systems/client-data.md`.
Procedure for the MPQ/bundle/deploy mechanics: `.agents/skills/build-client-patch/SKILL.md`. Dungeon
content bar (loot, pulls, spacing): `.agents/skills/build-dungeon/reference-content.md`. When this
folder is merged into the branch that carries `docs/README.md`, add one row under "Custom content
and client patches" pointing at this `README.md`, and a routing bullet in `AGENTS.md`
("New NPC model / texture / voice / phrases → `docs/custom-npc-skills/README.md`").
