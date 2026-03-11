---
name: x-starship
description: |
  Starship.rs cross-shell prompt with theme management.
  Minimal, blazing-fast, and infinitely customizable prompt.
  Auto-downloads starship binary if not available.
  
  **Requires x-cmd**: Use x-cmd skill to install and use x-cmd,
  see https://x-cmd.com/llms.txt . Note: load x-cmd with `. ~/.x-cmd.root/X` before use.

license: Apache-2.0
compatibility: POSIX Shell

metadata:
  author: Li Junhao
  version: "0.0.1"
  category: x-cmd-extension
  tags: [x-cmd, starship, prompt, theme, shell]
---

# x starship - Starship Prompt

> Starship.rs cross-shell prompt with easy theme switching.

---

## Quick Start

```bash
# Interactive theme preview
x starship

# Use a theme
x starship use gruvbox-rainbow

# List available themes
x starship ls
```

---

## Features

- **Auto-download**: Downloads starship binary automatically if not installed
- **Theme Preview**: Interactive fzf preview of all themes
- **One-command Switch**: Easy theme switching with `use`
- **Shell Support**: bash, zsh, fish, PowerShell
- **Custom Configs**: Support custom TOML configuration files

---

## Commands

| Command | Description |
|---------|-------------|
| `x starship` | Interactive theme preview (default) |
| `x starship fz` | Interactive theme preview with fzf |
| `x starship ls` | List all themes |
| `x starship use <name>` | Use theme globally |
| `x starship unuse` | Unset starship theme |
| `x starship try <name>` | Try theme in current session |
| `x starship untry` | Cancel try mode |
| `x starship current` | Show current theme |
| `x starship update` | Update theme resources |
| `x starship which <name>` | Get theme config file path |
| `x starship --run <cmd>` | Run native starship commands |

---

## Examples

### Basic Usage

```bash
# Open interactive theme selector
x starship

# Use a theme
x starship use gruvbox-rainbow

# Use no-nerd-font theme
x starship use no-nerd-font

# Use in specific shell
x starship use --shell fish gruvbox-rainbow

# Use in VSCode terminal
x starship use --vscode no-nerd-font
```

### Custom Configuration

```bash
# Use custom config file
x starship use /path/to/custom.toml
```

### Try Mode

```bash
# Try theme temporarily
x starship try pastel-powerline

# Cancel try
x starship untry
```

### Native Commands

```bash
# Run native starship commands
x starship --run prompt
x starship --run module git
```

---

## Available Themes

| Theme | Description |
|-------|-------------|
| `gruvbox-rainbow` | Gruvbox color scheme with rainbow segments |
| `pastel-powerline` | Soft pastel colors |
| `tokyo-night` | Tokyo Night color scheme |
| `no-nerd-font` | Theme without Nerd Font symbols |
| `no-empty-icons` | Hide empty icon segments |
| `no-runtime-versions` | Hide runtime version segments |
| `jetpack` | Compact single-line theme |
| `pure-preset` | Pure shell style |
| `nerd-font-symbols` | Rich Nerd Font symbols |
| `bracketed-segments` | Bracketed segment style |

---

## Features

| Feature | Description |
|---------|-------------|
| `zshplugin` | Load zsh-syntax-highlighting, zsh-autosuggestions |

---

## Notes

- Try/untry features only work in bash and zsh
- Using starship theme overrides STARSHIP_CONFIG environment variable

---

## Related

- [Starship Website](https://starship.rs)
- [x theme](extensions/x-theme/SKILL.md) - Main theme manager
- [x font](extensions/x-font/SKILL.md) - Font installation
- [Back to x-cmd Skill](../../SKILL.md)
