#!/usr/bin/env python3
"""Generate The Drowned Belfry WMO v17 + WDT (WotLK) and optional DBC rows.

Clone DBC from patch-enUS-3.MPQ (66-field Map.dbc). Do not clone locale-enUS.MPQ
(126-field vanilla layout the patches replaced).

World SQL uses the -X copy. Verts are emitted origin-symmetric so the client
shows a floor where players stand and vmaps have a hull after fixCoords.

Textures reuse the Waxworks BLPs already shipped in patch-4.MPQ.

Client collision: two-sided / thick floors, real MONR, MOBA per material, MOLR
on the group. Stub normals and a paper-thin floor render but do not catch the
3.3.5 walk hull (see reference-mesh.md pitfalls).
"""
from __future__ import annotations

import argparse
import struct
from pathlib import Path

WMO_PATH = r"World\wmo\Dungeon\DrownedBelfry\DrownedBelfry.wmo"
TEX_FLOOR = r"DUNGEONS\TEXTURES\FLOOR\MM_CAVEFLOOR_03.BLP"
TEX_WALL = r"DUNGEONS\TEXTURES\ROCK\MM_CAVEWALL_08.BLP"
LANG_MASK = 16712190


def _pad4(n: int) -> int:
    return (4 - (n % 4)) % 4


def cstr_aligned(s: str) -> bytes:
    """MOTX entries are 4-byte aligned; the client indexes them by that offset."""
    b = s.encode("ascii") + b"\x00"
    return b + b"\x00" * _pad4(len(b))


def chunk(tag: str, data: bytes) -> bytes:
    """WMO/WDT chunk. Size includes 4-byte padding: AC extractors seek size
    bytes and do not align, so a pad-only trailer would skip the next chunk.
    """
    pad = b"\x00" * _pad4(len(data))
    payload = data + pad
    return tag[::-1].encode("ascii") + struct.pack("<I", len(payload)) + payload


class Mesh:
    def __init__(self) -> None:
        self.verts: list[tuple[float, float, float]] = []
        self.tris: list[tuple[int, int, int, int]] = []  # i0,i1,i2,mat

    def add_vert(self, p: tuple[float, float, float]) -> int:
        self.verts.append(p)
        return len(self.verts) - 1

    def add_quad(self, a, b, c, d, mat: int) -> None:
        ia, ib, ic, id_ = (self.add_vert(p) for p in (a, b, c, d))
        self.tris.append((ia, ib, ic, mat))
        self.tris.append((ia, ic, id_, mat))

    def wall_with_door(self, p00, p10, door_t0, door_t1, door_h, wall_h, mat, floor_z):
        def lerp(t):
            return (
                p00[0] + (p10[0] - p00[0]) * t,
                p00[1] + (p10[1] - p00[1]) * t,
                floor_z,
            )

        def up(p, z):
            return (p[0], p[1], z)

        z1 = floor_z + wall_h
        zd = floor_z + door_h
        left = lerp(0.0)
        d0 = lerp(door_t0)
        d1 = lerp(door_t1)
        right = lerp(1.0)
        self.add_quad(left, d0, up(d0, z1), up(left, z1), mat)
        self.add_quad(d1, right, up(right, z1), up(d1, z1), mat)
        self.add_quad(up(d0, zd), up(d1, zd), up(d1, z1), up(d0, z1), mat)

    def closed_wall(self, p0, p1, floor_z, height, mat):
        z1 = floor_z + height
        a = (p0[0], p0[1], floor_z)
        b = (p1[0], p1[1], floor_z)
        c = (p1[0], p1[1], z1)
        d = (p0[0], p0[1], z1)
        self.add_quad(a, b, c, d, mat)

    def floor_ceil(self, x0, x1, y0, y1, floor_z, height, mat_f, mat_c):
        zc = floor_z + height
        zb = floor_z - 0.35
        # Walkable top, CCW from +Z. Duplicate the opposite winding: the 3.3.5
        # client collides one-sided, and a zero-thickness plane is easy to miss.
        self.add_quad((x0, y0, floor_z), (x1, y0, floor_z), (x1, y1, floor_z), (x0, y1, floor_z), mat_f)
        self.add_quad((x0, y1, floor_z), (x1, y1, floor_z), (x1, y0, floor_z), (x0, y0, floor_z), mat_f)
        self.add_quad((x0, y0, zb), (x0, y1, zb), (x1, y1, zb), (x1, y0, zb), mat_f)
        self.add_quad((x0, y1, zc), (x1, y1, zc), (x1, y0, zc), (x0, y0, zc), mat_c)
        self.add_quad((x0, y0, zc), (x1, y0, zc), (x1, y1, zc), (x0, y1, zc), mat_c)

    def compute_normals(self) -> list[tuple[float, float, float]]:
        acc = [(0.0, 0.0, 0.0)] * len(self.verts)
        for i0, i1, i2, _ in self.tris:
            a, b, c = self.verts[i0], self.verts[i1], self.verts[i2]
            e1 = (b[0] - a[0], b[1] - a[1], b[2] - a[2])
            e2 = (c[0] - a[0], c[1] - a[1], c[2] - a[2])
            nx = e1[1] * e2[2] - e1[2] * e2[1]
            ny = e1[2] * e2[0] - e1[0] * e2[2]
            nz = e1[0] * e2[1] - e1[1] * e2[0]
            for i in (i0, i1, i2):
                ax, ay, az = acc[i]
                acc[i] = (ax + nx, ay + ny, az + nz)
        out = []
        for x, y, z in acc:
            length = (x * x + y * y + z * z) ** 0.5
            out.append((0.0, 0.0, 1.0) if length < 1e-6 else (x / length, y / length, z / length))
        return out

    def tris_by_material(self) -> list[tuple[int, int, int, int]]:
        return [t for t in self.tris if t[3] == 0] + [t for t in self.tris if t[3] != 0]

    def mirror(self) -> None:
        n = len(self.verts)
        for x, y, z in list(self.verts):
            self.verts.append((-x, -y, z))
        extra = []
        for i0, i1, i2, mat in self.tris:
            extra.append((i0 + n, i2 + n, i1 + n, mat))
        self.tris.extend(extra)


