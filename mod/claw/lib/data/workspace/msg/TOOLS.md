# Tool Guide

> Guide for external tools, APIs, and commands.

## x-cmd

Use x-cmd skill to access 300+ shell utilities, 1000+ packages—all without sudo, and discover various safe, human-vetted skills. Learn more: https://www.x-cmd.com/llms.txt

## Scheduled Tasks

> **DO NOT use CronCreate, CronDelete, or any built-in/system scheduling tools.** In claw context, ONLY `x claw cron` is allowed.

- CronCreate/CronDelete: Only work during active session, will NOT survive agent exit.
- System cron/at: Not managed by claw, will NOT be tracked or cleaned up.
- `x claw cron`: Persists after agent exit, managed by claw. This is the ONLY correct choice.

- Run `x claw cron --help` first to see all subcommands and examples.
- Before adding the first task, confirm the user's timezone (`x claw cron tz <timezone>`).
- When using `x claw agentrequest` as a cron command, `<msg>` is sent to a **zero-memory** new agent. The message must include: goal, tools, steps, output, how to deliver results.
- Use single quotes for `<msg>`. Bad: `'Check HN'`. Good: `'Use x hn top for top 5 posts. Extract title, URL, score. Send: x weixin send --text <result>'`.

## Background Jobs

> Use `x agent run` for complex or long-running tasks that would block the chat.

**Rule of thumb**: Multi-step tasks, data analysis, research, or anything estimated >2 minutes.

- `x agent run --job-id "<id>" --max-iterations <n> "<task>"`: Create and start an async job. The AI auto-generates a PLAN.md and iterates until done or max iterations reached.
- `x agent job status --job-id "<id>" --llms`: Check progress, iteration count, and whether the job is active/completed (YAML output for parsing).
- `x agent job ls --active --llms`: List all active jobs.
- `x agent job stop --job-id "<id>"`: Stop the background process.

**Job ID convention**: Use `<im>-<chatid>-<brief>` for traceability, e.g., `weixin-user123-loganalysis`.

**CRITICAL constraints**:
- `x agent run` executes in a **fresh environment with NO chat memory**. The `<task>` must be self-contained: clear goal, required tools, expected output.
- The job does NOT notify the user automatically. Claw checks status via heartbeat and uses `x claw agentrequest` to report results.

**When NOT to use**:
- Quick Q&A or simple commands (reply directly)
- Tasks needing back-and-forth clarification (stay in chat)

## Heartbeat vs Scheduled Tasks

| Use Case | Mechanism | Reason |
|----------|-----------|--------|
| Batch periodic checks (inbox + tasks + notifications) | Heartbeat | Consolidated checks, uses session context |
| Exact time ("Every Monday at 9 AM") | Scheduled task | Precise scheduling, isolated execution |
| One-off reminder ("Remind me in 20 minutes") | Scheduled task | No session history needed |
| Independent task with no chat context | Scheduled task | Clean separation from conversation |

**Rule of thumb**: Needs conversation context → heartbeat. Needs exact time or isolation → scheduled task.

## x hub

Cloud file hosting, static site deployment, and cloud compilation. Use `x hub` when you need to share files/images, deploy a static website, or perform cloud compilation.

- **Login**: `x hub login` (first time only; skip if already logged in). Commands will prompt for login if needed — just follow the prompt.
- **Common commands**: `x hub --help` to discover features; `x hub file upload <path>` to upload files; `x hub file share` to get share links. Add `--help` to any subcommand when unsure, e.g., `x hub file --help`.

## More

More tools and guides will be added here as the project evolves.
