---
name: cve
description: |
  Look up CVE records via x cve — cached, zero-API-key, daily xz TSV.
  Load for cve, vulnerability id, kev, epss, nvd, cvelist, or security advisory.

metadata:
  version: "0.1.0"
  category: "security"
  tags: "cve,vulnerability,nvd,kev,epss,cvelist"
  repository: "https://github.com/x-cmd/skill0"
  type: "skill0"
  x-cmd-mod: "cve"
  datasource: "https://github.com/x-cmd/cve/releases/download/data/"
  upstream: "https://github.com/CVEProject/cvelistV5"
---

# cve — skill0

Per-year xz-compressed TSV; current and last year auto-refresh (1 h TTL), older years stay frozen 180 d. After the first online day, `x cve` works offline indefinitely.

## Quick Start with `x cve`

```bash
x cve info CVE-2024-0001      # id lookup (shorthand: x cve 2024-0001)
x cve year 2024               # per-year stream, pipe-friendly TSV
x cve detail CVE-2024-0001    # full upstream record (products, CWE, refs, ADP)
```

`x cve -h` for all flags, subcommands, and shorthand forms.

## Data and adjacent tools

Daily xz TSV published at `github.com/x-cmd/cve/releases/download/data/` (schema documented at the release). The cached record is a thin projection — for the questions that go one hop beyond it:

- `x shodan cve CVE-X` — EPSS score, KEV membership, exploit articles, vendor advisories
- `x kev ls` — CISA KEV catalog (known-exploited list, full table)
- `x osv` — per-package version-level query ("is MY version vulnerable"); accepts `osv-*` and `cve-*` ids
- `x cve detail` — raw `CVEProject/cvelistV5` JSON (canonical upstream, fetched on demand)
