---
solution: "001"
title: "Automated Order Fulfillment"
status: "Draft"
author: "A. Architect"
reviewer: ""
date: "2025-05-31"
revision: 1
approvals:
  - role: "Solution Architect"
    name: ""
    date: ""
  - role: "Enterprise Architect"
    name: ""
    date: ""
  - role: "Security Specialist"
    name: ""
    date: ""
  - role: "Business Process Owner"
    name: ""
    date: ""
changelog:
  - rev: 1
    date: "2025-05-31"
    author: "A. Architect"
    changes: "Initial draft — Fulfillment Engine design and integration"
---

# SAD Automated Order Fulfillment

# 1. General Project/Task Information

## 1.1 Glossary

| Term | Description |
| --- | --- |
| Order Fulfillment | End-to-end process from order confirmation to shipment dispatch |
| Picklist | Warehouse document listing items, quantities, and locations for order picking |
| Fulfillment Engine | New system orchestrating the automated fulfillment workflow |
| Fulfillment API | REST API for fulfillment trigger, status queries, and exception management |
| Picklist Generator | Component that creates optimized picklists with warehouse routing |
| Order Management | Existing core system — order lifecycle, status tracking |
| Inventory | Existing system — stock levels, warehouse locations, SKU catalog |
| Pricing | Existing system — real-time price calculation and discount rules |
| Payment Gateway | External — card authorization, capture, refund |
| Shipping Provider | External — rate calculation, label generation, tracking |
| Notification Service | Multi-channel customer notifications — email, SMS, push |
| Message Bus | Enterprise event backbone — Kafka |

## 1.2 Project/Task Description

**Goals:**
- Reduce order-to-ship time from 4 hours to under 30 minutes
- Eliminate manual picklist creation and shipping label generation
- Provide real-time fulfillment status visibility to customers and support agents
- Support 5,000 orders/day with peak capacity of 500 orders/hour
- Reduce fulfillment errors by 90% through automated validation

**Commissioned by:** Operations Department

**Consumers:** Warehouse staff, Customers, Support agents, Operations managers

**Constraints:**
- Must integrate with existing Order Management, Inventory, and Shipping Provider
- Order Management is system of record for order status
- Read-only access to Inventory
- Shipping Provider rate limit: 100 requests/min
- Fulfillment Engine in primary data center
- PII must not be logged
- All inter-service communication authenticated

# 2. Business Architecture and Requirements

[BR Automated Order Fulfillment](../input/BR%20Automated%20Order%20Fulfillment.md)

# 3. Architecture Solution Description

## 3.1 Proposed Solution Description

The solution introduces the **Fulfillment Engine** — a new system that automates the order fulfillment workflow end-to-end.

**Components:**

1. **Fulfillment API** (Go) — REST API receiving fulfillment triggers from Order Worker, exposing status endpoints for customer and support queries, and orchestrating the fulfillment pipeline.

2. **Picklist Generator** (Python) — gRPC service that generates optimized warehouse picklists. Reads stock locations from Inventory API, computes shortest-path pick routes by warehouse zone, and handles multi-warehouse order splitting.

3. **Fulfillment Database** (PostgreSQL) — Stores fulfillment state, picklist history, shipment tracking numbers, and audit log.

**Fulfillment flow:**

1. Order Worker sends confirmed order to Fulfillment API (INF01)
2. Fulfillment API validates the request and creates a fulfillment record
3. Fulfillment API invokes Picklist Generator (gRPC) with line items
4. Picklist Generator queries Inventory API for stock locations (INF04)
5. Picklist Generator returns optimized picklist (INF02)
6. Fulfillment API queries Shipping Provider for rates and generates label
7. Fulfillment API sends shipment notification via Notification Service (Kafka)
8. Fulfillment API reports status back to Order Management

**Existing systems — modifications:**

| System | Change |
| --- | --- |
| Order Management — Order Worker | Add fulfillment trigger on "Confirmed" status |
| Inventory — Inventory API | No changes (read-only access for fulfillment) |
| Notification Service | No changes (consumes from Kafka topic) |

**List of systems and IT services used:**

