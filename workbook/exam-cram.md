# RHCSA (EX200) One-Page Exam Cram Sheet – RHEL 10

This is a **last-minute, muscle-memory reference** for the RHCSA exam.  
No explanations. No theory. **Only what you type on the exam.**

---

## Exam Rules (Mental Checklist)

- Think **outcomes**, not commands
- **Reboot breaks weak configs**
- SELinux stays **Enforcing**
- firewalld stays **running**
- Validate everything before moving on

---

## Users & Groups

Create group:
```
groupadd GROUP
```

Create user with home + primary group:
```
useradd -m -g GROUP USER
passwd USER
```

Add secondary group:
```
usermod -aG GROUP USER
```

Lock account:
```
usermod -L USER
```

Check:
```
id USER
getent group GROUP
passwd -S USER
```

---

## Sudo (SAFE METHOD)

Always use visudo:
```
visudo -f /etc/sudoers.d/FILE
```

Group rule example:
```
%GROUP ALL=(ALL) NOPASSWD: /usr/bin/command
```

Validate:
```
visudo -c
```

---

## Storage (LVM)

Identify disks:
```
lsblk
```

Create LVM:
```
pvcreate /dev/sdX
vgcreate vgname /dev/sdX
lvcreate -n lvname -L 5G vgname
```

Filesystem:
```
mkfs.xfs /dev/vgname/lvname
```

Mount:
```
mkdir /mountpoint
mount /dev/vgname/lvname /mountpoint
```

Persistent mount:
```
/dev/vgname/lvname /mountpoint xfs defaults 0 0
```

Validate:
```
mount -a
df -h
```

---

## Networking (nmcli)

Show devices:
```
nmcli device status
```

Static IPv4:
```
nmcli connection modify CONN \
  ipv4.method manual \
  ipv4.addresses IP/24 \
  ipv4.gateway GW \
  ipv4.dns DNS
```

Apply:
```
nmcli connection down CONN
nmcli connection up CONN
```

Hostname:
```
hostnamectl set-hostname NAME
```

Check:
```
ip a
ip route
hostnamectl
```

---

## Services & Firewall

Install:
```
dnf install -y PACKAGE
```

Service:
```
systemctl start SERVICE
systemctl enable SERVICE
```

Firewall service:
```
firewall-cmd --add-service=SERVICE --permanent
firewall-cmd --reload
```

Firewall port:
```
firewall-cmd --add-port=PORT/tcp --permanent
```

Check:
```
systemctl status SERVICE
firewall-cmd --list-all
```

---

## SELinux (DO NOT DISABLE)

Status:
```
getenforce
```

Context check:
```
ls -Z PATH
```

Persistent context:
```
semanage fcontext -a -t TYPE "PATH(/.*)?"
restorecon -Rv PATH
```

Common type:
```
httpd_sys_content_t
```

---

## Archiving

Create:
```
tar -czvf file.tar.gz DIR
tar -cjvf file.tar.bz2 DIR
```

List:
```
tar -tzf file.tar.gz
tar -tjf file.tar.bz2
```

Extract:
```
tar -xzvf file.tar.gz -C DEST
```

---

## Bash Scripting

Shebang:
```
#!/bin/bash
```

Arguments:
```
[ $# -ne 1 ] && exit 1
```

If exists:
```
id USER &>/dev/null
```

FOR loop:
```
for i in a b c; do
  echo $i
done
```

WHILE loop:
```
while read line; do
  echo $line
done < file
```

CASE:
```
case "$1" in
  start) ;;
  stop) ;;
  *) exit 1 ;;
esac
```

---

## Containers (Podman)

Pull:
```
podman pull IMAGE
```

Run:
```
podman run -d --name NAME -p 8080:80 IMAGE
```

SELinux volume:
```
-v /host:/ctr:Z
```

Firewall:
```
firewall-cmd --add-port=8080/tcp --permanent
firewall-cmd --reload
```

Persist:
```
podman generate systemd --name NAME --files --new
mv container-NAME.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable --now container-NAME
```

Check:
```
podman ps
systemctl status container-NAME
```

---

## FINAL EXAM CHECK (DO THIS)

Before moving on:
```
reboot
```

After reboot:
```
getenforce
systemctl status SERVICE
df -h
ip a
podman ps
```

If it survives reboot, **you’re correct**.

---

**Simple. Persistent. Verified.**
