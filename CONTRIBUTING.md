# Contributing Guidelines

Thank you for your interest in contributing to **AWS EKS Secure Foundations**.

This repository is intended to demonstrate **security-focused, production-realistic EKS infrastructure** built with Terraform. Contributions are welcome when they align with the project’s scope, design intent, and operational discipline.

---

## Project Scope (Read First)

This repository intentionally focuses on:

- A **single AWS region**
- One EKS cluster per Terraform execution
- Security-first infrastructure design
- Realistic platform add-ons and operational tooling
- Infrastructure lifecycle managed via Terraform

The following are **out of scope** and will not be accepted:

- Multi-region or global architectures
- Active-active or cross-region failover designs
- Multi-account orchestration frameworks
- Tutorial-style simplifications that remove security controls

If you are unsure whether a change fits the scope, open an issue before submitting a pull request.

---

## What Contributions Are Appropriate

Appropriate contributions include:

- Security hardening improvements
- Terraform refactoring that improves clarity or safety
- Documentation improvements (accuracy, clarity, diagrams)
- Additional production-relevant EKS add-ons
- Validation fixes and correctness improvements
- IAM, networking, or IRSA refinements

Contributions should reflect **real operational environments**, not minimal demos.

---

## Contribution Expectations

All contributions must:

- Preserve single-region design
- Avoid hard-coded secrets or credentials
- Avoid committing `terraform.tfvars` or backend configuration
- Maintain least-privilege IAM principles
- Pass `terraform fmt` and `terraform validate`
- Be understandable by another operator without tribal knowledge

Terraform state, credentials, and environment-specific values must **never** be committed.

---

## Branching and Workflow

1. Fork the repository
2. Create a feature branch from `main`
3. Make focused, logically grouped commits
4. Ensure formatting and validation pass:
   ```bash
   terraform fmt -recursive
   terraform validate
