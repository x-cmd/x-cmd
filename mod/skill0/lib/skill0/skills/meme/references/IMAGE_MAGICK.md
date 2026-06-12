---
name: meme-imagemagick
description: ImageMagick backend for the meme skill — install (brew/apt/x pixi), usage via Python wrapper / shell script / direct magick command, coordinate conversion from Pillow anchor=mm to ImageMagick -draw left-baseline, and CJK font fallback.
---

# ImageMagick Backend

## Install

```bash
# macOS
brew install imagemagick

# Or via x-cmd
x pixi use imagemagick

# Linux
apt install imagemagick
```

## Usage

### Via Python wrapper

```bash
python3 skill/meme_render.py distracted-boyfriend ZIG ME RUST --backend magick
```

### Via shell script

```bash
bash skill/meme_render.sh distracted-boyfriend "ZIG" "ME" "RUST"
```

### Direct magick command

```bash
magick base.jpg \
  -colorspace sRGB \
  -font Impact -pointsize 48 \
  -fill white -stroke black -strokewidth 4 \
  -draw "text 140,340 'ZIG'" \
  -draw "text 400,280 'ME'" \
  -draw "text 595,370 'RUST'" \
  output.jpg
```

## Coordinates

ImageMagick `-draw "text x,y"` uses **left-baseline** anchor:
- x,y = left edge of text + baseline position
- Convert from center: `im_x = center_x - text_width/2`
- Convert from center: `im_y = center_y + font_size * 0.35`

### Coordinate conversion table

| Pillow (anchor=mm) | ImageMagick (-draw) |
|---------------------|---------------------|
| center coords       | left-baseline coords |
| `(170, 323)`       | `(140, 340)`        |
| `(427, 263)`       | `(400, 280)`        |
| `(645, 353)`       | `(595, 370)`        |

## Formats

```bash
magick input.jpg -quality 90 output.jpg      # JPEG
magick input.jpg -quality 90 output.webp     # WebP (~58% smaller)
magick input.jpg output.png                   # PNG
```

## CJK text

Impact has no CJK glyphs — Chinese/Japanese/Korean text will be invisible with Impact. The shell script auto-detects CJK characters and falls back to system CJK fonts:

- **macOS**: PingFang, STHeiti
- **Linux**: Noto Sans CJK, WenQuanYi Zen Hei

If CJK text appears blank, install fonts:
```bash
# Debian/Ubuntu
sudo apt install fonts-noto-cjk
# Fedora
sudo dnf install google-noto-sans-cjk-fonts
```

The script also resolves template filenames with either hyphens or underscores (e.g. `distracted-boyfriend.yml` finds `distracted_boyfriend.yml`).
