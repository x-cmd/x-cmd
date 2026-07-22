---
name: skill0-writer
description: Writing conventions for skill0 documents — pyramid structure, line limits, and layout rules.
x-meta:
  type: Convention
  status: stable
  related: [yfm, naming]
  owner: person:lijunhao
---

# skill0-writer

Skill0 documents follow the **pyramid principle**: agents may read only the first 10–30 lines, so the most important information must come first. Detail beyond line 30 is the bonus, not the load.

## Things no rule catches

- **Clarity over brevity.** A short document that gives the wrong answer is worse than a long one that gives the right one.
- **Security / safety warnings MUST be explicit** — use MUST, NEVER, DO NOT. State caveats as full statements, not parenthetical asides.

## YFM (layer 1, required)

```yaml
---
name: <slug>                  # SKILL.md uses directory name; sub-files use <skill>-<purpose>
description: <1-2 sentence summary an agent uses to decide whether to load>
---
```

`name` and `description` are load-bearing. Other top-level fields (`title` / `tag` / `link` / `date` / `author`, plus the `x-meta:` block from [yfm](../yfm/SKILL.md)) are optional and add structure for indexing, discovery, and ontology hooks.

For Chinese-localized versions, use a parallel `SKILL.cn.md` (one per skill). Don't mix languages inside a single file.

## Mechanical checks

Live in [skill0-writer.rule.yml](skill0-writer.rule.yml). Run `x rule lint skill0-writer.rule.yml` and `x rule check -r skill0-writer.rule.yml lib/skill0/`. Coverage: YFM presence + name/description fields, name format, line count ≤ 100 (ideal 50), section order install → usage → advanced → links, English-only, no-intro / no-conclusion / no-repetition, no-orphan files.

## Truncation safety check

After writing, review at line 30: would an agent who stops here form a wrong understanding?

If yes, move the critical qualifier earlier. The first 30 lines must give a correct (if incomplete) mental model. Beyond line 30, expand with detail — the pyramid is self-correcting.

## Two-layer loading: description for matching, body for reference

Skills loaders (Claude Code, Cursor, Continue, etc.) load SKILL.md in two stages:

  1. **YFM `description:`** — auto-loaded into the agent's catalog
     for matching. The agent reads the description to decide whether
     to load the skill.
  2. **Body** — loaded on-demand after a match. Reference material.

Implications:

- **Description** = *what it is + when to load it* — keyword-dense,
  trigger-rich, terse.
- **Body** = *how to use it + reference* — examples, schemas, edge
  cases, links to deeper docs.

**Do not duplicate content across the two layers.** Whatever the
description conveys, the body should *expand on it*, not re-state
the same surface. The body's leading paragraph in particular must
not list the same features as the description — the body leads with
reference, not with a second summary.

A practical test: if you delete the description entirely and read
only the first 30 lines of the body, the agent should still see what
the skill does and when to load it. If only the description carries
that information, the body has nothing to add at the top — move
the explanation into the body and let description carry the headline.

## A skill is a knowledge pack, not a tutorial

A skill body is a **briefing for the LLM**, not a course for a beginner.

- **Capability** lives in the LLM. The body does not teach.
- **Knowledge** lives in x-cmd data tools (`x wkp` / `x rfc` / `x cve`, NVD / MITRE / GHSA) and external sources. The body points; the agent re-fetches.
- **Framing** is the skill's job: names the problem shape, the convention, the structured output, the x-cmd tool to use.

| Skill carries | Skill does NOT carry |
|---|---|
| Solving angle / convention / output shape / source pointer | Capability (LLM has) / static data (rots) / tutorials (use sidecars) |

Where specifics are too detailed or too current, push to a sidecar (`references/`, `ANALYTICS.md`) or external always-updated doc.

## External links

Collect two types: **root links** (entry points like `llms.txt`, docs index) and **useful links** (targeted links for the 20% of docs that cover 80% of use cases). List root first, useful after — AI understands order. **No duplication** unless emphasis is critical.

## Soft caveats (judgment calls)

- **Sub-files (CLEANUP.md, references/*)** can be longer than SKILL.md but first 20 lines still carry the load (same pyramid).
- **MUST** keep SKILL.md ↔ sub-file links symmetric — every sub-file (CLEANUP, ANALYTICS, TROUBLESHOOTING, references/*) must be linked from its parent SKILL.md, and SKILL.md must link to each. Enforced by `sw-1000-no-orphan-docs` in [skill0-writer.rule.yml](skill0-writer.rule.yml).
- **Speculation** — state tested facts, or label "untested".
- **Emojis** unless the skill topic requires them.

## Related

- [yfm](../yfm/SKILL.md) — YFM convention that skill0-writer enforces layer-1 of
- [naming](../naming/SKILL.md) — naming also follows the writer rules
- [skill0-writer.rule.yml](skill0-writer.rule.yml) — mechanical enforcement
