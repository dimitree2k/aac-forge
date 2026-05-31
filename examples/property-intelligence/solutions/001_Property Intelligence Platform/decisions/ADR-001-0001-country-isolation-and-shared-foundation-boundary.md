---
id: ADR-001-0001
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

# ADR-001-0001: Country Isolation and Shared Foundation Boundary

## Context

The BR requires record-level country-owned property data to remain inside the owning country boundary, with only approved aggregated metrics shared centrally. It also expects per-country GCP projects or equivalent hard boundaries, VPC Service Controls or equivalent service perimeters, country-scoped IAM, repeatable country onboarding, and a thin reusable GCP, data platform, delivery, and operations foundation.

This is consequential because it defines the security model and constrains all later model, deployment, and operating decisions.

## Decision Drivers

- Country-owned record-level data must be isolated by default.
- The MVP has one pilot country but must not block country-by-country expansion.
- Data and AI is assumed to own and operate the first release end to end.
- GCP Infrastructure, DevOps, Security, and future application ownership boundaries remain open.
- Central analytics may consume only approved aggregated metrics.
- The design should avoid duplicating foundation decisions in every later product application.

## Options

### Option A: Per-country hard boundary with shared foundation capabilities

Model a reusable GCP Data and AI Foundation that provisions and governs per-country project boundaries, country-scoped IAM, service perimeters, key boundaries, IaC, observability, and support controls. The Property Intelligence Platform consumes the foundation for the pilot country.

Pros:

- Aligns with the BR's hard-isolation requirement.
- Supports later country onboarding without weakening isolation.
- Keeps shared platform decisions reusable for future intelligence applications.
- Gives Security and Enterprise Architecture a clear boundary to approve.

Cons:

- Requires more upfront platform definition than a one-off MVP.
- Depends on clarifying RACI across Data and AI, GCP Infrastructure, DevOps, and Security.
- May require a separate foundation solution later if the architecture package grows too large.

### Option B: Single shared project with logical country separation

Run all countries in a shared project or shared data platform namespace and rely on logical labels, row-level controls, and application authorization.

Pros:

- Simpler initial deployment.
- Lower platform setup effort for the first pilot.
- May be sufficient for non-sensitive internal datasets.

Cons:

- Conflicts with the BR expectation for per-country GCP projects or equivalent hard isolation.
- Raises higher risk of record-level cross-country access.
- Harder to prove VPC Service Controls or equivalent service perimeter protection by country.
- Future migration to hard boundaries may be expensive.

### Option C: One-off pilot-country project with no reusable foundation boundary

Create only the pilot-country deployment boundary and defer foundation standardization until after MVP validation.

Pros:

- Limits the initial scope.
- Fastest path to a single pilot-country implementation.
- Avoids premature standardization if the MVP changes direction.

Cons:

- Risks creating a non-reusable country implementation.
- Pushes foundational decisions into later rework.
- Weakens reuse for future Property Intelligence and Transactional Intelligence consumers.
- Does not fully satisfy the BR goal of establishing a thin reusable foundation.

## Decision

Proposed decision: choose Option A. Model a reusable GCP Data and AI Foundation capability and a hard pilot-country boundary for record-level property data. Keep the foundation thin in this solution, limited to controls directly needed by the Property Intelligence MVP: country project boundary, IAM, service perimeter, encryption/key boundary, IaC, observability, and support hooks.

## Consequences

### Positive

- Country isolation is treated as an architectural constraint, not an implementation detail.
- Future countries can reuse the same onboarding and control pattern.
- Later product applications can reference the foundation rather than reopening it.
- Security review can focus on explicit country-boundary controls.

### Negative

- Foundation ownership and operational RACI must be clarified.
- Stage B will need model elements for both the product platform and foundation capabilities.
- Some detailed foundation decisions may need to be split into a future foundation solution if reviewers judge this package too broad.

### Mitigations

- Keep this ADR scoped to the boundary model, not every GCP service selection.
- Use the change plan to identify foundation model elements without finalizing exact managed service choices.
- Record open RACI questions in the SAD and require architect approval before Stage B.

## References

- BR sections 2.1, 3.1, 6.1, 6.3, 8, 9, 10, 12
- docs/input/specs/multi-project-architecture-intent.md
- decisions/change-plan.md
