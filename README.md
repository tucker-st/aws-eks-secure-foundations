# AWS EKS Secure Foundations

This repository implements an **Amazon EKS platform foundation** using **Terraform**, with a focus on **security, operability, and audit-aware design**. It is intentionally scoped as a foundational EKS build and does not attempt to model global or multi-region architectures.

---

## Scope and Intent

This project supports:
- One EKS cluster per Terraform execution
- Infrastructure built and managed via Terraform
- Security-first configuration with production-realistic add-ons

Explicitly out of scope:
- Global or multi-region deployments
- Active-active or cross-region failover
- Cross-region state sharing
- Multi-account orchestration frameworks

If deployed to another region, it is done via a **separate Terraform execution and separate state**.

---

## Purpose

This repository exists to:
- Build a **secure and operable EKS baseline**
- Demonstrate **realistic EKS platform construction**
- Support **AWS platform engineering and security skill development**
- Bridge traditional infrastructure security practices into AWS

This is **not** a minimal demo or click-through tutorial.

---

## Architecture Overview

At a high level, this repository provisions:
- An Amazon EKS cluster
- Required IAM roles and policies
- An OIDC provider for IAM Roles for Service Accounts (IRSA)
- Core Kubernetes add-ons deployed via Helm
- Observability and optional platform services

All resources are deployed into a **single AWS region**, defined at runtime.

---

## Platform Components

The environment includes:
- Managed EKS control plane
- Managed node groups
- IAM OIDC provider for IRSA
- Metrics Server
- Cluster Autoscaler
- AWS Load Balancer Controller
- EBS CSI Driver
- Prometheus and Grafana
- Optional platform services (e.g., Portainer)

These components reflect **real operational requirements**, not minimal demos.

---

## Security Posture

Security is treated as a **baseline requirement**, not an afterthought.

Key principles applied:
- Least-privilege IAM roles
- No hard-coded AWS credentials
- Pod-level permissions via IRSA
- Terraform state treated as sensitive data
- Clear separation of infrastructure and workload identity

Host OS hardening and container runtime security are assumed to be handled at the AMI or node layer.

---

## Terraform Design Notes

- All inputs are defined in `variables.tf`
- Runtime values are supplied via `terraform.tfvars` (never committed)
- A safe example file is provided at `examples/terraform.tfvars.example`
- Two availability zones are used explicitly or deterministically
- Remote state is expected and configured at init time

---

## State Management and Terraform Initialization

Terraform state is treated as **sensitive operational data**. State files may contain infrastructure metadata, network topology, IAM relationships, and cluster endpoints. For this reason, state is **never stored locally** and **never committed to version control**.

This repository declares the backend type only:

```hcl
terraform {
  backend "s3" {}
}
```

Backend configuration values (S3 bucket, state key, region, and optional DynamoDB lock table) are supplied **at initialization time**, not embedded in Terraform source.

### Backend Prerequisites

Before running Terraform, the following resources must already exist in the target AWS account:

- An S3 bucket for Terraform state
  - Globally unique name
  - Versioning enabled
  - Server-side encryption enabled
  - Public access blocked
- (Strongly recommended) A DynamoDB table for state locking
  - Partition key: `LockID` (String)

Terraform will **not** create these resources automatically.

### Backend Configuration and Initialization

An example backend configuration file is provided at:

```
examples/backend.hcl.example
```

Create the backend configuration and initialize Terraform in one sequence:

```bash
cp examples/backend.hcl.example examples/backend.hcl
terraform init -reconfigure -backend-config=examples/backend.hcl
```

The real `backend.hcl` file is environment-specific and must **never** be committed.

---

## Usage

After backend initialization, complete the following steps in order.

1. Create a local variables file:

```bash
cp examples/terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` for the target environment.
- `client_ip` must be a **/32** representing a single trusted public IP
- `terraform.tfvars` must **never** be committed

2. Review planned infrastructure changes:

```bash
terraform plan
```

3. Apply the infrastructure:

```bash
terraform apply
```

4. Validate cluster health:

```bash
kubectl get nodes
kubectl get pods -A
```

5. Perform post-deployment security and operational checks:
- IRSA role bindings
- Security group exposure
- Observability components
- Secure handling of Terraform state and outputs

---

## Future Work

The following are intentionally excluded:
- Multi-region EKS
- Disaster recovery architectures
- Multi-account orchestration
- GitOps-driven lifecycle management

---

## Disclaimer

This repository is an **independent educational and professional project**.
- Not affiliated with AWS
- No proprietary training material used
- No production credentials included

Clear scope. Secure defaults. Operational realism.
