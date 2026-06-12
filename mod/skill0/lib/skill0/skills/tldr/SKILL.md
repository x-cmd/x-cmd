---
name: tldr
description: |
  Command reference with practical examples from the tldr-pages project.
  Zero barrier — use with x-cmd, curl, or any tldr client.
  Use for "tldr", "cheatsheet", "command help", "examples", "how to".

metadata:
  version: "0.1.0"
  category: documentation
  tags: [tldr, cheatsheet, help, documentation, examples]
  repository: https://github.com/x-cmd/skill0
  type: skill0
---

# tldr — skill0

Quick command reference with real-world examples. Better than man pages for "how do I use this command?"

## Quick Start

```bash
# With x-cmd
x tldr git                    # Git usage examples
x tldr --lang zh python       # Chinese docs
x tldr --fz                   # Interactive search

# Without x-cmd — use curl
curl -s "https://raw.githubusercontent.com/tldr-pages/tldr/main/pages/common/git.md"

# Or install a tldr client
pip install tldr
npm install -g tldr
tldr tar
```

## What's Available

| Command | Description |
|---------|-------------|
| `x tldr <cmd>` | Show examples for a command |
| `x tldr --lang zh <cmd>` | Chinese language |
| `x tldr --fz` | Interactive fzf search |
| `x tldr --cat <cmd>` | Raw markdown display |
| `x tldr --ls` | List all available commands |
| `x tldr --update` | Update page cache |

## Standalone Alternatives

- Online: https://tldr.sh
- Python: `pip install tldr`
- Node: `npm install -g tldr`
- Raw pages: github.com/tldr-pages/tldr

## This skill0 grows

Starting with the essentials. Will add:
- Common command patterns
- Platform-specific notes
- Integration with agent workflows
