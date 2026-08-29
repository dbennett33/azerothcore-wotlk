#!/usr/bin/env bash
# Restart AzerothCore systemd --user units created by service-manager.sh
# (auth.service, world.service). Safe to call when units are not installed yet.

set -euo pipefail

AUTH_UNIT="${ACORE_AUTH_UNIT:-auth.service}"
WORLD_UNIT="${ACORE_WORLD_UNIT:-world.service}"

if [ -z "${XDG_RUNTIME_DIR:-}" ]; then
  export XDG_RUNTIME_DIR="/run/user/$(id -u)"
fi

unit_exists() {
  local unit="$1"
  systemctl --user cat "$unit" >/dev/null 2>&1
}

stop_units() {
  if unit_exists "$WORLD_UNIT"; then
    systemctl --user stop "$WORLD_UNIT"
  else
    echo "skip stop: $WORLD_UNIT is not installed"
  fi
  if unit_exists "$AUTH_UNIT"; then
    systemctl --user stop "$AUTH_UNIT"
  else
    echo "skip stop: $AUTH_UNIT is not installed"
  fi
}

start_units() {
  if ! unit_exists "$AUTH_UNIT" || ! unit_exists "$WORLD_UNIT"; then
    echo "auth/world user units are not installed yet; skip start"
    echo "see apps/deploy/debian12/bootstrap.md section 6"
    return 0
  fi
  systemctl --user start "$AUTH_UNIT"
  systemctl --user start "$WORLD_UNIT"
  systemctl --user is-active --quiet "$AUTH_UNIT"
  systemctl --user is-active --quiet "$WORLD_UNIT"
  echo "$AUTH_UNIT and $WORLD_UNIT are active"
}

status_units() {
  systemctl --user --no-pager --full status "$AUTH_UNIT" "$WORLD_UNIT" || true
}

cmd="${1:-restart}"
case "$cmd" in
  stop)
    stop_units
    ;;
  start)
    start_units
    ;;
  restart)
    stop_units
    start_units
    ;;
  status)
    status_units
    ;;
  *)
    echo "usage: $0 {stop|start|restart|status}" >&2
    exit 2
    ;;
esac
