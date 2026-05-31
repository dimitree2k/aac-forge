# arch-export-diagrams

**What it does:** Exports all views from the LikeC4 model to PNG and optionally Mermaid format.

**Argument (optional):** Output directory. Default: `export/` in the solution folder, or `model/export/` if no solution context.

---

## Algorithm

### Step 1. Determine scope

If working within a solution context, export to `<solution>/output/`. Otherwise export to `model/export/`.

### Step 2. Validate the model

Run validation first — export will fail on invalid models:
```
runCommand: npx likec4 validate model/
```

Fix any errors before proceeding.

### Step 3. Export PNG diagrams

Export all views to PNG:
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
