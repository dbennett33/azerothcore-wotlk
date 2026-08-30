#!/usr/bin/env bash
# Send SIGTERM to worldserver and wait for clean shutdown (player saves on exit).
# Use before systemctl stop when the unit wraps run-engine/bash around the binary.
set -euo pipefail

ACORE_PREFIX="${ACORE_PREFIX:?set ACORE_PREFIX}"
TIMEOUT_SEC="${GRACEFUL_STOP_TIMEOUT:-120}"
BIN="${ACORE_PREFIX}/bin/worldserver"
CONF="${ACORE_PREFIX}/etc/worldserver.conf"

if [[ ! -x "$BIN" ]]; then
  echo "skip graceful stop: missing $BIN"
  exit 0
fi

find_world_pid() {
  local pid
  # Match the real worldserver process for this prefix (not bash/tclsh wrappers).
  pid="$(pgrep -f "${BIN} -c ${CONF}" 2>/dev/null | head -1 || true)"
  if [[ -z "$pid" ]]; then
    pid="$(pgrep -f "${BIN}" 2>/dev/null | head -1 || true)"
  fi
  echo "$pid"
}

pid="$(find_world_pid)"
if [[ -z "$pid" ]]; then
  echo "worldserver not running for ${ACORE_PREFIX}"
  exit 0
fi

echo "Graceful stop: worldserver pid=${pid} (${ACORE_PREFIX})"
kill -TERM "$pid" 2>/dev/null || true

for ((i = 1; i <= TIMEOUT_SEC; i++)); do
  if ! kill -0 "$pid" 2>/dev/null; then
    echo "worldserver exited cleanly after ${i}s"
    exit 0
  fi
  sleep 1
done

echo "worldserver still running after ${TIMEOUT_SEC}s; sending SIGKILL to pid=${pid}" >&2
kill -KILL "$pid" 2>/dev/null || true
sleep 2
if kill -0 "$pid" 2>/dev/null; then
  echo "failed to stop worldserver pid=${pid}" >&2
  exit 1
fi
