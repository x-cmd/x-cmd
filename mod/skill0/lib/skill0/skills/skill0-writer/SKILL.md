---
name: skill0-writer
description: Writing conventions for skill0 documents — pyramid structure, line limits, and layout rules.
---

# skill0-writer

## Core principle: pyramid structure

Agents may only read the first 10–30 lines. Put the most important information first.

## YAML front matter (YFM)

Every `.md` file in `lib/skill0/skills/` MUST start with a YFM block — including `SKILL.md`, sub-files (`ANALYTICS.md`, `CLEANUP.md`, `TROUBLESHOOTING.md`, `EXAMPLE.md`), and anything in `references/`, `template/`, etc.

Required fields:

- `name` — short slug. For a `SKILL.md`, use the skill directory name. For sub-files, use `<skill>-<purpose>` (kebab-case).
- `description` — one or two sentences, written for an agent to decide when to load this file.

Why: agent loaders and runtime filters key on YFM to decide which file to surface. A file without YFM is invisible to the filter and treated as dead text.

Format:
```
---
name: <slug>
description: <one or two sentence summary>
---
```
But **respect dependency order** — do not put usage before install/setup.

Recommended section order for SKILL.md:

1. **Install / setup** — must come first, without it nothing else works
2. **Most important usage** — the 80% use case
3. **Advanced / secondary** — remaining sections
4. **Links** — references and related docs

## SKILL.md rules

- **Clarity over brevity.** Simplification MUST NOT make the skill unreadable or unusable.
- **≤ 50 lines** ideal, **≤ 100 lines** hard limit. Agents may truncate at ~50 lines — the first 50 must be self-sufficient for the 80% use case. Detail goes in lines 50–100.
- Minimize blank lines — every line counts against truncation.
- Single-line prose where possible — collapse multi-line paragraphs into one line.
- English only
- Prefer code blocks, tables, bullet points. Prose is acceptable when needed to explain concepts that can't fit in a table or code block.
- Link to separate files for detailed content: `[Title](file.md)`
- No motivational text, no "let's get started", no conclusions
- **Security and safety warnings must be explicit and forceful** — use MUST, NEVER, DO NOT. State caveats and limitations as full statements (`-- also noted ...`), not parenthetical asides. Do not sacrifice clarity for brevity when safety is at stake. A weak warning is worse than no warning.

## External links

Skill0 delegates volatile details to authoritative external sources. Collect two types of links:

- **Root links** (e.g. `llms.txt`, docs index) — entry points where agents can explore the full documentation tree
- **Useful links** — targeted links for common agent topics (80/20 principle: the 20% of docs that cover 80% of use cases)

The value is not in collecting links, but in vetting which ones give agents correct, actionable knowledge at runtime.

List root links first, useful links after — no explicit labels needed, AI understands order.

**No duplication**: if a link already appears in the body text, do not repeat it in the "For more information" section unless it is critical enough to warrant emphasis.

## Separate file rules (CLEANUP.md, ANALYTICS.md, etc.)

- Can be longer but still follow pyramid structure
- Most critical info in the first 20 lines
- Use tables and code blocks over paragraphs
- Section order: actionable → explanatory → reference
- **No orphan files** — every separate file must be linked from its SKILL.md,
  and the separate file must link back to SKILL.md

## Formatting

- Code blocks: no language annotation needed for short snippets, use `bash` for copy-paste commands
- Tables for structured data (paths, sizes, comparisons)
- Bold for key terms and warnings
- No emojis unless the skill topic requires them
- No blank lines inside code blocks — every line should carry information
- Minimize vertical whitespace between sections

## What to avoid

- No introductory paragraphs ("agent-browser is a...")
- No trailing summaries or conclusions
- No repeated content across files — link instead
- No Chinese text — English only in skill0
- No speculation — state tested facts, or say "untested"

## Scope qualifiers

When a property applies to **all** options (e.g. "no re-authorization for any cleanup"),
state it once globally at the top. Do not attach it to a single section — that implies
the opposite for other sections.

## Truncation safety check

After writing, review at line 30: **would an agent who stops here form a wrong understanding?**

If yes — move the critical qualifier earlier. The first 30 lines must give a correct (if incomplete) mental model.
Beyond line 30, expand with detail — the pyramid is self-correcting: deeper = more context.

**Simplification must not mislead.** A short document that gives the wrong answer is worse than a long document that gives the right one.
