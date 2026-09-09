#!/usr/bin/env bash
# Choose a GitHub Actions self-hosted runner for vps-build, or require acore-vps online.
# Fails instead of queueing forever when the target runner is offline.
set -euo pipefail

VM_LABEL="${VM_LABEL:-acore-build-vm}"
VPS_LABEL="${VPS_LABEL:-acore-vps}"
REQUIRE_VPS=0

usage() {
  cat <<'EOF'
Usage: pick-github-runner.sh [--require-vps]

Default: prefer an online acore-build-vm runner, else an online acore-vps runner.
Writes GITHUB_OUTPUT labels= JSON array for runs-on.

--require-vps  Exit 0 only if an acore-vps runner is online (deploy jobs).
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --require-vps)
      REQUIRE_VPS=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if [[ -z "${GITHUB_REPOSITORY:-}" ]]; then
  echo "GITHUB_REPOSITORY is required" >&2
  exit 1
fi

if [[ -n "${ACORE_WORKFLOW_PAT:-}" ]]; then
  export GH_TOKEN="${ACORE_WORKFLOW_PAT}"
elif [[ -n "${GITHUB_TOKEN:-}" ]]; then
  export GH_TOKEN="${GITHUB_TOKEN}"
else
  echo "Set ACORE_WORKFLOW_PAT or GITHUB_TOKEN to list runners" >&2
  exit 1
fi

listing=""
set +e
listing="$(gh api "repos/${GITHUB_REPOSITORY}/actions/runners" \
  --jq '.runners[] | [.name, .status, .busy, ([.labels[].name] | join(","))] | @tsv' 2>&1)"
api_status=$?
set -e

echo "Runners:"
echo "${listing}"

if [[ $api_status -ne 0 ]]; then
  echo "Runner list API failed (${listing})" >&2
  echo "Add repo secret ACORE_WORKFLOW_PAT (repo Actions read) if GITHUB_TOKEN cannot list runners." >&2
  exit 1
fi

label_online() {
  local want="$1"
  awk -F '\t' -v want="$want" '
    function norm(s,    t) {
      t = s
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", t)
      return tolower(t)
    }
    $2 == "online" {
      n = split($4, a, ",")
      for (i = 1; i <= n; i++) {
        if (norm(a[i]) == norm(want)) found = 1
      }
    }
    END { exit found ? 0 : 1 }
  ' <<< "${listing}"
}

write_labels() {
  local label="$1"
  if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
    echo "labels=[\"self-hosted\",\"linux\",\"${label}\"]" >> "${GITHUB_OUTPUT}"
  fi
  echo "Selected labels: self-hosted, linux, ${label}"
}

vps_help() {
  cat <<'EOF' >&2
The acore-vps GitHub runner is offline, so deploy/compile jobs would sit queued.
On the VPS (SSH as debian):

  sudo -u acore bash -lc 'cd /home/acore/actions-runner && ./svc.sh status'
  sudo -u acore bash -lc 'cd /home/acore/actions-runner && ./svc.sh start'

If compile already rsynced staging, start the runner then either wait for the
queued promote-test job or run Actions → deploy-vps → test.
EOF
}

if [[ "$REQUIRE_VPS" -eq 1 ]]; then
  if label_online "$VPS_LABEL"; then
    echo "VPS runner online (label ${VPS_LABEL})"
    exit 0
  fi
  echo "No online runner with label ${VPS_LABEL}" >&2
  vps_help
  exit 1
fi

if label_online "$VM_LABEL"; then
  echo "Build VM online (label ${VM_LABEL})"
  write_labels "$VM_LABEL"
  exit 0
fi

echo "No online runner with label ${VM_LABEL}"

if label_online "$VPS_LABEL"; then
  echo "Compiling on VPS (label ${VPS_LABEL})"
  write_labels "$VPS_LABEL"
  exit 0
fi

echo "No online self-hosted runner for compile (tried ${VM_LABEL} then ${VPS_LABEL})" >&2
vps_help
exit 1
