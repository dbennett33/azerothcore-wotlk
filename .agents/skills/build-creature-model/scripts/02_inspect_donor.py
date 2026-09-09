"""Dump the donor M2 structure we must respect (bones, textures, particles, geometry)."""
import os
import struct
from collections import Counter
from wowlib import OUT

from pywowlib.m2_file import M2File
from pywowlib.file_formats.skin_format import M2SkinProfile

path = os.path.join(OUT, "donor", "Creature", "Kobold", "Kobold.m2")
m2 = M2File(3, path)   # 3 = WotLK expansion number
r = m2.root
print("name:", r.name.value if hasattr(r.name, "value") else r.name)
print("version:", r.version, "flags:", r.global_flags)
print("n vertices:", len(r.vertices), " n bones:", len(r.bones), " bone lookup:", len(r.bone_lookup_table),
      " key_bone_lookup:", len(r.key_bone_lookup))
print("n sequences:", len(r.sequences), " seq lookup:", len(r.sequence_lookup), " global seqs:", len(r.global_sequences))
print("textures:", [(t.type, t.flags, t.filename.value) for t in r.textures])
print("texture lookup:", list(r.texture_lookup_table))
print("materials:", [(m.flags, m.blending_mode) for m in r.materials])
print("tex unit lookup:", list(r.tex_unit_lookup_table), " transparency lookup:", list(r.transparency_lookup_table),
      " uv anim lookup:", list(r.texture_transforms_lookup_table))
print("n texture_weights:", len(r.texture_weights), " n texture_transforms:", len(r.texture_transforms))
print("n colors:", len(r.colors))
print("attachments:", [(a.id, a.bone, tuple(round(x, 3) for x in a.position)) for a in r.attachments])
print("attachment lookup:", list(r.attachment_lookup_table))
print("events:", [(e.identifier, e.bone, e.data) for e in r.events])
print("n lights:", len(r.lights), " n cameras:", len(r.cameras), " n ribbons:", len(r.ribbon_emitters))
print("particles:", len(r.particle_emitters))
for i, p in enumerate(r.particle_emitters):
    print(f"  [{i}] bone={p.bone} pos={tuple(round(x,3) for x in p.position)} tex={p.texture} flags={p.flags} "
          f"blend={p.blending_type} emitter={p.emitter_type} model={p.geometry_model_filename.value!r}")
print("bounding box:", [round(x, 3) for x in r.bounding_box.min], [round(x, 3) for x in r.bounding_box.max],
      "radius", r.bounding_sphere_radius)
print("collision box:", [round(x, 3) for x in r.collision_box.min], [round(x, 3) for x in r.collision_box.max],
      "radius", r.collision_sphere_radius)
print("collision tris:", len(r.collision_triangles), " collision verts:", len(r.collision_vertices))

print("\nbones (idx, keybone, parent, flags, pivot):")
for i, b in enumerate(r.bones):
    print(f"  {i:2d} key={b.key_bone_id:3d} parent={b.parent_bone:3d} flags={b.flags:#06x} "
          f"pivot=({b.pivot[0]:.3f},{b.pivot[1]:.3f},{b.pivot[2]:.3f}) "
          f"trans_keys={sum(len(t) for t in b.translation.timestamps)} rot_keys={sum(len(t) for t in b.rotation.timestamps)}")
print("bone lookup table:", list(r.bone_lookup_table))
print("key bone lookup:", list(r.key_bone_lookup))

print("\nsequences (id, variation, duration, flags):")
for s in r.sequences:
    print(f"  {s.id:3d}.{s.variation_index} dur={s.duration:5d} flags={s.flags:#06x} "
          f"bbox=({s.bounds.extent.min[0]:.2f},{s.bounds.extent.min[1]:.2f},{s.bounds.extent.min[2]:.2f})..."
          f"({s.bounds.extent.max[0]:.2f},{s.bounds.extent.max[1]:.2f},{s.bounds.extent.max[2]:.2f})")

