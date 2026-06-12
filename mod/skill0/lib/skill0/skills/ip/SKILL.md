---
name: ip
description: |
  IP address utilities — geolocation, subnet scanning, port discovery.
  Zero barrier — use with x-cmd or curl + standard networking tools.
  Use for "ip", "geolocation", "subnet", "port scan", "network".

metadata:
  version: "0.1.0"
  category: networking
  tags: [ip, geolocation, network, subnet, port-scan, cidr]
  repository: https://github.com/x-cmd/skill0
  type: skill0
---

# ip — skill0

IP address lookup, geolocation, subnet discovery, and port scanning.

## Quick Start

```bash
# With x-cmd
x ip                        # List all local IPs
x ip geolite 8.8.8.8        # Geolocation lookup
x ip info 192.168.1.0       # IP classification
x ip map 192.168.1.0/24     # Discover active hosts
x ip tps localhost           # Port scan

# Without x-cmd — use curl for geolocation
curl -s "https://ipinfo.io/8.8.8.8/json"
# Use standard tools for local IPs
ifconfig | grep "inet "     # macOS
ip addr show                # Linux
```

## What's Available

| Command | Description |
|---------|-------------|
| `x ip ls` | List all local IP addresses |
| `x ip geolite <ip>` | Geolocation via ipinfo.io |
| `x ip info <ip>` | IP class/type classification |
| `x ip cidr <cidr>` | CIDR range info |
| `x ip map <subnet>` | ICMP ping sweep |
| `x ip tps <host>` | TCP port scan |

## Standalone Alternatives

- Geolocation: `curl https://ipinfo.io/<IP>/json`
- Local IPs: `ifconfig`, `ip addr`, `hostname -I`
- Port scan: `nc -zv`, `nmap`

## This skill0 grows

Starting with the essentials. Will add:
- Common networking patterns
- API reference for ipinfo.io
- Subnet calculation formulas
