---
name: claw-background-jobs
description: |
  Claw background job management using x agent run and x agent job.
  Use when the agent needs to offload complex or long-running tasks that would block the chat.
---

# Claw Background Jobs Skill

## When to Use

Use `x agent run` for tasks estimated >2 minutes or that would block the chat:
- Multi-step tasks
- Data analysis
- Research
- Anything expected to take >2 minutes

## When NOT to Use

- Quick Q&A or simple commands (reply directly)
- Tasks needing back-and-forth clarification (stay in chat)

## Commands

- `x agent run --job-id "<id>" --max-iterations <n> "<task>"`: Create and start an async job. The AI auto-generates a PLAN.md and iterates until done or max iterations reached.
- `x agent job status --job-id "<id>" --llms`: Check progress, iteration count, and whether the job is active/completed (YAML output for parsing).
- `x agent job ls --active --llms`: List all active jobs.
- `x agent job stop --job-id "<id>"`: Stop the background process.

## Job ID Convention

Use `<im>-<chatid>-<brief>` for traceability, e.g., `weixin-user123-loganalysis`.

## Critical Constraints

- `x agent run` executes in a **fresh environment with NO chat memory**. The `<task>` must be self-contained: clear goal, required tools, expected output.
- The job does NOT notify the user automatically. Claw checks status via heartbeat and uses `x claw agentrequest` to report results.
