#!/usr/bin/env bash
# Self-hosted runners reuse the same workdir. deploy-vps sparse-checkout can
# persist and leave vps-build without CMakeLists.txt.
set -euo pipefail

cd "${GITHUB_WORKSPACE:?GITHUB_WORKSPACE required}"

git sparse-checkout disable 2>/dev/null || true
git checkout --force HEAD

if [[ ! -f CMakeLists.txt ]]; then
  echo "CMakeLists.txt missing after checkout (sparse-checkout leftover?)" >&2
  ls -la >&2
  exit 1
fi
