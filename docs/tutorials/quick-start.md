# Quick Start

Follow this guide to go from zero to seeing C4 architecture diagrams in your browser in under 5 minutes.

## Prerequisites

- **Node.js 20+** — [download](https://nodejs.org/)
- A terminal

## 1. Install Dependencies

```bash
cd aac-forge
npm install
```

This installs LikeC4 and Playwright (for PNG export).

## 2. Validate the Models

The repo ships with model workspaces. Validate them all:

```bash
# Main model (skeleton)
npm run validate

# Order Management (real-world enterprise)
npx likec4 validate examples/order-management/model/
```

Each should print `✓ Valid` in under a second.

## 3. Explore Diagrams in the Browser

Start an interactive diagram explorer with hot-reload:

```bash
npx likec4 start examples/order-management/model/
```

Open **http://localhost:5173** in your browser. You'll see:

- A **landscape view** showing all systems
- **Container views** drilling into each system's internals
- Click any element to navigate between views
- Edit any `.c4` file — the browser updates instantly

## 4. Export Static Diagrams

Generate PNG files for embedding in documents:

```bash
npm run export:png
# PNGs land in export/ (main model)
```

Or export a specific workspace:

```bash
npx likec4 export png examples/order-management/model/ -o examples/order-management/export/ --flat
```

## 5. Run the Smoke Test

Verify the entire pipeline works end-to-end:

```bash
bash tests/smoke-test.sh
```

Expect **6/6 pass** — validate, export, parse BPMN, extract labels, format check.

## Next Steps

- **Add your own domain** → [How to Add a New Domain](../how-to/add-new-domain.md)
- **Create a solution** → [How to Create a New Solution](../how-to/create-new-solution.md)
- **Understand the DSL** → [DSL Conventions Reference](../reference/dsl-conventions.md)
- **Learn the pipeline** → [Pipeline Architecture](../explanation/architecture.md)
