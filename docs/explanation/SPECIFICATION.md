# Architecture-as-Code + LLM Pipeline — Fork Specification

**Status:** Draft  
**Author:** Enterprise Architecture Team  
**Target stack:** LikeC4 + LLM abstraction layer (DeepSeek, Gemini, Claude)  
**Date:** June 2025

---

## 1. Executive Summary

This specification defines the architecture and implementation plan for **aac-forge** — an LLM-driven Architecture as Code pipeline using the **LikeC4** C4 modeling stack with an **LLM abstraction layer** that works with DeepSeek, Gemini, or Claude interchangeably.

The core value proposition remains: **BR document → LLM generates model → validate → export diagrams → write SAD → multi-role review**.

---

## 2. Stack Decision

### 2.1 Why LikeC4 over Structurizr

**Decision:** LikeC4 is the primary modeling stack. Structurizr is retained as an optional export target.

**Rationale:**

| Factor | Structurizr (new consolidated) | LikeC4 |
|---|---|---|
| Runtime dependency | Java 21 + Docker | Node.js 20+ |
| Installation | `docker pull structurizr/structurizr` | `npm install @likec4/cli` |
| Validation | Requires running container + API call | `npx likec4 validate` (instant) |
| Diagram export | PlantUML via CLI, SVG via Puppeteer | PNG/SVG/Mermaid via CLI |
| VSCode support | None built-in | First-class extension with live preview |
| Layout engine | Dagre v4 (recently improved) | Custom (Elk.js-based) |
| Merge conflicts | `workspace.json` still exists | No separate layout file |
| Licensing | Open core (server is paid £300+/mo) | MIT |
| LLM integration | DSL is text, validation needs container | DSL is text, validation is CLI |

**The deciding factor:** For a pipeline that an LLM drives — read DSL, mutate it, validate, export — the feedback loop is dramatically faster with LikeC4. The LLM can run `npx likec4 validate` in <1 second versus waiting for a Docker container API.

### 2.2 Structurizr as optional export target

We retain the ability to export Structurizr-compatible DSL for teams that use it. The LLM reads/writes LikeC4 `.c4` files natively, and a converter script (`scripts/c4-to-structurizr.sh`) produces `.dsl` files for Structurizr Lite viewing when needed.

### 2.3 Diagram output formats

| Format | Tool | Use case |
|---|---|---|
| **PNG** | `likec4 export png` | Embed in SAD documents |
| **Mermaid** | `likec4 export mermaid` | GitHub/GitLab markdown rendering |
| **Structurizr DSL** | Converter script | Structurizr Lite interactive viewing |
| **SVG** | Optional Puppeteer path | Formal documentation with legend keys |

---

## 3. Repository Structure

```
.
├── README.md
├── SPECIFICATION.md                  # This document
├── .env.example
├── package.json                      # Node.js project (LikeC4 + scripts)
│
├── model/                            # LikeC4 C4 model (replaces structurizr/)
│   ├── workspace.c4                  # Root: assembles via imports
│   ├── common.c4                     # Common actors & external systems
│   └── domains/
│       ├── customer-facing/          # e.g., Web Portal, Mobile API
│       │   ├── model.c4
│       │   └── views.c4
│       ├── core-services/            # e.g., Order Management, Payment
│       │   ├── model.c4
│       │   └── views.c4
│       └── integrations/            # e.g., External Gateways, Message Bus
│           ├── model.c4
│           └── views.c4
│
├── solutions/                        # Design solutions (preserved structure)
│   ├── index.md                      # Solution registry
│   └── NNN_Name/
│       ├── input/                    # BR documents, process diagrams
│       └── output/                   # SAD documents, exported diagrams
│
├── skills/                           # Provider-agnostic LLM playbooks
│   ├── arch-generate-solution.md
│   ├── arch-review-solution.md
│   ├── arch-export-diagrams.md
│   └── arch-list-resources.md
│
├── adapters/                         # LLM provider adapters
│   ├── adapter-interface.ts          # Abstract tool interface
│   ├── adapter-deepseek.ts
│   ├── adapter-gemini.ts
│   └── adapter-claude.ts
│
├── scripts/
│   ├── validate-model.sh             # likec4 validate wrapper
│   ├── export-diagrams.sh            # likec4 export wrapper
│   ├── c4-to-structurizr.sh          # LikeC4 → Structurizr DSL converter
│   ├── parse-bpmn.py                 # BPMN parser (adapted from original)
│   ├── extract-labels.py             # Diagram label extractor (adapted)
│   └── verify-consistency.sh         # Diagram/SAD consistency check
│
├── templates/
│   ├── SAD-template.md               # SAD document template
│   └── REVIEW-template.md            # Review report template
│
├── docs/
│   ├── SPECIFICATION.md
│   ├── Corporate Architecture Standards/
│   │   └── Corporate_Standard.md
│   └── Security Standards/
│       └── Security_Standard.md
│
├── examples/
│   └── order-management/             # Real-world example domain
│       ├── model/
│       └── solutions/
│           └── 001_Automated Order Fulfillment/
│               ├── input/
│               │   └── BR Automated Order Fulfillment.md
│               └── output/
│                   ├── SAD Automated Order Fulfillment.md
│                   └── SAD Review Automated Order Fulfillment.md
│
└── tests/
    ├── golden-files/                 # Known inputs → expected outputs
    │   └── 001_generate/
    │       ├── input/
    │       ├── expected-model.diff
    │       └── expected-sad-sections.json
    └── smoke-test.sh                  # End-to-end pipeline test
```

