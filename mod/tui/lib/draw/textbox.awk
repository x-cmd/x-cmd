## Section print
function draw_textbox_change_set( o, kp ){
    change_set(o, kp, "textbox")
}

function draw_textbox_paint( o, kp, x1, x2, y1, y2, has_box, color, is_box_arc, padding ){
    if (o[ kp, "MODE" ] == "scrollable")
        return  draw_textbox___paint_scrollable( o, kp, x1, x2, y1, y2, has_box, color, is_box_arc, padding )
    return      draw_textbox___paint_pageble( o, kp, x1, x2, y1, y2, has_box, color, is_box_arc, padding )
}

function draw_textbox___paint_pageble( o, kp, x1, x2, y1, y2, has_box, color, is_box_arc, padding,          a, l, i, col, row, _next_line, s, _start, _end, _comp_box, _comp_clear, _comp_text ){
    if ( ! change_is(o, kp, "textbox") ) return
    change_unset(o, kp, "textbox")

    _comp_clear = painter_clear_screen( x1, x2, y1, y2)
    if ( has_box == true ) {
        if (is_box_arc == true) _comp_box = painter_box_arc( x1, x2, y1, y2, color )
        else _comp_box = painter_box( x1, x2, y1, y2, color )
        x1++; x2--; y1++; y2--
    }
    x1+=padding; x2-=padding; y1+=padding; y2-=padding

    if ((row = x2 - x1 + 1) > 0) {
        utf8tt_refresh( o, kp, row, col = y2-y1+1 )
        l = o[kp, "VIEW" L]
        ctrl_page_init(o, kp, 1, l, "", row)

        _next_line = "\r\n" painter_right( y1 )
        _start = ctrl_page_begin(o, kp)
        _end   = ctrl_page_end( o, kp )
        s = o[kp, "VIEW", _start]
        for (i=_start+1; i<=_end; ++i)
            s = s _next_line ( (i>l) ? space_rep( col ) : o[kp, "VIEW", i] )
        _comp_text = painter_goto_rel(x1, y1) s
    }
    return _comp_clear _comp_text _comp_box
}

function draw_textbox___paint_scrollable( o, kp, x1, x2, y1, y2, has_box, color, is_box_arc, padding,          a, l, i, col, row, _next_line, s, _start, _comp_box, _comp_clear, _comp_text ){
    if ( ! change_is(o, kp, "textbox") ) return
    change_unset(o, kp, "textbox")

    _comp_clear = painter_clear_screen( x1, x2, y1, y2)
    if ( has_box == true ) {
        if (is_box_arc == true) _comp_box = painter_box_arc( x1, x2, y1, y2, color )
        else _comp_box = painter_box( x1, x2, y1, y2, color )
        x1++; x2--; y1++; y2--
    }
    x1+=padding; x2-=padding; y1+=padding; y2-=padding

    if ((row = x2 - x1 + 1) > 0) {
        utf8tt_refresh( o, kp, row, col = y2-y1+1 )
        l = o[kp, "VIEW" L]
        ctrl_page_max_set( o, kp, l )  # actually, it should use windows movement
        ctrl_page_pagesize_set( o, kp, row )

        _start = ctrl_page_val(o, kp)
        _next_line = "\r\n" painter_right( y1 )
        s = o[kp, "VIEW", _start]
        for (i=_start+1; i<=_start+row-1; ++i)
            s = s _next_line ( (i>l) ? space_rep( col ) : o[kp, "VIEW", i] )
        _comp_text = painter_goto_rel(x1, y1) s
    }
    return _comp_clear _comp_text _comp_box
}
# EndSection