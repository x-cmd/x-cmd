function re_positive_int( str ){
    return str ~ "^[+]?(0|[1-9][0-9]*)$"
}

function pick_init( o, kp, filter_sw, obj,          title, row, col, width, limit ){
    row = obj[ "ROW" ] ; col = obj[ "COL" ] ; width = obj[ "WIDTH" ] ; title = obj[ "TITLE" ] ; limit = obj[ "LIMIT" ]

    if (limit != "no-limit") {
        if (!re_positive_int(limit) || limit < 1) limit = 1
    }

    if ((!re_positive_int(row)) || (row < 5) )          panic("The pick row must be a positive integer greater than or equal to 5")
    if ((!re_positive_int(col)) || (col < 1) )          panic("The pick col must be a positive integer greater than or equal to 1")

    if ( width ~ "^"RE_NUM_PERCENTAGE"$" )              width = int(tapp_canvas_colsize_get() * width / 100)
    else if (width == "-")                              { width = 5; obj[ "WIDTH_ADAPTIVE" ] = 1; }
    else if ((!re_positive_int(width)) || (width < 5) ) panic("The pick width must be a positive integer greater than or equal to 5")

    comp_gsel_init(o, kp, title, filter_sw)
    comp_gsel_item_width(o, kp, width)
    comp_gsel_set_limit( o, kp, limit )

    obj[ "ROW" ] = row ; obj[ "COL" ] = col ; obj[ "WIDTH" ] = width ; obj[ "TITLE" ] = title ; obj[ "LIMIT" ] = limit
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

function pick_data_set( o, kp, arr, obj,        i, l, w, max_w, title_width ){
    if (obj[ "WIDTH_ADAPTIVE" ] == 1) {
        l = arr[L]
        for (i=1; i<=l; ++i){
            w = wcswidth_cache( arr[i] )
            if (max_w < w) max_w = w
        }
        title_width = wcswidth_cache( obj[ "TITLE" ] )
        if (max_w < title_width) max_w = title_width
        comp_gsel_item_width(o, kp, (obj[ "WIDTH" ] = max_w))
        obj[ "WIDTH_ADAPTIVE" ] = 0
    }
    comp_gsel_data_cp( o, kp, arr )
}

function pick_change_set_all( o, kp ){
    comp_gsel_change_set_all( o, kp )
}

function pick_paint_auto(o, kp, x1, x2, y1, y2, obj,        row, col, width, r, c, w){
    row = obj[ "ROW" ]
    col = obj[ "COL" ]
    width = obj[ "WIDTH" ]
    r = x2 - x1 + 1
    c = y2 - y1 + 1
    w = width * col

    if (width > c)  comp_gsel_item_width( o, GSEL_KP, ( obj[ "WIDTH" ] = width = c ) )
    if (w > c)      w = width * int(c/width)
    if (row > r) {
        if (row < ROWS-1) {
            obj[ "ROW" ] = ROW_RECALULATE = row
        } else {
            obj[ "ROW" ] = ROW_RECALULATE = row = ROWS - 1
        }
        tapp_canvas_has_changed()
        return
    }

    return pick_paint( o, kp, x1, x1 + row - 1, y1, y1 + w - 1)
}

function pick_paint( o, kp, x1, x2, y1, y2 ){
    return comp_gsel_paint( o, kp, x1, x2, y1, y2)
}

function pick_result( o, kp ){
    if (comp_gsel_ctrl_multiple_sw_get( o, kp )) return comp_gsel_get_selected_item(o, kp)
    else return comp_gsel_get_cur_item(o, kp)
}

