# IAM Foundations for EKS (Single-Region) – aws-eks-secure-foundations

This document defines the **IAM model and security posture** used for this EKS foundation repository.

The goal is to ensure:
- Least privilege and clear separation of duties
- Auditability (who did what, when, and why)
- Safe workload identity (no static credentials, no node-wide permissions)
- A clean path for DevSecOps automation

This repo is **single-region**. IAM itself is **global**.

---

## Scope

### In Scope
- IAM design for EKS control plane access
- Node/worker role separation
- Workload identity using IRSA (OIDC)
- Add-on permissions (ALB controller, EBS CSI, autoscaler, etc.)
- Deployment identity for Terraform/CI

### Out of Scope
- Multi-account organizational strategy (SCPs, org CloudTrail)
- Cross-region DR roles and global routing patterns
- Full enterprise identity provider configuration (beyond role assumption model)

---

## EKS IAM Model Overview

EKS has *three distinct identity planes*:

1. **AWS API Identity (IAM)**
   - Who can call AWS APIs like `eks:DescribeCluster`, `ec2:*`, `iam:*`, etc.

2. **Cluster Access (Kubernetes RBAC)**
   - Who can access the Kubernetes API server and what they can do inside the cluster

3. **Workload Identity (Pods calling AWS)**
   - How pods obtain AWS permissions (IRSA), without inheriting node permissions

Secure EKS requires controlling all three.

---

## Identity Separation (Non-Negotiable)

### 1) Human Administrative Access
Humans should authenticate via:
- SSO / federated identity (preferred), then assume roles
- Role sessions should be time-bound and logged

Humans should **not** use:
- Long-lived access keys
- Shared IAM users

**Audit goal:** every privileged action maps to an individual session identity.

---

### 2) Infrastructure Deployment Identity (Terraform / CI)
Terraform should run under a dedicated **deployment role**:
- Narrow scope to only required resources
- Separate per environment (dev/stage/prod) if applicable
- Use short-lived credentials (OIDC from CI if possible)

Terraform role should NOT be reused by:
- cluster workloads
- node instances
- add-ons

---

### 3) Runtime Workload Identity (IRSA)
Workloads should use **IRSA**:
- OIDC provider linked to cluster
- Kubernetes service account → IAM role mapping
- Pod gets only the permissions it needs

Avoid:
- granting AWS permissions to the node role “because it works”
- using static credentials in Kubernetes secrets

---

## Control Plane Access: AWS vs Kubernetes

### AWS-side (EKS API)
Controls who can manage cluster lifecycle and view cluster metadata:
- `eks:CreateCluster`, `eks:DescribeCluster`, `eks:UpdateClusterConfig`, etc.

### Kubernetes-side (RBAC)
Controls who can do what inside Kubernetes:
- create deployments
- read secrets
- manage namespaces
- etc.

**Important:** Being able to call EKS APIs is not the same as being cluster-admin in Kubernetes.

---

## Recommended Access Pattern (Clean and Auditable)

- A small set of **admin roles** can access the cluster
- Admin roles are mapped to Kubernetes RBAC cleanly
- Workload permissions are handled separately via IRSA roles

**Outcome:** least privilege and clear audit boundaries.

---

## Node Instance Role: Keep It Minimal

Node instance roles should have only what nodes need:
- join the cluster
- pull images (ECR if used)
- write logs/metrics if required
- basic networking and CNI requirements

Node roles should NOT contain:
- wildcard admin privileges
- permissions intended for pods/add-ons

If a pod needs AWS access, that’s a job for IRSA.

---

## IRSA (OIDC) – Trust Policy and Permissions

### What IRSA Solves
- Prevents “everything in the cluster can use the node role”
- Makes permissions **pod-scoped**
- Enables least privilege per add-on

### Common IRSA Flow
1. Cluster OIDC provider exists
2. Service account annotated with role ARN
3. Pod receives a projected token
4. AWS STS exchanges token for temporary creds

### Audit Note
- STS `AssumeRoleWithWebIdentity` events should appear in CloudTrail
- This is a key control point for investigations

---

## Add-On Permission Strategy (Typical Roles)

Each add-on should have its own role and policy, for example:

- **AWS Load Balancer Controller**
  - permissions to manage ALB/NLB resources it creates
- **EBS CSI Driver**
  - permissions to manage EBS volumes and attachments
- **Cluster Autoscaler**
  - permissions to describe/update ASGs (or node groups)
- **ExternalDNS** (if used)
  - permissions for Route53 changes (high-risk; scope carefully)

**Rule:** One add-on = one service account = one role = one scoped policy.

---

## Guardrails and Red Flags

### Red Flags (Immediate Review Required)
- `AdministratorAccess` attached to anything in this repo
- Wildcard `iam:*` permissions in deployment roles
- Node role used as a “shared permissions bucket”
- Static AWS credentials stored in Kubernetes secrets
- Unreviewed copy-paste IAM policies from the internet

### Guardrails (Expected)
- Policies scoped to actions and resources
- Roles with minimal trust relationships
- All privileged operations are traceable via CloudTrail
- No hard-coded secrets in code or outputs

---

## CloudTrail Expectations (Operational Readiness)

At minimum, ensure CloudTrail captures:
- `AssumeRole` (human role sessions)
- `AssumeRoleWithWebIdentity` (IRSA)
- IAM policy and role changes
- EKS cluster updates
- Load balancer and networking changes (if relevant)

Without logs, troubleshooting and investigations become guesswork.

---

## Practical Review Checklist (Use Before “Apply”)

- [ ] Deployment role is separate from runtime roles
- [ ] Node instance role is minimal
- [ ] Each add-on has a dedicated IRSA role
- [ ] No long-lived keys are used
- [ ] Trust policies are scoped properly
- [ ] CloudTrail visibility is confirmed (or planned)

---

## Summary

This EKS foundation treats IAM as the primary security boundary:

- Humans assume roles (auditable sessions)
- Terraform uses a deployment role (controlled operational impact)
- Nodes have minimal permissions (no “god role”)
- Pods use IRSA (least privilege at workload level)

This is the baseline expected for secure, production-minded EKS operations.

---
**Identity first. Least privilege always. Auditability by design.**
