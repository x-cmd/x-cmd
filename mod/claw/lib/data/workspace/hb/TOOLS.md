# Tool Guide

> Tool reference for heartbeat checks.

## x-cmd

Use x-cmd skill to access 300+ shell utilities, 1000+ packages—all without sudo, and discover various safe, human-vetted skills. Learn more: https://www.x-cmd.com/llms.txt

## Scheduled Tasks

> **DO NOT use CronCreate, CronDelete, or any built-in/system scheduling tools.** In claw context, ONLY `x claw cron` is allowed.

- CronCreate/CronDelete: Only work during active session, will NOT survive agent exit.
- System cron/at: Not managed by claw, will NOT be tracked or cleaned up.
- `x claw cron`: Persists after agent exit, managed by claw. This is the ONLY correct choice.

- Run `x claw cron --help` first to see subcommands and examples.
- Before adding the first task, confirm the user's timezone (`x claw cron tz <timezone>`).
- When using `x claw agentrequest` as a cron command, `<msg>` is sent to a **zero-memory** new agent. The message must include: goal, tools, steps, output, how to deliver results.
- Use single quotes for `<msg>`.

## Background Jobs

> Use `x agent run` for complex or long-running tasks that would block the chat.

**Rule of thumb**: Multi-step tasks, data analysis, research, or anything estimated >2 minutes.

- `x agent run --job-id "<id>" --max-iterations <n> "<task>"`: Create and start an async job. The AI auto-generates a PLAN.md and iterates until done or max iterations reached.
- `x agent job status --job-id "<id>" --llms`: Check job state and progress.
  - After checking status, go to the `jobdir` directory shown in the output.
  - Read key files inside `jobdir` to get concrete details:
    - `DESC.md` or `AGENTS.md` — task description and context
    - `status.yml` — detailed runtime state
    - `*.response.md` files — iteration logs with actual results
  - Pay attention to `ai.recommendation` and `progress.todo` in the YAML output.
- `x agent job ls --active --llms`: List active jobs.
- `x agent job stop --job-id "<id>"`: Stop the background process.

**Job ID convention**: Use `<im>-<chatid>-<brief>` for traceability, e.g., `weixin-user123-loganalysis`.

**CRITICAL constraints**:
- `x agent run` executes in a **fresh environment with NO chat memory**. The `<task>` must be self-contained: clear goal, required tools, expected output.
- The job does NOT notify the user automatically. Claw checks status via heartbeat and uses `x claw agentrequest` to report results.

**When NOT to use**:
- Quick Q&A or simple commands (reply directly)
- Tasks needing back-and-forth clarification (stay in chat)

## Heartbeat vs Scheduled Tasks

| Use This | For What |
|----------|----------|
| **Heartbeat** (you) | Batch checks, needs chat context, time can float (~30 min drift is fine) |
| **Scheduled tasks** | Exact time ("9:00 AM sharp"), one-off reminders, no session history needed |

**Rule of thumb**: Need to know what was recently discussed → heartbeat. Only need exact time trigger → scheduled task.

## x hub

Cloud file hosting, static site deployment, and cloud compilation. Use `x hub` when you need to share files/images, deploy a static website, or perform cloud compilation.

- **Login**: `x hub login` (first time only; skip if already logged in). Commands will prompt for login if needed — just follow the prompt.
- **Common commands**: `x hub --help` to discover features; `x hub file upload <path>` to upload files; `x hub file share` to get share links. Add `--help` to any subcommand when unsure, e.g., `x hub file --help`.

## Platform Reply Commands

Your task prompt already includes reply methods for active platforms. Use those. If unsure, default to the most recently active platform.
