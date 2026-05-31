# arch-export-diagrams

**What it does:** Exports curated LikeC4 views to PNG and optionally Mermaid format.

**Argument (optional):** Output directory and, when exporting a solution package, one
or more view IDs. Default output: `<solution>/output/` in a solution context, or
`model/export/` if no solution context.

---

## Algorithm

### Step 1. Determine scope

If working within a solution context, export to `<solution>/output/`. Otherwise export
to `model/export/`.

In a solution context, identify the exact views referenced by the SAD or change plan.
Treat only those filtered views as deliverables. Do not export workspace overview
artifacts such as `index.*` or generic `landscape.*` unless they are intentionally
curated for the solution and referenced by the SAD.

### Step 2. Validate the model

Run validation first — export will fail on invalid models:
```
runCommand: npx likec4 validate model/
```

Fix any errors before proceeding.

### Step 3. Export PNG diagrams

For solution packages, export only the curated solution views with `-f` filters:
```
runCommand: npx likec4 export png model/ -o <output-dir>/ --flat -f "<viewId1>" -f "<viewId2>"
```

For intentionally broad model exports outside a solution package, export all views:
```
runCommand: npx likec4 export png model/ -o <output-dir>/ --flat
```

Options:
- `--flat` — flatten all images in the output directory (ignores source structure)
- `--theme dark` — use dark theme (default: light)
- `-f "pattern*"` — filter specific views by ID pattern

### Step 4. Export Mermaid sources (optional)

For embedding in SAD documents with collapsible source blocks:
```
runCommand: npx likec4 gen mermaid model/ --outdir <output-dir>/
```

The Mermaid generator may not support `-f` filters. In solution packages, remove any
generated `.mmd` files that are not SAD-referenced deliverables, especially workspace
navigation artifacts such as `index.mmd` or generic `landscape.mmd`.

Mermaid output is a portability artifact, not the authoritative visual rendering.
LikeC4 shape semantics are best verified in the interactive browser or exported PNG.
Some LikeC4 shapes are mapped approximately to Mermaid shapes, and generic services may
still appear as Mermaid rectangles.

### Step 5. Export to additional formats (optional)

JSON (for programmatic processing):
```
runCommand: npx likec4 export json model/ -o <output-dir>/
```

DrawIO (for manual editing):
```
runCommand: npx likec4 export drawio model/ -o <output-dir>/
```

Graphviz DOT (for custom graph layouts):
```
runCommand: npx likec4 gen dot model/ --outdir <output-dir>/
```

### Step 6. Verify

List exported files to confirm all expected views were generated:
```
runCommand: ls -lh <output-dir>/
```

For solution packages, also verify:

- The output folder contains only SAD-referenced solution views, SAD files, and review
  files.
- No stale `index.*` or generic `landscape.*` artifacts remain unless intentionally
  curated.
- No unrelated sample/demo-domain labels appear in the generated solution output.

Report the file list and sizes to the user.

---

## Format Reference

| Format | Command | Use Case |
| --- | --- | --- |
| PNG | `likec4 export png` | Embed in SAD documents, presentations |
| JPEG | `likec4 export jpg` | Smaller file size, no transparency needed |
| Mermaid | `likec4 gen mermaid` | GitHub/GitLab markdown, collapsible source in SAD |
| JSON | `likec4 export json` | Programmatic processing, consistency checks |
| DrawIO | `likec4 export drawio` | Manual diagram editing in draw.io |
| Graphviz DOT | `likec4 gen dot` | Custom graph layout, CI pipelines |
| D2 | `likec4 gen d2` | D2 diagram language |
| PlantUML | `likec4 gen plantuml` | Teams already using PlantUML toolchain |
