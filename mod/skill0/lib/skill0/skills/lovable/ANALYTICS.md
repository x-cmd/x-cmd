---
name: lovable-analytics
description: Query traffic and analytics across Lovable projects — visitor counts, pageviews, bounce rate, breakdowns.
---

# Lovable analytics

Part of [lovable SKILL.md](SKILL.md). Full MCP reference: [lovable-mcp-server.md](https://docs.lovable.dev/integrations/lovable-mcp-server.md).

## Quick overview across all projects

`list_projects` returns visitor counts per project — no need to query each one individually.

```bash
mcp__lovable__list_projects  workspace_id=<id>  publish_status=published
```

Response includes per project:
- `app_visitors_24h` / `app_visitors_7d` / `app_visitors_30d`
- `url` — live site URL
- `trending_score`

This is the fastest way to compare traffic across all projects.

## Detailed analytics per project

Requires a specific `project_id` and date range (RFC 3339 format).

```bash
mcp__lovable__get_project_analytics  project_id=<id>  start_date="2026-05-01T00:00:00Z"  end_date="2026-06-01T00:00:00Z"
```

Returns: visitors, pageviews, bounce rate, session duration, breakdowns by page, source, device, country.
Optional: `granularity="daily"` or `"hourly"`.

## Real-time trend

Current visitor count + visit counts in 5-minute intervals over the last 30 minutes.

```bash
mcp__lovable__get_project_analytics_trend  project_id=<id>
```

## Typical workflow

1. `list_projects publish_status=published` → get all project IDs + visitor summaries
2. Identify which project needs deeper analysis
3. `get_project_analytics` with date range → pageviews, sources, devices
4. `get_project_analytics_trend` → real-time traffic check
