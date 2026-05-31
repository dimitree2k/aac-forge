# ADR Process — Practitioner Walkthrough

A concrete walkthrough of the BR → ADRs → SAD process, from a working architect's
perspective. The full specification is at [docs/input/specs/ADR-process.md](../input/specs/ADR-process.md).

## 1. New Project — Happy Path

You're an architect. The Operations team drops a BR on your desk: "Automated Order
Fulfillment."

### Step 1: Someone writes the BR

```
examples/order-management/solutions/002_Automated Order Fulfillment/input/BR Automated Order Fulfillment.md
```

This is the only human-authored artifact at this point.

### Step 2: You invoke the skill

```
arch-generate-solution: examples/order-management/solutions/002_Automated Order Fulfillment/
```

### Step 3: Stage A — Frame (no .c4 touched)

The skill creates a `proposal/002-automated-order-fulfillment` branch off main and
produces four artifacts:

**A. SAD skeleton** — `output/SAD Automated Order Fulfillment.md` (rev 1, Draft)

```markdown
---
solution: "002"
title: "Automated Order Fulfillment"
status: "Draft"
revision: 1
---
## Open Decisions

1. How should fulfillment events propagate?
   → ADR-002-0001
2. Where should the Fulfillment Engine live?
   → ADR-002-0002
```

The skeleton has headers, glossary, and open decisions — not the full architecture
description yet.

**B. Proposed ADRs** — `decisions/ADR-002-0001-kafka-vs-rest.md`

```
examples/order-management/solutions/002_.../decisions/
├── ADR-002-0001-kafka-vs-rest.md
└── ADR-002-0002-fulfillment-placement.md
```

```markdown
---
id: ADR-002-0001
status: Proposed
solution: "002"
date: "2026-05-31"
supersedes: []
superseded-by: []
---
# ADR-002-0001: Fulfillment Event Propagation

## Context
Order confirmation triggers fulfillment. Two integration patterns exist.

## Options
### Option A: Direct REST
- orderWorker → fulfillmentApi (POST /fulfillments)
- fulfillmentApi → orderApi (PUT /orders/{id}/fulfillment-status)

### Option B: Kafka events
- orderWorker publishes to `order.confirmed` topic
- fulfillmentApi consumes from `order.confirmed`
- fulfillmentApi publishes to `fulfillment.completed`

## Recommendation
Option B (Kafka). Rationale: decouples Order Management from Fulfillment Engine,
supports replay and multiple consumers, matches existing event-driven patterns in
the architecture.

## Consequences
- New Kafka topics: `order.confirmed`, `fulfillment.completed`
- fulfillmentApi becomes event-driven
- orderWorker extended to consume fulfillment events
```

**C. Change plan** — `decisions/change-plan.md`

```markdown
## New Systems
| System ID | Title | Domain | Description |
| --- | --- | --- | --- |
| fulfillmentEngine | Fulfillment Engine | core-services | Orchestrates order fulfillment |

## New Containers
| Container ID | Parent System | Title | Technology |
| --- | --- | --- | --- |
| fulfillmentApi | fulfillmentEngine | Fulfillment API | Go |
| picklistGenerator | fulfillmentEngine | Picklist Generator | Python |
| fulfillmentDb | fulfillmentEngine | Fulfillment Database | PostgreSQL |

## New Relationships
| From | To | Protocol | Description | ADR |
| --- | --- | --- | --- | --- |
| orderWorker | fulfillmentApi | Kafka | Order confirmed → trigger fulfillment | ADR-002-0001 |
| fulfillmentApi | orderApi | REST/HTTPS | Report fulfillment status | ADR-002-0001 |
| fulfillmentApi | picklistGenerator | gRPC | Request picklist generation | — |
| picklistGenerator | inventoryApi | REST/HTTPS | Read stock locations | — |
| fulfillmentApi | shippingProvider | REST/HTTPS | Request shipping rates and labels | — |
| fulfillmentApi | notificationService | Kafka | Send shipment notification | — |

## Files to Change
- `model/domains/core-services.c4` — add Fulfillment Engine system + containers + relationships
```

Container IDs are globally unique, so relationships use bare IDs (`orderWorker`,
`fulfillmentApi`) — no dot-notation needed.

**D. Resumption state** — derived from durable artifacts, not a state file.

