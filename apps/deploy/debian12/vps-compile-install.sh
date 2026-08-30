#!/usr/bin/env bash
# Configure, compile, and install AzerothCore to ACORE_STAGING (vps-build workflow).
set -euo pipefail

: "${GITHUB_WORKSPACE:?GITHUB_WORKSPACE required}"
: "${BUILD_DIR:?set BUILD_DIR}"
: "${ACORE_STAGING:?set ACORE_STAGING}"
: "${ACORE_PREFIX:?set ACORE_PREFIX}"

if [[ ! -f "${GITHUB_WORKSPACE}/CMakeLists.txt" ]]; then
  echo "No CMakeLists.txt in ${GITHUB_WORKSPACE}." >&2
  echo "The VPS runner workdir was likely left in sparse-checkout mode by deploy-vps." >&2
  ls -la "${GITHUB_WORKSPACE}" >&2
  exit 1
fi

CC="${CC:-gcc}"
CXX="${CXX:-g++}"

# CONF_DIR is compiled into the binary (module configs). For builds that will be
# promoted on the VPS, always use the remote prefix etc path — never the local
# ~/.cache/... path.
if [[ -n "${REMOTE_CONF_DIR:-}" ]]; then
  CONF_DIR_VALUE="${REMOTE_CONF_DIR}"
elif [[ "${ACORE_PREFIX}" == /home/acore/* ]]; then
  CONF_DIR_VALUE="${ACORE_PREFIX}/etc"
elif [[ "${ACORE_PREFIX}" == *prefix-test ]]; then
  CONF_DIR_VALUE="/home/acore/server-test/etc"
elif [[ "${ACORE_PREFIX}" == *prefix-live ]]; then
  CONF_DIR_VALUE="/home/acore/server/etc"
else
  CONF_DIR_VALUE="${ACORE_PREFIX}/etc"
fi

echo "CONF_DIR=${CONF_DIR_VALUE} (install prefix=${ACORE_STAGING})"

cmake -S "${GITHUB_WORKSPACE}" -B "${BUILD_DIR}" \
  -DCMAKE_C_COMPILER="${CC}" \
  -DCMAKE_CXX_COMPILER="${CXX}" \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo \
  -DCMAKE_INSTALL_PREFIX="${ACORE_STAGING}" \
  -DCONF_DIR="${CONF_DIR_VALUE}" \
  -DAPPS_BUILD=all \
  -DTOOLS_BUILD=none \
  -DSCRIPTS=static \
  -DMODULES=static

cmake --build "${BUILD_DIR}" --config RelWithDebInfo -j "$(($(nproc) + 2))"

rm -rf "${ACORE_STAGING}"
cmake --install "${BUILD_DIR}" --config RelWithDebInfo
test -x "${ACORE_STAGING}/bin/authserver"
test -x "${ACORE_STAGING}/bin/worldserver"
