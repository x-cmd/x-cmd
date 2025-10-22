---
name: x-cmd-git
description: Manage Git repositories across multiple platforms (GitHub, GitLab, Gitee, Codeberg) using x-cmd unified interface. Use when user wants to create repos, manage issues/PRs, or interact with Git hosting platforms.
---

# x-cmd Git Multi-Platform Management

Unified interface for managing repositories across GitHub, GitLab, Gitee, and Codeberg.

## Supported Platforms

- `x-cmd gh` - GitHub
- `x-cmd gl` - GitLab
- `x-cmd gt` - Gitea/Gitee
- `x-cmd cb` - Codeberg

## Commands Overview

### Repository Management
```bash
x-cmd gh repo create <name> --public/--private
x-cmd gh repo list
x-cmd gh repo clone <owner>/<repo>
```

### Issue Management
```bash
x-cmd gh issue list
x-cmd gh issue create --title "Bug report" --body "Description"
x-cmd gh issue view <number>
```

### Pull Request Management
```bash
x-cmd gh pr list
x-cmd gh pr create --title "Fix bug" --body "Description"
x-cmd gh pr view <number>
```

**Note**: Commands work similarly across all platforms. Replace `gh` with `gl` (GitLab), `gt` (Gitee), or `cb` (Codeberg). GitLab uses `mr` (merge request) instead of `pr`.

## Common Scenarios

**Create Repository on Multiple Platforms:**
```bash
x-cmd gh repo create myproject --public
x-cmd gl repo create myproject --public
x-cmd gt repo create myproject --public
```

**List All Repositories:**
```bash
x-cmd gh repo list
x-cmd gl repo list
x-cmd gt repo list
```

**Manage Issues:**
```bash
x-cmd gh issue list
x-cmd gh issue create --title "Feature request"
```

**Create Pull Request:**
```bash
x-cmd gh pr create --title "New feature"
x-cmd gl mr create --title "New feature"
```

## Authentication

Required once per platform:
```bash
x-cmd gh --cfg token="<your token>"
x-cmd gl --cfg token="<your token>"
x-cmd gt --cfg token="<your token>"
x-cmd cb --cfg token="<your token>"
```

## Quick Reference

| Command | Purpose |
|---------|---------|
| `x-cmd gh repo create <name>` | Create repository |
| `x-cmd gh repo list` | List repositories |
| `x-cmd gh repo clone <owner>/<repo>` | Clone repository |
| `x-cmd gh issue list` | List issues |
| `x-cmd gh issue create` | Create issue |
| `x-cmd gh pr list` | List pull requests |
| `x-cmd gh pr create` | Create pull request |

## When to Use

- User wants to create repos on GitHub/GitLab/Gitee
- User needs to manage issues or PRs programmatically
- User wants unified commands across Git platforms
- User is migrating or mirroring between platforms
- User maintains repositories on multiple services
