---
name: issue
description: Issue management for devloop — templates for goal, rule.yml, key-results, and issue lifecycle.
---

# issue

Part of [devloop](../devloop/SKILL.md).

## New dev issue template

```
gh issue create --title "<scope>: <short description>" --body "$(cat <<'EOF'
## Goal
<one-line objective>

## Key Results
- [ ] KR-1: <verifiable outcome>
- [ ] KR-2: <verifiable outcome>

## rule.yml
```yaml
goal: "<same as above>"
keyresults:
  - kr-1: "<same as above>"
  - kr-2: "<same as above>"
rules:
  - id: <rule-id>
    name: <name>
    apply: "<file pattern>"
    level: error
    desc:
    - <criterion>
```

## Screenshots
- Before: <image or "N/A">
- After: <image or "pending">
EOF
)"
```

## Issue lifecycle

| Stage | Action | Comment content |
|-------|--------|-----------------|
| Created | `gh issue create` with template | goal, key-results, rule.yml |
| In progress | Update as work proceeds | progress notes, intermediate screenshots |
| Verified | `x rule check` passes | rule check result, after screenshot |
| Closed | `gh issue close` | commit SHA, final verification summary |

## Completion comment template

```
gh issue comment <n> --body "$(cat <<'EOF'
## Verified
- rule.yml: <code block or link>
- x rule check: PASS
- Before: <image>
- After: <image>
- Commit: <sha>
EOF
)"
```

## Rules

- **MUST** include `goal` and `keyresults` in every dev issue — no exceptions
- **MUST** post rule.yml as code block in issue body or first comment
- **MUST** screenshot before and after for frontend changes
- **NEVER** close an issue without verification evidence
- Link issues to project board for roadmap visibility
