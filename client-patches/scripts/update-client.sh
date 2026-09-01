#!/usr/bin/env bash
# Download and install client MPQ patches for a local WoW 3.3.5a install.
#
# Usage:
#   WOW_DIR=/path/to/WoW PATCHES_BASE_URL=https://example.com/client-patches/current ./update-client.sh
#   ./update-client.sh --wow-dir /path/to/WoW --from-vps acore@your.vps
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "${SCRIPT_DIR}/lib.sh"

PATCHES_BASE_URL="${PATCHES_BASE_URL:-}"
WOW_DIR="${WOW_DIR:-}"
FROM_VPS="${FROM_VPS:-}"
VERSION="${VERSION:-}"
DRY_RUN=0
LOCALE=""

usage() {
  cat <<'EOF'
Usage: update-client.sh [options]

Options:
  --wow-dir PATH          WoW install root (contains Data/)
  --patches-url URL       Base URL to a release directory (must contain manifest.json)
  --from-vps USER@HOST    Fetch from /home/acore/client-patches/current on the VPS via scp
  --version VERSION       Release version (with --from-vps; default: current symlink target)
  --locale LOCALE         Override locale from manifest
  --dry-run               Show actions without writing files
  -h, --help              Show help

Environment:
  WOW_DIR, PATCHES_BASE_URL, FROM_VPS, VERSION
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --wow-dir)
      WOW_DIR="$2"
      shift 2
      ;;
    --patches-url)
      PATCHES_BASE_URL="$2"
      shift 2
      ;;
    --from-vps)
      FROM_VPS="$2"
      shift 2
      ;;
    --version)
      VERSION="$2"
      shift 2
      ;;
    --locale)
      LOCALE="$2"
      shift 2
      ;;
    --dry-run)
      DRY_RUN=1
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

require_cmd python3
require_cmd jq

if [[ -z "$WOW_DIR" ]]; then
  echo "Set WOW_DIR or pass --wow-dir" >&2
  exit 1
fi

if [[ ! -d "${WOW_DIR}/Data" ]]; then
  echo "WoW Data/ directory not found under ${WOW_DIR}" >&2
  exit 1
fi

WORKDIR="$(mktemp -d)"
trap 'rm -rf "$WORKDIR"' EXIT

MANIFEST_LOCAL="${WORKDIR}/manifest.json"

if [[ -n "$FROM_VPS" ]]; then
  require_cmd scp
  remote_base="/home/acore/client-patches"
  if [[ -n "$VERSION" ]]; then
    remote_release="${remote_base}/releases/${VERSION}"
  else
    remote_release="${remote_base}/current"
  fi
  scp -q "${FROM_VPS}:${remote_release}/manifest.json" "$MANIFEST_LOCAL"
  mkdir -p "${WORKDIR}/client"
  mapfile -t remote_files < <(jq -r '.client.patches[].file' "$MANIFEST_LOCAL")
  for file in "${remote_files[@]}"; do
    [[ -z "$file" || "$file" == "null" ]] && continue
    scp -q "${FROM_VPS}:${remote_release}/client/${file}" "${WORKDIR}/client/${file}"
  done
elif [[ -n "$PATCHES_BASE_URL" ]]; then
  download_file "${PATCHES_BASE_URL%/}/manifest.json" "$MANIFEST_LOCAL"
  mkdir -p "${WORKDIR}/client"
  while IFS=$'\t' read -r file sha; do
    [[ -z "$file" || "$file" == "null" ]] && continue
    dest="${WORKDIR}/client/${file}"
    download_file "${PATCHES_BASE_URL%/}/client/${file}" "$dest"
    verify_sha256 "$dest" "$sha"
  done < <(jq -r '.client.patches[] | [.file, .sha256] | @tsv' "$MANIFEST_LOCAL")
else
  echo "Set PATCHES_BASE_URL or --from-vps" >&2
  exit 1
fi

"${SCRIPT_DIR}/validate-manifest.sh" "$MANIFEST_LOCAL" "${WORKDIR}"

manifest_locale="$(jq -r '.client.locale' "$MANIFEST_LOCAL")"
LOCALE="${LOCALE:-$manifest_locale}"
TARGET_VERSION="$(jq -r '.version' "$MANIFEST_LOCAL")"
STATE_FILE="${WOW_DIR}/.acore-client-patch-version"

if [[ -f "$STATE_FILE" ]] && [[ "$(cat "$STATE_FILE")" == "$TARGET_VERSION" ]]; then
  echo "Client already at patch version ${TARGET_VERSION}"
  exit 0
fi

install_one() {
  local src="$1"
  local rel_path="$2"
  local dest="${WOW_DIR}/${rel_path}"
  mkdir -p "$(dirname "$dest")"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "would install ${src} -> ${dest}"
  else
    cp -a "$src" "$dest"
    echo "installed ${dest}"
  fi
}

while IFS=$'\t' read -r file install_path; do
  [[ -z "$file" || "$file" == "null" ]] && continue
  install_one "${WORKDIR}/client/${file}" "$install_path"
done < <(jq -r '.client.patches[] | [.file, .install_path] | @tsv' "$MANIFEST_LOCAL")

if [[ "$DRY_RUN" -eq 0 ]]; then
  echo "$TARGET_VERSION" >"$STATE_FILE"
  echo "Client patch version set to ${TARGET_VERSION}"
  cache_version="$(jq -r '.client_cache_version' "$MANIFEST_LOCAL")"
  echo "Server ClientCacheVersion for this release: ${cache_version}"
fi
