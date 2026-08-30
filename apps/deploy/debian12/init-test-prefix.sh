#!/usr/bin/env bash
# Prepare /home/acore/server-test for realm 2 (dev branch). Run once as acore after live exists.
set -euo pipefail

ACORE_USER="${ACORE_USER:-acore}"
LIVE_PREFIX="${LIVE_PREFIX:-/home/${ACORE_USER}/server}"
TEST_PREFIX="${TEST_PREFIX:-/home/${ACORE_USER}/server-test}"

set_kv() {
  local file="$1" key="$2" value="$3"
  if grep -q "^${key} =" "$file"; then
    sed -i "s/^${key} = .*/${key} = ${value}/" "$file"
  else
    echo "${key} = ${value}" >>"$file"
  fi
}

if [[ "$(id -un)" != "$ACORE_USER" ]]; then
  echo "run as ${ACORE_USER}: sudo -u ${ACORE_USER} bash $0" >&2
  exit 1
fi

if [[ ! -d "${LIVE_PREFIX}/etc" ]]; then
  echo "Live prefix missing (${LIVE_PREFIX}). Deploy live first." >&2
  exit 1
fi

mkdir -p "${TEST_PREFIX}/bin" "${TEST_PREFIX}/etc/modules" "${TEST_PREFIX}/logs"

if [[ ! -e "${TEST_PREFIX}/data" ]]; then
  ln -sfn "${LIVE_PREFIX}/data" "${TEST_PREFIX}/data"
  echo "Linked ${TEST_PREFIX}/data -> ${LIVE_PREFIX}/data"
fi

for f in authserver.conf worldserver.conf; do
  if [[ ! -f "${TEST_PREFIX}/etc/${f}" && -f "${LIVE_PREFIX}/etc/${f}" ]]; then
    cp -a "${LIVE_PREFIX}/etc/${f}" "${TEST_PREFIX}/etc/${f}"
  fi
done

for dist in "${TEST_PREFIX}/etc"/*.conf.dist "${TEST_PREFIX}/etc/modules"/*.conf.dist; do
  [[ -f "$dist" ]] || continue
  conf="${dist%.dist}"
  [[ -f "$conf" ]] || cp -a "$dist" "$conf"
done

if [[ -f "${LIVE_PREFIX}/etc/modules/playerbots.conf" && ! -f "${TEST_PREFIX}/etc/modules/playerbots.conf" ]]; then
  cp -a "${LIVE_PREFIX}/etc/modules/playerbots.conf" "${TEST_PREFIX}/etc/modules/playerbots.conf"
fi

if [[ -f "${LIVE_PREFIX}/etc/modules/individualProgression.conf" && ! -f "${TEST_PREFIX}/etc/modules/individualProgression.conf" ]]; then
  cp -a "${LIVE_PREFIX}/etc/modules/individualProgression.conf" "${TEST_PREFIX}/etc/modules/individualProgression.conf"
fi

WS="${TEST_PREFIX}/etc/worldserver.conf"
if [[ -f "$WS" ]]; then
  set_kv "$WS" "RealmID" "2"
  set_kv "$WS" "WorldServerPort" "8086"
  set_kv "$WS" "LoginDatabaseInfo" '"127.0.0.1;3306;acore;acore;acore_auth"'
  set_kv "$WS" "WorldDatabaseInfo" '"127.0.0.1;3306;acore;acore;acore_world_test"'
  set_kv "$WS" "CharacterDatabaseInfo" '"127.0.0.1;3306;acore;acore;acore_characters_test"'
  set_kv "$WS" "DataDir" "\"${TEST_PREFIX}/data\""
  set_kv "$WS" "LogsDir" "\"${TEST_PREFIX}/logs\""
fi

PB="${TEST_PREFIX}/etc/modules/playerbots.conf"
if [[ -f "$PB" ]]; then
  set_kv "$PB" "AiPlayerbot.PlayerbotsDatabaseInfo" "127.0.0.1;3306;acore;acore;acore_playerbots_test"
  set_kv "$PB" "AiPlayerbot.MinRandomBots" "50"
  set_kv "$PB" "AiPlayerbot.MaxRandomBots" "50"
fi

echo "Test prefix ready at ${TEST_PREFIX} (RealmID=2, port 8086)."
echo "Create test MySQL DBs if needed (see MULTI-REALM.md), then deploy-vps with target=test."
