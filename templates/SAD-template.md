---
solution: "NNN"
title: "Solution Title"
status: "Draft"
author: ""
reviewer: ""
date: ""
revision: 1
adrs: []
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
    date: ""
    author: ""
    changes: "Initial draft — skeleton with open decisions"
  - rev: 2
    date: ""
    author: ""
    changes: "Full SAD — model built, diagrams embedded, ADRs referenced"
---

# SAD Solution Title

# 1. General Project/Task Information

## 1.1 Glossary

| Term | Description |
| --- | --- |
| ... | ... |

## 1.2 Project/Task Description

<!-- Goals, customer, consumers, constraints — from BR documents -->

# 2. Business Architecture and Requirements

[BR Document Name](../input/BR%20Document.md)

# 3. Architecture Solution Description

## 3.1 Proposed Solution Description

<!-- Textual description of the solution -->

**List of systems and IT services used:**

| System/Service | Description | CMDB Link |
| --- | --- | --- |
| ... | ... | |

<!-- Description of microservices and components -->

## 3.2 Information Architecture

### Data Flow Diagram

![Data Flow Diagram](solution_NNN_dataflow.png)

<details>
<summary>Mermaid source (for editing)</summary>

```mermaid
C4Context
  ...
```
</details>

**Data flow description:**

| Code | Data Object | Source | Consumer | Type | Status | Mode | Data | Protocol | Transport | Comment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| INF01 | ... | ... | ... | ... | New | Synchronous | ... | REST/HTTPS | HTTP | |

## 3.3 System Architecture

### Container Diagram

![Container Diagram](solution_NNN_containers.png)

<details>
<summary>Mermaid source (for editing)</summary>

```mermaid
C4Container
  ...
```
</details>

# 4. Implementation

## 4.1 Implementation Requirements

- ...

## 4.2 System and IT Service Modifications

| System/Service | Work Description |
| --- | --- |
| ... | ... |

# 5. Information Security

## 5.1 Authentication and Authorization

| Purpose | Consumer System | Account Type | Status | Role | Role Status | Credential Storage | Data Flows |
| --- | --- | --- | --- | --- | --- | --- | --- |
| ... | ... | Service | New | ... | New | Vault | ... |

## 5.2 Logging and Audit

<!-- Logging requirements from input documents -->

## 5.3 External Data Access

<!-- Description or "Not required" -->

## 5.4 System and IT Service Publishing

| System/Service | Location |
| --- | --- |
| ... | ... |

## 5.5 Flows with Protected Information

<!-- Description of protected data in flows -->

## 5.6 File Exchange with External Systems

<!-- Description or "Not required" -->

# 6. Support Information

| System/Service | Development Contact | Support Team | Criticality | Technology Stack |
| --- | --- | --- | --- | --- |
| ... | | | | ... |

# 7. Non-Functional Requirements

| Metric | Value |
| --- | --- |
| ... | ... |

# 8. Architecture Decisions

<!--
  Rev 1 (skeleton): list open decisions with ADR IDs as "proposed."
  Rev 2 (full): reference Accepted ADRs by ID with a one-line summary.
-->

| ADR | Title | Status | Summary |
| --- | --- | --- | --- |
| ADR-NNN-NNNN | ... | Proposed | ... |

# 9. Traceability Matrix

| BR Requirement | SAD Section | Implementation |
| --- | --- | --- |
| ... | ... | ... |

# 10. Open Decisions

<!--
  Rev 1 (skeleton): decisions that need architecture review.
  Rev 2 (full): all resolved — remove section or mark as "all decisions accepted."
-->

1. ...

# 11. Open Questions

<!--
  Questions that are not architectural decisions — clarification needed
  from stakeholders, BR gaps, deferred features.
-->

1. ...
