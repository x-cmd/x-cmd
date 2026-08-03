---
name: yfm
description: |
  YAML front matter (YFM) for any markdown article. x-cmd's default is three top-level fields: `tags`, `description`, `memo`. Default borrows the Agent Skills frontmatter shape — see <https://agentskills.io/specification>. The yfm module is a helper: `x yfm ls / init / lint`.

metadata:
  related: "skill0-writer,ontology-database"
---


# yfm — skill0

## Adopt YFM

Use YFM for any markdown an agent, index, or ontology pipeline may scan. **Follow the existing dialect if one is already in use** (Agent Skills, Obsidian, Jekyll, Hugo, etc.) — the x-cmd default applies only when no other dialect governs.

## The x-cmd default: three fields

```yaml
---
tags: [design, front-matter]
description: One-sentence summary a reader uses to decide whether to open this file.
memo:
  2026-07-31T14:30:00+08:00: Cut aliases; renamed third field to memo.
---

# Title

Body...
```

- **`tags`** — top-level list of slugs `[a-z0-9-]`. Consumer: the collector for ontology indexing.
- **`description`** — top-level string. One sentence. Not the Agent Skills `description:` (that is a SKILL.md-only requirement, governed by `skill0-writer`).
- **`memo:`** — top-level map, the file's revision log. Keys are ISO 8601 timestamps (`YYYY-MM-DDTHH:mm:ss±HH:mm`, author's local offset); values are short change-descriptions. Newest first. Omit when no history is worth recording.

### Applicable scope

- `<project>/.x-cmd/story/` — extends with `issue:` — see [usecase/story.md](usecase/story.md).
- GitHub issue / PR bodies — extends with `repo:`, `number:` — see [usecase/git-issue-pr-wiki-markdown-etc.md](usecase/git-issue-pr-wiki-markdown-etc.md).
- GitHub `README.md` — default fields only.

## Module

The yfm module is a helper. Three commands:

- `x yfm ls [path]` — list YFM blocks; defaults to the current directory
- `x yfm init [path]` — write an x-cmd-default block into each markdown file under the path
- `x yfm lint [path]` — check that each YFM block is valid YAML and follows the dialect it claims

## Reading foreign front matter

The collector ingests many dialects. For the spec the default borrows from, see <https://agentskills.io/specification>. Per-dialect:

- [Agent Skills](usecase/agentskills.md) — `metadata:` is string→string; top level is closed
- [Obsidian](usecase/obsidian.md) — `tags` / `aliases` / `cssclasses` reserved
- [Jekyll](usecase/jekyll.md) — list or **space**-separated
- [Hugo](usecase/hugo.md) — TOML possible; site-configured taxonomy

