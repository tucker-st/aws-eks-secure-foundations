# RHCSA (EX200) Timed Mock Exam – RHEL 10

This is a **full, exam-style mock test** designed to simulate real RHCSA (EX200)
conditions as closely as possible.

- **Time limit:** 2 hours 30 minutes  
- **Environment:** Single RHEL 10 system  
- **Rules:** No internet, no notes, no man pages beyond `man` on the system  
- **Scoring:** Outcome-based (not command-based)

---

## Exam Rules (READ CAREFULLY)

- Do **not** disable SELinux
- Do **not** stop firewalld permanently
- All required configuration must **persist after reboot**
- Partial completion earns **no credit**
- Validate your work before moving on

---

## Exam Setup (5 Minutes – NOT SCORED)

1. Revert VM to snapshot:
   ```
   clean-base
   ```
2. Start timer
3. Log in as root or wheel user
4. Do **not** create additional snapshots

---

## TASK 1 – Users, Groups, and Sudo (15 points)

### Requirements

1. Create group `engineering`
2. Create user `devuser`
   - Primary group: engineering
   - Home directory required
   - Login shell: `/bin/bash`
3. Create user `audituser`
   - Primary group: engineering
4. Configure sudo so:
   - Members of `engineering` can run:
     - `systemctl status`
     - `journalctl`
   - No password required
5. Lock the `audituser` account

### Validation Hints
```
id devuser
id audituser
sudo -l
passwd -S audituser
```

---

## TASK 2 – Storage and LVM (20 points)

### Requirements

1. Identify unused disk (example: `/dev/sdb`)
2. Create LVM layout:
   - VG: `vgexam`
   - LV: `lvdata` (size 4G)
3. Create XFS filesystem
4. Mount at `/examdata`
5. Ensure mount persists after reboot

### Validation Hints
```
lsblk
pvs
vgs
lvs
df -h /examdata
mount -a
```

---

## TASK 3 – Networking (15 points)

### Requirements

1. Configure active network interface with:
   - Static IPv4 address: `192.168.100.50/24`
   - Gateway: `192.168.100.1`
   - DNS: `1.1.1.1`
2. Set hostname to:
   ```
   node01.exam.local
   ```

### Validation Hints
```
ip a
ip route
hostnamectl
```

---

## TASK 4 – Services and Firewall (15 points)

### Requirements

1. Install and configure `httpd`
2. Ensure service:
   - Is running
   - Starts automatically at boot
3. Allow HTTP traffic through firewall
4. Verify service responds locally

### Validation Hints
```
systemctl status httpd
systemctl is-enabled httpd
firewall-cmd --list-services
curl http://localhost
```

---

## TASK 5 – SELinux (15 points)

### Requirements

1. Create directory:
   ```
   /examweb
   ```
2. Place an `index.html` file in it
3. Configure Apache to use `/examweb` as DocumentRoot
4. Fix SELinux issues **without disabling SELinux**
5. Ensure access works under enforcing mode

### Validation Hints
```
getenforce
ls -Z /examweb
curl http://localhost
```

---

## TASK 6 – Archiving and Compression (10 points)

### Requirements

1. Create directory `/backupdata`
2. Place at least two files inside
3. Create:
   - gzip archive: `/root/backup.tar.gz`
   - bzip2 archive: `/root/backup.tar.bz2`
4. Verify contents of both archives

### Validation Hints
```
tar -tzf /root/backup.tar.gz
tar -tjf /root/backup.tar.bz2
```

---

## TASK 7 – Bash Scripting (10 points)

### Requirements

1. Create script `/root/check_service.sh`
2. Script must:
   - Accept service name as argument
   - Check if service is active
   - Print meaningful message
   - Exit 0 if active, non-zero otherwise
3. Script must be executable

### Validation Hints
```
./check_service.sh httpd
echo $?
```

---

## TASK 8 – Containers (Podman) (20 points)

### Requirements

1. Run a container using Podman:
   - Image: `nginx`
   - Name: `examctr`
   - Port mapping: `8081:80`
2. Configure firewall to allow access
3. Ensure container:
   - Starts automatically at boot
4. Verify access after reboot

### Validation Hints
```
podman ps
firewall-cmd --list-ports
curl http://localhost:8081
systemctl status container-examctr
```

---

## FINAL STEP – REBOOT VALIDATION (MANDATORY)

Reboot the system.

After reboot, validate **all tasks** again.

If anything is broken after reboot, it is **FAILED**.

---

## SCORING GUIDE

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

**Passing score:** ~70–75% equivalent

---

## SELF-EVALUATION

After finishing:

- Did you finish on time?
- Did everything survive reboot?
- Did SELinux remain enforcing?
- Did firewalld remain enabled?

If yes → **You are exam-ready**.

---

## IMPORTANT DISCLAIMER

This mock exam is an **original educational simulation**.

- Not affiliated with Red Hat
- Not based on real exam questions
- No proprietary or confidential material used

---

**Slow is smooth.  
Smooth is fast.  
Validate everything.**
