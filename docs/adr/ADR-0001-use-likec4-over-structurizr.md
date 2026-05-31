---
id: ADR-0001
status: Accepted
date: "2025-05-31"
approval:
  system: manual
  reference: "Bootstrapping decision — see docs/explanation/architecture.md"
approvers:
  - role: "Enterprise Architect"
    name: ""
    date: "2025-05-31"
supersedes: []
superseded-by: []
---

# ADR-0001: Use LikeC4 over Structurizr DSL

## Context

We needed to choose a modeling stack for an LLM-driven Architecture as Code pipeline.
The two candidates were Structurizr DSL and LikeC4.

## Decision Drivers

- **LLM feedback loop speed:** The pipeline's inner loop is "edit DSL → validate →
  export → review." Docker adds 5+ seconds of startup per validation call.
- **Dev experience:** Interactive diagram preview with hot reload is essential for
  rapid iteration during architecture design.
- **Modular files:** The pipeline generates and edits individual domain files. The
  DSL must support clean file separation without a preprocessor.
- **Licensing:** Structurizr's server is open-core with a paid tier (£300+/mo).
  LikeC4 is MIT.
- **Merge conflicts:** Structurizr has a separate `workspace.json` layout file that
  creates merge conflicts on concurrent edits. LikeC4 has no separate layout file.

## Options

### Option A: Structurizr DSL (consolidated, May 2025)

The newly consolidated Structurizr product combines the CLI and server into one
Docker image. It uses Dagre v4 for layout.

- **Pros:** Mature, well-documented, large community.
- **Cons:** Requires Java 21 + Docker. Validation needs a running container.
  Diagram export is Puppeteer-based (SVG only). No built-in dev server.
  `workspace.json` still exists.

### Option B: LikeC4

TypeScript-like DSL with a Node.js CLI. Uses Elk.js-based custom layout engine.

- **Pros:** Node.js 20+ (no Docker needed). `npx likec4 validate` takes < 1s.
  First-class VSCode extension with live preview. Exports to PNG, Mermaid, JSON,
  DrawIO, DOT, D2, PlantUML. MIT license. No separate layout file. Auto-discovers
  all `*.c4` files in a directory tree.
- **Cons:** Smaller community. Different DSL syntax (user-defined element kinds).
  No `!include` equivalent (compensated by auto-discovery).

## Decision

**Chose Option B: LikeC4.**

The deciding factor was the LLM feedback loop: `npx likec4 validate` runs in under
a second versus Structurizr's Docker API call (~5s). For a pipeline where an LLM
iterates on DSL changes dozens of times per session, this is a 10x speedup.

The MIT license and lack of Docker dependency also simplify CI and onboarding.

## Consequences

### Positive

- CLI validation in < 1s enables rapid LLM iteration
- Hot-reload dev server (`likec4 start`) for interactive diagram exploration
- Auto-discovery of `*.c4` files eliminates the need for `!include` directives
- No `workspace.json` — no merge conflicts on concurrent edits
- Multi-format export (PNG, Mermaid, JSON, DrawIO, DOT) from a single tool

### Negative

- Different DSL syntax required rewriting all domain files from Structurizr
  DSL (user-defined element kinds, no `!element` blocks, nested containers)
- Smaller community means fewer examples and Stack Overflow answers
- `@likec4/cli` was deprecated and replaced by the unscoped `likec4` package,
  requiring a mid-session migration during bootstrapping

### Mitigations

- Documented the DSL syntax mapping in `docs/reference/dsl-conventions.md`
- Added `scripts/c4-to-structurizr.sh` as a future export target for teams
  that need Structurizr compatibility

## References

- [LikeC4 Documentation](https://likec4.dev/)
- [Structurizr DSL](https://docs.structurizr.com/dsl)
- [Pipeline Architecture](../explanation/architecture.md)
- [Pipeline Specification](../explanation/pipeline-specification.md)
