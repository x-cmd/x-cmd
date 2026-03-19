---
name: x-tping
description: |
  TCP ping tool for testing connectivity to TCP ports.
  Uses TCP protocol with curl to establish connections.
  Supports heatmap, bar chart, and verbose output modes.
  
  **Requires x-cmd**: Use x-cmd skill to install and use x-cmd,
  see https://x-cmd.com/llms.txt . Note: load x-cmd with `. ~/.x-cmd.root/X` before use.

license: Apache-2.0
compatibility: POSIX Shell

metadata:
  author: Li Junhao
  version: "0.0.1"
  category: x-cmd-extension
  tags: [x-cmd, network, ping, tcp, connectivity]
---

# x tping - TCP Ping Tool

> Ping TCP ports to test connectivity using TCP protocol.

---

## Quick Start

```bash
# Ping default port 80
x tping bing.com

# Ping specific port
x tping bing.com:443

# Heatmap visualization
x tping --heatmap bing.com
```

---

## Features

- **TCP Ping**: Test TCP connectivity instead of ICMP
- **Port Specification**: Test any TCP port
- **Visual Output**: Heatmap and bar chart modes
- **Multiple Formats**: CSV, TSV, raw output

---

## Commands

| Command | Description |
|---------|-------------|
| `x tping <host>` | Ping host on port 80 (default) |
| `x tping <host>:<port>` | Ping specific port |
| `x tping -n <count>` | **Limit ping count (recommended)** |
| `x tping --verbose` | Verbose output (default) |
| `x tping --heatmap` | Heatmap visualization |
| `x tping --bar` | Bar chart visualization |
| `x tping --csv` | CSV format output |
| `x tping --tsv` | TSV format output |
| `x tping --raw` | Raw format output |

---

## Examples

### Basic Ping

```bash
# Ping port 80 (default) - runs indefinitely until Ctrl+C
x tping bing.com

# Ping with count limit (recommended - stops after N times)
x tping -n 10 bing.com
x tping -n 20 bing.com:443

# Ping port 443
x tping bing.com:443

# Ping specific IP and port
x tping 8.8.8.8:53
```

### Visual Output

```bash
# Heatmap mode
x tping --heatmap bing.com

# Bar chart mode
x tping --bar bing.com:80
```

### Data Processing

```bash
# CSV output
x tping --csv bing.com

# TSV output
x tping --tsv bing.com:443
```

---

## Comparison with Traditional Ping

| Feature | Traditional Ping | x tping |
|---------|-----------------|---------|
| Protocol | ICMP | TCP |
| Port-specific | No | Yes |
| Firewall-friendly | Often blocked | Usually allowed |
| Output | Text | Visual modes + Data formats |

---

## Platform Notes

Uses `curl` for TCP connections. On Windows and older curl versions (<8.4), uses `x cosmo curl` to avoid connection issues.

---

## Related

- [Back to x-cmd Skill](../../SKILL.md)
- [x-cmd tping module](https://x-cmd.com/mod/tping)