| System/Service | Description | CMDB Link |
| --- | --- | --- |
| Fulfillment Engine | New — orchestrates automated fulfillment | |
| Fulfillment API | REST API for fulfillment operations | |
| Picklist Generator | Warehouse picklist generation and optimization | |
| Fulfillment Database | Fulfillment state and history | |
| Order Management | Existing — order lifecycle | |
| Inventory | Existing — stock and warehouse data | |
| Shipping Provider | External — rates, labels, tracking | |
| Notification Service | Customer notifications | |
| Message Bus | Kafka event backbone | |

## 3.2 Information Architecture

### Data Flow Diagram

<!-- Exported from LikeC4 model -->

**Data flow description:**

| Code | Data Object | Source | Consumer | Type | Status | Mode | Data | Protocol | Transport | Comment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| INF01 | Order ready for fulfillment | Order Worker | Fulfillment API | Internal | New | Asynchronous | Order ID, line items, shipping address, customer info | REST/HTTPS | HTTP | Triggered on order confirmation |
| INF02 | Generated picklist | Picklist Generator | Fulfillment API | Internal | New | Synchronous | SKU, quantity, zone, shelf, pick route | gRPC | TCP | Optimized pick route |
| INF03 | Fulfillment state | Fulfillment DB | Fulfillment API | Internal | New | Synchronous | Status, timestamps, tracking numbers | TCP | PostgreSQL | Query and update |
| INF04 | Stock locations and quantities | Inventory API | Picklist Generator | Internal | Existing | Synchronous | Warehouse zone, shelf, available quantity | REST/HTTPS | HTTP | Read-only access |
| INF05 | Shipping rates and labels | Shipping Provider | Fulfillment API | External | New | Synchronous | Rate options, label PDF, tracking number | REST/HTTPS | HTTP | Rate-limited: 100 req/min |
| INF06 | Shipment notification | Fulfillment API | Notification Service | Internal | New | Asynchronous | Tracking number, carrier, ETA | Kafka | TCP | Triggers email/SMS to customer |
| INF07 | Fulfillment status update | Fulfillment API | Order API | Internal | New | Synchronous | Order ID, fulfillment status, tracking | REST/HTTPS | HTTP | Updates Order Management |
| INF08 | Fulfillment events | Fulfillment API | Message Bus | Internal | New | Asynchronous | Event type, order ID, timestamp, payload | Kafka | TCP | For downstream consumers |

## 3.3 System Architecture

### Container Diagram

<!-- Exported from LikeC4 model -->

# 4. Implementation

## 4.1 Implementation Requirements

- Deploy Fulfillment Engine (API + Picklist Generator + DB) in primary data center
- Provision PostgreSQL instance for Fulfillment Database
- Configure Order Worker to emit fulfillment trigger on order confirmation
- Register Fulfillment API in service mesh for mTLS
- Provision Shipping Provider API credentials in Vault
- Create Kafka topics: `fulfillment.events`, `notification.requests`
- Configure Prometheus alerts for fulfillment SLA breaches
- Build Operations dashboard for real-time fulfillment monitoring

## 4.2 System and IT Service Modifications

| System/Service | Work Description |
| --- | --- |
| Fulfillment Engine | New deployment — 3 components (API, Picklist Generator, DB) |
| Order Management | Add fulfillment trigger in Order Worker on "Confirmed" status |
| Message Bus | Create `fulfillment.events` topic |
| Notification Service | Subscribe to `fulfillment.events` for shipment notifications |
| Monitoring | Add Fulfillment Engine to Prometheus/Grafana dashboards |

# 5. Information Security

## 5.1 Authentication and Authorization

| Purpose | Consumer System | Account Type | Status | Role | Role Status | Credential Storage | Data Flows |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Trigger fulfillment | Order Worker | Service | New | Execution | New | Vault | INF01 |
| Query stock locations | Picklist Generator | Service | Existing | Read-only | Existing | Vault | INF04 |
| Get shipping rates/labels | Fulfillment API | Service | New | Execution | New | Vault | INF05 |
| Send notifications | Fulfillment API | Service | New | Write | New | Vault | INF06 |
| Update order status | Fulfillment API | Service | New | Read-Write | New | Vault | INF07 |

## 5.2 Logging and Audit

