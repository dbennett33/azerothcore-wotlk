# Client MPQ staging (local dev machine only)

Place finished MPQ archives here while building a release:

```
mpq/patch-A.MPQ
mpq/patch-B.MPQ
```

**These files are gitignored.** After `build-bundle.sh`, publish to the VPS with `publish-to-vps.sh` — that is where binaries are stored long-term.

Use letters after Blizzard's `patch-4.MPQ`. Pack loose files from `loose/` with an MPQ editor.

See `docs/client-patches.md`.
