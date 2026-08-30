#!/usr/bin/env bash
# Restore etc/ and MySQL from a backup-acore snapshot. Does not install client data or binaries.
set -euo pipefail

ACORE_USER="${ACORE_USER:-acore}"
ACORE_HOME="${ACORE_HOME:-/home/${ACORE_USER}}"
ACORE_PREFIX="${ACORE_PREFIX:-${ACORE_HOME}/server}"
ENV_FILE="${ENV_FILE:-${ACORE_HOME}/.acore-backup.env}"

usage() {
  echo "Usage: $0 <backup-dir-or-acore-backup.tar.gz>" >&2
  echo "  backup-dir: ${BACKUP_ROOT:-/home/acore/backups}/YYYYMMDDTHHMMSSZ" >&2
  exit 1
}

[[ $# -eq 1 ]] || usage

if [[ "$(id -un)" != "$ACORE_USER" ]]; then
  echo "run as ${ACORE_USER}: sudo -u ${ACORE_USER} bash $0 ..." >&2
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
  echo "Set MYSQL_PASS in ${ENV_FILE}." >&2
  exit 1
fi

src="$1"
work=""
cleanup() {
  [[ -n "$work" && -d "$work" ]] && rm -rf "$work"
}
trap cleanup EXIT

if [[ -f "$src" ]]; then
  work="$(mktemp -d)"
  tar xzf "$src" -C "$work"
  # tarball contains one top-level timestamp directory
  src="$(find "$work" -mindepth 1 -maxdepth 1 -type d | head -1)"
  [[ -d "$src" ]] || { echo "invalid backup archive" >&2; exit 1; }
fi

[[ -f "${src}/etc.tar.gz" ]] || { echo "missing etc.tar.gz in ${src}" >&2; exit 1; }
[[ -f "${src}/mysql/all-databases.sql" ]] || { echo "missing mysql dump in ${src}" >&2; exit 1; }

if [[ -x "${ACORE_HOME}/deploy/restart-acore.sh" ]]; then
  "${ACORE_HOME}/deploy/restart-acore.sh" stop || true
fi

echo "Restoring ${ACORE_PREFIX}/etc from backup..."
rm -rf "${ACORE_PREFIX}/etc"
mkdir -p "${ACORE_PREFIX}/etc"
tar xzf "${src}/etc.tar.gz" -C "${ACORE_PREFIX}"

if [[ -f "${src}/run-engine-services.tar.gz" ]]; then
  mkdir -p "${ACORE_HOME}/.config/azerothcore"
  tar xzf "${src}/run-engine-services.tar.gz" -C "${ACORE_HOME}/.config/azerothcore"
fi

if [[ -f "${src}/.vanilla-optional-applied" ]]; then
  cp -a "${src}/.vanilla-optional-applied" "${ACORE_PREFIX}/etc/"
fi

echo "Restoring MySQL databases..."
mysql -h "$MYSQL_HOST" -u "$MYSQL_USER" -p"$MYSQL_PASS" <"${src}/mysql/all-databases.sql"

if [[ -f "${src}/data-dbc.tar.gz" && -d "${ACORE_PREFIX}/data" ]]; then
  echo "Restoring data/dbc..."
  tar xzf "${src}/data-dbc.tar.gz" -C "${ACORE_PREFIX}/data"
fi

if [[ -f "${src}/manifest.txt" ]]; then
  cat "${src}/manifest.txt"
fi

echo "Restore complete. Run deploy-vps (or copy bin/) and restart services."
