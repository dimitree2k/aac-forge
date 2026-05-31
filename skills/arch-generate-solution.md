# arch-generate-solution

**What it does:** Reads BR documents → frames the architecture decision package (SAD
skeleton + Proposed ADRs + change plan) → stops for human approval → on resume, stamps
ADRs Accepted → edits the LikeC4 model → validates → exports diagrams → generates full
SAD (rev 2) → verifies.

**Argument:** Path to the solution folder, e.g.
`solutions/001_Forging Runic Diagrams and Covenant Scrolls` or
`examples/order-management/solutions/002_Automated Order Fulfillment`.

If no argument is provided, iterate through `solutions/NNN_Name/` folders (and
`examples/*/solutions/NNN_Name/`) from highest number to lowest. Target the first folder
that has files in `input/` but whose `output/` folder is empty or has only a SAD
skeleton (rev 1, status: Draft). If none found, ask the user.

---

## Resumption

On invocation, detect the current phase from **durable artifacts** on the proposal
branch (not from a cache file):

1. **`input/` exists but `decisions/` doesn't** → first invocation. Start from Phase 1.
2. **`decisions/` exists with Proposed ADRs, no Accepted ADRs** → gate in progress.
   Check the approval backend configured in `aac-forge.config.json`. If approved,
   proceed to Phase 3. If still pending, stop and tell the user.
3. **`decisions/` exists with Accepted ADRs, `.c4` files not yet edited** → gate
   approved. Resume at Phase 3 (skip Phase 1-2).
4. **`.c4` files edited, SAD is still rev 1 (status: Draft)** → model built. Resume
   at Phase 5 (export) or Phase 6 (SAD rev 2).
5. **SAD is rev 2, review report doesn't exist** → resume at Phase 7 (verify) or
   invoke `arch-review-solution`.
6. **SAD is rev 2, review report exists** → done. Print summary.

---

## Algorithm

### Phase 1. PREPARE

**1.1 Read input documents**
Use `readFile` to read all files from `<solution>/input/`.

> **BPMN files (.bpmn):** Use the parsing script:
> ```
> runCommand: python3 scripts/parse-bpmn.py <path to .bpmn file>
> ```
> The script outputs participants, message flows, lanes, and tasks. No need to read
> BPMN XML manually.

> **Large files:** If a BR document exceeds read limits, use `readFile` with `head`,
> `tail`, or `range` options.

**1.2 Read the current architecture model**
Use `searchFiles` with pattern `*.c4` under `model/` (or the relevant `examples/*/model/`)
to discover all model files. Use `readFile` to read every discovered `.c4` file.

**1.3 Read workspace configuration**
Use `readFile` to read `aac-forge.config.json` (repo root) for `approvalBackend` and
`archiveRejectedProposals` settings.

**1.4 Determine scope**
Identify which systems, containers, and relationships from the BR already exist in the
model and which need to be added. Identify **consequential decisions** that warrant ADRs
(see threshold below).

---

### Phase 2. FRAME & PLAN (Approval Gate)

**MANDATORY — do NOT proceed to Phase 3 without explicit approval.**

Produce the **decision package** — three artifacts on a proposal branch:

#### 2.1 SAD Skeleton (rev 1)

Use `writeFile` to create `<solution>/output/SAD <Name>.md`. Fill the front matter
(`status: Draft`, `revision: 1`, `adrs: [...]`), glossary, project description, and
**Open Decisions** section. Each open decision links to a Proposed ADR:

```markdown
## Open Decisions

1. How should fulfillment events propagate? Kafka vs direct REST?
   → ADR-002-0001 (Proposed)
2. Where should the Fulfillment Engine live? New system vs extend Order Management?
   → ADR-002-0002 (Proposed)
```

Do NOT fill the full architecture description, data flow table, security section, or
traceability matrix — those come in Phase 6 after the model is built.

#### 2.2 Proposed ADRs

Use `writeFile` to create one ADR per consequential decision in
`<solution>/decisions/ADR-<solution>-<sequence>-<slug>.md`. Use the ADR template
(`templates/ADR-template.md`). Each ADR has:

- `status: Proposed`
- Full context, options, recommendation, and consequences
- `supersedes: []` and `superseded-by: []`

**ADR Volume Threshold:** Create ADRs only for consequential decisions. A decision is
consequential if it meets at least one of:

- Introduces a **new system** (build vs reuse)
- Chooses between **sync/async** for a cross-system interaction
- Changes the **security model** (auth, encryption, data protection)
- Departs from an **existing pattern or standard**
- Involves a **standards exception**
- Has a **significant NFR tradeoff** (consistency vs availability, cost vs latency)

If no decisions meet this threshold, skip ADRs — the change plan alone is sufficient.

#### 2.3 Change Plan

Use `writeFile` to create `<solution>/decisions/change-plan.md`:

```markdown
## Proposed Changes

### New Systems
| System ID | Title | Domain | Description |

### New Containers
| Container ID | Parent System | Title | Technology |

### Modified Elements
| Element ID | Change Description |

### New Relationships
| From | To | Protocol | Description | ADR |

### Files to Change
- `model/domains/...` — what changes
```

