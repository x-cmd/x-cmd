---
name: x-kev
description: |
  CISA Known Exploited Vulnerabilities (KEV) catalog.
  List actively exploited vulnerabilities prioritized by CISA.
  
  **Requires x-cmd**: Use x-cmd skill to install and use x-cmd,
  see https://x-cmd.com/llms.txt . Note: load x-cmd with `. ~/.x-cmd.root/X` before use.

license: Apache-2.0
compatibility: POSIX Shell

metadata:
  author: Li Junhao
  version: "0.0.1"
  category: x-cmd-extension
  tags: [x-cmd, security, kev, cisa, vulnerability]
---

# x kev - Known Exploited Vulnerabilities

> CISA KEV Catalog - Known Exploited Vulnerabilities listing.

---

## Quick Start

```bash
# List all KEV vulnerabilities
x kev ls

# List top 100 KEVs
x kev top 100
```

---

## Features

- **CISA KEV Catalog**: Official CISA Known Exploited Vulnerabilities
- **Prioritized Remediation**: Focus on actively exploited vulnerabilities
- **Simple Interface**: List and filter KEV entries

---

## Commands

| Command | Description |
|---------|-------------|
| `x kev ls` | List all vulnerabilities in KEV catalog |
| `x kev top [n]` | List top N vulnerabilities |

---

## Examples

### List KEVs

```bash
# List all KEV vulnerabilities
x kev ls

# Get top 50
x kev top 50

# Get top 100
x kev top 100
```

---

## About KEV

The CISA Known Exploited Vulnerabilities (KEV) catalog contains vulnerabilities that:

- Have been assigned CVE IDs
- Have been actively exploited in the wild
- Have clear remediation actions

**Reference**: [CISA KEV Catalog](https://www.cisa.gov/known-exploited-vulnerabilities-catalog)

---

## Why KEV Matters

1. **Prioritization**: Not all CVEs are equally critical
2. **Active Exploitation**: KEV focuses on vulnerabilities being actively used by attackers
3. **Compliance**: US federal agencies required to patch KEVs within specified timeframes
4. **Risk Reduction**: Addressing KEVs provides immediate security improvement

---

## Related

- [Back to x-cmd Skill](../../SKILL.md)
- [x-cmd kev module](https://x-cmd.com/mod/kev)
- [CISA KEV Catalog](https://www.cisa.gov/known-exploited-vulnerabilities-catalog)
