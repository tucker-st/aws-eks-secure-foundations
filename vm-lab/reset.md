# VM Reset Guide – RHCSA (EX200) Practice – RHEL 10

This guide explains how to **safely reset your practice VM** between labs to
simulate real RHCSA exam conditions.

The goal is to ensure **clean state, repeatability, and no cross-lab contamination**.

---

## Why Resetting Matters (Exam Reality)

On the RHCSA exam:
- Each task is evaluated independently
- Leftover configuration can cause failures
- You cannot “undo” mistakes easily

Practicing with resets builds the **correct exam habit**.

---

## Recommended Reset Strategy (BEST PRACTICE)

### Use VM Snapshots

Snapshots are the **fastest and safest** way to reset.

#### Snapshot Naming Convention

Create ONE baseline snapshot after VM build:

```
clean-base
```

Do not modify this snapshot.

---

## Standard Lab Workflow

For **every lab**:

1. Revert VM to `clean-base`
2. Start the VM
3. Complete **one lab only**
4. Validate results
5. Reboot and validate again
6. Power off VM
7. Revert to `clean-base`

Repeat for the next lab.

---

## Hypervisor-Specific Notes

### KVM / libvirt
- Use virt-manager snapshots
- Or `virsh snapshot-revert`

### VMware Workstation / Fusion
- Use Snapshot Manager
- Avoid linked clones for exam practice

### VirtualBox
- Use full snapshots
- Avoid multiple snapshot chains

### Proxmox
- Use full VM snapshots
- Avoid live snapshots when possible

---

## Manual Reset (If Snapshots Are Not Available)

If you cannot use snapshots, **manual reset is required**.

### Manual Reset Checklist

Before starting a new lab, ensure:

- Users created in previous labs are removed
- Groups created in previous labs are removed
- Extra storage (LVM) removed
- Custom mount points removed
- Network settings returned to DHCP
- Services stopped and disabled
- Firewall rules removed
- Containers stopped and removed
- SELinux custom contexts removed

---

## Manual Reset Commands (Common)

### Users & Groups
```
userdel -r USER
groupdel GROUP
```

---

### Storage
```
umount /data
lvremove -y /dev/vgdata/lvdata
vgremove -y vgdata
pvremove -y /dev/sdX
sed -i '\|/data|d' /etc/fstab
```

---

### Networking
```
nmcli connection modify CONN ipv4.method auto
nmcli connection down CONN
nmcli connection up CONN
hostnamectl set-hostname localhost
```

---

### Services & Firewall
```
systemctl stop SERVICE
systemctl disable SERVICE
dnf remove -y PACKAGE
firewall-cmd --remove-service=SERVICE --permanent
firewall-cmd --remove-port=PORT/tcp --permanent
firewall-cmd --reload
```

---

### SELinux
```
semanage fcontext -d "PATH(/.*)?"
restorecon -Rv PATH
```

---

### Containers
```
systemctl stop container-NAME
systemctl disable container-NAME
rm -f /etc/systemd/system/container-NAME.service
systemctl daemon-reload
podman rm -f NAME
```

---

## Reset Validation (MANDATORY)

After reset, reboot the VM:

```
reboot
```

After reboot, confirm:

```
getenforce
systemctl status firewalld
lsblk
df -h
ip a
podman ps
```

Expected:
- SELinux enforcing
- firewalld running
- No extra mounts
- No leftover users or containers

---

## When to Use Manual Reset

Use manual reset ONLY if:
- Snapshots are unavailable
- Practicing disaster recovery
- Testing cleanup skills

Snapshots are always preferred.

---

## Exam Simulation Tip

Practice at least **one full lab cycle** using **manual reset only**.

This builds:
- Cleanup discipline
- Troubleshooting skills
- Confidence under pressure

---

## Final Rule

If you are unsure whether a system is clean:

**Reset it.**

Clean state prevents false failures.

---

## Next Step

After reset, proceed to:

```
labs/lab01-users
```

---

**Clean state.  
Clear thinking.  
Correct results.**