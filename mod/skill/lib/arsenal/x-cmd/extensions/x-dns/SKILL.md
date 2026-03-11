---
name: x-dns
description: |
  DNS configuration management utilities.
  View current DNS settings, list available DNS servers,
  and refresh DNS cache on the system.
  
  **Requires x-cmd**: Use x-cmd skill to install and use x-cmd,
  see https://x-cmd.com/llms.txt . Note: load x-cmd with `. ~/.x-cmd.root/X` before use.

license: Apache-2.0
compatibility: POSIX Shell

metadata:
  author: Li Junhao
  version: "0.0.1"
  category: x-cmd-extension
  tags: [x-cmd, network, dns, configuration]
---

# x dns - DNS Configuration Utilities

> DNS (Domain Name System) configuration management utilities.

---

## Quick Start

```bash
# Show current DNS configuration
x dns

# List available DNS servers
x dns ls

# Refresh DNS cache
x dns refresh
```

---

## Features

- **Current DNS**: View current DNS configuration
- **DNS List**: List available DNS server addresses
- **DNS Refresh**: Flush and refresh DNS cache
- **Multiple Formats**: JSON, YAML, CSV output support

---

## Commands

| Command | Description |
|---------|-------------|
| `x dns` | Show current DNS configuration (default) |
| `x dns current` | View detailed current DNS settings |
| `x dns ls` | List all available DNS servers |
| `x dns ls --json` | List DNS servers in JSON format |
| `x dns ls --yml` | List DNS servers in YAML format |
| `x dns ls --csv` | List DNS servers in CSV format |
| `x dns refresh` | Refresh system DNS cache |

---

## Examples

### View DNS Configuration

```bash
# Show current DNS
x dns

# View detailed settings
x dns current
```

### List DNS Servers

```bash
# List all available DNS servers
x dns ls

# JSON format
x dns ls --json

# YAML format
x dns ls --yml

# CSV format
x dns ls --csv
```

### Refresh DNS Cache

```bash
# Flush and refresh DNS cache
x dns refresh
```

---

## Platform Notes

- **Linux**: Uses systemd-resolve, NetworkManager, or resolv.conf
- **macOS**: Uses scutil and dscacheutil
- **Windows**: Uses ipconfig and netsh

---

## Related

- [Back to x-cmd Skill](../../SKILL.md)
- [x-cmd dns module](https://x-cmd.com/mod/dns)
