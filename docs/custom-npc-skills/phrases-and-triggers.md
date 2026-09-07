# Phrases and triggers: `creature_text` + SmartAI or C++

Back to [`README.md`](README.md). Voice files for the phrases: [`sounds.md`](sounds.md).
Verified against `src/server/game/Texts/CreatureTextMgr.cpp`, `AI/CreatureAI.cpp`,
`AI/ScriptedAI/ScriptedCreature.cpp`, `AI/SmartScripts/SmartScriptMgr.h`, `SmartScript.cpp` and the
Waxworks / Belfry scripts and SQL on `Playerbot`.

## Design first: the phrase sheet

One row per scenario; the row's `Group` becomes `creature_text.GroupID` and the C++ `SAY_*` enum
value. Two to four variants per group keep repeat visits fresh (`ID` 0..n, `Probability` split).

| Group | Scenario (trigger) | Lines (variants) | Type | Emote | Voice file | Range |
|---|---|---|---|---|---|---|
| 0 | Aggro | "Nobody makes port. That is the rule." | Yell (14) | 15 roar | `_Aggro01.wav` | normal |
| 1 | Health 60% (once) | "All hands! The crypt is not empty!" | Yell | 25 point | `_Adds01.wav` | normal |
| 2 | Health 20% (once) | "The bell still owes us a ringing." | Yell | 5 exclaim | `_Low01.wav` | map |
| 3 | Killed a player | "Down you go." / "Another for the tide." | Say (12) | 0 | `_Slay01..02.wav` | normal |
| 4 | Death | "…let it… ring…" | Say | 0 | `_Death01.wav` | normal |
| 5 | Idle, out of combat, every 60–120 s | flavour ×3 | Say | 1 talk | none | normal |
| 6 | Gossip hello (whisper to the clicker) | "Keep your voice down." | Whisper (15) | 0 | none | personal |

Keep boss lines ≤ 90 characters (chat bubble width), no trailing punctuation gimmicks, one idea
per line. The Waxworks and Belfry SQL are the house voice.

## `creature_text` rows

```sql
DELETE FROM `creature_text` WHERE `CreatureID` = 9000610;
INSERT INTO `creature_text` (`CreatureID`, `GroupID`, `ID`, `Text`, `Type`, `Language`,
 `Probability`, `Emote`, `Duration`, `Sound`, `BroadcastTextId`, `TextRange`, `comment`) VALUES
(9000610, 0, 0, 'Nobody makes port. That is the rule.', 14, 0, 100, 15, 0, 90010, 0, 0, 'Warden aggro'),
(9000610, 2, 0, 'The bell still owes us a ringing.',    14, 0, 100,  5, 0, 90012, 0, 3, 'Warden 20%'),
(9000610, 3, 0, 'Down you go.',                          12, 0,  50,  0, 0, 90013, 0, 0, 'Warden slay'),
(9000610, 3, 1, 'Another for the tide.',                 12, 0,  50,  0, 0, 90013, 0, 0, 'Warden slay');
```

