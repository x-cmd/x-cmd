BEGIN{
    line_count = 0
    printf("%s", UI_CURSOR_SAVE UI_CURSOR_HIDE) > "/dev/stderr"
}

function ui_cursor_goup_n_line(n){
    return "\033[" n "A"
}

function ui_cursor_godown_n_line(n){
    return "\033[" n "B"
}

function cal_empty_line(line_count, width,          i, ret, s){
    s = str_rep(" ", width)
    for (i=1; i<=line_count; i++)
        ret = ret s "\n"
    return ret
}

BEGIN{
    LAST_OUTPUT_LINE_COUNT = 0
    OUTPUT_LINE_COUNT = 0
}
function output(text,
    line, line_arr, line_arr_len, return_text, i, blank_line){

    return_text = "" UI_LINEWRAP_DISABLE


    line_arr_len = split(text, line_arr, "\n")
    OUTPUT_LINE_COUNT = 0
    blank_line = "\r" str_rep(" ", KNOWN_WIDTH) "\r"
    for (i=1; i<=line_arr_len; i++) {
        line = line_arr[i]
        return_text = return_text blank_line line "\n"
    }
    OUTPUT_LINE_COUNT=line_arr_len

    if (OUTPUT_LINE_COUNT < LAST_OUTPUT_LINE_COUNT) {
        return_text = return_text cal_empty_line(LAST_OUTPUT_LINE_COUNT - OUTPUT_LINE_COUNT, KNOWN_WIDTH)
    }

    return_text = return_text UI_LINEWRAP_ENABLE

    return return_text
}

BEGIN {
    output_test = ""
    last_output_test = ""
}

function update(text){

    LAST_OUTPUT_LINE_COUNT = OUTPUT_LINE_COUNT

    last_output_test = output_text

    output_text = output(text, width)

    printf("%s", UI_CURSOR_RESTORE) > "/dev/stderr"
    if (LAST_OUTPUT_LINE_COUNT < OUTPUT_LINE_COUNT) {
        # printf( "%s",
        #     last_output_test cal_empty_line(OUTPUT_LINE_COUNT - LAST_OUTPUT_LINE_COUNT, width) )
        printf("%s", str_rep("\n", OUTPUT_LINE_COUNT) \
            "\033[" (OUTPUT_LINE_COUNT ) "A" \
            UI_CURSOR_SAVE) > "/dev/stderr"
    }

    printf("%s", output_text) > "/dev/stderr"
}

BEGIN{
   ALREAD_END = 0
}

function end(){
    if (ALREAD_END == 1) return
    ALREAD_END = 1
    printf("%s", UI_CURSOR_RESTORE \
        UI_SCREEN_CLEAR_BOTTOM UI_LINE_CLEAR \
        UI_CURSOR_NORMAL UI_CURSOR_SHOW) > "/dev/stderr"
    # printf( "%s", cal_empty_line(OUTPUT_LINE_COUNT, KNOWN_WIDTH)) > "/dev/stderr"
    # printf(UI_CURSOR_RESTORE) > "/dev/stderr"
}

function env_code(VAR, text){
    gsub(/\\/, "\\\\", text)
    gsub(/"/, "\\\"", text)
    gsub("\n", "\\n", text)
    printf("%s", VAR "=\"$(printf \"" text "\")\"; ")
}

BEGIN {
    KNOWN_WIDTH = -1
    KNOWN_HEIGHT = -1
}

function update_width_height(w, h) {
    if ( (w != "") && (w > 0) ) {
        KNOWN_WIDTH = w
    }
    if ( (h != "") && (h > 0) ) {
        KNOWN_HEIGHT = h
    }
}

{
    if (op == "UPDATE") {
        if ($0 != "\003\002\005") {
            op_stream = (op_stream == "") ? $0 : op_stream "\n" $0
        } else {
            if (last_update != op_stream) {
                last_update = op_stream
                update( op_stream )
            }
            op = ""
            op_stream = ""
        }
    } else if (op == "ENV") {       # Using Quote
        if ($0 != "\003\002\005") {
            op_stream = (op_stream == "") ? $0 : op_stream "\n" $0
        } else {
            env_code( op_arg1, op_stream )
            op = ""
            op_stream = ""
        }
    } else {
        if ($1 == "SIZE") {
            update_width_height($2, $3)
        } else if ($1 == "UPDATE") {
            op = $1
            update_width_height($2, $3)
        } else {
            op = $1
            op_arg1 = $2
        }
    }
}

END {
    end()
}
