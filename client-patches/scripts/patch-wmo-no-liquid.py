#!/usr/bin/env python3
"""Dry a WotLK WMO: no DBC lava, no MLIQ fill, no red underwater fog.

WBS WotLK export always sets MOHD UseLiquidTypeDBCId (0x4). Its enum value
\"15\" is Green Lava, not AzerothCore's legacy MAG-none. Combined with MD_Crypt
MFOG color2=(255,0,0) that fills indoor groups orange and puts the player in
the swim anim. See reference-blender-wmo.md.

Usage:
  python3 client-patches/scripts/patch-wmo-no-liquid.py \\
    --root /path/to/DrownedBelfry.wmo
"""
from __future__ import annotations

import argparse
import struct
import sys
from pathlib import Path

# Legacy MAG none (UseLiquidTypeDBCId off). Matches gen-drowned-belfry-mesh.py.
MAG_NONE = 15
MOHD_UNIFIED_RENDER = 0x2
MOHD_USE_DBC_LIQUID = 0x4
MOGP_HAS_WATER = 0x1000


def find_chunk(blob: bytes, name: str) -> tuple[int, int] | None:
    rev = name[::-1].encode("ascii")
    idx = blob.find(rev)
    if idx < 0:
        idx = blob.find(name.encode("ascii"))
    if idx < 0:
        return None
    size = struct.unpack_from("<I", blob, idx + 4)[0]
    return idx, size


def patch_root(path: Path) -> None:
    blob = bytearray(path.read_bytes())
    mohd = find_chunk(blob, "MOHD")
    if mohd is None:
        raise SystemExit(f"no MOHD in {path}")
    flags_off = mohd[0] + 8 + 60
    flags = struct.unpack_from("<H", blob, flags_off)[0]
    flags = (flags & ~MOHD_USE_DBC_LIQUID) | MOHD_UNIFIED_RENDER
    struct.pack_into("<H", blob, flags_off, flags)

    mfog = find_chunk(blob, "MFOG")
    if mfog is not None:
        start = mfog[0] + 8
        n = mfog[1] // 48
        # Far grey fog, underwater start negative so it never engages.
        dry = struct.pack(
            "<I3f2f ffI ffI",
            0,
            0.0, 0.0, 0.0,
            0.0, 0.0,
            444.4445, 0.25, 0xFF708090,
            222.2222, -0.5, 0xFF102030,
        )
        assert len(dry) == 48
        for i in range(n):
            blob[start + i * 48:start + (i + 1) * 48] = dry

    path.write_bytes(blob)
    print(f"patched root {path} mohd_flags=0x{flags:x} mfog={n if mfog else 0}",
          file=sys.stderr)


def patch_group(path: Path) -> None:
    blob = bytearray(path.read_bytes())
    mogp = find_chunk(blob, "MOGP")
    if mogp is None:
        raise SystemExit(f"no MOGP in {path}")
    flags_off = mogp[0] + 8 + 8
    flags = struct.unpack_from("<I", blob, flags_off)[0]
    flags &= ~MOGP_HAS_WATER
    struct.pack_into("<I", blob, flags_off, flags)
    liquid_off = mogp[0] + 8 + 52
    struct.pack_into("<I", blob, liquid_off, MAG_NONE)
    mliq = find_chunk(blob, "MLIQ")
    if mliq is not None:
        # Drop the chunk; following chunks shift. Size field includes payload only.
        start = mliq[0]
        end = mliq[0] + 8 + mliq[1]
        del blob[start:end]
        print(f"stripped MLIQ {mliq[1]} bytes from {path.name}", file=sys.stderr)
    path.write_bytes(blob)
    print(f"patched group {path.name} flags=0x{flags:x} liquid={MAG_NONE}",
          file=sys.stderr)


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--root", type=Path, required=True, help="Name.wmo (root)")
    args = ap.parse_args()
    root = args.root.resolve()
    if not root.is_file():
        print(f"missing {root}", file=sys.stderr)
        return 1
    patch_root(root)
    for group in sorted(root.parent.glob(f"{root.stem}_*.wmo")):
        patch_group(group)
    return 0


if __name__ == "__main__":
    sys.exit(main())
