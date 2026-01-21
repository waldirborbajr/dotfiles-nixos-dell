# Versioning Policy

This repository follows an **infra-style versioning model**, inspired by Terraform and NixOS.

All releases **must be tagged** using the following format:

vMAJOR.MINOR.PATCH

---

## Versioning Rules

### MAJOR
Increment when:
- Breaking changes are introduced
- Module structure is reorganized
- Defaults change in a way that may impact existing systems

### MINOR
Increment when:
- New modules or features are added
- Backward-compatible improvements are introduced
- New profiles or hosts are added

### PATCH
Increment when:
- Fixes are applied
- Refactors do not change behavior
- Documentation or comments are updated

---

## Tagging Policy

- Every release **must be tagged**
- Tags must always start with `v`
- No mutable tags
- Main branch must always point to a released or releasable state

---

## Examples

Valid versions:
- v1.0.0
- v1.2.3
- v2.0.0

Invalid versions:
- 1.0.0
- v1
- v1.0
