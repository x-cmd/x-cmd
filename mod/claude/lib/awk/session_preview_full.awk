
BEGIN {
    RESET   = "\033[0m"
    BOLD    = "\033[1m"
    DIM     = "\033[2m"

    C_USER_H  = "\033[1;32m"
    C_USER_B  = "\033[38;5;120m"
    C_ASST_H  = "\033[1;34m"
    C_ASST_B  = "\033[38;5;69m"
    C_TEXT    = "\033[38;5;252m"
    C_THINK   = "\033[38;5;243m"
    C_CODE    = "\033[38;5;51m"
    C_LINENUM = "\033[38;5;238m"
    C_ARROW   = "\033[38;5;196m"
    C_TOOL    = "\033[38;5;214m"
    C_FILE    = "\033[4;37m"

    C_PROMPT  = "\033[1;35m"
    C_CMD_IN  = "\033[1;37m"
    C_CMD_OUT = "\033[38;5;248m"

    DEFAULT_WIDTH = 90
    MARGIN_OFFSET = 5
    if (COLUMNS > 0) MAX_WIDTH = COLUMNS - MARGIN_OFFSET
    else MAX_WIDTH = DEFAULT_WIDTH
    if (MAX_WIDTH < 40) MAX_WIDTH = 40

    CHAR_CONT_START = "\200"
    CHAR_LEAD_START = "\300"

    block_type = "NONE"
    pending_cmd_merge = 0
}

