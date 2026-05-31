# SAD Review Property Intelligence Platform

**Review date:** 2026-05-31  
**Reviewed document:** [SAD Property Intelligence Platform](SAD%20Property%20Intelligence%20Platform.md)  
**Review scope:** BR coverage, accepted ADR alignment, LikeC4 model consistency, SAD rev 2 completeness, security and country isolation, data/integration flows, and operational/support assumptions.

## Summary

| Role | Critical | Significant | Minor | Recommendations |
| --- | ---: | ---: | ---: | ---: |
| Solution Architect | 0 | 1 | 0 | 3 |
| Enterprise Architect | 0 | 2 | 0 | 1 |
| Security Specialist | 0 | 3 | 0 | 1 |
| Adjacent System Owner | 0 | 3 | 0 | 1 |
| Business Process Owner | 0 | 2 | 0 | 1 |
| **Total** | **0** | **11** | **0** | **7** |

### Finding Classification

- **Critical** - blocks implementation or creates significant risk. Requires mandatory correction before SAD approval.
- **Significant** - notable deficiency that needs to be addressed, but does not block implementation.
- **Minor** - small defect, typo, stylistic comment.
- **Recommendation** - improvement suggestion, not a finding.

---

## 1. Solution Architect

*Focus: technical quality, architecture correctness, decomposition, integration patterns, NFRs, completeness.*

### Findings

| # | Severity | SAD Section | Description | Recommendation |
| --- | --- | --- | --- | --- |
| SA-1 | Recommendation | SAD 3.2, model `property-intelligence.c4` | Remediated: duplicate/merge candidate review and steward approval decisions now have explicit INF24 and INF25 rows in the model and SAD data flow table. | Preserve INF24 and INF25 in future diagram exports and traceability updates. |
| SA-2 | Recommendation | SAD 3.2, model `property-intelligence.c4`, docs/reference/dsl-conventions.md | Remediated: relationship protocol labels now use standard protocol terms such as `HTTPS`; BigQuery and GCP remain technology/location context rather than protocol labels. | Keep protocol values aligned with `docs/reference/dsl-conventions.md` or update the convention if new protocol labels become standard. |
| SA-3 | Significant | SAD 4.1, 6, 7 | Most containers and support entries remain `To be decided`, and NFRs such as API latency, event delivery guarantees, stewardship UI availability, and metric freshness remain unquantified. This is acceptable for architecture framing, but not enough for implementation estimation or readiness. | Before implementation planning, add target technology choices or candidate service classes, minimum NFR targets, and assumptions for throughput, latency, event retention/replay, and freshness. |
| SA-4 | Recommendation | SAD 3.3 and output diagrams | The SAD references the clean solution-specific views only, and the model validates. The current output folder is scoped correctly after removing stale `index` and `landscape` exports. | Preserve filtered exports for solution packages so future workspace-level views do not leak unrelated model content into solution deliverables. |

### Overall Assessment

The component split is coherent and follows the accepted ADRs: canonical master, enrichment, stewardship, API, events, publication, metrics, and audit responsibilities are separated. The remaining technical gap is implementation readiness detail: technology choices, NFR targets, and operational characteristics remain open.

---

## 2. Enterprise Architect

*Focus: IT landscape alignment, reuse, naming conventions, architectural principles, CMDB links.*

### Findings

| # | Severity | SAD Section | Description | Recommendation |
| --- | --- | --- | --- | --- |
| EA-1 | Significant | SAD 3.1, 4.2, 6 | The SAD lists new systems and services but leaves all CMDB links blank and most development contacts blank. ADR-001-0002 explicitly introduces a new reusable platform system, so ownership and inventory registration are enterprise-relevant design outputs. | Add CMDB placeholders or registration tasks for Property Intelligence Platform, GCP Data and AI Foundation, and central aggregated metrics dataset. Add accountable owner fields for Data and AI, GCP Infrastructure, DevOps, and Security. |
| EA-2 | Significant | SAD 3.1, 4.2; ADR-001-0001 | The thin foundation model is appropriately restrained, but the SAD still does not define whether GCP Data and AI Foundation is a solution-local abstraction, a reusable platform product, or a future separate foundation solution. This affects reuse and governance for later countries and future applications. | Add an explicit foundation governance note: whether this solution owns only a reference architecture slice, or whether a separate foundation solution/ADR package must be created before reuse by later applications. |
| EA-3 | Recommendation | model/workspace.c4 | The root `landscape` view still uses `include *`. It is enterprise-clean now, but future unrelated domains will be included automatically. | Keep solution deliverables on filtered solution-specific views, or introduce portfolio/domain-specific landscape views when multiple enterprise solutions exist in the root model. |

### Overall Assessment

