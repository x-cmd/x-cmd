---
name: agent-browser-cleanup
description: Cleanup accumulated agent-browser data — screenshots, session metadata, Chrome profile cache.
---

# agent-browser cleanup

`close` does not delete any data. Both light and full cleanup are safe —
**no re-authorization** after deleting any files (tested on macOS).

## Light cleanup

Keeps profile data (cookies, auth state).

```bash
rm -rf ~/.agent-browser/tmp/screenshots/*
rm -f ~/.agent-browser/*.pid ~/.agent-browser/*.sock ~/.agent-browser/*.engine ~/.agent-browser/*.version
rm -rf /tmp/ab-default/Default/Cache /tmp/ab-default/Default/Code\ Cache /tmp/ab-default/GraphiteDawnCache
```

## Full cleanup

Removes everything including profile. Chrome recreates profile silently on next launch.

```bash
rm -rf ~/.agent-browser/tmp/screenshots/*
rm -f ~/.agent-browser/*.pid ~/.agent-browser/*.sock ~/.agent-browser/*.engine ~/.agent-browser/*.version
rm -rf /tmp/ab-default/
```

## What accumulates

| Path | Content | Size |
|------|---------|------|
| `~/.agent-browser/tmp/screenshots/` | Screenshot temp files | ~100KB–1MB each |
| `~/.agent-browser/<session>.*` | Session metadata (pid, sock, engine, version) | ~20 bytes each |
| `<profile>/Default/Cache/` | Chrome HTTP cache | Up to hundreds of MB |
| `<profile>/Default/Code Cache/` | Chrome JS cache | Up to hundreds of MB |
| `<profile>/GraphiteDawnCache/` | GPU shader cache | A few MB |
| `<profile>/Default/` | Cookies, localStorage, IndexedDB | Varies |

`<profile>` defaults to `/tmp/ab-default` (set via `--profile`).

## Notes

- `agent-browser --session <name> close` closes the browser but does not delete any files
- `agent-browser doctor --fix` cleans stale metadata but **reinstalls Chrome** — avoid for routine cleanup
- Never delete your personal Chrome profile (`~/Library/Application Support/Google/Chrome/`)
