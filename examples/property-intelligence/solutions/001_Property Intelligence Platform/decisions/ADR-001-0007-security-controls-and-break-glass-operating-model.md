---
id: ADR-001-0007
status: Accepted
solution: "001"
date: "2026-05-31"
approval:
  system: manual
  reference: "Manual Stage A approval in Codex thread, 2026-05-31"
approvers:
  - role: "Enterprise Architect"
    name: "Demo Architecture Gate"
    date: "2026-05-31"
  - role: "Security Specialist"
    name: "Demo Architecture Gate"
    date: "2026-05-31"
  - role: "Solution Architect"
    name: "Demo Architecture Gate"
    date: "2026-05-31"
supersedes: []
superseded-by: []
---

# ADR-001-0007: Security Controls and Break-Glass Operating Model

## Context

The BR requires country-scoped least privilege, encryption in transit and at rest, auditability for access and changes, controlled data publication, and break-glass access that is approved, time-limited, logged, and reviewed. It also requires classification of property data that may include limited personal/entity information and confirmation of retention, residency, and jurisdiction-specific compliance for the pilot country.

This is consequential because it defines security controls that must be embedded in the architecture before `.c4` model implementation and production readiness.

## Decision Drivers

- Record-level country data must be denied cross-country by default.
- Data may include limited personal/entity information.
- Access, stewardship, administrative, enrichment, and publication actions must be logged.
- Emergency access must be controlled and reviewed.
- Security boundary violations must be monitored where detectable.
- Pilot-country retention, residency, and jurisdiction-specific rules are not yet confirmed.

## Options

### Option A: Security-by-default controls with explicit break-glass workflow

Model country-scoped IAM, service-to-service authentication, encryption in transit and at rest, country-specific key boundaries where required, audit logging for data and administrative actions, publication audit, security alerts, and a formal break-glass workflow with approval, time limit, logging, and post-access review.

Pros:

- Directly satisfies the BR's security and compliance requirements.
- Makes emergency access auditable rather than informal.
- Creates clear acceptance criteria before production use.
- Supports future country onboarding with consistent controls.

Cons:

- Requires security workflow and support procedures before go-live.
- May require country-specific key, retention, and residency decisions.
- Adds operational overhead for approvals, reviews, and alert response.

### Option B: Standard platform controls only

Rely on default GCP and enterprise platform controls for IAM, encryption, logging, and incident handling. Document break-glass later.

Pros:

- Lower Stage B design effort.
- Leverages existing platform defaults.
- Avoids over-specifying controls before exact services are selected.

Cons:

- Does not satisfy explicit BR requirements for break-glass, publication audit, and country-specific controls.
- Leaves ambiguity for Security approval.
- Risks discovering compliance gaps late.

### Option C: Manual operational controls for MVP

Use manual approvals and logs outside the platform for sensitive access and publication decisions during the pilot.

Pros:

- May be practical for a small pilot.
- Reduces initial automation complexity.
- Allows process refinement before automation.

Cons:

- Weak auditability and repeatability.
- Poor fit for country onboarding and production use.
- Increases risk of inconsistent emergency access and publication controls.

## Decision

Proposed decision: choose Option A. Treat security controls and break-glass as part of the approved architecture package, with exact service-specific implementation details finalized in Stage B. Production use requires an operational break-glass runbook and audit review process.

## Consequences

### Positive

- Creates a clear Security approval baseline.
- Reduces risk of unapproved record-level access or publication.
- Supports repeatable onboarding for future countries.
- Gives support teams explicit incident and emergency-access expectations.

### Negative

- Requires Security, DevOps, GCP Infrastructure, and Data and AI to agree operational responsibilities.
- Requires confirmation of pilot-country retention, residency, and jurisdiction rules.
- May add implementation and support scope before MVP launch.

### Mitigations

- Keep this ADR at the control-model level until exact GCP services are selected.
- Require the Stage B change plan to model audit, monitoring, key, and break-glass relationships.
- Track retention, residency, support hours, and incident response as approval questions.

## References

- BR sections 6.1, 8, 9, 10, 11, 12
- ADR-001-0001
- decisions/change-plan.md
