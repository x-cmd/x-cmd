
# If row/col is not enough, full screen helper.
# side helper.

function comp_helper_init( o, kp ) {
    o[ kp ] = ""
    o[ kp, "TYPE" ] = "helper"
}

function comp_helper_handle( o, kp, char_value, char_name, char_type,       d ) {}

function comp_helper_paint( o, kp, x1, y1, y2,       v, l, vl ){
    return painter_goto_rel(x1, y1) space_restrict_or_pad( comp_helper_get( o, kp ), y2 - y1 + 1 )
}


