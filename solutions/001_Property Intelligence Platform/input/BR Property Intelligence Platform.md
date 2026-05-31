# BR Property Intelligence Platform

# 1. General Project Information

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

## 1.2 Project Description

The Property Intelligence Platform project establishes a reusable internal data and intelligence capability for commercial real estate property records.

The first release focuses on creating a trusted Property Master for one pilot country. It should support governed ingestion of curated source files or manually prepared input data, selected external/public enrichment, property lifecycle and enrichment events, data quality checks, stewardship review, and approved publishing of property master outputs.

The MVP is not intended to deliver a full business portal or advanced intelligence product. It is intended to prove that Data and AI can own and operate a reusable property data product foundation that can later support additional countries, downstream product applications, and more advanced intelligence use cases.

**MVP objective:** Produce a governed canonical Property Master for one pilot country with measurable data quality, lineage, stewardship, and controlled consumption.

**Commissioned by:** Corporate Technology, representing the business requirements and future internal consumers.

**Initial owner/operator assumption:** Data and AI owns and operates the first release end to end. Detailed RACI across Data and AI, GCP infrastructure, DevOps, Security, and future application teams must be refined later.

**Primary consumers for MVP:**

- Data and AI analytics consumers using approved aggregated BigQuery metrics.
- Data stewards responsible for property record review, enrichment approval, merge approval, and retirement approval.
- Selected pilot users validating property profiles through a lightweight read-only/stewardship UI.

**Future consumers:**

- Property Intelligence application teams.
- Transactional Intelligence Platform or other future intelligence applications.
- Corporate Technology analysts and business stakeholders.
- Country teams and other approved internal product teams.

## 1.3 Business Context

There is currently no reusable governed property data product for commercial real estate assets. Downstream teams and future applications risk building their own property views, identifiers, quality rules, and enrichment logic independently.

This creates inconsistent property definitions, duplicated data preparation effort, unclear lineage, and weak reuse across future intelligence applications. The first release should establish the foundation for a trusted Property Master without prematurely committing to all future intelligence capabilities.

# 2. Business Goals

## 2.1 MVP Goals

- Establish a governed canonical Property Master for one pilot country.
- Support commercial real estate assets such as office, retail, logistics, industrial, and mixed-use properties.
- Enable controlled enrichment of property records using selected external/public sources.
- Provide measurable data quality, duplicate detection, provenance, and lineage for property records.
- Provide a lean stewardship workflow for reviewing and approving enrichment results, merge candidates, and retirement decisions.
- Publish approved country-local property master outputs for authorized consumers.
- Publish only approved aggregated metrics for cross-country or central analytics.
- Establish a thin reusable GCP, data platform, delivery, and operations foundation that can be reused by later countries and applications.

## 2.2 Success Measures

- A canonical Property Master exists for one pilot country.
- Each property record has a stable identifier, source provenance, quality status, and lifecycle status.
- Data stewards can review and approve enrichment, merge, and retirement decisions.
- Property lifecycle and enrichment/quality events are produced for approved consumers.
- Country data is isolated so record-level property data is not accessible cross-country.
- Aggregated metrics are available for Data and AI analytics in BigQuery.
- Open architecture decisions are clear enough to drive ADRs in the later architecture workflow.

# 3. Scope

## 3.1 In Scope

- One pilot country.
- Commercial real estate property master records.
- Curated files or manually governed loads as initial MVP inputs.
- Selected external/public enrichment sources for address validation, geocoding, ownership/entity enrichment, classification, or similar attributes.
- Property lifecycle events:
  - property created
  - property updated
  - property merged
  - property retired
- Enrichment and data quality events:
  - address validated
  - geocoding completed
  - enrichment completed
  - quality score changed
- Governed datasets for property master consumption inside the country boundary.
- APIs for property profile and enrichment lookup by approved internal consumers.
- Approved aggregated metrics in BigQuery for Data and AI analytics.
- Lightweight stewardship and validation UI.
- Country-level isolation, encryption, auditability, and break-glass access controls.
- Thin shared platform foundation requirements for GCP, data platform, CI/CD, IaC, observability, and support.

## 3.2 Out of Scope

- Advanced AI/ML scoring, recommendations, predictions, valuation models, and risk models.
- Transactional Intelligence Platform capabilities.
- Lease, deal, sale, payment, or operational transaction analysis.
- Full product portal, rich dashboards, or complex end-user workflows.
- External user access.
- Multi-country rollout beyond the first pilot country.
- Real-time operational decisioning.
- Exact vendor, tool, or GCP service selection.
- Final RACI for every platform, DevOps, security, and operations role.