Every ADR should have at least one corresponding row in the change plan. Relationships
without an ADR are marked `—` in the ADR column.

#### 2.4 Present for Approval

Output the decision package summary:

```
Decision package ready:
  SAD skeleton: <solution>/output/SAD <Name>.md (rev 1, Draft)
  Proposed ADRs: <solution>/decisions/ADR-NNN-NNNN-*.md (N ADRs)
  Change plan: <solution>/decisions/change-plan.md

Push the proposal branch and create a PR. Required reviewers:
  - Enterprise Architect
  - Solution Architect
  - [system owners for affected systems]

Once approved, re-invoke this skill to continue.
```

If `approvalBackend` in `aac-forge.config.json` supports automatic PR creation
(`azure-devops`), create the PR. Otherwise, print manual PR instructions.

**DO NOT proceed to Phase 3. Stop here.**

---

### Phase 3. RESUME & STAMP

**This phase runs when the skill is re-invoked after gate approval.**

**3.1 Detect phase**
Determine the current phase from durable artifacts (see Resumption section above).

**3.2 Verify approval**

| Backend | Action |
| --- | --- |
| `manual` | Read each Proposed ADR's front matter. If `approval.reference` is filled and `approvers` list is populated, treat as approved. |
| `azure-devops` | Query the Azure DevOps REST API for the PR or work item referenced in the ADR front matter. If status is Approved, proceed. |

If approval is not confirmed, stop and tell the user.

**3.3 Stamp ADRs as Accepted**
For each ADR in `<solution>/decisions/` with `status: Proposed`, use `editFile` to
change `status: Accepted` and fill the `approval` block with the approval reference and
approver details. The skill is the **sole writer** of this transition.

```yaml
status: Accepted
approval:
  system: manual
  reference: "PR #1234"
approvers:
  - role: "Enterprise Architect"
    name: "G. White"
    date: "2026-06-01"
```

#### 3.4 Apply Model Changes

Apply the changes from `decisions/change-plan.md` to LikeC4 model files using `editFile`.

Follow all conventions from the DSL reference:
- Element kinds from `specification { }` in `workspace.c4`
- Containers nested inside their parent system
- Relationships with protocol
- Globally unique container IDs (no dot-notation needed)
- Cross-system references use bare container IDs

---

### Phase 4. VALIDATE

Run validation:
```
runCommand: npx likec4 validate model/
```

If errors — fix using `editFile` and re-validate. Do not proceed until valid.

**Failure path — model contradicts accepted ADR:** If validation reveals that an accepted
ADR cannot be implemented cleanly in the model (e.g., the chosen protocol can't be
expressed, the system placement creates an invalid structure), stop. Do not silently
drift from the accepted ADR. Report the contradiction and tell the user to revise the
ADR or change plan, then re-request gate approval.

---

### Phase 5. EXPORT

Export diagrams to PNG:
```
runCommand: npx likec4 export png model/ -o <solution>/output/ --flat
```

For Mermaid sources (optional, for embedding in SAD):
```
runCommand: npx likec4 gen mermaid model/ --outdir <solution>/output/
```

---

### Phase 6. GENERATE SAD (rev 2)

**6.1 Read the SAD skeleton**
Use `readFile` to read the existing SAD skeleton (`<solution>/output/SAD <Name>.md`,
rev 1, status: Draft).

**6.2 Find relevant existing SADs**
Use `readFile` to read `solutions/index.md` (if it exists). Select one most relevant
existing solution. Use `readFile` to read that solution's SAD for field value examples
(CMDB links, account types, location, criticality, technology stack).

**6.3 Fill the SAD**
Use `editFile` to update the SAD skeleton to rev 2:

- Update front matter: `status: Approved`, `revision: 2`, add changelog entry
- Fill **Architecture Decisions** (section 8): reference each Accepted ADR by ID with a
  one-line summary
- Remove or mark **Open Decisions** (section 10) as resolved
- Fill all remaining sections: data flow table (3.2), container diagram references (3.3),
  implementation (4), security (5), support (6), NFRs (7), traceability matrix (9)

**SAD filling rules:**
- Data flows must correspond to INFxx relationships in the model
- Systems table includes all systems and containers involved
- NFRs transferred from BR
- Security section: secrets in Vault, all flows with authorization
- Traceability matrix maps each BR requirement to SAD sections
- Open questions documented (section 11)

---

### Phase 7. VERIFY

1. Cross-reference INF codes between the SAD data flow table and the model:
   ```
   searchContent: pattern "INF\d+" under model/
   ```
2. Verify every Accepted ADR is referenced in the SAD's Architecture Decisions section
3. Verify the change plan rows are reflected in the model
4. Update the SAD if needed using `editFile`
5. Present a summary:
   - New/modified systems and containers
   - New relationships and data flows
   - Accepted ADRs with IDs
   - Files changed
   - Validation result
   - Exported diagrams
   - Next step: run `arch-review-solution`
