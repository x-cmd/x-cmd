---
name: meme-pillow
description: Pillow (PIL) backend for the meme skill — usage via Python wrapper, programmatic API examples, center coordinates with anchor=mm, and CJK font fallback notes (Impact lacks CJK glyphs).
---

# Pillow Backend

## Usage

```bash
python3 skill/meme_render.py distracted-boyfriend ZIG ME RUST
```

## Programmatic Usage

```python
from PIL import Image, ImageDraw, ImageFont

img = Image.open("base_image.jpg")
draw = ImageDraw.Draw(img)
font = ImageFont.truetype("Impact.ttf", 48)

draw.text(
    (170, 323), "ZIG",
    font=font, fill="white",
    stroke_width=4, stroke_fill="black",
    anchor="mm"
)

img.save("output.jpg", quality=95)
img.save("output.webp", "WEBP", quality=90)
```

## Coordinates

Pillow uses **center coordinates** with `anchor="mm"` (middle-middle):
- `pos: [170, 323]` = text center at pixel (170, 323)
- Origin: top-left = (0, 0), Y increases downward

## Font Notes

### CJK / Chinese text (IMPORTANT)

**Impact does NOT contain CJK glyphs.** If you render Chinese/Japanese/Korean text with Impact, the text will be invisible — no error, just blank.

The renderer auto-detects CJK text and falls back to:
- macOS: PingFang (苹方), STHeiti, Arial Unicode
- Linux: Noto Sans CJK

For meme specs that will carry Chinese text, consider:
- Setting `font.path` to a CJK font, or
- Let the auto-detection handle it (default behavior)

### English / Latin text

- Impact: classic meme font, macOS pre-installed at `/System/Library/Fonts/Supplemental/Impact.ttf`
- Free alternatives: Google Fonts Anton, Bangers
- The renderer uses Impact by default for non-CJK text
