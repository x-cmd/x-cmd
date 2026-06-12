---
name: meme
description: |
  Generate meme images by overlaying text onto templates.
  Zero barrier — works with Python + Pillow, no framework needed.
  Templates are fetched on demand from the awesome-meme data repo.
  Use for "meme", "meme generator", "text overlay", "distracted boyfriend", "image macro".

metadata:
  version: "0.1.0"
  category: image
  tags: [meme, image, text-overlay, pillow, imagemagick]
  repository: https://github.com/edwinjhlee/awesome-meme
  type: skill0
---

# meme — skill0

Generate meme images. 30+ templates. Zero barrier.

An AI agent reads this file and knows how to make memes. No x-cmd needed.

## Quick Start

```bash
# Install dependencies
pip install pillow pyyaml

# Generate a meme (auto-downloads template from GitHub)
python3 scripts/meme_render.py distracted-boyfriend "ZIG" "ME" "RUST"
```

## More Examples

```bash
python3 scripts/meme_render.py this-is-fine "ERROR LOG" "THIS IS FINE"
python3 scripts/meme_render.py drake-hotline-bling "Write tests" "Ship it"
python3 scripts/meme_render.py expanding-brain "Copy paste" "Google it" "Read docs" "Ask AI"
```

## Options

| Option | Values | Default | Description |
|--------|--------|---------|-------------|
| `--backend` | pillow, magick | pillow | Rendering backend |
| `--layout` | chest-label, above-head, bottom-label | (spec default) | Text placement preset |
| `--output` | file path | meme_output.jpg | Output file path |

## Font selection

| Text language | Font used |
|---|---|
| English / Latin | Impact (default) |
| Chinese / CJK | PingFang (macOS) / Noto Sans CJK (Linux) |
| Mixed | Each slot auto-detected independently |

Impact has no CJK glyphs — Chinese text will be invisible. The renderer auto-detects CJK and falls back to system fonts. On Linux: `apt install fonts-noto-cjk`.

## Pure Shell (no Python)

```bash
bash scripts/meme_render.sh distracted-boyfriend "ZIG" "ME" "RUST"
```

## Upgrade with x-cmd

If you have x-cmd installed:

```bash
eval "$(curl https://get.x-cmd.com)"
x meme distracted-boyfriend "ZIG" "ME" "RUST"
```

Same result, cleaner integration with the x-cmd ecosystem.

## Data Source

Templates live in [awesome-meme](https://github.com/edwinjhlee/awesome-meme). The renderer fetches specs and images from GitHub on demand.

## Docs

- [references/INSTALL.md](references/INSTALL.md) — Dependencies (Pillow, ImageMagick, fonts)
- [references/PILLOW.md](references/PILLOW.md) — Pillow backend details
- [references/IMAGE_MAGICK.md](references/IMAGE_MAGICK.md) — ImageMagick backend details
- [references/GUIDELINES.md](references/GUIDELINES.md) — AI agent usage guidelines
