# Changelog

All notable changes to **AWS EKS Secure Foundations** will be documented in this file.

This project follows a pragmatic variant of “Keep a Changelog”:
- Entries are grouped by release (or milestone)
- Changes are categorized for fast scanning
- Dates use ISO format (YYYY-MM-DD)

## [Unreleased]

### Added
- N/A

### Changed
- N/A

### Fixed
- N/A

### Security
- N/A

---

## [0.1.0] - 2026-01-04

### Added
- Initial repository documentation baseline (README)
- State management guidance using S3 backend configuration supplied at init time
- Usage workflow including backend init, tfvars setup, plan/apply, and validation steps

### Changed
- N/A

### Fixed
- Removed cross-repo contamination references from documentation

### Security
- Documented state handling expectations (no local state committed; backend config not committed)

