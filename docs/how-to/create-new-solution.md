# How to Create a New Solution

A **solution** is a design proposal for a specific business need — a BR document plus a generated SAD.

The pipeline: **BR document → LLM generates C4 model changes → validate → export diagrams → write SAD → multi-role review**.

## Quick Summary

1. Create the solution folder
2. Write a BR document
3. Run `arch-generate-solution` skill
4. Review the change plan, approve
5. Validate and export diagrams
6. Run `arch-review-solution` skill

## 1. Create the Solution Folder

Real architecture solutions live in root `solutions/`:

```
solutions/
└── NNN_Short_Name/
    ├── input/          # BR documents, BPMN diagrams
    │   └── BR Name.md
    └── output/         # Generated SAD, diagrams, review
        ├── SAD Name.md
        └── SAD Review Name.md
```

`NNN` is a zero-padded sequential number (001, 002, ...). Use the next available.
The `examples/` tree is reserved for tutorial/demo/reference material. Do not place
working enterprise architecture packages under `examples/`.

```bash
mkdir -p solutions/001_My_Feature/input
mkdir -p solutions/001_My_Feature/output
```

## 2. Write the BR Document

Create `solutions/001_My_Feature/input/BR My Feature.md`.

A good BR includes:

```markdown
# BR My Feature

## 1.1 Glossary
| Term | Description |
| --- | --- |
| ... | ... |

## 1.2 Project Description
**Goals:** ...
**Consumers:** ...
**Constraints:** ...

## 2. Business Requirements
...

## 3. Functional Requirements
- FR-01: ...
- FR-02: ...

## 4. Non-Functional Requirements
| Metric | Value |
| --- | --- |
| ... | ... |

## 5. Integration Requirements
| From | To | Protocol | Purpose |
| --- | --- | --- | --- |
| ... | ... | ... | ... |
```

See existing BRs for examples:

- `solutions/001_Property Intelligence Platform/input/BR Property Intelligence Platform.md`
- `examples/order-management/solutions/001_.../input/BR Automated Order Fulfillment.md`

## 3. Run the Generate Skill

Provide the solution path to the `arch-generate-solution` skill:

```
arch-generate-solution: solutions/001_My_Feature/
```

The skill will:

1. **Read** all input documents and the current model
2. **Output a change plan** — new systems, containers, relationships, data flows, files to change
3. **Wait for your approval** — review the plan and reply "Yes", "No", or "Modify: ..."
4. **Apply changes** — edits model files
5. **Validate** — runs `npx likec4 validate`
6. **Export diagrams** — generates PNGs
7. **Generate SAD** — fills the SAD template
8. **Verify** — cross-references data flows

## 4. Review the Change Plan

When the skill presents the plan:

```markdown
## Proposed Changes

### New Systems
| System ID | Title | Description |
| --- | --- | --- |
| fulfillmentEngine | Fulfillment Engine | Orchestrates order fulfillment |

### New Containers
| Container ID | Parent System | Title | Technology |
| --- | --- | --- | --- |
| fulfillmentApi | Fulfillment Engine | Fulfillment API | Go |

### Files to Change
- `model/domains/core-services.c4` — add Fulfillment Engine system
```

Verify that:
- New systems are placed in the right domain
- Relationships reference existing systems correctly
- Data flows match the BR requirements
- No unintended changes to existing elements

Reply with:
- `Yes` — proceed with all changes
- `No` — abort
- `Modify: move Fulfillment Engine to integrations domain` — request specific changes

## 5. After Generation

The skill produces:

- **Updated model files** — with new elements and relationships
- **Exported diagrams** — PNGs in the output folder
- **SAD document** — `output/SAD My Feature.md`

Verify the SAD:
- Data flow table matches diagrams
- Traceability matrix covers all BR requirements
- Security section is complete
- Open questions are documented

## 6. Run the Review

```
arch-review-solution: solutions/001_My_Feature/
```

The review runs in 5 phases:
1. **Context gathering** — reads BR, SAD, model, standards, ADRs
2. **Enumeration** — produces structured tables of Systems, Containers, Relationships, and BR Requirements
3. **Cross-cutting pattern checks** — 10 systematic checks for store+event consistency, external call resilience, API/event/data contracts, enterprise integration, DR/BCP, RACI, etc.
4. **5-role review** — each role executes a concrete checklist against the enumerated tables:
   - **Solution Architect** — technical quality, decomposition, protocol alignment, NFRs
   - **Enterprise Architect** — CMDB, naming, reuse, foundation governance, capability mapping, cost
   - **Security Specialist** — authZ per flow, PII, secrets, audit, encryption, break-glass
   - **Adjacent System Owner** — per-system dependency, load, SLA, support, monitoring
   - **Business Process Owner** — BR coverage matrix, user journey, scope, business value
5. **Verification** — coverage guard checks that no gap was missed

The review report is written to `output/SAD Review My Feature.md`. Framework alignment: C4 Model, TOGAF 10, ATAM, NIST SP 800-53, Enterprise Integration Patterns, ISO/IEC 42010.

## 7. Iterate

Address findings, regenerate diagrams if the model changed, and re-review until all critical findings are resolved.

## Optional: Include a BPMN Diagram

If your BR references a business process, add a `.bpmn` file to `input/`:

```bash
cp ~/Downloads/my-process.bpmn solutions/001_My_Feature/input/
```

The skill automatically parses it with `scripts/parse-bpmn.py`.
