---
name: lovable-troubleshooting
description: Common issues when developing with Lovable — PWA, sync, deploy, and debugging patterns.
---

# Lovable troubleshooting

Part of [lovable SKILL.md](SKILL.md). Full MCP reference: [lovable-mcp-server.md](https://docs.lovable.dev/integrations/lovable-mcp-server.md).

## Common issues

| Situation | Action |
|-----------|--------|
| Site not updated after deploy | `deploy_project` — wait 30s, check lovable.app URL first |
| Code change, local repo exists | Local edit → push → deploy |
| Code change, no local repo | `send_message` (high credit cost) |
| Mobile test | `agent-browser set device "iPhone 14"` |
| PWA behaves differently from browser | PWA (home screen) has separate cache/service worker — test both |
| Lovable and GitHub out of sync | Avoid mixing `send_message` with local edits — pick one workflow |
| Need to compare edit history | `list_edits` / `get_diff` to compare with local `git log` |
| Deploy succeeded but custom domain shows old version | CDN cache — wait or check lovable.app URL directly |

## Key lessons

- **Local first**: never use `send_message` when you have a local repo. `send_message` edits Lovable sandbox which can diverge from GitHub.
- **PWA vs browser**: iOS home screen PWA has its own SW cache, separate from Safari. Changes may take longer to appear.
- **Custom domains**: `deploy_project` returns the lovable.app URL. Custom domains point to the same build but may have CDN caching delay.
- **Always `get` knowledge before `set`**: `set_project_knowledge` replaces content entirely.
