#!/usr/bin/env bash
# Apply worldserver + playerbots settings for full WotLK 3.3.5 realms.
# Safe to re-run; edits live config under ACORE_PREFIX (default /home/acore/server).
set -euo pipefail

ACORE_PREFIX="${ACORE_PREFIX:-/home/acore/server}"
WS_CONF="${ACORE_PREFIX}/etc/worldserver.conf"
PB_CONF="${ACORE_PREFIX}/etc/modules/playerbots.conf"

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
set_kv "$WS_CONF" "EnablePlayerSettings" "0"
set_kv "$WS_CONF" "DBC.EnforceItemAttributes" "1"
set_kv "$WS_CONF" "CharacterCreating.Disabled.ClassMask" "0"
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

echo "WotLK realm config applied under ${ACORE_PREFIX}/etc"
