"""Headless Blender preview of mesh.json + WaxCandleSkin.png (rest pose). Run:
blender -b --python 20_preview_blender.py -- <work_dir>
"""
import json
import math
import os
import sys

import bpy
from mathutils import Vector

work = sys.argv[sys.argv.index("--") + 1]
out = os.path.join(work, "out")
mesh = json.load(open(os.path.join(out, "mesh.json")))

bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene

me = bpy.data.meshes.new("candle")
verts = [tuple(v["pos"]) for v in mesh["vertices"]]
tris = mesh["triangles"]
faces = [tuple(tris[i:i + 3]) for i in range(0, len(tris), 3)]
me.from_pydata(verts, [], faces)
me.update()
uv = me.uv_layers.new(name="UVMap")
for poly in me.polygons:
    for li in poly.loop_indices:
        vi = me.loops[li].vertex_index
        u, v = mesh["vertices"][vi]["uv"]
        uv.data[li].uv = (u, 1.0 - v)          # WoW v is top-down; Blender is bottom-up
obj = bpy.data.objects.new("candle", me)
scene.collection.objects.link(obj)

# material: image texture; flame submesh additive-ish via emission
img = bpy.data.images.load(os.path.join(out, "WaxCandleSkin.png"))
mat = bpy.data.materials.new("skin"); mat.use_nodes = True
nt = mat.node_tree; bsdf = nt.nodes["Principled BSDF"]
tex = nt.nodes.new("ShaderNodeTexImage"); tex.image = img
nt.links.new(tex.outputs["Color"], bsdf.inputs["Base Color"])
bsdf.inputs["Roughness"].default_value = 0.55
me.materials.append(mat)
flame = bpy.data.materials.new("flame"); flame.use_nodes = True
fnt = flame.node_tree; fb = fnt.nodes["Principled BSDF"]
ft = fnt.nodes.new("ShaderNodeTexImage"); ft.image = img
fnt.links.new(ft.outputs["Color"], fb.inputs["Emission"])
fb.inputs["Emission Strength"].default_value = 6.0
fb.inputs["Base Color"].default_value = (0, 0, 0, 1)
flame.blend_method = "BLEND"
me.materials.append(flame)
for s in mesh["submeshes"]:
    if s["name"] == "flame":
        for pi in range(s["istart"] // 3, (s["istart"] + s["icount"]) // 3):
            me.polygons[pi].material_index = 1
for p in me.polygons:
    p.use_smooth = True

# lights + camera
sun = bpy.data.objects.new("sun", bpy.data.lights.new("sun", "SUN"))
sun.data.energy = 3.0; sun.rotation_euler = (math.radians(50), math.radians(-20), math.radians(30))
scene.collection.objects.link(sun)
fill = bpy.data.objects.new("fill", bpy.data.lights.new("fill", "SUN"))
fill.data.energy = 1.0; fill.rotation_euler = (math.radians(60), 0, math.radians(200))
scene.collection.objects.link(fill)
scene.world = bpy.data.worlds.new("w"); scene.world.use_nodes = True
scene.world.node_tree.nodes["Background"].inputs[0].default_value = (0.25, 0.28, 0.32, 1)

cam = bpy.data.objects.new("cam", bpy.data.cameras.new("cam"))
scene.collection.objects.link(cam); scene.camera = cam
scene.render.engine = "BLENDER_EEVEE"
scene.render.resolution_x, scene.render.resolution_y = 640, 800
scene.render.film_transparent = False
target = Vector((0.06, 0.0, 1.0))


def shoot(name, pos):
    cam.location = Vector(pos)
    cam.rotation_euler = (target - cam.location).to_track_quat("-Z", "Y").to_euler()
    scene.render.filepath = os.path.join(out, f"preview_{name}.png")
    bpy.ops.render.render(write_still=True)


shoot("front", (4.2, -1.6, 1.4))
shoot("side", (0.2, 4.4, 1.3))
shoot("back", (-4.2, 1.4, 1.5))
print("previews written")
