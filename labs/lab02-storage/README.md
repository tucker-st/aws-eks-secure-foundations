# Lab 02 - Storage Management with LVM (RHEL 10)

Goal: Practice disk, volume, and filesystem management using LVM aligned to RHCSA (EX200).

This lab focuses on correct setup, persistence, and validation — exactly how the exam is graded.

---

## EX200 Objectives Covered

- Create and manage physical volumes, volume groups, and logical volumes
- Create and mount filesystems
- Configure persistent mounts using /etc/fstab

---

## Prerequisites

- RHEL 10 VM
- Root or wheel access
- An unused disk attached (example: /dev/sdb)
- Snapshot taken (recommended)

---

## Lab Scenario

A new application requires dedicated storage. You must:
- Prepare a new disk
- Create LVM components
- Format a filesystem
- Mount it persistently

---

## Tasks

### Task 1 - Identify Available Disk

List block devices and identify the unused disk.

Commands:
```
lsblk
```

Expected:
- Identify an unused disk (example: /dev/sdb)
- Disk must not contain existing partitions

---

### Task 2 - Create Physical Volume

Initialize the disk as an LVM physical volume.

Command:
```
pvcreate /dev/sdb
```

Validate:
```
pvs
```

Expected:
- /dev/sdb listed as a physical volume

---

### Task 3 - Create Volume Group

Create a volume group named vgdata.

Command:
```
vgcreate vgdata /dev/sdb
```

Validate:
```
vgs
```

Expected:
- Volume group vgdata exists

---

### Task 4 - Create Logical Volume

Create a logical volume named lvdata with size 5G.

Command:
```
lvcreate -n lvdata -L 5G vgdata
```

Validate:
```
lvs
```

Expected:
- Logical volume vgdata/lvdata exists

---

### Task 5 - Create Filesystem

Format the logical volume with XFS.

Command:
```
mkfs.xfs /dev/vgdata/lvdata
```

Validate:
```
blkid /dev/vgdata/lvdata
```

Expected:
- Filesystem type is xfs

---

### Task 6 - Create Mount Point

Create a mount point directory at /data.

Command:
```
mkdir /data
```

Validate:
```
ls -ld /data
```

---

### Task 7 - Mount Filesystem

Mount the logical volume at /data.

Command:
```
mount /dev/vgdata/lvdata /data
```

Validate:
```
df -h /data
```

Expected:
- /data is mounted
- Correct size displayed

---

### Task 8 - Configure Persistent Mount

Add an entry to /etc/fstab so the filesystem mounts at boot.

Edit /etc/fstab and add:
```
/dev/vgdata/lvdata /data xfs defaults 0 0
```

Validate:
```
mount -a
```

Expected:
- No errors
- Filesystem remains mounted

---

### Task 9 - Reboot Validation (CRITICAL)

Reboot the system.

After reboot, validate:
```
df -h /data
lsblk
```

Expected:
- /data is mounted automatically
- LVM components intact

---

## Auto-Grading Checklist

- Unused disk identified correctly
- Physical volume created
- Volume group vgdata exists
- Logical volume lvdata exists
- Filesystem is xfs
- /data directory exists
- Filesystem mounted at /data
- Entry exists in /etc/fstab
- Mount survives reboot

---

## Common Exam Failures

- Forgetting to update /etc/fstab
- Typos in fstab causing boot issues
- Mounting by device name but not validating
- Skipping reboot validation
- Using incorrect filesystem type

---

## Reset (Optional)

To reset the lab:
```
umount /data
lvremove -y /dev/vgdata/lvdata
vgremove -y vgdata
pvremove -y /dev/sdb
rm -rf /data
sed -i '\|/data|d' /etc/fstab
```

---

## Next Lab

Proceed to lab03-networking.
