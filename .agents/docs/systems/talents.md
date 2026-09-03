# Talents

Read this before touching talent trees, talent points, or talent spells. Procedure:
`.agents/skills/edit-talents/SKILL.md`. Data contract: `systems/client-data.md`.

## Where a talent lives

| Piece | Client | Server |
|---|---|---|
| Tree layout (tab, tier, column, ranks, prerequisites) | `Talent.dbc` | `data/dbc/Talent.dbc` **or** `talent_dbc` overlay (`ID, TabID, TierID, ColumnIndex, SpellRank_1..9, PrereqTalent_1..3, PrereqRank_1..3, Flags, RequiredSpellID, CategoryMask_1..2`) |
| Tabs (class mask, page 0–2, background art name) | `TalentTab.dbc` | `talenttab_dbc` overlay / `data/dbc` |
| What a rank does | `Spell.dbc` (tooltip, icon via `SpellIcon.dbc`) | `Spell.dbc` / `spell_dbc` overlay → `SpellInfo`; C++ `SpellScript`/`AuraScript` + `spell_script_names` when effects need code |
| Points a character has | derived | `Player::CalculateTalentsPoints()`: `level − 9` at level ≥ 10, × `Rate.Talent`, + `OnPlayerCalculateTalentsPoints` hook; DK starting-zone special case |
| What a character learned | derived from server | `acore_characters.character_talent (guid, spell, specMask)` — stores the **rank spell id**, not the talent id |

The client draws the tree and sends `CMSG_LEARN_TALENT(talentId, rank)`. The server re-validates
against **its** copy (`Player::LearnTalent`): class mask of the tab, free points, `DependsOn`/
`DependsOnRank`, and the tier gate `spentPointsInTab >= Row * 5`. If client and server DBCs differ,
the click silently does nothing. Inspect and talent hyperlinks encode bit positions computed from the
server's `TalentTab`/`Talent` tables (`sTalentTabPages`); a mismatch garbles other players' specs.

## Hard limits (core constants, not data)

- `MAX_TALENT_RANK = 5` ranks per talent; `MAX_TALENT_TABS = 3` tabs per class; `tabpage` 0–2.
  A fourth tab or a sixth rank needs C++ changes across `Player`, `DBCStores`, packets and the
  client UI (not feasible for 3.3.5a).
- Tiers: the 3.3.5a talent frame draws rows 0–10 and columns 0–3. Tier gate is 5 points per row.
- Pet talents: `petTalentMask` tabs, `MAX_PET_TALENT_RANK = 3`, `Rate.Talent.Pet`.
- Dual spec: `specMask` bits 1 and 2; `MinDualSpecLevel` in conf.

## Rules

- Ship the **same** `Talent.dbc` / `TalentTab.dbc` / `Spell.dbc` bytes to both sides. Server-side
  `*_dbc` overlays are fine for the server copy, but the client still needs the DBC in
  `Data/enUS/patch-enUS-4.MPQ` (locale archive; see client-data.md).
- Changing only numbers inside an existing rank spell (e.g. +2% → +5%) is a `Spell.dbc` edit on
  both sides; no `Talent.dbc` change, no reset needed.
- Moving/removing talents: characters keep unknown spells until `_LoadTalents` drops entries whose
  spell is no longer a talent rank. Force a clean state with `UPDATE characters SET at_login =
  at_login | 4` (`AT_LOGIN_RESET_TALENTS`) in the deploy SQL, or `.reset talents` per character.
- New rank spells need ids outside Blizzard's range (this fork: `9000000+` items/creatures; pick a
  spell block such as `9000000–9000999` and record it in `systems/dungeons.md`'s registry table if
  you add one). `spell_dbc` rows must match the `Spell.dbc` format (`SpellEntryfmt` in
  `src/server/shared/DataStores/DBCfmt.h`; the base `spell_dbc.sql` table is the column reference).
- A talent that grants an active ability: `addToSpellBook`/`Flags = 1` and the ability must exist in
  the spellbook chain (`spell_ranks` if ranked).
- Do not change talent point totals via SQL; use `Rate.Talent` or a `PlayerScript` on
  `OnPlayerCalculateTalentsPoints` (module-friendly, no client patch).
- Bump nothing in `ClientCacheVersion` for talent work; it caches query results, not DBCs. Players
  need the new MPQ.

## Verification

1. `worldserver` log: no `Talent.dbc … field count` error, `>> Loaded N DBC data stores`.
2. In game: `.reset talents`, open the tree, spend to the last tier, relog — points persist.
3. `.debug` / inspect another player of the class: tree renders, no shifted icons.
4. Second machine without the MPQ reproduces the desync (proves the client side is required).