| Column | Meaning (from `CreatureTextMgr::LoadCreatureTexts`) |
|---|---|
| `GroupID` | the scenario; `Talk(GroupID)` picks one `ID` from the group, weighted by `Probability`, avoiding the last-said id when the group has more than one |
| `Type` | `ChatMsg`: `12` MONSTER_SAY, `13` MONSTER_PARTY, `14` MONSTER_YELL, `15` MONSTER_WHISPER, `16` MONSTER_EMOTE, `41` RAID_BOSS_EMOTE (250 yd in dungeons), `42` RAID_BOSS_WHISPER |
| `Language` | `0` universal; `1` orcish, `7` common, `33` gutterspeak etc. only if players should not understand |
| `Emote` | `Emotes.dbc` id played with the line: `1` talk, `5` exclamation, `15` roar, `25` point, `68` kneel state; unknown id → error, zeroed |
| `Duration` | ms until `SMART_EVENT_TEXT_OVER` (52) fires; chain lines with it |
| `Sound` | `SoundEntries` id; validated, zeroed with an error if the server lacks it |
| `BroadcastTextId` | `0` for custom text (the row's `Text` is used; `broadcast_text` is for Blizzard localisation) |
| `TextRange` | `0` normal chat range, `1` area, `2` zone, `3` **map** (whole instance), `4` world |

Range per `Type` when `TextRange = 0`: say 25 yd, yell 300 yd, emote/whisper 25 yd, boss emote 250 yd
in dungeons. For a 5-man boss speech use yell or `TextRange 3`.

## Triggering with SmartAI (no rebuild)

`creature_template.AIName = 'SmartAI'`, `ScriptName = ''`. One `smart_scripts` row per trigger.
Column header exactly as the Belfry SQL:

```sql
DELETE FROM `smart_scripts` WHERE `entryorguid` = 9000610 AND `source_type` = 0;
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`,
 `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`,
 `event_param3`, `event_param4`, `event_param5`, `event_param6`, `action_type`,
 `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`,
 `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`,
 `target_param4`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
-- aggro → group 0
(9000610, 0, 0, 0,  4, 0, 100, 0,    0,   0,     0,      0, 0, 0,  1, 0, 0, 0, 0, 0, 0,  1, 0, 0, 0, 0, 0, 0, 0, 0, 'Warden - On Aggro - Talk 0'),
-- health 0–60 %, once → group 1
(9000610, 0, 1, 0,  2, 0, 100, 1,    0,  60,     0,      0, 0, 0,  1, 1, 0, 0, 0, 0, 0,  1, 0, 0, 0, 0, 0, 0, 0, 0, 'Warden - HP 60% - Talk 1'),
-- health 0–20 %, once → group 2
(9000610, 0, 2, 0,  2, 0, 100, 1,    0,  20,     0,      0, 0, 0,  1, 2, 0, 0, 0, 0, 0,  1, 0, 0, 0, 0, 0, 0, 0, 0, 'Warden - HP 20% - Talk 2'),
-- killed a player, 10–20 s cooldown → group 3
(9000610, 0, 3, 0,  5, 0, 100, 0, 10000, 20000,  1,      0, 0, 0,  1, 3, 0, 0, 0, 0, 0,  1, 0, 0, 0, 0, 0, 0, 0, 0, 'Warden - On Kill Player - Talk 3'),
-- death → group 4
(9000610, 0, 4, 0,  6, 0, 100, 0,    0,   0,     0,      0, 0, 0,  1, 4, 0, 0, 0, 0, 0,  1, 0, 0, 0, 0, 0, 0, 0, 0, 'Warden - On Death - Talk 4'),
-- out of combat, first 30–60 s then every 60–120 s → group 5
(9000610, 0, 5, 0,  1, 0, 100, 0, 30000, 60000, 60000, 120000, 0, 0,  1, 5, 0, 0, 0, 0, 0,  1, 0, 0, 0, 0, 0, 0, 0, 0, 'Warden - OOC - Talk 5'),
-- gossip hello → whisper group 6 to the invoker
(9000610, 0, 6, 0, 64, 0, 100, 0,    0,   0,     0,      0, 0, 0,  1, 6, 0, 0, 0, 0, 0,  7, 0, 0, 0, 0, 0, 0, 0, 0, 'Warden - On Gossip Hello - Whisper 6');
```

Health events: `SMART_EVENT_HEALTH_PCT` (2) fires on every AI update while in combat and HP% is
within `[param1, param2]`; `RecalcTimer(0,0)` re-arms it immediately, so **always** set
`event_flags = 1` (`SMART_EVENT_FLAG_NOT_REPEATABLE`) or give `param3/param4` a repeat window.
The flag resets on evade (`OnReset`) unless `0x100` `DONT_RESET` is also set.

Scenario → event catalogue (ids from `SmartScriptMgr.h`, params in its comments):

| Scenario | Event | Params |
|---|---|---|
| Pulled | `4` AGGRO | — |
| Own HP band | `2` HEALTH_PCT | min%, max%, repeatMin, repeatMax |
| Victim HP band | `12` TARGET_HEALTH_PCT | same |
| Own mana band | `3` MANA_PCT | same |
| Killed someone | `5` KILL | cdMin, cdMax, playerOnly, creatureEntry |
| Died | `6` DEATH | — |
| Evaded / reset / respawn | `7` EVADE, `25` RESET, `11` RESPAWN | — / type, map, zone |
| Hit by a spell | `8` SPELLHIT | spellId, school, cdMin, cdMax |
| Player in LOS out of combat | `10` OOC_LOS | hostility, range, cdMin, cdMax, playerOnly |
| Friend low / CC'd / missing buff | `14`, `74` FRIENDLY_HEALTH(_PCT), `15`, `16` | see header |
| Summoned an add / add died | `17` SUMMONED_UNIT, `82` SUMMONED_UNIT_DIES | entry, cd |
| Took big damage | `32` DAMAGED | minDmg, maxDmg, cdMin, cdMax |
| Reached a waypoint / point | `108` WAYPOINT_REACHED, `34` MOVEMENTINFORM | pointId, pathId |
| Another script set data | `38` DATA_SET | id, value, cd |
| Previous line finished | `52` TEXT_OVER | groupId, talker entry |
| Quest accepted / rewarded | `19`, `20` | questId, cd |
| Gossip opened / option chosen | `64` GOSSIP_HELLO, `62` GOSSIP_SELECT | filter / menuId, actionId |
| Player near (count) | `101` NEAR_PLAYERS, `102` negation | min, radius, first, repeatMin, repeatMax |
| Player enters the instance | `45` INSTANCE_PLAYER_ENTER | team, cd |
| Timer | `0` UPDATE_IC, `1` UPDATE_OOC, `60` UPDATE, `59` TIMED_EVENT_TRIGGERED | initMin, initMax, repMin, repMax |
| Received /emote | `22` RECEIVE_EMOTE | emoteId, cd |

Actions that speak: `1` TALK (groupId, duration, useTalkTarget), `84` SIMPLE_TALK (targets say it),
`4` SOUND, `115` RANDOM_SOUND, `216` MUSIC, `5` PLAY_EMOTE, `17` SET_EMOTE_STATE, `220` PLAYER_TALK
(player says an `acore_string`). Target `1` self, `7` action invoker (gossip clicker, killer),
`21` closest player, `17` player range, `16` invoker party. Whispers need a player target.

Chains: `link` to the next `id` with `event_type 61` (LINK) to talk **and** cast **and** summon on
the same trigger; `event_phase_mask` with `SET_EVENT_PHASE` (22) / `INC_EVENT_PHASE` (23) for
"only after 60% has happened". Conditions on an event: `conditions` table
`SourceType 22` (`CONDITION_SOURCE_TYPE_SMART_EVENT`), e.g. only when the victim is a mage.

## Triggering from C++ (bosses)

Bosses in this fork are `ScriptedAI`/`BossAI` structs with a `SAY_*` enum in the dungeon header
(`waxworks.h`) whose values are the `GroupID`s:

```cpp
enum WardenTexts { SAY_WARDEN_AGGRO = 0, SAY_WARDEN_ADDS, SAY_WARDEN_LOW, SAY_WARDEN_SLAY, SAY_WARDEN_DEATH };

void JustEngagedWith(Unit*) override { Talk(SAY_WARDEN_AGGRO); }
void KilledUnit(Unit* victim) override { if (victim->IsPlayer()) Talk(SAY_WARDEN_SLAY); }
void JustDied(Unit*) override { Talk(SAY_WARDEN_DEATH); }

// Pattern A (Waxworks): DamageTaken + one-shot flags
void DamageTaken(Unit*, uint32&, DamageEffectType, SpellSchoolMask) override
{
    if (!_low && me->HealthBelowPct(20)) { _low = true; Talk(SAY_WARDEN_LOW); DoCastSelf(SPELL_ENRAGE); }
}

// Pattern B (BossAI): declarative health checks, reset with the encounter
void JustEngagedWith(Unit* who) override
{
    BossAI::JustEngagedWith(who);
    ScheduleHealthCheckEvent(60, [&] { Talk(SAY_WARDEN_ADDS); SummonAdds(); });
    ScheduleHealthCheckEvent(20, [&] { Talk(SAY_WARDEN_LOW); });
}
```

`CreatureAI::Talk(uint8 group, WorldObject const* target = nullptr, Milliseconds delay = 0ms)`:
`target` becomes the whisper target; `delay` schedules on `me->m_Events` (stagger two lines). Text
plus sound come from the `creature_text` row, so the sheet stays the single source of truth for
both SmartAI and C++ NPCs. Other useful hooks: `EnterEvadeMode`, `MovementInform`, `SpellHit`,
`SpellHitTarget`, `JustSummoned`, `SummonedCreatureDies`, `OnGossipHello`/`OnGossipSelect` on the
`CreatureScript`, `ScheduleTimedEvent`/`ScheduleUniqueTimedEvent` for timers,
`me->PlayDirectSound(id)` for a sound with no text. Add every new `SAY_*` to the enum; no raw
literals (`.agents/docs/cpp-scripts.md`). C++ changes need `vps-build`; SQL alone needs a restart.

## Anti-spam and pacing rules

- One-shot scenario (HP thresholds, adds phase): `event_flags 1`, or a `bool` in C++ reset in `Reset()`.
- Repeating barks (kill, spell hit): 10–30 s cooldown, `Probability` < 100 or several variants.
- Idle chatter: `UPDATE_OOC` 60–180 s, `event_chance` 50–75, `Type` say, never yell.
- Whole-instance lines (`TextRange 3` or `Type 41`) only for the two or three beats that matter.
- Two lines on one trigger: `Duration` + `TEXT_OVER`, or `Talk(id, nullptr, 3s)`; never two `Talk`
  calls in the same frame (bubbles overlap).
- Text that must survive a wipe (phase change already announced) → `DONT_RESET` (0x100) is rarely
  right; prefer re-announcing.

## Verification

- worldserver log after restart: no `CreatureTextMgr:` errors for the entry; no
  `SMART_ACTION_TALK … non-existent Text id`.
- In game: `.npc say`, `.reload creature_text`, `.reload smart_scripts` (then re-spawn the NPC),
  `.npc info` shows `AIName`/`ScriptName`, `.debug` not needed. Use a level-1 bot or `.damage` to
  walk the boss through 60 % and 20 %; confirm each line fires once and the voice file plays.
- Second pull after a wipe: the one-shot lines fire again (flags reset on evade).
