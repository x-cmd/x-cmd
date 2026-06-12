---
name: claw-background-jobs
description: |
  Claw background job management using x agent run and x agent job.
  Use when the agent needs to offload tasks. As Manager in an interactive terminal, offload aggressively — almost everything beyond a single quick command should run in the background.
---

# Claw Background Jobs Skill

## When to Use

Use `x agent run` for ANY non-trivial task — the terminal must never block:
- Multi-step tasks
- File operations
- Data analysis
- Research
- External API calls
- Anything beyond a single simple command

## When NOT to Use

- Single simple commands that complete in <10 seconds (reply directly)
- Tasks needing back-and-forth clarification (stay in chat, but still offload once direction is clear)

## Commands

- `x agent run --job-id "<id>" --max-iterations <n> "<task>"`: Create and start an async job. The AI auto-generates a PLAN.md and iterates until done or max iterations reached.
- `x agent job status --job-id "<id>" --llms`: Check progress, iteration count, and whether the job is active/completed (YAML output for parsing).
- `x agent job ls --active --llms`: List all active jobs.
- `x agent job stop --job-id "<id>"`: Stop the background process.

## Job ID Convention

Use `manager-<brief>` for traceability, e.g., `manager-loganalysis`.

## After Offloading — Quick Wrap-up then STOP

`x agent run` returns immediately — the job runs asynchronously in the background. Do NOT linger. Do the wrap-up right away, then STOP.

**Required wrap-up**:
1. Record the job in HEARTBEAT.md (see `heartbeat-delegation` skill for format)
2. Write a brief memory entry: user request + job ID + your ack message
3. Reply to the user: "Started `<job-id>`. I'll follow up via heartbeat when it's done."

**Do NOT**:
- Run `x agent job status` to verify
- Wait, poll, or monitor the job
- Run any other commands
- Continue the conversation beyond the ack

The heartbeat agent monitors all background jobs and reports results. Trust the system. Exit immediately so the user can ask the next question.

## Critical Constraints

- `x agent run` executes in a **fresh environment with NO chat memory**. The `<task>` must be self-contained: clear goal, required tools, expected output.
- The job does NOT notify the user automatically. Claw checks status via heartbeat and uses `x claw agentrequest` to report results.
