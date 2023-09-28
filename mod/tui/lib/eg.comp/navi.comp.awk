# Section: navi init and statusline
function navi_request_data( o, kp, rootkp, args, sep ){
    if (! lock_acquire( o, kp ) ) panic("lock bug")
    tapp_request( "data:request:" rootkp)
}

function navi_init( o, kp ){
    comp_navi_init(o, kp)
    ctrl_sw_init( o, kp SUBSEP "IS_CTRL_CUSTOM_PREVIEW", false)
}

function navi_statusline_init( o, kp ){
    comp_statusline_init( o, kp SUBSEP "statusline" )
    navi_statusline_normal( o, kp )
}

function navi_statusline_normal( o, kp,       l, i, v ){
    kp = kp SUBSEP "statusline"
    comp_statusline_data_clear( o, kp )
    comp_statusline_data_put( o, kp, "←↓↑→/hjkl", "Move focus","Press keys to move focus"  )
    l = o[ kp, "custom" L ]
    for (i=1; i<=l; i++) {
        v = o[ kp, "custom", i ]
        comp_statusline_data_put( o, kp, v, o[ kp, "custom", v, "short-help"], o[ kp, "custom", v, "long-help"])
    }
    comp_statusline_data_put( o, kp, "q", "Quit", "Press 'q' to quit table" )
    comp_statusline_data_put( o, kp, "/", "Search", "Press '/' to search items" )
    comp_statusline_data_put( o, kp, "Ctrl x", "", "Change the display screen size" )
    comp_statusline_data_put( o, kp, "Tab", "Open help", "Close help" )
}

function navi_statusline_search(o, kp){
    kp = kp SUBSEP "statusline"
    comp_statusline_data_clear( o, kp )
    comp_statusline_data_put( o, kp, "←↓↑→/hjkl", "Move focus","Press keys to move focus"  )
    comp_statusline_data_put( o, kp, "/", "Close search", "Press '/' to close search items" )
}

function navi_statusline_add( o, kp, v, s, l ){
    o[ kp, "statusline", "custom" L ] = i = o[ kp, "statusline", "custom" L ] + 1
    o[ kp, "statusline", "custom", i ] = v
    o[ kp, "statusline", "custom", v, "short-help" ] = s
    o[ kp, "statusline", "custom", v, "long-help" ] = l
}

# EndSection

# Section: navi ctrl
function tapp_canvas_rowsize_recalulate( rows,          r, all_r ){
    if (rows < 10)  return false # Assure the screen size
    all_r = rows - 1
    if (TAPP_CANVAS_FULLSCREEN == 1) return all_r

    r = 30
    return (rows <= r) ? all_r : r
}

function tapp_canvas_colsize_recalulate( cols ){
    if (cols < 30) return false
    return cols - 2
}

# use user_paint and user_request_data
function navi_change_set_all(o, kp){
    comp_navi_change_set_all( o, kp )
    comp_statusline_change_set_all(o, kp SUBSEP "statusline")
}

function navi_handle_clocktick( o, kp, idx, trigger, row, col ){
    if (ROWS_COLS_HAS_CHANGED) navi_change_set_all( o, kp )
    user_paint( 1, row, 1, col )

    if (! lock_unlocked( o, kp )) return
    comp_navi_current_position_set(o, kp)
    if ( comp_navi_unava_has_set( o, kp ) ) user_request_data( o, kp, comp_navi_unava( o, kp ) )
}

function navi_handle_wchar( o, kp, value, name, type,          _has_no_handle ){
    comp_handle_exit( value, name, type )
    if (comp_statusline_isfullscreen(o, kp SUBSEP "statusline")){
        if (! comp_statusline_handle( o, kp SUBSEP "statusline", value, name, type )) _has_no_handle = true
        if (! comp_statusline_isfullscreen(o, kp SUBSEP "statusline")) navi_change_set_all( o, kp )
    } else {
        if (value == "/")                                           comp_navi_sel_sw_toggle( o, kp )
        else if (comp_navi_handle( o, kp, value, name, type ))      _has_no_handle = false
        else if (value == "q")                                      exit_with_elegant("q")
        else if (name == U8WC_NAME_CARRIAGE_RETURN)                 exit_with_elegant("ENTER")
        else _has_no_handle = true

        # update statusline
        if ((_has_no_handle == true) && (comp_statusline_handle( o, kp SUBSEP "statusline", value, name, type ))) _has_no_handle = false
        else if (ctrl_navi_sel_sw_get( o, kp )) navi_statusline_search( o, kp )
        else navi_statusline_normal( o, kp )
    }

    return ( _has_no_handle == true ) ? false : true
}
# EndSection

# Section: navi view
# use user_paint_custom_component and user_paint_status
function navi_paint( o, kp, x1, x2, y1, y2,       _res ){
    if (! comp_statusline_isfullscreen(o, kp SUBSEP "statusline")) {
        _res = comp_navi_paint( o, kp, x1, x2-3, y1, y2)

        if ( comp_navi_paint_preview_ischange( o, kp ) ){
            _res = _res user_paint_custom_component( o, kp, \
                o[ kp, "PREVIEW", "KP" ], \
                o[ kp, "PREVIEW", "X1" ], \
                o[ kp, "PREVIEW", "X2" ], \
                o[ kp, "PREVIEW", "Y1" ], \
                o[ kp, "PREVIEW", "Y2" ] )
        }

        _res = _res user_paint_status( o, kp, x2-2, x2-1, y1, y2 )
        _res = _res comp_statusline_paint( o, kp SUBSEP "statusline", x2, x2, y1, y2 )
        paint_screen( _res )
    } else {
        comp_statusline_set_fullscreen( o, kp SUBSEP "statusline", x1, x2, y1, y2 )
        paint_screen( comp_statusline_paint(o, kp SUBSEP "statusline") )
    }
}

# EndSection
