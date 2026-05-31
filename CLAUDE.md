# aac-forge — Architecture as Code Forge

LLM-driven Architecture as Code pipeline using **LikeC4** (C4 model) with multi-provider LLM support (DeepSeek, Gemini, Claude).

**Language of all documentation, comments, and commits — English.**

---

## Project Identity

- **Name:** aac-forge (Architecture as Code Forge)
- **Stack:** LikeC4 + LLM abstraction layer
- **Goal:** BR document → LLM generates C4 model → validate → export diagrams → write SAD → multi-role review
- **LLM targets:** DeepSeek (primary), Gemini, Claude (all supported via adapters)

---

## Repository Structure

```
aac-forge/
├── CLAUDE.md                         # This file — project context
├── README.md                         # Project overview, quick start
├── aac-forge.config.json             # Repo configuration
├── LICENSE                           # MIT
├── docs/
│   ├── index.md                      # Documentation hub
│   ├── tutorials/                    # Step-by-step guides
│   ├── how-to/                       # Task-oriented recipes
│   ├── reference/                    # Technical facts and specs
│   ├── explanation/                  # Design decisions and background
│   ├── adr/                          # Repo-level Architecture Decision Records
│   └── input/specs/                  # Process specifications
├── model/                            # LikeC4 C4 model
│   ├── workspace.c4                  # Root: specification + views
│   ├── common.c4                     # Common actors & external systems
│   └── domains/                      # Architectural domains
├── skills/                           # Provider-agnostic LLM playbooks
│   ├── arch-generate-solution.md
│   ├── arch-review-solution.md
│   ├── arch-export-diagrams.md
│   └── arch-list-resources.md
├── adapters/                         # LLM provider adapters
│   └── adapter-interface.ts
├── scripts/                          # Automation scripts
│   ├── validate-model.sh
│   ├── export-diagrams.sh
│   ├── c4-to-structurizr.sh
│   ├── parse-bpmn.py
│   ├── extract-labels.py
│   └── verify-consistency.sh
├── templates/                        # Document templates
│   ├── ADR-template.md
│   ├── SAD-template.md
│   └── REVIEW-template.md
├── examples/
│   └── order-management/            # Real-world enterprise domain
├── tests/                            # Golden-file tests + smoke test
└── .github/workflows/                # CI/CD
```

---

## LikeC4 Conventions

### Syntax

LikeC4 uses a TypeScript-like DSL with user-defined element kinds:

```ts
specification {
  element person
  element system
  element container
}

model {
  customer = person 'Customer' {
    description 'External customer placing orders'
  }

  orderSystem = system 'Order Management' {
    description 'Core order processing'

    orderApi = container 'Order API' 'REST API for order operations' 'Go'
    orderDb = container 'Order Database' 'Persistent order storage' 'PostgreSQL'
  }

  // Relationships with protocol
  customer -> orderSystem.orderApi 'Places orders' 'REST/HTTPS'
}

views {
  view landscape { include * }
  view orderSystemContainers { include orderSystem.*, -> orderSystem.* -> }
}
```

### Modular Files

All `*.c4` files in a directory tree are **auto-discovered and merged** by LikeC4.
There must be exactly one `specification` block and one `views` block across all files
in a workspace. Domain files contain only `model { }` blocks.

### Naming

- System IDs: PascalCase (`orderSystem`, `paymentGateway`)
- Container IDs: camelCase (`orderApi`, `orderDb`)
- Container IDs are globally unique — no dot-notation needed in cross-system references
- Use descriptive names that match the CMDB

### Protocols

Always specify: `'REST/HTTPS'`, `'gRPC'`, `'TCP'`, `'Kafka'`, `'AMQP'`, `'MCP/HTTPS'`,
`'HTTPS'`, `'GraphQL'`

### Data Flows

Modeled as relationships with INFxx codes in the title:
```ts
orderApi -> orderWorker 'INF01. Order events for processing' 'Kafka'
```

### Parent→Child

System→its own container relationships are implicit — don't declare them explicitly.

---

## ADR Process

The project follows the BR → ADRs → SAD process documented in
`docs/input/specs/ADR-process.md`. Architecture Decision Records for solution work
live in `<solution>/decisions/`. Repo-level ADRs live in `docs/adr/`.

Key principle: **one architecture decision gate, before any `.c4` model edit.**
The `arch-generate-solution` skill produces a decision package (SAD skeleton +
Proposed ADRs + change plan), stops for human approval, then resumes to build.
