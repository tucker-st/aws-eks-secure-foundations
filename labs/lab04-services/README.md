# Lab 04 - Services and Firewall Management (RHEL 10)

Goal: Practice installing, managing, and securing system services using systemd and firewalld, aligned to RHCSA (EX200).

This lab emphasizes service persistence, firewall configuration, and validation.

---

## EX200 Objectives Covered

- Install and manage software packages
- Start, stop, enable, and verify system services
- Configure firewall rules using firewalld
- Validate service availability

---

## Prerequisites

- RHEL 10 VM
- Root or wheel access
- Network connectivity to package repositories
- Snapshot taken (recommended)

---

## Lab Scenario

A web service must be deployed and secured according to baseline standards.

You must:
- Install a service
- Ensure it starts at boot
- Open the required firewall port
- Validate access

---

## Tasks

### Task 1 - Install Web Service

Install the Apache HTTP server package.

Command:
```
dnf install -y httpd
```

Validate:
```
rpm -q httpd
```

Expected:
- httpd package installed

---

### Task 2 - Start and Enable Service

Start the httpd service and enable it at boot.

Commands:
```
systemctl start httpd
systemctl enable httpd
```

Validate:
```
systemctl status httpd
systemctl is-enabled httpd
```

Expected:
- Service is active
- Service is enabled

---

### Task 3 - Verify Listening Port

Confirm the service is listening on port 80.

Command:
```
ss -tulnp | grep :80
```

Expected:
- httpd process listening on TCP port 80

---

### Task 4 - Configure Firewall

Allow HTTP traffic through the firewall permanently.

Commands:
```
firewall-cmd --add-service=http --permanent
firewall-cmd --reload
```

Validate:
```
firewall-cmd --list-services
```

Expected:
- http service listed

---

### Task 5 - Test Local Access

Verify the web service responds locally.

Commands:
```
curl http://localhost
```

Expected:
- HTML content returned
- No connection errors

---

### Task 6 - Reboot Validation (CRITICAL)

Reboot the system.

After reboot, validate:
```
systemctl status httpd
firewall-cmd --list-services
ss -tulnp | grep :80
```

Expected:
- httpd service running
- Firewall rule persists
- Port 80 open

---

## Auto-Grading Checklist

- httpd package installed
- httpd service started
- httpd service enabled at boot
- Firewall allows HTTP service permanently
- Service reachable locally
- Configuration persists after reboot

---

## Common Exam Failures

- Forgetting to enable the service
- Adding firewall rules without --permanent
- Forgetting to reload firewalld
- Not validating service status
- Skipping reboot validation

---

## Reset (Optional)

To reset the lab:
```
systemctl stop httpd
systemctl disable httpd
dnf remove -y httpd
firewall-cmd --remove-service=http --permanent
firewall-cmd --reload
```

---

## Next Lab

Proceed to lab05-selinux.
