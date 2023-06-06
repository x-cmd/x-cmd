# Section: visualize
function strlen_without_color(text){
    gsub(TH_TLDR_CMD_KEY_SEP_LEFT, "", text)
    gsub(TH_TLDR_CMD_KEY_SEP_RIGHT, "", text)
    return wcswidth( str_remove_esc(text) )
}

function cut_info_line(info, color, indent,
    _, i, l, _res, _next_line){

    utf8tt_init( color info, _, "")
    utf8tt_refresh(_, "", "", COMP_TLDR_COL - indent)

    _next_line = COMP_TLDR_NEWLINE color space_rep(indent)
    l = _[SUBSEP "VIEW" L]
    _res = _[ SUBSEP "VIEW", 1 ]
    for (i=2; i<=l; ++i) _res = _res _next_line _[ SUBSEP "VIEW", i ]
    return _res
}

function handle_title(title, _res){
    _res = COMP_TLDR_SPACE_LINE
    _res = _res COMP_TLDR_TILTE title ": "
    return _res
}

function handle_desc(desc, title_len){
    return cut_info_line( desc, COMP_TLDR_DESC, title_len ) COMP_TLDR_NEWLINE
}


function handle_cmd(cmd,     _res, _max_len, _i, l, _key_len, _cmd_text){
    _res = COMP_TLDR_SPACE_LINE
    l = cmd[ L ]
    for (_i=1; _i<l; _i++) {
        _cmd_text = cmd[ _i, "text" ]
        while (match(_cmd_text, "\\{\\{[^\\{]+\\}}"))
            cmd[ _i, "text" ] = _cmd_text = substr(_cmd_text,1,RSTART-1) \
                TH_TLDR_CMD_KEY_SEP_LEFT substr(_cmd_text,RSTART+2, RLENGTH-4) TH_TLDR_CMD_KEY_SEP_RIGHT \
                substr(_cmd_text, RSTART + RLENGTH)

        _key_len = strlen_without_color(_cmd_text)
        if (_key_len > _max_len) _max_len = _key_len
    }

    if (_max_len > COMP_TLDR_COL*0.6)  _res = _res handle_long_cmd(cmd)
    else _res = _res handle_short_cmd(cmd, _max_len)
    return _res
}

function handle_short_cmd(cmd, max_len,
    _res, _cmd_info, _cmd_text, _cmd_key_style, _cmd_info_style, i, l, _text){
    l = cmd[ L ]
    th_interval_init(COMP_TLDR_CMD_KEY_SEP)
    th_interval_init(COMP_TLDR_CMD_KEY_COLOR)
    th_interval_init(COMP_TLDR_CMD_INFO_COLOR)
    for (i=1; i<l; i++) {
        _cmd_key_style  = th_interval(COMP_TLDR_CMD_KEY_COLOR)
        _cmd_info_style = th_interval(COMP_TLDR_CMD_INFO_COLOR)
        _cmd_info = cmd[ i, "info" ]
        _cmd_text = cmd[ i, "text" ]
        gsub(/:[ ]*$/, "", _cmd_info)
        gsub(TH_TLDR_CMD_KEY_SEP_LEFT, th_interval(COMP_TLDR_CMD_KEY_SEP), _cmd_text)
        gsub(TH_TLDR_CMD_KEY_SEP_RIGHT, _cmd_key_style, _cmd_text)

        _text = _cmd_key_style _cmd_text space_rep(max_len+4-strlen_without_color(_cmd_text)) \
            cut_info_line(_cmd_info, _cmd_info_style, max_len+4)
        _res = _res _text COMP_TLDR_NEWLINE
    }
    return _res COMP_TLDR_SPACE_LINE
}

function handle_long_cmd(cmd,
    _res, _cmd_info, _cmd_text, _cmd_info_style, _cmd_text_style, i, l, _cmd_len){
    l = cmd[ L ]
    for (i=1; i<l; i++) {
        _cmd_text = cmd[ i, "text" ]; _cmd_text_style = COMP_TLDR_CMD_KEY_COLOR_LONG
        _cmd_info = cmd[ i, "info" ]; _cmd_info_style = COMP_TLDR_CMD_INFO_COLOR_LONG
        _cmd_len  = strlen_without_color(cmd[ i, "text" ])
        gsub(TH_TLDR_CMD_KEY_SEP_LEFT, COMP_TLDR_CMD_KEY_SEP[0], _cmd_text)
        gsub(TH_TLDR_CMD_KEY_SEP_RIGHT, _cmd_text_style, _cmd_text)
        gsub(/:[ ]*$/, "", _cmd_info)

        while (_cmd_len > COMP_TLDR_COL) _cmd_len = _cmd_len - COMP_TLDR_COL

        _res = _res cut_info_line(_cmd_text, _cmd_text_style) COMP_TLDR_NEWLINE
        _res = _res _cmd_info_style "    "  cut_info_line(_cmd_info, _cmd_info_style, 4) COMP_TLDR_NEWLINE
        _res = _res COMP_TLDR_SPACE_LINE
    }
    return _res
}

