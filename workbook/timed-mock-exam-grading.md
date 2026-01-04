# RHCSA (EX200) Timed Mock Exam – Grading Checklist (RHEL 10)

This checklist is used to **objectively score** the timed mock exam.  
It mirrors **Red Hat grading philosophy**: outcomes, persistence, and correctness.

Use this checklist **after completing the mock exam and rebooting**.

---

## Grading Rules (READ FIRST)

- All checks are performed **after a reboot**
- SELinux must be **Enforcing**
- firewalld must be **running**
- Partial completion earns **zero points** for that task
- If a task breaks another task, **both may fail**

---

## Global System Checks (MANDATORY)

These checks apply to the entire exam.

- `getenforce` returns **Enforcing**
- `systemctl status firewalld` shows running
- System boots without errors
- No services fail to start at boot

If any global check fails:
- **Exam is FAILED**, regardless of task scores

---

## TASK 1 – Users, Groups, and Sudo (15 points)

### Pass Criteria

- Group `engineering` exists
- User `devuser` exists
  - Primary group: engineering
  - Login shell: `/bin/bash`
- User `audituser` exists
  - Primary group: engineering
- Sudo configuration:
  - Members of `engineering` can run:
    - `systemctl status`
    - `journalctl`
  - No password required
  - No unrestricted sudo access
- `audituser` account is locked

### Validation Commands
```
getent group engineering
id devuser
id audituser
sudo -l
passwd -S audituser
```

### Scoring
- All criteria met: **15 points**
- Any item missing: **0 points**

---

## TASK 2 – Storage and LVM (20 points)

### Pass Criteria

- Unused disk correctly identified
- Volume group `vgexam` exists
- Logical volume `lvdata` exists (4G)
- Filesystem type: XFS
- Mount point `/examdata` exists
- Filesystem mounted at `/examdata`
- Entry exists in `/etc/fstab`
- Mount survives reboot

### Validation Commands
```
lsblk
pvs
vgs
lvs
df -h /examdata
mount -a
```

### Scoring
- All criteria met: **20 points**
- Any item missing: **0 points**

---

## TASK 3 – Networking (15 points)

### Pass Criteria

- Static IPv4 address configured
- Correct subnet and gateway
- DNS configured
- Hostname set to `node01.exam.local`
- Network connectivity functional
- Configuration persists after reboot

### Validation Commands
```
ip a
ip route
hostnamectl
ping -c 3 <gateway>
```

### Scoring
- All criteria met: **15 points**
- Any item missing: **0 points**

---

## TASK 4 – Services and Firewall (15 points)

### Pass Criteria

- `httpd` package installed
- Service is running
- Service enabled at boot
- Firewall allows HTTP traffic
- Service responds locally
- Configuration persists after reboot

### Validation Commands
```
rpm -q httpd
systemctl status httpd
systemctl is-enabled httpd
firewall-cmd --list-services
curl http://localhost
```

### Scoring
- All criteria met: **15 points**
- Any item missing: **0 points**

---

## TASK 5 – SELinux (15 points)

### Pass Criteria

- SELinux remains Enforcing
- Custom document root `/examweb` exists
- Apache configured to use `/examweb`
- Correct SELinux context applied
- Access works without disabling SELinux
- Configuration persists after reboot

### Validation Commands
```
getenforce
ls -Z /examweb
curl http://localhost
```

### Scoring
- All criteria met: **15 points**
- Any item missing: **0 points**

---

## TASK 6 – Archiving and Compression (10 points)

### Pass Criteria

- Directory `/backupdata` exists
- At least two files present
- gzip archive created
- bzip2 archive created
- Archive contents verified

### Validation Commands
```
tar -tzf /root/backup.tar.gz
tar -tjf /root/backup.tar.bz2
```

### Scoring
- All criteria met: **10 points**
- Any item missing: **0 points**

---

## TASK 7 – Bash Scripting (10 points)

### Pass Criteria

- Script `/root/check_service.sh` exists
- Script executable
- Accepts service name as argument
- Correct exit codes:
  - 0 if active
  - Non-zero if inactive
- Produces meaningful output

### Validation Commands
```
./check_service.sh httpd
echo $?
```

### Scoring
- All criteria met: **10 points**
- Any item missing: **0 points**

---

## TASK 8 – Containers (Podman) (20 points)

### Pass Criteria

- Container `examctr` exists
- Container running
- Port mapping `8081:80` active
- Firewall allows `8081/tcp`
- Container starts automatically at boot
- Service reachable after reboot

### Validation Commands
```
podman ps
firewall-cmd --list-ports
systemctl status container-examctr
curl http://localhost:8081
```

### Scoring
- All criteria met: **20 points**
- Any item missing: **0 points**

---

## Final Scoring Summary

| Task | Points |
|----|----|
| Task 1 | 15 |
| Task 2 | 20 |
| Task 3 | 15 |
| Task 4 | 15 |
| Task 5 | 15 |
| Task 6 | 10 |
| Task 7 | 10 |
| Task 8 | 20 |
| **Total** | **120** |

---

## Pass / Fail Interpretation

- **90+ points:** Very strong – exam-ready
- **75–89 points:** Likely pass
- **60–74 points:** Borderline – review weak areas
- **<60 points:** Not ready – repeat labs

---

## Examiner’s Final Check (MOST IMPORTANT)

Ask yourself:

- Did everything survive reboot?
- Did I keep SELinux enforcing?
- Did I avoid unnecessary configuration?
- Did I validate before moving on?

If yes, you passed **the right way**.

---

**Correct. Persistent. Secure.**

That is what RHCSA tests.
