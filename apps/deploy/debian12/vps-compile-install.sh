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
JOBS="$(($(nproc) + 2))"

# CONF_DIR is compiled into the binary (module configs). For builds that will be
# promoted on the VPS, always use the remote prefix etc path — never the local
# ~/.cache/... path.
if [[ -n "${REMOTE_CONF_DIR:-}" ]]; then
  RUNTIME_CONF_DIR="${REMOTE_CONF_DIR}"
elif [[ "${ACORE_PREFIX}" == /home/acore/* ]]; then
  RUNTIME_CONF_DIR="${ACORE_PREFIX}/etc"
elif [[ "${ACORE_PREFIX}" == *prefix-test ]]; then
  RUNTIME_CONF_DIR="/home/acore/server-test/etc"
elif [[ "${ACORE_PREFIX}" == *prefix-live ]]; then
  RUNTIME_CONF_DIR="/home/acore/server/etc"
else
  RUNTIME_CONF_DIR="${ACORE_PREFIX}/etc"
fi

# cmake install(FILES ...) writes *.conf.dist into CONF_DIR on UNIX. On the build VM
# that path is the VPS etc tree, which does not exist locally — install to staging instead.
if [[ "${RUNTIME_CONF_DIR}" == /home/acore/* ]] && [[ ! -d /home/acore/server || "$(id -un)" != "acore" ]]; then
  INSTALL_CONF_DIR="${ACORE_STAGING}/etc"
else
  INSTALL_CONF_DIR="${RUNTIME_CONF_DIR}"
fi

echo "CONF_DIR runtime=${RUNTIME_CONF_DIR} install=${INSTALL_CONF_DIR} (prefix=${ACORE_STAGING})"

run_cmake_configure() {
  local conf_dir="$1"
  cmake -S "${GITHUB_WORKSPACE}" -B "${BUILD_DIR}" \
    -DCMAKE_C_COMPILER="${CC}" \
    -DCMAKE_CXX_COMPILER="${CXX}" \
    -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    -DCMAKE_INSTALL_PREFIX="${ACORE_STAGING}" \
    -DCONF_DIR="${conf_dir}" \
    -DAPPS_BUILD=all \
    -DTOOLS_BUILD=none \
    -DSCRIPTS=static \
    -DMODULES=static
}

overlay_app_binaries() {
  local src="${BUILD_DIR}/bin"
  if [[ ! -x "${src}/worldserver" && -x "${BUILD_DIR}/bin/RelWithDebInfo/worldserver" ]]; then
    src="${BUILD_DIR}/bin/RelWithDebInfo"
  fi
  install -D "${src}/authserver" "${ACORE_STAGING}/bin/authserver"
  install -D "${src}/worldserver" "${ACORE_STAGING}/bin/worldserver"
}

if [[ "${INSTALL_CONF_DIR}" != "${RUNTIME_CONF_DIR}" ]]; then
  echo "Build host: full compile with install CONF_DIR, then relink apps with VPS CONF_DIR"
  run_cmake_configure "${INSTALL_CONF_DIR}"
  cmake --build "${BUILD_DIR}" --config RelWithDebInfo -j "${JOBS}"

  rm -rf "${ACORE_STAGING}"
  cmake --install "${BUILD_DIR}" --config RelWithDebInfo

  run_cmake_configure "${RUNTIME_CONF_DIR}"
  cmake --build "${BUILD_DIR}" --config RelWithDebInfo --target common authserver worldserver -j "${JOBS}"
  overlay_app_binaries
else
  run_cmake_configure "${RUNTIME_CONF_DIR}"
  cmake --build "${BUILD_DIR}" --config RelWithDebInfo -j "${JOBS}"

  rm -rf "${ACORE_STAGING}"
  cmake --install "${BUILD_DIR}" --config RelWithDebInfo
fi

test -x "${ACORE_STAGING}/bin/authserver"
test -x "${ACORE_STAGING}/bin/worldserver"