# vertex stats
xs = [v.pos[0] for v in r.vertices]; ys = [v.pos[1] for v in r.vertices]; zs = [v.pos[2] for v in r.vertices]
print("\nvertex extent x", round(min(xs), 3), round(max(xs), 3), " y", round(min(ys), 3), round(max(ys), 3),
      " z", round(min(zs), 3), round(max(zs), 3))
bi = Counter()
for v in r.vertices:
    for k in range(4):
        if v.bone_weights[k]:
            bi[v.bone_indices[k]] += 1
print("vertex bone index histogram (index -> count):", dict(sorted(bi.items())))

# skins
for lod in range(2):
    sp = os.path.join(OUT, "donor", "Creature", "Kobold", f"Kobold0{lod}.skin")
    skin = M2SkinProfile()
    with open(sp, "rb") as f:
        skin.read(f)
    print(f"\nskin {lod}: verts={len(skin.vertex_indices)} tris={len(skin.triangle_indices)//3} "
          f"bones={len(skin.bone_indices)} submeshes={len(skin.submeshes)} texunits={len(skin.texture_units)} "
          f"bone_count_max={skin.bone_count_max}")
    for i, sm in enumerate(skin.submeshes):
        print(f"  submesh[{i}] id={sm.skin_section_id} level={sm.level} vstart={sm.vertex_start} vcount={sm.vertex_count} "
              f"istart={sm.index_start} icount={sm.index_count} bone_count={sm.bone_count} "
              f"bone_combo_index={sm.bone_combo_index} bone_influences={sm.bone_influences} "
              f"center_bone={sm.center_bone_index} center={tuple(round(x,2) for x in sm.center_position)} "
              f"sort_center={tuple(round(x,2) for x in sm.sort_ceter_position)} sort_r={sm.sort_radius:.2f}")
    for i, tu in enumerate(skin.texture_units):
        print(f"  texunit[{i}] flags={tu.flags} priority={tu.priority_plane} shader={tu.shader_id} "
              f"submesh={tu.skin_section_index} geoset={tu.geoset_index} color={tu.color_index} "
              f"material={tu.material_index} layer={tu.material_layer} tex_count={tu.texture_count} "
              f"tex_combo={tu.texture_combo_index} texcoord_combo={tu.texture_coord_combo_index} "
              f"weight_combo={tu.texture_weight_combo_index} transform_combo={tu.texture_transform_combo_index}")
    pass
    # vertex bone index range inside skin sections
    for i, sm in enumerate(skin.submeshes):
        vi = skin.vertex_indices[sm.vertex_start:sm.vertex_start + sm.vertex_count]
        mx = max(max(r.vertices[v].bone_indices) for v in vi)
        print(f"  submesh[{i}] max vertex bone index = {mx}")

# compare M2 vertex bone indices with skin per-vertex "bones" (palette) entries
skin = M2SkinProfile()
with open(os.path.join(OUT, "donor", "Creature", "Kobold", "Kobold00.skin"), "rb") as f:
    skin.read(f)
print("\nfirst 12 vertices: (m2 bone idx, weights) vs skin.bones entry")
for i in range(12):
    v = r.vertices[skin.vertex_indices[i]]
    print("  ", list(v.bone_indices), list(v.bone_weights), "->", [skin.bone_indices[i][k] for k in range(4)])
lut = list(r.bone_lookup_table)
sm = skin.submeshes[0]
ok = all(lut[sm.bone_combo_index + skin.bone_indices[i][k]] == r.vertices[skin.vertex_indices[i]].bone_indices[k]
         for i in range(len(skin.vertex_indices)) for k in range(4) if r.vertices[skin.vertex_indices[i]].bone_weights[k])
print("skin.bones are palette indices into bone_lookup[combo_index..] mapping to M2 vertex bone ids:", ok)
print("vertex 0 full:", r.vertices[0].pos, r.vertices[0].normal, r.vertices[0].tex_coords, r.vertices[0].tex_coords2)
