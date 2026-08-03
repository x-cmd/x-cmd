# Jekyll

Docs: <https://jekyllrb.com/docs/front-matter/>

## Typical example

```markdown
---
layout: post
title: "Welcome to Jekyll"
date: 2026-07-31 10:00:00 +0800
categories: jekyll update
tags: [intro, meta]
---
```

The two forms coexist in one file: `categories` is a **space-separated string**, `tags` is a list. That coexistence is the trap.

## Tag extraction

- **key** — `tags` and `categories` (top-level, both)
- **type** — list *or* string
- **separator** — **space** in the string form, not comma

Spec: tags/categories "can be specified as a YAML list or a space-separated string".

The extractor must check the YAML-parsed type first: list → iterate items; string → split on space. Splitting on comma treats Jekyll's `categories: jekyll update` as a single tag `"jekyll update"`. Obsidian then rejects that value outright, since its tags cannot contain spaces, and the bad value propagates into downstream normalization. The opposite-of-Agent-Skills separator is the whole reason a shared split routine cannot serve both.

## categories is not tags

`categories` participates in URL path generation; `tags` does not. Semantically: categories are hierarchical, tags are flat keywords.

The collector should keep them as separate sets, not merge into one tag bag.

## Other

- Singular keys `category` / `tag` are also recognised and equivalent to the plural forms — scan all four.
- Top-level custom fields are accessible from templates → remaining fields become ontology properties directly.