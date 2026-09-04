#!/usr/bin/env bash
# Validate manifest.json structure and checksum fields.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "${SCRIPT_DIR}/lib.sh"

MANIFEST="${1:-${CLIENT_PATCHES_ROOT}/manifest.json}"
BUNDLE_DIR="${2:-}"

require_cmd python3
require_cmd jq

if [[ ! -f "$MANIFEST" ]]; then
  echo "Manifest not found: ${MANIFEST}" >&2
  exit 1
fi

python3 - "$MANIFEST" "${CLIENT_PATCHES_ROOT}/manifest.schema.json" <<'PY'
import json
import sys

manifest_path, schema_path = sys.argv[1], sys.argv[2]

with open(manifest_path, encoding="utf-8") as handle:
    manifest = json.load(handle)

with open(schema_path, encoding="utf-8") as handle:
    schema = json.load(handle)

# Minimal validation without external jsonschema dependency.
required = schema["required"]
for key in required:
    if key not in manifest:
        raise SystemExit(f"manifest missing required key: {key}")

version = manifest["version"]
if version == "0.0.0":
    print("warning: placeholder manifest version 0.0.0")

print(f"manifest ok: version={manifest['version']}")
PY

manifest_locale="$(jq -r '.client.locale' "$MANIFEST")"
while IFS=$'\t' read -r file install_path; do
  [[ -z "$file" || "$file" == "null" ]] && continue
  expected="$(mpq_install_path "$file" "$manifest_locale")"
  if [[ "$install_path" != "$expected" ]]; then
    echo "install_path for ${file} is ${install_path}; expected ${expected}" >&2
    echo "World archives (patch-4.MPQ) go in Data/; locale archives (patch-enUS-4.MPQ) in Data/${manifest_locale}/." >&2
    exit 1
  fi
done < <(jq -r '.client.patches[] | [.file, .install_path] | @tsv' "$MANIFEST")

if [[ -n "$BUNDLE_DIR" ]]; then
  if [[ ! -d "$BUNDLE_DIR" ]]; then
    echo "Bundle directory not found: ${BUNDLE_DIR}" >&2
    exit 1
  fi

  server_archive="$(jq -r '.server.archive' "$MANIFEST")"
  server_sha="$(jq -r '.server.sha256' "$MANIFEST")"
  server_size="$(jq -r '.server.size' "$MANIFEST")"

  if [[ -n "$server_sha" && "$server_size" != "0" ]]; then
    archive_path="${BUNDLE_DIR}/server/${server_archive}"
    if [[ ! -f "$archive_path" ]]; then
      echo "Missing server archive: ${archive_path}" >&2
      exit 1
    fi
    verify_sha256 "$archive_path" "$server_sha"
    echo "server archive checksum ok"
  fi

  mapfile -t patch_files < <(jq -r '.client.patches[].file' "$MANIFEST")
  mapfile -t patch_shas < <(jq -r '.client.patches[].sha256' "$MANIFEST")

  for i in "${!patch_files[@]}"; do
    file="${patch_files[$i]}"
    sha="${patch_shas[$i]}"
    [[ -z "$file" || "$file" == "null" ]] && continue
    patch_path="${BUNDLE_DIR}/client/${file}"
    if [[ ! -f "$patch_path" ]]; then
      echo "Missing client patch: ${patch_path}" >&2
      exit 1
    fi
    verify_sha256 "$patch_path" "$sha"
    echo "client patch checksum ok: ${file}"
  done
fi

echo "validation complete"
