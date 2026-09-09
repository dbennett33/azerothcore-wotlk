"""Rig transplant in bytes: donor Kobold.m2 + mesh.json -> WaxCandle.m2 + WaxCandle0N.skin (+ .anim copies).

Everything in the donor file is kept where it is; we append new arrays at the end and repoint the
MD20 header at them. Only geometry-related data changes:
  vertices, bone_lookup_table, materials (+1 unlit additive), bones (+1 spherical billboard for
  the flame quad), name, bounding boxes, per-sequence bounds, particle emitter position.
"""
import json
import math
import os
import shutil
import struct
import numpy as np
from wowlib import OUT

DONOR_DIR = os.path.join(OUT, "donor", "Creature", "Kobold")
DONOR = "Kobold"
NEW = "WaxCandle"
NEW_DIR = os.path.join(OUT, "Creature", NEW)
os.makedirs(NEW_DIR, exist_ok=True)

FLAME_BONE_PARENT = 4                  # spine-up: keep the wick/flame on the cylinder, not the hunched head
FLAME_BASE = (0.06, 0.0, 1.53)         # wick top, model space (see 10_build_mesh.py)
PARTICLE_POS = (0.06, 0.0, 1.56)
DANCE_ANIM_ID = 69                     # AnimationData EmoteDance (Emotes STATE_DANCE / ONESHOT_DANCE)
CRY_ANIM_ID = 77                       # AnimationData EmoteCry (snuff-out cower)
SPELLCAST_SEQ = 20                     # donor sequence index whose id is SpellCast (32)

# ---- header field offsets (MD20 v264, flags without 0x8) -------------------------------------
H = dict(name=8, flags=16, global_seqs=20, sequences=28, seq_lookup=36, bones=44, key_bone_lookup=52,
         vertices=60, n_views=68, colors=72, textures=80, texture_weights=88, texture_transforms=96,
         replacable_lookup=104, materials=112, bone_lookup=120, texture_lookup=128, tex_unit_lookup=136,
         transparency_lookup=144, texture_transforms_lookup=152, bbox=160, bsphere=184, cbox=188, csphere=212,
         collision_tris=216, collision_verts=224, collision_normals=232, attachments=240, attachment_lookup=248,
         events=256, lights=264, cameras=272, camera_lookup=280, ribbons=288, particles=296)

m2 = bytearray(open(os.path.join(DONOR_DIR, DONOR + ".m2"), "rb").read())
assert m2[:4] == b"MD20" and struct.unpack_from("<I", m2, 4)[0] == 264
flags = struct.unpack_from("<I", m2, H["flags"])[0]
assert not (flags & 0x8), "blend map overrides present: header is 312 bytes, adjust offsets"


def arr(field):
    return struct.unpack_from("<II", m2, H[field])


def set_arr(field, n, ofs):
    struct.pack_into("<II", m2, H[field], n, ofs)


def append(data, align=16):
    while len(m2) % align:
        m2.append(0)
    ofs = len(m2)
    m2.extend(data)
    return ofs


mesh = json.load(open(os.path.join(OUT, "mesh.json")))
verts, tris, subs = mesh["vertices"], mesh["triangles"], mesh["submeshes"]
n_bones_old = arr("bones")[0]
print(f"donor: {arr('vertices')[0]} verts, {n_bones_old} bones, {arr('materials')[0]} materials, "
      f"{arr('bone_lookup')[0]} lookup, {arr('sequences')[0]} sequences, {arr('particles')[0]} particles")

# ---- 1. name ---------------------------------------------------------------------------------
name = NEW.encode() + b"\0"
set_arr("name", len(name), append(name))

# ---- 2. flame bone: copy a key-less bone (39), re-parent, billboard ----------------------------
n_bones, ofs_bones = arr("bones")
BONE_SIZE = 88
bones = bytearray(m2[ofs_bones:ofs_bones + n_bones * BONE_SIZE])
tmpl = bytearray(bones[39 * BONE_SIZE:40 * BONE_SIZE])
struct.pack_into("<iI", tmpl, 0, -1, 0x8 | 0x200)               # key_bone -1, spherical billboard + transformed
struct.pack_into("<hH", tmpl, 8, FLAME_BONE_PARENT, 0)
struct.pack_into("<3f", tmpl, 76, *FLAME_BASE)
bones += tmpl
FLAME_BONE = n_bones
assert FLAME_BONE == 72
set_arr("bones", n_bones + 1, append(bytes(bones)))

