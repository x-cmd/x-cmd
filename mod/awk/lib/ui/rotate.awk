
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

# function ui_rotate1( screensize, fp,     line,     d, i ){
#     i = IFS
#     IFS = "\n"

#     printf("%s", UI_LINEWRAP_DISABLE) > "/dev/stderr"  # This must be  the default ...
#     printf("\033[?7l") > "/dev/stderr"

#     while (getline line <fp ) {
#         printf("\r%s") > "/dev/stderr"
#     }

#     IFS = i
# }

function ui_rotate_fromstdin( n, prefix, exitclear, prompt_run, prompt_end, output_raw,    i, o, _line, l, arr, _c, _has_content, OUTPUT_ARR, OUTPUT_ARRL ){
    prompt_run = ( prompt_run != "") ? prompt_run : "Running ..."
    prompt_end = ( prompt_end != "") ? prompt_end : "Done"
    ui_rotate_render_begin(n)
    ring_init( o, n )
    while (getline _line) {
        if ( output_raw == 1 ) {
            if (_line ~ /^UI_ROTATE_EXITCODE:/) {
                OUTPUT_ARRL --
                _c = int( substr( _line, 10 ) )
                break
            }
            OUTPUT_ARR[ ++OUTPUT_ARRL ] = _line
        }
        l = split(_line, arr, "\n|\r")
        for (i=1; i<=l; ++i){
            _line = arr[i]
            if (_line ~ /^UI_ROTATE_EXITCODE:/) {
                _c = int( substr( _line, 10 ) )
            }
            else {
                gsub("\033\\[[^A-Za-z]*[A-Za-z=]", "",  _line )
                gsub( "\n", "\\n", _line )
                gsub( "\t", "\\t", _line )
                gsub( "\v", "\\v", _line )
                gsub( "\b", "\\b", _line )
                gsub( "\r", "\\r", _line )
                if ( ! _has_content ) {
                    ui_rotate_render_begin(n)
                    _has_content = 1
                }
                ring_add( o, _line )
                ui_rotate_render( o, prefix )
                ui_rotate_render_prompt( o, prefix, prompt_run )
            }
        }
    }

    if ( _has_content == 1 ) {
        ui_rotate_render_prompt( o, prefix, prompt_end )
        if ( exitclear == 1 )       ui_rotate_render_clear()
        ui_rotate_render_restore()
    }
    for (i=1; i<=OUTPUT_ARRL; ++i) print OUTPUT_ARR[i]
    return _c
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
