# Obsidian

Docs: <https://help.obsidian.md/Editing+and+formatting/Properties>

## Typical example

```markdown
---
tags:
  - recipe
  - cooking
  - inbox/to-read
aliases:
  - Pasta recipe
cssclasses:
  - soft-embed
---

The inline #dinner in the body also counts as a tag.
```

## Tag extraction

- **key** — `tags` (top-level)
- **type** — **must be a list**. Spec: "Tags in YAML should always be formatted as a list."
- **body** — inline `#tag` counts too, not just YFM.

Character set: letters, digits, `_`, `-`, `/`, common Unicode (including emoji).

- **No spaces**. Multi-word: `camelCase` / `PascalCase` / `snake_case` / `kebab-case`.
- Must contain at least one non-numeric character (`#1984` is invalid, `#y1984` is valid).
- **Case-insensitive**: `#tag` and `#TAG` are the same tag. Normalize to lowercase.
- Comma is not in the character set, so a comma-joined string is technically unambiguous — but Obsidian itself does not produce that form.

## Nested tags are hierarchies

`/` creates hierarchy: `inbox/to-read`. A search for `tag:inbox` matches `#inbox` and all its children.

This is a real parent-child relation in the dialect; the collector should expand it into hierarchy edges, not flatten the string.

## Conflict with Agent Skills

Obsidian does not support nested properties. Agent Skills mandates that extension fields live under `metadata:`. The two cannot both be satisfied in the same file: `metadata.tags` is unreadable in Obsidian, top-level `tags:` is non-conforming in Agent Skills. The collector dispatches by source and does not try to reconcile.

## Reserved properties

`tags`, `aliases`, `cssclasses` — three default properties, semantics reserved by Obsidian, do not repurpose.

`aliases` is useful for the ontology: an alias set for the same entity. Note it does **not** mean the same as Hugo's `aliases` (redirect paths).

## Other constraints

- Property values **do not render markdown** (intentional).
- A property name has the same type across the entire vault — type is vault-level, not file-level. Infer types vault-wide.