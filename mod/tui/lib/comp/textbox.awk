
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
    draw_textbox_change_set(o, kp)
}

function comp_textbox_paint( o, kp, x1, x2, y1, y2, has_box, color, is_box_arc, padding ){
    return draw_textbox_paint( o, kp, x1, x2, y1, y2, has_box, color, is_box_arc, padding )
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

