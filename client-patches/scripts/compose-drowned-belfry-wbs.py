"""Compose The Drowned Belfry in Blender 3.4.1 + WBS (run inside Blender).

Playable run is Blender +X (world dest = -XY), matching existing SQL spawns.
Usage:
  DISPLAY=:0 /home/dan/dev/tools/blender-3.4.1-linux-x64/blender --python \\
    client-patches/scripts/compose-drowned-belfry-wbs.py

See .agents/skills/build-dungeon/reference-blender-wmo.md.
"""
from __future__ import annotations

import os
import sys

import bpy
from mathutils import Vector

CRYPT = "/home/dan/dev/wmo-projects/belfry/src-crypt/MD_Crypt.wmo"
RUIN = "/home/dan/dev/wmo-projects/belfry/src-ruinedkeep/Ruinedkeep_crypt.wmo"
OUT = "/home/dan/dev/wmo-projects/belfry/export/DrownedBelfry.wmo"

SPAWNS = {
    "porch": (16.0, 0.0),
    "nave": (50.0, 0.0),
    "choir": (50.0, 24.0),
    "crypt": (50.0, -22.0),
    "sacristy": (68.0, 0.0),
    "brine": (82.0, 0.0),
    "toll": (108.0, 0.0),
}


def log(msg: str) -> None:
    print(msg, file=sys.stderr, flush=True)


def mesh_groups():
    out = []
    for obj in bpy.data.objects:
        if obj.type != "MESH":
            continue
        cols = [c.name for c in obj.users_collection]
        if any("Indoor" in n or "Outdoor" in n for n in cols):
            out.append(obj)
    return out


def find_group(name: str):
    for obj in mesh_groups():
        if obj.name == name or obj.name.startswith(name + "."):
            return obj
    raise KeyError(name)


def world_aabb(obj):
    corners = [obj.matrix_world @ Vector(c) for c in obj.bound_box]
    xs, ys, zs = zip(*[(c.x, c.y, c.z) for c in corners])
    return min(xs), min(ys), min(zs), max(xs), max(ys), max(zs)


def duplicate(obj, name: str):
    bpy.ops.object.select_all(action="DESELECT")
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.duplicate()
    nobj = bpy.context.active_object
    nobj.name = name
    if nobj.data:
        nobj.data.name = name
    return nobj


def ray_floor(scene, x, y):
    deps = bpy.context.evaluated_depsgraph_get()
    origin = Vector((x, y, 4.0))
    hit, loc, *_ = scene.ray_cast(deps, origin, Vector((0.0, 0.0, -1.0)))
    if hit:
        return loc.z
    origin = Vector((x, y, 20.0))
    hit, loc, *_ = scene.ray_cast(deps, origin, Vector((0.0, 0.0, -1.0)))
    return loc.z if hit else None


def wipe_portals():
    """Deleted groups leave portal relations that crash WBS export."""
    for col in list(bpy.data.collections):
        if "Portal" not in col.name:
            continue
        for obj in list(col.objects):
            log(f"remove portal {obj.name}")
            bpy.data.objects.remove(obj, do_unlink=True)


def indoor_and_collision(groups):
    indoor = next((c for c in bpy.data.collections if "Indoor" in c.name), None)
    outdoor = next((c for c in bpy.data.collections if "Outdoor" in c.name), None)
    if indoor and outdoor:
        for obj in list(outdoor.objects):
            if obj.type != "MESH":
                continue
            outdoor.objects.unlink(obj)
            if obj.name not in indoor.objects:
                indoor.objects.link(obj)
            log(f"moved indoor {obj.name}")
    for obj in groups:
        flags = set(obj.wow_wmo_group.flags)
        flags.add("2")
        obj.wow_wmo_group.flags = flags
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

ext = find_group("Ext")
rm02 = find_group("CryptRm02")

# Ext native ~(-14.6..14, -9.6..9.6, -1.4..17). Floor ~-1.4.
# Put each spawn at native (-6, 0) so we are not standing in the +X door hole.
# location.z = 1.6 puts floor near spawn Z 0.2.
ext.location = (22.0, 0.0, -0.4)
nave = duplicate(ext, "Ext_Nave")
nave.location = (56.0, 0.0, -0.4)
sac = duplicate(ext, "Ext_Sacristy")
sac.location = (74.0, 0.0, -0.4)
crypt_hall = duplicate(ext, "Ext_Crypt")
crypt_hall.location = (56.0, -22.0, -14.75)

# Choir: CryptRm02 native y already ~6..29. Slide X to nave, lift floor to ~1.2.
rm02.location = (19.7, 0.0, 24.55)

keep = {ext, nave, sac, crypt_hall, rm02}
for obj in list(mesh_groups()):
    if obj in keep:
        continue
    log(f"remove leftover {obj.name}")
    bpy.data.objects.remove(obj, do_unlink=True)

wipe_portals()

before_ruin = set(bpy.data.objects)
log(f"IMPORT ruin {RUIN}")
log(str(bpy.ops.import_mesh.wmo(filepath=RUIN)))
ruin_objs = [o for o in bpy.data.objects if o not in before_ruin]
# Native x -68..3.5. +133 → blender 65..136.5 → world -65..-136 (brine + toll).
for obj in ruin_objs:
    obj.location.x += 133.0
    obj.location.z += -13.94

wipe_portals()
groups = mesh_groups()
indoor_and_collision(groups)

log("=== floors at spawns (blender xy; world = -xy) ===")
for name, (x, y) in SPAWNS.items():
    fz = ray_floor(scn, x, y)
    log(f"  {name:10} blender ({x:.0f},{y:.0f}) floor_z={fz}")

for obj in groups:
    bb = world_aabb(obj)
    log(f"group {obj.name:20} ({bb[0]:.1f},{bb[1]:.1f},{bb[2]:.1f})-({bb[3]:.1f},{bb[4]:.1f},{bb[5]:.1f})")

os.makedirs(os.path.dirname(OUT), exist_ok=True)
log(f"EXPORT {OUT}")
try:
    log(str(bpy.ops.export_mesh.wmo(filepath=OUT, export_method="FULL", export_selected=False)))
except Exception as exc:
    log(f"export failed: {exc}")
    raise
finally:
    bpy.ops.wm.quit_blender()
