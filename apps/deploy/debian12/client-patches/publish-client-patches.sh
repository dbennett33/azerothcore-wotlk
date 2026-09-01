#!/usr/bin/env bash
# Copy a built bundle into the VPS canonical store (/home/acore/client-patches).
set -euo pipefail

ACORE_USER="${ACORE_USER:-acore}"
ACORE_HOME="${ACORE_HOME:-/home/${ACORE_USER}}"
PATCHES_ROOT="${PATCHES_ROOT:-${ACORE_HOME}/client-patches}"

if [[ $# -lt 1 ]]; then
  echo "Usage: publish-client-patches.sh <bundle-dir|version>" >&2
  echo "  bundle-dir  path to client-patches/bundles/<version>" >&2
  echo "  version     looks up client-patches/bundles/<version> from repo checkout" >&2
  exit 1
fi

INPUT="$1"
REPO_ROOT="${REPO_ROOT:-/home/acore/src/azerothcore-wotlk}"

resolve_bundle_dir() {
  local arg="$1"
  if [[ -d "$arg" && -f "${arg}/manifest.json" ]]; then
    printf '%s' "$(cd "$arg" && pwd)"
    return
  fi
  if [[ -d "${REPO_ROOT}/client-patches/bundles/${arg}" ]]; then
    printf '%s' "$(cd "${REPO_ROOT}/client-patches/bundles/${arg}" && pwd)"
    return
  fi
  echo "Bundle not found: ${arg}" >&2
  exit 1
}

if [[ "$(id -un)" != "$ACORE_USER" ]]; then
  echo "run as ${ACORE_USER}: sudo -u ${ACORE_USER} bash $0 $*" >&2
  exit 1
fi

BUNDLE_DIR="$(resolve_bundle_dir "$INPUT")"
VERSION="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["version"])' "${BUNDLE_DIR}/manifest.json")"
DEST="${PATCHES_ROOT}/releases/${VERSION}"

if [[ -e "$DEST" ]]; then
  echo "Release already exists: ${DEST}" >&2
  echo "Remove it first or publish a new version." >&2
  exit 1
fi

mkdir -p "${PATCHES_ROOT}/releases"
rsync -a --delete "${BUNDLE_DIR}/" "${DEST}/"

ln -sfn "releases/${VERSION}" "${PATCHES_ROOT}/current"

{
  echo "version=${VERSION}"
  echo "published_at=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "source_bundle=${BUNDLE_DIR}"
} >"${DEST}/.publish-info"

echo "Published client patch release ${VERSION}"
echo "  ${DEST}"
echo "  current -> ${PATCHES_ROOT}/current"
echo ""
echo "Deploy server data with:"
echo "  ACORE_PREFIX=/home/acore/server apps/deploy/debian12/client-patches/apply-server-data.sh ${VERSION}"