def box_room(mesh: Mesh, cx, cy, floor_z, hx, hy, height, doors: dict[str, tuple[float, float]]):
    """doors: '+x'/'-x'/'+y'/'-y' -> (half_width, height). Opening centered on that wall."""
    x0, x1 = cx - hx, cx + hx
    y0, y1 = cy - hy, cy + hy
    mesh.floor_ceil(x0, x1, y0, y1, floor_z, height, 0, 1)

    def maybe(side, p0, p1, along_len):
        if side not in doors:
            mesh.closed_wall(p0, p1, floor_z, height, 1)
            return
        dw, dh = doors[side]
        t0 = 0.5 - (dw / along_len) / 2
        t1 = 0.5 + (dw / along_len) / 2
        t0 = max(0.08, t0)
        t1 = min(0.92, t1)
        mesh.wall_with_door(p0, p1, t0, t1, dh, height, 1, floor_z)

    maybe("+x", (x1, y0), (x1, y1), 2 * hy)
    maybe("-x", (x0, y1), (x0, y0), 2 * hy)
    maybe("+y", (x1, y1), (x0, y1), 2 * hx)
    maybe("-y", (x0, y0), (x1, y0), 2 * hx)


def build_layout() -> Mesh:
    m = Mesh()
    dh, dw = 5.0, 4.0
    # Tide Porch has +x (exit toward origin) and -x (nave). World -X copy.
    box_room(m, -16, 0, 0.0, 6, 5, 8, {"-x": (dw, dh), "+x": (dw, dh)})
    box_room(m, -31, 0, 0.0, 9, 2.5, 6, {"+x": (dw, dh), "-x": (dw, dh)})
    box_room(m, -50, 0, 0.0, 10, 8, 10, {"+x": (dw, dh), "-x": (dw, dh), "-y": (dw, dh), "+y": (dw, dh)})
    box_room(m, -50, -13, 0.0, 2.5, 5, 7, {"+y": (dw, dh), "-y": (dw, dh)})
    box_room(m, -50, -24, 1.0, 6, 6, 8, {"+y": (dw, dh)})
    box_room(m, -50, 12.5, -7.0, 2.5, 4.5, 10, {"-y": (dw, dh), "+y": (dw, dh)})
    box_room(m, -50, 24, -7.0, 7, 7, 9, {"-y": (dw, dh)})
    box_room(m, -64, 0, 0.0, 4, 2.5, 7, {"+x": (dw, dh), "-x": (dw, dh)})
    box_room(m, -76, 0, 0.0, 8, 7, 8, {"+x": (dw, dh), "-x": (dw, dh)})
    box_room(m, -88.5, 0, 0.0, 4.5, 2.5, 7, {"+x": (dw, dh), "-x": (dw, dh)})
    box_room(m, -102, 0, 0.0, 9, 9, 12, {"+x": (dw, dh)})
    m.mirror()
    return m


