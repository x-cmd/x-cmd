---
name: x-font
description: |
  Font toolkit for installing and managing fonts.
  Specializes in Nerd Fonts installation with multiple download sources.
  Auto-downloads fonts from GitHub or Codeberg mirrors.
  
  **Requires x-cmd**: Use x-cmd skill to install and use x-cmd,
  see https://x-cmd.com/llms.txt . Note: load x-cmd with `. ~/.x-cmd.root/X` before use.

license: Apache-2.0
compatibility: POSIX Shell

metadata:
  author: Li Junhao
  version: "0.0.1"
  category: x-cmd-extension
  tags: [x-cmd, font, fonts, nerd-fonts, typography]
---

# x font - Font Toolkit

> Install and manage fonts, especially Nerd Fonts.

---

## Quick Start

```bash
# Interactive Nerd Fonts preview
x font

# Install a Nerd Font
x font nerd install FiraCode

# Refresh font cache
x font refresh
```

---

## Features

- **Nerd Fonts**: Specialized for Nerd Fonts installation
- **Multiple Sources**: GitHub and Codeberg mirror support
- **Auto-install**: Automatic download and installation
- **Font Cache**: Refresh system font cache
- **Interactive**: Preview fonts before installing

---

## Commands

| Command | Description |
|---------|-------------|
| `x font` | Interactive Nerd Fonts preview (default) |
| `x font nerd` | Nerd Fonts management |
| `x font nerd ls` | List available Nerd Fonts |
| `x font nerd install <name>` | Install Nerd Font |
| `x font nerd preview <name>` | Open web preview |
| `x font nerd info <name>` | View font information |
| `x font install <name>` | Install font (generic) |
| `x font refresh [dir]` | Refresh font cache |

---

## Examples

### Install Nerd Fonts

```bash
# Install FiraCode Nerd Font
x font nerd install FiraCode

# Or using shorthand
x font install nerd/FiraCode

# Install with specific source
x font nerd install FiraCode --gh    # GitHub
x font nerd install FiraCode --cb    # Codeberg

# For WSL desktop
x font nerd install FiraCode --linux
```

### List and Preview

```bash
# List all Nerd Fonts
x font nerd ls

# Preview font on web
x font nerd preview FiraCode

# Get font info
x font nerd info FiraCode
```

### Refresh Font Cache

```bash
# Refresh all font caches
x font refresh

# Refresh specific directory
x font refresh ~/.local/share/fonts
```

---

## Installation Paths

| Platform | Font Directory |
|----------|---------------|
| Linux | `~/.local/share/fonts` |
| macOS | `~/Library/Fonts` |
| Termux | `~/.termux` |
| WSL | `~/.local/share/fonts` (use `--linux` flag) |

---

## Nerd Fonts Version

Default: `v3.4.0`

Environment variable: `___X_CMD_FONT_NERD_VERSION`

---

## Font Cache

After installing fonts, you may need to refresh the font cache:

```bash
# Linux with fontconfig
x font refresh

# Or manually
fc-cache -f -v
```

---

## Setting Terminal Font

After installing Nerd Fonts, configure your terminal:

1. Open terminal preferences
2. Set font to "FiraCode Nerd Font" (or installed font name)
3. Restart terminal

Detailed guide: https://x-cmd.com/mod/font/cookbook-2

---

## Related

- [Nerd Fonts Website](https://www.nerdfonts.com)
- [x theme](extensions/x-theme/SKILL.md) - Theme manager
- [x starship](extensions/x-starship/SKILL.md) - Starship prompt
- [x ohmyposh](extensions/x-ohmyposh/SKILL.md) - Oh-My-Posh prompt
- [Back to x-cmd Skill](../../SKILL.md)
