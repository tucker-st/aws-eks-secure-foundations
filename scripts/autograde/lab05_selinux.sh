#!/bin/bash
# Lab 05 autograde: SELinux enforcing + custom docroot context

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

echo "== Lab 05 - SELinux =="

require_root_or_warn
need_cmd getenforce || true
need_cmd ls || true
need_cmd curl || true

check_selinux_enforcing

# Check custom docroot and context
dir_exists /webdata
file_exists /webdata/index.html
check_file_context_type /webdata httpd_sys_content_t
check_file_context_type /webdata/index.html httpd_sys_content_t

# Access works
if curl -fsS http://localhost >/dev/null 2>&1; then pass "curl http://localhost succeeded"; else fail "curl http://localhost failed"; fi

summary_exit
