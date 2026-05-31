# Architecture Decision Records

This directory contains Architecture Decision Records (ADRs) for the aac-forge
repository and tooling itself — not for the solutions built with it.

Solution-specific ADRs live in `<solution>/decisions/`.

## Numbering

Repo ADRs use global sequential numbering: `ADR-0001`, `ADR-0002`, etc.

## Status Lifecycle

```
Proposed → Accepted → Superseded
Proposed → Rejected
```

## Creating a New ADR

1. Copy `templates/ADR-template.md`
2. Name it `ADR-NNNN-slug.md` (use the next available number)
3. Fill all sections, set `status: Proposed`
4. Open a PR for review
5. After approval, stamp `status: Accepted` with approver details

## Index

| ADR | Title | Status | Date |
| --- | --- | --- | --- |
| [ADR-0001](ADR-0001-use-likec4-over-structurizr.md) | Use LikeC4 over Structurizr DSL | Accepted | 2025-05-31 |
