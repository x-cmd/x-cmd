---
name: devloop
description: Goal-driven development loop — define objective, write rules with key-results, verify visually, sync to issue tracker.
---

# devloop

## Setup

```
x rule init :ror                          # or project-specific ruleset
x env use agent-browser                   # for visual verification
```

## Workflow

```
goal → rule.yml → code → verify → issue
```

### 1. Define goal → write rule.yml

Before coding, create a rule.yml for the task:

```yaml
goal: "Fix English version showing Chinese tags in Features section"
keyresults:
  - kr-1: "English mode Features tags are all English"
  - kr-2: "Chinese mode Features tags remain Chinese"
  - kr-3: "Build passes with no regressions"
rules:
  - id: kr-1-verify
    name: english-tags-no-chinese
    apply: "src/components/Features.tsx"
    level: error
    desc:
    - When language=en, all details[] items must be English
    - No Chinese characters in any tag badge in English mode
```

Rule fields: `id`, `name`, `apply`, `level`, `desc`, `tldr`. See `x rule -h`.

**MUST** include `goal` and `keyresults` — the two mandatory fields for every dev task.

### 2. Execute → visual verification (frontend)

```
agent-browser open <url> --session <proj> --headed
agent-browser --session <proj> screenshot /tmp/before.png
# ... make changes ...
agent-browser --session <proj> screenshot /tmp/after.png
```

**MUST** screenshot before and after. Compare against intent:
1. AI vision check: does after.png match the goal?
2. If mismatch → iterate and re-screenshot
3. **Scrub all privacy data** (tokens, emails, personal info) before uploading

### 3. Verify with x rule

```
x rule scan <files>     # fast (~1 min), for inner loop
x rule check <files>    # thorough (~10 min)
x rule audit <files>    # full report (~30 min)
```

### 4. Sync to issue tracker

See [issue/SKILL.md](../issue/SKILL.md). Minimum: post goal, key-results, rule.yml, before/after screenshots to the issue.

## Agent tools

| Tool | Use |
|------|-----|
| `x rule scan` | Quick check during iteration |
| `x rule check` | Full compliance before commit |
| `agent-browser screenshot` | Visual proof before/after |
| `gh issue create/comment` | Sync goal + rule.yml to tracker |
