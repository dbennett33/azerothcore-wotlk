#!/usr/bin/env bash
# Local build with the same CMake flags as vps-build (minus install prefix paths).
# Usage: bash apps/deploy/local-timed-build.sh
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
BUILD_DIR="${BUILD_DIR:-$ROOT/build/local-timed}"
JOBS="${JOBS:-$(( $(nproc) + 2 ))}"

need() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Missing: $1 (install build deps first)" >&2
    exit 1
  }
}

need cmake
need g++

if [[ ! -d "$ROOT/modules/mod-playerbots/src" ]]; then
  echo "Missing modules/mod-playerbots/src (symlink or clone mod-playerbots)" >&2
  exit 1
fi
if [[ ! -d "$ROOT/modules/mod-individual-progression/src" ]]; then
  echo "Missing modules/mod-individual-progression/src" >&2
  exit 1
fi

echo "Build dir: $BUILD_DIR"
echo "Jobs: $JOBS"
echo "CPU: $(nproc) cores"

SECONDS=0
cmake -S "$ROOT" -B "$BUILD_DIR" \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo \
  -DCMAKE_INSTALL_PREFIX="$ROOT/var/local-install" \
  -DCONF_DIR="$ROOT/var/local-install/etc" \
  -DAPPS_BUILD=all \
  -DTOOLS_BUILD=none \
  -DSCRIPTS=static \
  -DMODULES=static

configure_s=$SECONDS
echo "Configure: ${configure_s}s"

build_start=$SECONDS
cmake --build "$BUILD_DIR" --config RelWithDebInfo -j "$JOBS"
build_s=$((SECONDS - build_start))
total_s=$SECONDS

echo ""
echo "=== Timed build summary ==="
echo "Configure: ${configure_s}s"
echo "Compile:   ${build_s}s ($(printf '%d:%02d' $((build_s/60)) $((build_s%60))))"
echo "Total:     ${total_s}s ($(printf '%d:%02d' $((total_s/60)) $((total_s%60))))"
test -x "$BUILD_DIR/src/server/apps/worldserver/worldserver" && echo "worldserver: OK"
test -x "$BUILD_DIR/src/server/apps/authserver/authserver" && echo "authserver: OK"
