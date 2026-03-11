---
name: x-smart
description: |
  SMART disk health monitoring tool. Check disk health,
  temperature, and attributes using smartctl.
  
  **Requires x-cmd**: Use x-cmd skill to install and use x-cmd,
  see https://x-cmd.com/llms.txt . Note: load x-cmd with `. ~/.x-cmd.root/X` before use.

license: Apache-2.0
compatibility: POSIX Shell

metadata:
  author: Li Junhao
  version: "0.0.1"
  category: x-cmd-extension
  tags: [x-cmd, system, smart, disk, health]
---

# x smart - Disk Health Monitor

> SMART (Self-Monitoring, Analysis, and Reporting Technology) disk health checking tool.

---

## Quick Start

### List Available Disks

```bash
x smart --ls
```

### Check Disk Health

```bash
# macOS
x smart -a /dev/disk0

# Linux
x smart -a /dev/sda

# Windows
x smart -a C:
```

### Interactive Mode

```bash
x smart
```

Opens interactive UI to select disk and display SMART information.

---

## Common Commands

| Command | Description |
|---------|-------------|
| `x smart --ls` | List available disk paths |
| `x smart -a <disk>` | Display all SMART information for the disk |
| `x smart -H <disk>` | Display disk health status only |
| `x smart --app` | Interactive disk selection (default) |
| `x smart : disk health` | Search smartmontools.com via DuckDuckGo |
| `x smart --help` | Show help information |

---

## Examples

### Basic Usage

```bash
# List all disks
x smart --ls

# Check specific disk (macOS)
x smart -a /dev/disk0

# Check specific disk (Linux)
x smart -a /dev/sda

# Check health only
x smart -H /dev/disk0
```

### Search Documentation

```bash
x smart : disk health
x smart : temperature threshold
```

---

## Platform Notes

### macOS
- Disks: `/dev/disk0`, `/dev/disk1`, etc.
- No sudo required for most operations

### Linux
- Disks: `/dev/sda`, `/dev/nvme0n1`, etc.
- Automatically uses `sudo` for disk access
- smartctl installed via snap if not present

### Windows
- Drives: `C:`, `D:`, etc.
- May require administrator privileges

---

## Tips

- **Root privileges**: smartctl needs root to access SMART data
- **Linux**: sudo is automatically invoked, no manual prefix needed
- **Snap**: smartctl is auto-installed via snap if missing

---

## Related

- [Back to x-cmd Skill](../../SKILL.md)
- [x-cmd smart module](https://x-cmd.com/mod/smart)
- [smartmontools.com](https://www.smartmontools.org/)
