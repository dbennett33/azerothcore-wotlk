#!/usr/bin/env bash
# Apply a published client patch bundle's server data overlay to a realm prefix.
set -euo pipefail

ACORE_USER="${ACORE_USER:-acore}"
ACORE_HOME="${ACORE_HOME:-/home/${ACORE_USER}}"
PATCHES_ROOT="${PATCHES_ROOT:-${ACORE_HOME}/client-patches}"
ACORE_PREFIX="${ACORE_PREFIX:-${ACORE_HOME}/server}"
DRY_RUN=0
PREFLIGHT=0
FORCE=0
FROM_MANIFEST=""
VERSION=""

require_cmd() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Missing required command: ${cmd}" >&2
    exit 1
  fi
}

usage() {
  cat <<'EOF'
Usage: apply-server-data.sh [version] [options]

Arguments:
  version     Release version (default: current symlink — emergency only)

Environment:
  ACORE_PREFIX   Server prefix containing data/ and etc/ (default: /home/acore/server)
  PATCHES_ROOT   VPS patch store (default: /home/acore/client-patches)
  REPO_ROOT      Checkout with client-patches/scripts/validate-manifest.sh

Options:
  --from-manifest PATH   Use version from a git client-patches/manifest.json
                         Placeholder 0.0.0: no-op. Git checksums must match the store.
  --preflight            Check the VPS store has that release; do not apply
  --force                Re-apply even if etc/.client-patch-version already matches
  --dry-run              Show actions without applying changes
EOF
}

realm_current_link() {
  case "$ACORE_PREFIX" in
    */server-test)
      printf '%s/current-test' "$PATCHES_ROOT"
      ;;
    */server)
      printf '%s/current-live' "$PATCHES_ROOT"
      ;;
    *)
      printf ''
      ;;
  esac
}

manifest_identity() {
  jq -c '{
    version,
    client_cache_version,
    locale: .client.locale,
    patches: [.client.patches[] | {file, sha256, size, install_path}] | sort_by(.file),
    server: {archive: .server.archive, sha256: .server.sha256, size: .server.size, components: .server.components}
  }' "$1"
}

assert_git_matches_store() {
  local git_manifest="$1"
  local store_manifest="$2"
  local git_id store_id
  git_id="$(manifest_identity "$git_manifest")"
  store_id="$(manifest_identity "$store_manifest")"
  if [[ "$git_id" != "$store_id" ]]; then
    echo "Git manifest does not match VPS store release ${VERSION}." >&2
    echo "Publish the bundle that matches this commit, or commit the store's manifest.json." >&2
    echo "  git:   ${git_id}" >&2
    echo "  store: ${store_id}" >&2
    exit 1
  fi
}

point_realm_current() {
  local link
  link="$(realm_current_link)"
  if [[ -z "$link" ]]; then
    return 0
  fi
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "would point ${link} -> releases/${VERSION}"
    return 0
  fi
  ln -sfn "releases/${VERSION}" "$link"
  echo "Realm client pointer: ${link} -> releases/${VERSION}"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --from-manifest)
      FROM_MANIFEST="${2:?--from-manifest requires a path}"
      shift 2
      ;;
    --preflight)
      PREFLIGHT=1
      shift
      ;;
    --force)
      FORCE=1
      shift
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      VERSION="$1"
      shift
      ;;
  esac
done

if [[ "$(id -un)" != "$ACORE_USER" ]]; then
  echo "run as ${ACORE_USER}: sudo -u ${ACORE_USER} bash $0 $*" >&2
  exit 1
fi

require_cmd python3
require_cmd jq

if [[ -n "$FROM_MANIFEST" ]]; then
  if [[ ! -f "$FROM_MANIFEST" ]]; then
    echo "Git manifest not found: ${FROM_MANIFEST}" >&2
    exit 1
  fi
  VERSION="$(jq -r '.version' "$FROM_MANIFEST")"
  if [[ "$VERSION" == "0.0.0" ]]; then
    echo "Git manifest ${FROM_MANIFEST} is placeholder 0.0.0; skipping client-patch apply."
    exit 0
  fi
fi

