---
name: git
description: |
  Git and code hosting platform management — GitHub, GitLab, Codeberg, Forgejo.
  Zero barrier — install x-cmd and manage repos from the terminal.
  Use for "git", "github", "gitlab", "repo", "pull request", "code hosting".

metadata:
  version: "0.1.0"
  category: version-control
  tags: [git, github, gitlab, codeberg, repo, pr, code-review]
  repository: https://github.com/x-cmd/skill0
  type: skill0
---

# git — skill0

Manage Git repos and code hosting platforms from the command line.

## Quick Start

```bash
# Install x-cmd
eval "$(curl https://get.x-cmd.com)"

# GitHub repo management
x gh repo list
x gh repo clone owner/repo

# Create a pull request
x gh pr create --title "Fix bug" --body "Description"

# Git hooks management
x git hook
```

## What's Available

| Command | Platform | Description |
|---------|----------|-------------|
| `x gh` | GitHub | Full GitHub CLI integration |
| `x gl` | GitLab | GitLab project management |
| `x cb` | Codeberg | Codeberg integration |
| `x git hook` | Local | Git hooks management |

## This skill0 grows

Starting with GitHub basics. Will add:
- GitLab workflows
- Code hosting best practices
- Repo migration guides
- CI/CD integration tips

## Full experience

`x git --help` for all options after installing x-cmd.
