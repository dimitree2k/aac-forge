# BR → ADRs → SAD Process

**Status:** Proposed  
**Date:** 2026-05-31  
**Scope:** v0.2.0 implementation target

## Governing Principle

One architecture decision gate. No `.c4` model edit reaches the protected branch until the
decision package is approved. Everything upstream of the gate is *framing* (cheap to
discard); everything downstream is *building* (the LLM executing an approved decision).

The unit of work for a solution is a `proposal/<solution>` branch. Stage A publishes a
decision package to that branch but does **not** edit `.c4` model files. The human review
gate approves the package. The skill resumes after approval, stamps ADRs, and only then
touches the model.

## Approval Backend

The process is host-agnostic. The `approvalBackend` field in `aac-forge.config.json`
(repo root, committed) determines which adapter the skill uses. v0.2 supports two
backends; others are deferred.

| Backend | Approval record | Verification | v0.2 |
| --- | --- | --- | --- |
| `manual` | Signed approval recorded in ADR front matter | Human attestation | ✅ |
| `azure-devops` | PR + linked Architecture Review work item | Azure DevOps REST API | ✅ |
| `github` | PR review approval | GitHub Checks / API | Future |
| `gitlab` | Merge Request approval | GitLab API | Future |

CI pipelines (model validation, ADR linting) run on the PR regardless of which platform
hosts the review — they are triggered by branch pushes, not by a specific PR platform.

## End-to-End Flow

```
BR Document
  │
  ▼
┌─────────────────────────────────────────────────────┐
│ Stage A — Frame (proposal branch, no .c4 touched)   │
│                                                     │
│  1. Read BR + current model from main               │
│  2. Produce decision package:                       │
│     a. SAD skeleton (rev 1, status: Draft)          │
│     b. Proposed ADRs in decisions/                  │
│     c. Change plan in decisions/                    │
│  3. Push proposal branch, create PR (if backend     │
│     supports it) or print manual PR instructions    │
│  4. Skill stops                                     │
└────────────────────┬────────────────────────────────┘
                     │
                     ▼
          ┌──────────────────┐
          │  DECISION GATE   │
          │  (PR review)     │
          │                  │
          │  Approve /       │
          │  Request changes │
          │  / Reject        │
          └──────┬───────────┘
                 │
      ┌──────────┼──────────┐
      ▼          ▼          ▼
   Approve    Changes    Reject
      │          │          │
      │     Loop back to     │
      │     Stage A on       │
      │     same branch      │
      │          │           │
      ▼          │           ▼
      │          │    ┌──────────────┐
      │          │    │ Close/delete  │
      │          │    │ proposal      │
      │          │    │ branch         │
      │          │    │ (no archival   │
      │          │    │ by default)    │
      │          │    └──────────────┘
      ▼          │
┌─────────────────────────────────────────────────────┐
│ Stage B — Build (same branch, after approval)        │
│                                                     │
│  1. Skill detects approval:                         │
│     - manual: reads ADR front matter                │
│     - azure-devops: queries REST API                │
│  2. Skill stamps ADRs: status → Accepted            │
│     with approver names, date, approval reference   │
│  3. Edit .c4 model files per accepted ADRs           │
│  4. npx likec4 validate                             │
│     ─ on failure: fix and retry                      │
│     ─ if failure contradicts accepted ADR:           │
│       stop, return to gate with revised ADR          │
│  5. Export diagrams (PNG, Mermaid)                   │
└────────────────────┬────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────┐
│ Stage C — Document & Review                          │
│                                                     │
│  1. Update SAD to rev 2 (full)                       │
│     - reference Accepted ADRs by ID                  │
│     - embed exported diagrams                        │
│     - fill data flow table, security, NFRs           │
│  2. 5-role review (checks SAD + model + ADR alignment) │
│  3. Push all commits to proposal branch              │
└────────────────────┬────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────┐
│ Merge Gate (same PR, re-approval)                    │
│                                                     │
│  Steps 4 and 8 use the SAME PR. Stage B/C commits   │
│  dismiss the initial approval, so this is a          │
│  re-approval of the now-complete PR.                 │
│                                                     │
│  The durable record of the architecture decision is  │
│  the ADR front matter (approvers + date + approval   │
│  reference) — not the transient PR approval state.   │
│                                                     │
│  Verifies conformance, not architecture:             │
│  - .c4 model matches approved change plan            │
│  - SAD rev 2 references all Accepted ADRs            │
│  - Diagrams match model                              │
│  - Review findings resolved or acknowledged          │
│                                                     │
│  Does NOT reopen architecture decisions.             │
└────────────────────┬────────────────────────────────┘
                     │
                     ▼
              Merge to main
           Delete proposal branch
```

