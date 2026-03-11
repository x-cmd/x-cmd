---
name: x-lsof
description: |
  Enhanced lsof (List Open Files) with interactive UI and structured output.
  View open files, network connections, and processes.
  
  **Requires x-cmd**: Use x-cmd skill to install and use x-cmd,
  see https://x-cmd.com/llms.txt . Note: load x-cmd with `. ~/.x-cmd.root/X` before use.

license: Apache-2.0
compatibility: POSIX Shell

metadata:
  author: Li Junhao
  version: "0.0.1"
  category: x-cmd-extension
  tags: [x-cmd, system, lsof, files, process, network]
---

# x lsof - List Open Files

> Enhanced `lsof` with interactive UI, fzf search, and TSV/CSV/JSON output formats.

---

## Quick Start

```bash
# Interactive view (default in TTY)
x lsof

# fzf interactive search
x lsof fz

# TSV format output
x lsof --tsv
```

---

## Features

- **Auto-download**: If `lsof` is not available, x-cmd automatically downloads a portable version from trusted sources
- **Interactive UI**: TUI application for viewing open files
- **fzf Integration**: Interactive search with fzf
- **Multiple Formats**: TSV, CSV, and raw output for data processing
- **Port-to-PID**: Find process ID by port number

---

## Commands

| Command | Description |
|---------|-------------|
| `x lsof` | Interactive TUI view (default in TTY) / TSV (piped) |
| `x lsof fz` | Interactive fzf search |
| `x lsof --app` | TUI application view |
| `x lsof --tsv` | TSV format output |
| `x lsof --csv` | CSV format output |
| `x lsof --raw` | Raw format output |
| `x lsof --pidofport <port>` | Find PID by port number |

---

## Examples

### Basic Usage

```bash
# Interactive view (TTY default)
x lsof

# fzf interactive mode
x lsof fz

# TSV format for processing
x lsof --tsv

# CSV format
x lsof --csv
```

### Find Process by Port

```bash
# Find PID listening on port 8080
x lsof --pidofport 8080

# Find all processes using port 443
x lsof -i:443
```

### Data Processing

```bash
# Filter with awk
x lsof --tsv | awk -F'\t' '$2 == "TCP"'

# Import to spreadsheet
x lsof --csv > open_files.csv

# Count files by process
x lsof --tsv | cut -f1 | sort | uniq -c | sort -rn
```

---

## Output Fields

| Field | Description |
|-------|-------------|
| COMMAND | Process name |
| PID | Process ID |
| USER | User name |
| FD | File descriptor |
| TYPE | File type (REG, DIR, IPv4, IPv6) |
| DEVICE | Device number |
| SIZE/OFF | File size or offset |
| NODE | Inode number |
| NAME | File name / network connection |

---

## Automatic Binary Download

If `lsof` is not installed on your system, x-cmd automatically downloads a portable version from trusted sources (pixi/conda-forge) and manages it locally. No manual installation required.

Supported platforms:
- Linux (x86_64, aarch64)
- macOS (x86_64, arm64)
- Windows (limited support)

---

## Platform Notes

- **Linux/macOS**: Full support with native or auto-downloaded lsof
- **Windows**: Limited support, may require WSL

---

## Related

- [Back to x-cmd Skill](../../SKILL.md)
- [x-cmd lsof module](https://x-cmd.com/mod/lsof)
- Native `lsof(8)` manual page
