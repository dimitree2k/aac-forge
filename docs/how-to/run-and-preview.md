# How to Run and Preview

## Start the Interactive Diagram Explorer

The dev server lets you explore diagrams in a browser with live updates:

```bash
# Default (main model in model/)
npm run dev

# Or a specific workspace
npx likec4 start examples/order-management/model/
```

Open **http://localhost:5173**. Features:

| Action | How |
| --- | --- |
| Navigate views | Click view tabs in the sidebar |
| Drill into systems | Click any system/container box |
| Search elements | Use the search bar (top) |
| See relationships | Hover over any arrow |
| Live reload | Edit any `.c4` file — browser updates instantly |

## Validate a Model

Check for syntax errors, semantic issues, and layout drifts:

```bash
# Main model
npm run validate

# Any workspace
npx likec4 validate examples/order-management/model/
```

Successful output:
```
✓ Valid (5 files)
```

If there are errors, each one is reported with file path, line number, and description.

## Export Diagrams

### PNG (for documents and presentations)

```bash
# All views from a workspace
npx likec4 export png examples/order-management/model/ -o output/ --flat

# Specific views only
npx likec4 export png examples/order-management/model/ -f "solution001*" -o output/ --flat

# Dark theme
npx likec4 export png examples/order-management/model/ -o output/ --flat --theme dark
```

### JSON (for programmatic processing)

```bash
npx likec4 export json --pretty -o model.json examples/order-management/model/
```

### Mermaid (for GitHub Markdown)

```bash
npx likec4 gen mermaid examples/order-management/model/ --outdir mermaid/
```

### Other formats

```bash
npx likec4 gen dot model/ --outdir dot/       # Graphviz
npx likec4 gen d2 model/ --outdir d2/         # D2
npx likec4 gen plantuml model/ --outdir puml/ # PlantUML
npx likec4 export drawio model/ -o drawio/    # DrawIO
```

## Format Model Files

Auto-format all `.c4` files in a workspace:

```bash
npm run format
npx likec4 format examples/order-management/model/
```

## Build Static Website

Generate a standalone HTML site (for GitHub Pages, Netlify, etc.):

```bash
npx likec4 build examples/order-management/model/ -o dist/
```

## Available npm Scripts

| Command | What it does |
| --- | --- |
| `npm run dev` | Start dev server on main model |
| `npm run validate` | Validate main model |
| `npm run export:png` | Export main model to PNG |
| `npm run export:json` | Export main model to JSON |
| `npm run export:mermaid` | Export main model to Mermaid |
| `npm run export:dot` | Export main model to Graphviz DOT |
| `npm run format` | Format main model files |
| `npm run build` | Build static website from main model |
