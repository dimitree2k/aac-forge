---
solution: "001"
title: "Property Intelligence Platform"
status: "Approved"
author: "A. Architect"
reviewer: "Demo Architecture Gate"
date: "2026-05-31"
revision: 2
adrs:
  - ADR-001-0001
  - ADR-001-0002
  - ADR-001-0003
  - ADR-001-0004
  - ADR-001-0005
  - ADR-001-0006
  - ADR-001-0007
approvals:
  - role: "Solution Architect"
    name: "Demo Architecture Gate"
    date: "2026-05-31"
  - role: "Enterprise Architect"
    name: "Demo Architecture Gate"
    date: "2026-05-31"
  - role: "Security Specialist"
    name: "Demo Architecture Gate"
    date: "2026-05-31"
  - role: "Business Process Owner"
    name: "Demo Architecture Gate"
    date: "2026-05-31"
changelog:
  - rev: 1
    date: "2026-05-31"
    author: "A. Architect"
    changes: "Initial draft - Stage A skeleton with open architecture decisions"
  - rev: 2
    date: "2026-05-31"
    author: "A. Architect"
    changes: "Full SAD - accepted ADRs stamped, LikeC4 model built, diagrams exported, data flows and traceability completed"
---

# SAD Property Intelligence Platform

# 1. General Project/Task Information

## 1.1 Glossary

| Term | Description |
| --- | --- |
| Property Intelligence Platform | Internal platform capability for creating, governing, enriching, and publishing reusable commercial property intelligence data products |
| Property Master | Canonical, governed representation of a commercial real estate asset used as the trusted property reference for downstream consumers |
| Commercial Real Estate Asset | Business property such as office, retail, logistics, industrial, mixed-use, or similar investment/portfolio asset |
| Enrichment | Process of improving property records with validated address, geocoding, ownership/entity, classification, or other approved external/public attributes |
| Data Product | Governed dataset or API-backed capability with defined ownership, quality expectations, access controls, and consumption contracts |
| Data Steward | Business or data operations role responsible for reviewing property records, resolving duplicates, approving merges, and handling data quality exceptions |
| Country Boundary | Security, governance, and operational boundary that prevents country-owned property records from being accessed by other countries or central consumers except through approved aggregated outputs |
| Aggregated Metrics | Non-record-level summary measures such as property counts, enrichment coverage, completeness scores, and duplicate rates |
| Break-Glass Access | Controlled emergency access process with approval, time limits, audit logging, and post-access review |
| VPC Service Controls | GCP control used to reduce risk of data exfiltration across configured service perimeters |
| Downstream Consumer | Internal application, analytics user, data science team, or future product that consumes approved property intelligence outputs |

## 1.2 Project/Task Description

The Property Intelligence Platform establishes a reusable Data and AI-operated platform for governed commercial property master data products. The MVP creates a canonical Property Master for one pilot country, supports governed ingestion of curated or manually prepared inputs, selected external/public enrichment, data quality and lineage, steward review, country-local publication, approved property APIs, event publication, and central aggregated metrics.

**MVP objective:** Produce a governed canonical Property Master for one pilot country with measurable data quality, lineage, stewardship, and controlled consumption.

**Commissioned by:** Corporate Technology, representing business requirements and future internal consumers.

**Initial owner/operator assumption:** Data and AI owns and operates the first release end to end. GCP Infrastructure, DevOps, Security, and pilot-country owner responsibilities remain open items for operating-model refinement.

**Primary consumers for MVP:**

- Data and AI analytics consumers using approved aggregated BigQuery metrics.
- Data stewards reviewing property records, enrichment results, duplicate candidates, merge decisions, and retirement decisions.
- Selected pilot users validating property profiles through read-only UI access.
- Approved internal consumers using country-boundary-aware APIs and governed country-local datasets.

**Constraints:**

- One pilot country only for MVP.
- Record-level property data remains inside the owning country boundary.
- Central or cross-country analytics receive only approved aggregated metrics.
- Per-country GCP projects or equivalent hard boundaries are required.
- VPC Service Controls or equivalent service perimeter controls must protect country data boundaries.
- Encryption, auditability, country-scoped least privilege, and controlled break-glass access are mandatory.
- Exact vendor, GCP service, eventing, API, catalog, lineage, and workflow tooling choices remain "to be decided" implementation details.

