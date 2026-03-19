BEGIN {
    RESET     = "\033[0m"
    BOLD      = "\033[1m"
    DIM       = "\033[2m"

    C_USER_H  = "\033[1;32m"      # User Header (Green)
    C_USER_B  = "\033[38;5;120m"  # User Border
    C_ASST_H  = "\033[1;34m"      # Asst Header (Blue)
    C_ASST_B  = "\033[38;5;69m"   # Asst Border

    C_TEXT    = "\033[38;5;252m"
    C_CODE    = "\033[38;5;51m"
    C_META    = "\033[38;5;243m"

    C_LABEL   = "\033[1;33m"      # Yellow/Orange Bold
    C_GAP     = "\033[38;5;240m"  # Dark Grey

    MARGIN_OFFSET = 5
    if (COLUMNS > 0) MAX_WIDTH = COLUMNS - MARGIN_OFFSET
    else MAX_WIDTH = 90
    if (MAX_WIDTH < 40) MAX_WIDTH = 40

    CHAR_CONT_START = "\200"
    CHAR_LEAD_START = "\300"

    in_content_array = 0
    buffer_role = ""
    buffer_model = ""
    buffer_time = ""
    buffer_text = ""

    msg_count = 0
}

function unescape_json(str) {
    gsub(/\\\\/, "\001", str)
    gsub(/\\n/, "\n", str)
    gsub(/\\t/, "    ", str)
    gsub(/\\"/, "\"", str)
    gsub(/\001/, "\\", str)
    return str
}

function print_smart_wrap(text, prefix, color,    cut_len, next_byte) {
    if (length(text) == 0) { print prefix; return }
    while (length(text) > MAX_WIDTH) {
        cut_len = MAX_WIDTH
        while (cut_len > 0) {
            next_byte = substr(text, cut_len + 1, 1)
            if (next_byte >= CHAR_CONT_START && next_byte < CHAR_LEAD_START) cut_len--
            else break
        }
        if (cut_len == 0) cut_len = MAX_WIDTH
        print prefix color substr(text, 1, cut_len) RESET
        text = substr(text, cut_len + 1)
    }
    if (length(text) > 0) print prefix color text RESET
}

function render_content_lines(full_text, border_prefix, text_color,    n, i, lines, line, in_code) {
    n = split(full_text, lines, "\n")
    in_code = 0
    for (i = 1; i <= n; i++) {
        line = lines[i]
        if (line ~ /^```/) {
            in_code = !in_code
            print border_prefix C_CODE line RESET
            continue
        }
        if (in_code) print border_prefix C_CODE line RESET
        else {
            gsub(/`[^`]+`/, C_CODE "&" text_color, line)
            print_smart_wrap(line, border_prefix, text_color)
        }
    }
}

function flush_message() {
    if (buffer_role == "") return

    msg_count++

    if (msg_count == 1) {
        print ""
        print C_LABEL " == 🚩 FIRST CONVERSATION ==" RESET
    }
    else if (msg_count == 3) {
        print ""
        print C_GAP   "      . . ." RESET
        print C_GAP   "      . . ." RESET
        print ""
        print C_LABEL " == 🏁 LAST CONVERSATION ==" RESET
    }

    if (buffer_role == "user") {
        c_head = C_USER_H; c_bord = C_USER_B; icon = "👤 USER"
    } else {
        c_head = C_ASST_H; c_bord = C_ASST_B; icon = "🤖 ASSISTANT"
    }

    gsub("T", " ", buffer_time); gsub("Z", "", buffer_time); sub(/\..*$/, "", buffer_time)

    model_info = ""
    if (buffer_model != "" && buffer_model != "null") {
        model_info = " " c_head "⚡ " buffer_model RESET
    }

    print ""
    print c_bord "╭── " c_head icon RESET model_info C_META " (" buffer_time ")" RESET

    border_prefix = c_bord "│  " RESET
    render_content_lines(buffer_text, border_prefix, C_TEXT)

    print c_bord "╰──────────────────────────────────────────────────" RESET

    buffer_role = ""; buffer_model = ""; buffer_time = ""; buffer_text = ""
}

{
    raw = $0; sub(/^[ \t]+/, "", raw); sub(/,$/, "", raw)
}
/^[ \t]*"role":/ { val=raw; sub(/^"role": "/, "", val); sub(/"$/, "", val); buffer_role=val; next }
/^[ \t]*"model":/ { if (raw ~ /null/) buffer_model=""; else { val=raw; sub(/^"model": "/, "", val); sub(/"$/, "", val); buffer_model=val }; next }
/^[ \t]*"timestamp":/ { val=raw; sub(/^"timestamp": "/, "", val); sub(/"$/, "", val); buffer_time=val; next }

/^[ \t]*"content": "/ {
    val=raw; sub(/^"content": "/, "", val); sub(/"$/, "", val)
    parsed = unescape_json(val)
    buffer_text = (buffer_text != "") ? buffer_text "\n" parsed : parsed
    next
}
/^[ \t]*"content": \[/ { in_content_array = 1; next }
/^[ \t]*\]/ { if (in_content_array) in_content_array = 0; next }
in_content_array && /^[ \t]*"text": "/ {
    val=raw; sub(/^"text": "/, "", val); sub(/"$/, "", val)
    parsed = unescape_json(val)
    buffer_text = (buffer_text != "") ? buffer_text "\n" parsed : parsed
    next
}

/^[ \t]*\},?$/ { if (buffer_role != "") flush_message() }