def bbox(verts):
    xs, ys, zs = zip(*verts)
    return min(xs), min(ys), min(zs), max(xs), max(ys), max(zs)


def write_group(path: Path, mesh: Mesh, name_ofs: int, desc_ofs: int) -> None:
    bb = bbox(mesh.verts)
    tris = mesh.tris_by_material()
    ntri = len(tris)
    nvert = len(mesh.verts)
    n0 = sum(1 for t in tris if t[3] == 0)
    n1 = ntri - n0
    normals = mesh.compute_normals()
    # HAS_BSP + HAS_MOCV + HAS_LIGHTS + INTERIOR. Must match root MOGI.
    flags = 0x1 | 0x4 | 0x200 | 0x2000
    # 68-byte MOGP: 60-byte vmap-read header + 8 bytes WotLK flags2/parent/sibling.
    mogp = b"".join((
        struct.pack("<III", name_ofs, desc_ofs, flags),
        struct.pack("<6f", *bb),
        struct.pack("<HH", 0, 0),  # portalStart, portalCount
        struct.pack("<HH", 0, (1 if n0 else 0) + (1 if n1 else 0)),  # nBatchA trans, nBatchB int
        struct.pack("<I", 0),  # nBatchC
        struct.pack("<I", 0),  # fogIds
        struct.pack("<I", 15),  # groupLiquid = none
        struct.pack("<I", 900001),
        struct.pack("<IHH", 0, 0, 0),  # flags2 + parent + sibling
    ))
    assert len(mogp) == 68, len(mogp)

    mopy = b"".join(struct.pack("<BB", 0x28, tri[3]) for tri in tris)
    movi = b"".join(struct.pack("<HHH", t[0], t[1], t[2]) for t in tris)
    # MOPY size/2 is triangle count; keep payloads 4-aligned so padding is not counted as faces.
    assert len(mopy) % 4 == 0 and len(movi) % 4 == 0, (len(mopy), len(movi))
    movt = b"".join(struct.pack("<fff", *v) for v in mesh.verts)
    monr = b"".join(struct.pack("<fff", *n) for n in normals)
    motv = b"".join(struct.pack("<ff", v[0] * 0.12, v[1] * 0.12) for v in mesh.verts)
    mocv = b"".join(struct.pack("<BBBB", 70, 80, 95, 255) for _ in mesh.verts)

    bx0 = int(max(-32767, min(32767, bb[0])))
    by0 = int(max(-32767, min(32767, bb[1])))
    bz0 = int(max(-32767, min(32767, bb[2])))
    bx1 = int(max(-32767, min(32767, bb[3])))
    by1 = int(max(-32767, min(32767, bb[4])))
    bz1 = int(max(-32767, min(32767, bb[5])))
    # SMOBatch 24 bytes: int16 bbox[6], startIndex u32, count u16, minIndex u16, maxIndex u16, flags u8, mat u8
    def batch(start_tri: int, count_tri: int, mat: int) -> bytes:
        if count_tri == 0:
            return b""
        idxs = [i for t in tris[start_tri:start_tri + count_tri] for i in t[:3]]
        return struct.pack("<hhhhhhIHHHBB",
                           bx0, by0, bz0, bx1, by1, bz1,
                           start_tri * 3, count_tri * 3, min(idxs), max(idxs), 0, mat)

    moba = batch(0, n0, 0) + batch(n0, n1, 1)
    assert len(moba) % 24 == 0, len(moba)

    # 16-byte BSP leaf
    mobn = struct.pack("<HhhHIf", 4, -1, -1, ntri, 0, 0.0)
    assert len(mobn) == 16, len(mobn)
    mobr = b"".join(struct.pack("<H", i) for i in range(ntri))
    molt_ref = struct.pack("<H", 0)  # group uses root MOLT[0]

    inner = b"".join((
        chunk("MOPY", mopy),
        chunk("MOVI", movi),
        chunk("MOVT", movt),
        chunk("MONR", monr),
        chunk("MOTV", motv),
        chunk("MOBA", moba),
        chunk("MOLR", molt_ref),
        chunk("MOBN", mobn),
        chunk("MOBR", mobr),
        chunk("MOCV", mocv),
    ))
    mogp_chunk = b"PGOM" + struct.pack("<I", 68 + len(inner)) + mogp + inner
    path.write_bytes(chunk("MVER", struct.pack("<I", 17)) + mogp_chunk)


