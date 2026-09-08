#!/usr/bin/env bash
# Apply this fork's holding-pen patches onto a checked-out mod-playerbots tree.
# Used after vps-build checks out dbennett33/mod-playerbots. Delete the patches
# once the same change is on that repo's matching branch (dev / master).
set -euo pipefail

dest="${1:?usage: apply-playerbots-patches.sh /path/to/modules/mod-playerbots}"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
patch_dir="${script_dir}/patches/mod-playerbots"

if [[ ! -d "$dest" ]]; then
  echo "mod-playerbots tree not found: $dest" >&2
  exit 1
fi

shopt -s nullglob
patches=("${patch_dir}"/*.patch)
if [[ ${#patches[@]} -eq 0 ]]; then
  echo "No playerbots overlays in ${patch_dir}"
  exit 0
fi

for patch in "${patches[@]}"; do
  echo "Applying $(basename "$patch") to ${dest}"
  # Already applied (rebuild on the same tree) is OK.
  if git -C "$dest" apply --reverse --check "$patch" >/dev/null 2>&1; then
    echo "Already applied: $(basename "$patch")"
    continue
  fi
  git -C "$dest" apply "$patch"
done
