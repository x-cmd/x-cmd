function draw_lineedit_paint( x1, x2, y1, y2, opt ){
    return draw_lineedit___paint_with_cursor(x1, x2, y1, y2, opt)
}

function draw_lineedit___paint_with_cursor(x1, x2, y1, y2, opt,       _str){
    _str = draw_lineedit_str_with_cursor(opt)
    return painter_clear_screen(x1, x2, y1, y2) painter_goto_rel(x1, y1) _str
}

function draw_lineedit_str_with_cursor(opt,             s, i, b, lv, rv, l, _str, _text_style, _cursor_style){
    s = opt_get( opt, "line.text" )
    i = opt_get( opt, "cursor.pos" )
    b = opt_get( opt, "start.pos" )
    lv = substr(s, b+1, i-b)
    rv = substr( wcstruncate_cache( substr(s, b+1), opt_get( opt, "line.width" )-1 ), i-b+1 )

    if (opt_get( opt, "display.error" )) {
        _text_style     = UI_FG_BRIGHT_RED
        _cursor_style   = TH_ERROR_CURSOR
    } else {
        _text_style     = ""
        _cursor_style   = TH_CURSOR
    }

    if (rv == "") _str = th(_text_style, lv) th(_cursor_style, " ")
    else {
        l = wcwidth_first_char_cache(rv)
        _str = th(_text_style, lv) th( _cursor_style, substr(rv, 1, l) ) th(_text_style, substr(rv, l+1))
    }
    return _str
}
