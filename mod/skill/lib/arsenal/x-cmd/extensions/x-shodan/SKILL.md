---
name: x-shodan
description: |
  Shodan CLI for searching Internet-connected devices.
  Host intel, DNS tools, network scanning, alerts.
  
  **Requires x-cmd**: Use x-cmd skill to install and use x-cmd,
  see https://x-cmd.com/llms.txt . Note: load x-cmd with `. ~/.x-cmd.root/X` before use.

license: Apache-2.0
compatibility: POSIX Shell

metadata:
  author: Li Junhao
  version: "0.0.1"
  category: x-cmd-extension
  tags: [x-cmd, security, shodan, reconnaissance, network]
---

# x shodan - Internet Search Engine

> Shodan CLI - Search engine for Internet-connected devices and systems.

---

## Quick Start

```bash
# Initialize with API key
x shodan init

# Search for devices
x shodan search apache

# Get host information
x shodan host 8.8.8.8
```

---

## Features

- **Device Search**: Find Internet-connected devices
- **Host Intelligence**: Detailed host/port information
- **Network Monitoring**: Alerts and scanning
- **Geolocation**: Ping/DNS from multiple locations
- **DNS Tools**: Domain resolution and reverse DNS
- **Vulnerability Checks**: CVE and CPE lookups

---

## Setup

```bash
# Get API key from https://account.shodan.io
# Then initialize
x shodan init

# Or set API key directly
x shodan --cfg key=<your_api_key>
```

---

## Commands

| Command | Description |
|---------|-------------|
| `x shodan search <query>` | Search Shodan database |
| `x shodan host <ip>` | Get host information |
| `x shodan count <query>` | Count search results |
| `x shodan download <query>` | Download search results |
| `x shodan dns res <domain>` | DNS resolution |
| `x shodan dns rev <ip>` | Reverse DNS |
| `x shodan geo ping <ip>` | Ping from multiple locations |
| `x shodan geo dns <domain>` | DNS query from multiple locations |
| `x shodan idb <ip>` | InternetDB lookup |
| `x shodan ip` | Get current IP |
| `x shodan scan create <ip>` | Create scan |
| `x shodan alert ls` | List alerts |
| `x shodan cve <id>` | CVE lookup |
| `x shodan cpe <product>` | CPE lookup |

---

## Examples

### Search

```bash
# Search for Apache servers
x shodan search apache

# Search with filters
x shodan search 'port:22 country:US'

# Count results
x shodan count nginx

# Download results
x shodan download --limit 100 apache-results apache
```

### Host Analysis

```bash
# Get host details
x shodan host 8.8.8.8

# InternetDB quick lookup
x shodan idb 8.8.8.8

# Get current IP info
x shodan ip
```

### DNS Tools

```bash
# Resolve domains
x shodan dns res google.com facebook.com

# Reverse DNS
x shodan dns rev 8.8.8.8 1.1.1.1

# Geo DNS query
x shodan geo dns google.com
```

### Scanning

```bash
# Create network scan
x shodan scan create 8.8.8.8

# Scan specific ports
x shodan scan create 1.1.1.1=53/dns-udp,443/https

# List scans
x shodan scan ls
```

### Alerts

```bash
# List alerts
x shodan alert ls

# Add trigger to alert
x shodan alert trigger add <alert_id> <trigger_name> 8.8.8.8:22
```

### Trends & Analysis

```bash
# Search trends
x shodan trend search port:22

# List facets
x shodan trend facets

# Search entity database
x shodan entitydb search GOOGL
```

---

## Search Filters

Common Shodan search filters:

| Filter | Example | Description |
|--------|---------|-------------|
| `port:` | `port:22` | Specific port |
| `country:` | `country:US` | Country code |
| `os:` | `os:Linux` | Operating system |
| `product:` | `product:nginx` | Product name |
| `version:` | `version:1.20` | Version number |
| `org:` | `org:Google` | Organization |
| `net:` | `net:192.168.0.0/24` | Network range |

---

## Related

- [Back to x-cmd Skill](../../SKILL.md)
- [x-cmd shodan module](https://x-cmd.com/mod/shodan)
- [Shodan Website](https://www.shodan.io)
- [Shodan Docs](https://developer.shodan.io)
