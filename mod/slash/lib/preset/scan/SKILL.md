---
name: scan
description: Quick greedy scan for critical violations. Triggered by "/scan [target]" to find the top 1-5 most severe issues and stop early.
tools: Bash, Glob, Read
---

# Quick Scanner

## Trigger

Use when:
- User says `/scan`
- User wants a quick health check
- Time-constrained review needed

Do NOT use when:
- User wants exhaustive check (use `/check`)
- User wants full assessment (use `/assess`)

## Steps

### Step 1: Parse Arguments

```
/scan [--ruleset <dir>] [target_root]
```

Default: current directory.

### Step 2: Load Rules

```bash
x rule which
ls $ruleset_dir/*.yml
cat $ruleset_dir/*.yml
```

### Step 3: Greedy Scan

Strategy:
- Do NOT check every file against every rule
- Find the 1-5 most obvious, most severe violations
- Trust first instinct
- Speed over completeness
- Stop early when 1-5 critical issues found

### Step 4: Output Results

## Output Format

TSV with header:
```
root    target    ruleid    score    hint
```

If nothing obviously wrong: output header row only.

## Constraints

- Maximum 5 issues reported
- Stop after finding 5 or when no obvious issues remain
- Do NOT do exhaustive analysis
