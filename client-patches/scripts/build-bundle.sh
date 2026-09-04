#!/usr/bin/env bash
# Build a versioned client/server patch bundle from sources/.
#
# Usage:
#   ./build-bundle.sh <version> [--cache-version N] [--changelog "line1"]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "${SCRIPT_DIR}/lib.sh"

usage() {
  cat <<'EOF'
Usage: build-bundle.sh <version> [options]

Options:
  --cache-version N     ClientCacheVersion to publish (default: previous + 1)
  --locale LOCALE       Client locale folder (default: enUS)
  --changelog LINE      Repeatable changelog entry
  --skip-placeholder    Allow building when no client or server inputs exist
EOF
}

if [[ $# -lt 1 ]]; then
  usage >&2
  exit 1
fi

VERSION="$1"
shift

CACHE_VERSION=""
LOCALE="enUS"
declare -a CHANGELOG=()
SKIP_PLACEHOLDER=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --cache-version)
      CACHE_VERSION="$2"
      shift 2
      ;;
    --locale)
      LOCALE="$2"
      shift 2
      ;;
    --changelog)
      CHANGELOG+=("$2")
      shift 2
      ;;
    --skip-placeholder)
      SKIP_PLACEHOLDER=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

require_cmd python3
require_cmd jq
require_cmd tar

SOURCES="${CLIENT_PATCHES_ROOT}/sources"
OUT_DIR="$(bundle_dir_for_version "$VERSION")"
OUT_CLIENT="${OUT_DIR}/client"
OUT_SERVER="${OUT_DIR}/server"
mkdir -p "$OUT_CLIENT" "$OUT_SERVER"

rm -f "${OUT_CLIENT}/"*.MPQ "${OUT_CLIENT}/"*.mpq 2>/dev/null || true

shopt -s nullglob
client_mpqs=("${SOURCES}/client/mpq/"*.MPQ "${SOURCES}/client/mpq/"*.mpq)
shopt -u nullglob

server_components=()
for component in dbc maps vmaps mmaps; do
  if [[ -d "${SOURCES}/server/${component}" ]] && [[ -n "$(ls -A "${SOURCES}/server/${component}" 2>/dev/null || true)" ]]; then
    server_components+=("$component")
  fi
done

if [[ ${#client_mpqs[@]} -eq 0 && ${#server_components[@]} -eq 0 ]]; then
  if [[ "$SKIP_PLACEHOLDER" -eq 0 ]]; then
    echo "No inputs found under ${SOURCES}/client/mpq or ${SOURCES}/server/*" >&2
    echo "Add MPQ files or server data before building." >&2
    exit 1
  fi
fi

if [[ -d "${SOURCES}/client/loose" ]] && [[ -n "$(find "${SOURCES}/client/loose" -type f 2>/dev/null | head -1 || true)" ]]; then
  echo "note: loose client files found. Pack them into sources/client/mpq/ with an MPQ editor."
  echo "      See docs/client-patches.md"
fi

patch_json="[]"
if [[ ${#client_mpqs[@]} -gt 0 ]]; then
  patch_json="$(python3 - "$LOCALE" "${client_mpqs[@]}" <<'PY'
import json
import os
import sys

locale = sys.argv[1]
paths = sys.argv[2:]

def sha256_file(path: str) -> str:
    import hashlib
    digest = hashlib.sha256()
    with open(path, "rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()

def install_path(filename: str) -> str:
    lower = filename.lower()
    loc = locale.lower()
    if f"patch-{loc}" in lower or f"locale-{loc}" in lower:
        return f"Data/{locale}/{filename}"
    return f"Data/{filename}"

entries = []
for src in paths:
    base = os.path.basename(src)
    entries.append({
        "file": base,
        "sha256": sha256_file(src),
        "size": os.path.getsize(src),
        "install_path": install_path(base),
    })
print(json.dumps(entries))
PY
)"
  python3 - "$OUT_CLIENT" "${client_mpqs[@]}" <<'PY'
import os
import shutil
import sys

dest = sys.argv[1]
for src in sys.argv[2:]:
    shutil.copy2(src, os.path.join(dest, os.path.basename(src)))
PY
fi

server_archive="server-data.tar.gz"
server_sha=""
server_size=0
components_json="[]"

if [[ ${#server_components[@]} -gt 0 ]]; then
  tar -czf "${OUT_SERVER}/${server_archive}" -C "${SOURCES}/server" "${server_components[@]}"
  server_sha="$(sha256_file "${OUT_SERVER}/${server_archive}")"
  server_size="$(wc -c <"${OUT_SERVER}/${server_archive}" | tr -d ' ')"
  components_json="$(printf '%s\n' "${server_components[@]}" | python3 -c 'import json,sys; print(json.dumps([l.strip() for l in sys.stdin if l.strip()]))')"
fi

if [[ -z "$CACHE_VERSION" ]]; then
  if [[ -f "${CLIENT_PATCHES_ROOT}/manifest.json" ]]; then
    CACHE_VERSION="$(jq -r '.client_cache_version // 0' "${CLIENT_PATCHES_ROOT}/manifest.json")"
    CACHE_VERSION=$((CACHE_VERSION + 1))
  else
    CACHE_VERSION=1
  fi
fi

manifest_args=(--version "$VERSION" --locale "$LOCALE" --cache-version "$CACHE_VERSION")
manifest_args+=(--patch-json "$patch_json")
manifest_args+=(--server-archive "$server_archive" --server-sha256 "$server_sha" --server-size "$server_size")
manifest_args+=(--server-components "$components_json")
for line in "${CHANGELOG[@]}"; do
  manifest_args+=(--changelog "$line")
done

python3 "${SCRIPT_DIR}/write-manifest.py" "${OUT_DIR}/manifest.json" "${manifest_args[@]}"
cp -a "${OUT_DIR}/manifest.json" "${CLIENT_PATCHES_ROOT}/manifest.json"

"${SCRIPT_DIR}/validate-manifest.sh" "${OUT_DIR}/manifest.json" "${OUT_DIR}"

cat <<EOF

Built bundle ${VERSION}:
  ${OUT_DIR}
  manifest copied to ${CLIENT_PATCHES_ROOT}/manifest.json

Next steps:
  1. Publish binaries to the VPS store (does not apply to any realm):
       VPS_HOST=debian@your.vps client-patches/scripts/publish-to-vps.sh ${OUT_DIR}
  2. Commit client-patches/manifest.json with the matching C++/SQL (not bundle binaries).
  3. Push \`dev\` → vps-build auto-deploys Test. Merge to \`Playerbot\`, then Actions → deploy-vps → live.
  4. After that realm has the version, players update:
       client-patches/scripts/update-client.sh --from-vps debian@your.vps --target test   # or --target live
EOF
