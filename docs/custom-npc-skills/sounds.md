# Sounds: voice lines, grunts, and what the server has to know

Back to [`README.md`](README.md). Triggering a line from a scenario:
[`phrases-and-triggers.md`](phrases-and-triggers.md).

Two different systems play creature audio, and a new NPC usually wants both:

| System | Who decides when | Data | Example |
|---|---|---|---|
| **Server-sent sound** (`SMSG_PLAY_SOUND` / `SMSG_PLAY_OBJECT_SOUND`) | worldserver: `creature_text.Sound`, SmartAI `SMART_ACTION_SOUND`, C++ `PlayDirectSound` | `SoundEntries.dbc` row (client) + `soundentries_dbc` overlay (server validates the id) | "Boss at 20%: *The wax remembers!*" with a voice file |
| **Client-automatic creature sounds** | client, from the model's state | `CreatureDisplayInfo.SoundID` → `CreatureSoundData.dbc` → `SoundEntries.dbc`; `NPCSoundID` → `NPCSounds.dbc` | aggro roar, wound grunt, death cry, footsteps, gossip "hello/goodbye" |

The server never loads `CreatureSoundData.dbc` or `NPCSounds.dbc`; it loads `SoundEntries.dbc` only
to check ids (`CreatureTextMgr::LoadCreatureTexts`, `DBCStructure.h` keeps just `Id`).

## Audio files

- Formats the 3.3.5 client plays: **WAV** (PCM 16-bit; Blizzard voice lines are mono 22.05 kHz or
  44.1 kHz) and **MP3** (used for music and long lines). No OGG in 3.3.5.
