"""Build the candle creature mesh procedurally, bound to the Kobold skeleton.

Model space is WoW's: +X forward (the face looks down +X), +Y left, +Z up. Units are the donor's
(kobold ~1.6 tall); the DBC ModelScale makes it 6 ft in game.

Output: out/mesh.json with vertices [{pos, normal, uv, bones[4], weights[4]}], triangles (flat list)
and submeshes [{name, vstart, vcount, istart, icount, material}].
"""
import json
import math
import os
import numpy as np
from wowlib import OUT

TEX = 256.0

# --- kobold bones we bind to (index: pivot) ---------------------------------------------------
B_WAIST, B_SPINE_LO, B_SPINE_UP, B_HEAD = 3, 2, 4, 14
B_SHOULDER = (12, 13)      # L, R  (y+ is left)
B_UPPERARM = (15, 16)
B_FOREARM = (22, 23)
B_HAND = (27, 28)
B_THIGH = (9, 10)
B_SHIN = (18, 19)
B_FOOT = (25, 26)
B_TOE = (30, 31)
B_FLAME = 72               # new billboard bone appended by the splicer (parent: spine-up)

AXIS_X = 0.06              # spine line the body cylinder is centred on
R_BODY = 0.21
Z_BOTTOM, Z_TOP = 0.62, 1.42
SEG = 16                   # cylinder segments

V = []      # vertices: dict(pos, normal, uv, bones, weights)
T = []      # triangle indices
SUB = []    # submeshes


def add_vertex(pos, uv, bw):
    """bw: list of (bone, weight) with weights summing to ~1 (max 4)."""
    bw = sorted([(b, w) for b, w in bw if w > 1e-4], key=lambda x: -x[1])[:4]
    s = sum(w for _, w in bw)
    bones = [b for b, _ in bw] + [0] * (4 - len(bw))
    weights = [int(round(w / s * 255)) for _, w in bw]
    # make weights sum to exactly 255
    if weights:
        weights[0] += 255 - sum(weights)
    weights += [0] * (4 - len(weights))
    V.append({"pos": [float(p) for p in pos], "normal": [0.0, 0.0, 0.0], "uv": [float(uv[0]), float(uv[1])],
              "bones": bones, "weights": weights})
    return len(V) - 1


CENTER = lambda centroid: np.array([AXIS_X, 0.0, centroid[2]])   # "inside" point used to orient faces


def tri(a, b, c):
    """Emit a triangle wound counter-clockwise seen from outside (donor convention: 543/564)."""
    pa, pb, pc = (np.array(V[i]["pos"]) for i in (a, b, c))
    centroid = (pa + pb + pc) / 3
    if np.dot(np.cross(pb - pa, pc - pa), centroid - CENTER(centroid)) < 0:
        b, c = c, b
    T.extend([a, b, c])


def quad(a, b, c, d):
    tri(a, b, c)
    tri(a, c, d)


def body_weights(z):
    """Blend along the spine by height.

    Never weight the cylinder/crown onto B_HEAD. The kobold head pivot is ~0.28
    forward of the wax axis, so a head-bound lid yaws off the body when he turns.
    """
    if z <= 0.78:
        return [(B_WAIST, 1.0)]
    if z <= 0.98:
        t = (z - 0.78) / 0.20
        return [(B_WAIST, 1 - t), (B_SPINE_LO, t)]
    if z <= 1.20:
        t = (z - 0.98) / 0.22
        return [(B_SPINE_LO, 1 - t), (B_SPINE_UP, t)]
    return [(B_SPINE_UP, 1.0)]