## 3.3 Future Scope Candidates

- Additional countries onboarded country-by-country.
- Risk and opportunity signals.
- Market, valuation, rent, regulatory, and environmental indicators.
- Search and retrieval capabilities across property metadata.
- Downstream application consumption by Property Intelligence and Transactional Intelligence products.
- Broader stewardship reporting, issue management, workflow configuration, and service-level tracking.
- More advanced analytics or AI/ML capabilities after the governed property master foundation is proven.

# 4. Stakeholders and Consumers

| Stakeholder / Consumer | Role in MVP |
| --- | --- |
| Corporate Technology | Represents business requirements, prioritization, and acceptance expectations |
| Data and AI | Owns and operates the initial Property Intelligence Platform and data products |
| Data Stewards | Review property records, enrichment results, duplicates, merge candidates, and retirement decisions |
| Pilot Country Business/Data Owners | Own country-specific property data acceptance, access expectations, and approval of aggregated metric sharing |
| Data and AI Analytics Consumers | Consume approved aggregated BigQuery metrics |
| GCP Infrastructure | Provides or supports the cloud foundation, country projects, IAM, network controls, observability, and service perimeter capabilities |
| Dev and DevOps Teams | Support application delivery, CI/CD, IaC, deployment automation, and operational practices |
| Security and Compliance | Review country isolation, encryption, access controls, audit logging, and break-glass requirements |
| Future Product Teams | Potential consumers of property master APIs, events, and datasets |

# 5. Functional Requirements

## 5.1 Property Master

- FR-01: The platform must create and maintain a canonical Property Master for commercial real estate assets in the pilot country.
- FR-02: Each property master record must have a stable unique identifier controlled by the platform.
- FR-03: Each property master record must support lifecycle states including created, active, merged, and retired.
- FR-04: Each property master record must retain source provenance and lineage for key attributes.
- FR-05: The platform must support duplicate detection and candidate merge identification.
- FR-06: The platform must support approved merge and retirement decisions by data stewards.

## 5.2 Input and Enrichment

- FR-07: The platform must support MVP input from curated files or manually governed loads.
- FR-08: The platform must support selected external/public enrichment for address validation, geocoding, ownership/entity enrichment, classification, or similar approved attributes.
- FR-09: The platform must record enrichment source, timestamp, confidence, and processing outcome.
- FR-10: The platform must allow enrichment results to be reviewed and approved before they become trusted property master attributes where stewardship rules require approval.
- FR-11: The platform must preserve original submitted values separately from approved canonical values where practical.

## 5.3 Data Quality and Stewardship

- FR-12: The platform must calculate and expose data quality indicators for property master records.
- FR-13: The platform must flag records requiring steward review, including low-confidence enrichment, suspected duplicates, conflicting attributes, and retirement candidates.
- FR-14: Data stewards must be able to approve or reject enrichment results.
- FR-15: Data stewards must be able to approve merge candidates.
- FR-16: Data stewards must be able to approve property retirement decisions.
- FR-17: Stewardship actions must be auditable.

## 5.4 Events

- FR-18: The platform must emit or publish property lifecycle events for property created, updated, merged, and retired.
- FR-19: The platform must emit or publish enrichment and data quality events for address validated, geocoding completed, enrichment completed, and quality score changed.
- FR-20: Events must include enough metadata for authorized consumers to understand event type, affected property identifier, country boundary, timestamp, and correlation context.
- FR-21: The exact event technology, event schema standard, and delivery guarantees must be decided during the architecture workflow.

## 5.5 Datasets, APIs, and Analytics Outputs

- FR-22: The platform must publish governed property master datasets for authorized consumers inside the country boundary.
- FR-23: The platform must expose APIs for approved internal consumers to retrieve property profile and enrichment information.
- FR-24: Record-level property data must not be made available outside the owning country boundary.
- FR-25: The platform must publish approved aggregated metrics to BigQuery for Data and AI analytics.
- FR-26: Initial aggregated metrics must be limited to counts and data quality/completeness metrics, such as property counts, enrichment coverage, completeness scores, quality scores, and duplicate rates by country, region, or property category.

## 5.6 Lightweight UI

- FR-27: The platform must provide a lightweight UI for data stewards to review property records, enrichment results, duplicate candidates, merge decisions, and retirement decisions.
- FR-28: The platform must provide selected pilot users with a read-only way to inspect property profiles for validation.
- FR-29: The UI is not required to be a full product portal in the MVP.