if [[ -z "$VERSION" ]]; then
  if [[ -L "${PATCHES_ROOT}/current" ]]; then
    VERSION="$(basename "$(readlink -f "${PATCHES_ROOT}/current")")"
  else
    echo "No version specified and ${PATCHES_ROOT}/current is missing" >&2
    exit 1
  fi
fi

RELEASE_DIR="${PATCHES_ROOT}/releases/${VERSION}"
MANIFEST="${RELEASE_DIR}/manifest.json"
DATA_DIR="${ACORE_PREFIX}/data"
STATE_FILE="${ACORE_PREFIX}/etc/.client-patch-version"

if [[ ! -f "$MANIFEST" ]]; then
  echo "Release ${VERSION} is not in the VPS store (${RELEASE_DIR})." >&2
  echo "Publish the bundle with publish-to-vps.sh, then redeploy this branch." >&2
  exit 1
fi

if [[ -n "$FROM_MANIFEST" ]]; then
  assert_git_matches_store "$FROM_MANIFEST" "$MANIFEST"
fi

if [[ "$PREFLIGHT" -eq 1 ]]; then
  if [[ -n "$FROM_MANIFEST" ]]; then
    echo "Client patch ${VERSION} is in the VPS store (${RELEASE_DIR}) and matches git."
  else
    echo "Client patch ${VERSION} is in the VPS store (${RELEASE_DIR})"
  fi
  exit 0
fi

# Keep realm current-* in sync even when the overlay is already applied.
if [[ "$FORCE" -eq 0 && -f "$STATE_FILE" && "$(cat "$STATE_FILE")" == "$VERSION" ]]; then
  echo "Prefix ${ACORE_PREFIX} already has client patch ${VERSION}; skipping overlay."
  point_realm_current
  exit 0
fi

require_cmd tar

REPO_VALIDATE="${REPO_ROOT:-/home/acore/src/azerothcore-wotlk}/client-patches/scripts/validate-manifest.sh"
if [[ -x "$REPO_VALIDATE" ]]; then
  "$REPO_VALIDATE" "$MANIFEST" "$RELEASE_DIR"
else
  echo "warning: validate-manifest.sh not found; skipping checksum validation"
fi

server_size="$(jq -r '.server.size' "$MANIFEST")"
server_sha="$(jq -r '.server.sha256' "$MANIFEST")"
server_archive="$(jq -r '.server.archive' "$MANIFEST")"
cache_version="$(jq -r '.client_cache_version' "$MANIFEST")"

if [[ "$server_size" == "0" || -z "$server_sha" ]]; then
  echo "Release ${VERSION} has no server data archive; skipping data overlay."
else
  archive_path="${RELEASE_DIR}/server/${server_archive}"
  if [[ ! -f "$archive_path" ]]; then
    echo "Missing server archive: ${archive_path}" >&2
    exit 1
  fi

  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "would extract ${archive_path} into ${DATA_DIR}"
  else
    mkdir -p "$DATA_DIR"
    tar -xzf "$archive_path" -C "$DATA_DIR"
    echo "Applied server data overlay from ${VERSION} to ${DATA_DIR}"
  fi
fi

WS_CONF="${ACORE_PREFIX}/etc/worldserver.conf"
if [[ -f "$WS_CONF" && "$cache_version" != "0" ]]; then
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "would set ClientCacheVersion = ${cache_version} in ${WS_CONF}"
  else
    if grep -q '^ClientCacheVersion' "$WS_CONF"; then
      sed -i "s|^ClientCacheVersion = .*|ClientCacheVersion = ${cache_version}|" "$WS_CONF"
    else
      echo "ClientCacheVersion = ${cache_version}" >>"$WS_CONF"
    fi
    echo "Set ClientCacheVersion = ${cache_version}"
  fi
fi

if [[ "$DRY_RUN" -eq 0 ]]; then
  mkdir -p "$(dirname "$STATE_FILE")"
  echo "$VERSION" >"$STATE_FILE"
  {
    echo "version=${VERSION}"
    echo "applied_at=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "acore_prefix=${ACORE_PREFIX}"
  } >>"${ACORE_PREFIX}/etc/.client-patch-applied.log"
  echo "Recorded applied version in ${STATE_FILE}"
fi

point_realm_current
