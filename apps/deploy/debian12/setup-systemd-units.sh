#!/usr/bin/env bash
# Create auth.service, world.service, and world-test.service via AC service-manager.
# Run once as acore after binaries and configs exist under live and test prefixes.

set -euo pipefail

ACORE_USER="${ACORE_USER:-acore}"
LIVE_PREFIX="${ACORE_PREFIX:-/home/${ACORE_USER}/server}"
TEST_PREFIX="${TEST_PREFIX:-/home/${ACORE_USER}/server-test}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../../.." && pwd)"

find_service_manager() {
  local candidate
  for candidate in \
    "${REPO_ROOT}/apps/startup-scripts/src/service-manager.sh" \
    "/home/acore/src/azerothcore/apps/startup-scripts/src/service-manager.sh" \
    "${GITHUB_WORKSPACE:-}/apps/startup-scripts/src/service-manager.sh"; do
    if [ -f "$candidate" ]; then
      echo "$candidate"
      return 0
    fi
  done
  return 1
}

if [ "$(id -un)" != "$ACORE_USER" ]; then
  echo "run as ${ACORE_USER}: sudo -u ${ACORE_USER} bash $0" >&2
  exit 1
fi

SM="$(find_service_manager)" || {
  echo "service-manager.sh not found; run deploy-vps once (syncs scripts to /home/acore/src/azerothcore)" >&2
  exit 1
}

export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

create_unit() {
  local name="$1"
  local type="$2"
  local conf="$3"
  local bin_path="$4"
  if systemctl --user cat "${name}.service" >/dev/null 2>&1; then
    echo "skip: ${name}.service already exists"
    return 0
  fi
  bash "$SM" create "$type" "$name" \
    --provider systemd --user --restart-policy on-failure \
    --bin-path "$bin_path" \
    --server-config "$conf" \
    --no-start
}

LIVE_BIN="${LIVE_PREFIX}/bin"
LIVE_ETC="${LIVE_PREFIX}/etc"
TEST_BIN="${TEST_PREFIX}/bin"
TEST_ETC="${TEST_PREFIX}/etc"

if [ ! -x "${LIVE_BIN}/authserver" ] || [ ! -x "${LIVE_BIN}/worldserver" ]; then
  echo "live binaries missing under ${LIVE_BIN}; deploy live first" >&2
  exit 1
fi

if [ ! -f "${LIVE_ETC}/authserver.conf" ] || [ ! -f "${LIVE_ETC}/worldserver.conf" ]; then
  echo "live configs missing under ${LIVE_ETC}" >&2
  exit 1
fi

create_unit auth auth "${LIVE_ETC}/authserver.conf" "${LIVE_BIN}"
create_unit world world "${LIVE_ETC}/worldserver.conf" "${LIVE_BIN}"

if [ -x "${TEST_BIN}/worldserver" ] && [ -f "${TEST_ETC}/worldserver.conf" ]; then
  create_unit world-test world "${TEST_ETC}/worldserver.conf" "${TEST_BIN}"
else
  echo "skip world-test: deploy test realm first (${TEST_PREFIX})"
fi

echo "units ready. start with: /home/acore/deploy/restart-acore.sh start all"
