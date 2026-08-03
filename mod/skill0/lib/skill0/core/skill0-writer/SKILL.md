---
name: skill0-writer
description: Writing conventions for skill0 documents — pyramid structure, line limits, and layout rules.
metadata:
  related: "yfm,naming"
---

# skill0-writer

Skill0 documents follow the **pyramid principle**: agents may read only the first 10–30 lines, so the most important information must come first. Detail beyond line 30 is the bonus, not the load.

## Things no rule catches

- **Clarity over brevity.** A short document that gives the wrong answer is worse than a long one that gives the right one.
- **Security / safety warnings MUST be explicit** — use MUST, NEVER, DO NOT. State caveats as full statements, not parenthetical asides.
- **Don't elaborate common knowledge.** If a convention word plus one or two sentences conveys the point, stop. The reader already knows what YAML, git, and a cache are; spend the context on what is specific to this repo. Justification is the usual offender — give a rule's reason only when it looks wrong without one. (`sw-1200`)
- **Tables only for real matrices.** 3+ columns whose rows must be read against each other. A two-column table is a list wearing table syntax — write the list. A dataset belongs in an external `.tsv` beside the doc, linked, so `x tsv` can query it. (`sw-1250`)

## YFM — `SKILL.md` only

```yaml
---
name: <slug>                  # must equal the directory name
description: <1-2 sentence summary an agent uses to decide whether to load>
---
```

`name` and `description` are load-bearing. Everything else nests under the `metadata:` block from [yfm](../yfm/SKILL.md) as comma-separated scalars — optional, and adds structure for indexing, discovery, and ontology hooks.

**Sub-files carry no YFM.** Only `SKILL.md` is filtered by a loader, so only it needs front matter. Every other file (`references/*`, `usecase/*`, `EXAMPLE.md`, `*.report.md` …) is read directly by an agent that already decided to open it — YFM there is pure token cost, restating a purpose the title and first line already give. Start those files at the `#` heading. Deviating needs a stated reason in the file itself.

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

**Do not duplicate content across the two layers.** Whatever the description conveys, the body should *expand on it*, not re-state the same surface. The body's leading paragraph in particular must not list the same features as the description — the body leads with reference, not with a second summary.

A practical test: if you delete the description entirely and read only the first 30 lines of the body, the agent should still see what the skill does and when to load it. If only the description carries that information, the body has nothing to add at the top — move the explanation into the body and let description carry the headline.

## A skill is a knowledge pack, not a tutorial

A skill body is a **briefing for the LLM**, not a course for a beginner.

- **Capability** lives in the LLM. The body does not teach.
- **Knowledge** lives in x-cmd data tools (`x wkp` / `x rfc` / `x cve`, NVD / MITRE / GHSA) and external sources. The body points; the agent re-fetches.
- **Framing** is the skill's job: names the problem shape, the convention, the structured output, the x-cmd tool to use.

A skill carries the solving angle, the convention, the output shape, and source pointers. It does **not** carry capability (the LLM already has it), static data (it rots), or tutorials (use sidecars).

Where specifics are too detailed or too current, push to a sidecar (`references/`, `ANALYTICS.md`) or external always-updated doc.

## External links

Collect two types: **root links** (entry points like `llms.txt`, docs index) and **useful links** (targeted links for the 20% of docs that cover 80% of use cases). List root first, useful after — AI understands order. **No duplication** unless emphasis is critical.

## Soft caveats (judgment calls)

- **Sub-files (CLEANUP.md, references/*)** can be longer than SKILL.md but first 20 lines still carry the load (same pyramid).
- **MUST** link to every sub-file from its parent SKILL.md (forward link required). Back-link to parent SKILL.md from a sub-file is **optional** — usecase files reference the parent implicitly by their path. Enforced by `sw-1000-no-orphan-docs` in [skill0-writer.rule.yml](skill0-writer.rule.yml).
- **Speculation** — state tested facts, or label "untested".
- **Emojis** unless the skill topic requires them.

## Related

- [yfm](../yfm/SKILL.md) — YFM convention that skill0-writer enforces layer-1 of
- [naming](../naming/SKILL.md) — naming also follows the writer rules
- [skill0-writer.rule.yml](skill0-writer.rule.yml) — mechanical enforcement