# 2. Business Architecture and Requirements

[BR Property Intelligence Platform](../input/BR%20Property%20Intelligence%20Platform.md)

# 3. Architecture Solution Description

## 3.1 Proposed Solution Description

The approved solution introduces a new **Property Intelligence Platform** system operated by Data and AI. It is a reusable platform capability, not a one-off country data load and not a full product portal.

The platform contains:

1. **Property Ingestion Service** - governs curated file and manual load intake for pilot-country property records.
2. **Property Master Service** - owns canonical identifiers, lifecycle states, approved canonical attributes, merges, and retirements.
3. **Property Master Store** - country-local canonical record store for Property Master records, provenance, lifecycle, and quality state.
4. **Duplicate Detection Service** - identifies suspected duplicate properties and candidate merges.
5. **Enrichment Orchestrator** - invokes approved enrichment sources and routes candidates to stewardship when required.
6. **Enrichment Candidate Store** - preserves submitted, enriched, candidate, rejected, and approved values separately where practical.
7. **Data Quality and Lineage Service** - calculates quality indicators and records provenance and lineage.
8. **Stewardship UI** - lightweight UI for steward review and selected read-only pilot validation.
9. **Property Profile API** - country-boundary-aware API for approved internal consumers.
10. **Event Publisher** - publishes governed lifecycle, enrichment, and data quality events.
11. **Country Dataset Publisher** - publishes approved record-level datasets inside the country boundary.
12. **Aggregated Metrics Publisher** - publishes approved central aggregate metrics only.
13. **Audit Log Store** - stores access, stewardship, enrichment approval, administrative, publication, and break-glass audit events.

The approved model also introduces a thin **GCP Data and AI Foundation**. Per review guidance, this is not modeled as a detailed application component set. It contains only:

- **Country Boundary Controls** - per-country project boundary, country-scoped IAM, service perimeter, and key boundary controls.
- **Delivery and Observability Foundation** - CI/CD, IaC, logging, monitoring, and alerting capabilities.
- **Central Aggregated Metrics Dataset** - BigQuery dataset containing approved non-record-level property metrics only.

This preserves the distinction between ADR-001-0001, which defines the country/foundation boundary, and ADR-001-0007, which defines operational security, audit, and break-glass controls.

**List of systems and IT services used:**

| System/Service | Description | CMDB Link |
| --- | --- | --- |
| Property Intelligence Platform | New Data and AI-operated platform for governed commercial property master data products | |
| GCP Data and AI Foundation | Thin shared foundation for country boundary controls, delivery/observability, and central aggregate analytics | |
| External/Public Enrichment Sources | Approved sources for address validation, geocoding, ownership/entity enrichment, and classification | |
| Approved Internal Consumers | Internal systems and teams authorized for country-boundary-aware API or dataset consumption | |
| Future Product Applications | Future Property Intelligence, Transactional Intelligence, or related applications consuming approved events | |

## 3.2 Information Architecture

### Data Flow Diagram

![Solution 001 Property Intelligence](solution001PropertyIntelligence.png)

Mermaid source: [solution001PropertyIntelligence.mmd](solution001PropertyIntelligence.mmd)

**Data flow description:**

