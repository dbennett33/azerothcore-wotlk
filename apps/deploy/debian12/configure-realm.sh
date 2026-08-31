#!/usr/bin/env bash
# Apply worldserver + mod-individual-progression + playerbots for WotLK phase 1 (tier 13).
# Safe to re-run; edits live config under ACORE_PREFIX (default /home/acore/server).
set -euo pipefail

ACORE_PREFIX="${ACORE_PREFIX:-/home/acore/server}"
WS_CONF="${ACORE_PREFIX}/etc/worldserver.conf"
PB_CONF="${ACORE_PREFIX}/etc/modules/playerbots.conf"
IP_DIST="${ACORE_PREFIX}/etc/modules/individualProgression.conf.dist"
IP_CONF="${ACORE_PREFIX}/etc/modules/individualProgression.conf"

set_kv() {
  local file="$1" key="$2" value="$3"
  if grep -q "^${key} =" "$file"; then
    sed -i "s|^${key} = .*|${key} = ${value}|" "$file"
  else
    echo "${key} = ${value}" >>"$file"
  fi
}

if [[ ! -f "$WS_CONF" ]]; then
  echo "Missing ${WS_CONF}"
  exit 1
fi

realm_id="$(grep -E '^RealmID' "$WS_CONF" | head -1 | sed -E 's/^RealmID *= *//')"
if [[ "$realm_id" == "2" ]]; then
  world_db="${WORLD_DB:-acore_world_test}"
  character_db="${CHARACTER_DB:-acore_characters_test}"
  playerbots_db="${PLAYERBOTS_DB:-acore_playerbots_test}"
  min_bots="${MIN_RANDOM_BOTS:-50}"
  max_bots="${MAX_RANDOM_BOTS:-50}"
else
  world_db="${WORLD_DB:-acore_world}"
  character_db="${CHARACTER_DB:-acore_characters}"
  playerbots_db="${PLAYERBOTS_DB:-acore_playerbots}"
  min_bots="${MIN_RANDOM_BOTS:-1000}"
  max_bots="${MAX_RANDOM_BOTS:-1000}"
fi

db_info() {
  printf '127.0.0.1;3306;acore;acore;%s' "$1"
}

set_kv "$WS_CONF" "Expansion" "2"
set_kv "$WS_CONF" "MaxPlayerLevel" "80"
set_kv "$WS_CONF" "MinDualSpecLevel" "40"
set_kv "$WS_CONF" "EnablePlayerSettings" "1"
set_kv "$WS_CONF" "DBC.EnforceItemAttributes" "0"
set_kv "$WS_CONF" "CharacterCreating.Disabled.ClassMask" "0"
# SimpleConfigOverride would force the Vanilla 60s timer; keep WotLK 3 minutes.
set_kv "$WS_CONF" "WaterBreath.Timer" "180000"
set_kv "$WS_CONF" "SOAP.Enabled" "1"
set_kv "$WS_CONF" "SOAP.IP" "127.0.0.1"
if [[ "$realm_id" == "2" ]]; then
  set_kv "$WS_CONF" "SOAP.Port" "7879"
else
  set_kv "$WS_CONF" "SOAP.Port" "7878"
fi
set_kv "$WS_CONF" "WorldDatabaseInfo" "\"$(db_info "$world_db")\""
set_kv "$WS_CONF" "CharacterDatabaseInfo" "\"$(db_info "$character_db")\""
set_kv "$WS_CONF" "SourceDirectory" "\"/home/acore/src/azerothcore-wotlk\""
set_kv "$WS_CONF" "PlayerbotsDatabaseInfo" "\"$(db_info "$playerbots_db")\""
set_kv "$WS_CONF" "Playerbots.Updates.EnableDatabases" "1"

AUTH_CONF="${ACORE_PREFIX}/etc/authserver.conf"
if [[ -f "$AUTH_CONF" ]]; then
  # Compiled-in default is the build-VM runner path; auth will refuse to start without this.
  set_kv "$AUTH_CONF" "SourceDirectory" "\"/home/acore/src/azerothcore-wotlk\""
fi

if [[ -f "$IP_DIST" && ! -f "$IP_CONF" ]]; then
  cp "$IP_DIST" "$IP_CONF"
fi

