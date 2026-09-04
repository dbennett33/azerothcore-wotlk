# Server data staging (local dev machine only)

Overlay directories used when building a release:

```
dbc/     Spell.dbc, Talent.dbc, Map.dbc, ...
maps/    Map tiles from map_extractor
vmaps/   From vmap4_extractor + vmap4_assembler
mmaps/   From mmaps_generator (optional but recommended)
```

**These files are gitignored.** Populate with `client-patches/scripts/extract-server-data.sh`, then build and publish to the VPS.

See `docs/client-patches.md`.
