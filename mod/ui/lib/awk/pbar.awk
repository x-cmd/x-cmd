
function print_progressbar(percent, size,         i, _v, _s, _info){

    _s = get_progressbar_body(percent) _info

    size --
    for (i=1; i<=size && getline _v; ++i) _info = _info "  " th(TH_BAR_INFO[i%4], _v)
    _s = _s ((_info != "") ? "\n" th(UI_FG_DARKGRAY, _info) : "" )

    printf( "%s\n", UI_CURSOR_RESTORE UI_CURSOR_HIDE UI_SCREEN_CLEAR_BOTTOM UI_LINE_CLEAR \
                    _s UI_CURSOR_NORMAL ) > "/dev/stderr"
}

function get_progressbar_body(percent,          _width, _stars, i, _s){
    _width = int ( COLUMNS / 3 )
    _width = (_width < 10) ? 10 : _width
    percent = (percent > 100) ? 100 : percent

    _stars = int(_width * percent / 100)
    for (i=1; i<=_stars; ++i)   _s = _s th(TH_THEME_COLOR UI_TEXT_REV, " ")
    for (; i<=_width; ++i)      _s = _s th(UI_FG_DARKGRAY UI_TEXT_REV, " ")

    if (percent == 100) _s = _s " DONE!"
    else                _s = _s sprintf(" %3d%%", percent)
    return _s
}

BEGIN{
    # TH_THEME_COLOR = ENVIRON[ "___X_CMD_THEME_COLOR_CODE" ]
    # TH_THEME_COLOR = (TH_THEME_COLOR) ? "\033[" TH_THEME_COLOR "m" : UI_FG_CYAN
    TH_THEME_COLOR = UI_FG_CYAN
    TH_BAR_INFO[ 1 ] = UI_END
    TH_BAR_INFO[ 2 ] = UI_FG_GREEN
    TH_BAR_INFO[ 3 ] = UI_FG_YELLOW
    TH_BAR_INFO[ 0 ] = UI_FG_BLUE

    COLUMNS = ENVIRON[ "COLUMNS" ]
    if (COLUMNS < 20) log_error("ui", "The current screen COLUMNS[" COLUMNS "] is insufficient to display the content")
    BATCH_SIZE = int( ENVIRON[ "BATCH_SIZE" ] )
    if (BATCH_SIZE < 1)         BATCH_SIZE = 1
    else if (BATCH_SIZE > 10)   BATCH_SIZE = 10
    printf( "%s", "\n\n\n\r\033[3A" UI_CURSOR_SAVE ) > "/dev/stderr"
    while( getline ) {
        print_progressbar(int($0), BATCH_SIZE)
        fflush()
    }

    printf("%s", UI_CURSOR_NORMAL UI_CURSOR_SHOW ) > "/dev/stderr"
}


