#!/bin/bash
# Lab 03 autograde: nmcli static IPv4 + hostname

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

echo "== Lab 03 - Networking (nmcli) =="

require_root_or_warn
need_cmd nmcli || true
need_cmd hostnamectl || true
need_cmd ip || true

# Hostname
hn="$(hostnamectl --static 2>/dev/null || true)"
[ "$hn" = "server01.example.local" ] && pass "Hostname set to server01.example.local" || fail "Hostname expected server01.example.local, got ${hn:-<none>}"

# Active connection + IPv4 method
active_conn="$(nmcli -t -f NAME,DEVICE connection show --active 2>/dev/null | head -n1 | cut -d: -f1 || true)"
if [ -n "$active_conn" ]; then
  pass "Active connection found: $active_conn"
  method="$(nmcli -g ipv4.method connection show "$active_conn" 2>/dev/null || true)"
  [ "$method" = "manual" ] && pass "ipv4.method is manual for $active_conn" || fail "ipv4.method expected manual for $active_conn, got ${method:-<none>}"

  addrs="$(nmcli -g ipv4.addresses connection show "$active_conn" 2>/dev/null || true)"
  if [ -n "$addrs" ]; then pass "ipv4.addresses set: $addrs"; else fail "ipv4.addresses not set for $active_conn"; fi

  gw="$(nmcli -g ipv4.gateway connection show "$active_conn" 2>/dev/null || true)"
  if [ -n "$gw" ]; then pass "ipv4.gateway set: $gw"; else warn "ipv4.gateway not set (may be OK depending on lab environment)"; fi
else
  fail "No active NetworkManager connection found"
fi

summary_exit
