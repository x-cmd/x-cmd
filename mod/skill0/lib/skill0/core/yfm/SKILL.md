---
name: yfm
description: |
  YAML front matter (YFM) convention for markdown articles — memory entries, design notes, blog posts, RUNBOOKs, READMEs, any prose an agent or a pipeline may scan.
  Top-level fields (title, tag, link, date, author) for indexing and discovery. The `x-meta:` block is the x-cmd extension: it carries ontology fields that link the article into x-cmd's knowledge graph via `x ondb`.
  Apply unless a stricter spec forbids front matter. Helpers: `x yfm` (in design).

tag: [yfm, front-matter, metadata, ontology, markdown]
x-meta:
  type: Convention
  status: stable
  related: [skill0-writer, ontology-database]
  owner: person:lijunhao
---


# yfm — skill0

**Two aspects.** This skill teaches AI to do two things on a markdown article:

1. **Use YFM when allowed.** Add a YAML front matter block to any article an agent, search index, or ontology pipeline may scan — unless a stricter spec forbids it.
2. **Define `x-meta:` for ontology hooks.** Inside the YFM, reserve a top-level `x-meta:` block with ontology fields that link the article into the knowledge graph via `x ondb`.

A YFM convention for **any markdown article** — memory entries, design notes, blog posts, RUNBOOKs, READMEs. Top-level fields (`title` / `tag` / `link` / `date` / `author`, plus any free-form keys you need) are general; `x-meta:` is the x-cmd extension that ties the article into `x ondb`. SKILL.md are articles too, but they also carry skill0-writer's `name` + `description` (separate, additive).

## When to add YFM

Default behavior is **add YFM** for any markdown an agent, search index, or ontology pipeline may scan. **Skip** when a real restriction is in play:

- A stricter spec governs the file: GitHub repo root `README.md` (fixed-form contract), vendored tool output, Hugo / Jekyll / MDX files whose host format already defines its own front matter.
- **Markdown lint complains.** This is the most reliable signal that the host environment forbids or restricts front matter. Read the lint error — many projects encode project-specific YFM restrictions in lint rules rather than docs. Skim the relevant `.markdownlint.*` / `remark-*` / `.mdlrc` config to learn the local rules.

## `x-meta:` — ontology fields

`x-meta:` is a reserved **top-level** YFM block for ontology data, ingested by [ontology-database](../ontology-database/SKILL.md) into `x ondb`. The namespace isolates these fields from any other YFM key — no prefix, no rewrite, ingester maps them directly.

| Field | Maps to ondb | Purpose |
|---|---|---|
| `type` | entity type | Primary type — `Article`, `Memory`, `Note`, `Decision`, `Runbook`, `Convention` |
| `related` | `related` relation | Sibling articles / concepts (entity ids) |
| `supersedes` / `deprecated-by` | `supersedes` / `deprecated-by` | Replacement history (bi-directional) |
| `status` | enum property | `draft` / `stable` / `deprecated` |
| `owner` | `owner` property | Author or maintainer entity id |
| `tag` | `tag` relation | Tags promoted to ondb entities (preferred over flat `tag:`) |

```yaml
x-meta:
  type: Memory
  status: draft
  related: [memory:2026-07-19-on-xfm-design]
  owner: person:lijunhao
```

Flat `tag:` (top-level) is for human and agent indexing; `tag` (nested inside `x-meta:`) is for ontology-side graph relations. Both can coexist — `x yfm ingest` reconciles them.

## `x yfm` helpers (in design)

The helper module is not yet shipped. Planned subcommands:

```
x yfm lint <file>                       # validate required top-level fields
x yfm read <file> --field tag            # extract one or more dotted paths
x yfm inject <file>                      # add YFM block if missing (idempotent)
x yfm ingest <file> --ondb <dir>         # write x-meta to x ondb
```

## Rules

- MUST add standard top-level YFM fields (at minimum `title`) to every agent-indexable markdown unless a stricter spec forbids it.
- MUST keep ontology fields under the top-level `x-meta:` block.
- MUST NOT place ontology fields outside `x-meta:`.
- Treat `date`, `tag`, `link`, `author`, `x-meta` as optional — missing fields are not errors.

## Related

- [skill0-writer](../skill0-writer/SKILL.md) — writer rule enforces YFM layer-1
- [ontology-database](../ontology-database/SKILL.md) — x-meta ingests into ondb