The solution aligns with the multi-project slicing principle by keeping Property Intelligence separate from broader foundation concerns. The largest enterprise gaps are governance and ownership: CMDB registration, foundation product ownership, and cross-team RACI remain too implicit.

---

## 3. Information Security Specialist

*Focus: authentication, authorization, secret management, data protection, logging, audit, network security.*

### Findings

| # | Severity | SAD Section | Description | Recommendation |
| --- | --- | --- | --- | --- |
| SEC-1 | Recommendation | SAD 3.2 INF15-INF16, 5.4, 5.5, 11; BR SCR-10 | Remediated: SAD 5.4 now defines an MVP aggregate metric allow-list, minimum group size 10, suppression for smaller groups, whole-percentage rounding, approval responsibility, and an explicit prohibition on central record-level or identifiable property data publication. | Before real pilot launch, replace demo assumptions with approved country-specific metric definitions and approval references. |
| SEC-2 | Significant | SAD 5.1, 5.4; ADR-001-0001 and ADR-001-0007 | The SAD distinguishes country boundary controls from operational security controls, but the deployment boundary for the Audit Log Store is ambiguous: "Pilot-country boundary or approved audit boundary". That ambiguity matters because audit records may contain protected metadata and break-glass details. | Decide and document the audit boundary model, including whether audit data remains country-local, is replicated to a central security boundary, or is dual-written with country-aware controls. |
| SEC-3 | Significant | SAD 5.1, 5.2, 5.5 | Secret management and encryption are described generically as "Vault or platform secret manager" and "required in transit and at rest". Key ownership, rotation, service-to-service authentication, and event/dataset ACL controls are not specified enough to verify least privilege. | Add security implementation requirements for service identity, key ownership, key rotation, event ACLs, dataset ACLs, and API authorization claims before production readiness. |
| SEC-4 | Significant | SAD 5.3, 5.5, 11; BR SCR-11/SCR-12 | External/public enrichment can include owner, tenant, contact, or legal entity attributes, but the SAD leaves approved sources, data classification, retention, residency, and jurisdiction-specific compliance open. | Add a pre-production security gate for each enrichment source: approved source list, data categories, allowed outbound attributes, retention/residency assessment, and compliance approval reference. |

### Overall Assessment

The accepted ADRs correctly identify country isolation, least privilege, audit, and break-glass as architecture concerns. The central aggregation finding has been addressed for demo approval. Remaining security work is pre-production hardening: audit boundary, concrete identity/key controls, and enrichment source compliance.

---

## 4. Adjacent System Owner

*Focus: impact on existing systems, new dependencies, SLA, operational support, backward compatibility.*

### 4.1 GCP Data and AI Foundation

| # | Severity | SAD Section | Description | Recommendation |
| --- | --- | --- | --- | --- |
| SYS-1 | Significant | SAD 1.2, 4.2, 6, 7; BR OSR-01/OSR-06 | The SAD assumes Data and AI owns and operates the MVP while GCP Infrastructure, DevOps, and Security support the foundation. It does not define responsibility splits for provisioning, service perimeter changes, IAM changes, CI/CD, observability, incident response, or break-glass review. | Add a RACI table or support matrix covering Data and AI, GCP Infrastructure, DevOps, Security, and pilot-country owner responsibilities for build, deploy, operate, incident, and exception processes. |

### 4.2 External/Public Enrichment Sources

| # | Severity | SAD Section | Description | Recommendation |
| --- | --- | --- | --- | --- |
| SYS-2 | Significant | SAD 3.2 INF05, 5.3, 7, 11 | The external enrichment dependency is modeled, but exact sources, API contracts, quotas, retries, error handling, data categories, and support contacts are unresolved. This makes it impossible for an adjacent source owner or vendor owner to confirm load and SLA impact. | Add a source-by-source integration appendix before implementation: endpoint/API shape, quota/rate limits, retry policy, timeout policy, failure modes, contact/owner, and data handling constraints. |

### 4.3 Future Product Applications and Approved Internal Consumers

| # | Severity | SAD Section | Description | Recommendation |
| --- | --- | --- | --- | --- |
| SYS-3 | Significant | SAD 3.2 INF10, INF13, INF19; ADR-001-0004/0005 | Future applications and approved consumers are represented as broad system boundaries, but API contracts, dataset contracts, event schemas, delivery guarantees, and consumer onboarding controls are not defined. Consumer owners cannot yet assess compatibility or operational impact. | Add consumer contract artifacts or SAD subsections for API access, governed dataset access, and event consumption, including schema/versioning, authorization model, SLA assumptions, and onboarding approval. |
| SYS-4 | Recommendation | SAD 3.2, 5.1 | Approved Internal Consumers are a modeled system, but the process for becoming approved is not described. | Add a lightweight consumer onboarding process: requester, country owner approval, Security approval if record-level access is requested, access expiry/review cadence, and audit evidence. |

