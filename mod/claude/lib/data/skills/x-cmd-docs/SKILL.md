---
name: x-cmd-docs
description: Look up documentation and reference information using x-cmd including simplified man pages (tldr), Wikipedia articles, RFC documents, and CVE security information. Use when user asks for command examples, wants to search Wikipedia, needs RFC specs, or checks security vulnerabilities.
---

# x-cmd Documentation & Reference Lookup

Access documentation and reference sources using x-cmd.

## Commands Overview

### TLDR - Simplified Man Pages
```bash
x-cmd tldr <command>
```
Shows practical examples and common use cases for commands.

### Man Pages
```bash
x-cmd man <command>
```
Shows the full official manual for a command, including all options, arguments, and detailed usage.

### Wikipedia Search
```bash
x-cmd wkp <query>
```
Returns Wikipedia article summary for general information and definitions.

### RFC Documents
```bash
x-cmd rfc <number>
```
Displays IETF RFC document content for protocol specifications.

### Security Vulnerability Lookup
```bash
x-cmd osv <CVE-ID>
```
Shows vulnerability details, severity, and affected versions.

## Common Scenarios

**Learn Command Usage:**
```bash
x-cmd tldr tar
x-cmd tldr git
x-cmd tldr docker
```

**Man Pages:**
```bash
x-cmd man ls
x-cmd man tar
x-cmd man git
```

**Research Topics:**
```bash
x-cmd wkp "quantum computing"
x-cmd wkp "REST API"
```

**Look Up Protocols:**
```bash
x-cmd rfc 9110  # HTTP Semantics
x-cmd rfc 8446  # TLS 1.3
```

**Check Vulnerabilities:**
```bash
x-cmd osv CVE-2024-3094  # XZ backdoor
x-cmd osv CVE-2021-44228  # Log4Shell
```

## Quick Reference

| Command | Purpose |
|---------|---------|
| `x-cmd tldr <command>` | Command examples |
| `x-cmd man <command>` | Man Pages |
| `x-cmd wkp <query>` | Wikipedia lookup |
| `x-cmd rfc <number>` | RFC documents |
| `x-cmd osv <CVE-ID>` | CVE information |

## When to Use

- User asks "how to use" a command or needs examples
- User wants to search Wikipedia for definitions
- User needs protocol specifications or RFCs
- User checks security vulnerabilities or CVEs
- User prefers concise examples over full man pages
