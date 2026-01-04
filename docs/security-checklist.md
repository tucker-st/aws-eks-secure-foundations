# Security Checklist – EKS Secure Foundations (Pre-Deploy)

This checklist defines the **minimum security and operational validation requirements**
before applying Terraform or operating the EKS cluster created by this repository.

It is designed to:
- Prevent common EKS security failures
- Support audit and inspection readiness
- Reinforce least-privilege and traceability
- Align cloud-native controls with RMF expectations

This checklist should be reviewed **before every apply** and **after major changes**.

---

## 1. Identity & Access Management (IAM)

### Required
- [ ] No long-lived IAM access keys used by humans
- [ ] All human access via role assumption (SSO or federated)
- [ ] Terraform uses a **dedicated deployment role**
- [ ] Deployment role is not reused for workloads or nodes
- [ ] Node instance role is minimal (no wildcard permissions)
- [ ] Each add-on uses **IRSA** with a dedicated role
- [ ] Trust policies are scoped to:
  - Correct OIDC provider
  - Specific Kubernetes service account
- [ ] No use of `AdministratorAccess`

### Red Flags
- Shared IAM users
- Wildcard `iam:*` permissions
- Node role used as a general permissions bucket
- Static AWS credentials in Kubernetes secrets

---

## 2. Kubernetes Access Control (RBAC)

### Required
- [ ] Kubernetes admin access limited to approved roles
- [ ] RBAC mappings are explicit and documented
- [ ] No anonymous or unauthenticated access enabled
- [ ] Default service accounts not used for privileged workloads

### Red Flags
- Cluster-admin mapped to broad or shared roles
- Workloads running under default service accounts

---

## 3. Networking & Exposure

### Required
- [ ] Cluster deployed into expected VPC
- [ ] Security groups scoped to required traffic only
- [ ] No unintended public access to cluster API
- [ ] Load balancers reviewed for:
  - Public vs internal exposure
  - Listener ports
- [ ] No unnecessary 0.0.0.0/0 rules

### Red Flags
- Public load balancers without justification
- Broad ingress rules added “temporarily”
- Mixing internal and external traffic unintentionally

---

## 4. Logging & Visibility

### Required
- [ ] CloudTrail enabled for:
  - IAM role assumptions
  - IRSA (`AssumeRoleWithWebIdentity`)
  - EKS API calls
- [ ] Logs retained per policy
- [ ] Add-on activity observable (ALB controller, autoscaler, etc.)
- [ ] Errors and denied actions are reviewable

### Red Flags
- No visibility into role assumption
- Logs disabled to “reduce cost”
- No retention policy defined

---

## 5. Terraform State & Change Control

### Required
- [ ] Remote backend used (S3 recommended)
- [ ] State locking enabled (DynamoDB recommended)
- [ ] State treated as sensitive data
- [ ] One state per environment
- [ ] Terraform plan reviewed before apply

### Red Flags
- Local state used for shared environments
- State file committed to version control
- Apply performed without plan review

---

## 6. Secrets Handling

### Required
- [ ] No secrets hard-coded in Terraform files
- [ ] No secrets stored in `terraform.tfvars`
- [ ] No sensitive values exposed via Terraform outputs
- [ ] Secrets managed via:
  - AWS Secrets Manager, or
  - SSM Parameter Store

### Red Flags
- Credentials embedded in Helm values
- Kubernetes secrets containing AWS keys
- Sensitive outputs printed to console

---

## 7. Add-Ons & Workloads

### Required
- [ ] Each add-on reviewed for required AWS permissions
- [ ] Add-ons scoped to minimum permissions
- [ ] Helm values reviewed for security impact
- [ ] No add-on deployed “just to try it”

### Red Flags
- Add-ons installed without understanding permissions
- Shared service accounts across add-ons
- Add-ons with cluster-wide privileges without justification

---

## 8. Operational Readiness

### Required
- [ ] Operator understands how to:
  - Validate cluster health
  - Identify IAM permission failures
  - Investigate IRSA issues
- [ ] Rollback strategy understood
- [ ] Operational Impact of changes assessed

### Red Flags
- “We’ll fix it later” approach
- No documented validation steps
- Changes applied without understanding impact

---

## 9. Scope Confirmation (Intent Check)

Before applying, confirm:

- [ ] This is a **single-region deployment**
- [ ] Multi-region is not assumed or implied
- [ ] All changes align with stated repo scope

---

## Final Gate

If any **Required** item is unchecked:
> **Do not apply.**

Security and reliability failures in EKS are almost always **preventable** when identity, visibility, and scope are enforced upfront.

---

**Secure by design.  
Auditable by default.  
Operable under pressure.**
