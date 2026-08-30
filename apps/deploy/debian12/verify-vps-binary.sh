#!/usr/bin/env bash
# Reject binaries that cannot run on Debian 12 VPS (e.g. local CachyOS builds).
set -euo pipefail

bin="${1:?usage: verify-vps-binary.sh /path/to/worldserver}"

if [[ ! -x "$bin" ]]; then
  echo "Missing executable: $bin" >&2
  exit 1
fi

ldd_out="$(ldd "$bin" 2>&1)"
if grep -q 'not found' <<<"$ldd_out"; then
  echo "Binary has missing libraries on this host:" >&2
  grep 'not found' <<<"$ldd_out" >&2
  exit 1
fi

if grep -qE 'boost_filesystem\.so\.1\.9[2-9]|boost_filesystem\.so\.2' <<<"$ldd_out"; then
  echo "Binary requires Boost 1.92+ (local build); VPS needs Debian-built binaries." >&2
  exit 1
fi

if grep -qE 'GLIBC_2\.(38|39|40|41|42|43)' <<<"$ldd_out"; then
  echo "Binary requires newer glibc than Debian 12 provides." >&2
  exit 1
fi

if grep -qE 'GLIBCXX_3\.4\.(3[1-9]|[4-9])' <<<"$ldd_out"; then
  echo "Binary requires newer libstdc++ than Debian 12 provides." >&2
  exit 1
fi

echo "Binary looks compatible with Debian 12 VPS."
