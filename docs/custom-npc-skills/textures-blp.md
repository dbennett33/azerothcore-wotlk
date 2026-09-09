# Textures: BLP files and the Blizzard 3.3.5 look

Back to [`README.md`](README.md). Where a texture is referenced from: [`model-chain.md`](model-chain.md).

## Format facts

- Client format is **BLP2** (`BLP2` magic). Two encodings matter: **DXT** (DXT1 opaque, DXT3/DXT5
  with alpha; smallest, what nearly every 3.3.5 creature skin uses) and **palettized** 256-colour
  with 0/1/4/8-bit alpha (crisper for hard-edged UI art). Uncompressed BLP exists but is not used for
  creatures.
- Dimensions must be powers of two. Creature skins in 3.3.5 are 256×256 or 512×512 (bosses,
  player races); 1024 is the practical ceiling. A 256² DXT1 skin with mips is ~43 KB.
- Ship **mipmaps** (all tools generate them). Without mips the model shimmers at distance.
- Path length in the DBC overlay tables is `varchar(100)`; keep folder + name short.
- `TextureVariation_N` values are bare names (`KoboldTallow`), resolved in the M2's folder; the M2's
  own type-0 textures are full paths inside the M2. `BakeName` is a bare name under
  `Textures\BakedNpcTextures\`.
- MPQ paths are case-insensitive on the client but keep Blizzard casing (`Creature\Kobold\…`).

## Tools

| Task | Tool | Notes |
|---|---|---|
| PNG/TGA → BLP, BLP → PNG | **BLP Lab** (GUI, Windows) or **BLPConverter** (CLI, `BLPConverter.exe /FBLP_DXT1 file.png`) | Pick DXT1 when the alpha channel is unused; DXT5 for soft alpha (fur edges, glows); DXT3 for hard 1-bit alpha |
| Edit BLP directly | Photoshop / GIMP / Paint.NET BLP plug-ins | Round-trip through PNG is fine; BLP is lossy under DXT so keep the PNG master |
| Pull Blizzard textures for reference | wow.export "Open Legacy Installation" → Textures, export PNG; or MPQEditor extract from `common.MPQ` / `common-2.MPQ` | Use them as **palette and stroke reference**, never as shipped assets |
| See UVs to paint over | Blender after the `.m2i` import ([`models-m2.md`](models-m2.md)) → UV editor → Export UV Layout | 2048 PNG export, paint at 1024, downsample to the shipping size |
| Preview on the model | WoW Model Viewer 0.7/0.8 with the patched client, or in game via `.morph <displayid>` after packing | WMV reads the loaded MPQ chain including `patch-4` |

## Making it look like a 3.3.5 creature

Blizzard 2004–2010 creature skins share a recipe. Follow it and a re-skin passes as native:

1. **Diffuse only.** No normal, specular, emissive maps. Everything — highlights, shadows,
   ambient occlusion, rim light, wetness — is painted into the colour map.
2. **Painted lighting from above and slightly front.** Top planes lighter and warmer, undersides
   darker and cooler. Cavities (armpits, under jaw, between fingers) get deep painted AO.
3. **Big value contrast, mid saturation, one accent.** Read the silhouette in the thumbnail.
   Blizzard limits a creature to two or three hues plus one saturated accent (eyes, runes, wax drips).
4. **Edge highlights and thick outlines** on hard materials (metal, chitin, wax); soft gradients on
   organic ones. Hand-drawn strokes, not photo textures. 256² leaves no room for noise.
5. **Texel density**: the face and hands get the most pixels; big flat areas (back, cloak) get
   fewer. Copy the donor's UV allocation; it already does this.
6. **Colour variants** are how Blizzard gets three creatures from one mesh (`TextureVariation`
   slots; kobold, red kobold, blue kobold). Design your base skin with a hue shift in mind.
7. **Alpha**: DXT5 alpha for fur/hair edges and torn cloth; the material blend mode lives in the M2
   (render flag `blending_mode` 1 = alpha key, 2 = alpha blend). A re-skin inherits the donor's
   flags, so paint alpha only where the donor already uses it.
8. **Team/faction read**: recolouring to warm reds/oranges says enemy, cool greens/blues says
   allied or neutral in vanilla zones. Keep dungeon trash in the boss's palette family.

Practical loop: import the donor `.m2i` into Blender, export the UV layout, extract the donor BLP
to PNG, paint on top of it in layers (keep Blizzard's shading layer, replace the colour and
markings layers), export PNG → BLP DXT1, drop the BLP into `Creature\<Model>\` in the loose tree,
repack, restart Wow, `.morph`.

## Humanoid bakes (`BakedNpcTextures`)

A player-race NPC's body is one composited texture (skin + underwear + painted shirt/pants/tabard
if not on real items). Blizzard ships thousands of these under `Textures\BakedNpcTextures\`; the
layout equals the race's `CharSections` skin atlas (torso top-left, legs, arms, face at the
bottom-right on 256×256 for 3.3.5). To make a custom person: extract a bake of the same race/sex/skin
tone, paint scars, tattoos, uniform details, save as `<YourBake>.blp` at the same path, and put the
bare name in `CreatureDisplayInfoExtra.BakeName`. Armour that should have geometry (shoulders,
helm, belt buckles) stays on `NPCItemDisplay` slots; paint only what is flat on the body.

## Pitfalls

- Non power-of-two or missing mips → black/white model or invisible texture.
- Wrong folder: `TextureVariation` names are looked up next to the **M2**, not next to the DBC or
  in `Textures\`. `Creature\Kobold\KoboldTallow.blp` for `Creature\Kobold\Kobold.mdx`.
- A texture unit of type 0 in the M2 ignores the DBC name; you must edit the M2's texture path or
  pick another donor.
- Saving DXT1 over a texture that used alpha → hair/fur becomes solid blocks.
- Packing a UTF-8-BOM MPQEditor script silently skips the `new` line; the archive keeps old bytes.
- `Wow.exe` holds `patch-4.MPQ` open; replacing the file without a full client restart shows the
  old texture.
