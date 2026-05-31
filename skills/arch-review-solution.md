# arch-review-solution

**What it does:** Conducts a comprehensive review of a solution (SAD) from 5 role perspectives and generates a findings report.

**Argument:** Path to the solution folder, e.g. `solutions/001_Forging Runic Diagrams and Covenant Scrolls`.

If no argument is provided, ask the user.

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
Use `searchFiles` with pattern `*.md` under `docs/` to find standards.
Use `readFile` to read any found standards — they contain normative requirements to reference during review.

**1.5 Read existing SADs for consistency**
If `solutions/index.md` exists, read it. Read 2–3 existing SADs from `solutions/NNN_Name/output/` to understand quality baseline and consistency between solutions.

**1.6 Read ADRs (if present)**
Use `searchFiles` with pattern `ADR-*.md` under `<solution>/decisions/` to find ADRs.
Use `readFile` to read every discovered ADR. Cross-reference each Accepted ADR against
the SAD's Architecture Decisions section (section 8) — every Accepted ADR should be
listed there. Also read the change plan (`<solution>/decisions/change-plan.md`) if it
exists — it documents the intended `.c4` impact.

---

### Phase 2. REVIEW BY ROLES

Conduct a sequential review from the perspective of each of the 5 roles. For each role, embody it — use its focus area and competencies to identify findings, risks, and recommendations.

---

#### Role 1: Solution Architect

**Focus:** Technical quality, architecture correctness, completeness of design.

**Checklist:**
- **Component architecture:** Is the solution properly decomposed into systems/containers? Any mixing of responsibilities? Redundant components?
- **Integration patterns:** Are sync/async patterns correct? Single points of failure? Error handling, timeouts, retries?
- **Data flows:** Are all flows described? Do protocols and data formats match standards? Implicit flows not in the table?
- **Technology stack:** Is the technology choice justified? Does it match accepted standards?
- **NFRs:** Are non-functional requirements sufficient? Performance, availability, scalability metrics realistic?
- **Modification descriptions:** Are work descriptions for each system detailed enough for effort estimation?
- **Diagrams vs text:** Do diagrams match the textual description? Any discrepancies in names, components, flows?
- **Diagram visual semantics:** Do LikeC4 shapes/icons communicate element roles? People should not render as generic systems, UIs should be visually distinguishable from services, and stores, datasets, queues/events, buckets, and documents should not all appear as default rectangles.
- **Solution completeness:** Does the SAD cover all requirements from the BR? Missing functional requirements?
- **ADR alignment (secondary):** Does the SAD contradict any Accepted ADR? Are ADR decisions reflected in the architecture? If the SAD describes REST but ADR-002-0001 specifies Kafka, flag as SA finding with ADR cross-reference.

---

#### Role 2: Enterprise Architect

**Focus:** IT landscape alignment, reuse, naming, CMDB, architectural principles.

**Checklist:**
- **Landscape alignment:** Does the solution fit the existing C4 model? Does it duplicate capabilities of existing systems?
- **Reuse:** Are existing systems, services, integrations maximally utilized? New components justified vs enhancing existing ones?
- **Consistency:** Are system and component names aligned with the C4 model? Naming conventions followed?
- **Notation consistency:** Are the `docs/reference/visual-notation.md` shape, color, border, icon, and relationship conventions used consistently without becoming decorative? Are vendor icons used only where the technology choice is already approved or explicitly assumed?
- **Architectural principles:** Are principles followed (check `docs/` standards)?
- **Impact on adjacent systems:** Has impact been assessed? Excessive dependencies?
- **Scalability:** Can the solution scale to other business domains? Built-in limitations?
- **CMDB links:** Are they filled in? Which systems need entries created?
- **ADR hygiene (primary):** Are all consequential decisions covered by ADRs? Any missing ADR for a new system, sync/async choice, or security model change? Are ADRs internally consistent (no two ADRs contradicting each other)? Are Accepted ADRs immutable (no silent edits)?
- **ADR reuse & alignment:** Do ADRs maximize reuse of existing systems? Are build-vs-buy decisions justified? Does any ADR duplicate a decision already made in another solution?

---

#### Role 3: Information Security Specialist

**Focus:** Authentication, authorization, secret management, data protection, logging, audit.

