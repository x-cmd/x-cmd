---
name: prompt
description: Prompt engineering conventions for x-cmd — reuse via template variables, structure rules, safety enforcement patterns.
---

# Prompt

## Core principle: reuse, don't duplicate

Prompts in x-cmd are assembled from reusable fragments, not written as monoliths. A prompt template contains `<PLACEHOLDER>` variables that are resolved at runtime by the shell module.

Example from `claw`:
```
first_contact.md          # standalone — loaded into <FIRST_CONTACT_PROMPT>
msg_telegram.md           # assembles: <FIRST_CONTACT_PROMPT> + <CHECK_PROMPT> + <MSG>
msg_feishu.md             # same fragments, different platform adapter
heartbeat.md              # different workflow, shares <CHECK_PROMPT>
```

**Why**: one fix propagates everywhere. Platform adapters (Telegram, Feishu, WeChat) share behavioral rules but differ in send commands and formatting limits.

See [reusing.md](reusing.md) for detailed reuse patterns.

## Structure rules

- Each prompt file is a complete, self-contained instruction set for one scenario
- Use `<UPPER_CASE>` placeholders for variables — never inline real data
- Placeholders are resolved by the calling module, not the prompt itself
- Fragment = function (logic and flow), data is appended at runtime (like setting arguments)

## Safety enforcement pattern

Safety and behavioral rules MUST be explicit and forceful:

```
=== UNBREAKABLE RULES ===
>> RULE 1: Your stdout is INVISIBLE. Every reply MUST use send command. <<
>> RULE 2: Reply FIRST, think SECOND. For non-trivial tasks, send ack immediately. <<
>> RULE 3: Complex/long tasks → use `x agent run`. DO NOT block user. <<
```

Use MUST, NEVER, DO NOT. See [skill0-writer](../skill0-writer/SKILL.md) for the security language rule.

## Format guide pattern

When prompts target multiple platforms with different formatting capabilities:

```
FORMAT GUIDE:
- WeChat / Enterprise WeChat: Limited formatting. Plain text, lists, emoji. No tables.
- Telegram: Full markdown including tables. Max 4096 chars.
- Feishu: Full markdown. Card messages need JSON.
```

## Real examples

Prompt fragments currently live in each module's `lib/data/prompt/` (e.g., `claw/lib/data/prompt/`).
They will migrate to `skill0/lib/skill0/<subskill>/` — same structure, canonical location.

Current examples in `claw/lib/data/prompt/`:
- `first_contact.md` — new workspace greeting, reusable fragment
- `heartbeat.md` — background agent, reads workspace state
- `msg_<platform>.md` — per-platform message handlers, share common fragments
