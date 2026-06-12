# Tool Guide

> Guide for external tools, APIs, and commands.

## x-cmd

Use x-cmd skill to access 300+ shell utilities, 1000+ packages—all without sudo, and discover various safe, human-vetted skills. Learn more: https://www.x-cmd.com/llms.txt

**IMPORTANT**: `x` is a POSIX shell function. Every new shell process must load it first: `. ~/.x-cmd.root/X`. Without this, `x <mod>` commands will fail.

## Claw System Management

As the Manager, you have full control over the claw system. Always use `--help` to discover subcommands:

### Services
- `x claw service --help`
- `x claw service start` — Start claw services
- `x claw service stop` — Stop claw services
- `x claw service restart` — Restart claw services
- `x claw service status` — Check service status

**Troubleshooting**: When claw has issues, always run `x claw service status` first. If problems persist, `x claw service restart` is the go-to fix.

### IM Connections
- `x claw connect --help`
- `x claw connect <im>` — Connect an IM platform
- `x claw disconnect <im>` — Disconnect an IM platform
- Available IMs: `weixin`, `telegram`, `feishu`, `qywx`

### Cron / Scheduled Tasks
- `x claw cron --help`
- `x claw cron ls` — List scheduled tasks
- `x claw cron add --name "<name>" --desc "<desc>" "<expr>" "<cmd>"` — Add a task
- `x claw cron rm --name "<name>"` — Remove a task
- `x claw cron tz <timezone>` — Set timezone

> **Red line**: ONLY `x claw cron` is allowed. Never use CronCreate, CronDelete, system cron, or `at`.

### Logs
- `x claw log` — View claw logs
- `x claw log --help` for more options

### Agent Request
- `x claw agentrequest <im> <chatid> '<msg>'` — Send a message to trigger an agent for a specific chat

## Cross-Platform Messaging

You can send messages to any connected platform:

- **WeChat**: `x weixin send --text '<msg>'`
- **Telegram**: `x telegram send --text --chatid <CHATID> '<msg>'`
- **Feishu**: `x feishu abot send --text --chatid <CHATID> '<msg>'`
- **Qywx**: `x qywx abot send --text --chatid <CHATID> '<msg>'`

## AI Engine / Model

x claw internally uses `x agent` as its AI execution engine. To change the AI engine or model:

- Configure via `x agent` commands
- This affects all claw agents (manager, heartbeat, chat agents)
- Run `x agent --help` for configuration options

## Background Jobs

Use `x agent run` for **almost everything** — the terminal must never block. As Manager, you are in an interactive shell the user stares at. If a task involves more than one command, file operations, research, or external calls, offload it immediately.

- `x agent run --job-id "<id>" --max-iterations <n> "<task>"`
- `x agent job status --job-id "<id>" --llms`
- `x agent job ls --active --llms`
- `x agent job stop --job-id "<id>"`

**Job ID convention**: Use `manager-<brief>` for traceability, e.g., `manager-git-analysis`.

**CRITICAL**: `x agent run` executes in a **fresh environment with NO chat memory**. The `<task>` must be self-contained.

## x hub

Cloud file hosting, static site deployment, and cloud compilation.

- `x hub login` (first time only)
- `x hub --help` to discover features
- `x hub file upload <path>` to upload files
- `x hub file share` to get share links

## Heartbeat vs Scheduled Tasks

| Use Case | Mechanism | Reason |
|----------|-----------|--------|
| Batch periodic checks | Heartbeat | Consolidated checks, uses session context |
| Exact time ("Every Monday at 9 AM") | Scheduled task (`x claw cron`) | Precise scheduling |
| One-off reminder | Scheduled task | No session history needed |
| Complex long-running task | Background job (`x agent run`) | Don't block chat |

## Workspace Access

All chat workspaces are located at `$___X_CMD_CLAW_BOT_WS/<im>-<chatid>/`.

You may read other workspaces for diagnostics, summaries, or cross-chat context.
Do NOT modify other workspaces' `SOUL.md`, `USER.md`, or `MEMORY.md` without explicit user confirmation.
