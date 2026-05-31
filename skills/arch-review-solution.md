# arch-review-solution

**What it does:** Conducts a comprehensive review of a solution (SAD) from 5 role perspectives against enumerated model artifacts, and generates a findings report. Uses structured enumeration + concrete checklists so the review is systematic rather than gestalt — fewer missed gaps.

**Argument:** Path to the solution folder, e.g. `solutions/001_Property Intelligence Platform`.

If no argument is provided, ask the user.

---

## Design Notes (Provider-Agnostic)

This playbook is designed to work reliably across DeepSeek, Gemini, Claude, and Codex.
Key design decisions:

- **Enumeration before judgment.** Phase 1.5 produces structured tables (Systems,
  Containers, Relationships, BR Requirements) that become the single source of truth.
  Every checklist item cross-references these tables, so the LLM is executing lookup
  tasks rather than subjective "does this look right?" judgments.

- **Checklists are itemized tasks, not prose paragraphs.** Each item is a concrete
  instruction: "For each Container where X, verify Y." This prevents the LLM from
  doing a superficial gestalt pass and stopping.

- **Explicit anti-skip instructions.** Every checklist includes: "For each item, write
  EITHER a finding (with severity + SAD section + recommendation) OR `✓ OK — <brief
  reason>`. Do not skip items silently." Without this, some providers will skip items
  they can't easily answer.

- **Minimum-findings guard.** Each role must produce ≥3 findings (or explicitly explain
  why fewer). Roles with 0–1 findings are almost always under-reviewing.

- **Pattern detection rules are explicit.** Cross-cutting checks (store+event
  consistency, external-call resilience, API contracts, event schemas, data schemas)
  are enumerated as discrete checklist items. DeepSeek in particular needs patterns
  spelled out rather than inferred.

- **Structured output format.** The REVIEW-template.md provides the shape. Findings use
  a fixed table format with mandatory columns (Severity, SAD Section, Description,
  Recommendation, Cross-Ref).

---

## Algorithm

### Phase 1. CONTEXT GATHERING

**1.1 Read input documents**
Use `readFile` to read all files from `<solution>/input/` — BR documents, descriptions, process diagrams.

> **Large files:** If documents exceed read limits, use `readFile` with `head`/`tail` or `range` options.

**1.2 Read output documents**
Use `readFile` to read all files from `<solution>/output/` — SAD document, exported diagrams. Skip legend/key files.

**1.3 Read the current architecture model**
Use `searchFiles` with pattern `*.c4` under `model/` to discover all model files.
Use `readFile` to read discovered model files.

**1.4 Read standards (if present)**
Use `searchFiles` with pattern `*.md` under `docs/` to find standards files (excluding tutorials and how-to guides).
Use `readFile` to read any found standards — they contain normative requirements to reference during review.

Minimum: read `docs/reference/dsl-conventions.md` and `docs/reference/visual-notation.md`.

**1.5 Read ADRs and change plan**
Use `searchFiles` with pattern `ADR-*.md` under `<solution>/decisions/` to find ADRs.
Use `readFile` to read every discovered ADR.
Also read `<solution>/decisions/change-plan.md` if it exists.

Cross-reference: every Accepted ADR must appear in the SAD's Architecture Decisions section (section 8).

---

### Phase 1.5. PRE-REVIEW ENUMERATION

**Produce structured enumeration tables from the model + SAD + BR.** These tables are
the single source of truth that every subsequent checklist cross-references. Do not skip
this phase — it converts subjective "looks right?" into systematic "for each X, check Y."

Produce the following four tables as internal review artifacts (write them to a scratch
section at the top of the report draft, or keep them in working memory — they are NOT
part of the final review report):

**Table A: Systems**

| # | System ID | Type (new/existing/external) | CMDB Link (filled or blank) | Technology |
|---|---|---|---|---|
| S1 | propertyIntelligencePlatform | new | (blank) | To be decided |
| ... | ... | ... | ... | ... |

Build this from: SAD §3.1 "List of systems and IT services" + SAD §4.2 "System and IT Service Modifications" + the `.c4` model.

**Table B: Containers**