- Path convention: `Sound\Creature\<CreatureName>\<CreatureName>_<Kind><NN>.wav`, e.g.
  `Sound\Creature\TallowWarden\TallowWarden_Aggro01.wav`. The DBC stores `DirectoryBase`
  (`Sound\Creature\TallowWarden\`) and up to ten `File_N` names; the client picks one at random,
  weighted by `Freq_N`.
- Loudness: normalise voice lines to about −3 dBFS peak, −16 to −20 LUFS; Blizzard NPC lines are
  loud and dry (no reverb baked in — the client adds EAX per zone).
- One line ≈ 1–4 s, 20–80 KB as 22 kHz mono WAV. A boss with 12 lines is under 1 MB.

Iteration trick (verified community knowledge, `fondlez/wow-sounds`): the client looks for a loose
file at `<client>\Data\Sound\...` **before** searching the MPQs. Drop the WAV there while tuning
volume and timing; test with `/script PlaySoundFile("Sound\\Creature\\TallowWarden\\TallowWarden_Aggro01.wav")`.
Delete the loose file before you ship, or your client will pass while players hear nothing.

## `SoundEntries.dbc` row

| Column | Value for a custom voice line |
|---|---|
| `ID` | from the fork block `90000–90999` (README registry) |
| `SoundType` | `10` NPC Combat (voice lines) · `17` NPC Sounds (gossip hello/goodbye) · `16` death thud · `13`/`50` ambience |
| `Name` | internal label, e.g. `TallowWarden Aggro` |
| `File_1..10` | file names only, no path; unused slots empty string |
| `Freq_1..10` | relative weights, `1` each is fine |
| `DirectoryBase` | `Sound\Creature\TallowWarden\` (trailing backslash like Blizzard rows) |
| `Volumefloat` | `1.0` (Blizzard voice lines 0.8–1.0) |
| `Flags` | copy from a donor voice row (e.g. VanCleef aggro); `0` also works |
| `MinDistance` / `DistanceCutoff` | `8` / `45` for a room-scale voice; `15` / `100` for a boss yell |
| `EAXDef`, `SoundEntriesAdvancedID` | `0` |

Put the same row into `data/sql/updates/pending_db_world/…sql` as a `soundentries_dbc` INSERT
(column list in [`model-chain.md`](model-chain.md)). One row per *phrase*, not per file: the ten file
slots are the variants of that phrase (three different "aggro" takes), so `creature_text` needs one
`Sound` id per group.

## Attaching sounds to phrases

`creature_text.Sound = <SoundEntries id>` plays the sound to the same audience as the text (chat
range, or `TextRange`). `CreatureTextMgr::SendChat` sends `SMSG_PLAY_SOUND` right after the chat
packet. This is the path for "boss at 20% says X (with voice)". Text without a voice file: leave
`Sound = 0`; the client still plays the model's talk animation via `Emote`.

Without text, SmartAI `SMART_ACTION_SOUND` (4: soundId, onlySelf, distance) and
`SMART_ACTION_RANDOM_SOUND` (115: up to four ids), `SMART_ACTION_MUSIC` (216) do the same. C++:
`me->PlayDirectSound(id)` (everyone in visibility range or one player), `PlayDistanceSound(id)`
(3D positioned, attenuated), `PlayRadiusSound(id, radius)`, `GetMap()->PlayDirectSoundToMap(id)`.

## Automatic grunts: `CreatureSoundData.dbc` and `NPCSounds.dbc`

A re-skinned kobold still grunts like a kobold because the donor's `SoundID` is on the display row.
To give a new creature its own set, add a `CreatureSoundData` row (client-only DBC, into
`patch-enUS-4`) and put its id in `CreatureDisplayInfo.SoundID`:

| Field | Plays when |
|---|---|
| `SoundExertionID`, `SoundExertionCriticalID` | melee swing / crit |
| `SoundInjuryID`, `SoundInjuryCriticalID`, `SoundInjuryCrushingBlowID` | takes a hit |
| `SoundDeathID` | dies |
| `SoundStunID`, `SoundStandID` | stunned / idle fidget |
| `SoundFootstepID` → `FootstepTerrainLookup.dbc` | footsteps per terrain (copy donor) |
| `SoundAggroID` | enters combat (client plays it on aggro animation) |
| `SoundAlertID`, `SoundFidget_0..4`, `FidgetDelaySecondsMin/Max` | idle barks |
| `CustomAttack_0..3` | special attack animations |
| `LoopSoundID`, `BirthSoundID`, `SpellCastDirectedSoundID`, `Submerge*` | loops, spawn, cast, water |

`NPCSounds.dbc` (id + four `SoundEntries` ids: hello, goodbye, pissed, ack) plays on gossip open/
close; put its id in `CreatureDisplayInfo.NPCSoundID`. For a talking vendor or quest giver this is
what makes the model "greet" without any server script.

Each of these fields is a `SoundEntries` id, so a full custom voice set is: N `SoundEntries` rows
(one per kind, several files each) + one `CreatureSoundData` row + optionally one `NPCSounds` row.
Reuse Blizzard ids for the kinds you do not record (footsteps, wound grunts of the donor).

## Producing the audio

- Write the lines first (see the phrase sheet in phrases-and-triggers.md), record or synthesise
  them, keep takes short. Two or three takes per combat bark, one per scripted line.
- Process: high-pass 80 Hz, de-noise, light compression, optional pitch/formant shift for
  non-human creatures, hard limiter at −1 dBFS. Export mono 22 050 Hz 16-bit WAV.
- Check licensing for TTS voices before shipping to players.
- Match Blizzard's register: short, declarative, no modern idiom; humour comes from the situation
  (the Waxworks lines are the house style).

## Pitfalls

- `creature_text.Sound` pointing at an id the **server** does not know → error at load, sound
  zeroed, text still shows. Ship the `soundentries_dbc` row.
- Sound id known to the server but not in the client's `SoundEntries.dbc` (forgot `patch-enUS-4`)
  → silent, no error anywhere.
- `DirectoryBase` without trailing backslash, or `File_N` containing a path → file not found, silent.
- OGG or 24-bit WAV → silent.
- Volume set in the DBC is a multiplier; a quiet source file stays quiet.
- Many players on the same line: `PlayDirectSound` from a script fires per call; SmartAI health
  events without `SMART_EVENT_FLAG_NOT_REPEATABLE` spam the line every tick.
