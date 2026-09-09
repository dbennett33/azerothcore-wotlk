# Ship and verify a custom NPC

Back to [`README.md`](README.md). The general MPQ/bundle/deploy procedure is
[`../../.agents/skills/build-client-patch/SKILL.md`](../../.agents/skills/build-client-patch/SKILL.md)
and [`../client-patches.md`](../client-patches.md); this file is the NPC-specific delta.

## What goes where

| Artefact | Loose staging (`client-patches/sources/client/loose/`) | Archive | Server |
|---|---|---|---|
| `Creature\<Dir>\*.m2`, `*.skin`, `*.blp` | `Creature/<Dir>/…` | `Data/patch-4.MPQ` | none |
| `Textures\BakedNpcTextures\*.blp` | `Textures/BakedNpcTextures/…` | `patch-4` | none |
| `Sound\Creature\<Name>\*.wav` | `Sound/Creature/<Name>/…` | `patch-4` | none |
| `CreatureDisplayInfo.dbc`, `CreatureModelData.dbc`, `CreatureDisplayInfoExtra.dbc`, `SoundEntries.dbc`, `CreatureSoundData.dbc`, `NPCSounds.dbc` | `DBFilesClient/…` | `Data/enUS/patch-enUS-4.MPQ` | same rows as `*_dbc` overlay SQL (CDI, CMD, CDIExtra, SoundEntries); CSD/NPCSounds server-side not needed |
| `creature_template*`, `creature_model_info`, `creature_equip_template`, `creature_addon`, `creature_text`, `smart_scripts`, `creature` spawns | — | — | `data/sql/updates/pending_db_world/rev_*.sql` (`./create_sql.sh`) |
| Boss C++ | — | — | `src/server/scripts/EasternKingdoms/<Dungeon>/`, loader line, `vps-build` |
| `client-patches/manifest.json` | — | — | committed with the SQL/C++ |

No `maps/vmaps/mmaps` change for an NPC. The bundle's `server/` component only needs a `dbc/` dir
if you chose to ship files instead of overlay rows; overlays are the default here (small, reviewed
in the SQL diff, no `data/dbc` redistribution).

## Packing on Windows (MPQEditor console)

The existing pack script (`client-patches/_pack-p4.txt`) adds `World\` and `DUNGEONS\` only. NPC
assets need their roots added — one `add` line per top-level folder, always rebuilding the **whole**
archive so Waxworks/Belfry files stay in:

```
new "C:\dev\azerothcore-wotlk\client-patches\sources\client\mpq\patch-4.MPQ" 0x1000
add "…\patch-4.MPQ" "…\loose\World\*" "World\" /c /r
add "…\patch-4.MPQ" "…\loose\DUNGEONS\*" "DUNGEONS\" /c /r
add "…\patch-4.MPQ" "…\loose\Creature\*" "Creature\" /c /r
add "…\patch-4.MPQ" "…\loose\Textures\*" "Textures\" /c /r
add "…\patch-4.MPQ" "…\loose\Sound\*" "Sound\" /c /r
flush "…\patch-4.MPQ"
close
exit
```

Save as ASCII (no BOM), run `MPQEditor.exe /console pack.txt`, then list the archive and confirm
`Creature\<Dir>\<Name>.m2` sits at the root (not `loose\Creature\…`). Locale archive: same shape
with `DBFilesClient\*` → `patch-enUS-4.MPQ`. Compatibility "WoW: WotLK" = MPQ v2. On Linux the
`pack-mpq` loop in `reference-windows-linux.md` iterates `$LOOSE/World` — extend the `find` to the
same five roots.

## Dev-client loop (before any bundle)

1. Close `Wow.exe`. Copy `patch-4.MPQ` to `<client>\Data\`, `patch-enUS-4.MPQ` to `<client>\Data\enUS\`.
2. Apply the SQL to the local/test world DB (or let the test realm's worldserver apply it on
   restart). Restart worldserver; read the load log (below).
3. Start the client, log in as GM: `.morph 60010` (see yourself as the new display), `.npc add 9000610`,
   walk around it, `.npc info`, pull it, `.damage` it through the thresholds, kill it.
4. Iterate textures/sounds with loose files under `<client>\Data\…`; when done, delete them and
   re-test with the archive only.

## Server-side load log: what "good" looks like

After the SQL is applied, `grep` the worldserver startup log for the entry and the display id. No
line is the pass. Failures you will see otherwise:

| Log line | Cause |
|---|---|
| `Creature (Entry: N) lists non-existing CreatureDisplayID id (X), this can crash the client.` | CDI overlay row missing / id typo |
| `No model data exist for CreatureDisplayID = X listed by creature (Entry: N).` | `creature_model_info` row missing |
| `Table creature_model_info has model for not existed display id (X).` | model_info before the overlay, or typo |
| `CreatureTextMgr: Entry N, Group G in table creature_texts has Sound X but sound does not exist.` | `soundentries_dbc` row missing |
| `CreatureTextMgr: … has Emote X but emote does not exist.` | wrong emote id |
| `SmartScript::ProcessAction: SMART_ACTION_TALK: … non-existent Text id G` (runtime) | group not in `creature_text` |
| `Size of 'X.dbc' set by format string … does not match` | the overlay table columns do not match `DBCfmt.h` — never edit the format, fix the row |
| worldserver assert in `Unit::GetCollisionHeight` | CDI `ModelID` has no `creaturemodeldata_dbc` row |

## Client-side checks

- Creature enters view without a crash (missing CDI on the client crashes immediately).
- Correct texture, no white/black/magenta; correct size; selection circle at the feet.
- Animations: idle, walk toward you, attack, wound flinch, death. T-pose = missing sequence.
- Sounds: aggro grunt on pull (CreatureSoundData), voice line with the text (creature_text.Sound),
  greeting on gossip (NPCSounds). Silent with no server error = client-side DBC or file path.
- `Cache\WDB\enUS\creaturecache.wdb` — delete it if you changed name/subname/display of an
  entry the client already saw and are not bumping `client_cache_version` in the dev loop.

## Release

1. `client-patches/scripts/build-bundle.ps1 <version> -Changelog '…'` (patch bump for texture/sound
   fixes, minor for a new creature set). `client_cache_version` +1 only if existing template rows
   changed.
2. `publish-to-vps.ps1` **before** pushing.
3. Commit `manifest.json` + the `pending_db_world` SQL (+ C++) together; push `dev` → test realm
   builds, deploys, applies SQL. Live only via `dev → PR → Playerbot` and a manual `deploy-vps`.
4. Players: `update-client.ps1 -Target test|live`, Wow closed. A client without the patch must
   crash/blank on the new creature — that is the proof the release depends on the MPQ, and the
   reason the SQL must never reach a realm before its bundle is published.
5. Add the NPC's DBC ids to the registry table in `README.md` and its world-DB ids to the block in
   `.agents/docs/systems/dungeons.md`.

## Rollback

Revert the commit (manifest + SQL). Remove the spawn rows or set the creature back to a Blizzard
display id so clients without the new archive stop crashing; the DBC rows can stay (unused ids are
harmless on both sides). Files added by the newer archive stay on players' disks until the next
`update-client`.