### 3.1 Design Decisions

- **`model/` replaces `structurizr/`** — the domain structure is preserved, but DSL syntax changes to LikeC4
- **`skills/` replaces `.claude/skills/`** — renamed and made provider-agnostic
- **`adapters/` is new** — the LLM abstraction layer
- **`examples/` contains** a real-world enterprise domain showcasing the full pipeline
- **`tests/` is new** — golden-file tests for skill output validation

---

## 4. LLM Abstraction Layer

### 4.1 Problem

LLM platforms have different tool-calling APIs. The pipeline must work across
DeepSeek, Gemini, and Claude without platform-specific skill variants.

### 4.2 Solution: Adapter Interface

Define a minimal abstract tool interface that every provider adapter implements:

```typescript
// adapters/adapter-interface.ts

interface ArchToolAdapter {
  // Read a file (returns content as string)
  readFile(path: string, options?: { head?: number; tail?: number; range?: string }): Promise<string>;

  // Search file contents (returns match list)
  searchContent(pattern: string, options?: {
    path?: string;
    glob?: string;
    context?: number;
  }): Promise<MatchResult[]>;

  // Find files by name pattern
  searchFiles(pattern: string, path?: string): Promise<string[]>;

  // Run shell command (returns stdout, stderr, exit code)
  runCommand(command: string, options?: { timeoutSec?: number }): Promise<CommandResult>;

  // Write a new file
  writeFile(path: string, content: string): Promise<void>;

  // Apply a SEARCH/REPLACE edit to an existing file
  editFile(path: string, search: string, replace: string): Promise<void>;

  // Interactive user question (may not be supported by all providers)
  askUser(question: string, options?: string[]): Promise<string>;

  // Report progress / set task status
  setStatus(message: string): Promise<void>;
}

interface MatchResult {
  path: string;
  line: number;
  text: string;
}

interface CommandResult {
  stdout: string;
  stderr: string;
  exitCode: number;
}
```

### 4.3 Provider Implementations

Each provider adapter maps the abstract interface to the concrete tool calls of that LLM platform:

- **DeepSeek** — maps to DeepSeek API tool calling format
- **Gemini** — maps to Gemini's function calling / tool use
- **Claude** — maps to Claude's tool use (Read, Grep, Glob, Bash, etc.)

The adapter is ~100-150 lines per provider.

### 4.4 How Skills Reference the Adapter

Each skill is written in natural language and references the abstract tools by their interface names, not by provider-specific names:

```
# Skill: arch-generate-solution

## Algorithm

### Phase 1. Preparation
1. Use `readFile` to read all files from `<solution>/input/`
2. Use `searchFiles` with pattern `*.c4` under `model/` to find all model files
3. Use `readFile` to read the current architecture model
...

### Phase 3. Model Changes
1. Use `editFile` to add new system to `model/domains/<domain>/model.c4`
...
```

The LLM runtime injects the appropriate adapter, so the skill text is identical regardless of which provider is executing it.

---

## 5. LikeC4 DSL Conventions

### 5.1 Syntax Overview

LikeC4 uses a TypeScript-like DSL. Key differences from Structurizr DSL:

