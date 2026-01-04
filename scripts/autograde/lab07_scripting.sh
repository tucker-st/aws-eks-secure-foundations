#!/bin/bash
# Lab 07 autograde: scripts exist, executable, basic behavior

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

echo "== Lab 07 - Bash Scripting =="

require_root_or_warn
need_cmd bash || true

# These are expected to exist in the lab directory if you created them there.
# If you keep scripts elsewhere, adjust paths accordingly.
LAB_DIR="/root/lab07"  # recommended working dir
if [ -d "$LAB_DIR" ]; then
  pass "Found lab dir: $LAB_DIR"
else
  warn "Lab dir not found: $LAB_DIR (If you created scripts elsewhere, update LAB_DIR in this script)"
fi

check_exec() {
  local f="$1"
  if [ -f "$f" ]; then
    pass "File exists: $f"
    [ -x "$f" ] && pass "Executable: $f" || fail "Not executable: $f"
    head -n1 "$f" | grep -q "^#!/bin/bash" && pass "Shebang OK: $f" || warn "Shebang not '#!/bin/bash' in $f"
  else
    fail "Missing file: $f"
  fi
}

check_exec "${LAB_DIR}/create_user.sh"
check_exec "${LAB_DIR}/bulk_users.sh"
check_exec "${LAB_DIR}/users_from_file.sh"
check_exec "${LAB_DIR}/wait_for_service.sh"
check_exec "${LAB_DIR}/service_ctl.sh"
file_exists "${LAB_DIR}/users.txt"

summary_exit
