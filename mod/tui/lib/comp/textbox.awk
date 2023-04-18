
function comp_textbox_init( o, kp, scrollable ) {
    o[ kp, "val" ] = ""
    o[ kp, "TYPE" ] = "textbox"
    o[ kp, "MODE" ] = (scrollable) ? "scrollable" : "pagable"
    ctrl_page_init( o, kp, 1, 1, 1 )
}

# Section: handle
function comp_textbox_handle( o, kp, char_value, char_name, char_type ) {
    if ( o[ kp, "TYPE" ] != "textbox" ) return false
    if (o[ kp, "MODE" ] == "scrollable")
        return  comp_textbox___handle_scrollable( o, kp, char_value, char_name, char_type )
    return      comp_textbox___handle_pageble( o, kp, char_value, char_name, char_type )
}

function comp_textbox___handle_pageble( o, kp, char_value, char_name, char_type ) {
    if ((char_value == "k") || (char_name == U8WC_NAME_UP))          ctrl_page_prev_page( o, kp )
    else if ((char_value == "j") || (char_name == U8WC_NAME_DOWN))   ctrl_page_next_page( o, kp )
    else return false
    change_set(o, kp, "textbox")
    return true
}

function comp_textbox___handle_scrollable( o, kp, char_value, char_name, char_type ) {
    if ((char_value == "k") || (char_name == U8WC_NAME_UP))          ctrl_page_dec( o, kp )
    else if ((char_value == "j") || (char_name == U8WC_NAME_DOWN))   ctrl_page_inc( o, kp )
    else return false
    change_set(o, kp, "textbox")
    return true
}

# EndSection

# Section print
function comp_textbox_change_set( o, kp ){
    change_set(o, kp, "textbox")
}

function comp_textbox_paint( o, kp, x1, x2, y1, y2, has_box, color, is_box_arc, padding ){
    if (o[ kp, "MODE" ] == "scrollable")
        return  comp_textbox___paint_scrollable( o, kp, x1, x2, y1, y2, has_box, color, is_box_arc, padding )
    return      comp_textbox___paint_pageble( o, kp, x1, x2, y1, y2, has_box, color, is_box_arc, padding )
}

function comp_textbox___paint_pageble( o, kp, x1, x2, y1, y2, has_box, color, is_box_arc, padding,          a, l, i, col, row, _next_line, s, _start, _end, _comp_box, _comp_clear, _comp_text ){
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

function comp_textbox___paint_scrollable( o, kp, x1, x2, y1, y2, has_box, color, is_box_arc, padding,          a, l, i, col, row, _next_line, s, _start, _comp_box, _comp_clear, _comp_text ){
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

# Section: private
function comp_textbox_get( o, kp ) {
    return o[ kp, "val" ]
}

function comp_textbox_put( o, kp, val ) {
    change_set(o, kp, "textbox")
    o[ kp, "val" ] = val
    utf8tt_init( val, o, kp )
}

function comp_textbox_clear( o, kp ) {
    change_set(o, kp, "textbox")
    ctrl_page_init( o, kp, 1, 1, 1 )
    comp_textbox_put( o, kp, "" )
}
# EndSection

