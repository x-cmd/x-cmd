---
name: skill0
description: "Root index of x-cmd skill0 sub-skills. Defines the OKR-style agent workflow (goal → rule-verified results → execute), skill discovery, and agent tooling preferences. Style: principle-first, concise, delegate specifics to authoritative external sources."
metadata:
  related: "devloop,skill0-writer,yfm,ontology-database,rule"
---

# Skill0

## Skill0 encodes principles, not data

The LLM absorbs common sense continuously; skill0's job is to encode conventions and source pointers, then thin over time as the LLM catches up. Verify via first-party data (`x rfc`, `x cve`, `x wkp`, `agent-browser`) and current best practice (`x skill`, `x clawhub`), then reconstruct with formal logic instead of memorization.

## Sub-skills form a directed graph across 4 buckets

Buckets: `core/`, `data/`, `it/`, `life/`. Path: `<bucket>/<slug>/SKILL.md`. The machine-readable catalog (name + description) is at [index.tsv](index.tsv). One doc used to live here as a manager/lifestyle interaction guide; it was moved to [.x-cmd/todo/ai-human-interaction-guide.md](../../.x-cmd/todo/ai-human-interaction-guide.md) as it is not part of the skill0 graph.

## Goal → keyresults → x-rule is the OKR workflow

Objective: What to achieve
Key Results: How to verify
Verification: `x rule check/audit`

## After scaffolding, prefer x-cmd tools for execution

- `x skill` — x-cmd's curated, human-vetted skill catalog.
- `x clawhub` — global skill registry. **Caution**: free upload, MUST run `x clawhub skill moderate <name>` for the auto-generated safety report.
- `x roadmap`, `x cron`, `x agent job`, `x ondb`, `x wiki` / `x llmwiki` — project management, scheduling, background agents, ontology, wiki. Run `x [mod] --help`.

## Every SKILL.md must pass skill0-writer

See [skill0-writer](core/skill0-writer/SKILL.md) for the conventions.
