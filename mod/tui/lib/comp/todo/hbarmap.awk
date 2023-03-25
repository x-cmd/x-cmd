
function comp_hbarmap_init( o, kp ) {
    o[ kp ] = ""
    o[ kp, "TYPE" ] = "hbarmap"
}

function comp_hbarmap_handle( o, kp, char_value, char_name, char_type,       d ) {}

function comp_hbarmap_paint( o, kp, x1, y1, y2,       v, l, vl ){
    return painter_goto_rel(x1, y1) space_restrict_or_pad( comp_hbarmap_get( o, kp ), y2 - y1 + 1 )
}
