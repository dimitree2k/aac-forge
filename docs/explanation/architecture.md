# Pipeline Architecture

Why aac-forge is built the way it is — design decisions, stack rationale, and pipeline flow.

## The Pipeline

```
BR Document (.md)
    │
    ▼
┌─────────────────────────┐
│  arch-generate-solution  │  LLM reads BR + current model
│  (Plan-before-execute)   │  → proposes changes → user approves
└───────────┬─────────────┘
            │
            ▼
┌─────────────────────────┐
│  LikeC4 Model (.c4)     │  Systems, containers, relationships
│  Validated & formatted   │  `npx likec4 validate`
└───────────┬─────────────┘
            │
            ▼
┌─────────────────────────┐
│  Diagram Export          │  PNG, Mermaid, JSON, DrawIO
│  npx likec4 export png   │  Playwright → headless Chrome
└───────────┬─────────────┘
            │
            ▼
┌─────────────────────────┐
│  SAD Document (.md)      │  Filled from template
│  Data flow table +       │  Traceability matrix
│  container diagrams       │  Security + NFR sections
└───────────┬─────────────┘
            │
            ▼
┌─────────────────────────┐
│  arch-review-solution    │  5-role review
│  Findings report          │  Critical / Significant / Minor
└─────────────────────────┘
```

## Why LikeC4 over Structurizr

| Factor | Structurizr | LikeC4 |
| --- | --- | --- |
| Runtime | Java 21 + Docker | Node.js 20+ |
| Validation | Docker API call (~5s) | CLI command (< 1s) |
| Diagram export | Puppeteer SVG | Playwright PNG + native JSON/DrawIO/Mermaid |
| Dev server | None built-in | Hot-reload dev server on localhost |
| Modular files | `!include` directives | Auto-discovery of all `*.c4` files |
| Layout storage | `workspace.json` (merge conflicts) | No separate layout file |
| LLM feedback loop | Slow — needs Docker | Fast — instant CLI validation |
| License | Open core (£300+/mo server) | MIT |

**The deciding factor for LLM-driven pipelines:** The inner loop of "edit DSL → validate → export" is dramatically faster with LikeC4. An LLM can iterate on model changes 10x faster without Docker overhead.

## Why Provider-Agnostic Skills

LLM platforms have different tool-calling APIs — Claude, DeepSeek, and Gemini each
use their own format. aac-forge abstracts these behind an `ArchToolAdapter` interface. Each LLM provider (DeepSeek, Gemini, Claude) gets its own adapter that maps abstract tool names to concrete API calls. The skill text is identical regardless of which provider executes it.

```
Skill (Markdown)          Adapter (TypeScript)        LLM Runtime
─────────────────        ─────────────────────        ───────────
"Use readFile to..."  →  ArchToolAdapter.readFile  →  DeepSeek API
"Use searchContent..." →  ArchToolAdapter.searchContent → Gemini API
"Use editFile to..."  →  ArchToolAdapter.editFile  →  Claude API
```

## Plan-Before-Execute Gate

The original `arch-generate-solution` made all DSL changes in one shot without user review. If the LLM misunderstood a requirement, it required rollback.

aac-forge inserts an **approval gate** between analysis and application:

```
Phase 2. PLAN:
  → Output structured change plan
  → WAIT for user: "Yes" / "No" / "Modify: ..."
  → Only then proceed to Phase 3. APPLY
```

This is the single biggest UX improvement — the user reviews exactly what will change before any file is touched.

## Modular File Design

LikeC4 auto-discovers all `*.c4` files in a directory tree. This means:

- **No import directives needed** — just create a `.c4` file in the right directory
- **One specification block** across all files — all domains share the same element kinds
- **Domain files contain only `model { }` blocks** — clean separation of concerns
- **Views can be in any file** — domain views live alongside their elements

This is simpler than Structurizr's `!include` system and avoids the need for a preprocessor.

## Example Model

### Order Management (Real-World Enterprise)
- Customer-Facing: Web Portal, Mobile API
- Core Services: Order Management, Inventory, Pricing, Fulfillment
- Integrations: Payment Gateway, Shipping, Notifications, Kafka

Demonstrates the full pipeline: BR → SAD → Review with a relatable enterprise scenario.

## The 5-Role Review

The review covers five distinct perspectives, each with its own checklist:

1. **Solution Architect** — catches technical gaps (missing error handling, unrealistic NFRs)
2. **Enterprise Architect** — catches landscape issues (duplicating existing capabilities)
3. **Security Specialist** — catches compliance gaps (missing auth, secrets in plaintext)
4. **Adjacent System Owner** — catches integration risks (SLA impact, backward compat)
5. **Business Process Owner** — catches requirements gaps (BR not fully covered)

Each role has a distinct checklist and produces independently numbered findings. Overlaps get cross-references.

## See Also

- [Full Fork Specification](SPECIFICATION.md) — detailed technical spec
- [LikeC4 Documentation](https://likec4.dev/)
- [C4 Model](https://c4model.com/)
- [Diátaxis Framework](https://diataxis.fr/)
