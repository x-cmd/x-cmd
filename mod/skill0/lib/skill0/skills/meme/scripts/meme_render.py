# meme_render.py
# Meme text overlay tool — supports Pillow and ImageMagick backends
# Usage: python3 meme_render.py <template.yml|meme-id> TEXT1 TEXT2 TEXT3 [--layout chest-label] [--backend pillow|magick] [--output out.jpg]

import argparse
import os
import subprocess
import sys
import tempfile
import unicodedata

import yaml
from PIL import Image, ImageDraw, ImageFont


def _has_cjk(text):
    for ch in text:
        cp = ord(ch)
        if (0x4E00 <= cp <= 0x9FFF or 0x3400 <= cp <= 0x4DBF or
                0x2E80 <= cp <= 0x2EFF or 0x3000 <= cp <= 0x303F or
                0xF900 <= cp <= 0xFAFF or 0xFF00 <= cp <= 0xFFEF or
                0x2F800 <= cp <= 0x2FA1F):
            return True
    return False


CJK_FONT_PATHS = [
    # macOS
    "/System/Library/Fonts/PingFang.ttc",
    "/System/Library/Fonts/STHeiti Medium.ttc",
    "/System/Library/Fonts/STHeiti Light.ttc",
    "/System/Library/Fonts/Supplemental/Arial Unicode.ttf",
    "/Library/Fonts/Arial Unicode.ttf",
    # Linux — Noto Sans CJK
    "/usr/share/fonts/opentype/noto/NotoSansCJK-Regular.ttc",
    "/usr/share/fonts/noto-cjk/NotoSansCJK-Regular.ttc",
    "/usr/share/fonts/truetype/noto/NotoSansCJK-Regular.ttc",
    # Linux — WenQuanYi
    "/usr/share/fonts/truetype/wqy/wqy-zenhei.ttc",
    "/usr/share/fonts/wqy-zenhei/wqy-zenhei.ttc",
]


def _resolve_font(font_cfg, prefer_cjk=False):
    font_size = font_cfg["size"]
    font_path = font_cfg.get("path")
    if prefer_cjk:
        for p in CJK_FONT_PATHS:
            if os.path.exists(p):
                font_path = p
                break
    try:
        if font_path:
            return ImageFont.truetype(font_path, font_size)
    except Exception:
        pass
    return ImageFont.load_default(font_size)

RAW_MIRRORS = [
    "https://raw.githubusercontent.com/edwinjhlee/awesome-meme/main",
    "https://codeberg.org/edwinjhlee/awesome-meme/raw/branch/main",
]


def _resolve_template(template_arg):
    """Accept a local path or meme ID (e.g. 'distracted-boyfriend')."""
    if os.path.isfile(template_arg):
        with open(template_arg) as f:
            return yaml.safe_load(f)
    variants = list({
        template_arg,
        template_arg.replace("_", "-"),
        template_arg.replace("-", "_"),
    })
    for base in RAW_MIRRORS:
        for name in variants:
            url = f"{base}/data/spec/{name}.yml"
            print(f"Trying: {url}")
            r = subprocess.run(["curl", "-sL", "--max-time", "8", url],
                               capture_output=True, text=True, timeout=15)
            if r.returncode == 0 and r.stdout.strip() and not r.stdout.startswith("404") and not r.stdout.startswith("Not found"):
                data = yaml.safe_load(r.stdout)
                if isinstance(data, dict):
                    return data
    print(f"Error: template '{template_arg}' not found on any mirror", file=sys.stderr)
    sys.exit(1)


def download_image(urls, dest):
    for entry in urls:
        url = entry.get("url") or entry.get("path")
        if not url:
            continue
        if entry.get("path") and os.path.exists(url):
            return url
        try:
            r = subprocess.run(["curl", "-sL", "-o", dest, url], timeout=15)
            if r.returncode == 0 and os.path.exists(dest):
                return dest
        except Exception:
            continue
    return None


def render_pillow(template, image_path, texts, layout_id, output):
    img = Image.open(image_path)
    if tuple(img.size) != tuple(template["image_size"]):
        img = img.resize(tuple(template["image_size"]))
    if img.mode == "RGBA":
        img = img.convert("RGB")
    draw = ImageDraw.Draw(img)

    font_cfg = template["font"]
    layout = _get_layout(template, layout_id)
    slots = layout["slots"]

    for i, slot in enumerate(slots):
        if i >= len(texts):
            break
        text = texts[i]
        cjk = _has_cjk(text)
        font = _resolve_font(font_cfg, prefer_cjk=cjk)
        pos = tuple(slot["pos"])
        draw.text(
            pos, text, font=font,
            fill=font_cfg.get("color", "white"),
            stroke_width=font_cfg.get("stroke_width", 4),
            stroke_fill=font_cfg.get("stroke_color", "black"),
            anchor=font_cfg.get("anchor", "mm"),
        )

    img.save(output, quality=95)
    return output


def render_magick(template, image_path, texts, layout_id, output):
    font_cfg = template["font"]
    font_size = font_cfg["size"]
    stroke_w = font_cfg.get("stroke_width", 4)
    ascent_offset = int(font_size * 0.35)

    layout = _get_layout(template, layout_id)
    slots = layout["slots"]

    cmd = ["magick", image_path, "-colorspace", "sRGB"]

    for i, slot in enumerate(slots):
        if i >= len(texts):
            break
        text = texts[i]
        cx, cy = slot["pos"]
        cjk = _has_cjk(text)
        font_family = font_cfg.get("family", "Impact")
        if cjk:
            for p in CJK_FONT_PATHS:
                if os.path.exists(p):
                    font_family = p
                    break
        im_x = cx - len(text) * font_size // 4
        im_y = cy + ascent_offset

        cmd.extend([
            "-font", font_family,
            "-pointsize", str(font_size),
            "-fill", font_cfg.get("color", "white"),
            "-stroke", font_cfg.get("stroke_color", "black"),
            "-strokewidth", str(stroke_w),
            "-draw", f"text {im_x},{im_y} '{text}'",
        ])

    cmd.append(output)
    subprocess.run(cmd, check=True)
    return output


def _get_layout(template, layout_id):
    layouts = template["layouts"]
    if layout_id:
        for l in layouts:
            if l["id"] == layout_id:
                return l
    # default
    for l in layouts:
        if l.get("default"):
            return l
    return layouts[0]


def main():
    parser = argparse.ArgumentParser(description="Meme text overlay renderer")
    parser.add_argument("template", help="Meme ID (e.g. distracted-boyfriend) or path to template YAML")
    parser.add_argument("texts", nargs="+", help="Text for each slot")
    parser.add_argument("--layout", default=None, help="Layout preset (e.g. chest-label)")
    parser.add_argument("--backend", choices=["pillow", "magick"], default="pillow")
    parser.add_argument("--output", default="meme_output.jpg", help="Output file path")
    args = parser.parse_args()

    tmpl = _resolve_template(args.template)

    # Download image
    dest = tempfile.mktemp(suffix=".jpg", prefix="_meme_base_")
    img_path = download_image(tmpl["urls"], dest)
    if not img_path:
        print("Error: could not download image", file=sys.stderr)
        sys.exit(1)

    if args.backend == "pillow":
        render_pillow(tmpl, img_path, args.texts, args.layout, args.output)
    else:
        render_magick(tmpl, img_path, args.texts, args.layout, args.output)

    print(f"Saved: {args.output}")


if __name__ == "__main__":
    main()
