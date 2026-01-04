# Lab 06 - Archiving, Compression, and File Transfer (RHEL 10)

Goal: Practice creating, compressing, extracting, and validating archives using standard Linux tools aligned to RHCSA (EX200).

This lab emphasizes correct command usage, ownership preservation, and validation.

---

## EX200 Objectives Covered

- Create and extract archives
- Compress and decompress files
- Preserve file permissions and ownership
- Verify archive contents

---

## Prerequisites

- RHEL 10 VM
- Root or wheel access
- Existing directory with files (example: /data)
- Snapshot taken (recommended)

---

## Lab Scenario

System data must be backed up, transferred, and restored safely.

You must:
- Create a compressed archive
- Verify its contents
- Restore the archive to a new location
- Validate permissions and ownership

---

## Tasks

### Task 1 - Prepare Source Data

Create a test directory and files.

Commands:
```
mkdir -p /data/project
echo "file one" > /data/project/file1.txt
echo "file two" > /data/project/file2.txt
chown -R root:root /data
chmod -R 755 /data
```

Validate:
```
ls -l /data/project
```

---

### Task 2 - Create a Compressed Archive

Create a gzip-compressed tar archive.

Command:
```
tar -czvf /root/project_backup.tar.gz -C /data project
```

Validate:
```
ls -lh /root/project_backup.tar.gz
```

Expected:
- Archive file exists
- Size is non-zero

---

### Task 3 - List Archive Contents

View archive contents without extracting.

Command:
```
tar -tzvf /root/project_backup.tar.gz
```

Expected:
- Files and directories listed correctly

---

### Task 4 - Restore Archive to New Location

Create a restore directory.

Command:
```
mkdir /restore
```

Extract the archive.

Command:
```
tar -xzvf /root/project_backup.tar.gz -C /restore
```

Validate:
```
ls -l /restore/project
```

Expected:
- Files restored correctly

---

### Task 5 - Verify Permissions and Ownership

Confirm permissions and ownership match the source.

Command:
```
ls -l /restore/project
```

Expected:
- Owner: root
- Permissions preserved

---

### Task 6 - Create a bzip2 Archive (Alternate Compression)

Create a bzip2-compressed archive.

Command:
```
tar -cjvf /root/project_backup.tar.bz2 -C /data project
```

Validate:
```
ls -lh /root/project_backup.tar.bz2
```

---

### Task 7 - Remove Source and Restore Again

Remove original data.

Command:
```
rm -rf /data/project
```

Restore from gzip archive again.

Command:
```
tar -xzvf /root/project_backup.tar.gz -C /data
```

Validate:
```
ls -l /data/project
```

Expected:
- Data restored successfully

---

## Auto-Grading Checklist

- Source data created correctly
- gzip archive created
- Archive contents verified
- Data restored to /restore
- Permissions preserved
- bzip2 archive created
- Data restored after deletion

---

## Common Exam Failures

- Forgetting -C option during archive creation or extraction
- Extracting into wrong directory
- Not verifying archive contents
- Confusing compression flags
- Removing source before verifying backup

---

## Reset (Optional)

To reset the lab:
```
rm -rf /data /restore
rm -f /root/project_backup.tar.gz /root/project_backup.tar.bz2
```

---

## Next Lab

Proceed to lab07-scripting.