| # | Container ID | Parent System | Technology | Stores Data? | Publishes Events? | Calls External? | Exposes API? | Has UI? |
|---|---|---|---|---|---|---|---|---|
| C1 | propertyIngestionService | propertyIntelligencePlatform | To be decided | No | No | No | No | No |
| ... | ... | ... | ... | ... | ... | ... | ... | ... |

Build this from: the `.c4` model (every `container` definition) + SAD §3.1.

Column meanings:
- `Stores Data?` — YES if the container writes to a database, store, or persistent state
- `Publishes Events?` — YES if the container has an outgoing relationship with protocol `Kafka`, `AMQP`, or a queue-like protocol
- `Calls External?` — YES if the container has an outgoing relationship to a system that is not part of this solution (external system, external actor, or external consumer)
- `Exposes API?` — YES if the container receives incoming `REST/HTTPS` or `gRPC` calls from external systems or consumers
- `Has UI?` — YES if the container is a browser, mobile, or UI component

**Table C: Relationships**

| # | Flow ID | From | To | Protocol | Cross-Boundary? | Carries PII? | Has Contract? | Has Auth? |
|---|---|---|---|---|---|---|---|---|
| R1 | INF01 | propertyIngestionService | propertyMasterService | REST/HTTPS | No | ? | No | ? |
| ... | ... | ... | ... | ... | ... | ... | ... | ... |

Build this from: the `.c4` model (every `->` relationship) + SAD §3.2 data flow table.

Column meanings:
- `Cross-Boundary?` — YES if From and To are in different systems (cross-system relationship)
- `Carries PII?` — YES if the SAD §5.5 lists this flow as carrying protected information; mark `?` if unclear
- `Has Contract?` — YES if the SAD defines an API spec, event schema, or dataset schema for this flow
- `Has Auth?` — YES if the SAD §5.1 lists an account type, role, or auth mechanism for this flow; mark `?` if unclear

**Table D: BR Requirements**

| # | Req ID | Description | Mapped To (section/flow/container) | Coverage (✅/⚠️/❌) |
|---|---|---|---|---|
| 1 | FR-01 | Create and maintain canonical Property Master | SAD §3.1 Property Master Service | ✅ |
| ... | ... | ... | ... | ... |

Build this from: BR functional requirements (§5) + SAD §9 traceability matrix (if present) or manual mapping.

Coverage codes:
- `✅` — explicitly implemented by a named container, data flow, or SAD section
- `⚠️` — partially covered (direction exists but details are open/TBD)
- `❌` — not covered by any model element, data flow, or SAD section

---

### Phase 2. CROSS-CUTTING PATTERN CHECKS

Before role-specific reviews, run systematic pattern checks against Tables B and C.
These catch structural gaps that individual roles might miss through gestalt judgment.

**For each check, produce EITHER a finding (with severity + affected element + SAD section + recommendation) OR `✓ OK — <brief reason>`. Do not skip checks silently.**

#### CC-1. Store + Event Consistency

For every Container in Table B where `Stores Data? = YES` AND `Publishes Events? = YES`:
- Is a consistency boundary documented? (transactional outbox, change-data-capture, 2PC, saga orchestration, or an explicit acceptance of at-most-once / eventual)
- If not documented → flag as **SA finding (High)** — dual-write without a pattern risks lost events or phantom events.

#### CC-2. External Call Resilience

For every Relationship in Table C where `Cross-Boundary? = YES` AND the target is an external system (not an internal consumer):
- Is there a documented retry policy, timeout, circuit breaker, or dead-letter queue?
- If not documented → flag as **SA finding (Medium)** — unguarded external calls risk cascading failures.

#### CC-3. API Contract

For every Container in Table B where `Exposes API? = YES`:
- Is there an API contract? (OpenAPI spec reference, resource model, endpoint list, request/response shape)
- If not documented → flag as **SA finding (Medium)** — consumers cannot integrate without a contract.

#### CC-4. Event Schema

For every Relationship in Table C where Protocol is `Kafka`, `AMQP`, or queue-like:
- Is there an event schema or schema registry reference? (event envelope structure, payload definition, versioning strategy)
- If not documented → flag as **SA finding (Medium)** — consumers cannot deserialize or evolve without a schema.

#### CC-5. Data Store Schema

