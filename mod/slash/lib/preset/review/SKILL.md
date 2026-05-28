---
name: review
description: Review pull requests or code changes. Triggered by "/review [pr_link]" or when user asks to review pending changes.
tools: Bash, Read
---

# PR Reviewer

## Trigger

Use when:
- User says `/review` with a PR link
- User asks to review pending changes

Do NOT use when:
- User asks for security-only audit (use `/security-review`)
- User asks for performance optimization (use `/optimize`)
- User asks for refactoring/simplification (use `/simplify`)

## Steps

### Step 1: Fetch Changes

If PR link provided:
```bash
gh pr view <pr> --json title,body,state,base,head,files,additions,deletions,changedFiles
gh pr diff <pr>
```

If local changes:
```bash
git diff main..HEAD
git diff --name-only main..HEAD
```

### Step 2: Analyze

Review dimensions:
- **Correctness**: Logic errors, edge cases, race conditions
- **Design**: Architecture fit, abstraction level
- **Maintainability**: Readability, naming, test coverage
- **Security**: Surface-level check for secrets and injection risks
  - If deep security concerns found, flag for `/security-review`

### Step 3: Generate Report

Use the output format below.

## Output Format

```markdown
## PR Summary
- **Title**: ...
- **Author**: ...
- **Scope**: N files | +N/-N lines

## Changes Overview
[High-level summary of what changed and why]

## Detailed Review

### Approved
[What was done well]

### Suggestions
[Specific improvements with file:line references]

### Concerns
[Issues that need addressing before merge]

## Recommendation
[Approve / Request Changes / Comment]
```

## Constraints

- Focus on changes, not pre-existing code
- Do NOT auto-fix; suggest and let user decide
- Escalate security concerns to `/security-review` if beyond surface level
