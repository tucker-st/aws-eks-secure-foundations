# Manual Validation Checklists (RHCSA EX200 – RHEL 10)

These checklists define **what you should manually verify**, regardless of what the auto-grading scripts report.

This mirrors **Red Hat exam grading behavior**: outcomes, persistence, and correctness.

Use these checklists:
- Before running auto-graders
- After every reboot
- During mock exams

---

## Lab 01 – Users, Groups, and Sudo

### Manual Validation

- `getent group dev` returns group
- `getent group ops` returns group
- `id alice` shows:
  - User exists
  - Primary group = dev
  - Secondary group includes ops
- `id bob` shows:
  - User exists
  - Primary group = ops
- `getent passwd bob` shows shell `/bin/bash`
- File `/etc/sudoers.d/ops-lab01` exists
- `visudo -c` returns no errors
- As bob:
  ```
  sudo -l
  sudo systemctl status sshd
  sudo journalctl -n 5
  ```
- Bob cannot run unrestricted sudo commands
- `passwd -S bob` shows account locked

### Persistence Check
- Reboot system
- All users, groups, and sudo rules still present

---

## Lab 02 – Storage and LVM

### Manual Validation

- `lsblk` shows disk used for LVM
- `pvs` shows physical volume
- `vgs` shows vgdata
- `lvs` shows lvdata
- `blkid /dev/vgdata/lvdata` shows filesystem `xfs`
- Directory `/data` exists
- `df -h /data` shows mounted filesystem
- `/etc/fstab` contains entry for `/data`
- `mount -a` returns no errors

### Persistence Check
- Reboot system
- `/data` mounts automatically
- No boot errors

---

## Lab 03 – Networking

### Manual Validation

- `nmcli device status` shows connected interface
- `nmcli connection show --active` shows correct connection
- `ip a` shows static IPv4 address
- `ip route` shows default gateway
- `hostnamectl` shows `server01.example.local`
- `ping -c 3 <gateway>` succeeds
- `ping -c 3 8.8.8.8` succeeds

### Persistence Check
- Reboot system
- Static IP persists
- Hostname persists
- Network connectivity restored automatically

---

## Lab 04 – Services and Firewall

### Manual Validation

- `rpm -q httpd` shows package installed
- `systemctl status httpd` shows active
- `systemctl is-enabled httpd` returns enabled
- `ss -tulnp | grep :80` shows listening service
- `firewall-cmd --list-services` includes http
- `curl http://localhost` returns HTML

### Persistence Check
- Reboot system
- httpd starts automatically
- Firewall rule still present

---

## Lab 05 – SELinux

### Manual Validation

- `getenforce` returns Enforcing
- Directory `/webdata` exists
- File `/webdata/index.html` exists
- `ls -Z /webdata` shows `httpd_sys_content_t`
- Apache serves content:
  ```
  curl http://localhost
  ```
- No SELinux denials blocking access

### Persistence Check
- Reboot system
- SELinux still enforcing
- Context remains correct
- Web content still accessible

---

## Lab 06 – Archiving and Compression

### Manual Validation

- `/root/project_backup.tar.gz` exists
- `/root/project_backup.tar.bz2` exists
- `tar -tzf` lists gzip archive contents
- `tar -tjf` lists bzip2 archive contents
- Extracted files exist in `/restore/project`
- Ownership and permissions preserved

### Persistence Check
- Not applicable (files do not auto-mount)

---

## Lab 07 – Bash Scripting

### Manual Validation

For each script:
- File exists
- First line is valid shebang (`#!/bin/bash`)
- Script is executable
- Script runs without errors

Specific checks:
- `create_user.sh`:
  - Creates user if missing
  - Does not fail when re-run
- `bulk_users.sh`:
  - Creates multiple users safely
- `users_from_file.sh`:
  - Reads input file correctly
- `wait_for_service.sh`:
  - Waits until service becomes active
- `service_ctl.sh`:
  - start | stop | status work correctly

### Persistence Check
- Not applicable (scripts are manual tools)

---

## Lab 08 – Containers (Podman)

### Manual Validation

- `podman images` shows pulled image
- `podman ps` shows container running
- `ss -tulnp | grep 8080` shows listening port
- `firewall-cmd --list-ports` includes `8080/tcp`
- `curl http://localhost:8080` returns content
- `/container-data` exists
- `ls -Z /container-data` shows proper SELinux labeling
- `systemctl status container-webtest` shows active
- `systemctl is-enabled container-webtest` shows enabled

### Persistence Check
- Reboot system
- Container starts automatically
- Web service accessible after reboot

---

## Exam Reality Check (IMPORTANT)

If:
- The system reboots cleanly
- Required services start automatically
- SELinux is enforcing
- Firewall rules persist
- Functionality works as required

Then the task would be considered **correct on the exam**.

Scripts and checklists exist to support you — not replace understanding.

---

## Final Recommendation

Always trust:
1. Manual validation
2. Reboot testing
3. Outcome verification

Auto-graders are helpers, not judges.