For every Container in Table B where `Stores Data? = YES`:
- Is there a data model? (entity model, table design, dataset definition, or mandatory attribute list)
- If not documented → flag as **SA finding (Medium)** — implementers cannot create the store without a schema.

#### CC-6. Technology Deferral

For every Container in Table B where `Technology = "To be decided"`:
- Is there an explicit reason for deferral? (MVP scope, vendor evaluation in progress, implementation-detail by design)
- If 50%+ of containers are TBD with no acceptance note → flag as **SA finding (Significant)**.
- If individual containers are TBD but the SAD or ADR explicitly defers technology choice → `✓ OK`.

#### CC-7. Stewardship/Workflow Completeness

For every Container in Table B where `Has UI? = YES`:
- Is there a user workflow description? (states, actions, roles, queue management, SLAs)
- If not documented → flag as **BIZ finding (Significant)**.

#### CC-8. Enterprise Integration Touchpoints

Check for missing enterprise shared-service integrations:
- **API Gateway:** If any container `Exposes API? = YES` to external consumers AND there is no API Gateway modeled or referenced → flag as **EA finding (Medium)**.
- **Identity Provider:** If any container `Has UI? = YES` AND there is no IdP/SSO modeled or referenced → flag as **EA finding (Medium)**.
- **SIEM / Security Monitoring:** If audit events are collected (Audit Log Store or equivalent) AND there is no SIEM integration modeled or referenced → flag as **EA finding (Low)**.
- **Data Catalog:** If the solution produces governed datasets (Country Dataset Publisher or equivalent) AND there is no data catalog integration → flag as **EA finding (Low)**.

#### CC-9. DR/BCP Posture

If the solution stores canonical data (any Container with `Stores Data? = YES` for master/transactional data):
- Is there a documented RPO/RTO, backup strategy, or cross-region replication?
- If not documented → flag as **EA finding (Medium)**.

#### CC-10. RACI / Operating Model

If the solution spans multiple support teams (SAD §6 lists >1 team):
- Is there a RACI matrix or responsibility assignment covering build, deploy, operate, incident, and exception processes?
- If not documented → flag as **EA finding (Significant)**.

---

### Phase 3. REVIEW BY ROLES

Conduct a sequential review from the perspective of each of the 5 roles. Use the
enumerated tables (A–D) as the ground truth. Each checklist item is a concrete
instruction — execute it against the tables + SAD + model.

**For each checklist item, write EITHER a finding (with severity + SAD section +
recommendation + cross-reference to Table row or BR req) OR `✓ OK — <brief reason>`.
Do not skip items silently. A role with <3 findings after completing its checklist
must re-examine the checklist more carefully.**

---

#### Role 1: Solution Architect

**Focus:** Technical quality, architecture correctness, decomposition, integration patterns, NFRs, completeness.

**Checklist — execute each item against Tables B, C, D and the SAD:**

- **SA-COMPONENT.** For each Container in Table B: is its responsibility distinct from every other container? Any two containers with overlapping descriptions? Any missing container for a BR-listed capability? Flag overlaps or gaps.

- **SA-PROTOCOL.** For each Relationship in Table C: does the protocol match the flow semantics? (TCP for databases, Kafka/AMQP for async events, REST/HTTPS or gRPC for sync APIs, HTTPS for user/browser access). Flag mismatches (e.g., "TCP" on a browser→UI flow, "REST/HTTPS" where async is needed).

- **SA-NFR.** Are non-functional requirements quantified? Check SAD §7: are there concrete targets for latency (p95), availability (%), throughput, freshness? If most NFRs say "to be confirmed" or "to be decided" → flag as **SA finding (Significant)**.

- **SA-DIAGRAM-TEXT.** Cross-reference the SAD data flow table (SAD §3.2) against the `.c4` model: does every INF code in the table have a corresponding relationship in the model, and vice versa? Flag discrepancies.

- **SA-VISUAL.** Check diagram semantics against `docs/reference/visual-notation.md`:
  - People rendered as `person` shape, not default rectangles?
  - UIs rendered as `browser` shape?
  - Databases/stores rendered as `cylinder` or `storage`?
  - Event publishers/queues rendered as `queue`?
  - Vendor icons used only where technology is decided by BR/ADR/SAD?
  - Flag deviations.

