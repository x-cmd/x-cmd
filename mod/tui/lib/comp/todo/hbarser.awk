
function comp_hbarser_init( o, kp ) {
    o[ kp ] = ""
    o[ kp, "TYPE" ] = "hbarser"
}

function comp_hbarser_handle( o, kp, char_value, char_name, char_type,       d ) {}

function comp_hbarser_paint( o, kp, x1, y1, y2,       v, l, vl ){
    return painter_goto_rel(x1, y1) space_restrict_or_pad( comp_hbarser_get( o, kp ), y2 - y1 + 1 )
}
