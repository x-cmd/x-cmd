function draw_textbox_data_init( o, kp, v ){
    utf8tt_init( v, o, kp )
}

function draw_textbox_paint( o, kp, x1, x2, y1, y2, opt ){
    if (opt_get( opt, "textbox.mode" ) == "scrollable")
        return  draw_textbox___on_scrollable( o, kp, x1, x2, y1, y2, opt )
    return      draw_textbox___on_pageble( o, kp, x1, x2, y1, y2, opt )
}

function draw_textbox___on_pageble( o, kp, x1, x2, y1, y2, opt,         v, a, l, i, col, row, _next_line, s, _start, _end, _draw_box, _draw_clear, _draw_text, _color, _padding ){
    _draw_clear = painter_clear_screen( x1, x2, y1, y2)
    if ( opt_getor( opt, "box.enable", false ) ){
        _color = opt_get( opt, "box.color" )
        if ( opt_getor( opt, "box.arc.enable", false ) ) _draw_box = painter_box_arc( x1, x2, y1, y2, _color )
        else _draw_box = painter_box( x1, x2, y1, y2, _color )
        x1++; x2--; y1++; y2--
    }
    _padding = opt_get( opt, "padding" )
    x1+=_padding; x2-=_padding; y1+=_padding; y2-=_padding

    if ((row = x2 - x1 + 1) > 0) {
        utf8tt_refresh( o, kp, row, col = y2-y1+1 )
        l = o[kp, "VIEW" L]
        opt_set( opt, "page.max", l )
        opt_set( opt, "page.size", row )

        _next_line = "\r\n" painter_right( y1 )
        v = opt_getor( opt, "page.currow", 1 )
        _start = draw_unit_page_begin( v, row )
        _end = draw_unit_page_end( v, row, l )
        s = o[kp, "VIEW", _start]
        for (i=_start+1; i<=_end; ++i)
            s = s _next_line ( (i>l) ? space_rep( col ) : o[kp, "VIEW", i] )
        _draw_text = painter_goto_rel(x1, y1) s
    }
    return _draw_clear _draw_text _draw_box
}

function draw_textbox___on_scrollable( o, kp, x1, x2, y1, y2, opt,          a, l, i, col, row, _next_line, s, _start, _draw_box, _draw_clear, _draw_text, _color, _padding ){
    _draw_clear = painter_clear_screen( x1, x2, y1, y2)
    if ( opt_getor( opt, "box.enable", false ) ){
        _color = opt_get( opt, "box.color" )
        if ( opt_getor( opt, "box.arc.enable", false ) ) _draw_box = painter_box_arc( x1, x2, y1, y2, _color )
        else _draw_box = painter_box( x1, x2, y1, y2, _color )
        x1++; x2--; y1++; y2--
    }
    _padding = opt_get( opt, "padding" )
    x1+=_padding; x2-=_padding; y1+=_padding; y2-=_padding

    if ((row = x2 - x1 + 1) > 0) {
        utf8tt_refresh( o, kp, row, col = y2-y1+1 )
        l = o[kp, "VIEW" L]
        # actually, it should use windows movement
        opt_set( opt, "page.max", l )
        opt_set( opt, "page.size", row )

        _start = opt_getor( opt, "page.currow", 1 )
        _next_line = "\r\n" painter_right( y1 )
        s = o[kp, "VIEW", _start]
        for (i=_start+1; i<=_start+row-1; ++i)
            s = s _next_line ( (i>l) ? space_rep( col ) : o[kp, "VIEW", i] )
        _draw_text = painter_goto_rel(x1, y1) s
    }
    return _draw_clear _draw_text _draw_box
}

