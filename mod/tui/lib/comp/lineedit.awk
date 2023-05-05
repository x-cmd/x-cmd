
function comp_lineedit_init( o, kp, val, w) {
    o[ kp, "TYPE" ] = "lineedit"
    w = (w != "") ? w : 100
    ctrl_stredit_init(o, kp, val, w)
    change_set( o, kp, "lineedit" )
}

function comp_lineedit_width(o, kp, w){
    if (w == "")    return ctrl_stredit_width_get(o, kp)
    else            return ctrl_stredit_width_set(o, kp, w)
}

function comp_lineedit_handle( o, kp, char_value, char_name, char_type,       d ) {
    if ( o[ kp, "TYPE" ] != "lineedit" ) return false
    if ( char_type != U8WC_TYPE_SPECIAL ) {
        if (char_name == U8WC_NAME_DELETE)  ctrl_stredit_value_del(o, kp)
        else if (char_value != "") ctrl_stredit_value_add(o, kp, char_value)
        else return false
    }
    else if (char_name == U8WC_NAME_LEFT)   ctrl_stredit_cursor_backward(o, kp)
    else if (char_name == U8WC_NAME_RIGHT)  ctrl_stredit_cursor_forward(o, kp)
    else return false
    change_set( o, kp, "lineedit" )
    return true
}

function comp_lineedit_change_set( o, kp ){
    change_set(o, kp, "lineedit")
}

function comp_lineedit_paint( o, kp, x1, x2, y1, y2,        _opt ){
    if ( ! change_is(o, kp, "lineedit") ) return
    change_unset(o, kp, "lineedit")

    opt_set( _opt, "line.text",     comp_lineedit_get(o, kp) )
    opt_set( _opt, "line.width",    comp_lineedit_width(o, kp) )
    opt_set( _opt, "cursor.pos",    comp_lineedit___cursor_pos(o, kp) )
    opt_set( _opt, "start.pos",     comp_lineedit___start_pos(o, kp) )
    return draw_lineedit_paint( o, kp, x1, x2, y1, y2, _opt )
}

# Section: private
function comp_lineedit_get( o, kp ) {
    return ctrl_stredit_value(o, kp)
}

function comp_lineedit_put( o, kp, val ) {
    change_set( o, kp, "lineedit" )
    ctrl_stredit_init(o, kp, val)
}

function comp_lineedit_clear( o, kp ) {
    change_set( o, kp, "lineedit" )
    comp_lineedit_put( o, kp, "" )
}

function comp_lineedit___cursor_pos(o, kp) {
    return ctrl_stredit_cursor_pos(o, kp)
}

function comp_lineedit___start_pos(o, kp) {
    return ctrl_stredit_start_pos(o, kp)
}

function comp_lineedit___get_cursor_left_value(o, kp,        v, p){
    v = comp_lineedit_get(o, kp)
    p = comp_lineedit___cursor_pos(o, kp)
    return substr(v, 1, p-1)
}

function comp_lineedit___get_cursor_right_value(o, kp,        v, p){
    v = comp_lineedit_get(o, kp)
    p = comp_lineedit___cursor_pos(o, kp)
    return substr(v, p)
}

# EndSection
