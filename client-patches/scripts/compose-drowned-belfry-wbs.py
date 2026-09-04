"""Compose The Drowned Belfry in Blender 3.4.1 + WBS (run inside Blender).

One vanilla MD_Crypt: chapel mouth + stairs + crypt rooms, **portals kept**.
Do not overlay Ruinedkeep in the same XY (stacked floors / sliced coffins).
Do not strip portals (Indoor groups then draw through each other).
Do not set AlwaysDraw when portals exist.

Playable run is Blender +X (world dest = -XY).
Usage:
  DISPLAY=:0 /home/dan/dev/tools/blender-3.4.1-linux-x64/blender --python \\
    client-patches/scripts/compose-drowned-belfry-wbs.py
"""
from __future__ import annotations

import atexit
import os
import sys

import bpy
from mathutils import Vector

CRYPT = "/home/dan/dev/wmo-projects/belfry/src-crypt/MD_Crypt.wmo"
OUT = "/home/dan/dev/wmo-projects/belfry/export/DrownedBelfry.wmo"

SPAWNS = {
    "porch": (16.0, 0.0),
    "nave": (16.0, 0.0),
    "choir": (46.0, 18.0),
    "crypt": (32.0, -15.0),
    "whelm": (31.0, -15.0),
    "brine": (36.0, 18.0),
    "toll": (10.0, 18.0),
}


def log(msg: str) -> None:
    print(msg, file=sys.stderr, flush=True)


@atexit.register
def _quit_blender() -> None:
    try:
        bpy.ops.wm.quit_blender()
    except Exception:
        pass


def mesh_groups():
    out = []
    for obj in bpy.data.objects:
        if obj.type != "MESH":
            continue
        cols = [c.name for c in obj.users_collection]
        if any("Indoor" in n or "Outdoor" in n for n in cols):
            out.append(obj)
    return out


def world_aabb(obj):
    corners = [obj.matrix_world @ Vector(c) for c in obj.bound_box]
    xs, ys, zs = zip(*[(c.x, c.y, c.z) for c in corners])
    return min(xs), min(ys), min(zs), max(xs), max(ys), max(zs)


def translate_roots(objects, dx, dy, dz):
    for obj in objects:
        if obj.parent is None:
            obj.location.x += dx
            obj.location.y += dy
            obj.location.z += dz


def is_outdoor_chapel(obj):
    bb = world_aabb(obj)
    dx, dy, dz = bb[3] - bb[0], bb[4] - bb[1], bb[5] - bb[2]
    return 25.0 < dx < 32.0 and 16.0 < dy < 22.0 and 16.0 < dz < 21.0 and bb[2] > -4.0


def ray_floor(scene, x, y):
    deps = bpy.context.evaluated_depsgraph_get()
    for z0 in (4.0, 20.0, -8.0, -20.0):
        hit, loc, *_ = scene.ray_cast(deps, Vector((x, y, z0)), Vector((0.0, 0.0, -1.0)))
        if hit:
            return loc.z
    return None


def quick_collision(groups):
    for obj in groups:
        obj.wow_wmo_group.liquid_type = "15"
    bpy.ops.object.select_all(action="DESELECT")
    for obj in groups:
        obj.select_set(True)
        bpy.context.view_layer.objects.active = obj
    r = bpy.ops.scene.wow_quick_collision()
    log(f"quick_collision {r} n={len(groups)}")


bpy.ops.object.select_all(action="SELECT")
bpy.ops.object.delete()
scn = bpy.context.scene
scn.wow_scene.type = "WMO"
scn.wow_scene.version = "2"

log(f"IMPORT crypt {CRYPT}")
log(str(bpy.ops.import_mesh.wmo(filepath=CRYPT)))

chapel = next((o for o in mesh_groups() if is_outdoor_chapel(o)), None)
if chapel is None:
    chapel = next((o for o in mesh_groups()
                   if o.name.startswith("Ext") or o.name.startswith("Stairs05")), None)
if chapel is None:
    raise RuntimeError("no chapel group")
bb = world_aabb(chapel)
cx, cy = (bb[0] + bb[3]) / 2.0, (bb[1] + bb[4]) / 2.0
dx, dy, dz = 16.0 - cx, 0.0 - cy, 0.2 - bb[2]
log(f"chapel {chapel.name} aabb {tuple(round(v, 2) for v in bb)} d=({dx:.2f},{dy:.2f},{dz:.2f})")
translate_roots(list(bpy.data.objects), dx, dy, dz)
bpy.context.view_layer.update()

groups = mesh_groups()
quick_collision(groups)

log("=== floors (blender xy; world = -xy) ===")
for name, (x, y) in SPAWNS.items():
    fz = ray_floor(scn, x, y)
    log(f"  {name:10} blender ({x:.0f},{y:.0f}) floor_z={fz}")

for obj in groups:
    bb = world_aabb(obj)
    log(f"group {obj.name:24} ({bb[0]:.1f},{bb[1]:.1f},{bb[2]:.1f})-"
        f"({bb[3]:.1f},{bb[4]:.1f},{bb[5]:.1f})")

n_portals = sum(1 for c in bpy.data.collections if "Portal" in c.name
                for _ in c.objects)
log(f"portals kept: {n_portals}")

os.makedirs(os.path.dirname(OUT), exist_ok=True)
log(f"EXPORT {OUT}")
log(str(bpy.ops.export_mesh.wmo(filepath=OUT, export_method="FULL", export_selected=False)))
