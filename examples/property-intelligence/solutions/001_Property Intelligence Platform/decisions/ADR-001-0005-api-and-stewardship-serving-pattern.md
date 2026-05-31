---
id: ADR-001-0005
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
  - role: "Solution Architect"
    name: "Demo Architecture Gate"
    date: "2026-05-31"
  - role: "Business Process Owner"
    name: "Demo Architecture Gate"
    date: "2026-05-31"
supersedes: []
superseded-by: []
---

# ADR-001-0005: API and Stewardship Serving Pattern

## Context

The BR requires APIs for approved internal consumers to retrieve property profile and enrichment information, plus a lightweight UI for data stewards to review records, enrichment results, duplicate candidates, merge decisions, and retirement decisions. Selected pilot users also need a read-only way to inspect property profiles for validation. The MVP is not a full product portal.

This is consequential because it defines the serving boundary for approved users and consumers, affects access control, and controls whether stewardship is custom-built, configured in a platform tool, or deferred.

## Decision Drivers

- Approved consumers need property profile and enrichment lookup.
- Data stewards need auditable approval workflows.
- Selected pilot users need read-only validation access.
- External user access and a full product portal are out of scope.
- Stewardship actions must be auditable.
- API latency and throughput targets are open questions.
- Existing stewardship or governance tooling is not identified in the BR.

## Options

### Option A: Thin property profile API plus lightweight stewardship UI

Expose a country-boundary-aware property profile API for approved internal consumers. Provide a lightweight stewardship UI for review and approval workflows, including read-only profile validation for selected pilot users.

Pros:

- Satisfies API and stewardship requirements without building a full portal.
- Keeps user-facing scope narrow for MVP.
- Gives stewards a controlled and auditable workflow.
- Creates stable API contracts for future approved consumers.

Cons:

- Introduces application components and support responsibilities.
- Requires API authorization, auditing, and rate/latency targets.
- May duplicate capabilities if an existing governance workflow tool can be reused.

### Option B: Dataset-only access plus manual stewardship workflow

Give approved users access to governed datasets and manage stewardship approvals through manual processes or existing office tools.

Pros:

- Lower build effort for MVP.
- Avoids creating UI and API components.
- May be acceptable for small pilot volumes.

Cons:

- Does not satisfy the BR's API and lightweight UI requirements well.
- Weak auditability for stewardship actions.
- Poor fit for duplicate, enrichment, merge, and retirement approvals at scale.

### Option C: Full product portal

Build a richer product portal with dashboards, search, reporting, stewardship workflows, and user management.

Pros:

- Better end-user experience for future broader adoption.
- Could support stewardship reporting and issue management.
- May reduce later rework if product scope expands quickly.

Cons:

- Explicitly out of scope for MVP.
- Higher delivery and support complexity.
- Risks shifting focus away from proving the governed Property Master foundation.

## Decision

Proposed decision: choose Option A. Model a thin property profile API and lightweight stewardship UI/read-only validation surface inside the Property Intelligence Platform. Keep advanced portal, dashboards, workflow configuration, and rich reporting out of Stage B unless explicitly approved.

## Consequences

### Positive

- Meets MVP access needs while preserving scope discipline.
- Supports auditability of steward approvals.
- Provides a stable integration surface for approved internal consumers.
- Avoids treating datasets as the only user-facing product.

### Negative

- Adds API and UI operational responsibilities.
- Requires user authorization, audit logging, and support procedures.
- Requires decisions on initial approved consumers and support hours.

### Mitigations

- Keep UI workflow limited to BR-required review, approve/reject, merge, retire, and read-only validation tasks.
- Track API consumer authorization, latency, throughput, and support hours as open questions.
- Reassess whether existing governance tooling can implement the stewardship UI during Stage B if named by stakeholders.

## References

- BR sections 1.2, 3.1, 3.2, 5.3, 5.5, 5.6, 6.2, 6.4, 8, 9, 11, 12
- ADR-001-0002
- decisions/change-plan.md
