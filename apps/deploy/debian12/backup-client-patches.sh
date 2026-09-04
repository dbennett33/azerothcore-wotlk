#!/usr/bin/env bash
# Snapshot /home/acore/client-patches/releases for offsite backup.
# Run as acore on the VPS. Copy the output tarball off the server.
set -euo pipefail

ACORE_USER="${ACORE_USER:-acore}"
ACORE_HOME="${ACORE_HOME:-/home/${ACORE_USER}}"
PATCHES_ROOT="${PATCHES_ROOT:-${ACORE_HOME}/client-patches}"
BACKUP_ROOT="${BACKUP_ROOT:-${ACORE_HOME}/backups}"

if [[ "$(id -un)" != "$ACORE_USER" ]]; then
  echo "run as ${ACORE_USER}: sudo -u ${ACORE_USER} bash $0" >&2
  exit 1
fi

if [[ ! -d "${PATCHES_ROOT}/releases" ]]; then
  echo "No releases directory at ${PATCHES_ROOT}/releases" >&2
  exit 1
fi

timestamp="$(date -u +%Y%m%dT%H%M%SZ)"
dest="${BACKUP_ROOT}/client-patches-${timestamp}.tar.gz"

mkdir -p "$BACKUP_ROOT"
tar czf "$dest" -C "$PATCHES_ROOT" releases current current-test current-live 2>/dev/null \
  || tar czf "$dest" -C "$PATCHES_ROOT" releases current 2>/dev/null \
  || tar czf "$dest" -C "$PATCHES_ROOT" releases

{
  echo "timestamp=${timestamp}"
  echo "patches_root=${PATCHES_ROOT}"
  for link in current current-test current-live; do
    if [[ -L "${PATCHES_ROOT}/${link}" ]]; then
      echo "${link}=$(readlink -f "${PATCHES_ROOT}/${link}")"
    fi
  done
} >"${BACKUP_ROOT}/client-patches-${timestamp}.manifest.txt"

echo "Created ${dest}"
echo "Manifest: ${BACKUP_ROOT}/client-patches-${timestamp}.manifest.txt"
echo "Copy this tarball off the VPS (rsync, S3, etc.)."
