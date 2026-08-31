#!/usr/bin/env bash
# Prepare /home/acore/server-test for realm 2 (dev branch). Run once as acore after live exists.
set -euo pipefail

ACORE_USER="${ACORE_USER:-acore}"
LIVE_PREFIX="${LIVE_PREFIX:-/home/${ACORE_USER}/server}"
TEST_PREFIX="${TEST_PREFIX:-/home/${ACORE_USER}/server-test}"

set_kv() {
  local file="$1" key="$2" value="$3"
  if grep -q "^${key} =" "$file"; then
    sed -i "s|^${key} = .*|${key} = ${value}|" "$file"
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

LIVE_DATA="${LIVE_PREFIX}/data"
TEST_DATA="${TEST_PREFIX}/data"
DATA_MARKER="${TEST_PREFIX}/etc/.data-copied-from-live"

if [[ -L "${TEST_DATA}" ]]; then
  echo "Removing data symlink (${TEST_DATA} -> $(readlink "${TEST_DATA}"))"
  rm "${TEST_DATA}"
fi

mkdir -p "${TEST_DATA}"

copy_live_data() {
  if [[ ! -d "${LIVE_DATA}/dbc" ]]; then
    echo "Live data missing under ${LIVE_DATA}/dbc; copy maps/dbc/vmaps into ${TEST_DATA} manually."
    return 1
  fi
  echo "Copying client data live -> test (rsync; one-time unless FORCE_DATA_SYNC=1)..."
  rsync -a "${LIVE_DATA}/" "${TEST_DATA}/"
  date -u +%Y-%m-%dT%H:%M:%SZ >"${DATA_MARKER}"
  echo "Test data at ${TEST_DATA} (copied from live)."
}

if [[ "${SKIP_DATA_COPY:-0}" == "1" ]]; then
  echo "SKIP_DATA_COPY=1: using existing or empty ${TEST_DATA}"
elif [[ "${FORCE_DATA_SYNC:-0}" == "1" ]]; then
  copy_live_data
elif [[ ! -f "${LIVE_DATA}/dbc/Map.dbc" && ! -f "${TEST_DATA}/dbc/Map.dbc" ]]; then
  copy_live_data || true
elif [[ ! -f "${TEST_DATA}/dbc/Map.dbc" && -f "${LIVE_DATA}/dbc/Map.dbc" ]]; then
  copy_live_data
elif [[ -f "${DATA_MARKER}" ]]; then
  echo "Test data already initialized ($(cat "${DATA_MARKER}"))"
else
  echo "Test data present at ${TEST_DATA} (not managed by ${DATA_MARKER})"
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
echo "Test data is separate from live. Re-copy from live: FORCE_DATA_SYNC=1 $0"
echo "Create test MySQL DBs if needed (see MULTI-REALM.md), then deploy-vps with target=test."
