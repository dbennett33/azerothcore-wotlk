#!/usr/bin/env bash
# Snapshot live etc/, MySQL, and run-engine service configs for disaster recovery.
# Run as acore on the VPS (or sudo -u acore). Store the output off the server.
set -euo pipefail

ACORE_USER="${ACORE_USER:-acore}"
ACORE_HOME="${ACORE_HOME:-/home/${ACORE_USER}}"
ACORE_PREFIX="${ACORE_PREFIX:-${ACORE_HOME}/server}"
BACKUP_ROOT="${BACKUP_ROOT:-${ACORE_HOME}/backups}"
ENV_FILE="${ENV_FILE:-${ACORE_HOME}/.acore-backup.env}"
INCLUDE_DATA_DBC="${INCLUDE_DATA_DBC:-0}"

if [[ "$(id -un)" != "$ACORE_USER" ]]; then
  echo "run as ${ACORE_USER}: sudo -u ${ACORE_USER} bash $0" >&2
  exit 1
fi

if [[ -f "$ENV_FILE" ]]; then
  # shellcheck disable=SC1090
  source "$ENV_FILE"
fi

MYSQL_USER="${MYSQL_USER:-acore}"
MYSQL_PASS="${MYSQL_PASS:-}"
MYSQL_HOST="${MYSQL_HOST:-127.0.0.1}"

if [[ -z "$MYSQL_PASS" ]]; then
  echo "Set MYSQL_PASS in ${ENV_FILE} (see .acore-backup.env.example)." >&2
  exit 1
fi

timestamp="$(date -u +%Y%m%dT%H%M%SZ)"
dest="${BACKUP_ROOT}/${timestamp}"
mkdir -p "$dest/mysql"

echo "Backing up to ${dest}"

tar czf "${dest}/etc.tar.gz" -C "${ACORE_PREFIX}" etc

mysqldump -h "$MYSQL_HOST" -u "$MYSQL_USER" -p"$MYSQL_PASS" \
  --single-transaction --routines --triggers \
  acore_auth acore_characters acore_world acore_playerbots \
  >"${dest}/mysql/all-databases.sql"

if [[ -d "${ACORE_HOME}/.config/azerothcore/services" ]]; then
  tar czf "${dest}/run-engine-services.tar.gz" \
    -C "${ACORE_HOME}/.config/azerothcore" services
fi

if [[ "$INCLUDE_DATA_DBC" == "1" && -d "${ACORE_PREFIX}/data/dbc" ]]; then
  tar czf "${dest}/data-dbc.tar.gz" -C "${ACORE_PREFIX}/data" dbc
fi

if [[ -f "${ACORE_PREFIX}/etc/.vanilla-optional-applied" ]]; then
  cp -a "${ACORE_PREFIX}/etc/.vanilla-optional-applied" "${dest}/"
fi

if [[ -f "${ACORE_HOME}/server-staging/.build-info" ]]; then
  cp -a "${ACORE_HOME}/server-staging/.build-info" "${dest}/staging.build-info"
fi

{
  echo "timestamp=${timestamp}"
  echo "hostname=$(hostname)"
  echo "acore_prefix=${ACORE_PREFIX}"
  if command -v git >/dev/null 2>&1 && [[ -d "${ACORE_HOME}/src/azerothcore-wotlk/.git" ]]; then
    echo "acore_sha=$(git -C "${ACORE_HOME}/src/azerothcore-wotlk" rev-parse HEAD 2>/dev/null || true)"
  fi
} >"${dest}/manifest.txt"

tar czf "${BACKUP_ROOT}/acore-backup-${timestamp}.tar.gz" -C "${BACKUP_ROOT}" "${timestamp}"
echo "Created ${BACKUP_ROOT}/acore-backup-${timestamp}.tar.gz"
echo "Copy this file off the VPS (S3, rsync, etc.)."
