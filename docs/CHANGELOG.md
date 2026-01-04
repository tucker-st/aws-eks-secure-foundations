# Changelog

All notable changes to **AWS EKS Secure Foundations** are documented in this file.

This project follows a pragmatic changelog approach:
- Entries are grouped by milestone
- Changes are categorized for quick review
- Dates use ISO format (YYYY-MM-DD)

---

## [Unreleased]

### Added
- N/A

### Changed
- Ongoing refactoring and professionalization of Terraform configuration

### Fixed
- N/A

### Security
- N/A

---

## [0.3.0] - 2026-01-04

### Added
- CHANGELOG.md to formally track repository evolution
- Clear documentation change tracking separate from README

### Changed
- Repository hygiene finalized:
  - `.gitignore` hardened to prevent committing tfvars, state, and backend files
  - Example configuration files moved to `examples/`
  - Documentation normalized and cleaned

### Fixed
- Removed accidental cross-repository documentation contamination

### Security
- Reinforced non-commit policy for sensitive Terraform artifacts

---

## [0.2.0] - 2026-01-03

### Changed
- Refactored subnet definitions to use a count-based availability zone model
- Hardened variable definitions with clearer intent and validation
- Improved consistency and predictability of network layout

### Security
- Reduced configuration ambiguity that could lead to unintended infrastructure exposure

---

## [0.1.1] - 2026-01-02

### Changed
- Terminology normalized across documentation and code:
  - Replaced ambiguous “blast radius” wording with clearer “operational impact”

### Security
- Improved clarity around operational risk discussion

---

## [0.1.0] - 2026-01-02

### Added
- Initial AWS EKS Secure Foundations repository
- Single-region EKS platform baseline
- Terraform-based infrastructure definition
- Foundational IAM, networking, and cluster components

### Security
- Security-first design intent established at repository inception
