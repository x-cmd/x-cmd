
BEGIN{
    if (IS_TH_NO_COLOR != 1) {
        TH_THEME_COLOR  = ENVIRON[ "___X_CMD_THEME_COLOR_CODE" ]
        TH_THEME_COLOR  = (TH_THEME_COLOR) ? "\033[" TH_THEME_COLOR "m" : UI_FG_CYAN
        TH_BORDER_COLOR = ENVIRON[ "___X_CMD_UI_ROTATE_BORDER_COLOR" ]

        if ( TH_BORDER_COLOR != "" ) gsub( "\\\\033", "\033", TH_BORDER_COLOR )
        else TH_BORDER_COLOR = TH_THEME_COLOR

        TH_TEXT_COLOR   = ENVIRON[ "___X_CMD_UI_ROTATE_TEXT_COLOR" ]
        if ( TH_TEXT_COLOR != "" )  gsub( "\\\\033", "\033", TH_TEXT_COLOR )
        else TH_TEXT_COLOR = UI_TEXT_DIM # UI_FG_DARKGRAY
    }
}

END{
    ui_rotate_render_restore()
}

function ui_rotate___handle_running( ring_arr, output_arr, status_obj, line, prefix, prompt_run, output_raw,           i, l, arr, _c){
    if ( output_raw == 1 ) {
        if (match(line, /^UI_ROTATE_EXITCODE:/)) {
            output_arr[ L ] --
            _c = int( substr( line, RLENGTH+1 ) )
            status_obj[ "IS_BREAK" ] = 1
            status_obj[ "EXITCODE" ] = _c
            return
        }
        output_arr[ ++ output_arr[ L ]  ] = line
    }
    l = split(line, arr, "\n|\r")
    for (i=1; i<=l; ++i){
        line = arr[i]
        if (match(line, /^UI_ROTATE_EXITCODE:/)) {
            _c = int( substr( line, RLENGTH+1 ) )
            status_obj[ "EXITCODE" ] = _c
        }
        else {
            gsub("\033\\[[^A-Za-z]*[A-Za-z=]", "",  line )
            gsub( "\n", "\\n", line )
            gsub( "\t", "\\t", line )
            gsub( "\v", "\\v", line )
            gsub( "\b", "\\b", line )
            gsub( "\r", "\\r", line )
            if ( ! status_obj[ "HAS_CONTENT" ] ) {
                ui_rotate_render_begin(n)
                status_obj[ "HAS_CONTENT" ] = 1
            }
            ring_add( ring_arr, line )
            ui_rotate_render( ring_arr, prefix )
            ui_rotate_render_prompt( ring_arr, prefix, prompt_run )
        }
    }
    fflush()
}

# function ui_rotate_fromarr(){
#     # tail_idx = arr[ L ]
#     # if ( arr[ tail_idx, "IS_RENDERED" ] ) return
#     # arr[ tail_idx, "IS_RENDERED" ] = 1
# }

function ui_rotate_fromstdin( n, prefix, exitclear, prompt_run, prompt_end, output_raw,         i, l, _line, _c, output_arr, status_obj, ring_arr ){
    prompt_run = ( prompt_run != "") ? prompt_run : "Running ..."
    prompt_end = ( prompt_end != "") ? prompt_end : "Done"
    ui_rotate_render_begin(n)
    ring_init( ring_arr, n )
    while (getline _line) {
        ui_rotate___handle_running( ring_arr, output_arr, status_obj, _line, prefix, prompt_run, output_raw )
        _c = status_obj[ "EXITCODE" ]
        if ( status_obj[ "IS_BREAK" ] ) break
    }

    if ( status_obj[ "HAS_CONTENT" ] ) {
        ui_rotate_render_prompt( ring_arr, prefix, prompt_end )
        if ( exitclear == 1 )       ui_rotate_render_clear()
        ui_rotate_render_restore()
    }
    l = output_arr[ L ]
    for (i=1; i<=l; ++i) print output_arr[i]
    return int(_c)
}

function ui_rotate_render( o, prefix,      i, n, str, counter ){
    ui_rotate_render_clear()

    n = ring_size( o )
    counter = ring_counter( o )
    for (i=1; i<=n; ++i) {
        str = sprintf("%4d  ", (counter - n + i)) ring_get( o, i )
        printf("%s%s%s\n", prefix, th(TH_BORDER_COLOR, "│ "), UI_LINEWRAP_DISABLE th(TH_TEXT_COLOR, str) UI_LINEWRAP_ENABLE) > "/dev/stderr"
    }
}

function ui_rotate_render_begin(n,      i){
    for (i=0; i<=n; ++i)    printf("%s", "\r\n") > "/dev/stderr"
    printf("%s", "\033["int(n+1)"A" UI_CURSOR_SAVE) > "/dev/stderr"
}

function ui_rotate_render_clear(){
    printf( "%s", UI_CURSOR_RESTORE \
        UI_SCREEN_CLEAR_BOTTOM UI_LINE_CLEAR \
        "\r" UI_CURSOR_RESTORE UI_CURSOR_SAVE ) > "/dev/stderr"
}

function ui_rotate_render_restore(){
    printf ("%s", UI_CURSOR_NORMAL UI_CURSOR_SHOW ) > "/dev/stderr"
}

function ui_rotate_render_prompt( o, prefix, prompt,    n ){
    n = ring_size( o )
    printf("%s", UI_CURSOR_RESTORE "\033[" n "B" \
        UI_SCREEN_CLEAR_BOTTOM UI_LINE_CLEAR) > "/dev/stderr"

    printf("%s%s%s\n", PREFIX, th(TH_BORDER_COLOR, "└ "), prompt) > "/dev/stderr"
}
