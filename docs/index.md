# aac-forge Documentation

Architecture as Code Forge — LLM-driven C4 architecture pipeline using LikeC4.

## Tutorials

_Learning-oriented, step-by-step guides for beginners._

| Guide | What you'll learn |
| --- | --- |
| [Quick Start](tutorials/quick-start.md) | Install, validate, explore diagrams in the browser, export PNGs, run smoke tests |
| [ADR Process Walkthrough](tutorials/adr-process-walkthrough.md) | Full BR→ADRs→SAD lifecycle with edge cases — rejected proposals, scope expansion, late findings |

## How-To Guides

_Task-oriented, practical recipes for specific goals._

| Guide | What you'll accomplish |
| --- | --- |
| [Run and Preview](how-to/run-and-preview.md) | Start dev server, validate models, export to all formats, build static site |
| [Add a New Domain](how-to/add-new-domain.md) | Create a new architectural domain with systems, containers, relationships, and views |
| [Create a New Solution](how-to/create-new-solution.md) | Full BR→SAD→Review pipeline — write BR, run generate skill, review the output |

## Reference

_Information-oriented, technical facts and specs._

| Reference | Contents |
| --- | --- |
| [DSL Conventions](reference/dsl-conventions.md) | LikeC4 syntax: elements, relationships, protocols, data flows, views |
| [Visual Notation](reference/visual-notation.md) | Shape, color, border, icon, and relationship styling conventions for readable diagrams |
| [CLI Commands](reference/cli-commands.md) | All npm scripts, `likec4` commands, and project scripts |
| [Skills Reference](reference/skills-reference.md) | The 4 LLM playbooks — phases, roles, adapter interface |
| [ADR Process Spec](input/specs/ADR-process.md) | Formal specification for BR→ADRs→SAD, approval backend, ADR lifecycle, state machine |

## Explanation

_Understanding-oriented, background and design decisions._

| Explanation | Contents |
| --- | --- |
| [Pipeline Architecture](explanation/architecture.md) | Why this stack, how the pipeline works, design decisions |
| [Technical Specification](explanation/SPECIFICATION.md) | Full technical specification for the aac-forge pipeline |

---

## Quick Navigation by Task

| I want to... | Go to |
| --- | --- |
| See diagrams in my browser | [Quick Start → Step 3](tutorials/quick-start.md) |
| Add a new system to the model | [Add a New Domain](how-to/add-new-domain.md) |
| Generate a SAD from a BR | [Create a New Solution](how-to/create-new-solution.md) |
| Follow the full ADR process | [ADR Process Walkthrough](tutorials/adr-process-walkthrough.md) |
| Export PNG diagrams | [Run and Preview → Export Diagrams](how-to/run-and-preview.md) |
| Understand the DSL syntax | [DSL Conventions](reference/dsl-conventions.md) |
| Understand diagram shape/color conventions | [Visual Notation](reference/visual-notation.md) |
| Know what CLI commands are available | [CLI Commands](reference/cli-commands.md) |
| Understand why we chose LikeC4 | [Pipeline Architecture](explanation/architecture.md) |
