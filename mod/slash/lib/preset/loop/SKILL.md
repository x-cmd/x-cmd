---
name: loop
description: Schedule recurring tasks with notifications. Triggered by "/loop <interval> <prompt>" to set up periodic monitoring.
tools: Bash
---

# Loop Runner

## Trigger

Use when:
- User says `/loop <interval> <prompt>`
- User wants recurring monitoring or periodic execution

## Steps

### Step 1: Parse Arguments

```
/loop <interval> <prompt>
```

Interval patterns:
| Pattern | Cron Expression |
|---------|----------------|
| `Nm` (N ≤ 59) | `*/N * * * *` |
| `Nh` (N ≤ 23) | `0 */N * * *` |
| `Nd` | `0 0 */N * *` |

Round non-dividing intervals to nearest clean value.

### Step 2: Clarify Intent

Ask user:
1. What to monitor (parse prompt)
2. How to execute (which x-cmd module or command)
3. Where to store results

### Step 3: Configure Notification

Ask before creating:
- Memory (default) — store for later review
- Mailbox — notification on new results
- Other user-specified method

### Step 4: Create Cron Job

```bash
x cron add \
    --name "loop-$(date +%Y%m%d%H%M%S)" \
    --desc "<description>" \
    "<cron-expression>" \
    "<full-command>"
```

### Step 5: Execute Immediately

Run the command now; do not wait for first cron fire.

### Step 6: Confirm

Report to user:
- Job name and cron expression
- Human-readable cadence
- Monitoring target
- Result storage location
- Cancellation: `x cron rm <name>`

## Constraints

- Always ask about result storage before creating
- Always execute immediately
- Round messy intervals and inform user
