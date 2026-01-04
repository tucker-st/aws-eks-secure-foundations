# Lab 07 - Bash Scripting Fundamentals (RHEL 10)

Goal: Practice writing simple, reliable Bash scripts to automate system tasks aligned to RHCSA (EX200).

This lab focuses on correctness, readability, argument handling, and safe re-runs.

---

## EX200 Objectives Covered

- Create and execute simple shell scripts
- Use conditionals, loops, and positional parameters
- Automate basic system administration tasks
- Validate script behavior and exit status

---

## Prerequisites

- RHEL 10 VM
- Root or wheel access
- Basic familiarity with Bash
- Snapshot taken (recommended)

---

## Lab Scenario

Administrators often automate repetitive tasks using shell scripts.
You must create scripts that:
- Accept input arguments
- Perform checks before making changes
- Are safe to run multiple times
- Produce predictable results

---

## Script Rules (EXAM IMPORTANT)

- Must start with a valid shebang
- Must be executable
- Must handle missing arguments
- Must not fail when re-run
- Must exit with appropriate status codes

---

## Task 1 - Script Skeleton and Argument Handling

Create a script named `create_user.sh`.

Script content:
```
#!/bin/bash

if [ $# -ne 1 ]; then
  echo "Usage: $0 <username>"
  exit 1
fi

USER="$1"

id "$USER" &>/dev/null && {
  echo "User $USER already exists"
  exit 0
}

useradd "$USER"
echo "User $USER created"
```

Make executable:
```
chmod +x create_user.sh
```

Test:
```
./create_user.sh testuser
./create_user.sh testuser
```

Expected:
- First run creates user
- Second run exits cleanly

---

## Task 2 - FOR Loop Automation

Create a script named `bulk_users.sh`.

Script content:
```
#!/bin/bash

USERS="dev1 dev2 dev3"

for USER in $USERS; do
  id "$USER" &>/dev/null || useradd "$USER"
done
```

Make executable:
```
chmod +x bulk_users.sh
```

Validate:
```
id dev1
id dev2
id dev3
```

---

## Task 3 - WHILE Loop with Input File

Create a file named `users.txt`:
```
usera
userb
userc
```

Create script `users_from_file.sh`:

```
#!/bin/bash

while read USER; do
  [ -z "$USER" ] && continue
  id "$USER" &>/dev/null || useradd "$USER"
done < users.txt
```

Make executable:
```
chmod +x users_from_file.sh
```

Test:
```
./users_from_file.sh
```

---

## Task 4 - WHILE Loop for Service Check

Create script `wait_for_service.sh`:

```
#!/bin/bash

SERVICE=httpd

while ! systemctl is-active --quiet "$SERVICE"; do
  echo "Waiting for $SERVICE..."
  sleep 2
done

echo "$SERVICE is running"
```

Make executable:
```
chmod +x wait_for_service.sh
```

Test:
```
./wait_for_service.sh
```

---

## Task 5 - CASE Statement Control Script

Create script `service_ctl.sh`:

```
#!/bin/bash

case "$1" in
  start)
    systemctl start httpd
    ;;
  stop)
    systemctl stop httpd
    ;;
  status)
    systemctl status httpd
    ;;
  *)
    echo "Usage: $0 {start|stop|status}"
    exit 1
    ;;
esac
```

Make executable:
```
chmod +x service_ctl.sh
```

Test:
```
./service_ctl.sh status
```

---

## Auto-Grading Checklist

- Scripts contain valid shebang
- Scripts are executable
- Arguments validated correctly
- FOR loop creates users safely
- WHILE loop handles input correctly
- CASE statement routes commands correctly
- Scripts safe to run multiple times

---

## Common Exam Failures

- Missing shebang
- Forgetting chmod +x
- Hardcoding values incorrectly
- Overcomplicating logic
- Not testing scripts

---

## Reset (Optional)

To clean up users:
```
userdel -r testuser dev1 dev2 dev3 usera userb userc
```

To remove scripts:
```
rm -f create_user.sh bulk_users.sh users_from_file.sh wait_for_service.sh service_ctl.sh users.txt
```

---

## Next Lab

Proceed to lab08-containers.
