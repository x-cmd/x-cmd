
function comp_label_init( o, kp ) {
    o[ kp, "DATA" ] = ""
    change_set( o, kp, "label" )
}

function comp_label_handle( o, kp, char_value, char_name, char_type,       d ) {}

function comp_label_paint( o, kp, x1, y1, y2,       v, l, vl ){
    if ( ! change_is(o, kp, "label") ) return
    change_unset(o, kp, "label")
    return painter_clear_screen(x1, x2, y1, y2) painter_goto_rel(x1, y1) space_restrict_or_pad_utf8( comp_label_get( o, kp ), y2 - y1 + 1 )
}

# Section: private
function comp_label_get( o, kp ) {
    return o[ kp, "DATA" ]
}

function comp_label_put( o, kp, val ) {
    change_set( o, kp, "label" )
    o[ kp, "DATA" ] = val
}

function comp_label_clear( o, kp ) {
    comp_label_put( o, kp, "" )
}
# EndSection
