#!/usr/bin/env bash
# Clone extra AC modules into a modules/ directory (compile tree or VPS SourceDirectory).
set -euo pipefail

dest="${1:?usage: clone-extra-modules.sh /path/to/modules}"
mkdir -p "$dest"

clone_or_update() {
  local repo="$1" dir="$2" branch="${3:-master}"
  local path="${dest}/${dir}"
  if [[ ! -d "${path}/.git" ]]; then
    git clone --depth 1 --branch "$branch" "$repo" "$path"
  else
    git -C "$path" fetch --depth 1 origin "$branch"
    git -C "$path" checkout -f "$branch"
    git -C "$path" reset --hard "origin/$branch"
  fi
}

clone_or_update https://github.com/dbennett33/mod-npc-enchanter.git mod-npc-enchanter
clone_or_update https://github.com/azerothcore/mod-npc-services.git mod-npc-services
clone_or_update https://github.com/kadeshar/mod-dungeon-clear.git mod-dungeon-clear
