---
name: skill0
description: "Root index of x-cmd skill0 sub-skills. Defines the OKR-style agent workflow (goal → rule-verified results → execute), skill discovery, and agent tooling preferences. Style: principle-first, concise, delegate specifics to authoritative external sources."
x-meta:
  type: Framework
  status: stable
  related: [devloop, skill0-writer, yfm, ontology-database, rule]
  owner: person:lijunhao
---

# Skill0

## Design philosophy

skill0 is the **zero-skill** — a special class that aggregates
meta-knowledge across domains (best practices + data/behavioral
conventions, e.g., rule, score) and reduces its information density by
design. The LLM continuously absorbs latest knowledge, methodology,
and chain-of-thought — but data hallucinations have no solution, and
community/personal skills may be outdated or insecure. skill0 urges
the LLM to use tools (x rfc, x cve, x wkp, agent-browser) to fetch in
real time from first-party docs, the network, and the skill community
based on the current environment.

Principle: read with understanding → verify via first-party data +
formal logic → form a personalized skill set + memory.

Convergence: as LLMs absorb more common sense, skill0 thins to
conventions + source pointers.

## How x-cmd modules use skill0

Skill0 is both the spec and the live prompts of x-cmd's AI system.
x-cmd's AI modules (e.g., agent, claude, codex) directly reference
skill0's prompts and files, providing shell-level standard practices
that complement the methodology.

## Sub-skills

skill0 is a **directed graph** of sub-skills grouped into 4 buckets (`core/`, `data/`, `it/`, `life/`). Pick a starting point by the task shape:

- Goal-driven work — devloop is the orchestrator and drives rule (rule.yml), score (KRs), install (env), agent-browser (visual verify), issue (tracker), repo (sync).
- Conventions to know before writing — skill0-writer, yfm, ontology-database.
- Frameworks (process primitives) — rule, score, naming, prompt.
- Tools, grouped by bucket — single-purpose capabilities:
    - core/ — install, issue, meme, repo, x-cmd
    - data/ — ccal, knowledge
    - it/ — agent-browser, csv, env, git, ip, qr, time, tldr, tsv
    - life/ — lovable

Relative path from this file: `<bucket>/<slug>/SKILL.md` (no `../`). Example: [devloop](core/devloop/SKILL.md).

The machine-readable catalog (name = `<bucket>/<slug>`, description) lives at [index.tsv](index.tsv), sorted by bucket then by importance within bucket. Skipped from the catalog: `pet` (placeholder per its own description), `core/ai-human-interaction-guide` (README only, no SKILL.md), and 3 empty SKILL.md files (`data/api-less-website`, `life/health`, `life/travel`) — directories exist on disk but content has not been written yet.

## Agent workflow (OKR)

| OKR layer | x-cmd | Purpose |
|-----------|-------|---------|
| Objective | `goal` | Qualitative direction — what to achieve |
| Key Results | `keyresults` | Quantitative outcomes — how to verify |
| Scoring | `x rule check/audit` | Mechanized verification — pass/fail per rule |

Structure is OKR-equivalent: goal (qualitative) → keyresults (quantitative) → x rule (scoring).

### (GOAL) Clarify the objective before acting

### (RESULT-VERIFIED-BY-RULE-TEST) Define verifiable outcomes via `x rule` and `x test`

Enforced by `.x-cmd/rule/goal.rule.yml` and `.x-cmd/rule/keyresult.rule.yml`:

```
x rule lint .x-cmd/rule/           # verify rule structure
x rule check -r .x-cmd/rule/ ...   # check files against rules
```

| Rule | Level | What it checks |
|------|-------|----------------|
| `goal-must-exist` | error | rule.yml has a `goal` field |
| `goal-must-be-concise` | warn | goal is one sentence ≤ 80 chars |
| `keyresult-must-exist` | error | rule.yml has `keyresults` list ≥ 1 |
| `keyresult-must-be-verifiable` | warn | each keyresult is testable |

See the `rule` sub-skill, or `x rule -h` for the shell-integrated workflow.

### With rules in place, find strategies and execute with full initiative

0. Browse skill0 sub-skills — principle-first, concise style
1. `x skill` — x-cmd's curated, human-vetted skill catalog
2. `x clawhub` — global skill registry. **Caution**: free upload, MUST check `x clawhub skill moderate <name>` for auto-generated safety report -- also noted it is AI-generated, not human-reviewed.

**Execution preferences**

`x roadmap` (project management), `x cron` (scheduled tasks), `x agent job` (background agents), `x ondb` (ontology), `x wiki` / `x llmwiki` (wiki). Run `x [mod] --help` or check the corresponding sub-skill.

Unlike vendor-specific mechanisms, these are public, CLI-manageable, and cross-vendor.

## Rules

- **MUST pass skill0-writer** — every SKILL.md must comply with [skill0-writer](skills/skill0-writer/SKILL.md) conventions
- **MUST include goal-* and keyresult-* rules** — every dev rule.yml must contain at least one `goal-*` rule and one `keyresult-*` rule. These ARE rules (not metadata), enforceable by `x rule`. See [devloop](skills/devloop/SKILL.md) and `.x-cmd/rule/` for examples.
