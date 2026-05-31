# Visual Notation Conventions

This page defines how aac-forge uses LikeC4 visual styling. The purpose is to make
architecture diagrams easier to read, not more decorative.

Use this convention for generated solution views, SAD diagrams, and architecture review.

## Rationale

This is a lightweight enterprise visual notation for LikeC4. It is compatible with C4
principles and inspired by ArchiMate and cloud architecture diagram conventions, but it
is intentionally repo-local and decision-aware rather than a formal standard palette.

The convention aligns with:

- C4 and LikeC4 practice: people, systems, containers, relationships, and scoped views
  remain the primary modeling concepts.
- ArchiMate-style thinking: visual differences help readers distinguish business
  actors, application capabilities, data stores, technology/platform capabilities, and
  external actors.
- Cloud architecture diagrams: storage, database, queue, browser, and vendor icons are
  useful when they clarify known technology or infrastructure roles.
- Enterprise architecture review practice: color should communicate ownership, status,
  risk, scope, sensitivity, or lifecycle meaning rather than arbitrary decoration.

The convention deliberately does not copy a strict ArchiMate or cloud-provider palette.
C4 does not prescribe fixed colors, and provider-specific palettes can imply technology
decisions too early. The goal is consistent, readable architecture communication while
keeping the BR -> ADR -> SAD decision process in control of actual technology choices.

## Principles

- Shapes communicate the element's role.
- Colors communicate ownership zone, sensitivity, or lifecycle status.
- Borders communicate certainty or inclusion status.
- Relationship line style communicates flow semantics.
- Icons clarify a decided technology; they must not create an implied technology
  decision before a BR, ADR, or SAD has made that decision.
- If a style does not carry architecture meaning, do not add it.

## Element Shapes

| Shape | Use for |
| --- | --- |
| `person` | Business users, operators, external actors |
| `browser` | Web UIs and browser-based applications |
| `mobile` | Mobile apps |
| `component` | Application services, processors, workers |
| `cylinder` | Databases, warehouses, analytical datasets |
| `storage` | Persistent stores when cylinder is not specific enough |
| `bucket` | Object storage, file landing zones, data lake buckets |
| `queue` | Event topics, brokers, queues, publishers |
| `document` | Reports, documents, generated files |
| `rectangle` | Generic systems or elements without a clearer role |

Use shapes on normal `person`, `system`, or `container` elements. Do not introduce new
element kinds such as `database` or `queue` just to change visual appearance.

## Element Colors

| Color | Meaning |
| --- | --- |
| `primary` / `blue` | Solution-owned application components |
| `secondary` / `indigo` | Shared platform, foundation, or enterprise capabilities |
| `sky` | Data products, datasets, analytics surfaces |
| `green` | Approved publication paths, consumer-facing outputs, accepted/available capabilities |
| `amber` | External dependency, assumption, pending decision, or elevated operational attention |
| `red` | Restricted, security-sensitive, exceptional, or high-risk control point |
| `gray` / `muted` | Background, future, out-of-scope, deprecated, or low-emphasis element |

Use only a small number of colors in one view. Prefer 2-4 meaningful colors over a
full palette.

## Borders

| Border | Meaning |
| --- | --- |
| `solid` | In scope, approved, or current-state element |
| `dashed` | Boundary, planned element, or assumption-driven element |
| `dotted` | Optional, future candidate, or exploratory element |
| `none` | Abstract actor/consumer group that should not dominate the diagram |

Boundaries may use dashed borders when they represent deployment, country, platform,
trust, or ownership boundaries.

## Relationships

| Relationship style | Meaning |
| --- | --- |
| `line solid` | Primary runtime, data, or user flow |
| `line dashed` | Supporting, control, audit, dependency, or non-primary flow |
| `color green` | Approved publication or consumer access path |
| `color amber` | External dependency, pending decision, retry/error-prone flow, or assumption |
| `color red` | Restricted, privileged, break-glass, exceptional, or high-risk flow |
| `color gray` | Background or low-emphasis flow |

Do not color every relationship. Use relationship color only when the distinction helps
an architect answer a question quickly.

## Example

```ts
specification {
  element person {
    style {
      shape person
      color green
    }
  }
  element system
  element container
}

model {
  dataSteward = person 'Data Steward'

  propertyPlatform = system 'Property Intelligence Platform' {
    stewardshipUi = container 'Stewardship UI' 'Steward review application' 'Web' {
      style {
        shape browser
        color primary
        border solid
      }
    }

    propertyStore = container 'Property Master Store' 'Country-local canonical records' 'To be decided' {
      style {
        shape cylinder
        color sky
        border solid
      }
    }

    eventPublisher = container 'Event Publisher' 'Publishes governed lifecycle events' 'To be decided' {
      style {
        shape queue
        color primary
        border solid
      }
    }
  }

  dataSteward -> stewardshipUi 'Reviews and approves changes' 'HTTPS' {
    style {
      color green
      line solid
    }
  }

  stewardshipUi -> propertyStore 'Writes approved decisions' 'TCP' {
    style {
      color amber
      line dashed
    }
  }
}
```

## Review Checklist

- Can a reader distinguish people, UIs, services, stores, events, and documents without
  reading every label?
- Do colors map to ownership zone, sensitivity, lifecycle status, or publication path?
- Are borders used consistently for current, planned, future, abstract, or boundary
  elements?
- Are sensitive, exceptional, or external flows visible without overwhelming normal
  flows?
- Are vendor icons used only where the technology decision is already approved or
  explicitly assumed?
- Would the diagram still be understandable if printed in grayscale? If not, add or
  improve labels rather than relying only on color.

## Export Notes

The LikeC4 browser and PNG export are the authoritative visual rendering. Mermaid export
maps LikeC4 shapes approximately, and generic services may still appear as Mermaid
rectangles.
