#!/usr/bin/env python3
"""Extract a WMO family (root + _NNN groups) from a 3.3.5 MPQ for WBS import.

Textures resolve from the WBS client path; this dumps native WMO bytes only.
See .agents/skills/build-dungeon/reference-blender-wmo.md.
"""
from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

from mpyq import MPQArchive

_GROUP = re.compile(r"_\d{3}\.wmo$", re.IGNORECASE)


def norm(p: str) -> str:
    return p.replace("\\", "/").lower()


def family_paths(files: list[bytes | str], prefix: str) -> list[str]:
    want = norm(prefix)
    if want.endswith(".wmo"):
        want = want[:-4]
    out: list[str] = []
    for raw in files:
        name = raw.decode("ascii", errors="replace") if isinstance(raw, bytes) else raw
        n = norm(name)
        if n == want + ".wmo" or (n.startswith(want + "_") and _GROUP.search(n)):
            out.append(name)
    out.sort(key=lambda s: (0 if not _GROUP.search(norm(s)) else 1, norm(s)))
    return out


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--mpq", required=True, type=Path, help="common-2.MPQ (or expansion/lichking)")
    ap.add_argument(
        "--prefix",
        required=True,
        help="World/wmo/Dungeon/AZ_Deadmines/AZ_Deadmines_A  (with or without .wmo)",
    )
    ap.add_argument("--out", required=True, type=Path, help="directory to write the family into")
    args = ap.parse_args()

    arc = MPQArchive(str(args.mpq))
    names = family_paths(list(arc.files), args.prefix)
    if not names:
        print(f"no WMO family matching {args.prefix!r} in {args.mpq}", file=sys.stderr)
        return 1

    args.out.mkdir(parents=True, exist_ok=True)
    for name in names:
        key = name if isinstance(name, bytes) else name.encode("ascii")
        data = arc.read_file(key)
        if not data:
            print(f"read failed: {name}", file=sys.stderr)
            return 1
        dest = args.out / Path(name.replace("\\", "/")).name
        dest.write_bytes(data)
        print(f"wrote {dest} ({len(data)} bytes) from {name}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
