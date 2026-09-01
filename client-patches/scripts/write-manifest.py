#!/usr/bin/env python3
"""Write a client-patches bundle manifest."""
from __future__ import annotations

import argparse
import json
from datetime import datetime, timezone
from pathlib import Path


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("output")
    parser.add_argument("--version", required=True)
    parser.add_argument("--locale", default="enUS")
    parser.add_argument("--cache-version", type=int, required=True)
    parser.add_argument("--changelog", action="append", default=[])
    parser.add_argument("--patch-json", default="[]")
    parser.add_argument("--server-archive", default="server-data.tar.gz")
    parser.add_argument("--server-sha256", default="")
    parser.add_argument("--server-size", type=int, default=0)
    parser.add_argument("--server-components", default="[]")
    args = parser.parse_args()

    changelog = args.changelog or [f"Release {args.version}"]
    manifest = {
        "version": args.version,
        "released": datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z"),
        "blizzard_build": 12340,
        "client_cache_version": args.cache_version,
        "changelog": changelog,
        "client": {
            "locale": args.locale,
            "patches": json.loads(args.patch_json),
        },
        "server": {
            "archive": args.server_archive,
            "sha256": args.server_sha256,
            "size": args.server_size,
            "components": json.loads(args.server_components),
        },
    }

    output = Path(args.output)
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    print(output)


if __name__ == "__main__":
    main()