def ring(cx, cy, z, radius, seg, v, bw=None, u_span=1.0, u0=0.0, a0=math.pi):
    """Ring of seg+1 vertices (seam duplicated) starting at angle a0. u runs u0..u0+u_span.

    With a0 = pi the seam is at the back and the front (+X) lands at u0 + u_span/2. The donor
    texture flags are 0 (clamp), so u must stay inside [0, 1].
    """
    idx = []
    for i in range(seg + 1):
        a = a0 + 2 * math.pi * i / seg
        u = u0 + u_span * i / seg
        x = cx + radius * math.cos(a)
        y = cy + radius * math.sin(a)
        idx.append(add_vertex((x, y, z), (u, v), bw or body_weights(z)))
    return idx


def connect(r0, r1, flip=False):
    n = len(r0) - 1
    for i in range(n):
        if flip:
            quad(r0[i], r1[i], r1[i + 1], r0[i + 1])
        else:
            quad(r0[i], r0[i + 1], r1[i + 1], r1[i])


def body_v(z):
    """Texture v for the body wrap: top rim v=0.03 .. bottom v=0.47."""
    return 0.03 + (Z_TOP - z) / (Z_TOP - Z_BOTTOM) * 0.44


# ==== BODY ======================================================================================
vstart, istart = len(V), len(T)
# The body wrap uses the top half of the texture: u 0..1 around (seam at the back, face at u=0.5),
# v 0.0 (top rim) .. 0.47 (bottom).
rings_z = [Z_BOTTOM, 0.70, 0.80, 0.90, 1.00, 1.10, 1.20, 1.30, 1.36]
rings = []
for z in rings_z:
    # slight taper: fatter at the bottom
    r = R_BODY * (1.0 + 0.04 * (Z_TOP - z))
    rings.append(ring(AXIS_X, 0.0, z, r, SEG, body_v(z)))
# drip rim: bulges out then curls up to the top edge
rim_lo = ring(AXIS_X, 0.0, 1.385, R_BODY * 1.10, SEG, 0.012)
rim_hi = ring(AXIS_X, 0.0, Z_TOP, R_BODY * 1.06, SEG, 0.0)
for a, b in zip(rings[:-1] + [rings[-1], rim_lo], rings[1:] + [rim_lo, rim_hi]):
    connect(a, b)

# top dish (concave) mapped into the limb-wax quadrant (u 0..0.44, v 0.5..1)
dish_edge = ring(AXIS_X, 0.0, 1.405, R_BODY * 0.95, SEG, 0.53, bw=[(B_SPINE_UP, 1.0)], u_span=0.44)
dish_low = ring(AXIS_X, 0.0, 1.35, R_BODY * 0.30, SEG, 0.60, bw=[(B_SPINE_UP, 1.0)], u_span=0.44)
CENTER = lambda c: np.array([AXIS_X, 0.0, 1.0])       # concave dish faces up
connect(rim_hi, dish_edge)
connect(dish_edge, dish_low)
CENTER = lambda centroid: np.array([AXIS_X, 0.0, centroid[2]])
# wick: dark patch at u 0.45..0.5, v 0.95..1.0
wick_base = ring(AXIS_X, 0.0, 1.35, 0.022, SEG, 0.99, bw=[(B_SPINE_UP, 1.0)], u_span=0.05, u0=0.45)
wick_top = ring(AXIS_X, 0.0, 1.52, 0.016, SEG, 0.955, bw=[(B_SPINE_UP, 1.0)], u_span=0.05, u0=0.45)
connect(dish_low, wick_base)
connect(wick_base, wick_top)
wick_cap = add_vertex((AXIS_X, 0.0, 1.53), (0.475, 0.955), [(B_SPINE_UP, 1.0)])
CENTER = lambda c: np.array([AXIS_X, 0.0, 1.0])       # dish, wick cap: outside is "up"
for i in range(SEG):
    tri(wick_top[i], wick_top[i + 1], wick_cap)
# bottom cap
bot_c = add_vertex((AXIS_X, 0.0, Z_BOTTOM), (0.2, 0.75), [(B_WAIST, 1.0)])
CENTER = lambda c: np.array([AXIS_X, 0.0, 1.0])       # bottom cap faces down
for i in range(SEG):
    tri(rings[0][i + 1], rings[0][i], bot_c)


