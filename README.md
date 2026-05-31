# aac-forge — Architecture as Code Forge

LLM-driven Architecture as Code pipeline using **LikeC4** (C4 model) with multi-provider LLM support (DeepSeek, Gemini, Claude).

**Pipeline:** BR document → LLM generates C4 model → validate → export diagrams → write SAD → multi-role review.

## Quick Start

```bash
# Install dependencies
npm install

# Validate all models
npm run validate
npx likec4 validate examples/order-management/model/

# Start the interactive diagram explorer
npm run dev                        # Opens http://localhost:5173
npx likec4 start examples/order-management/model/

# Export diagrams to PNG
npm run export:png
npx likec4 export png examples/order-management/model/ -o examples/order-management/export/ --flat

# Run the smoke test
bash tests/smoke-test.sh
```

## What's Inside

### Example Model

| Model | Location | Scope |
| --- | --- | --- |
| **Order Management** | `examples/order-management/model/` | Real-world enterprise — 13 systems, 14 containers, 5 views across 3 domains |

### Pipeline Skills (Provider-Agnostic)

| Skill | Purpose |
| --- | --- |
| `arch-generate-solution` | Reads BR → plan-before-execute gate → edits model → validates → exports → generates SAD |
| `arch-review-solution` | 5-role architecture review (SA, EA, Security, Adjacent System Owner, Business Process Owner) |
| `arch-export-diagrams` | Export to PNG, Mermaid, JSON, DrawIO, DOT, D2, PlantUML |
| `arch-list-resources` | Extract all containers from LikeC4 model → resource table |

### LLM Abstraction Layer

```
adapters/
└── adapter-interface.ts    # Abstract tool interface (readFile, searchContent, editFile, runCommand, ...)
                            # Provider adapters (DeepSeek, Gemini, Claude) implement this interface
```

### Automation Scripts

| Script | Purpose |
| --- | --- |
| `scripts/validate-model.sh` | `npx likec4 validate` wrapper |
| `scripts/export-diagrams.sh` | Multi-format export (PNG + Mermaid + JSON) |
| `scripts/verify-consistency.sh` | Arrow vs INF code consistency check |
| `scripts/parse-bpmn.py` | BPMN 2.0 XML parser — participants, message flows, tasks |
| `scripts/extract-labels.py` | Extract relationships and data flows from LikeC4 JSON export |

## Repository Structure

```
aac-forge/
├── model/                            # Main LikeC4 model (to populate)
│   ├── workspace.c4                  # Specification + views
│   ├── common.c4                     # Common actors & external systems
│   └── domains/                      # Architectural domains
│
├── skills/                           # Provider-agnostic LLM playbooks
│   ├── arch-generate-solution.md
│   ├── arch-review-solution.md
│   ├── arch-export-diagrams.md
│   └── arch-list-resources.md
│
├── adapters/
│   └── adapter-interface.ts          # LLM provider abstraction
│
├── scripts/
│   ├── validate-model.sh
│   ├── export-diagrams.sh
│   ├── verify-consistency.sh
│   ├── parse-bpmn.py
│   └── extract-labels.py
│
├── templates/
│   ├── SAD-template.md               # Solution Architecture Document template
│   └── REVIEW-template.md            # 5-role review report template
│
├── examples/
│   └── order-management/             # Tutorial/demo/reference domain only
│       ├── model/                    # 3 domains: customer-facing, core-services, integrations
│       └── solutions/001_.../        # BR + SAD — Automated Order Fulfillment
├── solutions/                        # Real architecture change packages for the root model
│   └── 001_.../                      # BR + ADRs + SAD + review output
│
├── tests/
│   ├── smoke-test.sh                 # End-to-end pipeline validation
│   └── golden-files/                 # Golden-file test structure
│
├── docs/
│   └── SPECIFICATION.md              # Full fork specification
│
├── .github/workflows/validate.yml     # CI/CD — validation on PR, diagram export on merge
└── package.json                       # npm scripts for dev, build, validate, export
```

## LikeC4 DSL Conventions

LikeC4 uses a TypeScript-like DSL with **user-defined element kinds**:

```ts
specification {
  element person {          // define kinds and default styles
    style {
      shape person
    }
  }
  element system
  element container
}

model {
  // Actors
  customer = person 'Customer' {
    description 'External customer placing orders'
  }

  // System with nested containers
  orderSystem = system 'Order Management' {
    description 'Core order processing'

    orderApi = container 'Order API' 'REST API for order operations' 'Go'
    orderDb = container 'Order Database' 'Persistent order storage' 'PostgreSQL'
  }

  // Relationships with protocol
  customer -> orderSystem.orderApi 'Places orders' 'REST/HTTPS'
  orderSystem.orderApi -> orderSystem.orderDb 'Reads and writes orders' 'TCP'
}

views {
  // System context — explicit solution-scoped view
  view orderSystemContext {
    include orderSystem, -> orderSystem ->
  }

  // Per-system container view
  view orderSystemContainers {
    include orderSystem.*, -> orderSystem.* ->
  }
}
```

### Modular Files

All `*.c4` files in a directory tree are **auto-discovered and merged**. Only one `specification` block and one `views` block across all files. Domain files contain only `model { }` blocks.

### Key Conventions

- **Element IDs:** PascalCase for systems (`orderSystem`), camelCase for containers (`orderApi`)
- **Protocols:** Always specified: `'REST/HTTPS'`, `'gRPC'`, `'TCP'`, `'Kafka'`, `'AMQP'`, `'MCP/HTTPS'`, `'HTTPS'`
- **Containers** are nested inside their parent system
- **Semantic shapes** should be used where roles are clear: `person`, `browser`,
  `mobile`, `component`, `cylinder`, `storage`, `bucket`, `queue`, `document`
- **Visual notation** for colors, borders, icons, and relationship styling is defined
  in `docs/reference/visual-notation.md`
- **Parent→child** relationships (system→own container) are implicit — don't declare them
- **Data flows** use INFxx codes in relationship titles: `'INF01. Description of data'`
- **Cross-system container references** use the container ID directly (it's globally unique)
- **Solution views** should use explicit includes and be exported with `-f <viewId>`
  filters. Avoid generic `include *` landscape views for SAD deliverables unless they
  are intentionally curated portfolio/workspace views.

Real architecture work belongs in root `solutions/` and root `model/`. The `examples/`
tree is reserved for tutorial/demo/reference material and should not be auto-selected
for production architecture generation.

## CI/CD

On PR: validates all model workspaces + format check + smoke tests.
On merge to main: auto-exports all diagrams and commits them.

## Requirements

- **Node.js** 20+
- **LikeC4** 1.57.0 (installed via npm)
- **Playwright** (for PNG export — run `npx playwright install chromium`)

## License

MIT