- **SA-MODIFICATIONS.** Check SAD §4.2 "System and IT Service Modifications": does every system listed have a concrete work description (not just "New system")? Can an implementer estimate effort from it? Flag vague entries.

- **SA-ADR-ALIGNMENT.** For each Accepted ADR: is its decision reflected in the SAD and model? If ADR-001-0004 chooses async events but the model shows synchronous flows, flag as **SA finding (Critical)** with ADR cross-reference.

- **SA-BR-GAPS.** Cross-reference Table D against the SAD: any BR requirement with `⚠️` or `❌` coverage that has no corresponding open question or explicit deferral note? Flag as **SA finding (Significant)**.

---

#### Role 2: Enterprise Architect

**Focus:** IT landscape alignment, reuse, naming, CMDB, architectural principles, enterprise integration.

**Checklist — execute each item against Tables A, B, C and the SAD:**

- **EA-CMDB.** For each System in Table A where `CMDB Link = (blank)`: flag as **EA finding (Significant)**. Every new or modified system needs a CMDB placeholder or registration task.

- **EA-NAMING.** Check system and container names in Tables A/B against `docs/reference/dsl-conventions.md` naming rules (PascalCase IDs, descriptive titles). Flag deviations.

- **EA-NOTATION.** Check the `.c4` model against `docs/reference/visual-notation.md`:
  - Are colors used only where they carry architectural meaning (ownership zone, sensitivity, lifecycle, publication path)?
  - Are borders used consistently (solid=current, dashed=boundary/planned, dotted=future, none=abstract)?
  - Are relationship colors used sparingly and meaningfully?
  - Flag decorative styling or inconsistent usage.

- **EA-REUSE.** For each System in Table A marked `new`: is the build-vs-buy/reuse decision justified in an ADR or the SAD? Would extending an existing system be simpler? Flag unjustified new systems.

- **EA-FOUNDATION.** If the solution introduces a shared foundation or platform capability (e.g., "GCP Data and AI Foundation"): is it clear whether this is a solution-local abstraction or a reusable enterprise product? If ambiguous → flag as **EA finding (Significant)**.

- **EA-CAPABILITY.** Is there a mapping from enterprise business capabilities to solution components? (e.g., "Property Master Management" → Property Master Service). If absent → flag as **EA finding (Low)**.

- **EA-INFORMATION.** Is there an enterprise information model alignment note? (e.g., "Property Master belongs to Location domain, relates to Party domain"). If absent for a data-product solution → flag as **EA finding (Low)**.

- **EA-DR-BCP.** Check the CC-9 result. If no DR/BCP posture is defined for canonical data stores → flag as **EA finding (Medium)**.

- **EA-RACI.** Check the CC-10 result. If multiple support teams are listed without a RACI matrix → flag as **EA finding (Significant)**.

- **EA-ADR-HYGIENE.** Check ADR consistency:
  - Every Accepted ADR listed in SAD §8?
  - No two ADRs contradict each other (e.g., one chooses sync, another chooses async for the same flow)?
  - All ADRs that introduce a new system, sync/async choice, or security model change are present?
  - Flag gaps or contradictions as **EA finding (Significant)**.

- **EA-COST.** Is there a cost model, resource sizing, or order-of-magnitude estimate? If the solution provisions cloud resources and no cost discussion exists → flag as **EA finding (Low)**.

---

#### Role 3: Information Security Specialist

**Focus:** Authentication, authorization, secret management, data protection, logging, audit.

**Checklist — execute each item against Tables B, C and the SAD:**

- **SEC-AUTHZ.** For every Relationship in Table C where `Has Auth? = ?` or `No`: is there a documented auth mechanism? Check SAD §5.1 — does every flow that crosses a trust boundary have an account type, role, or auth model? Flag missing auth.

- **SEC-PII.** For every Relationship in Table C where `Carries PII? = YES` or `?`: is there a documented protection measure? Check SAD §5.5 — are protected flows listed with controls? Flag unprotected PII flows.

- **SEC-SECRETS.** Are secrets, tokens, and keys stored in a secret manager? Check SAD §5.1 — are "Vault or platform secret manager" references present for all service accounts? Flag hardcoded or unspecified secret storage.

