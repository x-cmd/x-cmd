---
name: agent-browser
description: Browser automation via Chrome/Chromium CDP — open, snapshot, click, screenshot. For testing web apps, mobile layouts, and automated interactions without Playwright/Puppeteer.
---

# agent-browser

## Install

```
x env use agent-browser
npm install -g agent-browser
brew install agent-browser
agent-browser install  # optional, skip if using existing Chrome
```

## Connect to existing Chrome

```
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --remote-debugging-port=9222
agent-browser --cdp 9222 open <url>
```

## Profile & multi-session

Use `--profile /tmp/ab-default` to authorize once and share across sessions.
Each new `--user-data-dir` triggers a Chrome auth prompt — reuse the default to avoid it.

```bash
agent-browser --profile /tmp/ab-default open <url> --session myapp-desktop --headed
agent-browser open <url> --session myapp-iphone14
agent-browser --session myapp-iphone14 set device "iPhone 14"
```

Session names are global — use `<project>-<device>` to avoid collisions across agents.
Sessions share the daemon but are fully isolated (cookies, cache, tabs).

## Skills & common commands

```
agent-browser skills get core --full
agent-browser open <url> --session <name> --device "iPhone 14"
agent-browser snapshot -i
agent-browser click @e<id>
agent-browser screenshot
agent-browser close --all
```

Data accumulates — see [CLEANUP.md](CLEANUP.md) for periodic cleanup.
