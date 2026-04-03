---
name: x-nets
description: |
  Enhanced netstat module with cached data and structured output.
  View network connections, routing tables, and interface statistics
  in interactive or TSV/CSV formats.
  
  **Dependency**: This is an x-cmd module. Install x-cmd first (see x-cmd skill for installation options).
  see x-cmd skill for installation.

license: Apache-2.0
compatibility: POSIX Shell

metadata:
  author: Li Junhao
  version: "1.0.0"
  category: x-cmd-extension
  tags: [x-cmd, network, netstat, connections, monitoring]
---

# x nets - Enhanced Network Statistics

> Enhanced `netstat` with data caching and structured output formats.

---

## Quick Start

```bash
# Update/collect network data (creates cache)
x nets update

# List available tables
x nets ls

# View a specific table
x nets view internet
```

---

## Features

- **Data Caching**: Update and cache network data for faster access
- **Table View**: View different network tables (internet, route, etc.)
- **Multiple Formats**: TSV, CSV output for data processing
- **Interactive Mode**: Interactive table selection
- **Cross-platform**: Works on Linux, macOS, Windows

---

## Commands

| Command | Description |
|---------|-------------|
| `x nets update` | **Collect and cache network data** |
| `x nets ls` | List all available tables |
| `x nets view <table>` | View table in interactive mode |
| `x nets view --tsv <table>` | View table in TSV format |
| `x nets view --csv <table>` | View table in CSV format |

---

## Examples

### Update Data (Create Cache)

```bash
# Collect and cache all network data
x nets update

# This creates cached data in ~/.x-cmd.root/data/nets/
```

### List Available Tables

```bash
# Show all available tables
x nets ls

# Common tables:
# - internet  : TCP/UDP connections
# - route     : Routing table
# - interface : Network interface statistics
```

### View Tables

```bash
# Interactive mode - select table to view
x nets view

# View specific table (interactive)
x nets view internet

# View in TSV format (for scripting)
x nets view --tsv internet

# View in CSV format
x nets view --csv route
```

### Data Processing

```bash
# Filter connections with awk
x nets view --tsv internet | awk -F'\t' '$1 == "TCP"'

# Count connections by state
x nets view --tsv internet | cut -f4 | sort | uniq -c

# Import into spreadsheet
x nets view --csv route > route.csv
```

---

## Available Tables

| Table | Description |
|-------|-------------|
| `internet` | TCP/UDP connections (like netstat) |
| `route` | Routing table information |
| `interface` | Network interface statistics |

---

## Table Output Fields

### internet table

| Field | Description |
|-------|-------------|
| Protocol | TCP/UDP |
| Local Address | Local IP:port |
| Foreign Address | Remote IP:port |
| State | Connection state (ESTABLISHED, LISTEN, etc.) |

### route table

| Field | Description |
|-------|-------------|
| Destination | Target network |
| Gateway | Next hop |
| Flags | Route flags |
| Interface | Network interface |

---

## Workflow

```bash
# 1. Update data (do this first or when data is stale)
x nets update

# 2. List available tables
x nets ls

# 3. View specific table
x nets view internet

# 4. Or process with other tools
x nets view --tsv internet | x csv sql "SELECT * WHERE State = 'ESTABLISHED'"
```

---

## Platform Notes

- **Linux**: Uses `netstat`, `ss`, or `/proc/net` data
- **macOS**: Uses `netstat` and `route` commands
- **Windows**: Uses `netstat` command

Data is cached in `~/.x-cmd.root/data/nets/latest/` for faster access.

---

## Related

- Native `netstat(8)` manual page
