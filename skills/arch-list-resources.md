# arch-list-resources

**What it does:** Extracts all containers from LikeC4 model files and generates a resource table.

---

## Algorithm

### Step 1. Discover model files

Find all `.c4` files in the model directory:
```
searchFiles: pattern *.c4 under model/
```

### Step 2. Extract container definitions

In each file, use `readFile` to read the content. Find all container definitions of the form:
```
containerName = container 'Container Title' 'Summary' 'Technology'
```

Containers are defined inside system blocks:
```
systemName = system 'System Title' {
  description '...'
  containerName = container 'Container Title' 'Summary' 'Technology'
}
```

Extract for each container:
- **Container name** — the title (first quoted string after `container`)
- **Container ID** — the identifier (before `=`)
- **System** — the title of the parent system (first quoted string after `system` on the enclosing block)
- **Technology** — the technology string (third argument after `container`)

### Step 3. Cross-reference with deployments (if available)

If the model has deployment information (check for `deployment` or `node` keywords), extract the node/instance assignments.

### Step 4. Generate resource table

Use `writeFile` to create `resources.md` in the project root:

```markdown
# Container Resources

| System | Container | Technology | CPU | RAM | GPU | SSD | Replicas |
| --- | --- | --- | --- | --- | --- | --- | --- |
| <system title> | <container title> | <technology> | | | | | |
```

**Rules:**
- Group rows by system (all containers of one system together)
- Sort systems alphabetically by title
- Sort containers within a system alphabetically by title
- Leave CPU, RAM, GPU, SSD, Replicas columns empty for manual fill-in
- If Technology is empty or not specified, leave the cell blank

### Step 5. Report

Present a summary to the user:
- Total container count
- Count per system
- Path to the generated file
