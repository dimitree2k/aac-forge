# Change Plan - Property Intelligence Platform

Status: Stage B applied. The actual model consolidates foundation controls into a thin `GCP Data and AI Foundation` shape instead of modeling every security/platform control as an application-like component.

## Source Inputs

- BR: `examples/property-intelligence/solutions/001_Property Intelligence Platform/input/BR Property Intelligence Platform.md`
- Current model inspected: `model/workspace.c4`, `model/common.c4`
- Current model finding: no existing Property Intelligence, Data and AI, GCP foundation, stewardship, enrichment, or BigQuery analytics elements were found in the root model.

## Proposed Changes

### New People / Actors

| Element ID | Title | Description | ADR |
| --- | --- | --- | --- |
| corporateTechnology | Corporate Technology | Represents business requirements, prioritization, and acceptance expectations | ADR-001-0002 |
| dataStewards | Data Stewards | Review property records, enrichment results, duplicates, merge candidates, and retirement decisions | ADR-001-0005 |
| pilotCountryOwners | Pilot Country Business/Data Owners | Own pilot-country property data acceptance, access expectations, and approval of aggregated metric sharing | ADR-001-0001 |
| dataAiAnalyticsConsumers | Data and AI Analytics Consumers | Consume approved aggregated metrics in BigQuery | ADR-001-0003 |
| selectedPilotUsers | Selected Pilot Users | Validate property profiles through read-only access | ADR-001-0005 |

### New Systems

| System ID | Title | Domain | Description | ADR |
| --- | --- | --- | --- | --- |
| propertyIntelligencePlatform | Property Intelligence Platform | data-and-ai | New Data and AI-operated platform for governed commercial property master data products | ADR-001-0002 |
| gcpDataAiFoundation | GCP Data and AI Foundation | platform-foundation | Shared foundation for country project boundaries, IAM, service perimeters, IaC, observability, key management, and managed data services | ADR-001-0001 |
| externalEnrichmentSources | External/Public Enrichment Sources | external | Approved external or public enrichment services for address validation, geocoding, ownership/entity enrichment, and classification | ADR-001-0006 |
| approvedInternalConsumers | Approved Internal Consumers | consumers | Internal applications, analytics users, data science teams, or future products authorized to consume property outputs | ADR-001-0005 |
| futureProductApplications | Future Product Applications | consumers | Future Property Intelligence, Transactional Intelligence, or related applications that may consume approved APIs, datasets, or events | ADR-001-0004 |

### New Containers

| Container ID | Parent System | Title | Technology | Description | ADR |
| --- | --- | --- | --- | --- | --- |
| propertyIngestionService | propertyIntelligencePlatform | Property Ingestion Service | To be decided | Governed curated file/manual load intake for pilot-country property records | ADR-001-0002 |
| propertyMasterService | propertyIntelligencePlatform | Property Master Service | To be decided | Owns canonical property identifiers, lifecycle states, approved canonical attributes, and property merge/retirement operations | ADR-001-0002 |
| propertyMasterStore | propertyIntelligencePlatform | Property Master Store | To be decided | Country-local canonical store for property master records, provenance, lifecycle, and quality state | ADR-001-0003 |
| duplicateDetectionService | propertyIntelligencePlatform | Duplicate Detection Service | To be decided | Identifies suspected duplicate properties and candidate merges for steward review | ADR-001-0002 |
| enrichmentOrchestrator | propertyIntelligencePlatform | Enrichment Orchestrator | To be decided | Invokes approved enrichment sources, captures outcomes/confidence, retries failures, and routes steward approvals | ADR-001-0006 |
| enrichmentCandidateStore | propertyIntelligencePlatform | Enrichment Candidate Store | To be decided | Stores submitted, enriched, candidate, rejected, and approved values separately where practical | ADR-001-0006 |
| dataQualityLineageService | propertyIntelligencePlatform | Data Quality and Lineage Service | To be decided | Calculates quality indicators and records provenance/lineage for key property attributes | ADR-001-0003 |
| stewardshipUi | propertyIntelligencePlatform | Stewardship UI | To be decided | Lightweight UI for steward review, approvals, merge decisions, retirement decisions, and selected read-only validation | ADR-001-0005 |
| propertyProfileApi | propertyIntelligencePlatform | Property Profile API | To be decided | Country-boundary-aware API for approved internal consumers to retrieve property profile and enrichment information | ADR-001-0005 |
| eventPublisher | propertyIntelligencePlatform | Event Publisher | To be decided | Publishes governed property lifecycle, enrichment, and data quality events | ADR-001-0004 |
| countryDatasetPublisher | propertyIntelligencePlatform | Country Dataset Publisher | To be decided | Publishes governed record-level datasets inside the country boundary | ADR-001-0003 |
| aggregatedMetricsPublisher | propertyIntelligencePlatform | Aggregated Metrics Publisher | To be decided | Publishes approved non-record-level metrics to central BigQuery analytics | ADR-001-0003 |
| auditLogStore | propertyIntelligencePlatform | Audit Log Store | To be decided | Stores access, stewardship, enrichment approval, administrative, publication, and break-glass audit events | ADR-001-0007 |
| countryProjectBoundary | gcpDataAiFoundation | Country Project Boundary | GCP | Per-country project or equivalent hard isolation boundary for record-level property data | ADR-001-0001 |
| countryIamBoundary | gcpDataAiFoundation | Country IAM Boundary | GCP IAM | Country-scoped least-privilege IAM boundary for users, service accounts, and consumers | ADR-001-0001 |
| servicePerimeter | gcpDataAiFoundation | Service Perimeter | VPC Service Controls or equivalent | Boundary control that reduces data exfiltration risk for country data | ADR-001-0001 |
| keyManagementBoundary | gcpDataAiFoundation | Key Management Boundary | To be decided | Encryption and key boundary for country data where required | ADR-001-0007 |
| cicdIacPipeline | gcpDataAiFoundation | CI/CD and IaC Pipeline | To be decided | Repeatable deployment automation and controlled infrastructure/configuration management | ADR-001-0001 |
| observabilityStack | gcpDataAiFoundation | Observability Stack | To be decided | Monitoring, alerting, logging, and operational dashboards for platform health and boundary violations | ADR-001-0007 |
| centralAggregatedMetricsDataset | gcpDataAiFoundation | Central Aggregated Metrics Dataset | BigQuery | Central analytics dataset containing approved aggregated property metrics only | ADR-001-0003 |

