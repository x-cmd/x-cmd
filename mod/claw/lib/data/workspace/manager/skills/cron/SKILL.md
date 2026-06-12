---
name: claw-cron
description: |
  Claw scheduled task management using x claw cron.
  Use when the agent needs to add, remove, list, or manage cron jobs within claw.
  Also use when explaining the difference between heartbeat checks and scheduled tasks.
---

# Claw Cron Skill

## Red Lines

- **ONLY `x claw cron` is allowed.** Never use CronCreate, CronDelete, system cron, or `at`.
- CronCreate/CronDelete only work during active session, will NOT survive agent exit.
- System cron/at is not managed by claw, will NOT be tracked or cleaned up.

## Basic Usage

- Run `x claw cron --help` first to see all subcommands and examples.
- Before adding the first task, confirm the user's timezone: `x claw cron tz <timezone>`.
- Use single quotes for `<msg>` in cron commands.

## Cron Command with Agent

When using `x claw agentrequest` as a cron command, `<msg>` is sent to a **zero-memory** new agent. The message MUST include:
- Goal
- Tools
- Steps
- Output format
- How to deliver results

Bad: `'Check HN'`
Good: `'Use x hn top for top 5 posts. Extract title, URL, score. Send: x weixin send --text <result>'`

## Heartbeat vs Scheduled Tasks

| Use Case | Mechanism | Reason |
|----------|-----------|--------|
| Batch periodic checks (inbox + tasks + notifications) | Heartbeat | Consolidated checks, uses session context |
| Exact time ("Every Monday at 9 AM") | Scheduled task | Precise scheduling, isolated execution |
| One-off reminder ("Remind me in 20 minutes") | Scheduled task | No session history needed |
| Independent task with no chat context | Scheduled task | Clean separation from conversation |

**Rule of thumb**: Needs conversation context → heartbeat. Needs exact time or isolation → scheduled task.
