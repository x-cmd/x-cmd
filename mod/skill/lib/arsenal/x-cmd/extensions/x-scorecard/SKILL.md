---
name: x-scorecard
description: |
  OpenSSF Scorecard for assessing open source project security.
  Check security best practices and compliance.
  
  **Requires x-cmd**: Use x-cmd skill to install and use x-cmd,
  see https://x-cmd.com/llms.txt . Note: load x-cmd with `. ~/.x-cmd.root/X` before use.

license: Apache-2.0
compatibility: POSIX Shell

metadata:
  author: Li Junhao
  version: "0.0.1"
  category: x-cmd-extension
  tags: [x-cmd, security, scorecard, openssf, audit]
---

# x scorecard - OpenSSF Security Scorecard

> OpenSSF Scorecard - Security health assessment for open source projects.

---

## Quick Start

```bash
# Check a project's scorecard
x scorecard info github.com/ossf/scorecard

# Search for supported projects
x scorecard search

# Update local index
x scorecard update
```

---

## Features

- **Security Scoring**: Automated security assessment
- **Best Practices**: Check compliance with security best practices
- **Project Search**: Find supported open source projects
- **Multiple Formats**: JSON, YAML, CSV output
- **Report Viewing**: Open detailed reports in browser

---

## Commands

| Command | Description |
|---------|-------------|
| `x scorecard info <project>` | Display scorecard for project |
| `x scorecard search [keyword]` | Search supported projects |
| `x scorecard open <project>` | Open report in browser |
| `x scorecard update` | Update local index |

---

## Examples

### Get Scorecard Info

```bash
# Basic scorecard
x scorecard info github.com/ossf/scorecard

# JSON format
x scorecard info github.com/nodejs/node --json

# YAML format
x scorecard info github.com/kubernetes/kubernetes --yml

# CSV format
x scorecard info github.com/torvalds/linux --csv

# Interactive view
x scorecard info github.com/microsoft/vscode --app
```

### Search Projects

```bash
# List all supported projects
x scorecard search

# Search with keyword
x scorecard search kubernetes
x scorecard search apache
```

### Open Reports

```bash
# Open in browser
x scorecard open github.com/ossf/scorecard
```

### Update Index

```bash
# Update local scorecard index
x scorecard update
```

---

## Scorecard Checks

Scorecard evaluates projects on multiple security dimensions:

| Check | Description |
|-------|-------------|
| **Code-Review** | Are code reviews required? |
| **Maintained** | Is the project actively maintained? |
| **Dependency-Update-Tool** | Uses automated dependency updates? |
| **Signed-Releases** | Are releases cryptographically signed? |
| **Vulnerabilities** | Known vulnerabilities present? |
| **Security-Policy** | Has a security policy? |
| **License** | Has an open source license? |
| **Binary-Artifacts** | Contains binary artifacts? |
| **Branch-Protection** | Has branch protection enabled? |
| **Dangerous-Workflow** | Dangerous GitHub Actions patterns? |
| **Token-Permissions** | Token permissions restricted? |
| **SAST** | Static analysis security testing? |
| **CII-Best-Practices** | Has CII Best Practices badge? |

---

## Project Format

Project addresses use format: `<platform>/<org>/<repo>`

Examples:
- `github.com/ossf/scorecard`
- `gitlab.com/namespace/project`

---

## Related

- [Back to x-cmd Skill](../../SKILL.md)
- [x-cmd scorecard module](https://x-cmd.com/mod/scorecard)
- [OpenSSF Scorecard](https://scorecard.dev)
- [Scorecard GitHub](https://github.com/ossf/scorecard)
