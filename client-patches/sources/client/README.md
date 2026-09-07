# Client MPQ staging (local dev machine only)

Place finished MPQ archives here while building a release:

```
mpq/patch-4.MPQ            # all custom world files (Data/patch-4.MPQ)
mpq/patch-enUS-4.MPQ       # DBC edits only (Data/enUS/patch-enUS-4.MPQ)
```

**These files are gitignored.** After `build-bundle.sh`, publish to the VPS with `publish-to-vps.sh` — that is where binaries are stored long-term.

One `patch-4.MPQ` holds every custom world file for this realm. Do not introduce `patch-5+` or lettered `patch-A.MPQ`: `map_extractor` stops at `patch-5` and lettered archives are invisible to it. Pack loose files from `loose/` as MPQ v2.

See `docs/client-patches.md` and `.agents/docs/systems/client-data.md`.
