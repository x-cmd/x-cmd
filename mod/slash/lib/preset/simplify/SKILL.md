---
name: simplify
description: Review code for readability, reuse, and simplicity. Triggered by "/simplify" when user wants to refactor complex code, remove duplication, or improve clarity.
tools: Bash, Read
---

# Code Simplifier

## Trigger

Use when:
- User says `/simplify`
- User asks to refactor, clean up, or make code more readable
- Complex functions, deep nesting, or duplication detected

Do NOT use when:
- User asks for performance optimization (use `/optimize`)
- User asks for security audit (use `/security-review`)

## Steps

### Step 1: Gather Code

```bash
git diff main..HEAD --stat
```

For specific files:
```bash
cat path/to/file
```

### Step 2: Analyze Issues

Checklist:
- **Readability**: Functions >50 lines, nesting >3 levels, unclear names, magic numbers
- **Reuse**: Duplicated blocks, similar patterns, custom implementations where stdlib exists
- **Complexity**: Over-engineering, premature optimization, feature envy, shotgun surgery

### Step 3: Generate Report

Use the output format below.

## Output Format

```markdown
## Simplification Review

### Readability Issues
| File | Line | Issue | Suggestion |
|------|------|-------|------------|
| ... | ... | ... | ... |

### Duplication Found
```python
# file1:X and file2:Y are identical
# → Extract to shared module
```

### Complexity Concerns
- [Specific issues]

### Suggested Refactors
1. [Action with file:line]
2. [Action with file:line]
```

## Constraints

- Only suggest changes with clear benefit
- Three similar lines is better than premature abstraction
- Prefer explicit over clever
- Do NOT auto-apply changes; present suggestions and wait for user confirmation