| Code | Data Object | Source | Consumer | Type | Status | Mode | Data | Protocol | Transport | Comment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| INF01 | Curated property inputs | Property Ingestion Service | Property Master Service | Internal | New | Synchronous | Source property records, submitted values, country context, load metadata | REST/HTTPS | HTTP | Governed file/manual input after intake controls |
| INF02 | Canonical property master changes | Property Master Service | Property Master Store | Internal | New | Synchronous | Stable property ID, lifecycle state, approved attributes, merge/retirement status | TCP | Database | Country-local canonical persistence |
| INF03 | Duplicate detection request | Property Master Service | Duplicate Detection Service | Internal | New | Synchronous | Candidate property attributes, matching keys, country context | REST/HTTPS | HTTP | Used to identify suspected duplicates and merge candidates |
| INF04 | Provenance, lineage, and quality updates | Property Master Service | Data Quality and Lineage Service | Internal | New | Synchronous | Attribute sources, lineage, quality scores, completeness indicators | REST/HTTPS | HTTP | Supports quality visibility and auditability |
| INF05 | Enrichment request and response | Enrichment Orchestrator | External/Public Enrichment Sources | External | New | Synchronous | Address, geocode, ownership/entity, classification attributes as approved | REST/HTTPS | HTTP | Limited to approved sources and categories |
| INF06 | Enrichment candidates | Enrichment Orchestrator | Enrichment Candidate Store | Internal | New | Synchronous | Source, timestamp, confidence, outcome, candidate values | TCP | Database | Candidate values are separated from approved canonical values |
| INF07 | Enrichment review item | Enrichment Orchestrator | Stewardship UI | Internal | New | Synchronous | Low-confidence or policy-controlled enrichment candidates | REST/HTTPS | HTTP | Routes items requiring steward review |
| INF08 | Steward review and approval actions | Data Stewards | Stewardship UI | Human/System | New | Synchronous | Approvals, rejections, merge decisions, retirement decisions, notes | HTTPS | Browser | Business-hours stewardship workflow |
| INF09 | Read-only property profile validation | Selected Pilot Users | Stewardship UI | Human/System | New | Synchronous | Approved property profile fields and quality status | HTTPS | Browser | Not a full product portal |
| INF10 | Property profile and enrichment lookup | Approved Internal Consumers | Property Profile API | Internal | New | Synchronous | Property ID, query parameters, consumer context | REST/HTTPS | HTTP | Country-boundary-aware API access |
| INF11 | Approved property profile query | Property Profile API | Property Master Service | Internal | New | Synchronous | Property profile, enrichment data, lineage and quality indicators | REST/HTTPS | HTTP | API reads approved canonical profile information |
| INF12 | Country-local dataset extract | Country Dataset Publisher | Property Master Store | Internal | New | Scheduled/Controlled | Approved record-level property master data | TCP | Database | Record-level output remains inside country boundary |
| INF13 | Governed country-local dataset consumption | Approved Internal Consumers | Country Dataset Publisher | Internal | New | Controlled | Approved record-level datasets | HTTPS | Governed dataset access | Access is limited to authorized country-local consumers |
| INF14 | Aggregation input | Aggregated Metrics Publisher | Property Master Store | Internal | New | Scheduled/Controlled | Approved fields needed for counts and quality/completeness metrics | TCP | Database | Used only for non-record-level metrics |
| INF15 | Approved aggregated metrics publication | Aggregated Metrics Publisher | Central Aggregated Metrics Dataset | Internal | New | Scheduled/Controlled | Approved counts, coverage, completeness, quality, and duplicate-rate metrics only | HTTPS | BigQuery API | No record-level or identifiable property data is published centrally |
| INF16 | Aggregated metrics consumption | Data and AI Analytics Consumers | Central Aggregated Metrics Dataset | Internal | New | Query | Approved aggregate metrics | HTTPS | BigQuery API | Central analytics consumption |
| INF17 | Property lifecycle events | Property Master Service | Event Publisher | Internal | New | Asynchronous | Created, updated, merged, retired events with property ID and country boundary | Kafka | TCP | Schema-governed event publication |
| INF18 | Enrichment and quality events | Enrichment Orchestrator | Event Publisher | Internal | New | Asynchronous | Address validated, geocoding completed, enrichment completed, quality score changed | Kafka | TCP | Published after governed processing |
| INF19 | Governed lifecycle and quality events | Event Publisher | Future Product Applications | Internal | New | Asynchronous | Authorized event payloads with country metadata and correlation context | Kafka | TCP | Enables future approved consumers |
| INF20 | Stewardship audit events | Stewardship UI | Audit Log Store | Internal | New | Synchronous | User, action, record, decision, timestamp, reason | TCP | Database | Required for stewardship auditability |
| INF21 | Property profile API access audit events | Property Profile API | Audit Log Store | Internal | New | Synchronous | Consumer, property ID, access reason/context, timestamp | TCP | Database | Required for access auditability |
| INF22 | Aggregated metric publication audit events | Aggregated Metrics Publisher | Audit Log Store | Internal | New | Synchronous | Metric set, approval reference, publication timestamp | TCP | Database | Required for central publication auditability |
| INF23 | Administrative, access, and break-glass audit events | Country Boundary Controls | Audit Log Store | Internal | New | Controlled | Access, administrative actions, break-glass approval and review metadata | HTTPS | Platform audit integration | Supports ADR-001-0007 operating model |
| INF24 | Duplicate and merge candidates for review | Duplicate Detection Service | Stewardship UI | Internal | New | Synchronous | Candidate property IDs, match rationale, confidence, source attributes, country context | REST/HTTPS | HTTP | Presents suspected duplicates and merge candidates for steward action |
| INF25 | Steward approval, rejection, merge, and retirement decisions | Stewardship UI | Property Master Service | Internal | New | Synchronous | Decision type, steward, affected property IDs, reason, timestamp, correlation ID | REST/HTTPS | HTTP | Applies steward decisions to the canonical Property Master through controlled service operations |