### Overall Assessment

Adjacent system impact is mostly contained because the MVP starts with curated input, approved enrichment, and future consumer boundaries rather than modifying existing source systems. The remaining risk is operational: foundation, enrichment, and consumer teams do not yet have enough contract or support detail to commit to the design.

---

## 5. Business Process Owner

*Focus: BR coverage, user journey, business value, usability, artifact quality.*

### Business Requirements Coverage

| Requirement from BR | Status | Comment |
| --- | --- | --- |
| FR-01 to FR-04 Property Master | Covered | Property Master Service and Store cover canonical records, stable IDs, lifecycle, provenance, and lineage. |
| FR-05 to FR-06 Duplicate detection, merge and retirement | Covered | Duplicate Detection Service, Stewardship UI, and Property Master Service now include explicit INF24 and INF25 decision flows. |
| FR-07 Curated/manual input | Covered | Property Ingestion Service and INF01 cover governed inputs. |
| FR-08 to FR-11 Enrichment | Partial | Enrichment orchestration is modeled, but approved sources, data categories, and quality thresholds remain open. |
| FR-12 to FR-17 Quality and stewardship | Partial | Quality/lineage and audit are modeled; stewardship journey and operational measures are not yet detailed. |
| FR-18 to FR-21 Events | Partial | Event Publisher and INF17-INF19 cover direction; delivery guarantees, schemas, and latency remain open. |
| FR-22 to FR-26 Datasets, APIs, analytics | Covered for demo | Country-local datasets, API, and central aggregates are modeled; SAD 5.4 now defines the MVP metric allow-list and disclosure threshold assumptions. |
| FR-27 to FR-29 Lightweight UI | Covered | Stewardship UI and read-only validation are included, and full portal scope is explicitly excluded. |
| SCR-01 to SCR-12 Security and compliance | Partial | Country isolation, aggregate disclosure controls, and audit controls are modeled; enrichment classification, retention/residency, and audit boundary remain pre-production gates. |
| OSR-01 to OSR-08 Operations and support | Partial | Support table and observability foundation exist; RACI, support hours, incident process, and break-glass runbook remain open. |

### Findings

| # | Severity | SAD Section | Description | Recommendation |
| --- | --- | --- | --- | --- |
| BIZ-1 | Significant | SAD 11; BR 2.2, 5, 8, 9 | Remediated for demo: SAD 11 now distinguishes demo assumptions from pre-production/pilot-discovery gates. The open questions remain visible, but are no longer presented as blockers to enterprise demo approval. They remain blockers for real pilot implementation. | Resolve the pre-production gate table before real implementation starts, especially pilot country, accountable owner, mandatory attributes, approved sources, compliance, support hours, and stewardship ownership. |
| BIZ-2 | Significant | SAD 3.1, 3.2, 7 | The SAD lists stewardship capabilities and flows, but does not describe an end-to-end steward journey for enrichment review, duplicate merge approval, retirement approval, exception handling, or SLA/queue management. This weakens usability and operational acceptance. | Add a concise steward workflow section covering queue entry, review screen, approve/reject, merge/retire decision, audit trail, exception escalation, and expected turnaround/support hours. |
| BIZ-3 | Recommendation | SAD 3.1, 3.2 | The SAD correctly avoids a full product portal. The minimum read-only validation experience for selected pilot users is still implicit. | Add a short MVP screen/function list for selected pilot users and data stewards so "lightweight UI" has a shared business meaning without expanding scope. |

### Overall Assessment

The architecture covers the BR at a structural level and respects MVP scope. Demo approval risk is reduced by distinguishing demo assumptions from real implementation gates. Business acceptance for a live pilot still depends on resolving the pre-production gates in SAD 11.

---

## Final Conclusion

The architecture is directionally aligned with the BR and the accepted ADRs. The LikeC4 model validates, the solution-specific diagrams are clean, and the SAD references all seven Accepted ADRs. The design correctly preserves country-local record-level data and central aggregate-only analytics as the core boundary.

The review does not recommend changing the accepted high-level architecture. The previous approval-blocking issues have been remediated for enterprise demo approval:

1. Aggregated metrics now have an MVP allow-list, threshold, disclosure, and approval model.
2. Open business questions are now framed as demo assumptions versus pre-production/pilot-discovery gates.

Remaining findings are significant implementation-readiness items, not critical architecture blockers.

### Recommended Order for Addressing Findings

1. Address SEC-2, SEC-3, SEC-4, SYS-1, SYS-2, and SYS-3 before implementation planning.
2. Address SA-3, EA-1, EA-2, and BIZ-2 before delivery estimation.
3. Resolve BIZ-1 pre-production gates before real pilot launch.
4. Fold recommendations SA-4, EA-3, SYS-4, and BIZ-3 into documentation cleanup and operating-model refinement.
