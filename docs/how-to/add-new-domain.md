# How to Add a New Domain

A **domain** is a group of related systems within your architecture. Adding one means creating a new `.c4` file in `model/domains/`.

## 1. Create the Domain File

Create `model/domains/<domain-name>.c4`:

```ts
// model/domains/payment.c4

model {
  // === Payment Processing ===
  paymentSystem = system 'Payment Processing' {
    description 'Handles payment authorization and capture'

    paymentApi = container 'Payment API' 'REST API for payment operations' 'Go'
    paymentDb = container 'Payment Database' 'Transaction ledger' 'PostgreSQL'
    fraudDetector = container 'Fraud Detector' 'Real-time fraud scoring' 'Python'
  }

  // === Relationships — within the domain ===
  paymentApi -> paymentDb 'Stores transactions' 'TCP'
  paymentApi -> fraudDetector 'Requests fraud score' 'gRPC'

  // === Relationships — cross-domain ===
  // Reference systems from other domains by their ID
  paymentApi -> orderSystem.orderApi 'Confirms payment for orders' 'REST/HTTPS'
  paymentApi -> notificationService 'Sends payment receipts' 'Kafka'
}

// Views for this domain
views {
  view paymentContainers {
    include
      paymentSystem.*,
      -> paymentSystem.* ->
  }
}
```

## 2. Element Kinds

Check `model/workspace.c4` — the `specification` block defines available element kinds:

```ts
specification {
  element person
  element system
  element container
}
```

If you need a new kind (e.g., `database`, `queue`, `mobileApp`), add it to the `specification` block in `workspace.c4`. All domain files share the same specification.

## 3. Naming Conventions

| Thing | Convention | Example |
| --- | --- | --- |
| System IDs | PascalCase | `paymentSystem`, `orderManagement` |
| Container IDs | camelCase | `paymentApi`, `fraudDetector` |
| Element titles | Human-readable sentence case | `'Payment Processing'`, `'Fraud Detector'` |
| Container IDs are **globally unique** — you don't need to prefix them with the system name. |

## 4. Adding Relationships

**Within a domain** — reference containers by their bare ID:
```ts
paymentApi -> fraudDetector 'Requests fraud score' 'gRPC'
```

**Across domains** — reference containers by their bare ID (they're globally unique):
```ts
paymentApi -> orderApi 'Confirms payment' 'REST/HTTPS'
```

**Person → System** — reference by the system's ID:
```ts
customer -> paymentSystem 'Enters payment details' 'HTTPS'
```

**Protocols** — always specify one:
```
'REST/HTTPS', 'gRPC', 'TCP', 'Kafka', 'AMQP', 'MCP/HTTPS', 'HTTPS', 'GraphQL'
```

## 5. Adding Views

Views go in the same file as the model. Common patterns:

```ts
views {
  // System context — who interacts with this system?
  view paymentSystemContext {
    include
      paymentSystem,
      -> paymentSystem ->
  }

  // Container view — what's inside?
  view paymentContainers {
    include
      paymentSystem.*,
      -> paymentSystem.* ->
  }

  // Consolidated solution view — multiple systems together
  view checkoutFlow {
    include
      paymentSystem.*,
      orderSystem.*,
      -> paymentSystem.* ->,
      -> orderSystem.* ->
  }
}
```

## 6. Validate

```bash
npx likec4 validate model/
```

Fix any errors before continuing.

## 7. Preview

Start the dev server to see your new domain in the browser:

```bash
npx likec4 start model/
```

Your new views appear in the sidebar alongside existing ones.

## Example: Real-World Domain File

See `examples/order-management/model/domains/core-services.c4` for a complete example with 4 systems, 7 containers, relationships, data flows, and views.
