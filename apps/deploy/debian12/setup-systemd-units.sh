#!/usr/bin/env bash
# Create auth.service and world.service via AC service-manager (run once as acore,
# after /home/acore/server/bin has authserver and worldserver).

set -euo pipefail

ACORE_PREFIX="${ACORE_PREFIX:-/home/acore/server}"
BIN_PATH="${ACORE_PREFIX}/bin"
ETC_PATH="${ACORE_PREFIX}/etc"
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

if [ "$(id -un)" != "acore" ]; then
  echo "run as acore: sudo -u acore bash $0" >&2
  exit 1
fi

if [ ! -x "${BIN_PATH}/authserver" ] || [ ! -x "${BIN_PATH}/worldserver" ]; then
  echo "binaries missing under ${BIN_PATH}; run deploy-vps or cmake --install first" >&2
  exit 1
fi

if [ ! -f "${ETC_PATH}/authserver.conf" ] || [ ! -f "${ETC_PATH}/worldserver.conf" ]; then
  echo "configs missing under ${ETC_PATH}; copy from *.conf.dist and edit DB settings" >&2
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
  if systemctl --user cat "${name}.service" >/dev/null 2>&1; then
    echo "skip: ${name}.service already exists"
    return 0
  fi
  bash "$SM" create "$name" "${type}server" \
    --provider systemd --user --restart-policy on-failure \
    --bin-path "$BIN_PATH" \
    --server-config "$conf" \
    --no-start
}

create_unit auth auth "${ETC_PATH}/authserver.conf"
create_unit world world "${ETC_PATH}/worldserver.conf"

echo "units created. start with: /home/acore/deploy/restart-acore.sh start"