## Artifact Locations

| Artifact | Path | Writer | Lifecycle |
| --- | --- | --- | --- |
| BR | `<solution>/input/` | Human | Authored once, stable |
| **SAD skeleton** | `<solution>/output/SAD <Name>.md` | Skill (Stage A) | rev 1 (Draft) → rev 2 (Approved) |
| **Proposed ADRs** | `<solution>/decisions/ADR-NNN-NNNN-*.md` | Skill (Stage A) | Proposed → Accepted or Rejected |
| **Change plan** | `<solution>/decisions/change-plan.md` | Skill (Stage A) | Transient — superseded by actual .c4 edits in Stage B |
| **Diagrams** | `<solution>/output/*.png` | Skill (Stage B) | Regenerated on model change |
| **SAD (full)** | `<solution>/output/SAD <Name>.md` | Skill (Stage C) | rev 2, references Accepted ADRs |
| **Review report** | `<solution>/output/SAD Review <Name>.md` | Skill (Stage C) | Generated after rev 2 |

### Distinction: Solution ADRs vs Repo ADRs

| Scope | Path | Example |
| --- | --- | --- |
| **Solution decisions** | `<solution>/decisions/` | `examples/order-management/solutions/002_.../decisions/ADR-002-0001-kafka-vs-rest.md` |
| **Repo/tooling decisions** | `docs/adr/` | `docs/adr/ADR-0001-use-likec4-over-structurizr.md` |

Solution ADRs are architecture decisions made while designing a solution. They live with
the solution they belong to and are numbered `ADR-<solution>-<sequence>`. Repo ADRs are
decisions about the tooling itself — globally numbered `ADR-NNNN` in `docs/adr/`.

## ADR Lifecycle

```
Proposed ──gate approve──► Accepted ──superseded by new ADR──► Superseded
    │
    └──gate reject──► Rejected (branch closed; no archival by default)
```

### Transitions

| From | To | Trigger | Writer |
| --- | --- | --- | --- |
| — | `Proposed` | Stage A publishes decision package | Skill |
| `Proposed` | `Accepted` | Gate approves; skill resumes and stamps | Skill (sole writer) |
| `Proposed` | `Rejected` | Gate rejects; branch closed or deleted | Skill |
| `Accepted` | `Superseded` | New ADR with `supersedes` field is accepted | Skill |

**Accepted ADRs are immutable.** After an ADR reaches `Accepted`, its body cannot be
silently edited. To change an accepted decision, create a new ADR with `supersedes`
pointing to the old one. The old ADR is stamped `Superseded` with `superseded-by`.

**Proposed ADRs are mutable.** During Stage A and gate review, Proposed ADRs can be
amended freely on the proposal branch in response to reviewer feedback.

## ADR Front Matter

```yaml
---
id: ADR-002-0001
status: Proposed | Accepted | Rejected | Superseded
solution: "002"
date: "2026-05-31"
approval:
  system: manual | azure-devops
  reference: "PR #1234 / AB#56789"
approvers:
  - role: Enterprise Architect
    name: ""
    date: ""
supersedes: []
superseded-by: []
---
```

## ADR Volume Threshold

ADRs are created only for **consequential** architectural decisions. Normal containers,
relationships, and INF flows stay in the change plan and SAD. Create an ADR when the
decision meets at least one of:

- Introduces a **new system** (build vs reuse)
- Chooses between **sync/async** for a cross-system interaction
- Changes the **security model** (auth, encryption, data protection)
- Departs from an **existing pattern or standard**
- Involves a **standards exception**
- Has a **significant NFR tradeoff** (consistency vs availability, cost vs latency)

