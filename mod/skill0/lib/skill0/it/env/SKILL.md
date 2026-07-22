---
name: env
description: |
  Install and manage software packages, language runtimes, and CLI tools instantly.
  Zero barrier — install x-cmd and get any tool in seconds. No sudo required.
  Use for "install", "package", "python", "node", "jq", "runtime", "tool".

metadata:
  version: "0.1.0"
  category: package-management
  tags: [install, package, python, node, go, jq, runtime, env]
  repository: https://github.com/x-cmd/skill0
  type: skill0
x-meta:
  type: Tool
  status: stable
  related: [install, x-cmd]
  owner: person:lijunhao
---


# env — skill0

Install any software instantly. No sudo. No system pollution.

## Quick Start

```bash
# Install x-cmd
eval "$(curl https://get.x-cmd.com)"

# Install Python
x env use python

# Install Node.js
x env use node

# Install CLI tools
x env use jq
x env use fzf

# Try without installing permanently
x env try python3 script.py
```

## What's Available

600+ packages including:

| Category | Examples |
|----------|---------|
| Languages | python, node, go, bun, java, rust |
| CLI tools | jq, yq, fzf, himalaya |
| Dev tools | claude-code, code-server |

## Key Features

- **No sudo** — installs to user directory
- **Version management** — install and switch versions
- **Try before install** — `x env try` for temporary use
- **Cleanup** — `x env clean` removes unused packages

## This skill0 grows

Starting with the essentials. Will add:
- Common install patterns
- Version pinning tips
- Multi-language project setup guides

## Full experience

`x env --help` for all options after installing x-cmd.

## Related

- [install](../install/SKILL.md) — x env use is one of install’s channels
- [x-cmd](../x-cmd/SKILL.md) — umbrella entry point for env