if [[ -f "$IP_CONF" ]]; then
  # Tier 13 = WotLK phase 1 (Naxx 80, Eye of Eternity, Obsidian Sanctum).
  set_kv "$IP_CONF" "IndividualProgression.Enable" "1"
  set_kv "$IP_CONF" "IndividualProgression.ProgressionLimit" "13"
  set_kv "$IP_CONF" "IndividualProgression.StartingProgression" "13"
  set_kv "$IP_CONF" "IndividualProgression.TbcRacesUnlockProgression" "0"
  # 0 = create DK as first character (13 would require an existing char at tier 13).
  set_kv "$IP_CONF" "IndividualProgression.DeathKnightUnlockProgression" "0"
  set_kv "$IP_CONF" "IndividualProgression.DeathKnightStartingProgression" "13"
  set_kv "$IP_CONF" "IndividualProgression.VanillaPowerAdjustment" "1"
  set_kv "$IP_CONF" "IndividualProgression.VanillaHealingAdjustment" "1"
  set_kv "$IP_CONF" "IndividualProgression.TBCPowerAdjustment" "1"
  set_kv "$IP_CONF" "IndividualProgression.TBCHealingAdjustment" "1"
  set_kv "$IP_CONF" "IndividualProgression.SimpleConfigOverride" "0"
  set_kv "$IP_CONF" "IndividualProgression.DisableRDF" "0"
  set_kv "$IP_CONF" "IndividualProgression.DisableQuestMarkers" "0"
  set_kv "$IP_CONF" "IndividualProgression.FishingFix" "0"
  set_kv "$IP_CONF" "IndividualProgression.RepeatableVanillaQuestsXP" "0"
  set_kv "$IP_CONF" "IndividualProgression.BotAccountsMaxLevel" "80"
  set_kv "$IP_CONF" "IndividualProgression.BotAccountsRegex" "^RNDBOT.*"
  set_kv "$IP_CONF" "IndividualProgression.BotOnlyAdjustments" "0"
else
  echo "individualProgression.conf not found (module not installed yet?). Skipping module config."
fi

if [[ -f "$PB_CONF" ]]; then
  set_kv "$PB_CONF" "AiPlayerbot.Enabled" "1"
  set_kv "$PB_CONF" "AiPlayerbot.RandomBotAutologin" "1"
  set_kv "$PB_CONF" "AiPlayerbot.MinRandomBots" "$min_bots"
  set_kv "$PB_CONF" "AiPlayerbot.MaxRandomBots" "$max_bots"
  set_kv "$PB_CONF" "AiPlayerbot.RandomBotAccountPrefix" "RNDBOT"
  set_kv "$PB_CONF" "AiPlayerbot.RandomBotMaps" "0,1,530,571"
  set_kv "$PB_CONF" "AiPlayerbot.RandomBotMinLevel" "1"
  set_kv "$PB_CONF" "AiPlayerbot.RandomBotMaxLevel" "80"
  # 10% spawn at 80, 90% at 1 and level. DisableRandomLevels would force everyone to StartingLevel.
  set_kv "$PB_CONF" "AiPlayerbot.DisableRandomLevels" "0"
  set_kv "$PB_CONF" "AiPlayerbot.RandombotStartingLevel" "1"
  set_kv "$PB_CONF" "AiPlayerbot.RandomBotMaxLevelChance" "0.1"
  set_kv "$PB_CONF" "AiPlayerbot.RandomBotMinLevelChance" "0.9"
  set_kv "$PB_CONF" "AiPlayerbot.RandomBotFixedLevel" "0"
  set_kv "$PB_CONF" "AiPlayerbot.ResetBotLevel.Enabled" "1"
  set_kv "$PB_CONF" "AiPlayerbot.ResetBotLevel.MaxLevel" "80"
  set_kv "$PB_CONF" "AiPlayerbot.ResetBotLevel.ResetToLevel" "1"
  set_kv "$PB_CONF" "AiPlayerbot.ResetBotLevel.ResetChance" "90"
  set_kv "$PB_CONF" "AiPlayerbot.ResetBotLevel.RestrictTimePlayed" "1"
  set_kv "$PB_CONF" "AiPlayerbot.ResetBotLevel.MinTimePlayed" "86400"
  set_kv "$PB_CONF" "AiPlayerbot.AutoDoQuests" "1"
  set_kv "$PB_CONF" "AiPlayerbot.DisableDeathKnightLogin" "0"
  set_kv "$PB_CONF" "AiPlayerbot.LimitEnchantExpansion" "0"
  set_kv "$PB_CONF" "AiPlayerbot.LimitGearExpansion" "0"
  set_kv "$PB_CONF" "AiPlayerbot.LimitTalentsExpansion" "0"
  set_kv "$PB_CONF" "AiPlayerbot.PlayerbotsDatabaseInfo" "$(db_info "$playerbots_db")"
fi

SKIP_DIST="${ACORE_PREFIX}/etc/modules/skip_dk_module.conf.dist"
SKIP_CONF="${ACORE_PREFIX}/etc/modules/skip_dk_module.conf"
if [[ -f "$SKIP_DIST" && ! -f "$SKIP_CONF" ]]; then
  cp "$SKIP_DIST" "$SKIP_CONF"
fi
if [[ -f "$SKIP_CONF" ]]; then
  set_kv "$SKIP_CONF" "Skip.Deathknight.Starter.Enable" "1"
  set_kv "$SKIP_CONF" "Skip.Deathknight.Optional.Enable" "1"
  set_kv "$SKIP_CONF" "Skip.Deathknight.Start.Level" "58"
  set_kv "$SKIP_CONF" "Skip.Deathknight.Start.Trained" "1"
  set_kv "$SKIP_CONF" "Skip.Deathknight.Starter.Announce.enable" "0"
  set_kv "$SKIP_CONF" "GM.Skip.Deathknight.Starter.Enable" "0"
  set_kv "$SKIP_CONF" "DeleteGold.Deathknight.Optional.Enable" "1"
fi

echo "WotLK tier-13 realm config applied under ${ACORE_PREFIX}/etc"
