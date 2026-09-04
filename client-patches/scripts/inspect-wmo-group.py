#!/usr/bin/env python3
"""Print WMO group collision-related chunks (MVER, MOGP flags, MOPY, MONR, MOBA, MOLR, MLIQ).

Python-hull / Waxworks walkable faces are MOPY 0x28 (render + F_COLLISION).
WBS Quick collision does not emit 0x28 on visible faces: it emits 0x20 (F_RENDER)
when every vertex of a triangle is in the Collision vertex group, or 0x24
(F_RENDER|F_DETAIL) when the group is incomplete. Ghost collision-collection
meshes are 0x08 only. See reference-blender-wmo.md.
"""
from __future__ import annotations

import argparse
import struct
import sys
from collections import Counter
from pathlib import Path


def find_chunk(blob: bytes, name: str) -> tuple[int, int] | None:
    fwd = name.encode("ascii")
    rev = name[::-1].encode("ascii")
    idx = blob.find(rev)
    if idx < 0:
        idx = blob.find(fwd)
    if idx < 0:
        return None
    size = struct.unpack_from("<I", blob, idx + 4)[0]
    return idx, size


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("group", type=Path, help="Name_000.wmo")
    args = ap.parse_args()
    blob = args.group.read_bytes()
    mopy = find_chunk(blob, "MOPY")
    if mopy is None:
        print("no MOPY", file=sys.stderr)
        return 1
    idx, size = mopy
    flags = blob[idx + 8: idx + 8 + size: 2]
    counts = dict(Counter(flags))
    mver = find_chunk(blob, "MVER")
    mver_n = struct.unpack_from("<I", blob, mver[0] + 8)[0] if mver else -1
    print(f"{args.group.name} MVER={mver_n} MOPY n={len(flags)} {counts}")
    mogp = find_chunk(blob, "MOGP")
    if mogp:
        flags32 = struct.unpack_from("<I", blob, mogp[0] + 8 + 8)[0]
        indoor = bool(flags32 & 0x2000)
        outdoor = bool(flags32 & 0x8)
        print(f"  MOGP flags=0x{flags32:x} indoor={indoor} outdoor={outdoor}")
    monr = find_chunk(blob, "MONR")
    if monr:
        n = monr[1] // 12
        stub = 0
        for i in range(n):
            x, y, z = struct.unpack_from("<3f", blob, monr[0] + 8 + i * 12)
            if abs(x) < 1e-6 and abs(y) < 1e-6 and abs(z - 1.0) < 1e-4:
                stub += 1
        print(f"  MONR n={n} stub(0,0,1)={stub}")
    moba = find_chunk(blob, "MOBA")
    if moba:
        print(f"  MOBA batches={moba[1] // 24}")
    print(f"  MOLR={'yes' if find_chunk(blob, 'MOLR') else 'no'} "
          f"MLIQ={'yes' if find_chunk(blob, 'MLIQ') else 'no'}")
    n20 = flags.count(0x20)
    n21 = flags.count(0x21)
    n24 = flags.count(0x24)
    n28 = flags.count(0x28)
    n08 = flags.count(0x08)
    n60 = flags.count(0x60)
    if n24 > n20:
        print("  warning: many MOPY 0x24 (incomplete Collision vertex group). "
              "Select indoor groups → WBS Quick collision before export.", file=sys.stderr)
    elif n28 == 0 and n60 == 0 and n20 and (n20 + n21 + n08 + n24) >= int(len(flags) * 0.9):
        print("  note: WBS Quick collision emits 0x20 on visible faces, not 0x28. "
              "Walk in-game before packing. Python hulls use 0x28.", file=sys.stderr)
    elif n28 == 0 and n08 == 0 and n20 == 0:
        print("  warning: no MOPY 0x20/0x28/0x08. Client may fall through.", file=sys.stderr)
    return 0


if __name__ == "__main__":
    sys.exit(main())
