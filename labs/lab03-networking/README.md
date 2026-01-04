# Lab 03 - Networking Configuration with nmcli (RHEL 10)

Goal: Practice network configuration and validation using NetworkManager tools aligned to RHCSA (EX200).

This lab focuses on persistence, correct interface handling, and verification.

---

## EX200 Objectives Covered

- Configure IPv4 networking and hostname resolution
- Manage network connections using NetworkManager (nmcli)
- Verify network configuration

---

## Prerequisites

- RHEL 10 VM
- Root or wheel access
- Active network interface (example: eth0 or ens33)
- Snapshot taken (recommended)

---

## Lab Scenario

A server must be configured with a static IPv4 address and hostname to meet infrastructure standards.

You must:
- Identify the active network interface
- Configure a static IPv4 address
- Set the system hostname
- Validate persistence after reboot

---

## Tasks

### Task 1 - Identify Active Network Interface

List network interfaces and identify the active connection.

Commands:
```
nmcli device status
ip a
```

Expected:
- One interface connected (STATE = connected)
- Interface name identified (example: eth0 or ens33)

---

### Task 2 - View Connection Profiles

List existing NetworkManager connections.

Command:
```
nmcli connection show
```

Expected:
- Connection profile associated with active interface

---

### Task 3 - Configure Static IPv4 Address

Modify the active connection to use a static IPv4 address.

Example values (adjust if required):
- IP address: 192.168.1.50/24
- Gateway: 192.168.1.1
- DNS: 8.8.8.8

Command:
```
nmcli connection modify <connection-name> \
  ipv4.method manual \
  ipv4.addresses 192.168.1.50/24 \
  ipv4.gateway 192.168.1.1 \
  ipv4.dns 8.8.8.8
```

Apply changes:
```
nmcli connection down <connection-name>
nmcli connection up <connection-name>
```

---

### Task 4 - Verify Network Configuration

Validate IP addressing and routing.

Commands:
```
ip a
ip route
nmcli device show <interface-name>
```

Expected:
- Static IP address assigned
- Default route present

---

### Task 5 - Configure Hostname

Set the system hostname to:
```
server01.example.local
```

Command:
```
hostnamectl set-hostname server01.example.local
```

Validate:
```
hostnamectl
hostname
```

---

### Task 6 - Network Connectivity Test

Verify basic network connectivity.

Commands:
```
ping -c 3 192.168.1.1
ping -c 3 8.8.8.8
```

Expected:
- Successful replies

---

### Task 7 - Reboot Validation (CRITICAL)

Reboot the system.

After reboot, validate:
```
hostname
ip a
nmcli connection show --active
```

Expected:
- Hostname persists
- Static IP persists
- Connection is active

---

## Auto-Grading Checklist

- Active network interface identified correctly
- Static IPv4 address configured
- Gateway configured
- DNS configured
- Hostname set correctly
- Network configuration persists after reboot
- Connectivity verified

---

## Common Exam Failures

- Modifying the wrong connection profile
- Forgetting to bring the connection down/up
- Using deprecated network scripts
- Not validating after reboot
- Typographical errors in IP configuration

---

## Reset (Optional)

To reset networking to DHCP:
```
nmcli connection modify <connection-name> ipv4.method auto
nmcli connection down <connection-name>
nmcli connection up <connection-name>
```

Reset hostname:
```
hostnamectl set-hostname localhost
```

---

## Next Lab

Proceed to lab04-services.