# ---- 3. materials: donor + unlit two-sided additive ----------------------------------------------
n_mat, ofs_mat = arr("materials")
mats = bytearray(m2[ofs_mat:ofs_mat + n_mat * 4])
mats += struct.pack("<HH", 0x01 | 0x04 | 0x10, 4)               # unlit | two-sided | no depth write ; Add
set_arr("materials", n_mat + 1, append(bytes(mats)))
FLAME_MATERIAL = n_mat

# ---- 4. vertices -----------------------------------------------------------------------------
vbuf = bytearray()
for v in verts:
    vbuf += struct.pack("<3f4B4B3f2f2f", *v["pos"], *v["weights"], *v["bones"], *v["normal"], *v["uv"], 0.0, 0.0)
set_arr("vertices", len(verts), append(bytes(vbuf)))

# ---- 5. bone lookup: one palette per submesh -------------------------------------------------
lookup = []
palettes = []
for s in subs:
    used = sorted({b for v in verts[s["vstart"]:s["vstart"] + s["vcount"]]
                   for b, w in zip(v["bones"], v["weights"]) if w})
    palettes.append((len(lookup), used))
    lookup += used
set_arr("bone_lookup", len(lookup), append(struct.pack(f"<{len(lookup)}H", *lookup)))

# ---- 6. bounds -------------------------------------------------------------------------------
P = np.array([v["pos"] for v in verts])
bmin, bmax = P.min(axis=0) - 0.05, P.max(axis=0) + 0.05
struct.pack_into("<6f", m2, H["bbox"], *bmin, *bmax)
struct.pack_into("<f", m2, H["bsphere"], float(np.linalg.norm(np.maximum(abs(bmin), abs(bmax)))))
struct.pack_into("<6f", m2, H["cbox"], -0.35, -0.45, 0.0, 0.35, 0.45, 1.95)
struct.pack_into("<f", m2, H["csphere"], 2.0)
n_seq, ofs_seq = arr("sequences")
# sanity: M2Sequence is 64 bytes, bounds at +32 (donor seq 0 = stand, bbox z max 1.24; seq 1 id = 4 walk)
assert struct.unpack_from("<H", m2, ofs_seq + 64)[0] == 4
assert abs(struct.unpack_from("<7f", m2, ofs_seq + 32)[5] - 1.24) < 0.01
for i in range(n_seq):                       # generous per-sequence culling bounds (DisplayScale 3 ~18 ft)
    struct.pack_into("<7f", m2, ofs_seq + i * 64 + 32, -4.0, -3.0, -1.0, 4.0, 3.0, 4.5, 8.0)

# ---- 7. particle emitter (the kobold candle flame) onto our wick -------------------------------
# M2Particle v264: id u32, flags u32, position vec3 (+8), bone u16 (+20), texture u16 (+22)
n_part, ofs_part = arr("particles")
assert n_part == 1 and struct.unpack_from("<H", m2, ofs_part + 20)[0] == 62
struct.pack_into("<3f", m2, ofs_part + 8, *PARTICLE_POS)
struct.pack_into("<H", m2, ofs_part + 20, FLAME_BONE)       # follow the billboard wick, not bone 14

with open(os.path.join(NEW_DIR, NEW + ".m2"), "wb") as f:
    f.write(m2)
print(f"wrote {NEW}.m2: {len(m2)} bytes, {len(verts)} verts, {n_bones + 1} bones, {n_mat + 1} materials, "
      f"lookup {len(lookup)}")


# ---- 8. skins --------------------------------------------------------------------------------
def build_skin():
    out = bytearray(b"SKIN" + bytes(44))
    n_v = len(verts)
    vidx = struct.pack(f"<{n_v}H", *range(n_v))
    tri_ = struct.pack(f"<{len(tris)}H", *tris)
    # per-vertex palette indices
    pal_of_vertex = {}
    for (start, used), s in zip(palettes, subs):
        for vi in range(s["vstart"], s["vstart"] + s["vcount"]):
            pal_of_vertex[vi] = used
    bones_ = bytearray()
    for vi, v in enumerate(verts):
        used = pal_of_vertex[vi]
        bones_ += bytes(used.index(b) if w else 0 for b, w in zip(v["bones"], v["weights"]))
    submeshes = bytearray()
    batches = bytearray()
    bone_count_max = 0
    for si, ((start, used), s) in enumerate(zip(palettes, subs)):
        sv = P[s["vstart"]:s["vstart"] + s["vcount"]]
        center = sv.mean(axis=0)
        radius = float(np.linalg.norm(sv - center, axis=1).max()) * 3.0 + 2.0
        influences = max(sum(1 for w in v["weights"] if w) for v in verts[s["vstart"]:s["vstart"] + s["vcount"]])
        submeshes += struct.pack("<10H3f3ff", 0, 0, s["vstart"], s["vcount"], s["istart"], s["icount"],
                                 len(used), start, influences, s["center_bone"], *center, *center, radius)
        # flags, priority, shader, submesh, geoset, color, material, layer, texcount, texcombo, texcoord, weight, transform
        batches += struct.pack("<BbHHHhHHHHHHH", 16, 0, 0, si, si, -1, s["material"] if s["material"] == 0 else FLAME_MATERIAL,
                               0, 1, 0, 0, 0, 0)
        bone_count_max = max(bone_count_max, len(used))

    def put(field_ofs, data, count):
        while len(out) % 16:
            out.append(0)
        struct.pack_into("<II", out, field_ofs, count, len(out))
        out.extend(data)
    put(4, vidx, n_v)
    put(12, tri_, len(tris))
    put(20, bytes(bones_), n_v)
    put(28, bytes(submeshes), len(subs))
    put(36, bytes(batches), len(subs))
    struct.pack_into("<I", out, 44, bone_count_max)
    return bytes(out)


