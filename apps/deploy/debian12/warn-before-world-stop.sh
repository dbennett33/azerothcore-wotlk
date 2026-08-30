#!/usr/bin/env bash
# Warn online players before deploy stops worldserver (SOAP announce + shutdown timer).
set -euo pipefail

ACORE_PREFIX="${ACORE_PREFIX:?set ACORE_PREFIX}"
WARN_SECS="${DEPLOY_WARN_SECS:-60}"
WARN_MESSAGE="${DEPLOY_WARN_MESSAGE:-Server restart for deployment update}"
ENV_FILE="${ENV_FILE:-/home/acore/.acore-backup.env}"
WS_CONF="${ACORE_PREFIX}/etc/worldserver.conf"
BIN="${ACORE_PREFIX}/bin/worldserver"

if [[ ! -x "$BIN" ]]; then
  echo "skip warn: missing $BIN"
  exit 0
fi

if [[ -f "$ENV_FILE" ]]; then
  # shellcheck disable=SC1090
  source "$ENV_FILE"
fi

SOAP_USER="${ACORE_SOAP_USER:-${SOAP_USER:-}}"
SOAP_PASS="${ACORE_SOAP_PASS:-${SOAP_PASS:-}}"

find_world_pid() {
  local pid
  pid="$(pgrep -f "${BIN} -c ${ACORE_PREFIX}/etc/worldserver.conf" 2>/dev/null | head -1 || true)"
  if [[ -z "$pid" ]]; then
    pid="$(pgrep -f "${BIN}" 2>/dev/null | head -1 || true)"
  fi
  echo "$pid"
}

pid="$(find_world_pid)"
if [[ -z "$pid" ]]; then
  echo "skip warn: worldserver not running for ${ACORE_PREFIX}"
  exit 0
fi

if [[ ! -f "$WS_CONF" ]]; then
  echo "skip warn: missing ${WS_CONF}"
  exit 0
fi

soap_enabled="$(grep -E '^SOAP\.Enabled' "$WS_CONF" | tail -1 | awk '{print $3}')"
soap_port="$(grep -E '^SOAP\.Port' "$WS_CONF" | tail -1 | awk '{print $3}')"
soap_port="${soap_port:-7878}"

if [[ "$soap_enabled" != "1" ]]; then
  echo "SOAP disabled; sleeping ${WARN_SECS}s before stop"
  sleep "$WARN_SECS"
  exit 0
fi

if [[ -z "$SOAP_USER" || -z "$SOAP_PASS" ]]; then
  echo "ACORE_SOAP_USER / ACORE_SOAP_PASS not set (repo secret or ${ENV_FILE}); sleeping ${WARN_SECS}s"
  sleep "$WARN_SECS"
  exit 0
fi

soap_exec() {
  local command="$1"
  local body
  body="$(cat <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns1="urn:AC">
  <SOAP-ENV:Body>
    <ns1:executeCommand>
      <command>${command}</command>
    </ns1:executeCommand>
  </SOAP-ENV:Body>
</SOAP-ENV:Envelope>
EOF
)"
  curl -fsS -u "${SOAP_USER}:${SOAP_PASS}" \
    -H "Content-Type: text/xml; charset=utf-8" \
    -d "$body" \
    "http://127.0.0.1:${soap_port}/"
}

announce_text="[Server] ${WARN_MESSAGE} — shutting down in ${WARN_SECS} seconds."
shutdown_reason="${WARN_MESSAGE}"

echo "Warning players on ${ACORE_PREFIX} (pid=${pid}, SOAP port ${soap_port})"
soap_exec "announce ${announce_text}" || echo "SOAP announce failed (continuing)" >&2
soap_exec "server shutdown ${WARN_SECS} ${shutdown_reason}" || {
  echo "SOAP server shutdown failed; sleeping ${WARN_SECS}s" >&2
  sleep "$WARN_SECS"
  exit 0
}

echo "Waiting up to $((WARN_SECS + 30))s for worldserver to exit..."
for ((i = 1; i <= WARN_SECS + 30; i++)); do
  if ! kill -0 "$pid" 2>/dev/null; then
    echo "worldserver exited after ${i}s"
    exit 0
  fi
  sleep 1
done

echo "worldserver still running after countdown; deploy will force stop"
