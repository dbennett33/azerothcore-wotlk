#!/usr/bin/env bash
# Apply worldserver + mod-individual-progression settings for a vanilla-locked server.
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
    sed -i "s/^${key} = .*/${key} = ${value}/" "$file"
  else
    echo "${key} = ${value}" >>"$file"
  fi
}

if [[ ! -f "$WS_CONF" ]]; then
  echo "Missing ${WS_CONF}"
  exit 1
fi

set_kv "$WS_CONF" "Expansion" "0"
set_kv "$WS_CONF" "MaxPlayerLevel" "60"
set_kv "$WS_CONF" "MinDualSpecLevel" "61"
set_kv "$WS_CONF" "EnablePlayerSettings" "1"
set_kv "$WS_CONF" "DBC.EnforceItemAttributes" "0"
set_kv "$WS_CONF" "CharacterCreating.Disabled.ClassMask" "32"
set_kv "$WS_CONF" "SOAP.Enabled" "1"
set_kv "$WS_CONF" "SOAP.IP" "127.0.0.1"
set_kv "$WS_CONF" "SOAP.Port" "7878"

if [[ -f "$IP_DIST" && ! -f "$IP_CONF" ]]; then
  cp "$IP_DIST" "$IP_CONF"
fi

if [[ ! -f "$IP_CONF" ]]; then
  echo "individualProgression.conf not found (module not installed yet?). Skipping module config."
  exit 0
fi

set_kv "$IP_CONF" "IndividualProgression.Enable" "1"
set_kv "$IP_CONF" "IndividualProgression.ProgressionLimit" "7"
set_kv "$IP_CONF" "IndividualProgression.StartingProgression" "0"
set_kv "$IP_CONF" "IndividualProgression.TbcRacesUnlockProgression" "8"
set_kv "$IP_CONF" "IndividualProgression.DeathKnightUnlockProgression" "13"
set_kv "$IP_CONF" "IndividualProgression.VanillaPowerAdjustment" "0.55"
set_kv "$IP_CONF" "IndividualProgression.VanillaHealingAdjustment" "0.5"
set_kv "$IP_CONF" "IndividualProgression.TBCPowerAdjustment" "1"
set_kv "$IP_CONF" "IndividualProgression.TBCHealingAdjustment" "1"
set_kv "$IP_CONF" "IndividualProgression.QuestXPFix" "1"
set_kv "$IP_CONF" "IndividualProgression.RequireNaxxStrathEntrance" "0"
set_kv "$IP_CONF" "IndividualProgression.FishingFix" "1"
set_kv "$IP_CONF" "IndividualProgression.SimpleConfigOverride" "1"
set_kv "$IP_CONF" "IndividualProgression.DisableQuestMarkers" "1"
set_kv "$IP_CONF" "IndividualProgression.DisableRDF" "1"
set_kv "$IP_CONF" "IndividualProgression.QuestMoneyAtLevelCap" "1"
set_kv "$IP_CONF" "IndividualProgression.RepeatableVanillaQuestsXP" "1"
set_kv "$IP_CONF" "IndividualProgression.BotAccountsMaxLevel" "60"
set_kv "$IP_CONF" "IndividualProgression.BotAccountsRegex" "^RNDBOT.*"
set_kv "$IP_CONF" "IndividualProgression.BotOnlyAdjustments" "0"
set_kv "$IP_CONF" "IndividualProgression.MaxMonsterSight" "1"

if [[ -f "$PB_CONF" ]]; then
  set_kv "$PB_CONF" "AiPlayerbot.Enabled" "1"
  set_kv "$PB_CONF" "AiPlayerbot.RandomBotAutologin" "1"
  set_kv "$PB_CONF" "AiPlayerbot.MinRandomBots" "500"
  set_kv "$PB_CONF" "AiPlayerbot.MaxRandomBots" "500"
  set_kv "$PB_CONF" "AiPlayerbot.RandomBotAccountPrefix" "RNDBOT"
  set_kv "$PB_CONF" "AiPlayerbot.RandomBotMaps" "0,1"
  set_kv "$PB_CONF" "AiPlayerbot.RandomBotMaxLevel" "60"
  set_kv "$PB_CONF" "AiPlayerbot.RandombotStartingLevel" "60"
  set_kv "$PB_CONF" "AiPlayerbot.DisableDeathKnightLogin" "1"
  set_kv "$PB_CONF" "AiPlayerbot.LimitEnchantExpansion" "1"
  set_kv "$PB_CONF" "AiPlayerbot.LimitGearExpansion" "1"
  set_kv "$PB_CONF" "AiPlayerbot.LimitTalentsExpansion" "0"
  set_kv "$PB_CONF" "AiPlayerbot.PlayerbotsDatabaseInfo" "127.0.0.1;3306;acore;acore;acore_playerbots"
fi

echo "Vanilla progression config applied under ${ACORE_PREFIX}/etc"
