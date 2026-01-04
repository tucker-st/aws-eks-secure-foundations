#!/bin/bash
# Lab 06 autograde: archives exist and extract sanity

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

echo "== Lab 06 - Archiving =="

require_root_or_warn
need_cmd tar || true

file_exists /root/project_backup.tar.gz
file_exists /root/project_backup.tar.bz2

# Optional: list contents
if [ -f /root/project_backup.tar.gz ]; then
  tar -tzf /root/project_backup.tar.gz >/dev/null 2>&1 && pass "tar.gz readable" || fail "tar.gz not readable"
fi
if [ -f /root/project_backup.tar.bz2 ]; then
  tar -tjf /root/project_backup.tar.bz2 >/dev/null 2>&1 && pass "tar.bz2 readable" || fail "tar.bz2 not readable"
fi

# Optional: restored content
if [ -d /restore/project ]; then
  pass "Restore directory exists: /restore/project"
else
  warn "Restore directory missing: /restore/project (OK if you cleaned up)"
fi

summary_exit
