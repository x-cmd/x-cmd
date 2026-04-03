---
name: x-ohmyposh
description: |
  Oh-My-Posh prompt theme engine with theme management.
  Cross-platform tool to render your prompt with consistent experience.
  Auto-downloads oh-my-posh binary if not available.
  
  **Dependency**: This is an x-cmd module. Install x-cmd first (see x-cmd skill for installation options).
  see x-cmd skill for installation.

## Prerequisites

| Tool | Purpose | Notes |
|------|---------|-------|
| x-cmd | Required module runtime | `brew install x-cmd` |
| oh-my-posh | Prompt theme engine | Optional - x-cmd auto-downloads from GitHub if not present |

**Auto-download Security**: When oh-my-posh is not found locally, x-cmd downloads the official binary from GitHub (https://github.com/JanDeDobbeleer/oh-my-posh/releases). All downloads are verified with SHA256 checksums before execution.


license: Apache-2.0
compatibility: POSIX Shell

metadata:
  author: Li Junhao
  version: "1.0.0"
  category: x-cmd-extension
  tags: [x-cmd, ohmyposh, oh-my-posh, prompt, theme, shell]
