---
id: ADR-001-0006
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

# ADR-001-0006: Enrichment Integration and Approval Pattern

## Context

The BR requires selected external/public enrichment for address validation, geocoding, ownership/entity enrichment, classification, or similar approved attributes. Enrichment source, timestamp, confidence, and processing outcome must be recorded. Enrichment results must be reviewable and approved before becoming trusted property master attributes where stewardship rules require approval.

This is consequential because it introduces external integrations, data classification concerns, audit requirements, retry/error handling, and steward approval before canonical updates.

## Decision Drivers

- Exact external/public enrichment sources are not finalized.
- Enrichment may include limited personal/entity information such as owner, tenant, contact, or legal entity attributes.
- Original submitted values should be preserved separately from approved canonical values where practical.
- Low-confidence enrichment and conflicting attributes must be flagged for steward review.
- Enrichment failures and processing issues require monitoring and alerts.
- Data access, enrichment approvals, and administrative events must be auditable.

## Options

### Option A: Governed enrichment orchestration with steward approval gates

Model an enrichment orchestration component that invokes approved external/public sources, records source metadata and confidence, stores enrichment candidates separately from approved canonical values, routes exceptions to stewardship, and updates the Property Master only after policy-based auto-approval or steward approval.

Pros:

- Aligns with BR requirements for provenance, confidence, auditability, and approval.
- Keeps external enrichment isolated from direct canonical writes.
- Supports retry, monitoring, and exception handling.
- Allows source-specific controls without changing the Property Master boundary.

Cons:

- Adds orchestration, candidate-state, and workflow complexity.
- Requires approved source list, data classification, and legal/compliance checks.
- Requires clear criteria for auto-approval versus steward review.

### Option B: Direct enrichment writes to canonical Property Master

External enrichment results update canonical property attributes directly after basic technical validation.

Pros:

- Simpler data flow.
- Faster enrichment turnaround.
- Lower workflow overhead for high-confidence enrichment.

Cons:

- Weak steward control over trusted attributes.
- Higher risk of overwriting canonical values with low-confidence or conflicting results.
- Harder to preserve original and candidate values separately.
- Inadequate for sensitive owner/entity attributes.

### Option C: Manual enrichment only for MVP

Avoid external enrichment automation in MVP and rely on manually prepared enrichment input files.

Pros:

- Lowest external integration risk.
- Easier to govern source approval and quality manually.
- May be sufficient for a small pilot.

Cons:

- Does not prove the reusable enrichment foundation.
- Weak support for eventing, quality indicators, and scalable stewardship.
- May delay validating important MVP requirements.

## Decision

Proposed decision: choose Option A. Model governed enrichment orchestration with approved source configuration, candidate-state storage, confidence/provenance capture, policy-based routing, steward approval gates, retry/error handling, and audit logging.

## Consequences

### Positive

- Protects canonical Property Master quality.
- Provides a clear audit trail for enrichment decisions.
- Supports controlled external integration and future enrichment categories.
- Gives Security a concrete place to review data classification and access controls.

### Negative

- Requires source approval and compliance confirmation before production use.
- Adds workflow complexity to the MVP.
- Requires data quality thresholds and steward routing rules.

### Mitigations

- Limit MVP enrichment categories to approved sources only.
- Keep initial workflow simple: accepted, rejected, needs review, and failed.
- Track approved source list, quality thresholds, and retention/residency requirements as gate questions.

## References

- BR sections 3.1, 5.2, 5.3, 6.1, 6.2, 7.1, 7.2, 8, 9, 11, 12
- ADR-001-0002
- decisions/change-plan.md