- **SEC-AUDIT.** Are all critical operations logged? Check the model for audit relationships — do stewardship actions, API access, administrative actions, publication actions, and break-glass events all have audit flows? Flag missing audit trails.

- **SEC-LEAST-PRIVILEGE.** Are access rights scoped to the minimum needed? Check SAD §5.1 — do account types/roles follow least-privilege (e.g., country-scoped reader vs global admin)? Flag overly broad roles.

- **SEC-ENCRYPTION.** Is encryption in transit and at rest required? Check SAD §5 and §7 — is encryption mentioned? Flag if absent.

- **SEC-BREAK-GLASS.** If the solution requires emergency access (break-glass): is the workflow documented? Approval, time limit, logging, post-access review? Flag if break-glass is required by BR but not modeled.

- **SEC-EXTERNAL.** If the solution exchanges data with external systems: is it approved? Check SAD §5.3 and §5.6 — are external data flows approved and classified? Flag unapproved external exchange.

- **SEC-ADR.** For each security-sensitive ADR (introducing a new integration, communication protocol, or data boundary): does the ADR's Consequences section address security implications (PII handling, encryption, ACLs, audit)? Flag ADRs that omit security consequences.

- **SEC-AUDIT-BOUNDARY.** If the solution has an Audit Log Store: is the deployment boundary clear? (country-local, central security boundary, dual-written?) Flag ambiguity — audit data may contain protected metadata.

---

#### Role 4: Adjacent System Owner

**Focus:** Impact on adjacent systems, new dependencies, SLA, operational support.

**Checklist — execute for each System in Table A marked `external` or `existing`:**

First, identify all adjacent systems from Table A (systems NOT owned by this solution).

For **each** adjacent system, create a subsection (e.g., "4.1 External/Public Enrichment Sources") and check:

- **SYS-DEPS.** What new dependencies does this solution create for the adjacent system? Are they agreed upon? Flag unapproved dependencies.

- **SYS-LOAD.** How will the solution impact the adjacent system's load? Are load expectations (call volume, data volume) documented? Flag unquantified load.

- **SYS-SLA.** Does the integration impose new SLA requirements on the adjacent system? (latency, availability, throughput). Are they within current limits? Flag unrealistic SLA expectations.

- **SYS-SUPPORT.** Who will support the integration? Is the support team listed in SAD §6? Flag missing support contacts.

- **SYS-MONITOR.** Is monitoring of the integration described? Failure detection, alerting? Flag missing integration monitoring.

- **SYS-DEGRADE.** What happens if the adjacent system is unavailable? Graceful degradation, circuit breaker, fallback? Flag missing resilience.

- **SYS-CONTRACT.** Is there a contract for the integration? (API spec, event schema, dataset schema, SLA). Check Table C `Has Contract?` for flows to/from this system. Flag missing contracts.

- **SYS-ADR.** For ADRs that affect this system: does the ADR's Consequences section accurately assess impact on this system? Flag if impact is underestimated.

If there are no adjacent systems (greenfield solution), note this and skip the per-system checklists. Still verify that future consumers are modeled with adequate contracts.

---

#### Role 5: Business Process Owner

**Focus:** BR coverage, user journey, business value, usability.

**Checklist — execute each item against Table D and the SAD:**

- **BIZ-COVERAGE.** For each BR requirement in Table D with `⚠️ Partial` or `❌ Not covered`: is there a corresponding open question, explicit deferral, or acceptance note in the SAD? Flag any uncovered requirement that has no documented disposition.

- **BIZ-JOURNEY.** For each user-facing Container in Table B where `Has UI? = YES`: is there an end-to-end user journey described? (entry point → states/actions → outcomes, roles, queue management). Flag missing or implicit journeys.

- **BIZ-SCOPE.** Check SAD scope against BR scope: are any BR "In Scope" items missing from the solution? Are any BR "Out of Scope" items accidentally included? Flag scope mismatches.

- **BIZ-VALUE.** Does the SAD's solution description (SAD §3.1) explain how the architecture achieves the BR's business goals (§2)? If the connection is implicit → flag as **BIZ finding (Low)**.

- **BIZ-CONSTRAINTS.** Are any business constraints imposed by the technical solution documented? (e.g., eventual consistency for event consumers, steward review latency, business-hours-only UI). Flag uncommunicated constraints.

