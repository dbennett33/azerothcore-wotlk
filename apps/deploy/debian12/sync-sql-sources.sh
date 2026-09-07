#!/usr/bin/env bash
# Copy data/sql from a git checkout into a realm SourceDirectory.
# Worldserver applies pending_* SQL from SourceDirectory on start. Live and test
# must not share one stale clone or a test deploy would arm live pending files.
set -euo pipefail

CHECKOUT="${1:?usage: sync-sql-sources.sh <checkout-root> <source-directory>}"
SOURCE_DIR="${2:?}"

if [[ ! -d "${CHECKOUT}/data/sql" ]]; then
  echo "Missing ${CHECKOUT}/data/sql" >&2
  exit 1
fi

mkdir -p "${SOURCE_DIR}/data/sql"
rsync -a --delete "${CHECKOUT}/data/sql/" "${SOURCE_DIR}/data/sql/"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
mkdir -p "${SOURCE_DIR}/modules"
CLONE_UPDATER_MODULES=1 \
  PLAYERBOTS_REF="${PLAYERBOTS_REF:-master}" \
  bash "${SCRIPT_DIR}/clone-extra-modules.sh" "${SOURCE_DIR}/modules"

echo "Synced SQL sources ${CHECKOUT}/data/sql -> ${SOURCE_DIR}"
