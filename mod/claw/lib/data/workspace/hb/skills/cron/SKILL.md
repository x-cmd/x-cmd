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

## Heartbeat vs Scheduled Tasks

| Use This | For What |
|----------|----------|
| **Heartbeat** (you) | Batch checks, needs chat context, time can float (~30 min drift is fine) |
| **Scheduled tasks** | Exact time ("9:00 AM sharp"), one-off reminders, no session history needed |

**Rule of thumb**: Need to know what was recently discussed → heartbeat. Only need exact time trigger → scheduled task.
