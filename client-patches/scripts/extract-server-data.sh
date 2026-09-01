#!/usr/bin/env bash
# Extract server data (maps/vmaps/mmaps/dbc) from a WoW 3.3.5a install into sources/server/.
#
# The AzerothCore extractors expect to run inside the WoW install directory.
#
# Usage:
#   WOW_CLIENT=/path/to/WoW AC_TOOLS_BIN=/path/to/build/bin ./extract-server-data.sh
#   ./extract-server-data.sh --dbc-only
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "${SCRIPT_DIR}/lib.sh"

WOW_CLIENT="${WOW_CLIENT:-${WOW_DIR:-}}"
AC_TOOLS_BIN="${AC_TOOLS_BIN:-}"
DBC_ONLY=0
SKIP_MMAPS=0

usage() {
  cat <<'EOF'
Usage: extract-server-data.sh [options]

Environment:
  WOW_CLIENT      Path to WoW 3.3.5a install (must contain Data/ and WoW.exe)
  AC_TOOLS_BIN    Directory containing map_extractor, vmap4_extractor, vmap4_assembler, mmaps_generator

Options:
  --dbc-only      Print DBC placement instructions only
  --skip-mmaps    Extract maps + vmaps but skip mmaps (faster iteration)
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dbc-only)
      DBC_ONLY=1
      shift
      ;;
    --skip-mmaps)
      SKIP_MMAPS=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

DEST="${CLIENT_PATCHES_ROOT}/sources/server"
mkdir -p "${DEST}/dbc" "${DEST}/maps" "${DEST}/vmaps" "${DEST}/mmaps"

if [[ "$DBC_ONLY" -eq 1 ]]; then
  cat <<EOF
Place edited DBC files in:
  ${DEST}/dbc/

After terrain work, use map_extractor / vmap4_extractor from your WoW folder
(see apps/extractor/extractor.sh) and rsync outputs into:
  ${DEST}/maps/
  ${DEST}/vmaps/
  ${DEST}/mmaps/
EOF
  exit 0
fi

if [[ -z "$WOW_CLIENT" || ! -d "${WOW_CLIENT}/Data" ]]; then
  echo "Set WOW_CLIENT to a WoW install containing Data/" >&2
  exit 1
fi

if [[ -z "$AC_TOOLS_BIN" ]]; then
  echo "Set AC_TOOLS_BIN to the directory containing AzerothCore extractor binaries." >&2
  exit 1
fi

for tool in map_extractor vmap4_extractor vmap4_assembler; do
  if [[ ! -x "${AC_TOOLS_BIN}/${tool}" ]]; then
    echo "Missing tool: ${AC_TOOLS_BIN}/${tool}" >&2
    exit 1
  fi
done

WORKDIR="$(mktemp -d)"
trap 'rm -rf "$WORKDIR"' EXIT

echo "Running extractors in ${WOW_CLIENT} ..."
(
  cd "$WOW_CLIENT"
  export PATH="${AC_TOOLS_BIN}:${PATH}"
  ./map_extractor
  mkdir -p Buildings vmaps
  ./vmap4_extractor
  ./vmap4_assembler Buildings vmaps
  rm -rf Buildings
  if [[ "$SKIP_MMAPS" -eq 0 && -x "${AC_TOOLS_BIN}/mmaps_generator" ]]; then
    mkdir -p mmaps
    ./mmaps_generator
  fi
)

for component in dbc maps vmaps mmaps; do
  if [[ -d "${WOW_CLIENT}/${component}" ]]; then
    rsync -a "${WOW_CLIENT}/${component}/" "${DEST}/${component}/"
    echo "synced ${component} -> ${DEST}/${component}/"
  fi
done

echo "Server sources ready under ${DEST}/"
echo "Build a release with: client-patches/scripts/build-bundle.sh <version>"
