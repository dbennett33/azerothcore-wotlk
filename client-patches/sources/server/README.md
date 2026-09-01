# Server data sources

Overlay directories merged into the realm `data/` folder on deploy:

```
dbc/     Spell.dbc, Talent.dbc, Map.dbc, ...
maps/    Map tiles from map_extractor
vmaps/   From vmap4_extractor + vmap4_assembler
mmaps/   From mmaps_generator (optional but recommended)
```

Populate with `client-patches/scripts/extract-server-data.sh` or copy from extractor output.

See `docs/client-patches.md`.