# ==== LIMBS =====================================================================================
def tube(points, radii, bone_chain, seg=8, u0=0.0, u_span=0.44, v0=0.52, v1=0.98):
    """Tube through `points` (list of xyz). bone_chain: list of (bone,) per point, blended between."""
    global CENTER
    pts_arr = np.array(points, dtype=float)

    def nearest_on_polyline(c):
        best, bd = pts_arr[0], 1e9
        for p0, p1 in zip(pts_arr[:-1], pts_arr[1:]):
            d = p1 - p0
            t = float(np.clip(np.dot(c - p0, d) / (np.dot(d, d) + 1e-12), 0, 1))
            q = p0 + t * d
            dist = np.linalg.norm(c - q)
            if dist < bd:
                best, bd = q, dist
        return best
    CENTER = nearest_on_polyline
    rings_ = []
    n = len(points)
    for k, (p, r) in enumerate(zip(points, radii)):
        p = np.array(p, dtype=float)
        # local frame: direction along the tube
        if k == 0:
            d = np.array(points[1]) - p
        elif k == n - 1:
            d = p - np.array(points[k - 1])
        else:
            d = np.array(points[k + 1]) - np.array(points[k - 1])
        d = d / (np.linalg.norm(d) + 1e-9)
        ref = np.array([1.0, 0.0, 0.0]) if abs(d[0]) < 0.9 else np.array([0.0, 0.0, 1.0])
        e1 = np.cross(d, ref); e1 /= np.linalg.norm(e1)
        e2 = np.cross(d, e1)
        v = v0 + (v1 - v0) * k / (n - 1)
        idx = []
        for i in range(seg + 1):
            a = 2 * math.pi * i / seg
            q = p + r * (math.cos(a) * e1 + math.sin(a) * e2)
            idx.append(add_vertex(q, (u0 + u_span * i / seg, v), bone_chain[k]))
        rings_.append(idx)
    for a, b in zip(rings_[:-1], rings_[1:]):
        connect(a, b)
    return rings_


def blob(center, radii, bw, seg=8, stacks=4, u0=0.0, u_span=0.44, v0=0.6, v1=0.9):
    """Ellipsoid blob (mitten / foot)."""
    global CENTER
    CENTER = lambda c, _ctr=np.array(center, dtype=float): _ctr
    cx, cy, cz = center
    rx, ry, rz = radii
    rings_ = []
    for s in range(stacks + 1):
        phi = math.pi * s / stacks          # 0 top .. pi bottom
        z = cz + rz * math.cos(phi)
        rr = math.sin(phi)
        idx = []
        for i in range(seg + 1):
            a = 2 * math.pi * i / seg
            idx.append(add_vertex((cx + rx * rr * math.cos(a), cy + ry * rr * math.sin(a), z),
                                  (u0 + u_span * i / seg, v0 + (v1 - v0) * s / stacks), bw))
        rings_.append(idx)
    for a, b in zip(rings_[:-1], rings_[1:]):
        connect(a, b, flip=True)
    return rings_