## 3.3 System Architecture

### Container Diagram

![Property Intelligence Containers](propertyIntelligenceContainers.png)

Mermaid source: [propertyIntelligenceContainers.mmd](propertyIntelligenceContainers.mmd)

# 4. Implementation

## 4.1 Implementation Requirements

- Create `model/domains/property-intelligence.c4` with the Property Intelligence Platform, thin GCP Data and AI Foundation, consumers, enrichment sources, and future application systems.
- Keep GCP/Data and AI foundation modeling thin: country boundary controls, delivery/observability foundation, and central aggregate dataset only.
- Implement the Property Intelligence Platform containers listed in section 3.1.
- Preserve the country-local canonical Property Master store and country-local record-level publication boundary.
- Publish only approved aggregate metrics centrally.
- Implement asynchronous event publication for property lifecycle and enrichment/quality events.
- Implement a lightweight stewardship UI, not a full product portal.
- Implement audit logging for stewardship actions, property profile access, aggregate publication, administrative access, and break-glass events.
- Keep technologies marked "To be decided" until implementation discovery names concrete services.

## 4.2 System and IT Service Modifications

| System/Service | Work Description |
| --- | --- |
| Property Intelligence Platform | New system with ingestion, master, storage, duplicate detection, enrichment, lineage, UI, API, event, publication, metrics, and audit containers |
| GCP Data and AI Foundation | New thin foundation system with country boundary controls, delivery/observability foundation, and central BigQuery aggregate dataset |
| External/Public Enrichment Sources | New external dependency, limited to approved enrichment categories and sources |
| Approved Internal Consumers | New consuming system boundary for approved API and country-local dataset access |
| Future Product Applications | New future consumer boundary for governed event consumption |
| Root LikeC4 workspace | Added Property Intelligence views to `model/workspace.c4` |

# 5. Information Security

## 5.1 Authentication and Authorization

| Purpose | Consumer System | Account Type | Status | Role | Role Status | Credential Storage | Data Flows |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Steward review and approval | Data Stewards | User | New | Country-scoped steward | New | Enterprise IAM | INF08, INF24, INF25, INF20 |
| Pilot profile validation | Selected Pilot Users | User | New | Read-only pilot validator | New | Enterprise IAM | INF09 |
| Property profile lookup | Approved Internal Consumers | Service | New | Country-scoped read | New | Vault or platform secret manager | INF10, INF11, INF21 |
| Country-local dataset consumption | Approved Internal Consumers | User/Service | New | Country-local dataset reader | New | Enterprise IAM / platform IAM | INF13 |
| Enrichment source access | Enrichment Orchestrator | Service | New | Approved source client | New | Vault or platform secret manager | INF05 |
| Event publication | Property Master Service, Enrichment Orchestrator | Service | New | Event publisher | New | Vault or platform secret manager | INF17, INF18 |
| Aggregate metrics publication | Aggregated Metrics Publisher | Service | New | Aggregate publisher | New | Platform IAM | INF14, INF15, INF22 |
| Break-glass administration | Country Boundary Controls | Privileged user/service | New | Time-limited emergency access | New | Enterprise IAM / privileged access manager | INF23 |

