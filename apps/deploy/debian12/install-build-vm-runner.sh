#!/usr/bin/env bash
# Install GitHub Actions runner on Debian 12 build VM (deployable binaries for VPS).
set -euo pipefail

RUNNER_ROOT="${RUNNER_ROOT:-${HOME}/actions-runner}"
RUNNER_NAME="${RUNNER_NAME:-acore-build-d12}"
REPO_URL="${REPO_URL:-https://github.com/dbennett33/azerothcore-wotlk}"

if [[ -z "${RUNNER_TOKEN:-}" ]]; then
  echo "Get a registration token:"
  echo "  ${REPO_URL} → Settings → Actions → Runners → New self-hosted runner"
  echo "  Or: gh api repos/dbennett33/azerothcore-wotlk/actions/runners/registration-token -X POST -q .token"
  read -rsp "Paste registration token: " RUNNER_TOKEN
  echo ""
fi

if ! command -v jq >/dev/null; then
  echo "Installing jq (sudo)..."
  sudo apt-get update -y
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y jq
fi

RUNNER_VERSION="$(curl -fsSL https://api.github.com/repos/actions/runner/releases/latest | jq -r '.tag_name[1:]')"
RUNNER_TARBALL="actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz"
RUNNER_URL="https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/${RUNNER_TARBALL}"

mkdir -p "${RUNNER_ROOT}"
cd "${RUNNER_ROOT}"

if [[ ! -f ./config.sh ]]; then
  echo "Downloading actions-runner v${RUNNER_VERSION}..."
  curl -fsSL -o "${RUNNER_TARBALL}" "${RUNNER_URL}"
  tar xzf "${RUNNER_TARBALL}"
  rm -f "${RUNNER_TARBALL}"
fi

echo "Installing runner OS packages (sudo)..."
sudo ./bin/installdependencies.sh

./config.sh \
  --url "${REPO_URL}" \
  --token "${RUNNER_TOKEN}" \
  --name "${RUNNER_NAME}" \
  --labels "self-hosted,linux,X64,acore-build" \
  --replace \
  --unattended

echo ""
echo "Start interactively:  cd ${RUNNER_ROOT} && ./run.sh"
echo "Install user service: cd ${RUNNER_ROOT} && sudo ./svc.sh install dan && sudo ./svc.sh start"
echo "Status:               cd ${RUNNER_ROOT} && sudo ./svc.sh status"
