# BR Automated Order Fulfillment

# 1. General Project Information

## 1.1 Glossary

| Term | Description |
| --- | --- |
| Order Fulfillment | End-to-end process from order confirmation to shipment dispatch |
| Picklist | Warehouse document listing items, quantities, and locations for order picking |
| Fulfillment Engine | New system orchestrating the fulfillment workflow |
| Picklist Generator | Component that creates optimized picklists from order line items |
| Order Management | Existing core system handling order lifecycle |
| Inventory | Existing system managing stock levels and warehouse locations |
| Shipping Provider | External carrier service for rate calculation, label generation, and tracking |
| SKU | Stock Keeping Unit — unique product identifier |
| SLA | Service Level Agreement — response time and availability commitments |

## 1.2 Project Description

The project aims to automate the order fulfillment process, which currently requires manual intervention at multiple stages: picklist creation, warehouse routing, shipping selection, and customer notification.

**Goals:**
- Reduce order-to-ship time from 4 hours to under 30 minutes
- Eliminate manual picklist creation and shipping label generation
- Provide real-time fulfillment status visibility to customers and support agents
- Support 5,000 orders/day with peak capacity of 500 orders/hour
- Reduce fulfillment errors by 90% through automated validation

**Commissioned by:** Operations Department

**Consumers:**
- Warehouse staff (picklist execution)
- Customers (shipment tracking and notifications)
- Support agents (fulfillment status lookups)
- Operations managers (fulfillment analytics and SLA monitoring)

**Interested parties:**
- Logistics team
- Customer Experience team
- Finance (shipping cost optimization)

## 1.3 Constraints

- Must integrate with existing Order Management, Inventory, and Shipping Provider systems
- Order Management remains the system of record for order status
- No changes to the Inventory data model — read-only access for fulfillment
- Shipping Provider API has rate limits: 100 requests/min
- Fulfillment Engine must be deployed in the primary data center
- PII (customer name, address, phone) must not be logged
- All inter-service communication must be authenticated

# 2. Business Requirements

## 2.1 Automated Fulfillment Workflow

When an order transitions to "Confirmed" status in Order Management, the Fulfillment Engine must:

1. **Receive fulfillment trigger** — Order Worker sends confirmed order with line items to Fulfillment API
2. **Validate inventory** — Check current stock levels via Inventory API for each line item
3. **Generate picklist** — Picklist Generator creates optimized picklist with warehouse locations and pick routes
4. **Request shipping rates** — Query Shipping Provider for available rates based on package dimensions, weight, and destination
5. **Select optimal shipping** — Apply business rules (cost, speed, customer preference) to select shipping method
6. **Generate shipping label** — Request label from Shipping Provider
7. **Notify customer** — Send shipment confirmation with tracking number via Notification Service
8. **Update order status** — Report fulfillment status back to Order Management

## 2.2 Exception Handling

- **Out of stock:** If stock is insufficient, move order to "Awaiting Stock" status and notify Operations
- **Shipping failure:** Retry 3 times with exponential backoff; escalate to manual review after final failure
- **Partial fulfillment:** Support splitting orders into multiple shipments when items are in different warehouses
- **Cancellation during fulfillment:** Check fulfillment stage and abort if not yet shipped; initiate return if already shipped

## 2.3 Monitoring and Reporting

- Real-time dashboard showing orders in each fulfillment stage
- SLA tracking: time from confirmation to shipment
- Error rate monitoring by failure type (stock, shipping, validation)
- Daily fulfillment volume reports

# 3. Functional Requirements

## 3.1 Fulfillment API

- FR-01: Receive fulfillment request with order ID, line items, shipping address
- FR-02: Validate request schema and business rules (non-empty items, valid address)
- FR-03: Return fulfillment status (pending, picking, packing, shipped, delivered, exception)
- FR-04: Support order cancellation during fulfillment
- FR-05: Expose fulfillment status for customer and support agent queries

## 3.2 Picklist Generation

- FR-06: Generate picklist from order line items with SKU, quantity, warehouse zone, shelf location
- FR-07: Optimize pick route by warehouse zone (shortest path)
- FR-08: Handle multi-warehouse orders (one picklist per warehouse)
- FR-09: Support picklist re-generation on stock location changes

## 3.3 Shipping Integration

- FR-10: Query available shipping rates from Shipping Provider
- FR-11: Select optimal shipping method based on configured rules
- FR-12: Generate shipping label and tracking number
- FR-13: Handle shipping provider errors with retry logic

## 3.4 Notification

- FR-14: Send shipment confirmation to customer (email + optional SMS)
- FR-15: Send fulfillment exception alerts to Operations team
- FR-16: Send daily fulfillment summary to Operations managers

# 4. Non-Functional Requirements

## 4.1 Performance

- Fulfillment API: p95 latency < 500ms for status queries
- Picklist generation: < 2 seconds for orders up to 50 line items
- Throughput: 500 orders/hour peak, 5,000 orders/day sustained

## 4.2 Availability

- Fulfillment Engine: 99.9% uptime (primary data center)
- Graceful degradation: if Shipping Provider is down, queue for retry without blocking other orders

## 4.3 Security

- All service-to-service calls authenticated via mutual TLS
- Secrets stored in Vault (Shipping Provider API key, DB credentials)
- PII masking in logs (customer name, address, phone, email)
- Audit log of all fulfillment state transitions

## 4.4 Data Retention

- Fulfillment records: 1 year online, 7 years archive
- Picklist data: 90 days online
- Shipping labels: generated on-demand, not stored

# 5. Integration Requirements

| From | To | Protocol | Purpose |
| --- | --- | --- | --- |
| Order Worker | Fulfillment API | REST/HTTPS | Trigger fulfillment on order confirmation |
| Fulfillment API | Inventory API | REST/HTTPS | Validate stock and read warehouse locations |
| Picklist Generator | Inventory API | REST/HTTPS | Read stock locations for pick routing |
| Fulfillment API | Shipping Provider | REST/HTTPS | Rates, label generation, tracking |
| Fulfillment API | Notification Service | Kafka | Customer shipment notifications |
| Fulfillment API | Order API | REST/HTTPS | Update order fulfillment status |
| Fulfillment API | Message Bus | Kafka | Publish fulfillment events |
