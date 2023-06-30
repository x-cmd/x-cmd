function re_isint( str ){
    return str ~ "^"RE_NUM"$"
}

function pick_init( o, kp, filter_sw, title, row, col, width, limit ){
    if (limit != "no-limit") {
        if (!re_isint(limit) || limit < 1) limit = 1
    }

    if ((!re_isint(row))    || (row < 5) )      panic("pick row must be a number greater than or equal to 5")
    if ((!re_isint(col))    || (col < 1) )      panic("pick col must be a number greater than or equal to 1")
    if ((!re_isint(width))  || (width < 5) )    panic("pick width must be a number greater than or equal to 5")

    comp_gsel_init(o, kp, title, filter_sw)
    comp_gsel_item_width(o, kp, width)
    comp_gsel_set_limit( o, kp, limit )
}

function pick_handle( o, kp, value, name, type ){
    comp_handle_exit( value, name, type )
    if (name == U8WC_NAME_CARRIAGE_RETURN)  exit_with_elegant("ENTER")
    else if ( comp_gsel_handle( o, kp, value, name, type ) ) {
        comp_gsel_model_end(o, kp)
        return true
    }
    return false
}

function pick_data_set( o, kp, arr ){
    comp_gsel_data_cp( o, kp, arr )
}

function pick_change_set_all( o, kp ){
    comp_gsel_change_set_all( o, kp )
}

function pick_paint_auto(o, kp, x1, x2, y1, y2, row, col, width,            r, c, w){
    r = x2 - x1 + 1
    c = y2 - y1 + 1
    w = width * col

    if (width > c)  comp_gsel_item_width( o, GSEL_KP, width = c )
    if (w > c)      w = width * int(c/width)
    if (row > r)    row = r
    return pick_paint( o, kp, x1, x1 + row - 1, y1, y1 + w - 1)
}

function pick_paint( o, kp, x1, x2, y1, y2 ){
    return comp_gsel_paint( o, kp, x1, x2, y1, y2)
}

function pick_result( o, kp ){
    if (comp_gsel_ctrl_multiple_sw_get( o, kp )) return comp_gsel_get_selected_item(o, kp)
    else return comp_gsel_get_cur_item(o, kp)
}

