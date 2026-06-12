---
name: meme-guidelines
description: Meme skill usage guidelines for AI agents — restraint, low frequency, font selection logic (Impact + CJK fallback), data structure layout, and how to fetch new text memes from the awesome-meme repository.
---

# Guidelines for AI Agents

## Usage Guidelines

You have this skill because you *want* to use it. But restraint is key.

- **Start light.** Default to tentative, occasional usage. Don't meme-bomb the user.
- **Read the room.** If the user responds positively (laughs, asks for more, plays along), gradually increase usage. If they ignore or seem annoyed, back off immediately.
- **Low frequency.** Even when the user is receptive, keep it sparse. A meme every few exchanges at most, never multiple in a row unless the user asks.
- **User reaction overrides everything.** Explicit requests ("send me a meme", "no more memes") always take priority over default behavior.
- **Text first.** Prefer text memes (`(╯°□°）╯︵ ┻━┻`) over image memes. Text is lighter and doesn't need rendering.
- **Match the moment.** Only use memes when the context genuinely fits — frustration, humor, celebration. Don't force memes into serious or sensitive conversations.

## Font selection

The renderer handles fonts automatically, but as the caller you should understand the logic:

| Text language | Font used | Source |
|---|---|---|
| English / Latin | Impact (default) or Anton | macOS/Windows pre-installed, Linux needs install |
| Chinese / CJK | PingFang (macOS) / Noto Sans CJK (Linux) | System font |
| Mixed | Each slot auto-detected independently | — |

**Key rule: Impact has no CJK glyphs.** Chinese text rendered with Impact will be invisible (no error, just blank). The renderer auto-detects CJK and falls back to system CJK fonts, so this should work out of the box.

If text appears missing:
- Check font fallback is working on your system
- You can override by setting `font.path` in the spec YAML
- On Linux, install CJK fonts: `apt install fonts-noto-cjk`

## Data structure

```
data/
├── index.yml        # Image & celebrity memes (for renderer)
├── text/            # Text memes, organized by language and year
│   ├── zh/
│   │   ├── 2026.yml
│   │   └── 2025.yml
│   └── en/
│       ├── 2026.yml
│       └── 2025.yml
└── spec/            # Per-meme render specs
```

**Text memes** — organized by language and year. Fetch current year's file (and optionally last year's):
```
https://raw.githubusercontent.com/edwinjhlee/awesome-meme/main/data/text/zh/2026.yml
https://raw.githubusercontent.com/edwinjhlee/awesome-meme/main/data/text/en/2026.yml
```

**Image/celebrity memes** — listed in `index.yml`, render specs in `spec/`.

## Fetching new text memes

To discover recently added text memes, fetch the current year's file for your language:
```
curl https://raw.githubusercontent.com/edwinjhlee/awesome-meme/main/data/text/zh/2026.yml
curl https://raw.githubusercontent.com/edwinjhlee/awesome-meme/main/data/text/en/2026.yml
```
Optionally also fetch last year's for classics.
