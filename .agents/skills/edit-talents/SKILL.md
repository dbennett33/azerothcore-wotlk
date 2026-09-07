---
name: edit-talents
description: >-
  Change WoW 3.3.5a talent trees on AzerothCore: move, add, remove or retune
  talents, change rank spells, talent points or tab layout. Use when editing
  Talent.dbc, TalentTab.dbc, Spell.dbc for talents, talent_dbc / talenttab_dbc /
  spell_dbc SQL, Rate.Talent, or when players report talents that will not
  learn, wrong tooltips, or inspect showing garbage.
---

# Edit talents (AzerothCore 3.3.5a, this fork)

Read `.agents/docs/systems/talents.md` (model and hard limits) and
`.agents/docs/systems/client-data.md` (why the client needs the same DBC) before starting.
Delivery uses `.agents/skills/build-client-patch/SKILL.md`; Windows/Linux tool commands in its
`reference-windows-linux.md`. SQL rules: `.agents/docs/sql-guidelines.md`.

## Decide the smallest change

| Goal | Touch | Client patch? | Character reset? |
|---|---|---|---|
| More/fewer talent points overall | `Rate.Talent` (conf) or `OnPlayerCalculateTalentsPoints` in a `PlayerScript` | No | No |
| Tune a talent's numbers (percent, duration) | `Spell.dbc` rows of each rank (both sides) | Yes | No |
| Change prerequisites / tier / column | `Talent.dbc` (both sides) | Yes | Recommended |
| Replace a talent's spells | `Talent.dbc` + new `Spell.dbc` rows (both sides) | Yes | **Required** |
| Add a talent to a free cell | `Talent.dbc` + spells | Yes | No |
| New tab / >3 tabs / >5 ranks | not possible without core + client changes | — | — |

Prefer the first row whenever it satisfies the request; it ships as a normal server deploy.

## Workflow

```
Task progress:
- [ ] Target rows identified (talent id, tab id, rank spell ids) from the extracted DBCs
- [ ] Edited Talent.dbc / TalentTab.dbc / Spell.dbc saved (WDBX or equivalent)
- [ ] Server copy: same DBCs in sources/server/dbc/ OR matching *_dbc SQL rows (one source per file)
- [ ] Client copy: DBFilesClient/*.dbc packed into Data/enUS/patch-enUS-4.MPQ
- [ ] Reset SQL for affected classes (at_login |= 4) if talents moved or spells changed
- [ ] Bundle built, published, manifest committed with the SQL; pushed to dev
- [ ] Verified on Test with a patched client and an unpatched one
```

### 1. Find the rows

Extracted server `dbc/` (`/home/acore/server/data/dbc/` or your local `map_extractor -e 2` output)
is the reference copy. Look up:

- `TalentTab.dbc`: the class's three tabs (`ClassMask` bit = `1 << (class − 1)`, `tabpage` 0–2).
- `Talent.dbc`: rows with that `TabID`; `TierID` 0–10, `ColumnIndex` 0–3, `SpellRank_1..5`,
  `PrereqTalent_1`/`PrereqRank_1`, `Flags` (1 = shows in spellbook).
- `Spell.dbc`: each rank spell (name, effects, `EffectBasePoints`, aura types).

Never change a Blizzard spell's *id*; change its fields or point the talent rank at a new id.

### 2. Edit

Windows: WDBX Editor opens `.dbc` with the 3.3.5 definitions, exports back to `.dbc` (and can
export SQL). Linux: WDBX under Wine/Mono, or edit via SQL — but the **client file** still has to be
produced; a Python DBC writer following `DBCfmt.h` is acceptable if it round-trips the original
byte-for-byte before your edit.

New spell ids: pick from a block you record in `systems/dungeons.md`'s registry (e.g. talents
`9001000–9001999`). Copy the nearest vanilla rank and change what differs. Spell effects that need
code get a `SpellScript`/`AuraScript` plus `spell_script_names` (see `cpp-scripts.md`).

### 3. Server copy

Option A (small edits): `pending_db_world` rows in `talent_dbc` / `talenttab_dbc` / `spell_dbc`
mirroring the edited rows (DELETE by `ID` then INSERT; column list from the base `*_dbc.sql`). The
overlay replaces same-id rows and adds new ones. Option B (many rows): drop the edited `.dbc` into
`client-patches/sources/server/dbc/` so `deploy-vps` overlays `data/dbc/`. Pick one per file.

For moved/removed talents add to the same SQL file:

```sql
-- characters DB: force a talent reset for affected classes on next login
UPDATE `characters` SET `at_login` = `at_login` | 4 WHERE `class` IN (<class ids>);
```

(`pending_db_characters` file; class ids per `ChrClasses.dbc`).

### 4. Client copy

Stage `DBFilesClient/Talent.dbc` (+ `TalentTab.dbc`, `Spell.dbc` when touched) under
`client-patches/sources/client/loose/` and pack `patch-enUS-4.MPQ` (locale archive; `Data/patch-4`
is never read for DBCs by the extractors and is the wrong place by convention). Add it to the bundle
with `install_path: Data/enUS/patch-enUS-4.MPQ`. `client_cache_version` stays as is unless item or
creature templates also changed.

### 5. Ship and verify

Follow build-client-patch §5–§7. Then, on Test:

1. worldserver log has no `Talent.dbc`/`Spell.dbc` format-size error.
2. Patched client, affected class: `.reset talents`, spend down the tree, prerequisites enforce,
   last tier reachable, relog keeps points, and `/inspect` from a second client shows the same
   picks (inspect uses the server's bit layout).
3. Unpatched client: the changed talent is greyed/refused (proves the server side is authoritative).
4. Grep `character_talent` for removed rank spell ids after a few logins — they should be gone.

## Pitfalls

- Editing only the server: the client still shows the old tree; clicks do nothing.
- Editing only the client: the server refuses `LearnTalent`; players see points refunded on relog.
- `Talent.dbc` row where `SpellRank_1` is 0 → talent unlearnable; where ranks skip → client shows N
  ranks but server counts by first zero.
- Prereq loops or a prerequisite in a higher tier soft-lock the tree.
- Changing `tabpage` order without changing `TalentTabID` shifts the inspect bit layout for
  everyone; reset talents for the class.
- `Rate.Talent` applies to every class and to pets via `Rate.Talent.Pet`; use the hook for per-class
  logic.
