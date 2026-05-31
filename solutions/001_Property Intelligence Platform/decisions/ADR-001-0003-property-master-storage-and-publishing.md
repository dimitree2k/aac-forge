---
id: ADR-001-0003
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

# ADR-001-0003: Property Master Storage and Publishing Pattern

## Context

The platform must maintain canonical Property Master records with stable identifiers, lifecycle status, provenance, lineage, quality status, and approved canonical attributes. It must publish governed property master datasets for authorized consumers inside the country boundary, expose APIs for approved consumers, and publish only approved aggregated metrics to BigQuery for central analytics.

This is consequential because it defines the primary data protection and publication pattern for country-owned record-level data.

## Decision Drivers

- Record-level country data must not be accessible cross-country by default.
- Approved central analytics are limited to aggregated metrics.
- Property records must preserve original submitted values separately from approved canonical values where practical.
- Quality, provenance, and lineage must be visible to stewards and approved consumers.
- Future consumers need stable datasets, APIs, and events.
- Exact storage and catalog tooling are not finalized in the BR.

## Options

### Option A: Country-local canonical store plus country-local governed datasets and central aggregated metrics

Maintain the canonical Property Master inside the pilot-country boundary. Publish governed record-level datasets only inside that same boundary. Publish a separate approved aggregated metrics dataset to central BigQuery after aggregation and disclosure controls.

Pros:

- Directly enforces country record-level isolation.
- Separates canonical record storage from central analytics publication.
- Supports country-local consumers without exposing records centrally.
- Creates a clear place for aggregation thresholds and approval controls.

Cons:

- Requires more publication paths to model and operate.
- Requires controls to prevent accidental central publication of record-level fields.
- Requires explicit metric approval and disclosure thresholds.

### Option B: Central canonical store with country-scoped access controls

Maintain a central canonical store for all countries and enforce country separation with IAM, row-level policies, views, and application controls.

Pros:

- Simplifies cross-country analytics and global property identity management.
- Can reduce duplication if many countries share the same platform.
- Easier to run central data quality reporting.

Cons:

- Conflicts with the BR's default denial of cross-country record-level access.
- Increases blast radius of access-control failures.
- Harder to align with per-country project or equivalent hard boundaries.

### Option C: Dataset-only publication without a canonical service boundary

Load property records into governed datasets, publish derived tables and views, and defer a canonical store/service until later.

Pros:

- Simpler initial data engineering implementation.
- May satisfy basic analytics and reporting needs for the pilot.
- Avoids committing to an application-style service boundary.

Cons:

- Weakens API, event, lifecycle, and stewardship consistency.
- Risks treating the Property Master as a derived dataset rather than a governed canonical source.
- Makes stable identifier and lifecycle operations harder to own.

## Decision

Proposed decision: choose Option A. Use a country-local canonical Property Master store as the source for country-local governed datasets, property profile APIs, and event generation. Publish only explicitly approved aggregated metrics to central BigQuery, with metric definitions and disclosure thresholds treated as approval inputs.

## Consequences

### Positive

- Aligns the data architecture with country isolation requirements.
- Makes central publication a controlled transformation, not a direct replication.
- Supports both country-local record-level consumption and central aggregate analytics.
- Gives Security a clear review point for aggregation and disclosure controls.

### Negative

- Requires additional publication, monitoring, and audit controls.
- Requires approval of exact central metrics and aggregation thresholds.
- Requires care to keep APIs and datasets consistent with the canonical store.

### Mitigations

- Model separate containers for canonical storage, country dataset publication, and aggregated metrics publication.
- Keep exact storage and BigQuery implementation choices out of this ADR unless required by reviewers.
- Track OQ-08 and OQ-09 as gate questions for approved metrics and disclosure controls.

## References

- BR sections 2.1, 2.2, 5.1, 5.5, 6.1, 6.2, 7.3, 8, 11, 12
- ADR-001-0001
- decisions/change-plan.md
