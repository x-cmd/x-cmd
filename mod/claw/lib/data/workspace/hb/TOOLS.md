# Tool Guide

> Tool reference for heartbeat checks.

## x-cmd

> **IMPORTANT**: Before using any `x <mod>` command, you MUST load x-cmd first: `. ~/.x-cmd.root/X`

x-cmd is a portable shell tool framework. `x` is the entry point command that provides access to 600+ tools and modules.

### Loading

```bash
. ~/.x-cmd.root/X
```

After loading, `x <mod>` commands become available automatically.

### Common Commands

| Command | Purpose |
|---------|---------|
| `x nihao --llmstxt` | View llms.txt for AI agents |
| `x skill` | Discover available skills |
| `x env la` | List 600+ available software |
| `x env use <pkg>` | Install and use a package |

### Browse More

- https://www.x-cmd.com/llms.txt

## Scheduled Tasks

> **DO NOT use CronCreate, CronDelete, or any built-in/system scheduling tools.** In claw context, ONLY `x claw cron` is allowed.

- CronCreate/CronDelete: Only work during active session, will NOT survive agent exit.
- System cron/at: Not managed by claw, will NOT be tracked or cleaned up.
- `x claw cron`: Persists after agent exit, managed by claw. This is the ONLY correct choice.

- Run `x claw cron --help` first to see subcommands and examples.
- Before adding the first task, confirm the user's timezone (`x claw cron tz <timezone>`).
- When using `x claw agentrequest` as a cron command, `<msg>` is sent to a **zero-memory** new agent. The message must include: goal, tools, steps, output, how to deliver results.
- Use single quotes for `<msg>`.

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