skin = build_skin()
n_views = struct.unpack_from("<I", m2, H["n_views"])[0]
for i in range(n_views):
    with open(os.path.join(NEW_DIR, f"{NEW}0{i}.skin"), "wb") as f:
        f.write(skin)
print(f"wrote {n_views} skins of {len(skin)} bytes")

# ---- 9. external .anim files follow the model file name ---------------------------------------
for fn in os.listdir(DONOR_DIR):
    if fn.lower().endswith(".anim"):
        shutil.copyfile(os.path.join(DONOR_DIR, fn), os.path.join(NEW_DIR, NEW + fn[len(DONOR):]))
        print("anim:", NEW + fn[len(DONOR):])
shutil.copyfile(os.path.join(OUT, "WaxCandleSkin.blp"), os.path.join(NEW_DIR, "WaxCandleSkin.blp"))
print("files:", sorted(os.listdir(NEW_DIR)))


def _f_to_s(f):
    """Inverse of M2CompQuaternion.to_quaternion's int16 decode. Result must satisfy -s in int16."""
    f = max(-1.0, min(1.0, float(f)))
    if f >= 0.99997:
        return -1
    if abs(f) < 1e-5:
        return 32767
    s = int(round(f * 32767.0 + 32767.0))
    if s > 32767:
        s -= 65536
    return max(-32767, min(32767, s))


def _qmul(a, b):
    aw, ax, ay, az = a
    bw, bx, by, bz = b
    return (aw * bw - ax * bx - ay * by - az * bz,
            aw * bx + ax * bw + ay * bz - az * by,
            aw * by - ax * bz + ay * bw + az * bx,
            aw * bz + ax * by - ay * bx + az * bw)


def _euler_xyz(rx, ry, rz):
    cx, sx = math.cos(rx * 0.5), math.sin(rx * 0.5)
    cy, sy = math.cos(ry * 0.5), math.sin(ry * 0.5)
    cz, sz = math.cos(rz * 0.5), math.sin(rz * 0.5)
    return (cx * cy * cz + sx * sy * sz,
            sx * cy * cz - cx * sy * sz,
            cx * sy * cz + sx * cy * sz,
            cx * cy * sz - sx * sy * cz)


def _pack_quat(wxyz):
    from pywowlib.file_formats.m2_format import M2CompQuaternion
    w, x, y, z = wxyz
    n = math.sqrt(w * w + x * x + y * y + z * z) or 1.0
    q = M2CompQuaternion()
    q.w, q.x, q.y, q.z = _f_to_s(w / n), _f_to_s(x / n), _f_to_s(y / n), _f_to_s(z / n)
    return q


def _stand_q(bone):
    vs = bone.rotation.values
    if vs and len(vs[0]) > 0:
        return vs[0][0].to_quaternion()
    return (1.0, 0.0, 0.0, 0.0)


def _iter_tracks(root):
    tracks = []
    for b in root.bones:
        tracks.extend((b.translation, b.rotation, b.scale))
    for e in root.events:
        tracks.append(e.enabled)
    for a in root.attachments:
        tracks.append(a.animate_attached)
    for tw in root.texture_weights:
        tracks.append(tw)
    for c in root.cameras:
        tracks.extend((c.positions, c.target_position, c.roll))
    for col in root.colors:
        tracks.extend((col.color, col.alpha))
    for p in root.particle_emitters:
        for name in dir(p):
            if name.startswith("_"):
                continue
            obj = getattr(p, name)
            if hasattr(obj, "timestamps") and hasattr(obj, "interpolation_type"):
                tracks.append(obj)
    return tracks