**Checklist:**
- **Authentication & authorization:** Are all inter-service interactions authenticated/authorized? All service accounts described? Account types correct?
- **Secret management:** Are all secrets, tokens, keys stored in Vault? Hardcoded secrets? Rotation?
- **Data protection:** Which flows contain protected information (PII, trade secrets)? Protection measures sufficient?
- **LLM gateway:** Do all LLM calls go through the Eye of Sauron (or equivalent gateway)? Masking/unmasking? DLP?
- **Logging and audit:** Does logging meet Security Service requirements? Critical operations logged? User action audit?
- **Network security:** Network segments and firewall rules described? Correct namespace placement?
- **Least privilege:** Are access rights to external systems appropriate? Excessive rights?
- **External exchange:** Data exchange with external systems? If so, approved by Security Service?
- **Data classification:** Categories of processed data defined? Protection measures match classification?
- **ADR security review (primary):** Review security-sensitive ADRs for gaps — does an ADR selecting a communication protocol (Kafka, REST) address PII handling, encryption, and ACLs? Does an ADR introducing a new integration specify the auth model? Flag if an ADR's Consequences section omits security implications.

---

#### Role 4: Adjacent System Owner

**Focus:** Impact on adjacent systems, new dependencies, SLA, operational aspects.

**Checklist (per adjacent system):**
- **New dependencies:** What new integrations are proposed? Are they agreed upon?
- **Load and SLA:** How will the solution impact system load? Within current limits? SLA degradation?
- **Modifications:** What modifications are proposed? Timelines and effort realistic? Who implements?
- **Backward compatibility:** Do changes break existing integrations?
- **Operational support:** Who will support new integrations? Support information sufficient?
- **Monitoring:** Is monitoring of new integrations provided for?
- **Rollback:** What happens if the new integration fails? Graceful degradation?
- **ADR integration/SLA impact (primary):** Review ADRs that affect this system — does the chosen integration pattern (sync/async, protocol) impose new SLA requirements? Does an ADR decision create a dependency this team hasn't agreed to? Flag if an ADR's Consequences section underestimates impact on this system.

First identify **all adjacent systems** by reading the model and the SAD's system modification table. For each affected system, conduct a review as its owner.

---

#### Role 5: Business Process Owner

**Focus:** BR coverage, user journey, business value, usability.

**Checklist:**
- **Requirements coverage:** Are all BR requirements implemented? Map each requirement → SAD implementation. Mark missing/partial.
- **User journey:** Is the full user journey described? Clear? Unnecessary steps?
- **Business value:** Does the SAD solve stated business problems? Expected outcome achievable?
- **Business constraints:** What constraints does the technical solution impose? Acceptable?
- **Usability:** How convenient is the solution for end users? Their needs considered?
- **Iterability:** Does the solution support iterative refinement?
- **Artifact quality:** How is quality of generated artifacts ensured? Validation sufficient?
- **Open questions:** Unresolved questions blocking launch? Out-of-scope items affecting business value?
- **ADR business tradeoffs (primary):** Review ADRs for business impact — does a technical decision (e.g., async processing) create an acceptable user experience? Does an ADR that defers a feature to v2 align with business priorities? Flag if an ADR makes a technical choice that harms the user journey without mitigation.

---

### Phase 3. REPORT GENERATION

Use `readFile` to read `templates/REVIEW-template.md`.

Use `writeFile` to create `<solution>/output/SAD Review <Name>.md` using the template, filled with findings from each role.

**Report rules:**
- Each finding must reference a specific SAD section, table, or wording. Avoid generic phrases.
- Each finding must include a correction recommendation.
- Reference business requirements from `input/`, standards from `docs/`, and the existing C4 model.
- Don't invent problems — if a section is well designed, note it in the overall assessment.
- Separate roles: a Solution Architect finding shouldn't concern security, a Security finding shouldn't concern business value.
- If a finding spans roles, place it in the most relevant role and add a cross-reference.

---

### Phase 4. VERIFICATION

1. Re-read the generated report using `readFile` and verify:
   - All 5 roles are represented
   - Summary table correctly reflects finding counts
   - Finding numbering is sequential within each role (SA-1, SA-2, ...)
   - Findings are specific with actionable recommendations
   - No duplicate findings between roles
2. Present a summary to the user: finding count per role and overall verdict.
