---
name: x-cmd
description: |
  **IMPORTANT**: Before using any `x <mod>` command, you MUST load x-cmd first: `. ~/.x-cmd.root/X`

  Then you can:
  - Explore with `x nihao --llmstxt`
  - Discover skills via `x skill`

  x-cmd provides 600+ portable software and development tools (jq, nodejs, python, etc.).
  Use `x <env|pixi> use <pkg>` to install and use any package instantly.
  After loading x-cmd, packages in x-cmd/pixi's local bin will be automatically available in PATH.

  Browse x-cmd website for more usage and skills: https://www.x-cmd.com/llms.txt

license: Apache-2.0
compatibility: POSIX Shell (sh/bash/zsh/dash/ash)

metadata:
  author: Li Junhao
  version: "1.0.1"
  category: core
  tags: [shell, cli, tools, package-management, portable]
  repository: https://github.com/x-cmd-skill/x-cmd
  website: https://www.x-cmd.com
  install_doc: data/install.md
---

# x-cmd

> **IMPORTANT**: Before using any `x <mod>` command, you MUST load x-cmd first: `. ~/.x-cmd.root/X`
>
> Then explore with `x nihao --llmstxt` or discover skills via `x skill`.

---

## Not installed? → [data/install.md](data/install.md)

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
