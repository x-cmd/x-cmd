---
name: x-last
description: |
  Enhanced `last` command with CSV, JSON, tree view, and 
  interactive UI for viewing login history.
  
  **Dependency**: This is an x-cmd module. Install x-cmd first (see x-cmd skill for installation options).
  see x-cmd skill for installation.

license: Apache-2.0
compatibility: POSIX Shell

metadata:
  author: Li Junhao
  version: "1.0.0"
  category: x-cmd-extension
  tags: [x-cmd, system, last, login, security]
---

# x last - User Login History

> Enhanced `last` command with multiple output formats, tree view, and interactive UI.

---

## Quick Start

```bash
# Interactive login history viewer (default in TTY)
x last

# All records
x last --all
```

---

## Features

- **Multiple formats**: CSV, JSON, tree view
- **Interactive UI**: Built-in picker for TTY mode
- **Filtering options**: Login only, reboot only, all records
- **Session duration**: Calculated login session lengths
- **Tree view**: Grouped by system reboot

---

## Commands

| Command | Description |
|---------|-------------|
| `x last` | Interactive view (default) / CSV (piped) |
| `x last --all` | All records (TTY: interactive picker) |
| `x last --login` | Login records only, exclude reboots |
| `x last --reboot` | System reboot records only |
| `x last --tree` | Tree view grouped by reboot |
| `x last --csv` | CSV format output |
| `x last --json` | JSON format output |

---

## Examples

### Basic Usage

```bash
# Default view
x last

# All records with interactive picker
x last --all

# Login records only
x last --login
```

### Format Output

```bash
# JSON format
x last --json

# CSV format
x last --csv

# Tree view
x last --tree
```

### Filtering

```bash
# Specific user
x last username

# Specific TTY
x last tty7

# Reboot records only
x last --reboot
```

### Data Processing

```bash
# Parse with jq
x last --json | jq '.[] | select(.user == "root")'

# Find recent reboots
x last --reboot --json | jq '.[0:5]'
```

---

## Output Fields

| Field | Description | Example |
|-------|-------------|---------|
| `user` | Username | `john`, `reboot` |
| `tty` | Terminal | `pts/0`, `tty7` |
| `host` | Remote host | `192.168.1.100` |
| `login` | Login time | `Mon Jan 15 09:30` |
| `logout` | Logout time | `Mon Jan 15 17:45` |
| `duration` | Session duration | `08:15` |

---

## Platform Notes

### Linux
- Uses native `last` command
- Reads from `/var/log/wtmp`

### macOS
- Uses native `last` command
- Full feature support

### Windows
- Limited support (no native last command)

---

## Related

- Native `last(1)` manual page
