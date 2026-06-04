---
name: skill0
description: Root index of x-cmd skill0 sub-skills. Defines the OKR-style agent workflow (goal → rule-verified results → execute), skill discovery, and agent tooling preferences. Style: principle-first, concise, delegate specifics to authoritative external sources.
---

# Skill0

Skill0 is both the **spec** and the **live prompts** of x-cmd's AI system. It defines how x-cmd agents operate and is loaded as real prompts at runtime — not documentation, but the actual instructions agents execute.

1. **Sub-skills** (agent-browser, lovable, rule, etc.) — self-contained SKILL.md files that teach an agent how to use a tool or follow a convention
2. **Agent workflow** — OKR-style process, skill discovery, execution preferences — all defined here and used by x-cmd agents in practice

**Content philosophy**: focus on stable principles. Avoid volatile info (API details, version-specific behavior, tutorials). Curate vetted authoritative links that agents can fetch and use at runtime. See [skill0-writer](skill0-writer/SKILL.md) for conventions including link curation rules.

## Agent workflow (OKR)

### (GOAL) Clarify the objective before acting

### (RESULT-VERIFIED-BY-RULE-TEST) Define verifiable outcomes via `x rule` and `x test`

See the `rule` sub-skill, or `x rule -h` for the shell-integrated workflow.

### With rules in place, find strategies and execute with full initiative

0. Browse skill0 sub-skills — principle-first, concise style
1. `x skill` — x-cmd's curated, human-vetted skill catalog
2. `x clawhub` — global skill registry. **Caution**: free upload, MUST check `x clawhub skill moderate <name>` for auto-generated safety report -- also noted it is AI-generated, not human-reviewed.

**Execution preferences**

`x roadmap` (project management), `x cron` (scheduled tasks), `x agent job` (background agents), `x ondb` (ontology), `x wiki` / `x llmwiki` (wiki). Run `x [mod] --help` or check the corresponding sub-skill.

Unlike vendor-specific mechanisms, these are public, CLI-manageable, and cross-vendor.
