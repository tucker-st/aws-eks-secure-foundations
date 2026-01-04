#!/bin/bash
# Lab 04 autograde: httpd + firewall

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

echo "== Lab 04 - Services and Firewall =="

require_root_or_warn
need_cmd systemctl || true
need_cmd firewall-cmd || true
need_cmd ss || true
need_cmd curl || true

# httpd service active/enabled
check_systemd_active_enabled httpd

# Listening on 80
ss -tulnp 2>/dev/null | grep -q ":80" && pass "Port 80 listening" || fail "Port 80 not listening"

# Firewall http service
check_firewalld_service http

# Local curl
if curl -fsS http://localhost >/dev/null 2>&1; then pass "curl http://localhost succeeded"; else fail "curl http://localhost failed"; fi

summary_exit