function clean_val(str) {
    sub(/^[ \t]*"(content|thinking|text)": "/, "", str)
    sub(/",?$/, "", str)
    gsub(/\\u001b/, "\033", str)
    gsub(/\\r/, "", str)
    return str
}

function extract_tag(text, tag,     pattern, match_str, content) {
    pattern = "<" tag ">.*</" tag ">"

    match(text, "<" tag ">")
    if (RSTART == 0) return ""

    content = substr(text, RSTART)
    match(content, "</" tag ">")
    if (RSTART == 0) return ""

    content = substr(content, length(tag) + 3, RSTART - (length(tag) + 3))

    return content
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

function render_content(raw_str, indent, base_color, mode,     val, lines, n, i, line) {
    val = (mode == "PRE_CLEANED") ? raw_str : clean_val(raw_str)
    n = split(val, lines, "\\\\n")
    in_code_block = 0

    for (i = 1; i <= n; i++) {
        line = lines[i]
        gsub(/\\\\/, "\\", line); gsub(/\\"/, "\"", line); gsub(/\\t/, "    ", line)

        if (line ~ /^```/) { in_code_block = !in_code_block; print indent base_color line RESET; continue }

        if (line ~ /^[ \t]*[0-9]+→/) {
            match(line, /^[ \t]*[0-9]+→/)
            num_part = substr(line, RSTART, RLENGTH)
            content_part = substr(line, RSTART+RLENGTH)
            sub(/→/, C_ARROW "→" C_LINENUM, num_part)
            print indent C_LINENUM num_part RESET C_CODE content_part RESET
            continue
        }

        if (in_code_block) {
            print indent C_CODE line RESET
        } else if (mode == "RAW" || mode == "PRE_CLEANED") {
            print indent base_color line RESET
        } else {
            if (mode != "THINK") gsub(/`[^`]+`/, C_CODE "&" base_color, line)
            print_smart_wrap(line, indent, base_color)
        }
    }
}

/"timestamp":/ {
    if (pending_cmd_merge == 1) {
        curr_time = $2; gsub(/"|,|T|\..*Z/, "", curr_time); sub(/T/, " ", curr_time)
    } else {
        if (block_type != "NONE") print (block_type ~ /USER|TOOL/ ? C_USER_B : C_ASST_B) "╰──────────────────────────────────────────────────" RESET
        block_type = "NONE"; curr_role = ""; curr_time = $2; gsub(/"|,|T|\..*Z/, "", curr_time); sub(/T/, " ", curr_time)
    }
}
/"role":/ { r=$2; gsub(/"|,/, "", r); curr_role = r }
/"model":/ { m=$2; gsub(/"|,/, "", m); curr_model = m }
/"type":/ { if ($0 ~ /"tool_result"/) prev_line_type = "tool_result"; else if ($0 ~ /"thinking"/) prev_line_type = "thinking"; else prev_line_type = "other" }

function ensure_header(type) {
    if (block_type == type) return
    if (block_type != "NONE") print (block_type ~ /USER|TOOL/ ? C_USER_B : C_ASST_B) "╰──────────────────────────────────────────────────" RESET

    print ""
    if (curr_role == "user") {
        print C_USER_B "╭── " C_USER_H "👤 USER" RESET DIM " (" curr_time ")" RESET
        block_type = "USER"
    } else {
        mod = (curr_model!="null" && curr_model!="") ? " " C_ASST_H "⚡ " curr_model RESET : ""
        print C_ASST_B "╭── " C_ASST_H "🤖 ASSISTANT" RESET mod DIM " (" curr_time ")" RESET
        block_type = "ASSISTANT"
    }
}

/"content": "/ || /"text": "/ {
    if ($0 ~ /tool_use_id/ || prev_line_type == "tool_result") next
    val = clean_val($0)

    if (val ~ /<local-command-caveat>/) next

    if (val ~ /<(bash-input|command-name)>/) {
        ensure_header("USER")

        final_cmd = ""

        if (val ~ /<bash-input>/) {
            final_cmd = extract_tag(val, "bash-input")
        }
        else if (val ~ /<command-name>/) {
            c_name = extract_tag(val, "command-name")
            c_args = extract_tag(val, "command-args")

            final_cmd = c_name
            if (length(c_args) > 0) final_cmd = final_cmd " " c_args
        }

        gsub(/\\n/, " ", final_cmd)
        gsub(/\n/, " ", final_cmd)
        gsub(/  +/, " ", final_cmd)
        sub(/^ /, "", final_cmd); sub(/ $/, "", final_cmd)

        print C_USER_B "│  " C_PROMPT "➜ " C_CMD_IN final_cmd RESET

        pending_cmd_merge = 1
        next
    }

    if (val ~ /<(bash-stdout|local-command-stdout|bash-stderr)>/) {
        if (block_type != "USER") ensure_header("USER")
        gsub(/<[^>]+>/, "", val)
        render_content(val, C_USER_B "│  " RESET, C_CMD_OUT, "PRE_CLEANED")
        pending_cmd_merge = 0
        next
    }

    pending_cmd_merge = 0
    ensure_header(curr_role == "user" ? "USER" : "ASSISTANT")
    border = (block_type == "USER") ? C_USER_B : C_ASST_B
    print border "│" RESET
    render_content($0, border "│  " RESET, C_TEXT, "TEXT")
}

/"thinking":/ {
    pending_cmd_merge = 0
    ensure_header("ASSISTANT")
    print C_ASST_B "│" RESET "  " C_THINK "💭 Thinking Process..." RESET
    render_content($0, C_ASST_B "│  " RESET, C_THINK, "THINK")
}

/"content":/ && prev_line_type == "tool_result" {
    pending_cmd_merge = 0
    ensure_header("USER"); print C_USER_B "├─ " C_TOOL "📊 Tool Output:" RESET; block_type = "TOOL_RES"
    render_content($0, C_USER_B "│  " RESET, C_TEXT, "RAW")
    prev_line_type = ""; next
}

/"type": "tool_use"/ { pending_cmd_merge = 0; ensure_header("ASSISTANT") }
/"name":/ && !/"role":/ { t=$2; gsub(/"|,/, "", t); if($0~/"name":/) print C_ASST_B "├─ " C_TOOL "🔨 Tool Call: " BOLD t RESET }
/"file_path":/ || /"command":/ || /"activeForm":/ {
    k=$1; v=$0; sub(/^[ \t]*"/,"",k); sub(/":.*$/,"",k); sub(/^[ \t]*"[^"]+": "/,"",v); sub(/",?$/, "", v); gsub(/\\\\/,"\\",v); gsub(/\\"/,"\"",v)
    print C_ASST_B "│  " RESET DIM k ": " RESET C_FILE v RESET
}

{ if ($0 !~ /"type":/) prev_line_type = "" }

END {
    if (block_type != "NONE") print (block_type ~ /USER|TOOL/ ? C_USER_B : C_ASST_B) "╰──────────────────────────────────────────────────" RESET
}
