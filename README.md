# AWS EKS Secure Foundations (Single-Region)

This repository implements a single-region Amazon EKS platform foundation using Terraform, with an emphasis on security, operability, and audit-aware infrastructure design. It is intentionally scoped as a foundational EKS build and does not attempt to model multi-region or global architectures.

## Scope and Intent

This project supports a single AWS region and provisions one EKS cluster per Terraform execution. Infrastructure is built and managed exclusively through Terraform with security-first defaults and production-realistic add-ons. Multi-region deployments, cross-region state sharing, global failover, and multi-account orchestration are explicitly out of scope. If this repository is deployed to another region, it is done via a separate Terraform execution and separate state.

## Purpose

The goal of this repository is to provide a secure and operable EKS baseline, demonstrate realistic EKS platform construction, support AWS certification preparation, and bridge traditional infrastructure security practices into AWS cloud-native environments. This is not a minimal demo or a click-through tutorial.

## Architecture Overview

At a high level, the platform provisions an Amazon EKS cluster, supporting IAM roles and policies, an OIDC provider for IAM Roles for Service Accounts (IRSA), core Kubernetes add-ons deployed via Helm, and observability and platform services. All resources are deployed into a single AWS region defined at runtime.

## Platform Components

The environment includes a managed EKS control plane, managed node groups, an IAM OIDC provider for IRSA, Metrics Server, Cluster Autoscaler, AWS Load Balancer Controller, EBS CSI Driver, Prometheus and Grafana for observability, and optional platform services such as Portainer. These components reflect real operational requirements rather than feature demonstrations.

## Security Posture

Security is treated as a baseline requirement. The design enforces least-privilege IAM, avoids static AWS credentials, uses IRSA for pod-level permissions, treats Terraform state as sensitive data, and maintains clear separation between infrastructure identity and workload identity. Host operating system and container runtime hardening are assumed to be handled at the AMI or node layer.

## Terraform Design Notes

This repository intentionally uses a single AWS region supplied via variables, without provider aliasing or region iteration logic. All supported inputs are defined in variables.tf. Runtime values are supplied via terraform.tfvars, which is intentionally excluded from version control. A safe example file is provided at examples/terraform.tfvars.example. Two availability zones are used either explicitly or deterministically selected. Remote state using S3 and DynamoDB is assumed but not hard-coded.

## Usage

To use this repository, operators should follow a deliberate, review-driven workflow consistent with real-world change control practices.

1. Copy the example variables file using `cp examples/terraform.tfvars.example terraform.tfvars`, then edit terraform.tfvars for the target environment. The client_ip value must be provided as a /32 representing a single trusted public IP address. The terraform.tfvars file must never be committed to version control.

2. Initialize Terraform by running `terraform init`. Provider plugins and backend configuration are initialized at this stage. Backend values are supplied externally if a remote backend is used.

3. Review the planned infrastructure changes by running `terraform plan`. Operators are expected to understand the IAM roles being created, network exposure, and add-ons that will be deployed into the cluster.

4. Apply the infrastructure by running `terraform apply` only after reviewing and accepting the plan. This provisions networking, the EKS control plane, managed node groups, and all configured platform add-ons.

5. Validate cluster health after deployment by running `kubectl get nodes` and `kubectl get pods -A`, confirming that nodes are Ready, system namespaces are healthy, and expected add-ons are running.

6. Perform post-deployment security and operational checks, including validation of IRSA role bindings, review of security group exposure, confirmation of logging and observability components, and secure handling of Terraform state and outputs.

## Relationship to Other Repositories

This repository complements RHCSA (EX200) practice material, AWS Cloud Security foundations, Secure Infrastructure-as-Code foundations, and RMF-oriented operational playbooks. Together they represent a security-minded cloud platform skillset.

## Future Work

Multi-region EKS patterns, disaster recovery architectures, multi-account orchestration, and GitOps-driven lifecycle management are intentionally excluded to keep this repository focused and understandable.

## Disclaimer

This repository is an independent educational and professional project. It is not affiliated with AWS, contains no proprietary training material, and includes no production credentials.

Clear scope. Secure defaults. Operational realism.
