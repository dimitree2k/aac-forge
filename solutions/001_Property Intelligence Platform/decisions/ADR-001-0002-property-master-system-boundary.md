---
id: ADR-001-0002
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

# ADR-001-0002: Property Master System Boundary

## Context

The BR states that there is no reusable governed property data product for commercial real estate assets. The MVP must create a trusted Property Master for one pilot country while proving that Data and AI can own and operate a reusable data product foundation for later countries, downstream product applications, and more advanced intelligence use cases.

This is consequential because it introduces a new system boundary and determines whether the MVP becomes a reusable platform capability or a one-off country data load.

## Decision Drivers

- The platform must maintain canonical property identifiers, lifecycle states, provenance, lineage, duplicate detection, stewardship decisions, and quality indicators.
- The MVP is not a full business portal or advanced intelligence product.
- The solution must support future country onboarding and downstream consumers.
- The architecture must not preclude future Property Intelligence or Transactional Intelligence applications.
- Data and AI owns and operates the first release under the current assumption.

## Options

### Option A: New reusable Property Intelligence Platform system

Model a new Property Intelligence Platform system containing the canonical Property Master capability, ingestion, enrichment orchestration, stewardship workflow, quality/lineage services, APIs, event publication, and dataset publication.

Pros:

- Directly supports the BR goal of a reusable governed data product foundation.
- Creates a clear ownership boundary for Data and AI.
- Allows future product applications to consume stable APIs, datasets, and events.
- Avoids hiding property-master responsibilities inside unrelated analytics or ETL components.

Cons:

- Introduces a new system requiring governance, support, CMDB registration, and operating model definition.
- Requires explicit interfaces with foundation services and downstream consumers.
- Needs careful scope control to avoid becoming a broad product portal.

### Option B: One-off pilot-country data load and analytics dataset

Implement only the pilot-country Property Master as a governed load into an analytics dataset, with stewardship and quality controls handled manually or in spreadsheets.

Pros:

- Lower initial build effort.
- Faster path to proving data availability for one country.
- Avoids creating a permanent platform boundary before full demand is proven.

Cons:

- Conflicts with the BR's reusable platform objective.
- Weak support for stable identifiers, lineage, eventing, APIs, and stewardship auditability.
- Likely causes rework when adding countries or consumers.
- Risks downstream teams building inconsistent property definitions.

### Option C: Extend an existing data platform or governance tool as the primary system

Use an existing data platform or governance workflow tool as the primary system boundary, configuring property-specific datasets, quality rules, stewardship queues, and publication interfaces.

Pros:

- Maximizes reuse if a mature platform already exists.
- May reduce custom build scope for catalog, lineage, quality, and workflow.
- Can align with enterprise data governance standards.

Cons:

- The current repo model does not expose a relevant existing property or data governance system.
- The BR does not name a specific existing platform or tool.
- May blur responsibility for APIs, eventing, and property-master lifecycle ownership.
- Tool fit must be proven before using it as the core system boundary.

## Decision

Proposed decision: choose Option A for the Stage B model, while allowing individual containers to be implemented with reused platform services where available. The Property Intelligence Platform should be modeled as a new Data and AI-operated system with a deliberately narrow MVP scope.

## Consequences

### Positive

- Establishes a clear canonical Property Master boundary.
- Supports stable future consumption through datasets, APIs, and events.
- Makes stewardship, data quality, lineage, and publication responsibilities explicit.
- Prevents a one-off pilot from becoming the de facto architecture.

### Negative

- Requires ownership, support, and CMDB decisions for the new system.
- Requires an explicit decision on what belongs in the shared foundation versus the property-specific platform.
- Requires later model work to avoid over-modeling implementation details.

### Mitigations

- Keep MVP containers tied to BR requirements and avoid modeling advanced AI/ML or portal capabilities.
- Use ADR-001-0001 to constrain foundation responsibilities.
- List tool-fit and RACI gaps as open questions in the SAD.

## References

- BR sections 1.2, 1.3, 2.1, 3.1, 3.2, 4, 5.1, 6.3, 10, 12
- docs/input/specs/ADR-process.md
- decisions/change-plan.md
