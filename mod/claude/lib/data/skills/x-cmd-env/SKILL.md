---
name: x-cmd-env
description: Install and manage 500+ development tools and CLI utilities (Python, Node.js, Go, Rust, Java, jq, yq, ripgrep, etc.) without root access using x-cmd. Use when the user needs a CLI tool that may not be installed, wants to set up a development environment, or mentions installing/using specific command-line tools.
---

# x-cmd Environment Manager

## Overview

x-cmd env is a universal package manager that installs 500+ CLI tools and development environments without requiring root access. Supports programming languages (Python, Node.js, Go, Rust, Java), utilities (jq, yq, ripgrep, fd, bat), cloud tools (kubectl, helm, terraform), and more.

## Usage Patterns

### One-Time Commands
Execute tools directly without installation:
```bash
x-cmd jq '.results[] | .name' data.json
x-cmd rg "TODO" ./src --type rust
x-cmd fd "*.log" /var/log
```

### Persistent Installation
Install for regular use:
```bash
x-cmd env use node=v20.11.0
x-cmd env use python go rust
x-cmd env unuse node
```

### Version Management
```bash
x-cmd env ls                      # list all in use package version
x-cmd env ls -i                   # list all installed packages
x-cmd env ls -a python            # List installed versions
```

## Decision Workflow

```
1. Check if tool exists: command -v <tool>

2. If missing, choose pattern:
   - One-time use     → x-cmd <tool> [args]
   - Regular use      → x-cmd env use <tool>[=version]

3. Execute task

4. Clean up if temporary: x-cmd env unuse <tool>
```

## Common Scenarios

**JSON Processing:**
```bash
command -v jq || x-cmd env use jq
jq '.results[] | {name, status}' data.json
```

**Code Search:**
```bash
x-cmd rg "TODO|FIXME" ./src --type py
```

**Python Development:**
```bash
x-cmd env use python=v3.11.0+23.11.0-2
python --version
```

**Node.js Project:**
```bash
x-cmd env use node
npm install && npm start
```

## Quick Reference

| Command | Purpose |
|---------|---------|
| `x-cmd <tool> [args]` | Run once without installation |
| `x-cmd env try <pkg>` | Install for session |
| `x-cmd env untry <pkg>` | Remove session package |
| `x-cmd env use <pkg>[=ver]` | Install permanently |
| `x-cmd env unuse <pkg>` | Remove permanent package |
| `x-cmd env ls` | list all in use package version |

## When to Use

- User needs CLI tools or development environments
- User wants programming languages (Python, Node, Go, etc.)
- User mentions utilities (jq, yq, ripgrep, etc.)
- User lacks root/sudo access
- User needs multiple tool versions
- Setting up development environments
