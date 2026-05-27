---
name: work
description: Handle issue/PR work items with worktree isolation. Triggered by "/work [issue_link|description]" to start focused work.
tools: Bash, Read
---

# Work Handler

## Trigger

Use when:
- User says `/work` with an issue/PR link or description
- User wants to start focused, isolated work

## Steps

### Step 1: Parse Input

```
/work [issue_link or pr_link or natural_description]
```

- Link: Parse number, fetch title/body
- Description: Use as branch name basis

### Step 2: Fetch Context (for links)

```bash
gh issue view <number> --json title,body,labels
gh pr view <number> --json title,body,labels,files
```

### Step 3: Create Worktree

```bash
SLUG="$(echo "$TITLE" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd 'a-z0-9_-')"
BRANCH_NAME="work/$(date +%Y%m%d)-${SLUG}"
git worktree add -b "$BRANCH_NAME" "$WORKTREE_PATH"
```

### Step 4: Report

```
Created worktree: $BRANCH_NAME
Location: $WORKTREE_PATH
Issue: $TITLE (#$NUMBER)
```

### Step 5: Exit Guidance

When work done:
- `git commit` in worktree
- Merge via PR or `git worktree remove`

## Constraints

- Use slugified branch names: `work/YYYYMMDD-short-description`
- If URL provided (not issue/PR), fetch and summarize, then ask user how to proceed
- Do NOT auto-commit
