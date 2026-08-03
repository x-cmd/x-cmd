# Not executable — invoke with bash: bash meme_render.sh <args>
# meme_render.sh — ImageMagick-based meme renderer
# Usage: bash meme_render.sh <template.yml|meme-id> "TEXT1" "TEXT2" "TEXT3" [--output out.jpg]
# Examples:
#   bash meme_render.sh distracted-boyfriend "ZIG" "ME" "RUST"
#   bash meme_render.sh path/to/spec.yml "TEXT1" "TEXT2" --output out.jpg

set -euo pipefail

TEMPLATE="${1:?Usage: bash meme_render.sh <template.yml|meme-id> TEXT1 TEXT2 TEXT3 [--output path]}"
shift

TEXTS=()
OUTPUT="meme_output.jpg"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --output) OUTPUT="$2"; shift 2 ;;
        *) TEXTS+=("$1"); shift ;;
    esac
done

GITHUB_BASE="https://raw.githubusercontent.com/edwinjhlee/awesome-meme/main/data/spec"

# If not a local file, try fetching from GitHub by meme ID (with hyphen/underscore variants)
if [[ ! -f "$TEMPLATE" ]]; then
    ID="${TEMPLATE%.yml}"
    VARIANTS=("$ID")
    ALT="${ID//-/_}"; [[ "$ALT" != "$ID" ]] && VARIANTS+=("$ALT")
    ALT="${ID//_/-}"; [[ "$ALT" != "$ID" ]] && VARIANTS+=("$ALT")
    FETCHED=""
    for VID in "${VARIANTS[@]}"; do
        LOCAL_CACHE="/tmp/_meme_spec_${VID}.yml"
        if [[ -f "$LOCAL_CACHE" ]]; then
            FETCHED="$LOCAL_CACHE"
            break
        fi
        URL="${GITHUB_BASE}/${VID}.yml"
        if curl -sLf -o "$LOCAL_CACHE" "$URL" 2>/dev/null; then
            FETCHED="$LOCAL_CACHE"
            break
        fi
    done
    if [[ -n "$FETCHED" ]]; then
        TEMPLATE="$FETCHED"
    else
        echo "Error: Cannot find template '${ID}' locally or on GitHub" >&2
        exit 1
    fi
fi

# Resolve template: try both hyphens and underscores
resolve_template() {
    local tmpl="$1"
    [[ -f "$tmpl" ]] && echo "$tmpl" && return
    local alt
    if [[ "$tmpl" == *-* ]]; then
        alt="${tmpl//-/_}"
    else
        alt="${tmpl//_/-}"
    fi
    [[ -f "$alt" ]] && echo "$alt" && return
    echo "$tmpl"
}
TEMPLATE=$(resolve_template "$TEMPLATE")

# Parse nested YAML (font: section has indented keys)
# Usage: get_font_val KEY FILE — reads  family:, size:, etc. under the font: block
get_font_val() {
    local key="$1" file="$2"
    # Find the font: block, then read indented key within it
    sed -n '/^font:/,/^[^ ]/p' "$file" | grep "^[[:space:]]*${key}:" | head -1 | sed "s/.*${key}: *//" | tr -d '"' | tr -d "'" | xargs
}

FONT_FAMILY=$(get_font_val "family" "$TEMPLATE" || echo "Impact")
FONT_SIZE=$(get_font_val "size" "$TEMPLATE" || echo "48")
STROKE_W=$(get_font_val "stroke_width" "$TEMPLATE" || echo "4")
FILL=$(get_font_val "color" "$TEMPLATE" || echo "white")
STROKE=$(get_font_val "stroke_color" "$TEMPLATE" || echo "black")

# CJK font detection
has_cjk() {
    local i cp
    for (( i=0; i<${#1}; i++ )); do
        cp=$(printf '%d' "'${1:$i:1}" 2>/dev/null) || continue
        (( cp >= 0x2E80 )) && return 0
    done
    return 1
}

CJK_FONT_PATHS=(
    "/System/Library/Fonts/PingFang.ttc"
    "/System/Library/Fonts/STHeiti Medium.ttc"
    "/System/Library/Fonts/STHeiti Light.ttc"
    "/System/Library/Fonts/Supplemental/Arial Unicode.ttf"
    "/Library/Fonts/Arial Unicode.ttf"
    "/usr/share/fonts/opentype/noto/NotoSansCJK-Regular.ttc"
    "/usr/share/fonts/noto-cjk/NotoSansCJK-Regular.ttc"
    "/usr/share/fonts/truetype/noto/NotoSansCJK-Regular.ttc"
    "/usr/share/fonts/truetype/wqy/wqy-zenhei.ttc"
    "/usr/share/fonts/wqy-zenhei/wqy-zenhei.ttc"
)

find_cjk_font() {
    local p
    for p in "${CJK_FONT_PATHS[@]}"; do
        [[ -f "$p" ]] && echo "$p" && return
    done
}

# Find the first URL
URL=$(grep "url:" "$TEMPLATE" | head -1 | sed 's/.*url: *//' | tr -d '"' | tr -d "'")
BASE_IMG="/tmp/_meme_base_$$.jpg"
curl -sL -o "$BASE_IMG" "$URL" 2>/dev/null || { echo "Failed to download image"; exit 1; }

# Build magick command
CMD=("magick" "$BASE_IMG" "-colorspace" "sRGB")

# Get slot positions from template — read from the first layout's slots section
# YAML structure: layouts: → - id: ... slots: → - pos: [x, y]
SLOT_POS=()
while IFS= read -r POS; do
    [[ -n "$POS" ]] && SLOT_POS+=("$POS")
done < <(awk '/^  - id:/ { layout++; next } layout==1 && /pos:/ { gsub(/.*pos: *\[/, ""); gsub(/\].*/, ""); print }' "$TEMPLATE")

for i in "${!TEXTS[@]}"; do
    [[ -z "${SLOT_POS[$i]:-}" ]] && break
    IFS=',' read -r CX CY <<< "${SLOT_POS[$i]}"
    # Convert center coords to left-baseline for ImageMagick
    IM_X=$((CX - ${#TEXTS[$i]} * FONT_SIZE / 4))
    IM_Y=$((CY + FONT_SIZE * 35 / 100))

    SLOT_FONT="$FONT_FAMILY"
    if has_cjk "${TEXTS[$i]}"; then
        CJK_FONT=$(find_cjk_font)
        [[ -n "$CJK_FONT" ]] && SLOT_FONT="$CJK_FONT"
    fi

    CMD+=(
        "-font" "$SLOT_FONT"
        "-pointsize" "$FONT_SIZE"
        "-fill" "$FILL"
        "-stroke" "$STROKE"
        "-strokewidth" "$STROKE_W"
        "-draw" "text ${IM_X},${IM_Y} '${TEXTS[$i]}'"
    )
done

CMD+=("$OUTPUT")
"${CMD[@]}"
rm -f "$BASE_IMG"
echo "Saved: $OUTPUT"
