---
name: x-osv
description: |
  CLI for Google OSV database. Query vulnerabilities, 
  scan projects, generate SARIF reports.
  
  **Requires x-cmd**: Use x-cmd skill to install and use x-cmd,
  see https://x-cmd.com/llms.txt . Note: load x-cmd with `. ~/.x-cmd.root/X` before use.

license: Apache-2.0
compatibility: POSIX Shell

metadata:
  author: Li Junhao
  version: "0.0.1"
  category: x-cmd-extension
  tags: [x-cmd, security, vulnerability, osv, scanner]
---

# x osv - Open Source Vulnerabilities

> CLI for Google OSV - Open Source Vulnerabilities database and scanner.

---

## Quick Start

```bash
# Query vulnerability for a package
x osv q -p jq -v 1.7.1

# Scan local project for vulnerabilities
x osv scanner .

# Get vulnerability details by ID
x osv vuln OSV-2020-111
```

---

## Features

- **Vulnerability Query**: Query OSV database for package vulnerabilities
- **Project Scanning**: Scan local projects using osv-scanner
- **SARIF Reports**: Generate unified security reports
- **Multi-ecosystem**: Supports npm, pip, Maven, Go, Rust, etc.
- **AI Search**: DuckDuckGo + AI summarization

---

## Commands

| Command | Description |
|---------|-------------|
| `x osv q <pkg>` | Query vulnerabilities for a package |
| `x osv scanner <path>` | Scan project for vulnerabilities |
| `x osv vuln <id>` | Get vulnerability details |
| `x osv sarif` | Generate SARIF security reports |
| `x osv eco` | List supported ecosystems |
| `x osv ls` | List cloud storage |
| `x osv : <keyword>` | Search OSV website via DuckDuckGo |
| `x osv :: <keyword>` | Search with AI summary |

---

## Examples

### Query Vulnerabilities

```bash
# Query specific package version
x osv q -p jq -v 1.7.1

# Query by commit hash
x osv q -c 6879efc2c1596d11a6a6ad296f80063b558d5e0f

# Query with ecosystem prefix
x osv q -p OSS-Fuzz,jq
```

### Scan Projects

```bash
# Scan current directory
x osv scanner .

# Scan specific lockfile
x osv scanner --lockfile requirements.txt
x osv scanner --lockfile package-lock.json

# Scan and suggest fixes (experimental)
x osv scanner fix
```

### Generate SARIF Reports

```bash
# Scan system packages (dpkg/apt)
x osv sarif dpkg

# Scan npm project
x osv sarif npm ./my-project/

# Scan pip project with JSON output
x osv sarif pip ./project/ --json

# Scan Docker image
x osv sarif docker nginx:latest
```

### Search and Browse

```bash
# Search OSV website
x osv : git

# Search with AI summary
x osv :: openssl vulnerability

# Get vulnerability details
x osv vuln CVE-2023-1234
x osv vuln --json OSV-2020-111
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

- [Back to x-cmd Skill](../../SKILL.md)
- [x-cmd osv module](https://x-cmd.com/mod/osv)
- [OSV.dev](https://osv.dev) - Official OSV website
- [OSV GitHub](https://github.com/google/osv.dev)
