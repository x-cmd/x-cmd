function draw_lineeditadvise_paint( x1, x2, y1, y2, opt ){
    return draw_lineeditadvise___paint_with_cursor_advise(x1, x2, y1, y2, opt)
}

function draw_lineeditadvise___paint_with_cursor_advise(x1, x2, y1, y2, opt,       _str){
    _str = draw_lineeditadvise_str_with_cursor_advise(opt)
    return painter_clear_screen(x1, x2, y1, y2) painter_goto_rel(x1, y1) _str
}

function draw_lineeditadvise_str_with_cursor_advise(opt,             s, i, b, lv, lw, rv, style_width, adv, e, l, _str, _text_style, _cursor_style){
    s = opt_get( opt, "line.text" )
    i = opt_get( opt, "cursor.pos" )
    b = opt_get( opt, "start.pos" )
    lv = substr(s, b+1, i-b)
    rv = substr(s, i+1)
    lw = i - b + 1
    style_width = opt_get( opt, "line.width" ) - 1
    adv = opt_get( opt, "advise.text" )

    if (opt_get( opt, "display.error" )) {
        _text_style     = UI_FG_BRIGHT_RED
        _cursor_style   = TH_ERROR_CURSOR
    } else {
        _cursor_style   = TH_CURSOR
        _text_style     = ""
    }

    e = substr( wcstruncate_cache( lv adv rv, style_width ), lw )
    if (e == "") _str = th(_text_style, lv) th(_cursor_style, " ")
    else {
        l = wcwidth_first_char_cache(e)
        rv = substr(e, l+1)
        adv = substr(adv, l+1)
        _str = th(_text_style, lv) th(_cursor_style, substr(e, 1, l)) th(UI_TEXT_DIM, adv) th(_text_style, substr(rv, length(adv)+1))
    }

    return _str
}

# function draw_lineeditadvise___paint_with_advise_box(o, kp, x1, x2, y1, y2,         rv){
#     rv = comp_lineeditadvise___get_cursor_right_value(o, kp)
#     comp_lineeditadvise___load_advise(o, kp, rv)
#     if (o[ kp, "advise", "candidate.data" L ] <= 0) return
#     # comp_lsel_data_clear(o, kp SUBSEP "lsel")
#     # comp_lsel_data_cp(o, kp SUBSEP "lsel", o, kp SUBSEP "advise")
#     # return comp_lsel_paint_body( o, kp SUBSEP "lsel", x1, x2, y1, y2 )
# }