The skill does not depend on a cached state file to resume. On re-invocation, it
detects its phase by inspecting: (1) does `decisions/` exist with Proposed ADRs?
(2) are they Accepted? (3) have `.c4` files been edited? (4) is the SAD still rev 1?

A `.aac-forge/state.json` cache file may be written as an optimization, but it is
not committed and the skill re-derives phase if it's absent.

The skill pushes the branch and stops:

```
Decision package pushed to proposal/002-automated-order-fulfillment.

If your approval backend supports automatic PR creation (azure-devops), a PR
has been created. Otherwise, create a PR manually and add required reviewers:
  - Enterprise Architect
  - Solution Architect
  - Order Management system owner

Once approved, re-invoke this skill to continue.
```

**No `.c4` file has been touched.**

### Step 4: Architecture Decision Gate

Reviewers comment on the PR:

- **EA:** "ADR-002-0002 — reuse Order Management's container space instead of a new
  system. Adjust recommendation."
- **Security:** "ADR-002-0001 — Kafka topics must be ACL'd. Add to Consequences."
- **Order Management owner:** "Change plan row 1: orderWorker change is on our Q3
  roadmap. Timeline OK."

You update the Proposed ADRs on the proposal branch to address feedback. CI re-runs
(model validation and ADR linting). Reviewers approve the PR.

### Step 5: You re-invoke the skill

```
arch-generate-solution: examples/order-management/solutions/002_Automated Order Fulfillment/
```

The skill detects its phase by inspecting durable artifacts on the branch:
`decisions/` exists, ADRs are still `Proposed`, `.c4` files are untouched.
It queries the approval backend (`aac-forge.config.json` → `approvalBackend`),
confirms the PR is approved, then **stamps each ADR as Accepted**:

```markdown
---
id: ADR-002-0001
status: Accepted
solution: "002"
date: "2026-05-31"
approval:
  system: azure-devops
  reference: "PR #1234"
approvers:
  - role: Enterprise Architect
    name: "G. White"
    date: "2026-06-01"
  - role: Solution Architect
    name: "A. Grey"
    date: "2026-06-01"
supersedes: []
superseded-by: []
---
```

The ADR body is unchanged — only the front matter is stamped. The skill is the sole
writer of the `status: Accepted` transition.

### Step 6: Stage B — Build

The skill edits `model/domains/core-services.c4` to add the Fulfillment Engine system,
its three containers, and all relationships from the change plan. It runs
`npx likec4 validate` — passes. It exports diagrams to `output/`.

**Failure path — model contradicts accepted ADR:** If validation revealed that the model
structure can't express what ADR-002-0001 decided (e.g., LikeC4 can't model the Kafka
protocol path cleanly), the skill stops: *"ADR-002-0001 specifies Kafka, but the model
can't express this cleanly. Revise the ADR or change plan."* The state marker resets to
`awaiting-approval`. You amend the ADR on the proposal branch, request re-approval, then
resume.

### Step 7: Stage C — Document & Review

The skill updates the SAD to rev 2 — fills all sections, references Accepted ADRs by ID,
embeds exported diagrams. It runs the 5-role review:

- **SA:** NFRs realistic for event-driven architecture?
- **EA:** ADRs consistent with each other? Reuse maximized?
- **Security:** ADR-002-0001 Kafka topics ACL'd and encrypted?
- **Order Management owner:** New Kafka consumer impact on Order Worker SLA?
- **BPO:** All BR open decisions covered by ADRs?

All findings go into `output/SAD Review Automated Order Fulfillment.md`.

### Step 8: Merge Gate

This is the **same PR** from Step 4. The Stage B/C commits dismissed the initial
approval, so the PR needs re-approval — but this is a **conformance check**, not a
second architecture review. It verifies:

- `.c4` model matches the approved change plan
- SAD rev 2 references all Accepted ADRs
- Diagrams match the model
- Review findings are resolved or acknowledged

The architecture decisions themselves are not reopened. The durable record is the ADR
front matter — the PR approval state is transient and dismissible.

PR approved. Merge to main. Delete proposal branch. Done.

---

## 2. Edge Case: BR Rejected

The BR is placed in `input/`. The Enterprise Architect reads it and says: "This conflicts
with Q3 priorities. Defer to Q4."

The BR never reaches the skill. No branch, no files.

If the skill had been invoked and Stage A produced a decision package, but the gate
reviewers concluded the entire proposal should be rejected:

