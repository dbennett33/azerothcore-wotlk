#!/usr/bin/env bash
# Shared helpers for client-patches scripts.
set -euo pipefail

CLIENT_PATCHES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

sha256_file() {
  local file="$1"
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$file" | awk '{print $1}'
  else
    shasum -a 256 "$file" | awk '{print $1}'
  fi
}

require_cmd() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Missing required command: ${cmd}" >&2
    exit 1
  fi
}

json_get() {
  local file="$1"
  local key="$2"
  python3 - "$file" "$key" <<'PY'
import json
import sys

path, key = sys.argv[1], sys.argv[2]
with open(path, encoding="utf-8") as handle:
    data = json.load(handle)

value = data
for part in key.split("."):
    value = value[part]

if isinstance(value, (dict, list)):
    print(json.dumps(value))
else:
    print(value)
PY
}

verify_sha256() {
  local file="$1"
  local expected="$2"
  local actual
  actual="$(sha256_file "$file")"
  if [[ "$actual" != "$expected" ]]; then
    echo "Checksum mismatch for ${file}" >&2
    echo "  expected: ${expected}" >&2
    echo "  actual:   ${actual}" >&2
    return 1
  fi
}

download_file() {
  local url="$1"
  local dest="$2"
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$url" -o "$dest"
  elif command -v wget >/dev/null 2>&1; then
    wget -q -O "$dest" "$url"
  else
    echo "Need curl or wget to download ${url}" >&2
    return 1
  fi
}

bundle_dir_for_version() {
  local version="$1"
  printf '%s/bundles/%s' "$CLIENT_PATCHES_ROOT" "$version"
}

# World archives (patch-4.MPQ, patch-5.MPQ) belong in Data/. Locale archives
# (patch-enUS-4.MPQ, locale-enUS.MPQ) belong in Data/<locale>/.
mpq_install_path() {
  local filename="$1"
  local locale="${2:-enUS}"
  local lower
  lower="$(printf '%s' "$filename" | tr '[:upper:]' '[:lower:]')"
  local loc
  loc="$(printf '%s' "$locale" | tr '[:upper:]' '[:lower:]')"
  case "$lower" in
    *"patch-${loc}"*|*"locale-${loc}"*)
      printf 'Data/%s/%s' "$locale" "$filename"
      ;;
    *)
      printf 'Data/%s' "$filename"
      ;;
  esac
}

default_locale() {
  json_get "${CLIENT_PATCHES_ROOT}/manifest.json" "client.locale"
}
