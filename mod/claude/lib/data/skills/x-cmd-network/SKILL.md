---
name: x-cmd-network
description: Get network information using x-cmd including public IP address, DNS lookups, and ping tests. Use when user asks "what's my IP", "check DNS for domain", "ping host", or needs network diagnostics.
---

# x-cmd Network Information

Retrieve network information and perform network diagnostics using x-cmd.

## Commands Overview

### Get Public IP Address
```bash
x-cmd ip
```
Returns current public IP address.

### DNS Lookup
```bash
x-cmd dns <domain>
```
Resolves domain to IP and shows DNS records.

### Ping Host
```bash
x-cmd ping <host>
```
Tests connectivity and measures latency.

## Common Scenarios

**Check Internet Connectivity:**
```bash
x-cmd ip
x-cmd dns google.com
x-cmd ping 8.8.8.8
```

**Troubleshoot Domain:**
```bash
x-cmd dns github.com
```

**Test Network Latency:**
```bash
x-cmd ping google.com
```

## Quick Reference

| Command | Purpose |
|---------|---------|
| `x-cmd ip` | Get public IP address |
| `x-cmd dns <domain>` | DNS lookup |
| `x-cmd ping <host>` | Test connectivity |

## When to Use

- User asks "what's my IP" or "my public IP"
- User wants to resolve domain to IP
- User needs to test connectivity or latency
- User troubleshoots network or domain issues