for side, sgn in ((0, 1.0), (1, -1.0)):
    # arm: shoulder (in the body) -> elbow -> wrist
    sh, ua, fa, ha = B_SHOULDER[side], B_UPPERARM[side], B_FOREARM[side], B_HAND[side]
    pts = [(0.09, sgn * 0.17, 1.30), (0.06, sgn * 0.26, 1.18), (-0.02, sgn * 0.31, 1.04),
           (-0.03, sgn * 0.35, 0.86), (-0.03, sgn * 0.36, 0.72)]
    chain = [[(ua, 0.8), (sh, 0.2)], [(ua, 1.0)], [(ua, 0.45), (fa, 0.55)], [(fa, 0.8), (ha, 0.2)], [(ha, 1.0)]]
    tube(pts, [0.075, 0.062, 0.058, 0.055, 0.052], chain)
    blob((-0.03, sgn * 0.37, 0.64), (0.085, 0.075, 0.095), [(ha, 1.0)])
    # leg: hip (inside body) -> knee -> ankle
    th, shn, ft, toe = B_THIGH[side], B_SHIN[side], B_FOOT[side], B_TOE[side]
    pts = [(0.04, sgn * 0.125, 0.70), (0.02, sgn * 0.128, 0.56), (-0.005, sgn * 0.13, 0.41),
           (-0.04, sgn * 0.13, 0.27), (-0.06, sgn * 0.13, 0.15)]
    chain = [[(th, 1.0)], [(th, 0.75), (shn, 0.25)], [(shn, 1.0)], [(shn, 0.6), (ft, 0.4)], [(ft, 1.0)]]
    tube(pts, [0.085, 0.08, 0.075, 0.072, 0.07], chain)
    blob((0.03, sgn * 0.13, 0.065), (0.17, 0.095, 0.065), [(ft, 0.7), (toe, 0.3)])

SUB.append({"name": "body", "vstart": vstart, "vcount": len(V) - vstart, "istart": istart,
            "icount": len(T) - istart, "material": 0, "center_bone": B_SPINE_LO})

# ==== FLAME (billboard quad on the new flame bone) ===============================================
vstart, istart = len(V), len(T)
fx, fz = AXIS_X, 1.53          # flame base = wick top
w, h = 0.16, 0.40
# billboard bone: the client rotates the bone to face the camera; geometry is in the bone's local
# frame at the pivot. Spherical billboards: local +X toward the camera, +Y right(ish), +Z up.
bw = [(B_FLAME, 1.0)]
fl = [add_vertex((fx, -w, fz), (0.52, 0.98), bw), add_vertex((fx, w, fz), (0.98, 0.98), bw),
      add_vertex((fx, w, fz + h), (0.98, 0.52), bw), add_vertex((fx, -w, fz + h), (0.52, 0.52), bw)]
T.extend([fl[0], fl[1], fl[2], fl[0], fl[2], fl[3]])   # two-sided material: winding irrelevant
SUB.append({"name": "flame", "vstart": vstart, "vcount": len(V) - vstart, "istart": istart,
            "icount": len(T) - istart, "material": 1, "center_bone": B_FLAME})

# ==== normals (area-weighted, smooth) ===========================================================
P = np.array([v["pos"] for v in V])
N = np.zeros_like(P)
tri_arr = np.array(T).reshape(-1, 3)
for a, b, c in tri_arr:
    n = np.cross(P[b] - P[a], P[c] - P[a])
    N[a] += n; N[b] += n; N[c] += n
for i, v in enumerate(V):
    ln = np.linalg.norm(N[i])
    v["normal"] = [float(x) for x in (N[i] / ln if ln > 1e-12 else np.array([0, 0, 1.0]))]
# flame quads: normal up, they are unlit anyway
for vi in fl:
    V[vi]["normal"] = [0.0, 0.0, 1.0]

# body u: wrap into [0, 1) range is not needed (sampler repeats), but keep floats sane
mesh = {"vertices": V, "triangles": T, "submeshes": SUB,
        "bbox_min": [float(x) for x in P.min(axis=0)], "bbox_max": [float(x) for x in P.max(axis=0)]}
with open(os.path.join(OUT, "mesh.json"), "w") as f:
    json.dump(mesh, f)
print(f"vertices={len(V)} triangles={len(T)//3} submeshes={[(s['name'], s['vcount'], s['icount']//3) for s in SUB]}")
print("bbox", mesh["bbox_min"], mesh["bbox_max"])
maxb = max(max(v["bones"]) for v in V)
print("max bone id used:", maxb, " distinct bones:", sorted({b for v in V for b, w in zip(v['bones'], v['weights']) if w}))
