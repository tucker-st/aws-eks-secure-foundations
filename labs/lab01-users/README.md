# Lab 01 - Users, Groups, and Sudo (RHEL 10)

Goal: Practice local identity management and privilege escalation tasks aligned to RHCSA (EX200).

This lab is exam-realistic, repeatable, and useful as an on-the-job reference.

---

## EX200 Objectives Covered

- Create, delete, and modify local user accounts
- Create, delete, and modify local groups and memberships
- Configure superuser access (sudo)

---

## Prerequisites

- RHEL 10 VM
- Root or wheel access
- Snapshot taken (recommended)

---

## Lab Scenario

A system is being prepared for a new project team. You must create users and groups, enforce basic standards, and configure restricted sudo access.

---

## Tasks

### Task 1 - Create Groups

Create the following groups:
- dev
- ops

Commands:
```
groupadd dev
groupadd ops
```

Validate:
```
getent group dev
getent group ops
```

---

### Task 2 - Create Users

Create users with home directories:
- alice (primary group: dev)
- bob (primary group: ops)

Commands:
```
useradd -m -g dev alice
useradd -m -g ops bob
passwd alice
passwd bob
```

Validate:
```
id alice
id bob
ls -ld /home/alice /home/bob
```

---

### Task 3 - Secondary Group Membership

Add alice to the ops group.

Command:
```
usermod -aG ops alice
```

Validate:
```
id alice
getent group ops
```

---

### Task 4 - Default Shell

Ensure bob uses /bin/bash.

Command:
```
usermod -s /bin/bash bob
```

Validate:
```
getent passwd bob | cut -d: -f1,7
```

---

### Task 5 - Configure Sudo Access

Requirement:
Members of group ops may run ONLY:
- systemctl status
- journalctl

Steps:

Open sudoers file:
```
visudo -f /etc/sudoers.d/ops-lab01
```

Add:
```
%ops ALL=(ALL) NOPASSWD: /usr/bin/systemctl status *, /usr/bin/journalctl *
```

Validate:
```
visudo -c
```

Test:
```
su - bob
sudo -l
sudo systemctl status sshd
sudo journalctl -n 5
```

---

### Task 6 - Lock Account

Lock bob.

Command:
```
usermod -L bob
```

Validate:
```
passwd -S bob
```

---

## Auto-Grading Checklist

- dev group exists
- ops group exists
- alice primary group is dev
- bob primary group is ops
- alice is member of ops
- bob shell is /bin/bash
- sudo rule exists and works
- bob account is locked

---

## Common Exam Failures

- Editing /etc/sudoers directly
- Forgetting -a with usermod -G
- Breaking sudo syntax
- Not validating changes

---

## Reset (Optional)

```
userdel -r alice
userdel -r bob
groupdel dev
groupdel ops
rm -f /etc/sudoers.d/ops-lab01
visudo -c
```

---

## Next Lab

Proceed to lab02-storage.