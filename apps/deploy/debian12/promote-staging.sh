#!/usr/bin/env bash
# Promote ACORE_STAGING/bin (+ optional etc) into ACORE_PREFIX. Used by deploy-vps.
set -euo pipefail

ACORE_PREFIX="${ACORE_PREFIX:?set ACORE_PREFIX}"
ACORE_STAGING="${ACORE_STAGING:?set ACORE_STAGING}"

if [[ ! -x "${ACORE_STAGING}/bin/worldserver" ]]; then
  echo "Missing ${ACORE_STAGING}/bin/worldserver" >&2
  exit 1
fi

mkdir -p "${ACORE_PREFIX}"
staging_bin="${ACORE_STAGING}/bin"
live_bin="${ACORE_PREFIX}/bin"
new_bin="${ACORE_PREFIX}/bin.new"
old_bin="${ACORE_PREFIX}/bin.old"

rm -rf "${new_bin}"
mkdir -p "${new_bin}"
rsync -a --delete "${staging_bin}/" "${new_bin}/"

if [[ -d "${live_bin}" ]]; then
  rm -rf "${old_bin}"
  mv "${live_bin}" "${old_bin}"
fi
mv "${new_bin}" "${live_bin}"

if [[ -d "${ACORE_STAGING}/etc" ]]; then
  mkdir -p "${ACORE_PREFIX}/etc"
  rsync -a --ignore-existing "${ACORE_STAGING}/etc/" "${ACORE_PREFIX}/etc/"
fi

if [[ -f "${ACORE_STAGING}/.build-info" ]]; then
  cp -a "${ACORE_STAGING}/.build-info" "${ACORE_PREFIX}/.build-info"
fi

echo "Promoted ${ACORE_STAGING} -> ${ACORE_PREFIX}/bin"
