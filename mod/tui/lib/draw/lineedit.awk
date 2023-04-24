function draw_lineedit_change_set( o, kp ){
    change_set(o, kp, "lineedit")
}

function draw_lineedit_paint( o, kp, x1, x2, y1, y2, opt ){
    return draw_lineedit___paint_with_cursor(o, kp, x1, y1, y2, opt)
}

function draw_lineedit___paint_with_cursor(o, kp, x1, y1, y2, opt,       s, i, b, lv, rv, l, _str){
    if ( ! change_is(o, kp, "lineedit") ) return
    change_unset(o, kp, "lineedit")

    s = opt_get( opt, "line.text" )
    i = opt_get( opt, "cursor.pos" )
    b = opt_get( opt, "start.pos" )
    lv = substr(s, b+1, i-b)
    rv = substr( wcstruncate_cache( substr(s, b+1), opt_get( opt, "line.width" )-1 ), i-b+1 )
    if (rv == "") _str = lv th(TH_CURSOR, " ")
    else {
        l = wcwidth_first_char_cache(rv)
        _str = lv th( TH_CURSOR, substr(rv, 1, l) ) substr(rv, l+1)
    }
    return painter_clear_screen(x1, x2, y1, y2) painter_goto_rel(x1, y1) _str
}