function comp_tldr_parse_of_mdfile_unit(item, cmd,      _res, l ){
    if (item ~ /^[ \t\r]*$/){

    } else if (item ~ "^# ") {
        gsub("^#[ ]*", "", item)
        title_len = int(strlen_without_color(item)+2)
        return handle_title(item)
    } else if (item ~ /^> /) {
        gsub(/^>[ ]*/, "", item)
        _res = handle_desc(item, title_len)
        title_len = 0
        return _res
    } else if (item ~ /^- /) {
        gsub(/^-[ ]*/, "", item)
        cmd[ L ] = l = cmd[ L ] + 1
        cmd[ l, "info" ] = item
    } else if (item ~ /^`[^`]+`/) {
        gsub("`","  ", item)
        item = substr(item, 1, length(item)-2)
        l = cmd[ L ]
        cmd[ l, "text" ] = item
    }
}

# EndSection

function comp_tldr_init_of_mdfile(col, no_color){
    COMP_TLDR_COL = col
    COMP_TLDR_NEWLINE = UI_END "\n"
    TH_TLDR_CMD_KEY_SEP_LEFT  = SUBSEP "TH_TLDR_CMD_KEY_SEP_LEFT" SUBSEP
    TH_TLDR_CMD_KEY_SEP_RIGHT = SUBSEP "TH_TLDR_CMD_KEY_SEP_RIGHT" SUBSEP
    if (no_color != 1) {
        COMP_TLDR_BACKGROUND = UI_BG_BLACK
        COMP_TLDR_TILTE = UI_TEXT_BOLD UI_FG_GREEN COMP_TLDR_BACKGROUND
        COMP_TLDR_DESC  = UI_TEXT_BOLD UI_FG_YELLOW COMP_TLDR_BACKGROUND

        COMP_TLDR_CMD_KEY_SEP[0] = UI_TEXT_BOLD UI_FG_RED COMP_TLDR_BACKGROUND
        COMP_TLDR_CMD_KEY_SEP[1] = UI_TEXT_BOLD UI_FG_MAGENTA COMP_TLDR_BACKGROUND

        COMP_TLDR_CMD_KEY_COLOR[0]  = UI_TEXT_BOLD UI_FG_WHITE COMP_TLDR_BACKGROUND
        COMP_TLDR_CMD_KEY_COLOR[1]  = UI_TEXT_BOLD UI_FG_YELLOW COMP_TLDR_BACKGROUND
        COMP_TLDR_CMD_INFO_COLOR[0] = UI_TEXT_BOLD UI_FG_CYAN COMP_TLDR_BACKGROUND
        COMP_TLDR_CMD_INFO_COLOR[1] = UI_TEXT_BOLD UI_FG_GREEN COMP_TLDR_BACKGROUND

        COMP_TLDR_CMD_KEY_COLOR_LONG  = UI_TEXT_BOLD UI_FG_YELLOW COMP_TLDR_BACKGROUND
        COMP_TLDR_CMD_INFO_COLOR_LONG = UI_TEXT_BOLD UI_FG_CYAN COMP_TLDR_BACKGROUND
    }

    COMP_TLDR_SPACE_LINE = th(COMP_TLDR_BACKGROUND, space_rep(COMP_TLDR_COL)) "\n"
}

function comp_tldr_paint_of_file_content(content, width, no_color,      r, i, l, _, cmd, _res){
    if (width < 50) return "The current width is not enough to display the tldr document!"
    comp_tldr_init_of_mdfile(width, no_color)

    l = split(content, _, "\n")
    for (i=1; i<=l; ++i) _res = _res comp_tldr_parse_of_mdfile_unit(_[i], cmd)
    _res = _res handle_cmd(cmd)
    return _res
}
