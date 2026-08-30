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

# On UNIX, cmake install(FILES ...) writes *.conf.dist into CONF_DIR. When the build VM
# embeds the VPS etc path in binaries, that same path must still exist locally for install.
ensure_conf_dir_for_install() {
  local modules_dir="${CONF_DIR_VALUE}/modules"
  if [[ -d "${modules_dir}" ]]; then
    return 0
  fi
  echo "Creating CONF_DIR install tree at ${modules_dir}"
  if mkdir -p "${modules_dir}"; then
    return 0
  fi
  if sudo -n install -d -o "$(id -un)" -g "$(id -gn)" -m 755 "${modules_dir}" 2>/dev/null; then
    return 0
  fi
  echo "ERROR: cannot create ${modules_dir} (cmake install needs a writable CONF_DIR)." >&2
  echo "On build VM run:" >&2
  echo "  sudo install -d -o $(id -un) -g $(id -gn) ${modules_dir}" >&2
  exit 1
}

if [[ "${CONF_DIR_VALUE}" == /home/acore/* ]] && [[ ! -d /home/acore/server || "$(id -un)" != "acore" ]]; then
  ensure_conf_dir_for_install
fi

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
