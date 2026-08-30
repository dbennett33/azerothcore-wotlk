#!/usr/bin/env bash
# Copy local ACORE_STAGING to the VPS staging path (after a local pool build).
set -euo pipefail

ACORE_STAGING="${ACORE_STAGING:?set ACORE_STAGING}"
REMOTE_STAGING="${REMOTE_STAGING:?set REMOTE_STAGING (e.g. /home/acore/server-staging-test)}"
VPS_HOST="${VPS_HOST:?set VPS_HOST (ssh target, e.g. user@host)}"
SSH_KEY_PATH="${SSH_KEY_PATH:-}"

if [[ ! -d "${ACORE_STAGING}/bin" ]]; then
  echo "Missing staged bin under ${ACORE_STAGING}" >&2
  exit 1
fi

ssh_cmd=(ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new)
if [[ -n "$SSH_KEY_PATH" && -f "$SSH_KEY_PATH" ]]; then
  ssh_cmd+=(-i "$SSH_KEY_PATH")
fi

rsync_cmd=(rsync -az --delete -e)
rsync_ssh="ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new"
if [[ -n "$SSH_KEY_PATH" && -f "$SSH_KEY_PATH" ]]; then
  rsync_ssh+=" -i ${SSH_KEY_PATH}"
fi

TMP="/tmp/acore-staging-sync-$$"
echo "Rsync local staging → ${VPS_HOST}:${REMOTE_STAGING}"

"${ssh_cmd[@]}" "${VPS_HOST}" "rm -rf '${TMP}' && mkdir -p '${TMP}'"

rsync -az --delete -e "${rsync_ssh}" "${ACORE_STAGING}/" "${VPS_HOST}:${TMP}/"

"${ssh_cmd[@]}" "${VPS_HOST}" bash -s <<REMOTE
set -euo pipefail
sudo mkdir -p "${REMOTE_STAGING}"
sudo rsync -a --delete "${TMP}/" "${REMOTE_STAGING}/"
sudo chown -R acore:acore "${REMOTE_STAGING}"
rm -rf "${TMP}"
echo "VPS staging updated: ${REMOTE_STAGING}"
REMOTE
