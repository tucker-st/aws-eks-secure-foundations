# Terraform Backend and State Management – EKS Secure Foundations

This document defines **Terraform backend and state management expectations** for the
`aws-eks-secure-foundations` repository.

State is treated as **sensitive operational data** and managed accordingly.

---

## Purpose

This document exists to:

- Prevent accidental state loss or corruption
- Ensure safe collaboration and change control
- Support audit and inspection readiness
- Establish clear expectations for operators and reviewers

Terraform state is **not an implementation detail** — it is part of the system’s security boundary.

---

## Design Principles

- Remote state is mandatory for shared or long-lived environments
- State locking is required to prevent concurrent modification
- State is scoped narrowly to reduce operational impact
- Backend configuration is explicit and intentional

---

## Expected Backend Pattern

This repository assumes use of:

- **Amazon S3** for remote state storage
- **DynamoDB** for state locking
- **Encryption enabled** at rest

Backend configuration values are **environment-specific** and intentionally **not hard-coded**.

---

## Example Backend Configuration (Reference Only)

The following is a **reference example**, not a committed configuration:

```hcl
terraform {
  backend "s3" {
    bucket         = "example-terraform-state"
    key            = "eks/<environment>/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
```

Operators are expected to supply actual backend values via:
- Backend configuration files
- CLI `-backend-config` options
- Environment-specific tooling

---

## State Scope and Isolation

### Required Practices

- One Terraform state per **environment**
- One EKS cluster per state
- No sharing of state across unrelated workloads

Typical environments:
- `dev`
- `stage`
- `prod`

This prevents:
- Accidental cross-environment drift
- Unintended destructive changes
- Audit ambiguity

---

## Single-Region Implications

This repository is **single-region by design**.

State reflects:
- One AWS region
- One EKS cluster
- One operational scope

Deploying to another region requires:
- Separate backend configuration
- Separate state file
- Separate execution

Multi-region state sharing is **explicitly out of scope**.

---

## State Sensitivity and Handling

Terraform state may contain:
- Resource ARNs
- IAM role identifiers
- Cluster endpoints
- Add-on configuration metadata

As a result:
- State files must not be committed to version control
- S3 buckets must enforce encryption and access controls
- Access to state should be limited to deployment roles

---

## Locking and Concurrency

### Required
- DynamoDB locking enabled
- Only one apply operation at a time
- Failed or interrupted applies investigated immediately

### Red Flags
- Disabling locking “temporarily”
- Forcing unlocks without understanding cause
- Multiple operators applying concurrently

State corruption is far more costly than a delayed deployment.

---

## Terraform Workspaces (Guidance)

Terraform workspaces are **not required** for this repository.

If used:
- Must be documented
- Must not replace proper state isolation
- Must not be used to mix unrelated environments

Directory-based isolation is preferred for clarity.

---

## Change Control Expectations

Before applying changes:
- `terraform fmt` has been run
- `terraform validate` passes
- `terraform plan` reviewed
- Impact to IAM, networking, and workloads understood

Blind applies are unacceptable in production-oriented environments.

---

## Recovery and Incident Considerations

If state is suspected to be corrupted or out-of-sync:

1. Stop all applies immediately
2. Identify last known-good state
3. Review S3 version history
4. Restore state deliberately
5. Re-run plan before apply

State recovery should be treated as a **controlled incident**, not a routine operation.

---

## Summary

Terraform state is:
- Sensitive
- Authoritative
- Operationally critical

In this repository:
- Remote state is mandatory
- Locking is required
- Scope is intentionally narrow
- Change control is enforced

These practices support **secure, auditable, and reliable EKS operations**.

---

---
**Protect the state.  
Control the changes.  
Understand the operational impact.**
