# Surfaces — which YFM where

Surface-by-surface map for the yfm skill. For each markdown surface x-cmd writes to or reads from, which fields apply.

## Quick map

| Surface | Writing | Reading | Useful fields |
|---|---|---|---|
| GitHub issue body | [§GitHub issue & PR bodies](#github-issue--pr-bodies) | same | `tags`, `description`, `repo`, `number` |
| GitHub PR body | [§GitHub issue & PR bodies](#github-issue--pr-bodies) | same | same as issue |
| GitHub wiki page | [x-cmd default](../SKILL.md#the-x-cmd-default-three-fields) | [x-cmd default](../SKILL.md#the-x-cmd-default-three-fields) | `tags`, `description`, `memo` |
| GitHub `README.md` | [x-cmd default](../SKILL.md#the-x-cmd-default-three-fields) | [x-cmd default](../SKILL.md#the-x-cmd-default-three-fields) | `tags`, `description`, `memo` |
| `<project>/.x-cmd/story/*.md` | [story](story.md) | [story](story.md) | `tags`, `description`, `memo`, `issue` |
| `<skill>/SKILL.md` | [x-cmd default](../SKILL.md#the-x-cmd-default-three-fields) + [skill0-writer](../../skill0-writer/SKILL.md) | [x-cmd default](../SKILL.md#the-x-cmd-default-three-fields) | `tags`, `description`, `memo`; plus `metadata.related` per skill0-writer |
| Local markdown notes | [x-cmd default](../SKILL.md#the-x-cmd-default-three-fields) or no YFM | [x-cmd default](../SKILL.md#the-x-cmd-default-three-fields) | `tags`, `description`, `memo` |
| Obsidian vault files | (Obsidian native) | [obsidian](obsidian.md) | `tags`, `aliases`, `cssclasses` |
| Jekyll site files | (Jekyll native) | [jekyll](jekyll.md) | `title`, `date`, `tags`, `categories` |
| Hugo site files | (Hugo native) | [hugo](hugo.md) | `title`, `date`, `tags`, `keywords`, site taxonomy |
| Agent Skill files | [agentskills](agentskills.md) | [agentskills](agentskills.md) | `name`, `description`, `metadata.*` |

Anything not listed falls back to [x-cmd default](../SKILL.md#the-x-cmd-default-three-fields). The 3 fields are the floor, not the ceiling — but adding more requires a new usecase, never a private field.

## GitHub issue & PR bodies

Inherits the [x-cmd default](../SKILL.md#the-x-cmd-default-three-fields) and adds two issue-identification extensions.

```markdown
---
tags: [yfm, design]
description: Should the yfm skill include metadata.related?
repo: x-bash/skill0
number: 142
memo:
  2026-07-31T14:30:00+08:00: Initial draft.
---

# Should yfm include metadata.related?
...
```

- **`repo:`** — `owner/name` (e.g., `x-bash/skill0`). Required when the document is a free-standing issue summary; optional when the document is the issue body itself (GitHub already knows).
- **`number:`** — integer issue number. Same optionality as `repo:`. The same pair works for PR bodies.

State (open / closed / merged) is **not** part of this surface — GitHub's API is the system of record; re-stating it in YFM risks drift. Same for `labels:`, `assignees:`, `created_at:`, `updated_at:`.

Use this section when writing a YFM block that describes an issue or PR, or as the body of a GitHub issue/PR written by x-cmd tooling. The GitHub API is the system of record for issues you do not control.