## 5.2 Logging and Audit

- Stewardship actions are logged with user, record, action, decision, reason, and timestamp.
- Property profile API access is logged with consumer, property ID, country context, and timestamp.
- Aggregate metric publication is logged with metric set, approval reference, publisher, and timestamp.
- Administrative, country-boundary, and break-glass events are logged with approval, time limit, actor, action, and post-access review metadata.
- Enrichment requests and outcomes are logged with source, timestamp, confidence, result status, and correlation ID.
- Security boundary violations are monitored where detectable through the delivery and observability foundation.

## 5.3 External Data Access

External data access is limited to approved external/public enrichment sources for MVP categories such as address validation, geocoding, ownership/entity enrichment, and classification. Exact sources require approval before production use. Enrichment may include limited personal/entity information, so source selection, retention, and jurisdiction-specific rules must be confirmed.

## 5.4 System and IT Service Publishing

| System/Service | Location |
| --- | --- |
| Property Intelligence Platform | Pilot-country GCP project or equivalent hard country boundary |
| Property Master Store | Pilot-country boundary only |
| Country Dataset Publisher | Pilot-country boundary only |
| Central Aggregated Metrics Dataset | Central BigQuery analytics environment, aggregated metrics only |
| Audit Log Store | Pilot-country boundary or approved audit boundary with country-aware controls |

### MVP Aggregated Metrics Publication Controls

The MVP central analytics publication is limited to the following aggregate metric allow-list:

| Metric family | Allowed dimensions | Notes |
| --- | --- | --- |
| Property counts | Country, region, property category, lifecycle status | Counts only; no property identifiers, addresses, coordinates, or names |
| Enrichment coverage | Country, region, property category, enrichment category | Percent or count of records with approved enrichment coverage |
| Completeness scores | Country, region, property category, completeness band | Banding only; no record-level field completeness output |
| Quality scores | Country, region, property category, quality band | Banding only; no individual property score output |
| Duplicate rates | Country, region, property category | Aggregate duplicate candidate counts or rates only |

Disclosure assumptions for MVP:

- No record-level property data, stable property identifiers, addresses, exact coordinates, ownership/entity attributes, tenant/contact attributes, or free-text fields may be published to the Central Aggregated Metrics Dataset.
- Aggregates may be published only for groups with at least 10 contributing property records.
- Groups below the minimum threshold must be suppressed or combined into a higher-level approved grouping.
- Percentages and rates are rounded to whole percentages for central publication.
- Publication of new metric families, new dimensions, or lower thresholds requires explicit approval and likely a superseding ADR or new ADR if it changes the approved sharing model.

Approval responsibility:

- Data and AI data product owner prepares the metric definition and publication evidence.
- Pilot Country Business/Data Owner approves that the metric is allowed to leave the country boundary.
- Security and Compliance approves the disclosure controls and confirms that the output does not expose record-level or identifiable property data.
- The Aggregated Metrics Publisher records the approval reference in INF22 before INF15 publication.

## 5.5 Flows with Protected Information

- INF01 through INF14 may involve record-level property data and must remain inside the country boundary unless explicitly aggregated.
- INF05 may include external/public enrichment attributes and must be limited to approved sources and approved data categories.
- INF10, INF11, and INF13 expose record-level property information and require country-scoped authorization.
- INF15 and INF16 contain allow-listed aggregate metrics only and must not expose record-level or identifiable property data.
- INF20 through INF25 contain audit, administrative, and stewardship decision metadata and must be protected from unauthorized access.

## 5.6 File Exchange with External Systems

MVP input may include curated files or manually governed loads through the Property Ingestion Service. External enrichment uses approved API-based integrations. No uncontrolled file exchange with external systems is approved by this SAD.

# 6. Support Information

