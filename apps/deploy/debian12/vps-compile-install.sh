#!/usr/bin/env bash
# Configure, compile, and install AzerothCore to ACORE_STAGING (vps-build workflow).
set -euo pipefail

: "${GITHUB_WORKSPACE:?GITHUB_WORKSPACE required}"
: "${BUILD_DIR:?set BUILD_DIR}"
: "${ACORE_STAGING:?set ACORE_STAGING}"
: "${ACORE_PREFIX:?set ACORE_PREFIX}"

CC="${CC:-gcc}"
CXX="${CXX:-g++}"

cmake -S "${GITHUB_WORKSPACE}" -B "${BUILD_DIR}" \
  -DCMAKE_C_COMPILER="${CC}" \
  -DCMAKE_CXX_COMPILER="${CXX}" \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo \
  -DCMAKE_INSTALL_PREFIX="${ACORE_STAGING}" \
  -DCONF_DIR="${ACORE_PREFIX}/etc" \
  -DAPPS_BUILD=all \
  -DTOOLS_BUILD=none \
  -DSCRIPTS=static \
  -DMODULES=static

cmake --build "${BUILD_DIR}" --config RelWithDebInfo -j "$(($(nproc) + 2))"

rm -rf "${ACORE_STAGING}"
cmake --install "${BUILD_DIR}" --config RelWithDebInfo
test -x "${ACORE_STAGING}/bin/authserver"
test -x "${ACORE_STAGING}/bin/worldserver"