If none of these apply, the change plan alone is sufficient — no ADR needed.

## Rejected Proposals

When the gate rejects a proposal, the skill:

1. Optionally stamps ADRs in `decisions/` as `status: Rejected` (for branch history)
2. Closes or deletes the proposal branch

By default, rejected proposals are **not** archived to main. If the team wants a
permanent record of rejected decisions, set `archiveRejectedProposals: true` in
`aac-forge.config.json`. When enabled, the skill merges only the `decisions/` directory
(no `.c4` changes) to main before deleting the branch.

## Resumption

The skill detects its phase on re-invocation by inspecting **durable** state — not by
reading a cache file:

1. **Solution directory doesn't exist** → start from Stage A (first invocation)
2. **`decisions/` exists with Proposed ADRs, no Accepted ADRs** → gate in progress; check approval backend
3. **`decisions/` exists with Accepted ADRs, `.c4` files not yet edited** → resume at Stage B
4. **`.c4` files edited, SAD is still rev 1** → resume at Stage C
5. **SAD is rev 2, review report exists** → done; print summary

The skill may write `<solution>/.aac-forge/state.json` as an **optional cache** to avoid
re-deriving phase on resume, but the file is not committed and the skill must not depend
on it. If the cache is absent or stale, the skill re-derives phase from the durable
artifacts above.

The `.gitignore` entry for `.aac-forge/` covers this cache file only — the committed
config lives at repo root as `aac-forge.config.json`.

## v0.2.0 Scope

### Included

- Write SAD skeleton (rev 1) with Open Decisions
- Write Proposed ADRs in `<solution>/decisions/`
- Write change plan in `<solution>/decisions/change-plan.md`
- `manual` approval backend: human records approval in ADR front matter
- `azure-devops` approval backend: skill queries ADO REST API for PR/work-item status
- Skill stamps ADRs Accepted on resume (sole writer)
- Edit `.c4` model, validate, export diagrams
- Write SAD rev 2 referencing Accepted ADRs
- 5-role review with ADR findings distributed by subject
- ADR template with `approval`, `supersedes`, `superseded-by` front matter
- CI: ADR front matter lint (validates status, approval block, cross-references)

### Deferred

- GitHub/GitLab approval adapters
- Automatic PR creation (skill prints instructions; human creates PR)
- Automatic rejected-proposal archival (manual only unless `archiveRejectedProposals` is set)
- API-based approver name/date extraction (human fills approver fields)
- Complex state machine (phase is derived, not stored)

## Skill Changes Required (v0.2.0)

| Target | Change |
| --- | --- |
| `skills/arch-generate-solution.md` | Phase 2 becomes "Frame & Plan": produces SAD skeleton + Proposed ADRs + change plan, then stops. Phase 3 resumes after gate, stamps ADRs Accepted, then edits `.c4`. Phase detection derived from durable artifacts. |
| `skills/arch-review-solution.md` | Context gathering reads `decisions/*.md`. ADR findings distributed by subject: Security owns security-sensitive ADRs, Adjacent System Owner owns integration/SLA ADRs, BPO owns business tradeoff ADRs, EA owns ADR hygiene and reuse/alignment. |
| `templates/ADR-template.md` | **New** — ADR template with status lifecycle, `approval` block, `supersedes`/`superseded-by` fields. |
| `templates/SAD-template.md` | Add `adrs:` field to front matter. Add "Architecture Decisions" section referencing ADRs by ID. Add "Open Decisions" section for rev 1 (skeleton). |
| `aac-forge.config.json` | **New** — committed repo-root config: `approvalBackend`, `archiveRejectedProposals`. |
| `.gitignore` | Add `.aac-forge/` (covers per-solution state cache only). |
| CI (`validate.yml`) | Add ADR lint job: validates front matter, checks that every `Accepted` ADR has `approval` block, checks `supersedes`/`superseded-by` cross-references. |

## Practitioner Example

A walkthrough of the full process with edge cases is in
[docs/tutorials/adr-process-walkthrough.md](../tutorials/adr-process-walkthrough.md).
