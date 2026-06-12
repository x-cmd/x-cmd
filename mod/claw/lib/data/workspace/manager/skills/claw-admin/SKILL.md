---
name: claw-admin
description: |
  Claw system administration: service management, IM connections, logs, cron, and workspace diagnostics.
  Use when the user asks to manage claw services, connect/disconnect IM platforms, view logs,
  or perform system-wide operations.
---

# Claw Admin Skill

## When to Use

Use this skill when the user asks about or needs to:
- Start, stop, restart, or check claw services
- Connect or disconnect IM platforms (weixin, telegram, feishu, qywx)
- View or analyze claw logs
- Manage scheduled tasks (cron)
- Inspect other chat workspaces for diagnostics
- Perform any system-wide claw administration

## Service Management

```bash
x claw service --help        # Discover all service commands
x claw service start         # Start claw services
x claw service stop          # Stop claw services
x claw service restart       # Restart claw services
x claw service status        # Check current service status
```

Always check status after start/restart to confirm services are healthy.

## Troubleshooting

**Golden rule**: When claw is not working correctly:

1. **Check status first**: `x claw service status`
2. **Check logs**: `x claw log`
3. **If status shows issues or logs show persistent errors**: `x claw service restart`
4. **Verify after restart**: `x claw service status`

Restart is the universal fix for most transient issues — use it when status/logs indicate problems that aren't immediately obvious.

## IM Connection Management

```bash
x claw connect --help        # Discover connect commands
x claw connect weixin        # Connect WeChat
x claw connect telegram      # Connect Telegram
x claw connect feishu        # Connect Feishu
x claw connect qywx          # Connect Enterprise WeChat
x claw disconnect <im>       # Disconnect an IM platform
```

For Feishu group chats:
- `x claw connect feishu:oc_xxx` — Connect a specific group
- `x claw connect feishu:groups` — Connect all available groups
- `x claw disconnect feishu:oc_xxx` — Disconnect a specific group
- List available groups: `x feishu group ls`

## Log Management

```bash
x claw log                   # View recent claw logs
x claw log --help            # Discover log options
```

Use logs for diagnostics when:
- A service fails to start
- Messages are not being delivered
- An IM platform appears disconnected
- Background jobs fail

## Scheduled Tasks

```bash
x claw cron --help           # Discover cron commands
x claw cron ls               # List all scheduled tasks
x claw cron tz <timezone>    # Set timezone (do this before adding tasks)
x claw cron add --name "<name>" --desc "<desc>" "<expr>" "<cmd>"
x claw cron rm --name "<name>"
```

**Red line**: ONLY `x claw cron` is allowed. Never use system cron or `at`.

## Workspace Diagnostics

All chat workspaces are at `$___X_CMD_CLAW_BOT_WS/<im>-<chatid>/`.

You may read (but not modify) other workspaces for diagnostics:
- Check `HEARTBEAT.md` for pending follow-ups
- Check `PLAN.md` for active tasks
- Check `memory/YYYY-MM-DD.md` for recent activity
- Check `.x-cmd/agent/` for agent execution logs

Do NOT modify other workspaces' `SOUL.md`, `USER.md`, or `MEMORY.md`.

## AI Engine / Model Management

x claw internally uses `x agent` as its AI execution engine. To change the AI engine or model that claw uses:

- Use `x agent` commands to configure the underlying AI provider/model
- This affects all claw agent sessions (manager, heartbeat, and chat agents)

Refer to `x agent --help` for available options.

## Cross-Platform Messaging

As Manager, you can send messages to any connected platform:

- **WeChat**: `x weixin send --text '<msg>'`
- **Telegram**: `x telegram send --text --chatid <CHATID> '<msg>'`
- **Feishu**: `x feishu abot send --text --chatid <CHATID> '<msg>'`
- **Qywx**: `x qywx abot send --text --chatid <CHATID> '<msg>'`

## Safety Checklist

Before performing destructive or impactful operations:
- [ ] Confirm the user explicitly requested it
- [ ] Check `x claw service status` to understand current state
- [ ] Warn the user about potential side effects (e.g., disconnecting an IM will stop message delivery)
- [ ] For service restarts, confirm it's an appropriate time
