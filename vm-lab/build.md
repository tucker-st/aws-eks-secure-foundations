# VM Build Guide – RHCSA (EX200) Practice – RHEL 10

This guide describes how to build a **clean, exam-realistic virtual machine**
for RHCSA (EX200) practice using **RHEL 10** or a compatible rebuild.

The goal is to mirror **Red Hat exam conditions** as closely as possible.

---

## Design Principles

- Minimal installation
- One system (exam style)
- No GUI
- No automation that hides learning
- SELinux enforcing
- firewalld enabled
- Easy reset between labs

---

## Supported Hypervisors

Any of the following are acceptable:

- KVM / libvirt (recommended)
- VMware Workstation or Fusion
- VirtualBox
- Proxmox

Cloud VMs are **not recommended** for exam-style practice.

---

## VM Hardware Requirements

Minimum recommended configuration:

- vCPU: 2
- Memory: 4 GB RAM
- Disk: 30–40 GB
- Network: NAT or bridged

---

## Operating System

- Red Hat Enterprise Linux 10
- Or compatible rebuild (Rocky / Alma)

Use the **Server** or **Minimal** ISO.

---

## Installation Options

Choose **one**:
- Minimal Install (preferred)
- Server (no GUI)

Do **NOT** install a desktop environment.

---

## Disk Layout

During installation:
- Use **automatic partitioning**
- Do **not** manually create LVM yet

LVM will be created during labs.

---

## User Accounts

During installation:

- Set a **root password**
- Create one **non-root user**
- Add the user to the `wheel` group

This mirrors RHCSA exam expectations.

---

## Network Configuration

During install:
- Use DHCP
- Do not hardcode static IPs yet

Static networking is configured in Lab 03.

---

## First Boot Checklist

After first login, verify:

```
hostnamectl
ip a
lsblk
df -h
getenforce
systemctl status firewalld
```

Expected:
- SELinux: Enforcing
- firewalld: running
- Network functional
- Clean boot

---

## Required Packages

Install only what is needed:

```
dnf install -y \
  vim \
  bash-completion \
  podman \
  firewalld
```

Do **NOT** install:
- Docker
- Kubernetes
- Ansible
- Desktop packages

---

## Enable Required Services

Ensure firewalld is enabled:

```
systemctl enable --now firewalld
```

Verify:

```
systemctl is-enabled firewalld
systemctl status firewalld
```

---

## Time and Locale (Optional)

Set timezone (optional but recommended):

```
timedatectl set-timezone UTC
```

---

## Snapshot Strategy (CRITICAL)

Before starting labs:

- Take a snapshot named:
  ```
  clean-base
  ```

Before each lab:
1. Revert to `clean-base`
2. Perform the lab
3. Validate
4. Revert again

This simulates **exam resets** and prevents cross-lab contamination.

---

## Internet Access Guidance

- Internet access may be available
- Practice as if documentation is unavailable
- Do not rely on external references

Build muscle memory.

---

## What NOT to Install

Do NOT install:

- GUI environments
- Configuration management tools
- Extra services
- Third-party repos

The exam environment is minimal.

---

## Final VM Readiness Checklist

Before starting Lab 01:

- System boots cleanly
- SELinux enforcing
- firewalld running
- Root + wheel user available
- Snapshot created

If all checks pass, the VM is ready.

---

## Next Step

Proceed to:

- `vm-lab/reset.md`
- Then `labs/lab01-users`

---

**Make it work.  
Make it persistent.  
Validate everything.**