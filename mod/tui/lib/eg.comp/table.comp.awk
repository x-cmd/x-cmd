# Section: table init
function table_init(o, kp){
    table_datamodel_request_page_count()
    table_datamodel_request_page(o, kp, 1)
    comp_table_init(o, kp)
    # comp_table_model_fulldata_mode( o, kp, FULLDATA_MODE_ONTHEWAY )
}

function table_statusline_init(o, kp){
    comp_statusline_init( o, kp SUBSEP "statusline", "?" )
    table_statusline_normal( o, kp SUBSEP "statusline" )
}

# EndSection

# Section: statusline
function table_statusline_normal(o, kp,         l, i, v){
    comp_statusline_data_clear( o, kp )
    comp_statusline_data_put( o, kp, "?", "Open help", "Close help" )
    comp_table_inject_statusline_default( o, kp )
    comp_statusline_data_put( o, kp, "/", "Search", "Press 's' to search items" )
    comp_statusline_data_put( o, kp, "f", "Filter", "Press '/' to filter items" )
    comp_statusline_data_put( o, kp, "q", "Quit", "Press 'q' to quit table" )
    l = o[ kp, "custom" L ]
    for (i=1; i<=l; i++) {
        v = o[ kp, "custom", i ]
        comp_statusline_data_put( o, kp, v, o[ kp, "custom", v, "short-help"], o[ kp, "custom", v, "long-help"])
    }
    comp_statusline_data_put( o, kp, "CURRENT INFO")
}

function table_statusline_search(o, kp){
    comp_statusline_data_clear( o, kp )
    comp_statusline_data_put( o, kp, "enter", "Quit filter/search" )
}
# EndSection

function table_cell_def( o, kp, rowid, colid, val ){     comp_table_model_set_cell( o, kp, rowid, colid, val ); }
function table_layout( o, kp, colid, min, max ){    return comp_table_layout_avg_ele_add( o, kp, colid, min, max );   }
function table_add( o, kp, name ) {     return comp_table_head_add(o, kp, name);  }
function table_statusline_add( o, kp, v, s, l,          i ){
    o[ kp, "statusline", "custom" L ] = i = o[ kp, "statusline", "custom" L ] + 1
    o[ kp, "statusline", "custom", i ] = v
    o[ kp, "statusline", "custom", v, "short-help" ] = s
    o[ kp, "statusline", "custom", v, "long-help" ] = l
}

# Section: handle_wchar,table_handle_wchar
function table_handle_wchar( o, kp, value, name, type,            _has_no_handle ){
    comp_handle_exit( value, name, type )
    if (comp_statusline_isfullscreen(o, kp SUBSEP "statusline")){
        if (! comp_statusline_handle( o, kp SUBSEP "statusline", value, name, type ) ) _has_no_handle = true
        if (! comp_statusline_isfullscreen(o, kp SUBSEP "statusline")) table_change_set_all( o, kp )
    }else {
        if (comp_table_handle( o, kp, value, name, type ))  comp_table_model_end(o, kp)
        else if (name == U8WC_NAME_CARRIAGE_RETURN)         exit_with_elegant("ENTER")
        else if (value == "q")                              exit(0)
        else if (value == "f"){
            comp_table_ctrl_filter_sw_toggle(o, kp)
            table_change_set_all( o, kp )
            if ( ! comp_table_model_isfulldata(o, kp) )     comp_table_model_fulldata_mode( o, kp, FULLDATA_MODE_ONTHEWAY )
        }
        else if (value == "/"){
            comp_table_ctrl_search_sw_toggle(o, kp)
            table_change_set_all( o, kp )
            if ( ! comp_table_model_isfulldata(o, kp) )     comp_table_model_fulldata_mode( o, kp, FULLDATA_MODE_ONTHEWAY )
        }
        else _has_no_handle = true

        # update statusline
        if ((_has_no_handle == true) && (comp_statusline_handle( o, kp SUBSEP "statusline", value, name, type )))
            comp_statusline_data_set_long(o, kp SUBSEP "statusline", "CURRENT INFO", comp_table_get_cur_line(o, kp, true, "\n  "))
        else if (comp_table_ctrl_filter_sw_get(o, kp) || comp_table_ctrl_search_sw_get(o, kp))
            table_statusline_search(o, kp SUBSEP "statusline")
        else table_statusline_normal(o, kp SUBSEP "statusline")
    }

    return ( _has_no_handle == true ) ? false : true
}
# EndSection

# Section: table_paint
function table_change_set_all( o, kp ){
    comp_table_change_set_all( o, kp )
    comp_statusline_change_set_all(o, kp SUBSEP "statusline")
}

function table_paint_necessary_rows(){   return 6; }
function table_paint_necessary_cols(data_row){   return 7+length(data_row); }
function table_paint(o, kp, x1, x2, y1, y2, has_change_canvas,        _res, r ){
    if (has_change_canvas == true) table_change_set_all( o, kp )
    if (! comp_statusline_isfullscreen(o, kp SUBSEP "statusline")){
        _res = \
            comp_table_paint( o, kp, x1, x2-1, y1, y2) \
            comp_statusline_paint( o, kp SUBSEP "statusline", x2, x2, y1+1, y2 )
        paint_screen( _res )
    }else{
        comp_statusline_set_fullscreen( o, kp SUBSEP "statusline", x1, x2, y1, y2 )
        paint_screen( comp_statusline_paint(o, kp SUBSEP "statusline") )
    }
}

# EndSection

# Section: user controller: tapp_handle_response --- request data
function table_datamodel_refill(o, kp,         r){
    if (ROWS_COLS_HAS_CHANGED) table_change_set_all( o, kp )
    if (! lock_unlocked( o, kp )) return
    if ( (r = comp_table_unava(o, kp)) >= 1 ) {     # comp_table_paint_data_is_inavailable( o, kp )
        if (!comp_table_model_isfulldata(o, kp)) table_datamodel_request_page( o, kp, r )
    } else {
        if (comp_table_model_fulldata_mode_is_ontheway( o, kp )) {
            r = comp_table_get_the_first_unava(o, kp)     # Get the first unavailable
            if ( r != "" ) table_datamodel_request_page( o, kp, r )
            else comp_table_model_fulldata_mode(o, kp, FULLDATA_MODE_TRUE)
        }
    }
}

function table_datamodel_request_page(o, kp, row){
    if (! lock_acquire( o, kp ) ) panic("lock bug")
    tapp_request("data:request:" row)
}

function table_datamodel_request_page_count(){
    tapp_request("data:total_count")
}


function table_handle_response( o, kp, content,             _start ){
    if ( match( content, "^data:total_count:[0-9]+") ) {
        gsub("^.+:.+:", "", content)
        comp_table_model_maxrow(o, kp, int(content))
        comp_table_model_end(o, kp)
        lock_release( o, kp )
        return true
    }

    if( match( content, "^data:start:[0-9]+")){

        _start = substr(content, 12, RLENGTH-11)
        content = substr(content, RLENGTH+1)

        # JSON => comp_table
        user_table_data_set( o, kp, content, int(_start))
        comp_table_model_end(o, kp)

        lock_release( o, kp )
        return ture
    }
    return false
}
# EndSection

function table_result_cur_item(o, kp,       ri, ci){
    ri = comp_table_get_cur_row(o, kp)
    ci = comp_table_get_cur_col(o, kp)
    return table_arr_get_data(o, kp, ri, ci)
}

function table_result_cur_line(o, kp){
    return comp_table_get_cur_line(o, kp)
}
