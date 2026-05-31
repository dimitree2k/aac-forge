# Multi-Project Architecture Approach

**Status:** Draft intent  
**Date:** 2026-05-31  
**Scope:** exploratory proposal for future implementation  
**Related spec:** [ADR-process.md](ADR-process.md)

## Purpose

This document captures an initial intent for using aac-forge across several related
projects, teams, and platform capabilities.

The goal is to create a clear picture of how shared platform work, product applications,
requirements ownership, and architecture decisions fit together without turning the first
model into a large, hard-to-approve design.

This is not an implementation plan. Stakeholders, technologies, ownership boundaries, and
delivery sequencing are not complete yet. The document is deliberately written as a
proposal to refine later.

## Current Understanding

The organization has several related groups and initiatives:

- **Corporate Technology** represents the requirements side. It owns or coordinates
  business needs, prioritization, and acceptance criteria.
- **Data and AI** owns data and AI-related capabilities. This may include data products,
  pipelines, analytics, machine learning, governance, and GCP-related data platform work.
- **GCP infrastructure** provides cloud foundation capabilities such as projects,
  networking, IAM, storage, observability, and managed data services.
- **Dev and DevOps teams** build and operate applications, CI/CD, deployment automation,
  and integration with the shared cloud and data platform.
- **Product applications** consume shared platform capabilities. Known examples are:
  - Property Intelligence Platform
  - Transactional Intelligence Platform
  - future applications that need the same DevOps, GCP, and Data and AI support

The exact team names, system names, technology choices, and ownership model still need to
be clarified.

## Problem

If we model everything as one solution, the architecture package will become too large:

- too many stakeholders in one approval gate
- too many unrelated decisions in one ADR set
- unclear ownership between requirements, product applications, data platform, and cloud
  infrastructure
- repeated platform decisions for every application
- hard-to-review diagrams that mix portfolio, platform, and application concerns

The process needs a structure that shows the whole picture while keeping each approval
package small enough to review.

## Proposed Slicing Principle

Use this rule:

> One solution per independently approvable architecture decision package.

That means shared platform decisions are approved once, then product applications reference
those accepted decisions instead of reopening them.

## Proposed Structure

Use three levels of architecture material.

### 1. Portfolio Landscape

The portfolio landscape explains the full operating picture:

- Corporate Technology provides business requirements.
- Product applications implement user-facing or decision-support capabilities.
- Data and AI provides shared data and intelligence capabilities.
- GCP infrastructure and DevOps provide hosting, delivery, security, and operations.
- Future applications can reuse the same platform capabilities.

This level is for orientation. It should not contain all detailed implementation choices.

### 2. Shared Platform Foundation

Create one or more platform foundation solutions for decisions that constrain multiple
applications.

Possible first foundation package:

```text
001_GCP_Data_AI_Foundation
```

Candidate decisions:

- GCP project, folder, and environment structure
- IAM and security boundary model
- network and connectivity model
- data landing zone and storage conventions
- BigQuery, object storage, and analytics conventions
- deployment and IaC ownership
- observability and support model
- shared data product ownership

This package should create the reusable baseline for later applications.

### 3. Product Application Solutions

Create separate solutions for product applications that consume the foundation.

Examples:

```text
002_Property_Intelligence_Platform
003_Transactional_Intelligence_Platform
004_<Future_Intelligence_App>
```

Each application solution should reference accepted foundation ADRs and only introduce new
ADRs for application-specific choices.

Examples of application-specific decisions:

- application integration pattern with the Data and AI platform
- product-specific data products and APIs
- serving pattern for intelligence outputs
- user access model
- application-specific NFRs
- exception from the shared platform standard

## Suggested Mental Model

```text
Corporate Technology
  owns business requirements and priorities
        |
        v
Product Applications
  Property Intelligence, Transactional Intelligence, future apps
        |
        v
Data and AI
  data products, pipelines, analytics, AI/ML services, governance
        |
        v
GCP Foundation and DevOps Enablement
  cloud projects, IAM, networking, CI/CD, IaC, observability
```

This is a simplification. The real model may have feedback loops, shared ownership, and
direct dependencies between applications and GCP services. Those should be added when the
stakeholder and technology picture is clearer.

## ADR Usage

Do not create ADRs for every team boundary or every technical component.

Create ADRs for choices that constrain future work:

- platform boundary or ownership model
- GCP project or environment strategy
- data ownership and data product boundary
- application-to-data-platform integration pattern
- security, IAM, or data protection model
- build vs reuse decision
- shared DevOps or IaC ownership model
- standards exception
- major NFR tradeoff

Application solutions should reference foundation ADRs where possible.

Example:

```yaml
adrs:
  - ADR-001-0001 # GCP environment structure
  - ADR-001-0002 # shared data product ownership
  - ADR-002-0001 # Property Intelligence serving pattern
```

## Proposed Initial Sequence

Start with a short discovery and portfolio picture before generating detailed solutions.

1. Create a portfolio landscape model with the known actors, domains, and product
   applications.
2. Create `001_GCP_Data_AI_Foundation` for shared platform decisions.
3. Create `002_Property_Intelligence_Platform` as the first product application solution.
4. Create `003_Transactional_Intelligence_Platform` as the second product application
   solution.
5. Use each later application to test whether the foundation ADRs are reusable or need
   an exception ADR.

## What Not To Do

Avoid these patterns:

- one giant solution covering platform, both applications, all teams, and all future apps
- separate ADRs for every GCP service or every relationship in the diagram
- product application ADRs that duplicate already accepted foundation ADRs
- diagrams that mix stakeholder ownership, runtime architecture, and deployment details
  in one view
- treating the current stakeholder list as complete

## Open Questions

- Which team owns the GCP foundation decisions?
- Is Data and AI responsible for GCP infrastructure, data platform capabilities, or both?
- Which parts of DevOps are shared platform capabilities versus application-team
  responsibilities?
- Are Property Intelligence and Transactional Intelligence separate systems, separate
  products on one platform, or separate modules of a larger intelligence platform?
- What are the primary data sources and system-of-record boundaries?
- Which applications are first consumers of the shared Data and AI capabilities?
- Which approvals are required from Corporate Technology, Data and AI, DevOps, Security,
  and application owners?
- Which Azure DevOps project, repository, or work item type should represent the
  architecture approval gate?

## Future Work

When the stakeholder and technology picture is clearer, turn this intent into:

- a concrete multi-project walkthrough
- a LikeC4 example model for the portfolio landscape
- a foundation solution example
- one product application solution example
- guidance for referencing foundation ADRs from application ADRs and SADs