1. The skill stamps ADRs in `decisions/` as `status: Rejected`
2. The proposal branch is closed or deleted

By default, rejected proposals are **not** archived to main — the branch is simply
discarded. If the team wants a permanent record of rejected decisions, set
`archiveRejectedProposals: true` in `aac-forge.config.json`. When enabled, the skill
merges only the `decisions/` directory (no `.c4` changes) to main before deleting the
branch. The rejected ADRs on main then serve as a permanent record of what was
considered and why it was declined.

---

## 3. Edge Case: Scope Expands During Planning

The skill reads the BR and finds: "Picklist generation needs warehouse zone data, but
Inventory doesn't expose zone information."

The SAD skeleton flags it:

```markdown
## Open Decisions

3. **Scope gap: Inventory zone data** — The BR doesn't mention Inventory changes,
   but picklist routing requires warehouse zone data that Inventory doesn't expose.
   → Amend BR to include Inventory API extension, or defer zone optimization to v2.
```

Gate reviewer decides: "Include it. I'll add the Inventory team as reviewers."

The skill adds `ADR-002-0003-inventory-zone-api.md` to `decisions/`, expands the change
plan with a new `inventoryApi` relationship, and the gate approves the larger package.

If the reviewer had chosen to defer: the skill adds a constraint to the SAD skeleton
("zone optimization out of scope for v1"), removes the Inventory dependency from the
change plan, and proceeds with reduced scope.

---

## 4. Operational: New Feature on an Existing Project

Fulfillment Engine has been live for three months. The Shipping team wants to add
real-time tracking webhooks.

Process is identical to a new project, just smaller:

1. BR: `solutions/003_Real-time Tracking/input/BR Real-time Tracking.md`
2. Skill creates `proposal/003-real-time-tracking`
3. Stage A reads the **current** model from main — Fulfillment Engine already exists
4. The change plan shows only the delta: one new relationship
   `shippingProvider → fulfillmentApi`, one new container `trackingWebhookHandler`
5. One ADR in `decisions/ADR-003-0001-tracking-push-vs-poll.md`
6. Gate, approve, stamp, build, review, merge

The skill doesn't need history — it reads main's current state every time.

---

## 5. Operational: Late Security Finding After Gate

Solution 002 is in Stage B (post-gate, model being edited). The Security reviewer
realizes: "ADR-002-0001 selected Kafka but didn't address PII in message payloads."

ADR-002-0001 is already `Accepted` — it can't be silently edited. The skill stops Stage B.
On next invocation, it detects that `.c4` files have been partially edited but a
new Proposed ADR exists — the gate must re-approve before Stage B can resume.

You create a new ADR on the proposal branch:

```
decisions/ADR-002-0003-pii-in-kafka.md
```

```markdown
---
id: ADR-002-0003
status: Proposed
solution: "002"
supersedes: ["ADR-002-0001"]
---
# ADR-002-0003: PII Protection in Fulfillment Kafka Messages

ADR-002-0001 selected Kafka for fulfillment event propagation but did not address PII.
This ADR adds:
- Encryption-at-rest for `order.confirmed` and `fulfillment.completed` topics
- Field-level masking of customer name, address, and phone in message payloads
- Kafka ACLs restricting consumer groups to authorized services only
```

The gate approves ADR-002-0003. The skill:

1. Stamps ADR-002-0003 as `Accepted`
2. Stamps ADR-002-0001 as `Superseded` with `superseded-by: ["ADR-002-0003"]`
3. Resumes Stage B

The original ADR's body is preserved — ADR-002-0003 adds the missing security analysis
without rewriting history.

---

## Quick Reference

| Step | Who | What | Files touched |
| --- | --- | --- | --- |
| 1. BR | Human | Write BR | `input/` |
| 2. Invoke | Human | Run skill | — |
| 3. Stage A | LLM | Skeleton + ADRs + change plan + state | Proposal branch, no `.c4` |
| 4. Gate | Human | PR review, approve/amend/reject | Proposed ADRs updated on branch |
| 5. Resume | LLM | Verify approval, stamp ADRs Accepted | ADR front matter (sole writer) |
| 6. Stage B | LLM | Edit `.c4`, validate, export | `.c4` files, PNGs |
| 7. Stage C | LLM | SAD rev 2, 5-role review | `output/` |
| 8. Merge | Human | Same PR, conformance re-approval, merge | — |