def write_root(path: Path, mesh: Mesh) -> tuple[int, int]:
    names = b"\x00" + b"DrownedBelfry\x00" + b"The Drowned Belfry\x00"
    name_ofs = 1
    desc_ofs = 1 + len("DrownedBelfry") + 1
    bb = bbox(mesh.verts)
    flags = 0x1 | 0x4 | 0x200 | 0x2000  # same bits as the group MOGP header
    mogi = struct.pack("<I6fi", flags, *bb, name_ofs)
    floor_tex = cstr_aligned(TEX_FLOOR)
    wall_tex = cstr_aligned(TEX_WALL)
    tex = floor_tex + wall_tex
    floor_off = 0
    wall_off = len(floor_tex)

    def material(tex_off: int) -> bytes:
        # SMOMaterial 64 bytes. Flags 0 matches the working Waxworks materials;
        # texture1 is 4-aligned into MOTX. texture2 unused (shader 0).
        return struct.pack("<IIIIIIIIIIIIIIII",
                           0,
                           0, 0, tex_off,
                           0xFF000000, 0,
                           0, 0xFF808080,
                           0, 0, 0, 0, 0, 0, 0, 0)

    momt = material(floor_off) + material(wall_off)
    mohd = struct.pack("<7I", 2, 1, 0, 1, 0, 0, 1)
    mohd += struct.pack("<I", 0xFF405060)
    mohd += struct.pack("<I", 900000)
    mohd += struct.pack("<6f", *bb)
    mohd += struct.pack("<I", 0x2)  # do not use liquid DBC id
    assert len(mohd) == 64, len(mohd)

    mods = struct.pack("<20sIII", b"Set_$DefaultGlobal", 0, 0, 0)
    # One omni light so INTERIOR groups are not skipped as unlit.
    molt = struct.pack("<BB2x I 3f f f f 4f",
                       1, 1,
                       0xFFC0D0E0,
                       0.0, 0.0, 4.0,
                       2.0,
                       0.0, 400.0,
                       0.0, 0.0, 0.0, 0.0)
    assert len(molt) == 48, len(molt)
    fog = struct.pack("<I3f2f", 0, 0.0, 0.0, 0.0, 0.0, 0.0)
    fog += struct.pack("<ffI", 444.4445, 0.25, 0xFF708090)
    fog += struct.pack("<ffI", 222.2222, -0.5, 0xFF102030)
    assert len(fog) == 48, len(fog)

    path.write_bytes(b"".join((
        chunk("MVER", struct.pack("<I", 17)),
        chunk("MOHD", mohd),
        chunk("MOTX", tex),
        chunk("MOMT", momt),
        chunk("MOGN", names),
        chunk("MOGI", mogi),
        chunk("MOSB", b"\x00"),
        chunk("MOPV", b""),
        chunk("MOPT", b""),
        chunk("MOPR", b""),
        chunk("MOVV", b""),
        chunk("MOVB", b""),
        chunk("MOLT", molt),
        chunk("MODS", mods),
        chunk("MODN", b"\x00"),
        chunk("MODD", b""),
        chunk("MFOG", fog),
    )))
    return name_ofs, desc_ofs


