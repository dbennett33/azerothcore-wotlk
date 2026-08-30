#!/usr/bin/env bash
# Restart AzerothCore systemd --user units (auth.service, world.service, world-test.service).
# Safe when units are not installed yet.

set -euo pipefail

AUTH_UNIT="${ACORE_AUTH_UNIT:-auth.service}"
WORLD_UNIT="${ACORE_WORLD_UNIT:-world.service}"
WORLD_TEST_UNIT="${ACORE_WORLD_TEST_UNIT:-world-test.service}"

if [ -z "${XDG_RUNTIME_DIR:-}" ]; then
  export XDG_RUNTIME_DIR="/run/user/$(id -u)"
fi

unit_exists() {
  local unit="$1"
  systemctl --user cat "$unit" >/dev/null 2>&1
}

stop_one() {
  local unit="$1"
  if unit_exists "$unit"; then
    systemctl --user stop "$unit"
  else
    echo "skip stop: $unit is not installed"
  fi
}

start_one() {
  local unit="$1"
  if unit_exists "$unit"; then
    systemctl --user start "$unit"
    systemctl --user is-active --quiet "$unit"
    echo "$unit is active"
  else
    echo "skip start: $unit is not installed"
  fi
}

stop_live() {
  stop_one "$WORLD_UNIT"
  stop_one "$AUTH_UNIT"
}

stop_test() {
  stop_one "$WORLD_TEST_UNIT"
}

stop_all() {
  stop_one "$WORLD_TEST_UNIT"
  stop_one "$WORLD_UNIT"
  stop_one "$AUTH_UNIT"
}

start_live() {
  if ! unit_exists "$AUTH_UNIT" || ! unit_exists "$WORLD_UNIT"; then
    echo "live units missing; skip start (see apps/deploy/debian12/bootstrap.md)"
    return 0
  fi
  start_one "$AUTH_UNIT"
  start_one "$WORLD_UNIT"
}

start_test() {
  start_one "$WORLD_TEST_UNIT"
}

start_all() {
  start_live
  start_test
}

status_units() {
  local units=()
  unit_exists "$AUTH_UNIT" && units+=("$AUTH_UNIT")
  unit_exists "$WORLD_UNIT" && units+=("$WORLD_UNIT")
  unit_exists "$WORLD_TEST_UNIT" && units+=("$WORLD_TEST_UNIT")
  if [ "${#units[@]}" -eq 0 ]; then
    echo "no acore user units installed"
    return 0
  fi
  systemctl --user --no-pager --full status "${units[@]}" || true
}

cmd="${1:-restart}"
target="${2:-all}"

case "$cmd" in
  stop)
    case "$target" in
      live) stop_live ;;
      test) stop_test ;;
      all) stop_all ;;
      *) echo "usage: $0 stop {live|test|all}" >&2; exit 2 ;;
    esac
    ;;
  start)
    case "$target" in
      live) start_live ;;
      test) start_test ;;
      all) start_all ;;
      *) echo "usage: $0 start {live|test|all}" >&2; exit 2 ;;
    esac
    ;;
  restart)
    case "$target" in
      live)
        stop_live
        start_live
        ;;
      test)
        stop_test
        start_test
        ;;
      all)
        stop_all
        start_all
        ;;
      *) echo "usage: $0 restart {live|test|all}" >&2; exit 2 ;;
    esac
    ;;
  status)
    status_units
    ;;
  *)
    echo "usage: $0 {stop|start|restart|status} [live|test|all]" >&2
    exit 2
    ;;
esac
