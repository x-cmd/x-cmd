---
name: lovable
description: Lovable MCP tool usage — deploy projects, message agent, test with agent-browser. Minimize credits by delegating to local repo.
---

# Lovable

## Setup & full MCP reference

```
claude mcp add --transport http lovable "https://mcp.lovable.dev"
```

Full MCP reference: [lovable-mcp-server.md](https://docs.lovable.dev/integrations/lovable-mcp-server.md).

| | |
|---|---|
| Plan | Pro/Business required |
| Auth | OAuth browser prompt on first call |
| Clients | Claude Code, Claude Desktop, ChatGPT, Cursor, VS Code |

## Core workflow: local first, save credits

```
local edit → npm run dev (verify) → git push → mcp__lovable__deploy_project → agent-browser test
```

## Common MCP calls

```
mcp__lovable__list_workspaces
mcp__lovable__list_projects  workspace_id=<id>  query=<name>
mcp__lovable__get_project  project_id=<id>
mcp__lovable__deploy_project  project_id=<id>
mcp__lovable__send_message  project_id=<id>  message="<instruction>"  wait=true
mcp__lovable__get_diff  project_id=<id>  message_id=<msg_id>
```

## Usecase — Analytics

Quick overview: `list_projects publish_status=published` returns visitor counts per project.
Export as TSV/CSV with schema: `id, project, 24h, 7d, 30d, URL`.

For detailed analytics (pageviews, bounce rate, traffic sources, devices), see [ANALYTICS.md](ANALYTICS.md).

## Usecase — Knowledge (persisted instructions for Lovable agent)

```
mcp__lovable__get_project_knowledge  project_id=<id>
mcp__lovable__set_project_knowledge  project_id=<id>  content="<markdown>"
```
Always `get` before `set` — replaces entirely. Max 10K chars. Also: `get/set_workspace_knowledge`.

## Test with agent-browser

```
agent-browser --profile /tmp/ab-default open <url> --session <proj>-mobile --headed
agent-browser --session <proj>-mobile set device "iPhone 14"
agent-browser --session <proj>-mobile snapshot -i
```
Full usage: see skill0 `agent-browser`.

## Troubleshooting

| Situation | Action |
|-----------|--------|
| Site not updated | `deploy_project` |
| Code change, local exists | Local → push → deploy |
| Code change, no local | `send_message` (high credit cost) |
| Mobile test | `agent-browser set device "iPhone 14"` |

For PWA issues, sync problems, and more, see [TROUBLESHOOTING.md](TROUBLESHOOTING.md).

## For more information

- [docs llms.txt](https://docs.lovable.dev/llms.txt) — full documentation index
- [lovable.dev llms.txt](https://lovable.dev/llms.txt) — product hub, pricing, guides, templates
- [Integrations](https://docs.lovable.dev/integrations/introduction.md) — Stripe, Supabase, Slack, etc.
- [Chat connectors](https://docs.lovable.dev/integrations/mcp-servers.md) — bring Notion, Linear, Jira into builds
- [Lovable API](https://docs.lovable.dev/integrations/lovable-api.md) — build apps programmatically via REST
