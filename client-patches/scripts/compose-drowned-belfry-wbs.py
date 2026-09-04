"""Compose The Drowned Belfry in Blender 3.4.1 + WBS (run inside Blender).

Keep MD_Crypt as one connected vanilla crypt (chapel mouth + stairs + rooms).
Attach Ruinedkeep indoor halls on +X. Do **not** duplicate the outdoor chapel
(Ext/Stairs05) as a spine — that is buildings floating in the WMO-only void.

Playable run is Blender +X (world dest = -XY).
Usage:
  DISPLAY=:0 /home/dan/dev/tools/blender-3.4.1-linux-x64/blender --python \\
    client-patches/scripts/compose-drowned-belfry-wbs.py

See .agents/skills/build-dungeon/reference-blender-wmo.md.
"""
from __future__ import annotations

import atexit
import os
import sys

import bpy
from mathutils import Vector

CRYPT = "/home/dan/dev/wmo-projects/belfry/src-crypt/MD_Crypt.wmo"
RUIN = "/home/dan/dev/wmo-projects/belfry/src-ruinedkeep/Ruinedkeep_crypt.wmo"
OUT = "/home/dan/dev/wmo-projects/belfry/export/DrownedBelfry.wmo"

# Blender xy. world = (-x, -y, z). Updated from raycasts after compose.
SPAWNS = {
    "porch": (16.0, 0.0),
    "nave": (40.0, 0.0),
    "choir": (36.0, 18.0),
    "crypt": (36.0, -16.0),
    "sacristy": (52.0, 0.0),
    "brine": (64.0, 0.0),
    "toll": (72.0, 0.0),
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
    """MD_Crypt Stairs05 / Ext: ~29x19 chapel that sits on overworld terrain."""
    bb = world_aabb(obj)
    dx, dy, dz = bb[3] - bb[0], bb[4] - bb[1], bb[5] - bb[2]
    return 25.0 < dx < 32.0 and 16.0 < dy < 22.0 and 16.0 < dz < 21.0 and bb[2] > -4.0


def is_outdoor_shell(obj):
    """Ruinedkeep righthall11: 70x70 exterior hull. Shows as a building in the void."""
    bb = world_aabb(obj)
    return (bb[3] - bb[0]) > 50.0 and (bb[4] - bb[1]) > 50.0


def ray_floor(scene, x, y):
    deps = bpy.context.evaluated_depsgraph_get()
    for z0 in (4.0, 20.0, 40.0, -8.0):
        hit, loc, *_ = scene.ray_cast(deps, Vector((x, y, z0)), Vector((0.0, 0.0, -1.0)))
        if hit:
            return loc.z
    return None


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
wipe_portals()

chapel = next((o for o in mesh_groups() if is_outdoor_chapel(o)), None)
if chapel is None:
    chapel = next((o for o in mesh_groups()
                   if o.name.startswith("Ext") or o.name.startswith("Stairs05")), None)
if chapel is None:
    raise RuntimeError("no chapel group (Ext/Stairs05)")
bb = world_aabb(chapel)
cx, cy = (bb[0] + bb[3]) / 2.0, (bb[1] + bb[4]) / 2.0
# Mouth SQL / C++ dest is world (-16, 0, 0.2) = blender (16, 0, 0.2).
dx, dy, dz = 16.0 - cx, 0.0 - cy, 0.2 - bb[2]
log(f"chapel {chapel.name} aabb {tuple(round(v, 2) for v in bb)} d=({dx:.2f},{dy:.2f},{dz:.2f})")
translate_roots(list(bpy.data.objects), dx, dy, dz)
bpy.context.view_layer.update()
chapel_east = world_aabb(chapel)[3]
log(f"chapel east x {chapel_east:.1f}")

before_ruin = set(bpy.data.objects)
log(f"IMPORT ruin {RUIN}")
log(str(bpy.ops.import_mesh.wmo(filepath=RUIN)))
ruin_names = {o.name for o in bpy.data.objects if o not in before_ruin}
for obj in list(mesh_groups()):
    if obj.name not in ruin_names:
        continue
    if is_outdoor_shell(obj):
        log(f"remove outdoor shell {obj.name} {tuple(round(v, 1) for v in world_aabb(obj))}")
        bpy.data.objects.remove(obj, do_unlink=True)
wipe_portals()
ruin_meshes = [o for o in mesh_groups() if o.name in ruin_names]
if not ruin_meshes:
    raise RuntimeError("no ruinedkeep indoor groups left")
# Join the keep hall that sits on y=0 (righthall10), not the north tower.
spine = [o for o in ruin_meshes if world_aabb(o)[1] < 1.0 and world_aabb(o)[4] > -1.0]
if not spine:
    spine = ruin_meshes
west = min(spine, key=lambda o: world_aabb(o)[0])
wbb = world_aabb(west)
overlap = 6.0
rdx = (chapel_east - overlap) - wbb[0]
rdz = 0.2 - wbb[2]
log(f"join {west.name} aabb {tuple(round(v, 1) for v in wbb)} d=({rdx:.2f},0,{rdz:.2f})")
live_ruin = [o for o in bpy.data.objects if o.name in ruin_names]
translate_roots(live_ruin, rdx, 0.0, rdz)
bpy.context.view_layer.update()

wipe_portals()
groups = mesh_groups()
indoor_and_collision(groups)

log("=== floors at spawns (blender xy; world = -xy) ===")
for name, (x, y) in SPAWNS.items():
    fz = ray_floor(scn, x, y)
    log(f"  {name:10} blender ({x:.0f},{y:.0f}) floor_z={fz}")

log("=== spine y=0 ===")
for x in range(8, 80, 4):
    fz = ray_floor(scn, float(x), 0.0)
    log(f"  x={x:3d} floor_z={fz}")

for obj in groups:
    bb = world_aabb(obj)
    log(f"group {obj.name:24} ({bb[0]:.1f},{bb[1]:.1f},{bb[2]:.1f})-"
        f"({bb[3]:.1f},{bb[4]:.1f},{bb[5]:.1f})")

os.makedirs(os.path.dirname(OUT), exist_ok=True)
log(f"EXPORT {OUT}")
log(str(bpy.ops.export_mesh.wmo(filepath=OUT, export_method="FULL", export_selected=False)))