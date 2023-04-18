
function comp_lineedit_init( o, kp, val, w) {
    o[ kp, "TYPE" ] = "lineedit"
    w = (w != "") ? w : 100
    ctrl_stredit_init(o, kp, val, w)
    change_set( o, kp, "lineedit" )
}

function comp_lineedit_width(o, kp, w){
    return ctrl_stredit_width_set(o, kp, w)
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

function comp_lineedit_paint( o, kp, x1, x2, y1, y2 ){
    return comp_lineedit_paint_with_cursor(o, kp, x1, y1, y2)
}

function comp_lineedit_paint_with_cursor(o, kp, x1, y1, y2,       s, i, b, lv, rv, l, _str){
    if ( ! change_is(o, kp, "lineedit") ) return
    change_unset(o, kp, "lineedit")

    s = comp_lineedit_get(o, kp)
    i = comp_lineedit_curpos(o, kp)
    b = ctrl_stredit_border_left_get( o, kp )
    lv = substr(s, b+1, i-b)
    rv = substr( wcstruncate_cache(  substr(s, b+1), ctrl_stredit_width_get( o, kp )-1 ), i-b+1 )

    if (rv == "") _str = lv th(TH_CURSOR, " ")
    else {
        l = ctrl_stredit_nextfont_width(rv)
        _str = lv th( TH_CURSOR, substr(rv, 1, l) ) substr(rv, l+1)
    }
    return painter_clear_screen(x1, x2, y1, y2) painter_goto_rel(x1, y1) _str
}

# Section: private
function comp_lineedit_get( o, kp ) {
    return ctrl_stredit_value(o, kp)
}

function comp_lineedit_curpos(o, kp) {
    return ctrl_stredit_curpos(o, kp)
}

function comp_lineedit_get_cursor_left_value(o, kp,        v, p){
    v = comp_lineedit_get(o, kp)
    p = comp_lineedit_curpos(o, kp)
    return substr(v, 1, p-1)
}

function comp_lineedit_get_cursor_right_value(o, kp,        v, p){
    v = comp_lineedit_get(o, kp)
    p = comp_lineedit_curpos(o, kp)
    return substr(v, p)
}

function comp_lineedit_put( o, kp, val ) {
    change_set( o, kp, "lineedit" )
    ctrl_stredit_init(o, kp, val)
}

function comp_lineedit_clear( o, kp ) {
    change_set( o, kp, "lineedit" )
    comp_lineedit_put( o, kp, "" )
}

function comp_lineedit_width_set( o, kp, w ){
    change_set( o, kp, "lineedit" )
    o[ kp, "width" ] = w
}
function comp_lineedit_width_get( o, kp ){ return o[ kp, "width" ];     }

# EndSection
