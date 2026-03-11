---
name: x-df
description: |
  Enhanced `df` combining disk usage and mount info. 
  Supports CSV, TSV, and TUI with filesystem type detection.
  
  **Requires x-cmd**: Use x-cmd skill to install and use x-cmd,
  see https://x-cmd.com/llms.txt . Note: load x-cmd with `. ~/.x-cmd.root/X` before use.

license: Apache-2.0
compatibility: POSIX Shell

metadata:
  author: Li Junhao
  version: "0.0.1"
  category: x-cmd-extension
  tags: [x-cmd, system, df, disk, storage]
---

# x df - Disk Free Space Viewer

> Enhanced `df` command combining `df` and `mount` output with multiple formats.

---

## Quick Start

```bash
# Interactive disk usage viewer (default in TTY)
x df

# TSV format output (default when piped)
x df | cat
```

---

## Features

- **Joint output**: Combines `df` and `mount` command information
- **Multi-format**: TSV, CSV, TUI application, raw
- **Cross-platform**: Linux, macOS, Windows support
- **Auto-detection**: Interactive mode in TTY, TSV when piped

---

## Output Fields

### Linux / Windows

| Field | Description | Example |
|-------|-------------|---------|
| `Filesystem` | Device path | `/dev/sda1` |
| `Type` | Filesystem type | `ext4`, `ntfs` |
| `Size` | Total size | `500G` |
| `Used` | Used space | `200G` |
| `Avail` | Available space | `300G` |
| `Use%` | Usage percentage | `40%` |
| `Mounted_path` | Mount point | `/`, `/home` |
| `Mounted_attr` | Mount attributes | `rw,relatime` |

### macOS (additional fields)

| Field | Description | Example |
|-------|-------------|---------|
| `Capacity` | Capacity percentage | `40%` |
| `iused` | Used inodes | `1000000` |
| `ifree` | Free inodes | `9000000` |
| `%iused` | Inode usage % | `10%` |

---

## Commands

| Command | Description |
|---------|-------------|
| `x df` | Auto mode: TTY→interactive, pipe→TSV |
| `x df --app` | Interactive TUI view |
| `x df --csv` | CSV format output |
| `x df --tsv` | TSV format output |
| `x df --raw` | Raw system command output |
| `x df --numeric` | Display sizes in pure numeric form |

---

## Examples

### Basic Usage

```bash
# Interactive view (TTY)
x df

# TSV format
x df --tsv

# CSV format
x df --csv
```

### Filter and Process

```bash
# Find large filesystems (>100GB)
x df --tsv | awk -F'\t' 'NR>1 && $3 > 100'

# Check specific mount point
x df --tsv | grep "/home"

# Get usage percentages only
x df --tsv | awk -F'\t' '{print $1, $6}'
```

### Data Processing

```bash
# Convert to JSON via csv
x df --csv | x csv tojson

# SQL-like query on disk usage
x df --csv | x csv sql "SELECT * WHERE Use% > 80"
```

---

## Platform Notes

### Linux
- Uses `df` and `/proc/mounts` or `mount` command
- Full feature support

### macOS
- Uses `df` and `mount` command
- Additional inode information (iused, ifree, %iused)

### Windows
- Uses available disk space APIs
- Full feature support

---

## Comparison with Native df

| Command | Output |
|---------|--------|
| `df -h` | Basic disk usage |
| `mount` | Mount information |
| `x df` | Combined view with filesystem type and mount attributes |

```bash
# Native df
$ df -h
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda1       500G  200G  300G  40% /

# x df (combined with mount info)
$ x df --tsv
Filesystem    Type    Size    Used    Avail   Use%    Mounted_path    Mounted_attr
/dev/sda1     ext4    500G    200G    300G    40%     /               rw,relatime
```

---

## Related

- [Back to x-cmd Skill](../../SKILL.md)
- [x-cmd df module](https://x-cmd.com/mod/df)
- Native `df(1)` manual page
- Native `mount(8)` manual page
