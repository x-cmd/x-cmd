# Agent Skills

Spec: <https://agentskills.io/specification>

## Typical example

```markdown
---
name: pdf-processing
description: Extract PDF text, fill forms, merge files. Use when handling PDFs.
license: Apache-2.0
compatibility: Requires Python 3.14+ and uv
allowed-tools: Bash(git:*) Bash(jq:*) Read
metadata:
  author: example-org
  version: "1.0"
  tags: "pdf,forms,extraction"
---
```

## Tag extraction

- **key** — `metadata.tags` (nested one level, not top-level)
- **type** — **string**. The spec mandates `metadata` be a string→string map; lists are not allowed.
- **separator** — undefined by the spec. skill0 convention: comma, no spaces.

The comma join is safe here because the value domain is constrained: slugs are `[a-z0-9-]` and cannot contain a comma. Note that within the same front matter `allowed-tools` is **space**-separated while `metadata.tags` is comma-separated — separators are not uniform across the spec, dispatch per key.

## Top level is a closed set

Only: `name`, `description`, `license`, `compatibility`, `metadata`, `allowed-tools`.

`version`, `author`, `tag`, `date` at the top level are non-conforming — they belong inside `metadata:`. This is the largest delta from every other dialect: other dialects let you add fields at the top level; this one does not.

## Ontology mapping

Everything under `metadata:` is a string, so no type inference is needed — each key becomes an entity property directly.

The spec recommends key names be "reasonably unique" to avoid collisions, so generic keys inside `metadata:` (`type`, `category`, `related`) must be treated as local naming and not assumed to mean the same thing across dialects.

## Constraints

- `name`: 1-64 chars, `[a-z0-9-]`, no leading/trailing hyphens, no consecutive `--`, must equal parent directory name
- `description`: 1-1024 chars
- `compatibility`: ≤500 chars