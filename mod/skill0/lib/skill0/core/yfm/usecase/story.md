# story

YFM convention for `<project>/.x-cmd/story/` design stories. Inherits the [x-cmd default](../SKILL.md#the-x-cmd-default-three-fields) and adds `issue:`.

## Typical example

```markdown
---
tags: [yfm, design]
description: How the yfm skill settled on three fields, in chronological order.
issue: 142
memo:
  2026-07-31T14:30:00+08:00: Tightened field list; cut aliases, added memo.
  2026-07-31T10:00:00+08:00: Initial draft.
---

# Title

Body...
```

## `issue:`

Reference to a related issue. Single number or list:

```yaml
issue: 142
issue: [142, 158]
```

The collector maps this to an ontology relation linking the story entity to the issue entity. Omit the field if there is no related issue — do not write `issue: null` or `issue: 0`.

## Date format for `memo:` keys

ISO 8601, accurate to the second, numeric offset — e.g. `2026-07-31T14:30:00+08:00`.
