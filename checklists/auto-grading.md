# Auto-Grading Scripts - Usage Notes and False FAIL Prevention

The auto-grading scripts in this repository are **read-only validation tools**
designed to help you self-assess RHCSA (EX200) practice labs.

They are **not official Red Hat tools** and **do not replace manual verification**.

Use them as a **final checklist**, not as the only source of truth.

---

## General Rules (READ FIRST)

1. **Run as root whenever possible**
   ```
   sudo ./scripts/autograde/grade_all.sh
   ```
   Many checks require elevated privileges (users, SELinux, firewall, systemd).

2. **Auto-grading assumes labs were completed as written**
   - Names, paths, and services matter
   - Defaults are intentional and exam-aligned

3. **A FAIL does not always mean your solution is wrong**
   - It may mean the grader cannot safely detect your implementation
   - Always manually verify before redoing a lab

---

## Common Causes of False FAILS

### 1. Not Running as Root

Symptoms:
- FAIL on users, groups, sudo
- FAIL on SELinux or firewall
- FAIL on systemd checks

Fix:
```
sudo ./scripts/autograde/grade_all.sh
```

---

### 2. Different Names or Paths Than the Lab

The graders expect the following values:

Lab 01:
- Users: alice, bob
- Groups: dev, ops

Lab 02:
- Volume Group: vgdata
- Logical Volume: lvdata
- Mount point: /data

Lab 03:
- Hostname: server01.example.local

Lab 04:
- Service: httpd

Lab 05:
- Custom document root: /webdata

Lab 06:
- Archives:
  - /root/project_backup.tar.gz
  - /root/project_backup.tar.bz2

Lab 07:
- Scripts directory: /root/lab07

Lab 08:
- Container name: webtest
- Port: 8080

If you intentionally used different values:
- Update the corresponding script in scripts/autograde/
- OR re-run the lab using the documented values

---

### 3. Lab 07 (Scripting) Directory Assumption

By default, the Lab 07 grader expects scripts in:
```
/root/lab07
```

Containing:
- create_user.sh
- bulk_users.sh
- users_from_file.sh
- wait_for_service.sh
- service_ctl.sh
- users.txt

If your scripts are elsewhere:

1. Edit:
   ```
   scripts/autograde/lab07_scripting.sh
   ```
2. Change:
   ```
   LAB_DIR="/your/script/path"
   ```

This is the **most common source of false FAILS**.

---

### 4. Firewall and Network Environment Differences

Symptoms:
- FAIL on curl tests
- FAIL on firewall checks

Causes:
- firewalld not running
- Different firewall zones
- Offline or restricted VM

Checks:
```
systemctl status firewalld
firewall-cmd --list-all
```

If networking is intentionally restricted, WARN or FAIL is expected.

---

### 5. SELinux Context Detection Limitations

The SELinux grader checks **type labels**, not full policies.

If you used:
- Equivalent custom types
- Non-default httpd policies

The grader may FAIL even though the service works.

Always manually verify:
```
getenforce
ls -Z /webdata
curl http://localhost
```

If it works under enforcing mode, your solution is valid.

---

### 6. Containers and Timing Issues

Symptoms:
- FAIL immediately after reboot
- FAIL on container checks

Cause:
- systemd unit exists but container has not fully started

Fix:
- Wait 10 to 15 seconds after reboot
- Re-run the grader

Low-resource VMs may start containers slowly.

---

## How to Interpret Results

PASS:
- Requirement detected exactly as expected

WARN:
- Check could not be verified safely
- Manual validation recommended

FAIL:
- Expected state not detected
- Investigate before redoing the lab

---

## Recommended Workflow

1. Complete the lab manually
2. Reboot the system
3. Manually validate critical outcomes
4. Run the auto-grader
5. Investigate FAILs
6. Fix only if truly incorrect

Never blindly fix a lab just to satisfy the grader.

---

## Important Disclaimer

These scripts:
- Are educational tools
- Do not reflect Red Hat internal grading logic
- Reinforce exam habits, not memorization

Red Hat exams grade **outcomes**, not scripts.

---

## Final Advice

If:
- The service works
- The configuration persists
- SELinux is enforcing
- Firewall rules are correct

You are likely **exam-ready**, even if a script reports a FAIL.

Trust your validation skills first.