def _clone_stand_slots(track, n_old, extra):
    nts = len(track.timestamps)
    if nts != n_old:
        return
    stand_ts = track.timestamps[0]
    has_vals = hasattr(track, "values")
    stand_vs = track.values[0] if has_vals else None
    for _ in range(extra):
        track.timestamps.append(stand_ts)
        if stand_vs is not None:
            track.values.append(stand_vs)


def _replace_rot(bone, seq_i, times, deltas, rest):
    import copy
    ts = copy.deepcopy(bone.rotation.timestamps[0])
    ts.values = list(times)
    vs = copy.deepcopy(bone.rotation.values[0])
    vs.values = [_pack_quat(_qmul(rest, d)) for d in deltas]
    bone.rotation.interpolation_type = 1
    bone.rotation.timestamps.set_index(seq_i, ts)
    bone.rotation.values.set_index(seq_i, vs)


def _replace_trans(bone, seq_i, times, vecs):
    import copy
    ts = copy.deepcopy(bone.translation.timestamps[0])
    ts.values = list(times)
    vs = copy.deepcopy(bone.translation.values[0])
    vs.values = [tuple(v) for v in vecs]
    bone.translation.interpolation_type = 1
    bone.translation.timestamps.set_index(seq_i, ts)
    bone.translation.values.set_index(seq_i, vs)


def _make_seq(src, anim_id, duration, flags):
    from pywowlib.file_formats.m2_format import M2Sequence
    s = M2Sequence()
    s.id = anim_id
    s.variation_index = 0
    s.duration = duration
    s.movespeed = 0.0
    s.flags = flags
    s.frequency = 32767
    s.padding = 0
    s.replay.minimum = 0
    s.replay.maximum = 0
    s.blend_time = src.blend_time
    s.bounds.extent.min = (-4.0, -3.0, -1.0)
    s.bounds.extent.max = (4.0, 3.0, 4.5)
    s.bounds.radius = 8.0
    s.variation_next = -1
    s.alias_next = 0
    return s


