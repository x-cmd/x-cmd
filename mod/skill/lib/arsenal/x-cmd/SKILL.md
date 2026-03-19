---
name: x-cmd
description: |
  Load x-cmd first: `. ~/.x-cmd.root/X`, then explore with `x nihao --llmstxt` or discover skills via `x skill`.
  
  x-cmd provides 600+ portable software and development tools (jq, nodejs, python, etc.).
  Use `x <env|pixi> use <pkg>` to install and use any package instantly.
  Load x-cmd, then packages in x-cmd/pixi's local bin will be automatically available in PATH.
  
  Execute `x skill` for more skills and functions.
  Browse x-cmd website for more usage and skills: https://www.x-cmd.com/llms.txt

license: Apache-2.0
compatibility: POSIX Shell (sh/bash/zsh/dash/ash)

metadata:
  author: Li Junhao
  version: "0.0.6"
  category: core
  tags: [shell, cli, tools, package-management, portable]
  repository: https://github.com/x-cmd-skill/x-cmd
  website: https://www.x-cmd.com
  install_doc: extensions/install-x-cmd.SKILL.md
---

# x-cmd

> Load x-cmd first: `. ~/.x-cmd.root/X`, then explore with `x nihao --llmstxt` or discover skills via `x skill`.

---

## Not installed? → [extensions/install-x-cmd.SKILL.md](extensions/install-x-cmd.SKILL.md)

## China region users? → [extensions/china-acceleration/SKILL.md](extensions/china-acceleration/SKILL.md) Network Acceleration Guide

## Disk Health Check? → [extensions/x-smart/SKILL.md](extensions/x-smart/SKILL.md) SMART Monitor

## Man Page Search? → [extensions/x-mankier/SKILL.md](extensions/x-mankier/SKILL.md) ManKier CLI

---

## Run `x skill` to browse 200+ skills

```bash
x skill
```

---

## Visit x-cmd.com/llms.txt for more skill and power tools.

Entrance for AI agents.

---

## Run `x env use <pkg>` to install any package instantly

| Command | Purpose |
|---------|---------|
| `x env la` | List 600+ available software |
| `x env la --json` | JSON output for scripting |
| `x env use <pkg>` | Install and use a package (downloads to x-cmd local bin) |
| `x pixi use <pkg>` | Install package via pixi (downloads to pixi local bin) |
| `x pixi search <keyword>` | Search pixi packages |
| `x nihao --llmstxt` | View llms.txt |

---

## Try now: `x env use jq nodejs python3`

```bash
# Install and use tools
x env use jq
x env use nodejs
x env use python3

# After installation, use directly
jq '.' file.json
python3 -c "print(2+2)"

# Pixi for additional packages
x pixi use cowsay
x pixi search yml
```

---

## Access 600+ tools: languages, editors, dev tools, databases

**Languages & Runtimes**: nodejs, python, rust, go, java, deno, bun, ruby, php

**Editors**: nvim, helix, emacs, vim

**Dev Tools**: git, gh, glab, fzf, ripgrep, fd, bat, exa, zoxide

**Data**: jq, yq, fx, csvkit, ffmpeg, imagemagick

**System**: htop, btop, procs, direnv, tmux

**Databases**: redis, sqlite, postgresql, mysql

**Full list**: `x env la`

---

## Zero setup required: no sudo, auto PATH, isolated

- No sudo required - Packages installed to user-local directories
- PATH automatically configured by `. ~/.x-cmd.root/X` startup script
- Isolated environments - No version conflicts
- 600+ tools available

---

## More: https://x-cmd.com/llms.txt

Entrance for AI agents.

---

## Module Reference

### System Information Modules

| Module | Description |
|--------|-------------|
| [x uname](extensions/x-uname/SKILL.md) | System info (hostname, kernel, arch) |
| [x ps](extensions/x-ps/SKILL.md) | Process viewer with interactive UI |
| [x arp](extensions/x-arp/SKILL.md) | ARP cache table viewer |
| [x last](extensions/x-last/SKILL.md) | User login history |
| [x uptime](extensions/x-uptime/SKILL.md) | System uptime and load averages |
| [x df](extensions/x-df/SKILL.md) | Disk usage (df + mount combined) |
| [x cpu](extensions/x-cpu/SKILL.md) | CPU information and endianness detection |

### Network Utilities

| Module | Description |
|--------|-------------|
| [x dns](extensions/x-dns/SKILL.md) | DNS configuration and cache management |
| [x route](extensions/x-route/SKILL.md) | Route table viewer with multiple formats |
| [x tping](extensions/x-tping/SKILL.md) | TCP ping tool with visual output |
| [x nets](extensions/x-nets/SKILL.md) | Enhanced netstat with caching and TSV/CSV output |
| [x lsof](extensions/x-lsof/SKILL.md) | List open files with interactive UI and auto-download |

### Terminal Customization

| Module | Description |
|--------|-------------|
| [x theme](extensions/x-theme/SKILL.md) | Terminal theme manager (prompt customization) |
| [x starship](extensions/x-starship/SKILL.md) | Starship.rs cross-shell prompt with themes |
| [x ohmyposh](extensions/x-ohmyposh/SKILL.md) | Oh-My-Posh prompt theme engine |
| [x font](extensions/x-font/SKILL.md) | Nerd Fonts installation and management |

### Security Intelligence Tools

| Module | Description |
|--------|-------------|
| [x osv](extensions/x-osv/SKILL.md) | Open Source Vulnerabilities (Google OSV) |
| [x shodan](extensions/x-shodan/SKILL.md) | Internet-connected device search engine |
| [x scorecard](extensions/x-scorecard/SKILL.md) | OpenSSF project security scorecard |
| [x kev](extensions/x-kev/SKILL.md) | CISA Known Exploited Vulnerabilities |