# 6. Non-Functional Requirements

## 6.1 Security and Isolation

| Requirement | MVP Target |
| --- | --- |
| Country isolation | Record-level country-owned property data must be isolated by country |
| Cross-country access | Cross-country access to record-level property data is not allowed by default |
| Shared analytics | Only approved aggregated metrics may be shared centrally |
| Cloud boundary | Per-country GCP projects or equivalent hard boundaries are required |
| Service perimeter | VPC Service Controls or equivalent controls must protect country data boundaries |
| Access control | IAM must be country-scoped and least-privilege by default |
| Encryption | Data must be encrypted in transit and at rest |
| Break-glass | Emergency access must be controlled, time-limited, approved, logged, and reviewed |
| Auditability | Access, changes, stewardship actions, enrichment approvals, and administrative events must be logged |

## 6.2 Data Quality and Lineage

| Requirement | MVP Target |
| --- | --- |
| Provenance | Key property attributes must retain source and processing lineage |
| Completeness | Completeness must be measured for required property master fields |
| Duplicate detection | Suspected duplicates must be detectable and reviewable |
| Enrichment confidence | Enrichment results must expose confidence or quality indicators where available |
| Quality visibility | Property records must expose quality status to stewards and approved consumers |

## 6.3 Reuse and Evolvability

- The platform must be designed as a reusable data product foundation, not as a one-off country data load.
- The architecture must support future onboarding of additional countries without weakening country data isolation.
- The platform must support future consumers through datasets, APIs, and events.
- The architecture must not preclude future Property Intelligence or Transactional Intelligence applications.
- Exact service choices, event technologies, API standards, and dataset publishing patterns should be decided through ADRs.

## 6.4 Availability, Performance, and Freshness

- The MVP must support event-based updates rather than batch-only processing.
- The exact event processing latency target is an open question for architecture discovery.
- Property profile lookup APIs should be suitable for internal application integration, but final latency and throughput targets must be confirmed during architecture discovery.
- Stewardship UI availability should be sufficient for business-hours operations in the pilot country.
- Aggregated metrics freshness should align to approved analytics needs and country governance constraints.

# 7. Data and Integration Requirements

## 7.1 Input Data

| Source Category | MVP Expectation |
| --- | --- |
| Curated property inputs | Supported through governed file/manual load process |
| External/public enrichment | Supported for selected approved enrichment categories |
| Existing internal source systems | Not assumed for MVP; future integrations remain open |
| Transactional systems | Out of scope for MVP |

## 7.2 Integration Requirements

| From | To | Pattern | Purpose |
| --- | --- | --- | --- |
| Curated input process | Property Intelligence Platform | File/manual governed load | Create or update pilot country property records |
| Property Intelligence Platform | External/public enrichment sources | To be decided | Validate address, geocode, enrich, and classify property records |
| Property Intelligence Platform | Authorized country-local consumers | Governed dataset | Provide approved property master data inside the country boundary |
| Approved internal consumers | Property Intelligence Platform | API | Retrieve property profile and enrichment information |
| Property Intelligence Platform | Event consumers | Event-based | Publish property lifecycle and enrichment/quality events |
| Property Intelligence Platform | BigQuery analytics dataset | Aggregated dataset | Publish approved counts and data quality/completeness metrics |
| Data stewards | Stewardship UI | Human workflow | Review and approve enrichment, merge, and retirement decisions |

## 7.3 Analytics Sharing Rules

- Country-owned record-level property data must remain inside the country boundary.
- Central or cross-country analytics may receive only approved aggregated metrics.
- Initial shared metrics must be limited to counts and quality/completeness indicators.
- Any expansion of shared analytics beyond these metrics requires explicit approval and likely an ADR.

# 8. Security and Compliance Requirements

- SCR-01: The platform must enforce per-country data isolation for record-level property data.
- SCR-02: The MVP must use one pilot country boundary and support future country-by-country expansion.
- SCR-03: Country-specific data must be stored in per-country GCP projects or equivalent hard isolation boundaries.
- SCR-04: VPC Service Controls or equivalent service perimeter controls must be in place for country data boundaries.
- SCR-05: Encryption must be applied for data in transit and data at rest.
- SCR-06: Access to country property data must be least-privilege and country-scoped.
- SCR-07: Cross-country access to record-level property data must be denied by default.
- SCR-08: Break-glass access must require approval, be time-limited, be logged, and be reviewed after use.
- SCR-09: Stewardship actions, data access, administrative actions, and data publication actions must be auditable.
- SCR-10: Aggregated metrics shared outside the country boundary must be approved and must not expose record-level or identifiable property data.
- SCR-11: The platform must support classification of property data that may include limited personal/entity information such as owner, tenant, contact, or legal entity attributes.
- SCR-12: Retention, residency, and jurisdiction-specific compliance requirements must be confirmed for the pilot country during architecture discovery.

