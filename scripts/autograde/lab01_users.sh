#!/bin/bash
# Lab 01 autograde: Users, Groups, Sudo

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=common.sh
source "${SCRIPT_DIR}/common.sh"

echo "== Lab 01 - Users, Groups, and Sudo =="

require_root_or_warn
need_cmd getent || true
need_cmd id || true
need_cmd visudo || true

check_group_exists dev
check_group_exists ops

check_user_exists alice
check_user_exists bob

# Primary groups (only check if users exist)
if id alice >/dev/null 2>&1; then check_user_primary_group alice dev; fi
if id bob   >/dev/null 2>&1; then check_user_primary_group bob ops; fi

# Group membership
if id alice >/dev/null 2>&1; then check_user_in_group alice ops; fi

# Shell
if id bob >/dev/null 2>&1; then check_user_shell bob /bin/bash; fi

# Sudoers file + syntax
if [ -f /etc/sudoers.d/ops-lab01 ]; then
  pass "Sudoers drop-in exists: /etc/sudoers.d/ops-lab01"
  if visudo -c >/dev/null 2>&1; then pass "Sudoers syntax OK (visudo -c)"; else fail "Sudoers syntax error (visudo -c)"; fi
else
  fail "Missing /etc/sudoers.d/ops-lab01"
fi

# Account locked
if id bob >/dev/null 2>&1; then check_account_locked bob; fi

summary_exit
