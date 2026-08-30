#!/usr/bin/env bash
# Install GitHub Actions self-hosted runner on this machine (dev PC).
# Uses label acore-local so VPS jobs (acore-vps) never run here.
set -euo pipefail

AC_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../" && pwd)"
RUNNER_ROOT="${RUNNER_ROOT:-${HOME}/actions-runner}"
RUNNER_NAME="${RUNNER_NAME:-acore-build-local}"
GITHUB_REPO="${GITHUB_REPO:-}"

if [[ -z "${REPO_URL:-}" ]]; then
  origin="$(git -C "$AC_ROOT" remote get-url origin 2>/dev/null || true)"
  case "$origin" in
    https://github.com/*)
      GITHUB_REPO="${origin#https://github.com/}"
      GITHUB_REPO="${GITHUB_REPO%.git}"
      ;;
    git@github.com:*)
      GITHUB_REPO="${origin#git@github.com:}"
      GITHUB_REPO="${GITHUB_REPO%.git}"
      ;;
  esac
  if [[ -n "$GITHUB_REPO" ]]; then
    REPO_URL="https://github.com/${GITHUB_REPO}"
  fi
fi

if [[ -z "${REPO_URL:-}" ]]; then
  read -rp "GitHub repo (owner/name): " GITHUB_REPO
  REPO_URL="https://github.com/${GITHUB_REPO}"
fi

if [[ -n "${REPO_URL:-}" && -z "${GITHUB_REPO}" ]]; then
  GITHUB_REPO="${REPO_URL#https://github.com/}"
  GITHUB_REPO="${GITHUB_REPO%.git}"
fi

echo "Repo:    ${REPO_URL}"
echo "Install: ${RUNNER_ROOT}"
echo "Name:    ${RUNNER_NAME}"
echo "Labels:  self-hosted, linux, X64, acore-build, acore-local"
echo ""

if [[ -z "${RUNNER_TOKEN:-}" ]]; then
  echo "Get a registration token:"
  echo "  GitHub → ${REPO_URL} → Settings → Actions → Runners → New self-hosted runner"
  echo "  Or: gh api repos/${GITHUB_REPO}/actions/runners/registration-token -X POST -q .token"
  echo ""
  read -rsp "Paste registration token: " RUNNER_TOKEN
  echo ""
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

if [[ ! -x ./bin/installdependencies.sh ]]; then
  echo "Runner extract failed; missing bin/installdependencies.sh" >&2
  exit 1
fi

echo "Installing runner OS packages (sudo)..."
sudo ./bin/installdependencies.sh

./config.sh \
  --url "${REPO_URL}" \
  --token "${RUNNER_TOKEN}" \
  --name "${RUNNER_NAME}" \
  --labels "self-hosted,linux,X64,acore-build,acore-local" \
  --replace \
  --unattended

echo ""
echo "Start interactively:  cd ${RUNNER_ROOT} && ./run.sh"
echo "Install user service: cd ${RUNNER_ROOT} && ./svc.sh install && ./svc.sh start"
echo "Status:               cd ${RUNNER_ROOT} && ./svc.sh status"
echo ""
echo "Pool label acore-build — same as VPS (add acore-build to VPS runner in GitHub UI)."
