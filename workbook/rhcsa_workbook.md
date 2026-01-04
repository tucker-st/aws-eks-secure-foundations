# RHCSA (EX200) Workbook – RHEL 10

This workbook provides **structured, hands-on practice** for the  
**Red Hat Certified System Administrator (RHCSA) – EX200** exam.

It is designed to:
- Mirror exam conditions
- Reinforce persistence and validation
- Build real operational confidence
- Serve as a long-term reference

---

## How to Use This Workbook

Recommended workflow:

1. Build a clean VM (see `vm-lab/build.md`)
2. Take a snapshot
3. Complete labs **in order**
4. Reboot after each lab
5. Manually validate outcomes
6. Use auto-grading scripts as a final check

---

## Exam Mindset (READ FIRST)

- Red Hat grades **results**, not commands
- Reboot persistence is mandatory
- SELinux must remain **Enforcing**
- firewalld must remain **running**
- Partial solutions do not earn credit

---

## Lab 01 – Users, Groups, and Sudo

### Objectives
- Manage local users and groups
- Configure restricted sudo access

### Skills Practiced
- useradd, usermod, groupadd
- sudoers drop-ins
- Account locking

### Validation Focus
- Correct group membership
- Least-privilege sudo
- Persistence after reboot

---

## Lab 02 – Storage and LVM

### Objectives
- Create and manage LVM storage
- Configure persistent mounts

### Skills Practiced
- pvcreate, vgcreate, lvcreate
- mkfs.xfs
- /etc/fstab management

### Validation Focus
- Correct filesystem
- Mount survives reboot
- No boot errors

---

## Lab 03 – Networking

### Objectives
- Configure static IPv4 networking
- Manage connections using NetworkManager

### Skills Practiced
- nmcli connection management
- Hostname configuration
- Connectivity validation

### Validation Focus
- IP persistence
- Hostname persistence
- Network availability after reboot

---

## Lab 04 – Services and Firewall

### Objectives
- Manage systemd services
- Configure firewall access

### Skills Practiced
- systemctl start/enable
- firewalld services and ports
- Service validation

### Validation Focus
- Service starts automatically
- Firewall rules persist
- Service accessible

---

## Lab 05 – SELinux

### Objectives
- Diagnose SELinux access issues
- Apply persistent context fixes

### Skills Practiced
- ls -Z, restorecon
- semanage fcontext
- Troubleshooting under enforcing mode

### Validation Focus
- SELinux remains enforcing
- Correct context persists
- Service functions securely

---

## Lab 06 – Archiving and Compression

### Objectives
- Create and restore compressed archives
- Preserve permissions and ownership

### Skills Practiced
- tar with gzip and bzip2
- Archive verification
- Restore testing

### Validation Focus
- Archive integrity
- Correct extraction
- Ownership preserved

---

## Lab 07 – Bash Scripting

### Objectives
- Automate tasks using Bash scripts
- Use loops and conditionals safely

### Skills Practiced
- Shebangs and permissions
- for, while, case
- Argument validation

### Validation Focus
- Scripts executable
- Safe re-runs
- Predictable output

---

## Lab 08 – Containers (Podman)

### Objectives
- Run and manage containers
- Configure persistence with systemd

### Skills Practiced
- podman run, inspect
- Port mapping
- SELinux-safe volumes
- systemd integration

### Validation Focus
- Container starts at boot
- Firewall allows access
- Service reachable after reboot

---

## Manual Validation (Exam Habit)

Always manually check:

- Users/groups exist
- Filesystems mounted
- Services active and enabled
- Firewall rules present
- SELinux enforcing
- Functionality works

Never trust configuration without validation.

---

## Auto-Grading Usage

Auto-grading scripts are provided to assist review.

Run:
```
sudo ./scripts/autograde/grade_all.sh
```

Important:
- Scripts are read-only
- Manual validation takes priority
- Passing scripts ≠ passing exam

---

## Day-of-Exam Strategy

1. Read the task completely
2. Plan before typing
3. Implement cleanly
4. Validate immediately
5. Reboot when required
6. Re-validate after reboot

---

## Common Exam Failure Patterns

- Forgetting to enable services
- Missing /etc/fstab entries
- Breaking sudo syntax
- Disabling SELinux
- Not validating persistence
- Rushing without checking

---

## Final Readiness Checklist

Before exam day, ensure you can:

- Complete all labs without notes
- Fix SELinux issues confidently
- Recover from mistakes quickly
- Validate everything from memory

If you can do that, you are ready.

---

## Disclaimer

This workbook is an **independent educational resource**.

It is **not affiliated with or endorsed by Red Hat, Inc.**  
No proprietary or confidential exam content is included.

---

**Practice clean.  
Validate everything.  
Reboot often.**