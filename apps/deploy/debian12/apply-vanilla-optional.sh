#!/usr/bin/env bash
# One-time optional SQL + server DBC patches from mod-individual-progression.
# Idempotent via marker file. Requires module clone at MOD_IP_ROOT.
set -euo pipefail

ACORE_PREFIX="${ACORE_PREFIX:-/home/acore/server}"
MOD_IP_ROOT="${MOD_IP_ROOT:-/home/acore/src/mod-individual-progression}"
MARKER="${ACORE_PREFIX}/etc/.vanilla-optional-applied"
DBC_DIR="${ACORE_PREFIX}/data/dbc"
MYSQL_USER="${MYSQL_USER:-acore}"
MYSQL_PASS="${MYSQL_PASS:-acore}"
WORLD_DB="${WORLD_DB:-acore_world}"

if [[ -f "$MARKER" ]]; then
  echo "Optional vanilla patches already applied ($(cat "$MARKER"))"
  exit 0
fi

if [[ ! -d "$MOD_IP_ROOT/optional" ]]; then
  echo "Clone mod-individual-progression to ${MOD_IP_ROOT} first."
  exit 1
fi

mysql_world() {
  mysql -u "$MYSQL_USER" -p"$MYSQL_PASS" "$WORLD_DB" "$@"
}

OPTIONAL_SQL=(
  zz_optional_phasing.sql
  zz_optional_limit_spells_to_expansion.sql
  zz_optional_remove_heirlooms.sql
  zz_optional_vanilla_crafting_requirements.sql
  zz_optional_vanilla_regen_values.sql
  zz_optional_vanilla_transports.sql
  zz_optional_creature_stats.sql
  zz_optional_spell_damage_and_healing.sql
  zz_optional_item_stack_sizes.sql
  zz_optional_restore_potion_cd.sql
  zz_optional_restore_rogue_poisons.sql
  zz_optional_stackable_buff_scrolls.sql
  zz_optional_ammo_stack_size.sql
)

for sql in "${OPTIONAL_SQL[@]}"; do
  path="${MOD_IP_ROOT}/optional/sql/world/${sql}"
  if [[ -f "$path" ]]; then
    echo "Applying ${sql}..."
    mysql_world <"$path"
  else
    echo "Skip missing ${sql}"
  fi
done

if command -v 7z >/dev/null 2>&1; then
  work="$(mktemp -d)"
  trap 'rm -rf "$work"' EXIT
  mkdir -p "$DBC_DIR"
  if [[ -f "${MOD_IP_ROOT}/optional/dbc.7z" ]]; then
    echo "Extracting server DBC from dbc.7z..."
    7z x -o"$work" "${MOD_IP_ROOT}/optional/dbc.7z" -y
    for f in SkillLine.dbc SkillLineAbility.dbc SkillRaceClassInfo.dbc SpellItemEnchantment.dbc; do
      if [[ -f "${work}/${f}" ]]; then
        cp -a "${work}/${f}" "${DBC_DIR}/${f}"
      fi
    done
  fi
  if [[ -f "${MOD_IP_ROOT}/optional/patch-V.7z" ]]; then
    echo "Extracting vanilla Spell.dbc from patch-V.7z..."
    7z x -o"$work/v" "${MOD_IP_ROOT}/optional/patch-V.7z" -y
    if [[ -f "${work}/v/Spell.dbc" ]]; then
      cp -a "${work}/v/Spell.dbc" "${DBC_DIR}/Spell.dbc"
    fi
  fi
else
  echo "7z not installed; skip optional DBC (install p7zip-full)."
fi

# WotLK Map.dbc marks Naxxramas (533) as expansion 2; vanilla-locked servers need 0.
MAP_DBC="${DBC_DIR}/Map.dbc"
if [[ -f "$MAP_DBC" ]] && command -v python3 >/dev/null 2>&1; then
  python3 - "$MAP_DBC" <<'PY'
import struct, sys
path = sys.argv[1]
with open(path, "rb") as f:
    data = bytearray(f.read())
_, nrec, _, ssize = struct.unpack_from("<4sIII", data, 0)
off = 20
for i in range(nrec):
    rec_off = off + i * ssize
    if struct.unpack_from("<I", data, rec_off)[0] != 533:
        continue
    exp_off = rec_off + 252
    old = struct.unpack_from("<I", data, exp_off)[0]
    if old != 0:
        struct.pack_into("<I", data, exp_off, 0)
        with open(path, "wb") as f:
            f.write(data)
        print(f"Patched Map.dbc: map 533 ExpansionID {old} -> 0")
    break
PY
fi

date -u +%Y-%m-%dT%H:%M:%SZ >"$MARKER"
echo "Optional vanilla patches applied."