### Modified Elements

| Element ID | Change Description | ADR |
| --- | --- | --- |
| model/workspace.c4 | No Stage A edit. Stage B may add views for the Property Intelligence landscape and containers after approval. | ADR-001-0002 |
| model/common.c4 | No Stage A edit. Stage B may add common actors and external systems if the model remains root-scoped. | ADR-001-0002 |

### New Relationships

| From | To | Protocol | Description | ADR |
| --- | --- | --- | --- | --- |
| corporateTechnology | propertyIntelligencePlatform | Business request | Commissions the MVP and acceptance expectations | ADR-001-0002 |
| dataStewards | stewardshipUi | HTTPS | Review property records, enrichment results, duplicates, merges, and retirement decisions | ADR-001-0005 |
| selectedPilotUsers | stewardshipUi | HTTPS | Read-only validation of selected property profiles | ADR-001-0005 |
| propertyIngestionService | propertyMasterService | To be decided | Submit governed curated/manual property inputs for canonical processing | ADR-001-0002 |
| propertyMasterService | propertyMasterStore | To be decided | Create, update, merge, and retire canonical property records | ADR-001-0003 |
| propertyMasterService | duplicateDetectionService | To be decided | Request duplicate detection and merge candidate identification | ADR-001-0002 |
| duplicateDetectionService | stewardshipUi | To be decided | Present suspected duplicates and merge candidates for review | ADR-001-0005 |
| propertyMasterService | dataQualityLineageService | To be decided | Record provenance, lineage, quality status, and quality score changes | ADR-001-0003 |
| enrichmentOrchestrator | externalEnrichmentSources | To be decided | Validate address, geocode, enrich ownership/entity/classification attributes | ADR-001-0006 |
| enrichmentOrchestrator | enrichmentCandidateStore | To be decided | Store enrichment source, timestamp, confidence, outcome, and candidate values | ADR-001-0006 |
| enrichmentOrchestrator | stewardshipUi | To be decided | Route low-confidence or policy-controlled enrichment results for approval | ADR-001-0006 |
| stewardshipUi | propertyMasterService | HTTPS | Approve/reject enrichment, merge, and retirement decisions | ADR-001-0005 |
| propertyProfileApi | propertyMasterService | To be decided | Retrieve approved property profile and enrichment information | ADR-001-0005 |
| approvedInternalConsumers | propertyProfileApi | HTTPS | Retrieve approved country-boundary-aware property profile data | ADR-001-0005 |
| countryDatasetPublisher | propertyMasterStore | To be decided | Read approved canonical record-level data for country-local dataset publication | ADR-001-0003 |
| approvedInternalConsumers | countryDatasetPublisher | Governed dataset | Consume approved record-level property master datasets inside the country boundary | ADR-001-0003 |
| aggregatedMetricsPublisher | propertyMasterStore | To be decided | Read approved inputs for aggregate metric calculation | ADR-001-0003 |
| aggregatedMetricsPublisher | centralAggregatedMetricsDataset | BigQuery | Publish approved counts, coverage, completeness, quality, and duplicate metrics only | ADR-001-0003 |
| dataAiAnalyticsConsumers | centralAggregatedMetricsDataset | BigQuery | Consume approved aggregated metrics | ADR-001-0003 |
| propertyMasterService | eventPublisher | To be decided | Emit property created, updated, merged, and retired events | ADR-001-0004 |
| enrichmentOrchestrator | eventPublisher | To be decided | Emit address validated, geocoding completed, enrichment completed, and quality score changed events | ADR-001-0004 |
| eventPublisher | futureProductApplications | To be decided | Publish governed lifecycle and quality events to authorized consumers | ADR-001-0004 |
| propertyIntelligencePlatform | countryProjectBoundary | GCP boundary | Deploy and process record-level country data inside hard country boundary | ADR-001-0001 |
| propertyIntelligencePlatform | countryIamBoundary | IAM | Enforce country-scoped least-privilege access | ADR-001-0001 |
| propertyIntelligencePlatform | servicePerimeter | Service perimeter | Protect country data against exfiltration outside the approved boundary | ADR-001-0001 |
| propertyIntelligencePlatform | keyManagementBoundary | To be decided | Encrypt data in transit and at rest with approved key boundary | ADR-001-0007 |
| propertyIntelligencePlatform | cicdIacPipeline | CI/CD/IaC | Deploy platform and country environments through controlled automation | ADR-001-0001 |
| propertyIntelligencePlatform | observabilityStack | Logs/metrics/traces | Publish operational monitoring, alerts, audit events, and security boundary signals | ADR-001-0007 |
| stewardshipUi | auditLogStore | To be decided | Log steward actions, approvals, rejections, merges, and retirements | ADR-001-0007 |
| propertyProfileApi | auditLogStore | To be decided | Log API access to property profile and enrichment data | ADR-001-0007 |
| aggregatedMetricsPublisher | auditLogStore | To be decided | Log central metric publication approvals and publication actions | ADR-001-0007 |
| countryIamBoundary | auditLogStore | To be decided | Log administrative, access, and break-glass events | ADR-001-0007 |

