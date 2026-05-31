# Skills Reference

The four LLM playbooks that drive the aac-forge pipeline. Each skill is provider-agnostic — it references abstract tool names (`readFile`, `searchContent`, `editFile`, `runCommand`, etc.) that the runtime adapter maps to the concrete LLM platform.

## arch-generate-solution

**Purpose:** BR documents → model changes → validate → export → SAD document.

**Argument:** Solution path (e.g. `solutions/001_My_Feature/`).

**Phases:**

| Phase | What happens |
| --- | --- |
| 1. PREPARE | Read all input documents, parse BPMN, read current model |
| 2. PLAN | Output structured change plan — new systems, containers, relationships, data flows, files to change. **WAIT for user approval.** |
| 3. APPLY | Edit model files with new elements and relationships |
| 4. VALIDATE | Run `npx likec4 validate`, fix errors, re-validate |
| 5. EXPORT | Export PNG and Mermaid diagrams to output folder |
| 6. GENERATE SAD | Fill SAD template from BR + model data |
| 7. VERIFY | Cross-reference INF codes between diagrams and SAD |

**Key feature:** Plan-before-execute approval gate prevents unintended model changes.

---

## arch-review-solution

**Purpose:** 5-role comprehensive review of a completed SAD.

**Argument:** Solution path.

**Phases:**

| Phase | What happens |
| --- | --- |
| 1. CONTEXT | Read input docs, SAD, current model, standards |
| 2. REVIEW | Sequential review from 5 role perspectives |
| 3. REPORT | Generate structured findings report |
| 4. VERIFY | Cross-check finding counts, numbering, cross-references |

**5 Roles:**

| # | Role | Focus |
| --- | --- | --- |
| 1 | Solution Architect | Technical quality, decomposition, integration patterns, NFRs |
| 2 | Enterprise Architect | Landscape alignment, reuse, naming, CMDB, principles |
| 3 | Security Specialist | Auth, secrets, data protection, logging, audit |
| 4 | Adjacent System Owner | Per-system impact, dependencies, SLA, backward compat |
| 5 | Business Process Owner | BR coverage, user journey, business value, usability |

**Output:** `SAD Review <Name>.md` with per-role finding tables and severity classification (🔴 Critical / 🟡 Significant / 🟢 Minor / 💡 Recommendation).

---

## arch-export-diagrams

**Purpose:** Export all views from a LikeC4 model to PNG and other formats.

**Argument (optional):** Output directory.

**Steps:**

1. Validate model (`npx likec4 validate`)
2. Export PNG (`npx likec4 export png`)
3. Export Mermaid (optional — `npx likec4 gen mermaid`)
4. Export to additional formats (JSON, DrawIO, DOT, D2, PlantUML)

**Formats supported:**

| Format | Command | Use case |
| --- | --- | --- |
| PNG | `likec4 export png` | Documents, presentations |
| JPEG | `likec4 export jpg` | Smaller files, no transparency |
| Mermaid | `likec4 gen mermaid` | GitHub Markdown, collapsible in SAD |
| JSON | `likec4 export json` | Programmatic processing |
| DrawIO | `likec4 export drawio` | Manual editing in draw.io |
| DOT | `likec4 gen dot` | Graphviz, custom layouts |
| D2 | `likec4 gen d2` | D2 diagram language |
| PlantUML | `likec4 gen plantuml` | Teams using PlantUML |

---

## arch-list-resources

**Purpose:** Extract all containers from the model and generate a resource table.

**Steps:**

1. Discover all `.c4` files in `model/`
2. Parse container definitions (ID, title, technology, parent system)
3. Generate `resources.md` with system-grouped table

**Output columns:** System, Container, Technology, CPU, RAM, GPU, SSD, Replicas (resource columns left empty for manual fill-in).

---

## Adapter Interface

Skills reference these abstract tool names:

| Tool | Purpose |
| --- | --- |
| `readFile(path, options?)` | Read file contents |
| `searchContent(pattern, options?)` | Search file contents |
| `searchFiles(pattern, path?)` | Find files by name |
| `runCommand(command, options?)` | Execute shell command |
| `writeFile(path, content)` | Create/overwrite file |
| `editFile(path, search, replace)` | Apply SEARCH/REPLACE edit |
| `askUser(question, options?)` | Interactive prompt |
| `setStatus(message)` | Report progress |

The adapter (`adapters/adapter-interface.ts`) maps these to provider-specific tool calls.
