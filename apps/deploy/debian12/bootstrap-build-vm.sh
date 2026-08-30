#!/usr/bin/env bash
# Minimal Debian 12 build VM for AzerothCore (match VPS glibc/Boost/MySQL client).
# Run on the VM: sudo bash bootstrap-build-vm.sh
set -euo pipefail

if [[ "$(id -un)" != root ]]; then
  echo "Run as root: sudo bash $0" >&2
  exit 1
fi

export DEBIAN_FRONTEND=noninteractive

echo "==> Base build packages"
apt-get update -y
apt-get install -y \
  git cmake make g++ gcc ccache \
  libssl-dev libbz2-dev libboost-all-dev \
  libncurses-dev libreadline-dev \
  curl wget gnupg rsync unzip ca-certificates

echo "==> MySQL client dev (Oracle apt, no server)"
MYSQL_APT_CONFIG_VERSION=0.8.36-1
tmpdir="$(mktemp -d)"
cd "$tmpdir"
wget -q "https://dev.mysql.com/get/mysql-apt-config_${MYSQL_APT_CONFIG_VERSION}_all.deb"
dpkg -i "./mysql-apt-config_${MYSQL_APT_CONFIG_VERSION}_all.deb" || true
apt-get update -y
apt-get install -y libmysqlclient-dev
rm -rf "$tmpdir"

echo "==> Build cache dirs for user dan"
cache_root=/home/dan/.cache/azerothcore
for d in build/live build/test staging staging-test prefix-live prefix-test; do
  install -d -o dan -g dan "${cache_root}/${d}"
done
install -d -o dan -g dan /home/dan/actions-runner

echo "==> Verify toolchain"
g++ --version | head -1
dpkg -l | grep -E 'libboost-filesystem|libmysqlclient-dev' | awk '{print $2, $3}'

echo ""
echo "Bootstrap complete."
echo "Next: install GitHub Actions runner (see apps/deploy/debian12/install-local-runner.sh)"
