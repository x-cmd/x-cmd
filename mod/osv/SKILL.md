---
name: x-osv
description: |
  CLI for Google OSV database. Query vulnerabilities for packages, 
  scan local projects for vulnerable dependencies.
  
  **Dependency**: This is an x-cmd module. Install x-cmd first (see x-cmd skill).
  **Required Tool**: Install osv-scanner for project scanning (see https://github.com/google/osv-scanner).

license: Apache-2.0
compatibility: POSIX Shell

metadata:
  author: Li Junhao
  version: "1.0.1"
  category: x-cmd-extension
  tags: [x-cmd, security, vulnerability, osv, scanner]
---

# x osv - Open Source Vulnerabilities

> Query Google OSV database for package vulnerabilities and scan local projects.

---

## Quick Start

```bash
# Query vulnerability for a package
x osv q -p jq -v 1.7.1

# Scan local project for vulnerabilities (requires osv-scanner)
x osv scanner .
```

---

## Features

- **Vulnerability Query**: Query OSV database for package vulnerabilities
- **Project Scanning**: Scan local projects using osv-scanner
- **SARIF Reports**: Generate SARIF security reports
- **Multi-ecosystem**: Supports npm, pip, Maven, Go, Rust, etc.

---

## Prerequisites

| Tool | Purpose | Install |
|------|---------|---------|
| x-cmd | Required module runtime | `brew install x-cmd` |
| osv-scanner | Project scanning | https://github.com/google/osv-scanner |

---

## Commands

| Command | Description |
|---------|-------------|
| `x osv q <pkg>` | Query vulnerabilities for a package |
| `x osv scanner <path>` | Scan project for vulnerabilities (requires osv-scanner) |
| `x osv vuln <id>` | Get vulnerability details |
| `x osv sarif` | Generate SARIF security reports |
| `x osv eco` | List supported ecosystems |

---

## Examples

### Query Vulnerabilities

```bash
# Query specific package version
x osv q -p jq -v 1.7.1

# Query by commit hash
x osv q -c 6879efc2c1596d11a6a6ad296f80063b558d5e0f
```

### Scan Projects

```bash
# Scan current directory (requires osv-scanner installed)
x osv scanner .

# Scan specific lockfile
x osv scanner --lockfile requirements.txt
x osv scanner --lockfile package-lock.json
```

### Generate SARIF Reports

```bash
# Scan npm project
x osv sarif npm ./my-project/

# Scan pip project with JSON output
x osv sarif pip ./project/ --json
```

---

## Supported Ecosystems

View all supported ecosystems:
```bash
x osv eco
```

Includes: npm, PyPI, Maven, Go, Rust, NuGet, Packagist, etc.

---

## API Key

No API key required for basic usage. Rate limits apply for unauthenticated requests.

---

## Related

- [OSV.dev](https://osv.dev) - Official OSV website
- [osv-scanner](https://github.com/google/osv-scanner) - Required tool for project scanning
