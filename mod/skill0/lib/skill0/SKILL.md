---
name: skill0
description: Root index of x-cmd skill0 sub-skills. Defines the OKR-style agent workflow (goal → rule-verified results → execute), skill discovery, and agent tooling preferences. Style: principle-first, concise, delegate specifics to authoritative external sources.
---

# Skill0

Skill0 is both the **spec** and the **live prompts** of x-cmd's AI system. It defines how x-cmd agents operate and is loaded as real prompts at runtime — not documentation, but the actual instructions agents execute.

1. **Sub-skills** (agent-browser, lovable, rule, etc.) — self-contained SKILL.md files that teach an agent how to use a tool or follow a convention
2. **Agent workflow** — OKR-style process, skill discovery, execution preferences — all defined here and used by x-cmd agents in practice

**Content philosophy**: focus on stable principles. Avoid volatile info (API details, version-specific behavior, tutorials). Curate vetted authoritative links that agents can fetch and use at runtime. See [skill0-writer](skills/skill0-writer/SKILL.md) for conventions including link curation rules.

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