```typescript
specification {
  element person {
    style {
      shape person
    }
  }
  element system
  element container
}

model {
  // Person
  customer = person 'Customer' {
    description 'External customer placing orders'
  }

  // Software system
  orderSystem = system 'Order Management' {
    description 'Core order processing system'

    // Containers inside the system
    orderApi = container 'Order API' 'REST API for order operations' 'Go' {
      // Technology: Go
    }
    orderDb = container 'Order Database' 'Persistent order storage' 'PostgreSQL' {
      style {
        shape cylinder
        icon tech:postgresql
      }
    }
    orderWorker = container 'Order Worker' 'Async order processor' 'Go'
  }

  // External system
  paymentGateway = system 'Payment Gateway' {
    description 'External payment processing'
  }

  // Relationships
  customer -> orderSystem.orderApi 'Places orders' 'REST/HTTPS'
  orderSystem.orderApi -> orderSystem.orderDb 'Reads/writes orders' 'TCP'
  orderSystem.orderApi -> paymentGateway 'Processes payment' 'REST/HTTPS'
}

views {
  // System context
  view orderSystemContext {
    title 'Order Management Context'
    include orderSystem, -> orderSystem ->
  }

  // Container view
  view orderSystemContainers {
    title 'Order Management Containers'
    include orderSystem.*, -> orderSystem.* ->
  }
}
```

### 5.2 Conventions

| Convention | Rule |
|---|---|
| Modular files | Each domain = `model.c4` + `views.c4`, imported in `workspace.c4` |
| Naming | PascalCase for system IDs, camelCase for container IDs |
| Protocols | Always specified: `'REST/HTTPS'`, `'gRPC'`, `'TCP'`, `'Kafka'`, `'GraphQL'` |
| Visual semantics | Use LikeC4 `style { shape ... }` for clear roles such as `person`, `browser`, `component`, `cylinder`, `storage`, `bucket`, `queue`, and `document` |
| Data flows | Use LikeC4's `note` or relationship description for INF numbering |
| External systems | Tag with `#external` |
| New/changed | All elements added/modified for a solution use `#new` / `#changed` |

### 5.3 Solution Views

LikeC4 supports multiple views of the same model:

```typescript
views {
  // Solution-specific view
  view solution001 of 'Solution 001: Automated Order Fulfillment' {
    include
      orderSystem.*,
      paymentGateway,
      -> orderSystem.* ->,
      -> paymentGateway ->
  }
}
```

---

## 6. Skills — Rewritten Playbooks

### 6.1 arch-generate-solution

**What it does:** Reads BR documents → analyzes requirements → proposes model changes → validates → exports diagrams → generates SAD.

