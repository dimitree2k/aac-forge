# LikeC4 DSL Conventions

Reference for the LikeC4 DSL syntax used in `*.c4` files.

## File Structure

All `*.c4` files in a directory tree are **auto-discovered and merged** by LikeC4. There must be exactly **one** `specification` block and exactly **one** `views` block across all files in a workspace.

```
model/
├── workspace.c4       # specification { } + views { }
├── common.c4          # model { } — shared actors & external systems
└── domains/
    ├── domain-a.c4    # model { } — domain elements
    └── domain-b.c4    # model { } — domain elements
```

## Specification Block

Defines element kinds, relationship kinds, and tags available in this workspace:

```ts
specification {
  element person {     // actors
    style {
      shape person
    }
  }
  element system       // software systems
  element container    // containers inside systems
}
```

All domain files share this specification. Add new kinds here when needed.

## Semantic Shapes and Icons

Use LikeC4 shapes to make diagrams readable. Do not create new element kinds just to
change visual appearance; prefer `style { shape ... }` on the existing `person`,
`system`, or `container`.

For the full shape, color, border, icon, and relationship styling convention, see
[Visual Notation](visual-notation.md).

Common shapes available in LikeC4:

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

```ts
propertyStore = container 'Property Master Store' 'Country-local canonical records' 'PostgreSQL' {
  style {
    shape cylinder
    icon tech:postgresql
  }
}

stewardshipUi = container 'Stewardship UI' 'Steward review application' 'Web' {
  style {
    shape browser
  }
}

eventPublisher = container 'Event Publisher' 'Publishes lifecycle events' 'Kafka' {
  style {
    shape queue
  }
}
```

Use technology/vendor icons only when the technology is decided or explicitly assumed
by the BR/ADR/SAD. An icon should clarify a decision, not create one silently.

## Model Block — Elements

### Person (Actor)

```ts
rangers = person 'Rangers of the North' {
  description 'Dúnedain who guard the wilds'
}
```

### System

```ts
orderSystem = system 'Order Management' {
  description 'Core order processing system'
}
```

### System with Nested Containers

```ts
orderSystem = system 'Order Management' {
  description 'Core order processing'

  orderApi = container 'Order API' 'REST API for order operations' 'Go'
  orderDb = container 'Order Database' 'Persistent order storage' 'PostgreSQL' {
    style {
      shape cylinder
      icon tech:postgresql
    }
  }
  orderWorker = container 'Order Worker' 'Async order processor' 'Go'
}
```

Container syntax: `id = container 'Title' 'Summary' 'Technology'`

| Argument | Required | Example |
| --- | --- | --- |
| Title | Yes | `'Order API'` |
| Summary | Yes | `'REST API for order operations'` |
| Technology | No | `'Go'`, `'PostgreSQL'`, `'Kafka'` |

## Model Block — Relationships

### Basic Syntax

```ts
source -> target 'Description' 'Protocol'
```

### Person → System

```ts
customer -> orderSystem 'Places orders' 'HTTPS'
```

### System → System

```ts
orderSystem -> paymentGateway 'Processes payment' 'REST/HTTPS'
```

### Container → System

```ts
orderApi -> paymentGateway 'Authorizes payment' 'REST/HTTPS'
```

Container IDs are **globally unique** — no need to prefix with the parent system.

### Container → Container (Same System)

```ts
orderApi -> orderDb 'Reads and writes orders' 'TCP'
```

### Container → Container (Cross-System)

```ts
fulfillmentApi -> orderApi 'Updates order status' 'REST/HTTPS'
```

### Rules

- **Parent→child** (system→its own container) relationships are **implicit** — don't declare them
- Always specify a **protocol**
- Description should be a short action phrase

## Protocols

| Protocol | Use for |
| --- | --- |
| `'REST/HTTPS'` | Synchronous HTTP APIs |
| `'gRPC'` | High-performance internal services |
| `'TCP'` | Database connections, raw sockets |
| `'Kafka'` | Async event streaming |
| `'AMQP'` | Message queues (RabbitMQ) |
| `'MCP/HTTPS'` | MCP tool protocol |
| `'HTTPS'` | Simple HTTP (no REST semantics) |
| `'GraphQL'` | GraphQL APIs |
| `'SMTP/HTTP'` | Email delivery |

## Data Flows (INF Codes)

Data flows are modeled as relationships with INFxx codes in the title:

```ts
orderApi -> orderWorker 'INF01. Order events for processing' 'Kafka'
inventoryApi -> orderWorker 'INF02. Stock reservation confirmation' 'REST/HTTPS'
```

- Number sequentially within each system/domain
- The INF code prefix (`INF01.`) is part of the relationship title
- Data flows appear alongside regular relationships — filter by title pattern for data-flow-specific views

## Views

Views are defined in the `views { }` block (shared across all files):

```ts
views {
  // System context — a system and its direct relationships
  view orderSystemContext {
    include
      orderSystem,
      -> orderSystem ->
  }

  // Container view — all containers inside a system
  view orderContainers {
    include
      orderSystem.*,
      -> orderSystem.* ->
  }

  // Consolidated view — containers from multiple systems
  view checkoutFlow {
    include
      orderSystem.*,
      paymentSystem.*,
      -> orderSystem.* ->,
      -> paymentSystem.* ->
  }
}
```

| Pattern | Meaning |
| --- | --- |
| `include *` | Everything |
| `include systemName` | That system and its direct relationships |
| `include systemName.*` | All containers inside that system |
| `include -> systemName ->` | Relationships to/from that system |
| `include -> systemName.* ->` | Container-level relationships |

## View Hygiene

LikeC4 auto-discovers and merges all `*.c4` files in a workspace. Broad root views can
therefore pull unrelated domains, examples, or stale sample elements into solution
deliverables.

For solution packages:

- Prefer solution-scoped views with explicit `include` rules.
- Avoid generic root views such as `view landscape { include * }` unless the view is an
  intentionally curated portfolio/workspace view.
- Use human-readable view IDs/names that make sense in the LikeC4 UI and exported files.
- Export SAD deliverables with `-f <viewId>` filters.
- Treat generated `index.*` and generic workspace overview files as app navigation
  artifacts, not solution deliverables, unless they are intentionally curated and
  referenced by the SAD.
- Keep root/common model files free of sample or demo-domain elements.

For portfolio views, explicitly include the portfolio elements or domains that belong in
the view instead of relying on `include *`.
