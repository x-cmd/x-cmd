---
name: check
description: Comprehensive rule-based check. Triggered by "/check [target]" to evaluate all source files against project rules and report every violation.
tools: Bash, Glob, Read
---

# Rule Checker

## Trigger

Use when:
- User says `/check`
- User wants to verify code against project rules
- Pre-commit or CI validation needed

Do NOT use when:
- User wants quick scan of top issues (use `/scan`)
- User wants multi-dimensional assessment (use `/assess`)

## Steps

### Step 1: Parse Arguments

```
/check [--ruleset <dir>] [target_root]
```

Default: current directory.

### Step 2: Load Rules

```bash
x rule which      # locate ruleset
ls $ruleset_dir/*.yml
cat $ruleset_dir/*.yml
```

### Step 3: Evaluate All Files Against All Rules

For each file under target_root:
1. Determine applicable rules based on rule `apply` field
2. Check each applicable rule
3. Record violations (score < 81)

Rule `apply` values:
| Apply Value | Files Matched |
|-------------|---------------|
| `all posix shell files` | `*.sh` |
| `all shell files` | `*.sh`, `*.bash`, `*.zsh` |
| `all yaml files` | `*.yml`, `*.yaml` |
| `all json files` | `*.json` |
| `all source files` | source code files |
| `all files` | any file |

### Step 4: Output Results

## Output Format

TSV with header:
```
root    target    ruleid    score    hint
```

Scoring:
- 0-10: Complete violation
- 11-50: Significant issues
- 51-80: Minor issues (still reported)
- 81-100: No violation (omitted from output)

If all pass: output header row only.

## Constraints

- Check EVERY file against EVERY applicable rule (exhaustive, not greedy)
- Do NOT stop early
- Do NOT auto-fix violations
