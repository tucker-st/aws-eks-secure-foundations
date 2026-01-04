#!/bin/bash
# Run all lab autogrades and summarize

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

chmod +x "${SCRIPT_DIR}/"*.sh >/dev/null 2>&1 || true

echo "RHCSA Autograde - Running all labs"
echo "Tip: run as root for best results: sudo $0"
echo

run_one() {
  local f="$1"
  echo "----------------------------------------"
  bash "$f" || true
}

run_one "${SCRIPT_DIR}/lab01_users.sh"
run_one "${SCRIPT_DIR}/lab02_storage.sh"
run_one "${SCRIPT_DIR}/lab03_networking.sh"
run_one "${SCRIPT_DIR}/lab04_services.sh"
run_one "${SCRIPT_DIR}/lab05_selinux.sh"
run_one "${SCRIPT_DIR}/lab06_archiving.sh"
run_one "${SCRIPT_DIR}/lab07_scripting.sh"
run_one "${SCRIPT_DIR}/lab08_containers.sh"

echo "----------------------------------------"
echo "Done."
