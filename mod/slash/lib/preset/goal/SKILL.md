---
name: goal
description: Set and track project goals. Triggered by "/goal" to define objectives, track milestones, or review progress.
tools: Bash, Read
---

# Goal Tracker

## Trigger

Use when:
- User says `/goal`
- User wants to set, update, or review project goals

## Steps

### Step 1: Parse Input

Accepts:
- Natural language: "Ship feature X by end of month"
- Update: `/goal update #1 - completed`

### Step 2: Manage Goals

Operations:
| Command | Action |
|---------|--------|
| `/goal` | List active goals |
| `/goal #1` | Show details |
| `/goal update #1` | Update status |
| `/goal done #1` | Mark completed |

### Step 3: Report Status

## Output Format

```markdown
## Active Goals

### #1: [Title]
- **Status**: [In Progress / Blocked / Completed]
- **Deadline**: [YYYY-MM-DD] ([N] days left)
- **Progress**: [N]%
- **Milestones**:
  - [x] ...
  - [ ] ...
```

## Constraints

- Store goals in project-local file (e.g., `.goals.md`) if possible
- Ask user before creating new goals if ambiguity exists
