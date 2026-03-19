---
name: x-uname
description: |
  Enhanced `uname` command with colorized, structured output.
  Shows hostname, OS, kernel, architecture.
  
  **Requires x-cmd**: Use x-cmd skill to install and use x-cmd,
  see https://x-cmd.com/llms.txt . Note: load x-cmd with `. ~/.x-cmd.root/X` before use.

license: Apache-2.0
compatibility: POSIX Shell

metadata:
  author: Li Junhao
  version: "0.0.1"
  category: x-cmd-extension
  tags: [x-cmd, system, uname, sysinfo]
---

# x uname - System Information

> Enhanced `uname` command with colorized, structured output.

---

## Quick Start

```bash
# Display system information
x uname
```

---

## Features

- **Colorized output**: Key-value format with ANSI colors (auto-disabled when piped)
- **Structured display**: hostname, osname, kernel, machine, version
- **Cross-platform**: Works on Linux, macOS, Windows (via cosmo)

---

## Output Fields

| Field | Description | Example |
|-------|-------------|---------|
| `hostname` | System hostname | `myserver` |
| `osname` | Operating system name | `Linux`, `Darwin` |
| `kernel` | Kernel version | `5.15.0-91-generic` |
| `machine` | Hardware architecture | `x86_64`, `arm64` |
| `version` | Full OS version string | `#101-Ubuntu SMP...` |

---

## Examples

### Basic Usage

```bash
# Default - colorful structured output
x uname

# Output example:
# hostname   :  myserver
# osname     :  Linux
# kernel     :  5.15.0-91-generic
# machine    :  x86_64
# version    :  #101-Ubuntu SMP Tue Nov 14 13:29:11 UTC 2023
```

### Pipe Usage

Colors are automatically disabled when output is piped:

```bash
# No colors in piped output
x uname | cat

# Parse with awk
x uname | awk -F': ' '/kernel/{print $2}'
```

---

## Comparison with Native uname

| Command | Output Style |
|---------|--------------|
| `uname -a` | Single line, space-separated |
| `x uname` | Multi-line, key-value format |

```bash
# Native uname
$ uname -a
Linux myserver 5.15.0-91-generic #101-Ubuntu SMP ... x86_64 x86_64 x86_64 GNU/Linux

# x uname
$ x uname
hostname   :  myserver
osname     :  Linux
kernel     :  5.15.0-91-generic
machine    :  x86_64
version    :  #101-Ubuntu SMP Tue Nov 14 13:29:11 UTC 2023
```

---

## Related

- [Back to x-cmd Skill](../../SKILL.md)
- [x-cmd uname module](https://x-cmd.com/mod/uname)
- Native `uname(1)` manual page