def write_wdt(path: Path, mesh: Mesh) -> None:
    bb = bbox(mesh.verts)
    pad = 200.0
    bounds = (bb[0] - pad, bb[1] - pad, bb[2] - pad, bb[3] + pad, bb[4] + pad, bb[5] + pad)
    mver = chunk("MVER", struct.pack("<I", 18))
    mphd = chunk("MPHD", struct.pack("<8I", 1, 0, 0, 0, 0, 0, 0, 0))
    main = chunk("MAIN", b"\x00" * (64 * 64 * 8))
    mwmo = chunk("MWMO", WMO_PATH.encode("ascii") + b"\x00")
    modf = struct.pack(
        "<II 3f 3f 6f HHHH",
        0, 0xFFFFFFFF,  # nameId 0, uniqueId -1 (Ragefire / Waxworks)
        0.0, 0.0, 0.0,
        0.0, 0.0, 0.0,
        *bounds,
        0, 0, 0, 0,
    )
    assert len(modf) == 64, len(modf)
    path.write_bytes(mver + mphd + main + mwmo + chunk("MODF", modf))


class DBC:
    def __init__(self, data: bytes) -> None:
        if data[:4] != b"WDBC":
            raise ValueError("not WDBC")
        self.n, self.fields, self.rec, self.slen = struct.unpack_from("<4I", data, 4)
        off = 20
        self.records = [data[off + i * self.rec: off + (i + 1) * self.rec] for i in range(self.n)]
        self.strings = bytearray(data[off + self.n * self.rec:])
        if not self.strings:
            self.strings = bytearray(b"\x00")

    def id_of(self, rec: bytes) -> int:
        return struct.unpack_from("<I", rec, 0)[0]

    def find(self, rec_id: int) -> bytes:
        for r in self.records:
            if self.id_of(r) == rec_id:
                return r
        raise KeyError(rec_id)

    def add_string(self, s: str) -> int:
        b = s.encode("utf-8") + b"\x00"
        ofs = len(self.strings)
        self.strings.extend(b)
        return ofs

    def dumps(self) -> bytes:
        body = b"".join(self.records)
        strb = bytes(self.strings)
        if not strb.endswith(b"\x00"):
            strb += b"\x00"
        hdr = b"WDBC" + struct.pack("<4I", len(self.records), self.fields, self.rec, len(strb))
        return hdr + body + strb


def clone_map_row(dbc: DBC, src_id: int) -> None:
    """patch-enUS-3 Map.dbc: 66 fields / 264 bytes. Offsets match MapEntryfmt."""
    if dbc.fields != 66 or dbc.rec != 264:
        raise SystemExit(f"Map.dbc is {dbc.fields} fields/{dbc.rec} bytes; need patch-enUS-3 (66/264)")
    rec = bytearray(dbc.find(src_id))
    struct.pack_into("<I", rec, 0, 900)  # ID
    struct.pack_into("<I", rec, 4, dbc.add_string("DrownedBelfry"))  # Directory
    struct.pack_into("<I", rec, 8, 1)  # InstanceType
    struct.pack_into("<I", rec, 12, 0)  # Flags
    struct.pack_into("<I", rec, 16, 0)  # PVP
    struct.pack_into("<I", rec, 20, dbc.add_string("The Drowned Belfry"))  # MapName enUS
    struct.pack_into("<I", rec, 21 * 4, LANG_MASK)
    struct.pack_into("<I", rec, 22 * 4, 9000)  # AreaTableID
    struct.pack_into("<I", rec, 57 * 4, 15)  # LoadingScreenID (Stockades)
    struct.pack_into("<f", rec, 58 * 4, 1.0)  # MinimapIconScale
    struct.pack_into("<I", rec, 59 * 4, 0)  # CorpseMapID Eastern Kingdoms
    struct.pack_into("<f", rec, 60 * 4, -10740.0)
    struct.pack_into("<f", rec, 61 * 4, -1189.67)
    struct.pack_into("<i", rec, 62 * 4, -1)  # TimeOfDayOverride
    struct.pack_into("<I", rec, 63 * 4, 0)  # ExpansionID
    struct.pack_into("<I", rec, 64 * 4, 0)  # RaidOffset
    struct.pack_into("<I", rec, 65 * 4, 5)  # MaxPlayers
    dbc.records.append(bytes(rec))


