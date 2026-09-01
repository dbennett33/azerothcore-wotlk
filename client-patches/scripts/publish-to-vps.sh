#!/usr/bin/env bash
# Upload a local bundle directory to the VPS patch store and publish it.
#
# Usage (from your dev machine):
#   VPS_HOST=acore@your.vps ./publish-to-vps.sh client-patches/bundles/1.0.0
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: publish-to-vps.sh <bundle-dir>" >&2
  exit 1
fi

BUNDLE_DIR="$1"
VPS_HOST="${VPS_HOST:-}"
REMOTE_REPO="${REMOTE_REPO:-/home/acore/src/azerothcore-wotlk}"

if [[ -z "$VPS_HOST" ]]; then
  echo "Set VPS_HOST (e.g. acore@203.0.113.10)" >&2
  exit 1
fi

if [[ ! -d "$BUNDLE_DIR" || ! -f "${BUNDLE_DIR}/manifest.json" ]]; then
  echo "Bundle directory not found: ${BUNDLE_DIR}" >&2
  exit 1
fi

VERSION="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["version"])' "${BUNDLE_DIR}/manifest.json")"
REMOTE_STAGING="/home/acore/client-patches/staging/${VERSION}"

echo "Uploading bundle ${VERSION} to ${VPS_HOST}:${REMOTE_STAGING} ..."
ssh "$VPS_HOST" "mkdir -p '${REMOTE_STAGING}'"
rsync -av --delete "${BUNDLE_DIR}/" "${VPS_HOST}:${REMOTE_STAGING}/"

echo "Publishing on VPS ..."
ssh "$VPS_HOST" "bash ${REMOTE_REPO}/apps/deploy/debian12/client-patches/publish-client-patches.sh '${REMOTE_STAGING}'"

echo "Done. Deploy server data with deploy-client-patches workflow or:"
echo "  ssh ${VPS_HOST} 'ACORE_PREFIX=/home/acore/server bash ${REMOTE_REPO}/apps/deploy/debian12/client-patches/apply-server-data.sh ${VERSION}'"
