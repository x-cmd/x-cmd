---
name: x-arp
description: |
  Display ARP cache table with MAC vendor lookup and suspicious 
  entry detection. Supports CSV, TSV, and TUI output.
  
  **Requires x-cmd**: Use x-cmd skill to install and use x-cmd,
  see https://x-cmd.com/llms.txt . Note: load x-cmd with `. ~/.x-cmd.root/X` before use.

license: Apache-2.0
compatibility: POSIX Shell

metadata:
  author: Li Junhao
  version: "0.0.1"
  category: x-cmd-extension
  tags: [x-cmd, network, arp, security]
---

# x arp - ARP Cache Table Viewer

> Display and inspect the local system's ARP cache table with multiple output formats.

---

## Quick Start

```bash
# Interactive ARP table viewer (default in TTY)
x arp

# TSV format output (default when piped)
x arp | cat
```

---

## Features

- **Multi-format output**: TSV, CSV, TUI application, raw
- **MAC vendor lookup**: Automatic vendor identification
- **Suspicious entry detection**: Flags potentially suspicious entries
- **Cross-platform**: Linux, macOS, Windows support

---

## Output Fields

| Field | Description | Example |
|-------|-------------|---------|
| `ip` | IP address | `192.168.1.1` |
| `mac` | MAC address | `00:11:22:33:44:55` |
| `if` | Network interface | `eth0`, `en0` |
| `suspicious` | Suspicious flag | Yes/No |
| `scope` | Address scope | `link`, `global` |
| `type` | Entry type | `static`, `dynamic` |
| `vendor` | MAC vendor (if available) | `Apple, Inc.` |

---

## Commands

| Command | Description |
|---------|-------------|
| `x arp` | Auto mode: TTY→interactive, pipe→TSV |
| `x arp --app` | Interactive TUI view |
| `x arp --csv` | CSV format output |
| `x arp --tsv` | TSV format output |
| `x arp --raw` | Raw system command output |
| `x arp --all` | Include incomplete entries |
| `x arp --no-vendor` | Skip MAC vendor lookup |

---

## Examples

### Basic Usage

```bash
# Interactive view (TTY)
x arp

# TSV format
x arp --tsv

# CSV format
x arp --csv
```

### Filtering and Processing

```bash
# Find entries for specific IP
x arp --tsv | awk -F'\t' '$1 == "192.168.1.1"'

# Check for suspicious entries
x arp --tsv | grep "Yes"

# Get all entries including incomplete
x arp --all
```

### Network Troubleshooting

```bash
# View raw ARP output
x arp --raw

# Check specific interface
x arp --tsv | grep "eth0"
```

---

## Platform Notes

### Linux
- Uses `ip neigh` or `arp -n`
- Full feature support

### macOS
- Uses `arp -an`
- Full feature support

### Windows
- Uses `arp -a`
- Full feature support

---

## Security Notes

- **Suspicious entries**: Flags entries that may indicate ARP spoofing
- **MAC vendor**: Helps identify unknown devices on network
- Use `--no-vendor` for faster output without network lookup

---

## Related

- [Back to x-cmd Skill](../../SKILL.md)
- [x-cmd arp module](https://x-cmd.com/mod/arp)
- Native `arp(8)` manual page
