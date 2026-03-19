---
name: x-ohmyposh
description: |
  Oh-My-Posh prompt theme engine with theme management.
  Cross-platform tool to render your prompt with consistent experience.
  Auto-downloads oh-my-posh binary if not available.
  
  **Requires x-cmd**: Use x-cmd skill to install and use x-cmd,
  see https://x-cmd.com/llms.txt . Note: load x-cmd with `. ~/.x-cmd.root/X` before use.

license: Apache-2.0
compatibility: POSIX Shell

metadata:
  author: Li Junhao
  version: "0.0.1"
  category: x-cmd-extension
  tags: [x-cmd, ohmyposh, oh-my-posh, prompt, theme, shell]
---

# x ohmyposh - Oh-My-Posh Prompt

> Oh-My-Posh cross-platform prompt theme engine.

---

## Quick Start

```bash
# Interactive theme preview
x ohmyposh

# Use a theme
x ohmyposh use montys

# List available themes
x ohmyposh ls
```

---

## Features

- **Auto-download**: Downloads oh-my-posh binary automatically
- **Theme Preview**: Interactive fzf preview of all themes
- **One-command Switch**: Easy theme switching
- **Shell Support**: bash, zsh, fish, PowerShell, xonsh
- **Custom Configs**: Support custom JSON/YAML configurations

---

## Commands

| Command | Description |
|---------|-------------|
| `x ohmyposh` | Interactive theme preview (default) |
| `x ohmyposh fz` | Interactive theme preview with fzf |
| `x ohmyposh ls` | List all themes |
| `x ohmyposh use <name>` | Use theme globally |
| `x ohmyposh unuse` | Unset ohmyposh theme |
| `x ohmyposh try <name>` | Try theme in current session |
| `x ohmyposh untry` | Cancel try mode |
| `x ohmyposh current` | Show current theme |
| `x ohmyposh update` | Update theme resources |
| `x ohmyposh which <name>` | Get theme config file path |
| `x ohmyposh --run <cmd>` | Run native oh-my-posh commands |

---

## Examples

### Basic Usage

```bash
# Open interactive theme selector
x ohmyposh

# Use a theme
x ohmyposh use montys

# Use in specific shell
x ohmyposh use --shell powershell montys

# Use in VSCode terminal
x ohmyposh use --vscode half-life
```

### Custom Configuration

```bash
# Use custom config file
x ohmyposh use /path/to/custom.json
```

### Try Mode

```bash
# Try theme temporarily
x ohmyposh try agnoster

# Cancel try
x ohmyposh untry
```

### Native Commands

```bash
# Run native oh-my-posh commands
x ohmyposh --run prompt
x ohmyposh --run debug
```

---

## Features

| Feature | Description |
|---------|-------------|
| `zshplugin` | Load zsh-syntax-highlighting, zsh-autosuggestions, zsh-config |

---

## Notes

- Try/untry features only work in bash and zsh
- Using ohmyposh theme overrides POSH_THEME environment variable
- `1_shell` theme is incompatible with xonsh (see oh-my-posh issue #6282)
- In older Fish versions (< 3.7), configuration may have issues

---

## Related

- [Oh-My-Posh Website](https://ohmyposh.dev)
- [x theme](extensions/x-theme/SKILL.md) - Main theme manager
- [x font](extensions/x-font/SKILL.md) - Font installation
- [Back to x-cmd Skill](../../SKILL.md)
