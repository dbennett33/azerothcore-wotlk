#!/usr/bin/env bash
# Fix cache dir ownership after bootstrap (parent dirs may be root-owned).
set -euo pipefail
chown -R dan:dan /home/dan/.cache/azerothcore
chown dan:dan /home/dan/actions-runner
for etc in /home/acore/server/etc/modules /home/acore/server-test/etc/modules; do
  install -d -o dan -g dan -m 755 "$etc"
done
echo "Fixed ownership under /home/dan/.cache/azerothcore and /home/acore/*/etc"
