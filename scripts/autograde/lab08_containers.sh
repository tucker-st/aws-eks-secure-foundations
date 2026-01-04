#!/bin/bash
# Lab 08 autograde: podman container + systemd persistence + curl

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

echo "== Lab 08 - Containers (Podman) =="

require_root_or_warn
need_cmd podman || true
need_cmd systemctl || true
need_cmd curl || true
need_cmd firewall-cmd || true

# Firewalld port
check_firewalld_port 8080/tcp

# systemd unit
if systemctl is-active --quiet container-webtest; then pass "container-webtest active"; else fail "container-webtest NOT active"; fi
if systemctl is-enabled --quiet container-webtest; then pass "container-webtest enabled"; else fail "container-webtest NOT enabled"; fi

# container exists/running (best effort)
if podman ps --format "{{.Names}}" 2>/dev/null | grep -qx "webtest"; then
  pass "Podman container running: webtest"
else
  fail "Podman container not running: webtest"
fi

# content and SELinux volume
dir_exists /container-data
file_exists /container-data/index.html

# curl
if curl -fsS http://localhost:8080 >/dev/null 2>&1; then pass "curl http://localhost:8080 succeeded"; else fail "curl http://localhost:8080 failed"; fi

summary_exit
