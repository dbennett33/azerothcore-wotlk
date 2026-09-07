#!/usr/bin/env python3
"""Write a Ragefire-style WMO-only WDT from an exported WotLK (v17) root WMO.

WBS exports the WMO family; this fork still writes the WDT. MODF at origin,
uniqueId 0xFFFFFFFF, AABB padded on all three axes (extractor fixCoords maps
WDT Z → vmap X). See .agents/skills/build-dungeon/reference-blender-wmo.md.
"""
from __future__ import annotations

import argparse
import struct
import sys
from pathlib import Path


def _pad4(n: int) -> int:
    return (4 - (n % 4)) % 4


def chunk(tag: str, data: bytes) -> bytes:
    """WDT chunk. FourCC is byte-reversed (`REVM` on disk) like Blizzard and
    `gen-drowned-belfry-mesh.py`. Size includes 4-byte padding; extractors seek
    `size` bytes and do not align, so a pad-only trailer would skip the next chunk.
    """
    payload = data + b"\x00" * _pad4(len(data))
    return tag[::-1].encode("ascii") + struct.pack("<I", len(payload)) + payload


def fourcc(raw: bytes) -> str:
    """WBS roots store fourCCs little-endian (`DHOM`); accept ASCII too."""
    a = raw.decode("ascii", errors="replace")
    b = raw[::-1].decode("ascii", errors="replace")
    known = {"MVER", "MOHD", "MOTX", "MOMT", "MOGN", "MOGI", "MWMO", "MODF", "MPHD", "MAIN"}
    if a in known:
        return a
    if b in known:
        return b
    return a


def iter_chunks(blob: bytes):
    off = 0
    n = len(blob)
    while off + 8 <= n:
        tag = fourcc(blob[off:off + 4])
        size = struct.unpack_from("<I", blob, off + 4)[0]
        start = off + 8
        end = start + size
        if end > n:
            raise ValueError(f"truncated chunk {tag} at {off}")
        yield tag, blob[start:end]
        off = end


def mohd_bbox(root: bytes) -> tuple[float, float, float, float, float, float]:
    for tag, payload in iter_chunks(root):
        if tag != "MOHD":
            continue
        if len(payload) < 64:
            raise ValueError(f"MOHD is {len(payload)} bytes, need 64")
        return struct.unpack_from("<6f", payload, 36)
    raise ValueError("no MOHD chunk in root WMO")


def write_wdt(out: Path, wmo_path: str, bounds: tuple[float, ...]) -> None:
    mver = chunk("MVER", struct.pack("<I", 18))
    mphd = chunk("MPHD", struct.pack("<8I", 1, 0, 0, 0, 0, 0, 0, 0))
    main = chunk("MAIN", b"\x00" * (64 * 64 * 8))
    mwmo = chunk("MWMO", wmo_path.encode("ascii") + b"\x00")
    modf = struct.pack(
        "<II 3f 3f 6f HHHH",
        0, 0xFFFFFFFF,
        0.0, 0.0, 0.0,
        0.0, 0.0, 0.0,
        *bounds,
        0, 0, 0, 0,
    )
    if len(modf) != 64:
        raise SystemExit(f"MODF is {len(modf)} bytes, need 64")
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_bytes(mver + mphd + main + mwmo + chunk("MODF", modf))


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--root-wmo", required=True, type=Path, help="exported Name.wmo (root)")
    ap.add_argument(
        "--wmo-path",
        required=True,
        help=r"MWMO string, e.g. World\wmo\Dungeon\DrownedBelfry\DrownedBelfry.wmo",
    )
    ap.add_argument("--out", required=True, type=Path, help="Directory.wdt")
    ap.add_argument("--pad", type=float, default=200.0, help="AABB pad on all axes (default 200)")
    args = ap.parse_args()

    root = args.root_wmo.read_bytes()
    bb = mohd_bbox(root)
    pad = args.pad
    bounds = (bb[0] - pad, bb[1] - pad, bb[2] - pad, bb[3] + pad, bb[4] + pad, bb[5] + pad)
    write_wdt(args.out, args.wmo_path, bounds)
    print(f"wrote {args.out} mwmo={args.wmo_path} bbox={bb} pad={pad}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
