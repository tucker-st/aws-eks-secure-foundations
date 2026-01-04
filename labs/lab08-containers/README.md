# Lab 08 - Container Management with Podman (RHEL 10)

Goal: Practice basic container management using Podman aligned to RHCSA (EX200).

This lab focuses on running containers, inspecting them, configuring networking and storage, and ensuring containers persist across reboots.

---

## EX200 Objectives Covered

- Run and manage containers using Podman
- Inspect and troubleshoot containers
- Configure port mappings
- Use volumes with SELinux
- Configure containers to start at boot

---

## Prerequisites

- RHEL 10 VM
- Root or wheel access
- podman installed
- firewalld running
- Snapshot taken (recommended)

---

## Lab Scenario

A lightweight web service must be deployed using containers.
You must:
- Pull an image
- Run a container
- Expose a service port
- Apply SELinux-safe volume access
- Make the container persistent

---

## Tasks

### Task 1 - Verify Podman Installation

Command:
```
podman --version
```

Expected:
- Podman version displayed

---

### Task 2 - Pull Container Image

Pull a Universal Base Image.

Command:
```
podman pull registry.redhat.io/ubi10/ubi
```

Validate:
```
podman images
```

Expected:
- Image listed locally

---

### Task 3 - Run a Basic Container

Run a detached container.

Command:
```
podman run -d --name webtest nginx
```

Validate:
```
podman ps
```

Expected:
- Container webtest running

---

### Task 4 - Inspect Container

Inspect container details.

Command:
```
podman inspect webtest
```

Validate:
- Container status
- Image name
- Network settings

---

### Task 5 - Expose Container Port

Stop and remove the existing container.

Commands:
```
podman stop webtest
podman rm webtest
```

Run container with port mapping.

Command:
```
podman run -d --name webtest -p 8080:80 nginx
```

Validate:
```
ss -tulnp | grep 8080
```

---

### Task 6 - Configure Firewall Access

Allow traffic on port 8080.

Commands:
```
firewall-cmd --add-port=8080/tcp --permanent
firewall-cmd --reload
```

Validate:
```
firewall-cmd --list-ports
```

---

### Task 7 - Test Container Access

Test local access.

Command:
```
curl http://localhost:8080
```

Expected:
- Default nginx page returned

---

### Task 8 - Use Volume with SELinux Context

Create host directory for content.

Commands:
```
mkdir -p /container-data
echo "Container test page" > /container-data/index.html
```

Stop and remove container:
```
podman stop webtest
podman rm webtest
```

Run container with volume and SELinux label.

Command:
```
podman run -d \
  --name webtest \
  -p 8080:80 \
  -v /container-data:/usr/share/nginx/html:Z \
  nginx
```

Validate:
```
curl http://localhost:8080
ls -Z /container-data
```

Expected:
- Custom content displayed
- SELinux context applied correctly

---

### Task 9 - Make Container Persistent (EXAM CRITICAL)

Generate systemd unit.

Command:
```
podman generate systemd --name webtest --files --new
```

Move and enable unit.

Commands:
```
mv container-webtest.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable --now container-webtest
```

Validate:
```
systemctl status container-webtest
```

---

### Task 10 - Reboot Validation

Reboot the system.

After reboot, validate:
```
podman ps
systemctl status container-webtest
curl http://localhost:8080
```

Expected:
- Container running
- Service active
- Web content accessible

---

## Auto-Grading Checklist

- Podman installed
- Image pulled successfully
- Container runs
- Port mapped correctly
- Firewall allows access
- SELinux-safe volume mount used
- Container persists after reboot

---

## Common Exam Failures

- Forgetting firewall rule
- Missing :Z on volume mount
- Not generating systemd unit
- Not validating after reboot
- Using Docker instead of Podman

---

## Reset (Optional)

To reset the lab:
```
systemctl stop container-webtest
systemctl disable container-webtest
rm -f /etc/systemd/system/container-webtest.service
systemctl daemon-reload
podman rm -f webtest
rm -rf /container-data
firewall-cmd --remove-port=8080/tcp --permanent
firewall-cmd --reload
```

---

## Lab Series Complete

You have completed all core RHCSA (EX200) practice labs.

Review the workbook, perform a timed mock run, and validate every task.
