---
name: x-uptime
description: |
  Enhanced `uptime` with structured YAML output showing 
  uptime, users, and 1/5/15-minute load averages.
  
  **Dependency**: This is an x-cmd module. Install x-cmd first (see x-cmd skill for installation options).
  see x-cmd skill for installation.

license: Apache-2.0
compatibility: POSIX Shell

metadata:
  author: Li Junhao
  version: "1.0.0"
  category: x-cmd-extension
  tags: [x-cmd, system, uptime, load]
---

# x uptime - System Uptime and Load

> Enhanced `uptime` command with structured YAML output and cross-platform support.

---

## Quick Start

```bash
# YAML format output (default)
x uptime

# Raw uptime command output
x uptime --raw
```

---

## Features

- **Structured YAML output**: Easy to parse and read
- **Load averages**: 1, 5, and 15-minute trends
- **Cross-platform**: Linux, macOS, Windows (via cosmo/busybox)
- **Auto-detection**: Uses native, busybox, or cosmo backends

---

## Output Fields

| Field | Description | Example |
|-------|-------------|---------|
| `time` | Current system time | `14:32:10` |
| `up` | System uptime | `5 days, 3 hours, 27 minutes` |
| `users` | Logged-in users count | `2 users` |
| `load` | Load averages (1m, 5m, 15m) | `0.52, 0.58, 0.59` |

---

## Commands

| Command | Description |
|---------|-------------|
| `x uptime` | YAML format output (default) |
| `x uptime --yml` | YAML format (explicit) |
| `x uptime --raw` | Raw system uptime output |

---

## Examples

### Basic Usage

```bash
# Default YAML output
x uptime

# Output example:
# time  : 14:32:10
# up    : 5 days, 3 hours, 27 minutes
# users : 2 users
# load  : 0.52, 0.58, 0.59
```

### Raw Output

```bash
# Traditional uptime output
x uptime --raw
# 14:32:10 up 5 days, 3:27, 2 users, load average: 0.52, 0.58, 0.59
```

### Parsing

```bash
# Extract uptime
x uptime | awk -F': ' '/^up/{print $2}'

# Get load average
x uptime | awk -F': ' '/^load/{print $2}'
```

---

## Understanding Load Averages

Load averages indicate system busyness - the average number of processes waiting for CPU or I/O.

| Value | Interpretation |
|-------|----------------|
| `< 1.0` | System has spare capacity |
| `≈ 1.0` | System is fully utilized |
| `> 1.0` | Processes are waiting (queue forming) |

The three numbers show:
- **1 min**: Short-term trend (immediate load)
- **5 min**: Medium-term trend (recent history)
- **15 min**: Long-term trend (sustained load)

### Multi-Core Systems

Divide load by CPU core count:
```bash
# 4-core system with load 3.2
effective_load = 3.2 / 4 = 0.8  # Still has capacity
```

---

## Platform Notes

### Linux
- Uses native `uptime` command
- Full feature support

### macOS
- Uses native `uptime` command
- Full feature support

### Windows
- No native `uptime` command
- Automatically uses cosmo binary or busybox

---

## Related

- Native `uptime(1)` manual page
