---
id: ADR-001-0004
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
  - role: "Adjacent System Owner"
    name: "Demo Architecture Gate"
    date: "2026-05-31"
supersedes: []
superseded-by: []
---

# ADR-001-0004: Property Lifecycle and Quality Eventing Pattern

## Context

The BR requires property lifecycle events for created, updated, merged, and retired records, plus enrichment and data quality events for address validation, geocoding, enrichment completion, and quality score changes. Events must include metadata for event type, property identifier, country boundary, timestamp, and correlation context. The exact event technology, schema standard, and delivery guarantees are explicitly open.

This is consequential because it chooses between synchronous and asynchronous integration patterns and affects future consumers, replay, delivery guarantees, security controls, and operational monitoring.

## Decision Drivers

- MVP must support event-based updates rather than batch-only processing.
- Future product applications and event consumers should be able to react to approved property changes.
- Country boundary metadata and authorization constraints must travel with events.
- Delivery latency and guarantees are open questions.
- Event publication failures must be monitored and alerted.
- Exact eventing technology is not finalized in the BR.

## Options

### Option A: Asynchronous governed event publication

Publish property lifecycle, enrichment, and quality events asynchronously through a governed event channel with schema ownership, country-boundary metadata, replay posture, consumer authorization, and monitoring.

Pros:

- Matches the BR requirement for event-based updates.
- Decouples future consumers from property-master write paths.
- Supports replay and multiple authorized consumers if the chosen platform permits.
- Makes event schemas and country metadata explicit architecture assets.

Cons:

- Requires event platform, schema, ACL, and delivery guarantee decisions.
- Adds operational complexity around retries, dead-letter handling, and monitoring.
- Eventual consistency must be acceptable for consumers.

### Option B: Synchronous consumer callbacks or polling APIs

Use synchronous REST callbacks or polling APIs for consumers that need property changes.

Pros:

- Simpler for a small number of known consumers.
- Easier to reason about request/response errors.
- Avoids introducing or selecting event infrastructure for MVP.

Cons:

- Does not satisfy the BR direction for event-based updates as cleanly.
- Couples the Property Intelligence Platform to consumer availability and SLA.
- Poor fit for future multiple consumers and replay needs.

### Option C: Batch-only publication of changes

Publish change extracts on a schedule and defer eventing.

Pros:

- Lowest operational complexity for MVP.
- Fits analytics-only consumption.
- Avoids event schema and platform decisions initially.

Cons:

- Conflicts with the BR requirement for event-based updates.
- Weakens future application integration.
- Delays downstream reaction to stewardship-approved changes.

## Decision

Proposed decision: choose Option A. Model an asynchronous governed event publication pattern for property lifecycle and enrichment/quality events. Defer exact technology and latency values until architecture approval, but require schema governance, country-boundary metadata, authorized consumer access, failure monitoring, and replay/dead-letter posture in Stage B.

## Consequences

### Positive

- Aligns with the BR's event-based update requirement.
- Reduces coupling between the Property Intelligence Platform and future consumers.
- Supports richer downstream products without changing the canonical write path.
- Gives adjacent system owners clear event contracts to review.

### Negative

- Introduces eventual consistency.
- Requires operational handling for failed publications and consumers.
- Requires a schema and compatibility management process.

### Mitigations

- Keep initial event scope to BR-listed lifecycle, enrichment, and quality events.
- Treat event delivery guarantees and latency as explicit gate questions.
- Include security requirements for event ACLs, encryption, and country metadata in Stage B.

## References

- BR sections 5.4, 6.3, 6.4, 7.2, 9, 11, 12
- ADR-001-0001
- decisions/change-plan.md
