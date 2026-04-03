---
name: x-theme
description: |
  Change terminal command line prompt theme.
  Globally manage the display style of all x-cmd interactive components.
  Supports multiple theme vendors: theme, starship, ohmyposh.
  
  **Dependency**: This is an x-cmd module. Install x-cmd first (see x-cmd skill for installation options).
  see x-cmd skill for installation.

license: Apache-2.0
compatibility: POSIX Shell

metadata:
  author: Li Junhao
  version: "1.0.0"
  category: x-cmd-extension
  tags: [x-cmd, theme, prompt, shell, customization]
---

# x theme - Terminal Theme Manager

> Change terminal command line prompt theme and manage display styles.

---

## Quick Start

```bash
# Open interactive theme preview
x theme

# List available themes
x theme ls

# Use a theme
x theme use robby
```

---

## Features

- **Interactive Preview**: Visual theme selection with `--app`
- **Multiple Vendors**: Supports theme, starship, ohmyposh
- **Feature Management**: Enable/disable transient mode, emoji, symbols
- **Font Integration**: Install fonts for better theme rendering
- **Shell Support**: bash, zsh, fish, PowerShell

---

## Commands

| Command | Description |
|---------|-------------|
| `x theme` | Open interactive theme preview (default) |
| `x theme --app` | Open theme preview client |
| `x theme ls` | List all themes |
| `x theme ls --info` | List current environment theme info |
| `x theme use <name>` | Use theme globally |
| `x theme unuse` | Unset theme |
| `x theme try <name>` | Try theme in current session |
| `x theme untry` | Cancel try mode |
| `x theme current` | Show current theme |
| `x theme update` | Update theme resources |
| `x theme font` | Install fonts |
| `x theme feature use <feature>` | Enable feature globally |
| `x theme feature try <feature>` | Try feature in current session |

---

## Theme Vendors

| Vendor | Description |
|--------|-------------|
| `theme` | x-cmd built-in themes (el, ide, mini, l series) |
| `starship` | Starship.rs cross-shell prompt |
| `ohmyposh` | Oh-My-Posh prompt theme engine |

---

## Examples

### Basic Usage

```bash
# Open interactive theme selector
x theme

# Use a theme globally
x theme use robby

# Use random theme
x theme use random

# Use random from specific themes
x theme use random "ys,ya,vitesse"
```

### Try Before Apply

```bash
# Try theme in current session only
x theme try robby

# Cancel try
x theme untry
```

### Feature Management

```bash
# Enable transient mode globally
x theme feature use transient_enable always

# Disable transient mode
x theme feature use transient_enable never

# Try emoji feature
x theme feature try emoji -t festival
```

### Vendor-Specific Themes

```bash
# Use starship theme via x theme
x theme use --vendor starship gruvbox-rainbow

# Use ohmyposh theme via x theme
x theme use --vendor ohmyposh montys
```

---

## Available Features

| Feature | Description |
|---------|-------------|
| `transient_enable` | Simplify prompt after command execution |
| `transient_cwd` | Show cwd in transient mode |
| `transient_time` | Show execution time in transient mode |
| `emoji` | Enable emoji in prompt |
| `symbol` | Use symbols in prompt |
| `zshplugin` | Load zsh plugins |

---

## Theme Series

| Series | Description |
|--------|-------------|
| `el` | Elegant line themes |
| `ide` | IDE-style themes |
| `mini` | Minimal themes |
| `l` | Lightweight themes |

---

## Related

- [x starship](https://x-cmd.com/mod/starship) - Starship prompt module
- [x ohmyposh](https://x-cmd.com/mod/ohmyposh) - Oh-My-Posh module
- [x font](https://x-cmd.com/mod/font) - Font installation module