def clone_mapdifficulty(dbc: DBC) -> None:
    src = None
    for rec in dbc.records:
        map_id, diff = struct.unpack_from("<II", rec, 4)
        if map_id == 33 and diff == 0:
            src = rec
            break
    if src is None:
        raise SystemExit("no MapDifficulty row for map 33 difficulty 0")
    rec = bytearray(src)
    struct.pack_into("<I", rec, 0, 9000900)
    struct.pack_into("<I", rec, 4, 900)
    struct.pack_into("<I", rec, 8, 0)
    struct.pack_into("<I", rec, 21 * 4, 5)  # MaxPlayers
    dbc.records.append(bytes(rec))


def clone_areatable(dbc: DBC) -> None:
    rec = bytearray(dbc.find(2437))
    struct.pack_into("<I", rec, 0, 9000)
    struct.pack_into("<I", rec, 4, 900)  # ContinentID
    struct.pack_into("<I", rec, 8, 0)  # Parent
    struct.pack_into("<I", rec, 12, 3990)  # AreaBit
    struct.pack_into("<I", rec, 16, 0)  # Flags
    struct.pack_into("<I", rec, 10 * 4, 22)  # ExplorationLevel
    struct.pack_into("<I", rec, 11 * 4, dbc.add_string("The Drowned Belfry"))
    struct.pack_into("<I", rec, 27 * 4, LANG_MASK)
    dbc.records.append(bytes(rec))


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", required=True, help="loose client root (contains World/)")
    ap.add_argument("--dbc-mpq", help="patch-enUS-3.MPQ (66-field Map.dbc) for cloning rows")
    args = ap.parse_args()
    out = Path(args.out)
    wmo_dir = out / "World" / "wmo" / "Dungeon" / "DrownedBelfry"
    map_dir = out / "World" / "Maps" / "DrownedBelfry"
    wmo_dir.mkdir(parents=True, exist_ok=True)
    map_dir.mkdir(parents=True, exist_ok=True)

    mesh = build_layout()
    print(f"verts={len(mesh.verts)} tris={len(mesh.tris)} bb={bbox(mesh.verts)}")
    name_ofs, desc_ofs = write_root(wmo_dir / "DrownedBelfry.wmo", mesh)
    write_group(wmo_dir / "DrownedBelfry_000.wmo", mesh, name_ofs, desc_ofs)
    write_wdt(map_dir / "DrownedBelfry.wdt", mesh)
    print("wrote WMO+WDT")

    if not args.dbc_mpq:
        return
    from mpyq import MPQArchive
    arc = MPQArchive(args.dbc_mpq)
    dbc_dir = out / "DBFilesClient"
    dbc_dir.mkdir(parents=True, exist_ok=True)

    def extract(name: str) -> bytes:
        key = f"DBFilesClient\\{name}".encode("ascii")
        data = arc.read_file(key)
        if not data:
            raise SystemExit(f"{name} missing from {args.dbc_mpq}")
        return data

    m = DBC(extract("Map.dbc"))
    clone_map_row(m, 33)
    (dbc_dir / "Map.dbc").write_bytes(m.dumps())

    md = DBC(extract("MapDifficulty.dbc"))
    clone_mapdifficulty(md)
    (dbc_dir / "MapDifficulty.dbc").write_bytes(md.dumps())

    at = DBC(extract("AreaTable.dbc"))
    clone_areatable(at)
    (dbc_dir / "AreaTable.dbc").write_bytes(at.dumps())
    print("wrote Map/MapDifficulty/AreaTable DBC")


if __name__ == "__main__":
    main()