- All Fulfillment API requests logged with correlation ID
- PII (customer name, address, phone, email) masked in logs
- Fulfillment state transitions audited with timestamp and actor
- Picklist generation events logged (order ID, item count, warehouse)
- Shipping Provider API calls logged (endpoint, latency, status)
- Logs shipped to centralized logging platform, retained 90 days

## 5.3 External Data Access

- **Shipping Provider** — API key stored in Vault, calls authenticated via HTTPS + API key header
- No customer PII sent to Shipping Provider beyond what's required for label generation
- All external calls logged and monitored for rate limit compliance

## 5.4 System and IT Service Publishing

| System/Service | Location |
| --- | --- |
| Fulfillment API | Primary Data Center |
| Picklist Generator | Primary Data Center |
| Fulfillment Database | Primary Data Center |

## 5.5 Flows with Protected Information

- INF01 contains customer PII (name, address, phone) — transmitted over mTLS, masked in logs
- INF06 contains tracking number and customer contact — customer PII masked in notification payload

## 5.6 File Exchange with External Systems

- Not required. All integrations are API-based.

# 6. Support Information

| System/Service | Development Contact | Support Team | Criticality | Technology Stack |
| --- | --- | --- | --- | --- |
| Fulfillment API | | Fulfillment Team | High | Go 1.22 |
| Picklist Generator | | Fulfillment Team | High | Python 3.12 |
| Fulfillment Database | | DBA Team | High | PostgreSQL 16 |

# 7. Non-Functional Requirements

| Metric | Value |
| --- | --- |
| Fulfillment API latency (p95) | < 500ms for status queries |
| Picklist generation time | < 2s for ≤50 line items |
| Peak throughput | 500 orders/hour |
| Sustained throughput | 5,000 orders/day |
| Availability | 99.9% |
| Shipping Provider retry | 3 attempts, exponential backoff |
| Data retention (online) | Fulfillment records 1 year, picklists 90 days |
| Data retention (archive) | 7 years |

# 8. Traceability Matrix

| BR Requirement | SAD Section | Implementation |
| --- | --- | --- |
| FR-01 Receive fulfillment request | 3.1 | Fulfillment API — POST /fulfillments endpoint |
| FR-02 Validate request | 3.1 | Fulfillment API — schema + business rule validation middleware |
| FR-03 Return fulfillment status | 3.1 | Fulfillment API — GET /fulfillments/{id} |
| FR-04 Support cancellation | 3.1 | Fulfillment API — POST /fulfillments/{id}/cancel |
| FR-05 Status for customer/support | 3.1 | Fulfillment API — public + internal status endpoints |
| FR-06 Generate picklist | 3.1 | Picklist Generator — generatePicklist(order) |
| FR-07 Optimize pick route | 3.1 | Picklist Generator — zone-based shortest path algorithm |
| FR-08 Multi-warehouse orders | 3.1 | Picklist Generator — split by warehouse, one picklist per zone |
| FR-09 Picklist re-generation | 3.1 | Picklist Generator — regenerate on stock location change event |
| FR-10 Query shipping rates | 3.1 | Fulfillment API → Shipping Provider integration |
| FR-11 Select optimal shipping | 3.1 | Fulfillment API — rule engine (cost, speed, preference) |
| FR-12 Generate shipping label | 3.1 | Fulfillment API → Shipping Provider label generation |
| FR-13 Shipping error retry | 3.1 | Fulfillment API — retry queue with exponential backoff |
| FR-14 Shipment confirmation | 3.1, INF06 | Fulfillment API → Notification Service (Kafka) |
| FR-15 Exception alerts | 3.1 | Fulfillment API — exception events to Operations topic |
| FR-16 Daily summary | 3.1 | Separate reporting job (out of scope for initial phase) |

# 9. Open Questions

1. Should the Fulfillment Engine support partial fulfillment (split shipments) in v1, or defer to v2?
2. What are the specific business rules for shipping method selection (cost threshold, speed preference, carrier contracts)?
3. Should picklists be printed automatically in the warehouse, or accessed via tablet/mobile?
4. What is the rollback strategy if Shipping Provider is unavailable for > 30 minutes?
5. Do we need a manual override UI for Operations to adjust picklists or shipping methods?
