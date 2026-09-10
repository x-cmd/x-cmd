---
name: x-todo
description: |
  Minimal personal todo list (task tracker) for x-cmd.
  add/list/done/archive/restore/rm with an active -> archived -> trash
  state machine, plain-text storage (one file per task).

  **Dependency**: This is an x-cmd module. Install x-cmd first (see x-cmd skill for installation options).

license: Apache-2.0
compatibility: POSIX Shell

metadata:
  author: xuanyuanluoxue
  version: "0.1.0"
  category: x-cmd-extension
  tags: [x-cmd, todo, task, productivity]
---

# x todo - Personal Todo List

> Minimal personal todo list with an `active -> archived -> trash` state machine.

---

## Quick Start

```bash
# Add a task
x todo add "buy milk"

# Add with priority and note
x todo add "ship v1" --priority high --note "blocked by review"

# List active tasks (TSV: id / priority / created / status / name)
x todo list

# List everything
x todo list --all

# Complete / archive / restore / remove
x todo done <id>
x todo archive <id> --reason "no time"
x todo restore <id>
x todo rm <id>          # to trash
x todo rm <id> --force  # delete for real
```

---

## Features

- **State machine**: `active -> archived -> trash`, each step is a file move
- **Plain-text storage**: one file per task under `$___X_CMD_ROOT_DATA/todo/<status>/<id>`
- **TSV output**: agent-friendly `id \t priority \t created \t status \t name` rows
- **POSIX-only**: shell + awk, no external dependencies

---

## State Machine

| Command | From | To |
|---------|------|----|
| `done <id>` | active | archived (reason=done) |
| `archive <id>` | active | archived |
| `restore <id>` | archived / trash | active |
| `rm <id>` | any | trash |
| `rm <id> --force` | any | deleted |

---

## Data Format

Each task is a plain-text `key: value` file:

```text
name: buy milk
priority: normal
created: 1754123456
finished: 1754123556
reason: done
note: optional
```

Storage layout:

```text
$___X_CMD_ROOT_DATA/todo/
├── active/<id>
├── archived/<id>
└── trash/<id>
```
