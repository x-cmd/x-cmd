---
name: claw-memory-management
description: |
  Workspace memory management guide: memory layers, writing rules, entry format, and maintenance.
  Use when writing, updating, or maintaining memory files (memory/YYYY-MM-DD.md and MEMORY.md).
---

# Memory Management

## Memory Layers

| Layer | File | Content | Purpose |
|-------|------|---------|---------|
| **Layer 2** | `MEMORY.md` | Persistent facts, preferences, conventions | Cross-session knowledge |
| **Layer 1** | `memory/YYYY-MM-DD.md` | Concise daily index: tasks, decisions, changes, next steps | Quick context recovery |

**Key difference**: `memory/` is what you *need to know* to continue working. Keep it concise — do not stuff it with exhaustive operational details.

## Writing Rules

1. **Write memory after action** — Each round produces one concise memory index entry.
2. **Keep memory concise** — `memory/` is for quick context recovery. If it becomes too long to scan at a glance, you are writing too much detail.
3. **Use timestamps inside entries** — Use `HH:MM:SS` inside entries. The `## ` heading already provides the date.
4. **Link to long-term memory** — If a pattern or preference should persist, update `MEMORY.md` directly.
5. **Silent writing** — Write memory as part of tool calls. Do not mention logging in your text replies to the user.
6. **Log every reply** — Every memory entry must include a `Sent` field summarizing what you output to the user. If you said nothing, write `"No reply"`.
7. **Check before replying** — Before replying, scan today's `memory/` entries for the `Sent` field. If you already answered this question, do not repeat it.
8. **Check context on short/ambiguous replies** — If the user's message is brief or seems to reference something not in their message (e.g., "ok", "好的", "why", "next time"), ALWAYS check the most recent `Sent` entry in `memory/YYYY-MM-DD.md`. The user may be responding to a heartbeat notification. If so, acknowledge the notification context in your reply.

## Memory Index Entry Format

Append entries to `memory/YYYY-MM-DD.md`. Keep them short — this is for quick context recovery, not full documentation.

```markdown
## HH:MM:SS — [One-sentence task summary]

- **Request**: [What the user asked for]
- **Method**: [Brief description of the approach or pattern used]
- **Key decision**: [Important choices and rationale]
- **Changes**: [List of files touched]
- **Status**: [Complete / Partial / Blocked / Needs review]
- **Sent**: [Brief summary of what you sent to the user, e.g., "Explained heartbeat mechanism" or "No reply"]
- **Next step**: [Suggested next step, or empty if complete. If you sent a message to the user and expect a reply, write: "If user replies, they are likely responding to: <summary of what you sent>". This helps the next agent session understand the context when the user replies.]
```

Do not output these logs in your text replies. Write them directly to files.

## Memory Maintenance

Periodically (every few days or when you notice accumulation), review and maintain your memory:

1. **Read** recent `memory/YYYY-MM-DD.md` files
2. **Identify** significant events, lessons, insights worth saving long-term
3. **Update** `MEMORY.md` with distilled learnings (not raw logs)
4. **Delete** outdated information in `MEMORY.md` that is no longer relevant

This is like a human reviewing a diary and updating their mental model. Daily files are raw notes; `MEMORY.md` is curated wisdom.

**Key rule**: If you want to remember something, **write it to a file**.