- **BIZ-USABILITY.** For stewardship/UI components: are usability considerations addressed? (queue visibility, turnaround expectations, exception handling). Flag missing usability details.

- **BIZ-OPEN.** Check SAD §11 "Open Questions and Pilot Gates": are there unresolved questions that block launch? Do any open questions have no owner or resolution timeline? Flag as **BIZ finding (Significant)**.

- **BIZ-ADR.** For each ADR with business impact (deferred features, async processing, approval gates): does the ADR's Consequences section address business tradeoffs? Flag ADRs that make business-affecting choices without acknowledging user impact.

- **BIZ-ARTIFACT.** Are generated artifacts (diagrams, SAD sections) at a quality level suitable for business stakeholder review? Flag unclear, overly technical, or incomplete sections.

---

### Phase 4. REPORT GENERATION

Use `readFile` to read `templates/REVIEW-template.md`.

Use `writeFile` to create `<solution>/output/SAD Review <Name>.md` using the template, filled with findings from all preceding phases.

**Report assembly rules:**

1. **Summary table** at the top: aggregate finding counts per role (Critical, Significant, Minor, Recommendations). Include Phase 2 cross-cutting findings under the most relevant role (CC-1 through CC-7 → Solution Architect; CC-8 → Enterprise Architect; CC-9 → Enterprise Architect; CC-10 → Enterprise Architect).

2. **Per-role sections** (1–5): each includes a findings table + overall assessment. Findings from the role's checklist AND relevant cross-cutting checks go here.

3. **Finding format — every finding must include:**
   - Unique ID (SA-1, EA-2, SEC-3, SYS-4, BIZ-5)
   - Severity: Critical / Significant / Minor / Recommendation
   - SAD Section: the specific section, table, paragraph, or model element
   - Description: what is missing/wrong, with evidence
   - Recommendation: concrete fix
   - (Optional) Cross-Ref: Table row ID (C1, R5), BR req ID (FR-03), or ADR ID

4. **Business Requirements Coverage table** (Role 5): use Table D as the source. Every BR requirement must be listed with its coverage status.

5. **Overall Assessment per role**: strengths + main improvement areas. Be fair — if a section is well-designed, say so.

6. **Final Conclusion**: key risks, mandatory improvements, recommended order for addressing findings.

**Report quality rules:**
- Don't invent problems. If a checklist item passes, write `✓ OK` in your working notes — don't fabricate a finding.
- Separate roles cleanly: SA findings are about technical design, EA findings about landscape/governance, SEC findings about security, SYS findings about adjacent system impact, BIZ findings about business requirements.
- If a finding spans roles, place it in the most relevant role and add a cross-reference note.
- Reference standards from `docs/` and BR requirements by ID.

---

### Phase 5. VERIFICATION

**5.1 Re-read the generated report** using `readFile` and verify:

- [ ] All 5 roles are represented with findings or explicit "no findings" notes
- [ ] Summary table correctly reflects finding counts
- [ ] Finding numbering is sequential within each role (SA-1, SA-2, ...)
- [ ] Every finding has: Severity, SAD Section, Description, Recommendation
- [ ] No duplicate findings between roles
- [ ] BR coverage table (Role 5) is complete

**5.2 Coverage guard — check the following invariants:**

- [ ] For every Container in Table B with `Technology = "To be decided"`: there must be a corresponding finding (from CC-6 or SA checklist) OR an explicit acceptance note in the report.
- [ ] For every Relationship in Table C with `Has Contract? = No` AND `Protocol ≠ "TCP"`: there must be a finding (from CC-3/CC-4) OR an explicit acceptance note.
- [ ] For every BR requirement in Table D with `⚠️ Partial` or `❌ Not covered`: there must be a finding (from BIZ-COVERAGE) OR an explicit acceptance/deferral note in the SAD §11.
- [ ] Each role has ≥3 findings (critical + significant + minor + recommendations combined) OR an explicit explanation in the Overall Assessment for why fewer. Roles with 0–1 findings are almost always under-reviewing.

**5.3 Present a summary to the user:**
- Finding count per role (Critical / Significant / Minor / Recommendations)
- Overall verdict (e.g., "Ready for implementation planning with N significant items to address")
- Top 3 highest-priority findings
