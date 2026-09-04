#!/usr/bin/env bash
# Clone extra AC modules into a modules/ directory (compile tree or VPS SourceDirectory).
set -euo pipefail

dest="${1:?usage: clone-extra-modules.sh /path/to/modules}"
mkdir -p "$dest"

clone_or_update() {
  local repo="$1" dir="$2" branch="${3:-master}"
  local path="${dest}/${dir}"
  if [[ ! -d "${path}/.git" ]]; then
    # SourceDirectory copies may be rsynced without .git; clone needs an empty dest.
    rm -rf "$path"
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
clone_or_update https://github.com/azerothcore/mod-skip-dk-starting-area.git mod-skip-dk-starting-area

# Worldserver DBUpdater looks under SourceDirectory/modules/ for these. Compile trees
# already check them out in vps-build; set CLONE_UPDATER_MODULES=1 from sync-sql-sources.
if [[ "${CLONE_UPDATER_MODULES:-0}" == "1" ]]; then
  clone_or_update "${PLAYERBOTS_REPO:-https://github.com/dbennett33/mod-playerbots.git}" \
    mod-playerbots "${PLAYERBOTS_REF:-master}"
  clone_or_update "${IP_REPO:-https://github.com/ZhengPeiRu21/mod-individual-progression.git}" \
    mod-individual-progression "${IP_REF:-master}"
fi
