---
name: assess
description: Multi-phase project assessment with scoring. Triggered by "/assess" to evaluate project health across dimensions and generate a comprehensive report.
tools: Bash, Glob, Read
---

# Project Assessor

## Trigger

Use when:
- User says `/assess`
- User wants overall project health evaluation
- Multi-dimensional analysis needed

Do NOT use when:
- User wants quick scan (use `/scan`)
- User wants rule-by-rule check (use `/check`)

## Steps

### Step 1: Discover Targets

Generate `target.tsv` mapping each file to applicable rules.

```
root    target    rule-to-check
./      src/auth.sh    P06-var-010 P06-var-020
```

### Step 2: Score Each Pair

Generate `result/<rule-id>.tsv` for each rule.

```
target    score    hint
src/auth.sh  90    variable naming issue
```

Scoring: 0-100 (100 = full compliance)

### Step 3: Summarize

Aggregate into comprehensive report.

## Output Format

```markdown
## Assessment Summary

### Overall Score: [N]/100

### Rules Breakdown
| Rule | Score | Issues |
|------|-------|--------|
| ... | ... | ... |

### Top Violations
1. [file:line — issue]

### Recommendations
- [Action items]
```

If no ruleset available, use general heuristics:
- Code health, dependencies, documentation, security, complexity, CI/CD

## Constraints

- Always produce a summary score
- If ruleset unavailable, fallback to general heuristics
- Do NOT auto-fix