# 9. Operational and Support Requirements

- OSR-01: Data and AI must be able to operate the MVP end to end under the initial ownership assumption.
- OSR-02: The platform must have deployment automation suitable for repeatable country environments.
- OSR-03: Infrastructure and configuration should be managed through IaC or equivalent controlled automation.
- OSR-04: The platform must expose operational monitoring for ingestion/enrichment processing, event publication, API health, stewardship queues, and aggregated metric publication.
- OSR-05: Operational alerts must cover failed loads, failed enrichment, event publication failures, API degradation, and security boundary violations where detectable.
- OSR-06: Support procedures must define how data stewards, platform operators, and security reviewers handle incidents and exceptions.
- OSR-07: Break-glass access must have an operational runbook before production use.
- OSR-08: Country onboarding should be repeatable, but only one pilot country is required for MVP.

# 10. Assumptions

- A1: Data and AI owns and operates the first release end to end.
- A2: Detailed RACI across Data and AI, GCP infrastructure, DevOps, Security, Corporate Technology, and future application teams will be refined later.
- A3: The MVP starts with one pilot country.
- A4: MVP input can come from curated files or manually governed loads.
- A5: Existing internal source-system integrations are not required for MVP.
- A6: The first release focuses on commercial real estate assets.
- A7: Exact external/public enrichment sources are not finalized.
- A8: Exact GCP services, eventing technology, API platform, storage services, and catalog/lineage tooling are not finalized.
- A9: Per-country GCP projects, VPC Service Controls, encryption, audit logging, and break-glass controls are expected foundation requirements.
- A10: Future applications, including Transactional Intelligence Platform, should be able to reuse the foundation where appropriate.

# 11. Open Questions

- OQ-01: Which country is the pilot country?
- OQ-02: Who is the accountable business owner for pilot country property data?
- OQ-03: Which property attributes are mandatory for the initial canonical Property Master?
- OQ-04: Which external/public enrichment sources are approved for MVP?
- OQ-05: What quality thresholds must a property record meet before it is considered trusted?
- OQ-06: What are the target event delivery guarantees and latency expectations?
- OQ-07: Which consumers are authorized to call property profile APIs during MVP?
- OQ-08: What exact aggregated metrics are approved for central BigQuery analytics?
- OQ-09: What aggregation thresholds or disclosure controls are required before metrics leave the country boundary?
- OQ-10: What retention, residency, and jurisdiction-specific compliance rules apply to the pilot country?
- OQ-11: What support hours and incident response expectations apply to the MVP?
- OQ-12: How will stewardship responsibilities be assigned and measured?

# 12. Candidate Architecture Decisions for Later ADRs

The following are candidate decisions for the later BR -> ADRs -> SAD workflow. They are not decided by this BR.

| Candidate Decision | Why It May Need an ADR |
| --- | --- |
| Country isolation model | Defines hard boundaries across GCP projects, IAM, VPC Service Controls, data storage, and operations |
| Shared foundation vs product-specific implementation | Determines which capabilities become reusable platform foundation versus Property Intelligence-specific implementation |
| Eventing pattern and delivery guarantees | Chooses how property lifecycle and enrichment events are published, consumed, secured, and replayed |
| Property master storage and publishing pattern | Determines canonical storage, governed datasets, country-local publishing, and BigQuery aggregated output design |
| API serving pattern | Determines how approved consumers access property profiles and enrichment data |
| Enrichment integration pattern | Determines how external/public enrichment sources are integrated, governed, retried, and audited |
| Data stewardship workflow implementation | Determines whether stewardship is custom-built, configured in a data governance tool, or implemented through another platform capability |
| Catalog, lineage, and quality tooling | Determines how provenance, lineage, quality scoring, and data product discoverability are implemented |
| Encryption and key management approach | Determines use of platform-managed versus customer-managed keys and country-specific key boundaries |
| Break-glass operating model | Defines emergency access approvals, logging, time limits, and post-access review |
| Aggregated analytics publication model | Determines how approved metrics are transformed, thresholded, and published for central analytics without exposing record-level country data |
| Country onboarding pattern | Determines how new countries are provisioned, governed, monitored, and supported using the same foundation |

