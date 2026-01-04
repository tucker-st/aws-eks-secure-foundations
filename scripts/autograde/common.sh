#!/bin/bash
# Common helpers for RHCSA autograding (read-only checks)

set -u

PASS_COUNT=0
FAIL_COUNT=0
WARN_COUNT=0

green() { printf "\033[0;32m%s\033[0m\n" "$*"; }
red()   { printf "\033[0;31m%s\033[0m\n" "$*"; }
yellow(){ printf "\033[0;33m%s\033[0m\n" "$*"; }

pass() { green "[PASS] $*"; PASS_COUNT=$((PASS_COUNT+1)); }
fail() { red   "[FAIL] $*"; FAIL_COUNT=$((FAIL_COUNT+1)); }
warn() { yellow "[WARN] $*"; WARN_COUNT=$((WARN_COUNT+1)); }

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || { fail "Missing required command: $1"; return 1; }
  return 0
}

file_exists() {
  local f="$1"
  [ -f "$f" ] && pass "File exists: $f" || fail "Missing file: $f"
}

dir_exists() {
  local d="$1"
  [ -d "$d" ] && pass "Directory exists: $d" || fail "Missing directory: $d"
}

is_root() {
  [ "${EUID:-$(id -u)}" -eq 0 ]
}

require_root_or_warn() {
  if ! is_root; then
    warn "Not running as root. Some checks may be incomplete. Consider: sudo $0"
  fi
}

check_group_exists() {
  local g="$1"
  getent group "$g" >/dev/null 2>&1 && pass "Group exists: $g" || fail "Group missing: $g"
}

check_user_exists() {
  local u="$1"
  id "$u" >/dev/null 2>&1 && pass "User exists: $u" || fail "User missing: $u"
}

check_user_primary_group() {
  local u="$1" g="$2"
  local actual
  actual="$(id -gn "$u" 2>/dev/null || true)"
  [ "$actual" = "$g" ] && pass "$u primary group is $g" || fail "$u primary group expected $g, got ${actual:-<none>}"
}

check_user_in_group() {
  local u="$1" g="$2"
  id -nG "$u" 2>/dev/null | tr ' ' '\n' | grep -qx "$g" && pass "$u is member of $g" || fail "$u is NOT member of $g"
}

check_user_shell() {
  local u="$1" shell_expected="$2"
  local shell_actual
  shell_actual="$(getent passwd "$u" | cut -d: -f7)"
  [ "$shell_actual" = "$shell_expected" ] && pass "$u shell is $shell_expected" || fail "$u shell expected $shell_expected, got ${shell_actual:-<none>}"
}

check_account_locked() {
  local u="$1"
  local st
  st="$(passwd -S "$u" 2>/dev/null | awk '{print $2}' || true)"
  [ "$st" = "L" ] && pass "Account locked: $u" || fail "Account not locked (expected locked): $u"
}

check_systemd_active_enabled() {
  local svc="$1"
  systemctl is-active --quiet "$svc" && pass "Service active: $svc" || fail "Service NOT active: $svc"
  systemctl is-enabled --quiet "$svc" && pass "Service enabled: $svc" || fail "Service NOT enabled: $svc"
}

check_firewalld_service() {
  local s="$1"
  firewall-cmd --list-services 2>/dev/null | tr ' ' '\n' | grep -qx "$s" && pass "Firewalld service allowed: $s" || fail "Firewalld service NOT allowed: $s"
}

check_firewalld_port() {
  local p="$1"  # ex: 8080/tcp
  firewall-cmd --list-ports 2>/dev/null | tr ' ' '\n' | grep -qx "$p" && pass "Firewalld port allowed: $p" || fail "Firewalld port NOT allowed: $p"
}

check_mountpoint() {
  local mp="$1"
  mountpoint -q "$mp" && pass "Mounted: $mp" || fail "Not mounted: $mp"
}

check_fstab_has_mount() {
  local mp="$1"
  grep -E "^[^#].*\s${mp}\s" /etc/fstab >/dev/null 2>&1 && pass "/etc/fstab has entry for $mp" || fail "/etc/fstab missing entry for $mp"
}

check_selinux_enforcing() {
  local st
  st="$(getenforce 2>/dev/null || true)"
  [ "$st" = "Enforcing" ] && pass "SELinux Enforcing" || fail "SELinux not Enforcing (got: ${st:-<none>})"
}

check_file_context_type() {
  local path="$1" type_expected="$2"
  local out type_actual
  out="$(ls -Z "$path" 2>/dev/null || true)"
  type_actual="$(printf "%s" "$out" | awk '{print $1}' | awk -F: '{print $3}' || true)"
  [ "$type_actual" = "$type_expected" ] && pass "SELinux type OK for $path: $type_expected" || fail "SELinux type for $path expected $type_expected, got ${type_actual:-<none>}"
}

summary_exit() {
  echo
  echo "===== SUMMARY ====="
  echo "PASS: $PASS_COUNT"
  echo "FAIL: $FAIL_COUNT"
  echo "WARN: $WARN_COUNT"
  echo "==================="
  echo
  [ "$FAIL_COUNT" -eq 0 ]
}