**Key improvements over original:**
- Plan-before-execute: LLM first outputs a **change plan** (affected files, new elements, new relationships) → user approves → LLM applies edits
- No `AskUserQuestion` dependency (works with providers that don't support it — falls back to structured output)
- Uses `npx likec4 validate` instead of Docker API call
- Exports PNG directly (no Puppeteer)

**Algorithm (abbreviated):**

```
Phase 1. PREPARE
  - readFile all input/* files
  - searchFiles model/**/*.c4
  - readFile all model files
  - Parse BPMN if present (scripts/parse-bpmn.py)

Phase 2. PLAN (NEW — approval gate)
  - Analyze what needs to change
  - Output a structured change plan:
    NEW systems:     [...]
    NEW containers:  [...]
    MODIFIED:        [...]
    NEW rels:        [...]
    DATA FLOWS:      INF01: ... → ...
  - WAIT for user approval

Phase 3. APPLY
  - editFile each model/*.c4 file with changes
  - Add solution view to views.c4

Phase 4. VALIDATE
  - runCommand: npx likec4 validate
  - Fix errors, re-validate until clean

Phase 5. EXPORT
  - runCommand: scripts/export-diagrams.sh <solution>
  - Verify consistency: scripts/verify-consistency.sh

Phase 6. GENERATE SAD
  - Use SAD-template.md
  - Fill all sections from BR + model
  - Embed exported PNG diagrams
  - Cross-reference data flow table with INF codes

Phase 7. VERIFY
  - Extract labels from diagrams
  - Cross-reference with SAD table
  - Report summary
```

### 6.2 arch-review-solution

**What it does:** 5-role review of a completed SAD.

**Key improvements:**
- Uses standards from `docs/` as normative reference
- Auto-detects adjacent systems from the model (no manual enumeration)
- BR → SAD coverage matrix is automated (LLM maps each BR requirement to SAD sections)

**Roles maintained from original:**
1. Solution Architect (technical quality, decomposition, NFRs)
2. Enterprise Architect (landscape fit, naming, CMDB, reuse)
3. Security Specialist (auth, secrets, classification, logging)
4. Adjacent System Owner (per-system impact analysis)
5. Business Process Owner (BR coverage, user journey, business value)

### 6.3 arch-export-diagrams

**What it does:** Exports all solution views to PNG/Mermaid.

**Key improvement:** No Docker dependency. Single CLI command per format.

### 6.4 arch-list-resources

**What it does:** Parses LikeC4 model files, extracts all containers, outputs a resource table.

**Key improvement:** Uses LikeC4's structured model (can be parsed as a TypeScript AST or via `likec4 export json`) rather than grep-based extraction.

---

## 7. SAD Template — Improvements

### 7.1 Revision Header (NEW)

```markdown
---
solution: "001"
title: "Automated Order Fulfillment"
status: "Draft"             # Draft | Review | Approved | Implemented
author: "A. Architect"
reviewer: "B. Reviewer"
date: "2025-06-15"
revision: 1
approvals:
  - role: "Solution Architect"
    name: "..."
    date: "..."
  - role: "Security"
    name: "..."
    date: "..."
changelog:
  - rev: 1
    date: "2025-06-15"
    author: "A. Architect"
    changes: "Initial draft"
  - rev: 2
    date: "2025-06-20"
    author: "A. Architect"
    changes: "Addressed review findings SA-1, SEC-2"
---
```

### 7.2 Diagram Embedding (CHANGED)

Instead of SVG with legend keys, embed PNG for visual + provide Mermaid source for text-based rendering:

```markdown
### Container Diagram

![Container Diagram](solution_001_containers.png)

<details>
<summary>Mermaid source (for editing)</summary>

```mermaid
C4Context
  ...
```
</details>
```

### 7.3 Data Flow Table (PRESERVED)

The INFxx table structure from the original is production-quality and is kept as-is:

| Code | Data Object | Source | Consumer | Type | Status | Mode | Data | Protocol | Transport | Comment |

### 7.4 Traceability Matrix (NEW)

New section linking BR requirements to SAD sections:

| BR Requirement | SAD Section | Implementation |
|---|---|---|
| 4.1 Artifact Forging | 3.1, INF01-INF04 | Rune Master + Istari |
| 4.5 Task Palantir Integration | 3.1, INF07 | Knowledge Palantir extension |
| ... | ... | ... |

This replaces the manual requirement mapping the reviewer previously had to do.

---

## 8. Plan-Before-Execute Approval Gate

### 8.1 Problem

The original `arch-generate-solution` makes all DSL changes in one shot without user review. If the LLM misunderstands a requirement, it requires rollback and re-generation.

### 8.2 Solution

Between Phase 2 (Analysis) and Phase 3 (Apply), the LLM outputs a **structured change plan**:

```markdown
## Proposed Changes

### New Systems
| System | Domain | Description |
|---|---|---|
| Order Fulfillment Engine | core-services | Orchestrates fulfillment workflow |

### New Containers
| Container | Parent System | Technology | Description |
|---|---|---|---|
| Fulfillment API | Order Fulfillment Engine | Go | REST API for fulfillment operations |
| Picklist Generator | Order Fulfillment Engine | Python | Generates warehouse picklists |

### Modified Containers
| Container | Change |
|---|---|
| Order API | Add fulfillment trigger endpoint |

### New Relationships
| From | To | Protocol | Description |
|---|---|---|---|
| Order API | Fulfillment API | REST/HTTPS | Triggers fulfillment |
| Fulfillment API | Picklist Generator | gRPC | Requests picklist generation |

### Data Flows
| Code | From | To | Description |
|---|---|---|---|
| INF01 | Fulfillment API | Order API | Fulfillment status update |
| INF02 | Picklist Generator | Fulfillment API | Generated picklist |

### Files to Change
- `model/domains/core-services/model.c4` — add Order Fulfillment Engine system + containers
- `model/domains/core-services/views.c4` — add solution view
- `model/domains/integrations/model.c4` — add relationship to Payment Gateway

**Approve?** [Yes / No / Modify]
```

The user reviews and approves before any file is touched. This is the single biggest UX improvement over the original.

---

## 9. Real-World Example Domain

### 9.1 Choice: Order Management

The project includes a **real enterprise domain**: Order Management. This covers:

- **Customer-Facing**: Web Portal, Mobile API
- **Core Services**: Order Management, Inventory, Pricing
- **Integrations**: Payment Gateway, Shipping Provider, Notification Service

### 9.2 First Solution: Automated Order Fulfillment

The first real-world solution demonstrates:
1. Adding a new system (Fulfillment Engine) to an existing landscape
2. Cross-system container integration (Order API → Fulfillment API → Picklist Generator)
3. Event-driven data flows (Kafka for status updates)
4. External system integration (Shipping Provider)
5. Full 5-role review with realistic findings

## 10. CI/CD Pipeline

### 10.1 Validation on PR

```yaml
# .github/workflows/validate.yml
name: Validate Architecture Model

on:
  pull_request:
    paths:
      - 'model/**'
      - 'solutions/*/output/**'

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
      - run: npm ci
      - run: npx likec4 validate
      - run: scripts/verify-consistency.sh
```

### 10.2 Diagram Export on Merge

On merge to main, auto-export all diagrams and commit them to the repo (so SAD documents always have up-to-date diagrams):

```yaml
- run: scripts/export-diagrams.sh
- uses: stefanzweifel/git-auto-commit-action@v5
  with:
    commit_message: 'chore: update exported diagrams'
    file_pattern: 'solutions/*/output/*.png'
```

### 10.3 Golden-File Tests

Each skill has a golden-file test: known BR input → expected model diff + expected SAD sections. These run in CI to catch skill regressions:

```bash
tests/smoke-test.sh
```

---

## 11. Test Strategy

### 11.1 Unit Tests

- `adapters/*.ts` — test each provider adapter against mock tool responses
- `scripts/c4-to-structurizr.sh` — test round-trip conversion
- `scripts/extract-labels.py` — test against known diagram outputs

### 11.2 Golden-File Tests (Skill Output Validation)

For each skill, a test directory with:

```
tests/golden-files/
├── generate/
│   ├── 001_order_fulfillment/
│   │   ├── input/                      # BR document
│   │   ├── initial-model/              # Starting model state
│   │   ├── expected-model/             # Expected model after generation
│   │   ├── expected-sad-sections.json  # Expected SAD section contents
│   │   └── expected-review-sections.json
│       └── ...
└── review/
    └── ...
```

The test runner:
1. Copies initial-model to a temp workspace
2. Runs the skill against the input
3. Diffs the resulting model against expected-model
4. Asserts SAD sections contain required fields
5. Reports pass/fail

### 11.3 End-to-End Smoke Test

```bash
#!/usr/bin/env bash
# tests/smoke-test.sh
set -euo pipefail

echo "=== Smoke test: Full pipeline ==="

# 1. Validate base model
npx likec4 validate || exit 1

# 2. Export diagrams
scripts/export-diagrams.sh || exit 1

# 3. Parse BPMN
python3 scripts/parse-bpmn.py examples/order-management/solutions/001_*/input/*.bpmn || true

# 4. Verify consistency
scripts/verify-consistency.sh || true

echo "=== Smoke test PASSED ==="
```

---

## 12. Open Questions

1. **LikeC4 import syntax** — LikeC4's `import` mechanism for modular models needs verification. If it doesn't support `!include`-style file imports, we may need a preprocessor that concatenates `.c4` files before validation.

2. **Diagram key/legend** — LikeC4 may not generate separate legend images like Structurizr does. If needed, we can generate legend tables in Markdown instead.

3. **`workspace.json` equivalent** — LikeC4 may have a layout configuration file. If it exists, the merge-conflict skill may still be needed (or simplified).

4. **DeepSeek tool calling** — DeepSeek's tool calling API compatibility with the adapter interface needs validation. If it differs significantly from OpenAI/Claude format, adapter complexity increases.

5. **BPMN parser compatibility** — The Python BPMN parser is unchanged, but BR documents in the real-world example may use different BPMN structures.

6. **LikeC4 Mermaid export fidelity** — Need to verify that LikeC4's Mermaid export produces diagrams of comparable quality to the PNG export.

---

## 14. References

- [LikeC4 Documentation](https://likec4.dev/)
- [LikeC4 GitHub](https://github.com/likec4/likec4)
- [Structurizr DSL](https://docs.structurizr.com/dsl)
- [Structurizr Product Consolidation (Patreon, May 2025)](https://www.patreon.com/posts/146923136)
- [C4 Model](https://c4model.com/)
