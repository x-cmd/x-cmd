---
name: prompt-reusing
description: Prompt reuse pattern — placeholders for variables, fragments for logic, data appended at runtime like function arguments.
---

# Prompt reusing

Part of [prompt SKILL.md](SKILL.md).

## Core idea: prompt = function, placeholder = variable

A prompt fragment is like a function — it defines logic and flow using `<PLACEHOLDER>` variables. The actual data is never inlined; it is resolved and appended at runtime, like setting argument values.

```
# first_contact.md — the "function"
You are **X-CLAW**. Your workspace is "<WORKSPACE_DIR>".

# msg_telegram.md — assembles fragments, then appends data
<FIRST_CONTACT_PROMPT>
CURRENT CHAT ID: "<CHATID>"
Your workspace: "<WORKSPACE_DIR>"
Current time: '<CURRENT_TIME>'
<MSG>
```

`<WORKSPACE_DIR>`, `<CHATID>`, `<CURRENT_TIME>`, `<MSG>` — all resolved at runtime.
The fragment only declares where they go, never what they are.

## Why this matters

- **One fix propagates everywhere** — `first_contact.md` is shared by `msg_telegram`, `msg_feishu`, `msg_weixin`, etc.
- **Logic and data are separated** — fragments can be reviewed for behavioral correctness without touching real data
- **Composable** — different platform adapters reuse the same fragments, differ only in send commands and format limits

## Example: claw

```
claw/lib/data/prompt/
├── first_contact.md      # Reusable fragment (identity/personality)
├── heartbeat.md          # Standalone prompt (background agent)
├── msg_feishu.md         # Telegram adapter + shared fragments + runtime data
├── msg_qywx.md           # Enterprise WeChat adapter + shared fragments + runtime data
├── msg_telegram.md       # Telegram adapter + shared fragments + runtime data
└── msg_weixin.md         # WeChat adapter + shared fragments + runtime data
```

Shared across `msg_*` templates:
- `<FIRST_CONTACT_PROMPT>` — identity rules
- `<CHECK_PROMPT>` — workspace state check
- `=== UNBREAKABLE RULES ===` — behavioral constraints

Differ per platform:
- Send command syntax (`x feishu abot send` vs `x telegram send`)
- Formatting limits (Feishu cards vs Telegram markdown vs WeChat plain text)