def author_custom_anims(path):
    """Append inline Dance (69) and Cry (77) sequences; retarget SpellCast into a wick-blow."""
    from pywowlib.m2_file import M2File

    mf = M2File(3, path)
    root = mf.root
    n_old = len(root.sequences)
    stand = root.sequences[0]
    dance = _make_seq(stand, DANCE_ANIM_ID, 3500, 0x20)   # 0x20 = keys live in the M2, looping
    cry = _make_seq(stand, CRY_ANIM_ID, 2200, 0x21)       # oneshot + blend
    dance_i = root.sequences.add(dance)
    cry_i = root.sequences.add(cry)
    dance.alias_next = dance_i
    cry.alias_next = cry_i

    while len(root.sequence_lookup) <= max(DANCE_ANIM_ID, CRY_ANIM_ID):
        root.sequence_lookup.append(0xFFFF)
    root.sequence_lookup.set_index(DANCE_ANIM_ID, dance_i)
    root.sequence_lookup.set_index(CRY_ANIM_ID, cry_i)
    if len(root.sequence_lookup) > 32:
        root.sequence_lookup.set_index(32, SPELLCAST_SEQ)

    for tr in _iter_tracks(root):
        _clone_stand_slots(tr, n_old, 2)

    bones = root.bones
    rest = {i: _stand_q(bones[i]) for i in (2, 3, 4, 12, 13, 15, 16)}

    # --- Dance: 2 Hz bounce, hip sway, opposite-phase arm windmills ---
    step, dur = 50, 3500
    times = list(range(0, dur, step)) + [dur]
    n = len(times)
    bounce = [_euler_xyz(0.18 * math.sin(2 * math.pi * 2 * t / 1000.0), 0.0, 0.0) for t in times]
    sway = [_euler_xyz(0.04 * math.sin(2 * math.pi * 2 * t / 1000.0),
                       0.28 * math.sin(2 * math.pi * 1.0 * t / 1000.0),
                       0.12 * math.sin(2 * math.pi * 1.0 * t / 1000.0)) for t in times]
    spine = [_euler_xyz(0.22 * math.sin(2 * math.pi * 2 * t / 1000.0),
                        0.10 * math.sin(2 * math.pi * 1.0 * t / 1000.0 + 0.4),
                        0.0) for t in times]
    sh_l = [_euler_xyz(-0.15 + 0.35 * math.sin(2 * math.pi * 2 * t / 1000.0), 0.25, 0.0) for t in times]
    sh_r = [_euler_xyz(-0.15 + 0.35 * math.sin(2 * math.pi * 2 * t / 1000.0 + math.pi), -0.25, 0.0) for t in times]
    arm_l = [_euler_xyz(0.85 * math.sin(2 * math.pi * 2 * t / 1000.0),
                        0.55 * math.sin(2 * math.pi * 2 * t / 1000.0 + 0.5),
                        0.40 * math.cos(2 * math.pi * 2 * t / 1000.0)) for t in times]
    arm_r = [_euler_xyz(0.85 * math.sin(2 * math.pi * 2 * t / 1000.0 + math.pi),
                        -0.55 * math.sin(2 * math.pi * 2 * t / 1000.0 + 0.5),
                        -0.40 * math.cos(2 * math.pi * 2 * t / 1000.0)) for t in times]
    _replace_rot(bones[3], dance_i, times, sway, rest[3])
    _replace_rot(bones[2], dance_i, times, bounce, rest[2])
    _replace_rot(bones[4], dance_i, times, spine, rest[4])
    _replace_rot(bones[12], dance_i, times, sh_l, rest[12])
    _replace_rot(bones[13], dance_i, times, sh_r, rest[13])
    _replace_rot(bones[15], dance_i, times, arm_l, rest[15])
    _replace_rot(bones[16], dance_i, times, arm_r, rest[16])
    if len(bones[3].translation.timestamps) > dance_i:
        _replace_trans(bones[3], dance_i, times, bob)
    if len(bones) > 72 and len(bones[72].translation.timestamps) > dance_i:
        _replace_trans(bones[72], dance_i, times,
                       [(0.0, 0.0, 0.07 * math.sin(2 * math.pi * 2 * t / 1000.0 + 0.3)) for t in times])

    # --- Cry / snuff-out: fold forward and cover the wick ---
    ct = [0, 400, 1100, 1800, 2200]
    hunch = [_euler_xyz(a, 0.0, 0.0) for a in (0.0, 0.55, 0.70, 0.55, 0.15)]
    cover_l = [_euler_xyz(ax, ay, 0.2) for ax, ay in ((0, 0), (0.9, 0.7), (1.1, 0.85), (0.9, 0.7), (0.1, 0.1))]
    cover_r = [_euler_xyz(ax, ay, -0.2) for ax, ay in ((0, 0), (0.9, -0.7), (1.1, -0.85), (0.9, -0.7), (0.1, -0.1))]
    _replace_rot(bones[2], cry_i, ct, hunch, rest[2])
    _replace_rot(bones[4], cry_i, ct, [_euler_xyz(a, 0, 0) for a in (0.0, 0.35, 0.45, 0.35, 0.1)], rest[4])
    _replace_rot(bones[15], cry_i, ct, cover_l, rest[15])
    _replace_rot(bones[16], cry_i, ct, cover_r, rest[16])

    # --- SpellCast (seq 20, 1000 ms): birthday blow — lean in, puff, recover ---
    if n_old > SPELLCAST_SEQ:
        bt = [0, 180, 380, 620, 1000]
        blow = [_euler_xyz(a, 0.0, 0.0) for a in (0.0, 0.35, 0.55, 0.20, 0.0)]
        puff_l = [_euler_xyz(ax, 0.4, 0.1) for ax in (0.0, 0.6, 0.85, 0.4, 0.0)]
        puff_r = [_euler_xyz(ax, -0.4, -0.1) for ax in (0.0, 0.6, 0.85, 0.4, 0.0)]
        _replace_rot(bones[4], SPELLCAST_SEQ, bt, blow, rest[4])
        _replace_rot(bones[15], SPELLCAST_SEQ, bt, puff_l, rest[15])
        _replace_rot(bones[16], SPELLCAST_SEQ, bt, puff_r, rest[16])

    with open(path, "wb") as f:
        for b in root.bones:
            if not hasattr(b.rotation, "values"):
                continue
            for arr in b.rotation.values:
                for q in arr:
                    if q.x < -32767:
                        q.x = -32767
                    elif q.x > 32767:
                        q.x = 32767
        root.write(f)
    print(f"authored sequences: Dance idx={dance_i} id={DANCE_ANIM_ID}, Cry idx={cry_i} id={CRY_ANIM_ID}, "
          f"lookup={len(root.sequence_lookup)}")


# ---- 10. custom sequences (Dance + Cry) + SpellCast blow, authored in the M2 ----------------
author_custom_anims(os.path.join(NEW_DIR, NEW + ".m2"))

