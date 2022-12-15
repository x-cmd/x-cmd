# Section: user controller: tapp_handle_response --- request data and parsing data
function TABLE_add( name ) {     return comp_table_head_add(o, TABLE_KP, name);  }

function user_datamodel_refill(         r){
    if (! lock_unlocked( o, TABLE_KP )) return
    if ( (r = comp_table_get_unava(o, TABLE_KP)) != "" ) {     # comp_table_paint_data_is_inavailable( o, TABLE_KP )
        user_datamodel_request_page( o, TABLE_KP, r )
    } else {
        if (comp_table_model_fulldata_mode_is_ontheway( o, TABLE_KP )) {
            r = comp_table_get_the_first_unava(o, TABLE_KP)     # Get the first unavailable
            if ( r != "" ) user_datamodel_request_page( o, TABLE_KP, r )
            else comp_table_model_fulldata_mode_set(o, TABLE_KP, FULLDATA_MODE_TRUE)
        }
    }
}

function user_datamodel_request_page(o, kp, row,            _page, _start){
    if (! lock_acquire( o, kp ) ) {
        # TODO: log and exit for there must be a bug.
        panic("lock bug")
    }
    tapp_request("data:request:" row)
}

function user_datamodel_request_page_count(){
    tapp_request("data:total_count")
}

# EndSection

# Section: data binding: table
function CELL_DEF( rowid, colid, val ){     comp_table_model_set_cell( o, TABLE_KP, rowid, colid, val ); }

# EndSection

# Section: user controler -- tapp definition
function tapp_init(){
    user_model_init()
}

function tapp_canvas_rowsize_recalulate( rows ){
    if (rows < 8) return false
    return rows -1  # Assure the screen size
}

function tapp_handle_clocktick( idx, trigger, row, col,        v ){
    user_view()

    # request data
    user_datamodel_refill()
}

function tapp_handle_response( fp,      _content, _start ){
    _content = cat( fp )
    if ( match( _content, "^data:total_count:[0-9]+") ) {
        gsub("^.+:.+:", "", _content)
        comp_table_model_maxrow_set(o, TABLE_KP, int(_content))
        comp_table_model_end(o, TABLE_KP)
        lock_release( o, TABLE_KP )
        return
    }

    if( match( _content, "^data:start:[0-9]+")){

        _start = substr(_content, 12, RLENGTH-11)
        _content = substr(_content, RLENGTH+1)

        # JSON => comp_table
        user_table_data_set( o, TABLE_KP, _content, int(_start))
        comp_table_model_end(o, TABLE_KP)

        lock_release( o, TABLE_KP )
        return
    }

    if( match( _content, "^errexit:")){
        panic( substr(_content, RSTART+RLENGTH) )
    }
}

function tapp_handle_wchar( value, name, type ){

    if (name == U8WC_NAME_END_OF_TEXT)                  exit(0)
    else if (name == U8WC_NAME_END_OF_TRANSIMISSION)    exit(0)

    if (comp_statusline_isfullscreen(o, TAB_STATUSLINE_KP)){
        comp_statusline_handle( o, TAB_STATUSLINE_KP, value, name, type )
        if (! comp_statusline_isfullscreen(o, TAB_STATUSLINE_KP)) comp_table_change_set_all( o, TABLE_KP )
    } else {
        if (comp_table_handle( o, TABLE_KP, value, name, type )) comp_table_model_end(o, TABLE_KP)
        else if (value == "/")       {
            ctrl_sw_toggle( o, TABLE_KP)
            comp_table_change_set_all( o, TABLE_KP )
            if ( ! comp_table_model_isfulldata(o, TABLE_KP) ) comp_table_model_fulldata_mode_set( o, TABLE_KP, FULLDATA_MODE_ONTHEWAY )
        }
        else if (comp_statusline_handle(o, TAB_STATUSLINE_KP, value, name, type )) return comp_statusline_data_set_long(o, TAB_STATUSLINE_KP, "CURRENT INFO", comp_table_get_cur_line(o, TABLE_KP))
        else if (name == U8WC_NAME_CARRIAGE_RETURN)     exit_with_elegant("ENTER")
        else user_handle_wchar_customize(value, name, type)

        if (ctrl_sw_get(o, TABLE_KP)) user_statusline_search()
        else user_statusline_normal()
    }
}


function tapp_handle_exit( exit_code,            ri, ci ){
    if (exit_is_with_cmd()){
        ri = comp_table_get_cur_row(o, TABLE_KP)
        ci = comp_table_get_cur_col(o, TABLE_KP)
        tapp_send_finalcmd( sh_varset_val( "___X_CMD_TUI_TABLE_FINAL_COMMAND", FINALCMD ) )
        tapp_send_finalcmd( sh_varset_val( "___X_CMD_TUI_TABLE_CUR_ITEM", table_arr_get_data(o, TABLE_KP, ri, ci) ) )
        tapp_send_finalcmd( sh_varset_val( "___X_CMD_TUI_TABLE_CUR_LINE", comp_table_get_cur_line(o, TABLE_KP) ) )
    }
}
# EndSection

# Section: user model init

function TABLE_LAYOUT( colid, min, max ){   return comp_table_layout_avg_ele_add( o, TABLE_KP, colid, min, max );   }

function user_statusline_normal(                kp){
    kp = TAB_STATUSLINE_KP = TABLE_KP SUBSEP "statusline"
    comp_statusline_data_clear( o, kp )
    comp_statusline_init( o, kp, "?" )
    comp_statusline_data_put( o, kp, "?", "Open help", "Close help" )
    comp_statusline_data_put( o, kp, "/", "Search",  "Press '/' to search items" )
    user_statusline_normal_customize(o, kp)
    comp_table_inject_statusline_default( o, kp )
}

function user_statusline_search(                kp){
    kp = TAB_STATUSLINE_KP = TABLE_KP SUBSEP "statusline"
    comp_statusline_data_clear( o, kp )
    comp_statusline_init( o, kp, "?" )
    comp_statusline_data_put( o, kp, "enter", "Quit filter" )
}

# EndSection

# Section: user view
function user_view(      x1, x2 ,y1, y2 ){
    x1 = y1 = 1
    x2 = tapp_canvas_rowsize_get()
    y2 = tapp_canvas_colsize_get()
    if (ROWS_COLS_HAS_CHANGED) comp_table_change_set_all( o, TABLE_KP )
    user_paint( x1, x2, y1, y2 )
}

function user_paint( x1, x2, y1, y2,       _res, r ){

    if (! comp_statusline_isfullscreen(o, TAB_STATUSLINE_KP)) {
        _res = \
            comp_table_paint( o, TABLE_KP, x1, x2-1, y1, y2) \
            comp_statusline_paint( o, TAB_STATUSLINE_KP, x2, x2, y1+1, y2 )
        paint_screen( _res )
    }else {
        # comp_statusline_set_fullscreen( o, TAB_STATUSLINE_KP, int(x2/3), int(x2/3)*2, int(y2/3), int(y2/3)*2 )
        comp_statusline_set_fullscreen( o, TAB_STATUSLINE_KP, x1, x2, y1, y2 )
        paint_screen( comp_statusline_paint(o, TAB_STATUSLINE_KP) )
    }
}
# EndSection