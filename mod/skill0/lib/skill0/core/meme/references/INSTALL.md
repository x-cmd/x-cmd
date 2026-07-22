---
name: meme-install
description: Install dependencies for the meme skill — x-cmd (optional), Pillow + PyYAML (Python), ImageMagick (brew/apt), Impact font (Microsoft Core Font), CJK fallback fonts, and open-source alternatives like Anton and Bangers.
---

# Install Dependencies

## x-cmd (optional)

[x-cmd](https://www.x-cmd.com) provides portable package management without sudo.

Install:

```bash
eval "$(curl https://get.x-cmd.com)"
```

See [x-cmd.com/llms.txt](https://www.x-cmd.com/llms.txt) for details.

## Pillow (Python)

```bash
pip install pillow pyyaml
```

Or via x-cmd:

```bash
x env use python
pip install pillow pyyaml
```

## ImageMagick

### macOS

```bash
brew install imagemagick
```

Or via x-cmd:

```bash
x pixi use imagemagick
```

### Linux

```bash
apt install imagemagick    # Debian/Ubuntu
dnf install imagemagick    # Fedora
```

## Fonts

### Impact (classic meme font)

- **macOS**: `/System/Library/Fonts/Supplemental/Impact.ttf` (pre-installed)
- **Windows**: `C:\Windows\Fonts\impact.ttf` (pre-installed)
- **Linux (Debian/Ubuntu)**: `sudo apt install ttf-mscorefonts-installer`
- **Linux (Fedora)**: `sudo dnf install ms-core-impact-fonts`
- **Note**: Impact is a Microsoft Core Font — free to use and distribute, but not open source

### CJK / Chinese fonts (required for Chinese text)

Impact has no CJK glyphs — Chinese text renders invisible with Impact. The renderer auto-detects CJK and falls back to system CJK fonts:

- **macOS**: PingFang (苹方) — pre-installed
- **Linux**: Noto Sans CJK — `sudo apt install fonts-noto-cjk` (Debian/Ubuntu) or `sudo dnf install google-noto-sans-cjk-fonts` (Fedora)

### Open-source alternatives to Impact

If you prefer fully open-source fonts:

- **Anton** (Google Fonts) — very similar to Impact, great for memes
- **Bangers** (Google Fonts) — comic/meme style, slightly rounder

Install from [Google Fonts](https://fonts.google.com):
```bash
# Download Anton
mkdir -p ~/.local/share/fonts
curl -L "https://github.com/google/fonts/raw/main/ofl/anton/Anton-Regular.ttf" -o ~/.local/share/fonts/Anton-Regular.ttf
fc-cache -f
```
