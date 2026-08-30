#!/usr/bin/env bash
# Fix cache dir ownership after bootstrap (parent dirs may be root-owned).
set -euo pipefail
chown -R dan:dan /home/dan/.cache/azerothcore
chown dan:dan /home/dan/actions-runner
echo "Fixed ownership under /home/dan/.cache/azerothcore"