| System/Service | Development Contact | Support Team | Criticality | Technology Stack |
| --- | --- | --- | --- | --- |
| Property Ingestion Service | | Data and AI | Medium | To be decided |
| Property Master Service | | Data and AI | High | To be decided |
| Property Master Store | | Data and AI / GCP Infrastructure | High | To be decided |
| Duplicate Detection Service | | Data and AI | Medium | To be decided |
| Enrichment Orchestrator | | Data and AI | Medium | To be decided |
| Stewardship UI | | Data and AI | Medium | To be decided |
| Property Profile API | | Data and AI | High | To be decided |
| Event Publisher | | Data and AI / DevOps | Medium | To be decided |
| Country Dataset Publisher | | Data and AI | High | To be decided |
| Aggregated Metrics Publisher | | Data and AI | Medium | To be decided |
| Audit Log Store | | Data and AI / Security | High | To be decided |
| GCP Data and AI Foundation | | GCP Infrastructure / DevOps / Security | High | GCP / CI/CD / BigQuery |

# 7. Non-Functional Requirements

| Metric | Value |
| --- | --- |
| Country isolation | Record-level country data remains inside the owning country boundary |
| Cross-country access | Denied by default for record-level property data |
| Central analytics | Approved aggregate metrics only |
| Encryption | Required in transit and at rest |
| Auditability | Access, changes, stewardship actions, enrichment approvals, administrative actions, publication actions, and break-glass events logged |
| Stewardship UI availability | Business-hours operation for pilot country; exact target to be confirmed |
| Property profile API latency | Suitable for internal application integration; exact p95 target to be confirmed |
| Event processing | Event-based updates required; latency and delivery guarantees to be confirmed |
| Aggregated metrics freshness | Must align to approved analytics needs and country governance constraints |
| Country onboarding | Repeatable pattern required, but only one pilot country in MVP |
| Operational alerts | Failed loads, failed enrichment, event publication failures, API degradation, and detectable security boundary violations |

# 8. Architecture Decisions

| ADR | Title | Status | Summary |
| --- | --- | --- | --- |
| ADR-001-0001 | Country isolation and shared foundation boundary | Accepted | Use a hard pilot-country boundary and a thin reusable GCP/Data and AI foundation. |
| ADR-001-0002 | Property master system boundary | Accepted | Introduce a new reusable Data and AI-operated Property Intelligence Platform system. |
| ADR-001-0003 | Property master storage and publishing pattern | Accepted | Keep canonical and record-level datasets country-local; publish only approved aggregate metrics centrally. |
| ADR-001-0004 | Property lifecycle and quality eventing pattern | Accepted | Use asynchronous governed event publication for lifecycle, enrichment, and quality events. |
| ADR-001-0005 | API and stewardship serving pattern | Accepted | Provide a thin property profile API and lightweight stewardship/read-only validation UI. |
| ADR-001-0006 | Enrichment integration and approval pattern | Accepted | Use governed enrichment orchestration with candidate storage, confidence capture, retries, and steward approval gates. |
| ADR-001-0007 | Security controls and break-glass operating model | Accepted | Apply explicit audit, encryption, least-privilege, publication, monitoring, and break-glass controls. |

# 9. Traceability Matrix

