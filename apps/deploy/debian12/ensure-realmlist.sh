#!/usr/bin/env bash
# Ensure auth.realmlist rows for live (8085) and test (8086). Safe to re-run.
set -euo pipefail

ENV_FILE="${ENV_FILE:-/home/acore/.acore-backup.env}"
MYSQL_USER="${MYSQL_USER:-acore}"
MYSQL_PASS="${MYSQL_PASS:-}"
MYSQL_HOST="${MYSQL_HOST:-127.0.0.1}"

if [[ -f "$ENV_FILE" ]]; then
  # shellcheck disable=SC1090
  source "$ENV_FILE"
fi

if [[ -z "$MYSQL_PASS" ]]; then
  echo "Set MYSQL_PASS in ${ENV_FILE} or environment." >&2
  exit 1
fi

PUBLIC_ADDRESS="${REALMLIST_ADDRESS:-}"
if [[ -z "$PUBLIC_ADDRESS" ]]; then
  PUBLIC_ADDRESS="$(mysql -h "$MYSQL_HOST" -u "$MYSQL_USER" -p"$MYSQL_PASS" -N -e \
    "SELECT address FROM acore_auth.realmlist WHERE id=1 LIMIT 1" 2>/dev/null || true)"
fi
PUBLIC_ADDRESS="${PUBLIC_ADDRESS:-127.0.0.1}"

mysql -h "$MYSQL_HOST" -u "$MYSQL_USER" -p"$MYSQL_PASS" acore_auth <<SQL
INSERT INTO realmlist (id, name, address, localAddress, localSubnetMask, port, icon, flag, timezone, allowedSecurityLevel, population, gamebuild)
VALUES (1, 'Live', '${PUBLIC_ADDRESS}', '127.0.0.1', '255.255.255.0', 8085, 0, 2, 1, 0, 0, 12340)
ON DUPLICATE KEY UPDATE
  name='Live', address='${PUBLIC_ADDRESS}', port=8085;

INSERT INTO realmlist (id, name, address, localAddress, localSubnetMask, port, icon, flag, timezone, allowedSecurityLevel, population, gamebuild)
VALUES (2, 'Test', '${PUBLIC_ADDRESS}', '127.0.0.1', '255.255.255.0', 8086, 0, 2, 1, 0, 0, 12340)
ON DUPLICATE KEY UPDATE
  name='Test', address='${PUBLIC_ADDRESS}', port=8086;
SQL

echo "realmlist: Live (id=1, port 8085), Test (id=2, port 8086), address=${PUBLIC_ADDRESS}"
