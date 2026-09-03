# The Waxworks

5-man instance on **map 44** (`Monastery.wdt` → original `Waxworks.wmo`). Walk south of Goldshire through the pink veil, or talk to Sergeant Wickham.

Client needs `Data\patch-4.MPQ` (restart Wow after packing). Server needs extracted `maps/044*`, `vmaps/044*`, `mmaps/044*` in the client-data volume.

## Enable

1. Rebuild worldserver with modules enabled (`MODULES=static`).
2. Restart worldserver so `data/sql/db-world/*.sql` applies (MODULE state).
3. `.go xyz -9432 62 56.8 0` — walk through the pink veil.

GM smoke test (do this before a normal character): `.go xyz 12 0 0.15 44`

If that crashes, loads Scarlet cathedral, or snaps you to the plaza, stop — tiles or patch are wrong.

## Layout

| Room | Content |
|---|---|
| Mouth | Wickham, enter/leave, quests, first red-candle shrine |
| Wickworks | Kobold trash, tallow vat, dripping wax, candle cart, optional Gug |
| North gallery | Unused wing — acolytes kneeling at a great red candle |
| West tunnel | Second unused wing, another prayer circle |
| King Wick | Don't stand in fire, don't greed the candles, interrupt |
| Commissary | Riverpaw kitchen + Snarlroast |
| Flooded alcove | Skippable murloc consultants |
| Bargaining Table | Defias trash + Voss (read the gossip) |
| Pumpkin Sty | Optional Princess + Unit 07 |

## Notes

- This is a real 5-man (`dungeon_access_template` id 122, min level 7). GMs can still enter.
- Do not spawn or stand on Goldtooth (`-9745.84, 87.57, 12.77`). Vanilla quests 62 / 60 / 87 / 47 / 88 / 132 / 176 are untouched.
- Cart: do not AoE it. Hitting it pops a small nova and enrages nearby kobolds.
- Voss: Yes = −20% HP, no extra guards. No / timeout = enrage + bodyguards. Never uses spell 5200.
