# Lab 05 - SELinux Troubleshooting and Context Management (RHEL 10)

Goal: Practice diagnosing and resolving access issues using SELinux tools while keeping SELinux enforcing, aligned to RHCSA (EX200).

This lab emphasizes correct use of contexts, persistence, and validation.

---

## EX200 Objectives Covered

- Verify and adjust SELinux modes
- Identify and correct SELinux context problems
- Restore default file contexts
- Validate services under SELinux enforcing mode

---

## Prerequisites

- RHEL 10 VM
- Root or wheel access
- httpd installed and enabled (from Lab 04)
- SELinux in enforcing mode
- Snapshot taken (recommended)

---

## Lab Scenario

A web service fails to serve content even though the service is running and the firewall is open.

You must:
- Diagnose the SELinux-related cause
- Fix the issue without disabling SELinux
- Validate correct access

---

## Tasks

### Task 1 - Verify SELinux Status

Confirm SELinux is enforcing.

Command:
```
getenforce
```

Expected:
- Output is Enforcing

---

### Task 2 - Simulate an SELinux Context Issue

Create a custom directory and file for web content.

Commands:
```
mkdir /webdata
echo "SELinux test page" > /webdata/index.html
```

Set ownership and permissions:
```
chown -R root:root /webdata
chmod -R 755 /webdata
```

---

### Task 3 - Configure Apache to Use Custom Directory

Edit Apache configuration to use the new document root.

Edit:
```
/etc/httpd/conf/httpd.conf
```

Change or add:
```
DocumentRoot "/webdata"
<Directory "/webdata">
    AllowOverride None
    Require all granted
</Directory>
```

Restart the service:
```
systemctl restart httpd
```

---

### Task 4 - Observe Access Failure

Test access:
```
curl http://localhost
```

Expected:
- Access denied or empty response
- httpd service still running

---

### Task 5 - Identify SELinux Context Problem

Check SELinux context of the directory and file.

Command:
```
ls -Z /webdata /webdata/index.html
```

Expected:
- Context is not httpd_sys_content_t

---

### Task 6 - Restore Correct SELinux Context (TEMPORARY FIX)

Apply the default context recursively.

Command:
```
restorecon -Rv /webdata
```

Test again:
```
curl http://localhost
```

Expected:
- Web page content displayed

---

### Task 7 - Make Context Change Persistent (EXAM-IMPORTANT)

Define the correct context rule permanently.

Command:
```
semanage fcontext -a -t httpd_sys_content_t "/webdata(/.*)?"
```

Apply the context:
```
restorecon -Rv /webdata
```

Validate:
```
ls -Z /webdata/index.html
```

Expected:
- Context type is httpd_sys_content_t

---

### Task 8 - Reboot Validation (CRITICAL)

Reboot the system.

After reboot, validate:
```
getenforce
curl http://localhost
ls -Z /webdata/index.html
```

Expected:
- SELinux still enforcing
- Web content accessible
- Correct context persists

---

## Auto-Grading Checklist

- SELinux is enforcing
- httpd service running
- Custom document root configured
- Access failure observed before fix
- Correct SELinux context applied
- Context change persists after reboot
- Web content accessible

---

## Common Exam Failures

- Disabling SELinux instead of fixing context
- Forgetting to make fcontext rule persistent
- Skipping reboot validation
- Confusing permissions with SELinux issues
- Editing wrong Apache configuration file

---

## Reset (Optional)

To reset the lab:
```
sed -i 's|DocumentRoot "/webdata"|DocumentRoot "/var/www/html"|' /etc/httpd/conf/httpd.conf
sed -i '/<Directory "\/webdata">/,/<\/Directory>/d' /etc/httpd/conf/httpd.conf
systemctl restart httpd
rm -rf /webdata
semanage fcontext -d "/webdata(/.*)?"
```

---

## Next Lab

Proceed to lab06-archiving.