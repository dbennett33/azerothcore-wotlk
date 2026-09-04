#!/usr/bin/env bash
# Extract server data (maps/vmaps/mmaps/dbc) from a WoW 3.3.5a install into sources/server/.
#
# Invokes the AzerothCore extractors from AC_TOOLS_BIN with explicit -i/-o/-d paths.
# Do not run them as ./map_extractor from the WoW directory — they are not there.
#
# Use a slim client copy (Blizzard base + locale + your patches) so unchanged
# continent maps are skipped. The server overlay is additive; overlaying a full
# extract would replace every continent file.
#
# Usage:
#   WOW_CLIENT=/path/to/WoW AC_TOOLS_BIN=/path/to/build/bin ./extract-server-data.sh
#   ./extract-server-data.sh --map 44 --skip-mmaps
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "${SCRIPT_DIR}/lib.sh"

REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
WOW_CLIENT="${WOW_CLIENT:-${WOW_DIR:-}}"
AC_TOOLS_BIN="${AC_TOOLS_BIN:-}"
DBC_ONLY=0
SKIP_MMAPS=0
ALL_MMAPS=0
declare -a MAP_IDS=()

usage() {
  cat <<'EOF'
Usage: extract-server-data.sh [options]

Environment:
  WOW_CLIENT      Path to WoW 3.3.5a install (must contain Data/)
  AC_TOOLS_BIN    Directory containing map_extractor, vmap4_extractor,
                  vmap4_assembler, mmaps_generator

Options:
  --dbc-only      Print DBC placement instructions only
  --skip-mmaps    Extract maps + vmaps but skip mmaps
  --map ID        Generate mmaps for this map id (repeatable). Without this,
                  mmaps are skipped unless --all-mmaps is set.
  --all-mmaps     Run mmaps_generator for every extracted map (slow)
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
    --all-mmaps)
      ALL_MMAPS=1
      shift
      ;;
    --map)
      MAP_IDS+=("$2")
      shift 2
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

Or run this script with WOW_CLIENT and AC_TOOLS_BIN set. Ship only the files
for maps/tiles you changed — the VPS overlay is additive.
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
EXTRACT_OUT="${WORKDIR}/out"
mkdir -p "$EXTRACT_OUT"

echo "Extracting maps + DBC from ${WOW_CLIENT} -> ${EXTRACT_OUT}"
"${AC_TOOLS_BIN}/map_extractor" -i "$WOW_CLIENT" -o "$EXTRACT_OUT" -e 3

echo "Extracting vmaps (Buildings wiped first) ..."
(
  cd "$EXTRACT_OUT"
  rm -rf Buildings
  mkdir -p Buildings vmaps
  "${AC_TOOLS_BIN}/vmap4_extractor" -d "${WOW_CLIENT}/Data/"
  "${AC_TOOLS_BIN}/vmap4_assembler" Buildings vmaps
  rm -rf Buildings
)

if [[ "$SKIP_MMAPS" -eq 0 ]]; then
  if [[ ${#MAP_IDS[@]} -eq 0 && "$ALL_MMAPS" -eq 0 ]]; then
    echo "note: skipping mmaps (pass --map ID or --all-mmaps)."
  elif [[ ! -x "${AC_TOOLS_BIN}/mmaps_generator" ]]; then
    echo "Missing tool: ${AC_TOOLS_BIN}/mmaps_generator" >&2
    exit 1
  else
    mkdir -p "${EXTRACT_OUT}/mmaps"
    config="${EXTRACT_OUT}/mmaps-config.yaml"
    cp "${REPO_ROOT}/src/tools/mmaps_generator/mmaps-config.yaml" "$config"
    echo "Generating mmaps ..."
    (
      cd "$EXTRACT_OUT"
      if [[ "$ALL_MMAPS" -eq 1 ]]; then
        "${AC_TOOLS_BIN}/mmaps_generator" --config "$config" --silent --threads "$(nproc)"
      else
        for map_id in "${MAP_IDS[@]}"; do
          "${AC_TOOLS_BIN}/mmaps_generator" --config "$config" --silent --threads "$(nproc)" "$map_id"
        done
      fi
    )
  fi
fi

for component in dbc maps vmaps mmaps; do
  if [[ -d "${EXTRACT_OUT}/${component}" ]]; then
    rsync -a "${EXTRACT_OUT}/${component}/" "${DEST}/${component}/"
    echo "synced ${component} -> ${DEST}/${component}/"
  fi
done

cat <<EOF
Server sources ready under ${DEST}/
Ship only the files for maps/tiles you changed before build-bundle.
Build a release with: client-patches/scripts/build-bundle.sh <version>
EOF