### Files Changed After Approval

- `model/domains/property-intelligence.c4` - created the Property Intelligence Platform system, core containers, thin foundation system, actors, adjacent systems, and relationships from the approved change plan.
- `model/workspace.c4` - added solution-specific views for the Property Intelligence Platform.
- `model/common.c4` - unchanged.

The foundation implementation intentionally keeps ADR-001-0001 country/foundation boundary concerns separate from ADR-001-0007 operational security and break-glass controls.

## ADR Coverage Check

| ADR | Corresponding Change Plan Rows |
| --- | --- |
| ADR-001-0001 | `gcpDataAiFoundation`, `countryProjectBoundary`, `countryIamBoundary`, `servicePerimeter`, `cicdIacPipeline`, country-boundary relationships |
| ADR-001-0002 | `propertyIntelligencePlatform`, `propertyIngestionService`, `propertyMasterService`, `duplicateDetectionService`, commissioning and canonical-processing relationships |
| ADR-001-0003 | `propertyMasterStore`, `dataQualityLineageService`, `countryDatasetPublisher`, `aggregatedMetricsPublisher`, `centralAggregatedMetricsDataset`, publishing relationships |
| ADR-001-0004 | `eventPublisher`, property lifecycle and enrichment/quality event relationships |
| ADR-001-0005 | `stewardshipUi`, `propertyProfileApi`, steward, pilot-user, and approved-consumer relationships |
| ADR-001-0006 | `externalEnrichmentSources`, `enrichmentOrchestrator`, `enrichmentCandidateStore`, enrichment and approval relationships |
| ADR-001-0007 | `auditLogStore`, `keyManagementBoundary`, `observabilityStack`, audit, encryption, monitoring, and break-glass control relationships |

## Human Approval Gate

Before Stage B starts, architects must approve or request changes to:

1. The seven Proposed ADRs and whether this is the right ADR volume.
2. The solution boundary between reusable GCP/Data and AI foundation capabilities and Property Intelligence-specific components.
3. The country-isolation control model, including hard project boundary, service perimeter, IAM, encryption/key boundary, and break-glass posture.
4. The data publication model: country-local record-level outputs and central aggregated BigQuery metrics only.
5. The eventing direction, including whether asynchronous event publication is approved before exact technology selection.
6. The API and stewardship serving boundary, including whether a lightweight UI is approved for MVP.
7. The enrichment integration and approval pattern, including whether external/public source integration is allowed in MVP.
8. The proposed Stage B `.c4` file plan.

With `approvalBackend: manual`, approval should be recorded by filling each ADR front matter `approval.reference` and `approvers` block. Until that is done, the workflow remains stopped at the decision gate.