| BR Requirement | SAD Section | Implementation |
| --- | --- | --- |
| FR-01, FR-02, FR-03, FR-04 | 3.1, 3.2 | Property Master Service and Property Master Store; INF01, INF02 |
| FR-05, FR-06 | 3.1, 3.2 | Duplicate Detection Service and Stewardship UI; INF03, INF24, INF25, INF20 |
| FR-07 | 3.1, 3.2 | Property Ingestion Service; INF01 |
| FR-08, FR-09, FR-10, FR-11 | 3.1, 3.2, 5.3 | Enrichment Orchestrator and Enrichment Candidate Store; INF05, INF06, INF07 |
| FR-12, FR-13 | 3.1, 3.2 | Data Quality and Lineage Service and Stewardship UI; INF04, INF07, INF08 |
| FR-14, FR-15, FR-16, FR-17 | 3.1, 3.2, 5.2 | Stewardship UI, Property Master Service, and Audit Log Store; INF08, INF25, INF20 |
| FR-18, FR-19, FR-20, FR-21 | 3.1, 3.2 | Event Publisher; INF17, INF18, INF19; technology and guarantees remain implementation decisions within ADR-001-0004 |
| FR-22, FR-24 | 3.1, 3.2, 5.4 | Country Dataset Publisher and country boundary controls; INF12, INF13 |
| FR-23 | 3.1, 3.2 | Property Profile API; INF10, INF11 |
| FR-25, FR-26 | 3.1, 3.2, 5.4 | Aggregated Metrics Publisher, Central Aggregated Metrics Dataset, MVP metric allow-list, and disclosure controls; INF14, INF15, INF16, INF22 |
| FR-27, FR-28, FR-29 | 3.1, 3.2 | Lightweight Stewardship UI; INF08, INF09; full portal remains out of scope |
| SCR-01 through SCR-04, SCR-06, SCR-07 | 3.1, 5.1, 5.4 | Country Boundary Controls in thin GCP/Data and AI Foundation; ADR-001-0001 |
| SCR-05, SCR-08, SCR-09 | 5.1, 5.2 | Authentication, encryption, audit logging, and break-glass audit flow; ADR-001-0007; INF20-INF23 |
| SCR-10 | 3.2, 5.4, 5.5 | Aggregated Metrics Publisher, central aggregate-only dataset, minimum group-size threshold, suppression/rounding controls, and approval evidence; INF15, INF16, INF22 |
| SCR-11, SCR-12 | 5.3, 5.5, 11 | External enrichment classification and pilot-country compliance open questions |
| OSR-01 through OSR-08 | 4, 5, 6, 7 | Data and AI operating model, CI/CD/IaC, observability, alerts, support table, break-glass runbook requirement, repeatable country boundary |

# 10. Open Decisions

All Stage A architecture decisions have been accepted for this demo. Future changes to accepted decisions require new ADRs or superseding ADRs.

# 11. Open Questions and Pilot Gates

The following items remain visible for the demo. They do not reopen the accepted architecture decisions, but they control whether the solution can move from enterprise demo to real pilot implementation.

## 11.1 Demo Assumptions

| Question | Demo assumption | Real implementation impact |
| --- | --- | --- |
| Which country is the pilot country? | A single pilot-country boundary exists but is unnamed in the demo. | Must be named before environment provisioning and compliance review. |
| Who is the accountable business owner for pilot-country property data? | Pilot Country Business/Data Owner role exists. | Named accountable owner required before metric publication and data acceptance. |
| Which consumers are authorized to call property profile APIs during MVP? | Approved Internal Consumers are represented as a controlled consumer boundary. | Named consumers and access approvals required before production access. |
| What support hours and incident response expectations apply to the MVP? | Business-hours stewardship operation is assumed for the demo. | Support hours and incident response targets required before go-live. |

## 11.2 Pre-Production / Pilot-Discovery Gates

| Gate | Question | Required before real implementation |
| --- | --- | --- |
| Data definition gate | Which property attributes are mandatory for the initial canonical Property Master? | Mandatory attribute set, validation rules, and acceptance criteria. |
| Enrichment approval gate | Which external/public enrichment sources are approved for MVP? | Approved source list, data categories, outbound attributes, compliance approval, quotas, and support owner. |
| Quality gate | What quality thresholds must a property record meet before it is considered trusted? | Trusted-record threshold, duplicate confidence threshold, steward routing rules, and exception handling. |
| Event contract gate | What are the target event delivery guarantees and latency expectations? | Event schema, retention/replay posture, delivery target, dead-letter handling, and consumer SLA assumptions. |
| Aggregate publication gate | Which exact aggregated metrics are approved for central BigQuery analytics? | Metric definitions must stay within the allow-list in section 5.4, with approval evidence recorded before INF15 publication. |
| Disclosure gate | What aggregation thresholds or disclosure controls are required before metrics leave the country boundary? | MVP assumes minimum group size 10, suppression for smaller groups, and whole-percentage rounding; any weaker control requires explicit Security and country-owner approval. |
| Compliance gate | What retention, residency, and jurisdiction-specific compliance rules apply to the pilot country? | Retention schedule, residency constraints, audit boundary decision, and break-glass review process. |
| Stewardship operating gate | How will stewardship responsibilities be assigned and measured? | Named steward group, queue ownership, turnaround expectations, escalation path, and audit review cadence. |
