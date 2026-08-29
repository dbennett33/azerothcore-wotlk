#!/usr/bin/env bash
# One-time Debian 12 host prep for AzerothCore deploy (sections 1–2 + linger).
# Run as root on a fresh VPS. MySQL, client data, configs, and the GitHub runner
# still require the manual steps in bootstrap.md.

set -euo pipefail

ACORE_USER="${ACORE_USER:-acore}"
ACORE_HOME="/home/${ACORE_USER}"
ACORE_PREFIX="${ACORE_PREFIX:-${ACORE_HOME}/server}"
MYSQL_APT_CONFIG_VERSION="${MYSQL_APT_CONFIG_VERSION:-0.8.36-1}"

if [ "$(id -u)" -ne 0 ]; then
  echo "run as root: sudo bash $0" >&2
  exit 1
fi

if ! command -v lsb_release >/dev/null 2>&1; then
  apt-get update -y
  apt-get install -y lsb-release
fi

debian_version="$(lsb_release -sr)"
if [ "${debian_version%%.*}" -lt 12 ]; then
  echo "Debian 12+ required (found $debian_version)" >&2
  exit 1
fi

echo "==> user and directories"
if ! id "$ACORE_USER" >/dev/null 2>&1; then
  adduser --disabled-password --gecos "" "$ACORE_USER"
fi
mkdir -p "${ACORE_PREFIX}/{bin,etc,data,logs}" "${ACORE_HOME}/server-staging"
chown -R "${ACORE_USER}:${ACORE_USER}" "${ACORE_PREFIX}" "${ACORE_HOME}/server-staging"

echo "==> build packages"
apt-get update -y
apt-get install -y lsb-release gdbserver gdb unzip curl \
  libncurses-dev libreadline-dev clang g++ gcc git cmake make ccache \
  libssl-dev libbz2-dev libboost-all-dev gnupg wget jq screen tmux expect rsync

echo "==> MySQL 8 (Oracle apt)"
tmpdir="$(mktemp -d)"
cd "$tmpdir"
wget -q "https://dev.mysql.com/get/mysql-apt-config_${MYSQL_APT_CONFIG_VERSION}_all.deb"
DEBIAN_FRONTEND=noninteractive dpkg -i "./mysql-apt-config_${MYSQL_APT_CONFIG_VERSION}_all.deb" || true
apt-get update -y
DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-server libmysqlclient-dev
rm -rf "$tmpdir"
systemctl enable --now mysql

echo "==> systemd user linger for ${ACORE_USER}"
loginctl enable-linger "$ACORE_USER"

cat <<EOF

Bootstrap script finished.

Next (see apps/deploy/debian12/bootstrap.md):
  1. Create MySQL databases and user (section 3)
  2. Copy client data into ${ACORE_PREFIX}/data (section 4)
  3. After first deploy, edit ${ACORE_PREFIX}/etc/*.conf (section 5)
  4. Register GitHub Actions runner as ${ACORE_USER} (section 7)
  5. Run deploy-vps workflow, then create systemd units (section 6)

EOF
