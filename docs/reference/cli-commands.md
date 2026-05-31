# CLI Commands Reference

All available commands for working with LikeC4 models in aac-forge.

## npm Scripts

```bash
npm run dev              # Start interactive diagram explorer (http://localhost:5173)
npm run validate         # Validate main model (model/)
npm run export:png       # Export main model to PNG
npm run export:json      # Export main model to JSON
npm run export:mermaid   # Export main model to Mermaid (.mmd)
npm run export:dot       # Export main model to Graphviz (.dot)
npm run format           # Auto-format main model files
npm run build            # Build static website from main model
```

## likec4 CLI

All commands accept a `[path]` argument — the directory containing `.c4` files (default: current directory).

### Development

```bash
npx likec4 start [path]        # Start dev server with hot reload
                                # Aliases: serve, dev
npx likec4 preview [path]      # Preview production build (after `build`)
```

### Validation

```bash
npx likec4 validate [path]     # Syntax, semantics, and layout drift check
npx likec4 validate --json [path]  # JSON output (for CI parsing)
npx likec4 validate --no-layout    # Skip layout drift check (faster)
```

### Export

```bash
npx likec4 export png [path]    # Export views to PNG
npx likec4 export jpg [path]    # Export to JPEG
npx likec4 export json [path]   # Export model to JSON
npx likec4 export drawio [path] # Export to DrawIO (.drawio)
```

PNG options:

| Flag | Effect |
| --- | --- |
| `-o <dir>` | Output directory |
| `--flat` | Flatten output (ignore source structure) |
| `-f "pattern*"` | Filter views by ID pattern |
| `--theme dark` | Dark color scheme |
| `--timeout <sec>` | Playwright timeout (default 15) |
| `-i`, `--ignore` | Continue if some views fail |

For solution deliverables, prefer filtered PNG exports with `-f <viewId>` and include
only views referenced by the SAD. Treat generated `index.*` and generic workspace
overview files as navigation artifacts unless intentionally curated.

PNG/browser output is the authoritative rendering for LikeC4 visual semantics. Mermaid
generation maps LikeC4 shapes approximately and may still render generic services as
rectangles.

### Code Generation

```bash
npx likec4 gen mermaid [path]    # Mermaid (.mmd)
npx likec4 gen dot [path]        # Graphviz (.dot)
npx likec4 gen d2 [path]         # D2 (.d2)
npx likec4 gen plantuml [path]   # PlantUML (.puml)
npx likec4 gen react [path]      # React components
npx likec4 gen model [path]      # TypeScript model (.ts)
```

### Formatting

```bash
npx likec4 format [path]         # Auto-format all .c4 files
```

### Build

```bash
npx likec4 build [path] -o dist/  # Static website
```

### MCP / LSP

```bash
npx likec4 mcp [path]            # Start MCP server (stdio)
npx likec4 mcp --http -p 3333    # Start MCP server (HTTP)
npx likec4 lsp                   # Start LSP server
```

## Project Scripts

```bash
bash scripts/validate-model.sh [model-dir]
bash scripts/export-diagrams.sh [model-dir] [output-dir]
bash scripts/verify-consistency.sh [model-dir]
python3 scripts/parse-bpmn.py <bpmn-file>
python3 scripts/extract-labels.py <model.json>
bash tests/smoke-test.sh
```
