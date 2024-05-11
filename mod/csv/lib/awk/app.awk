function TABLE_ADD( name ){    return table_add(o, TABLE_KP, name);  }
function TABLE_LAYOUT( colid, min, max ){       table_layout( o, TABLE_KP, colid, min, max );   }
function TABLE_CELL_DEF( rowid, colid, val ){   table_cell_def( o, TABLE_KP, rowid, colid, val ); }
function TABLE_STATUSLINE_ADD( v, s, l ){       table_statusline_add(o, TABLE_KP, v, s, l);}

BEGIN{
    ___X_CMD_CSV_APP_WIDTH = ENVIRON[ "___X_CMD_CSV_APP_WIDTH" ]
    ___X_CMD_CSV_APP_RET_STYLE = ENVIRON[ "___X_CMD_CSV_APP_RET_STYLE" ]
    ___X_CMD_CSV_APP_IS_HIDE_INDEX = ENVIRON[ "___X_CMD_CSV_APP_IS_HIDE_INDEX" ]
    ___X_CMD_CSV_APP_PREVIEW = ENVIRON[ "___X_CMD_CSV_APP_PREVIEW" ]

    ___X_CMD_CSV_APP_TABLE_WIDTH = tui_parse_width_num( ENVIRON[ "___X_CMD_CSV_APP_TABLE_WIDTH" ], COLS, 70, 30 )
    CSVAPP_POSITION = ENVIRON[ "___X_CMD_TUI_CSV_POSITION" ]
}

# Section: user controler -- tapp definition
function tapp_init(){
    user_table_model_init()
}

function tapp_canvas_rowsize_recalulate( rows ){
    if (rows < 8) return false
    return (ROW_RECALULATE == "") ? 8 : ROW_RECALULATE # rows -1  # Assure the screen size
}

function tapp_canvas_colsize_recalulate( cols ){
    if (cols < 30) return false
    return (COL_RECALULATE == "") ? cols - 2 : COL_RECALULATE
}

function tapp_handle_clocktick( idx, trigger, row, col,        v ){
    user_view(1, row, 1, col)
    # request data
    table_datamodel_refill(o, TABLE_KP )
}

function tapp_handle_wchar( value, name, type,          i, l, v, r, c, _cur_data, _cur_row, _res ){
    if (user_comp_ctrl_sw_get() == 1) {
        if (comp_textbox_handle( o, PREVIEW_KP, value, name, type ))    change_set(o, PREVIEW_KP)
        else if (value == "q")                                          exit(0)
        else if (name == U8WC_NAME_LEFT)                                user_comp_ctrl_sw_toggle()
    }
    else{
        if ( table_handle_wchar( o ,TABLE_KP, value, name, type ) )     {
            change_set(o, PREVIEW_KP)
            return
        }
        else if ( name == U8WC_NAME_RIGHT )                             user_comp_ctrl_sw_toggle()
    }

    if ( value == "r" )                                                 user_table_model_init()
    else if ( value != "") {
        l = TABLE_CUSTOM_ACTION[L]
        for (i=1; i<=l; ++i){
            v = TABLE_CUSTOM_ACTION[i]
            if ( value != v ) continue
            r = comp_table_get_cur_row(o, TABLE_KP) + 1
            c = comp_table_get_cur_col(o, TABLE_KP)
            _cur_data = CSV_DATA[ SUBSEP r, c ]
            _cur_row = csv_dump_row(CSV_DATA, "", r, 1, 1, CSV_DATA[ L L ])
            _res = jqu( "x:request:" v "\001" _cur_data "\001" _cur_row )
            tapp_request( _res )
            return true
        }
        return false
    }
}

function tapp_handle_exit( exit_code,       r, _cur_row, i, l, k, v ){
    if (exit_is_with_cmd()){
        tapp_send_finalcmd( sh_varset_val( "___X_CMD_TUI_CURRENT_CSV_POSITION", comp_table_current_position_get(o, TABLE_KP) ) )
        if (___X_CMD_CSV_APP_RET_STYLE == "") return
        r = comp_table_get_cur_row(o, TABLE_KP) + 1
        if (___X_CMD_CSV_APP_RET_STYLE ~ "^(line|print)$"){
            _cur_row = csv_dump_row(CSV_DATA, "", r, 1, 1, CSV_DATA[ L L ])
            tapp_send_finalcmd( sh_printf_varset_val( "___X_CMD_CSV_APP_DATA_CURROW", _cur_row ) )
        } else if (___X_CMD_CSV_APP_RET_STYLE == "var") {
            l = CSV_DATA[ L L ]
            for (i=1; i<=l; ++i){
                k = CSV_DATA[ SUBSEP 1, i ]
                gsub("[\\.\\|:/]", "_", k)
                v = CSV_DATA[ SUBSEP r, i ]
                tapp_send_finalcmd( sh_printf_varset_val( "___X_CMD_CSV_APP_DATA_" k, v ) )
            }
        }
    }
}

# EndSection

# Section: data binding: table and parsing data
function user_table_data_set( o, kp, text, data_id,     arr, l, i, j, c, w, _cell, _widths_l, _width, _skip, cl ){
    arr_cut( arr, csv_trim(text), "\n" )
    if ( csv_parse( arr, CSV_DATA ) <=0 ) panic( "Data error" )

    l = CSV_DATA[ L ]
    c = CSV_DATA[ L L ]
    _width = tapp_canvas_colsize_get() - table_paint_necessary_cols(l)
    if (l < 2) panic("The CSV data is empty.")
    if (___X_CMD_CSV_APP_WIDTH != "") csv_parse_width(CSV_WIDTH, ___X_CMD_CSV_APP_WIDTH, _width, ",")

    _widths_l = CSV_WIDTH[L]
    c = (_widths_l != 0) ? _widths_l : c
    if (___X_CMD_CSV_APP_PREVIEW != "") {
        for (j=1; j<=c; ++j){
            _cell = CSV_DATA[ S 1, j ]
            if (o[ kp, "PREVIEW_VIEW", "HEADER_ID", _cell ] <= 0 ) continue
            o[ kp, "PREVIEW_VIEW", "HEADER_ID", _cell ] = j
            _skip[ j ] = 1
        }
        if ( _width > ___X_CMD_CSV_APP_TABLE_WIDTH ) _width = ___X_CMD_CSV_APP_TABLE_WIDTH
    }

    for (i=1; i<=l; ++i){
        cl = 0
        for (j=1; j<=c; ++j){
            if (_skip[ j ] == 1) continue
            _cell = CSV_DATA[ S i, j ]
            if (i == 1) TABLE_ADD( _cell )
            else TABLE_CELL_DEF( i-1, ++cl, _cell )

            if (CSV_WIDTH[j, "CUSTOM_WIDTH"]) continue
            w = wcswidth_cache( draw_text_first_line(_cell) )
            if (CSV_WIDTH[j, "width"] < w) CSV_WIDTH[j, "width"] = w
        }
    }

    _width = int(_width * 0.3)
    cl = 0
    for (i=1; i<=c; ++i) {
        if (_skip[ i ] == 1) continue
        w = CSV_WIDTH[i, "width"] + 1
        if (w > _width) TABLE_LAYOUT( ++cl, _width, w )
        else TABLE_LAYOUT( ++cl, w )
    }

    comp_table_current_position_set(o, kp)

    # if (_width > 0 ) COL_RECALULATE = COLS -2 - _width
    if( l < (ROWS - 1 - table_paint_necessary_rows())) ROW_RECALULATE = l + table_paint_necessary_rows() - 1
    else ROW_RECALULATE = ROWS - 1
    tapp_canvas_has_changed()
    change_set(o, PREVIEW_KP)
}

# EndSection

# Section: table model init and layout
function user_table_model_init(){
    delete o
    TABLE_KP  = "TABLE_KP"
    PREVIEW_KP = "PREVIEW_KP"

    table_init(o, TABLE_KP)
    comp_table_set_limit(o, TABLE_KP, ENVIRON["TEST_TABLE_LIMIT"])
    if (___X_CMD_CSV_APP_IS_HIDE_INDEX == true) comp_table_display_column_num( o, TABLE_KP, false )

    ___X_CMD_CSV_APP_ACTION = ENVIRON[ "___X_CMD_CSV_APP_ACTION" ]
    if (___X_CMD_CSV_APP_ACTION != "") {
        user_parse_action_to_arr( ___X_CMD_CSV_APP_ACTION, TABLE_CUSTOM_ACTION )
        user_parse_action_statusline(o, TABLE_KP, TABLE_CUSTOM_ACTION)
    }
    table_statusline_init(o, TABLE_KP)
    comp_table_current_position_var(o, TABLE_KP, CSVAPP_POSITION)
    if ( ___X_CMD_CSV_APP_PREVIEW != "" ) {
        user_parse_preview_str(o, TABLE_KP, ___X_CMD_CSV_APP_PREVIEW )
        comp_textbox_init(o, PREVIEW_KP, "scrollable")
    }

    ctrl_sw_init(o, TABLE_KP SUBSEP "COMP_CTRL_SW_TOGGLE" )
}

function user_parse_action_to_arr(action, arr){
    return arr_cut( arr, action, "\n")
}

function user_parse_action_statusline(o, kp, arr,        i, l, _){
    l = arr[L]
    for (i=1; i<=l; i+=3) table_statusline_add(o, kp, arr[i], arr[i+1], arr[i+2])
}

function user_parse_preview_str(o, kp, str,             i, l, c){
    if (str == "") return
    l = split(str, _, ",")
    for (i=1; i<=l; ++i) {
        c = _[ i ]
        o[ kp, "PREVIEW_VIEW", i ] = c
        o[ kp, "PREVIEW_VIEW", "HEADER_ID",  c ] = i # tmp_id
    }
    return o[ kp, "PREVIEW_VIEW" L ] = l
}

function user_change_set_all(){
    comp_table_change_set_all(o, TABLE_KP)
    change_set(o, PREVIEW_KP)
}

function user_comp_ctrl_sw_toggle(){
    if (o[ TABLE_KP, "PREVIEW_VIEW" L ] <= 0) return
    ctrl_sw_toggle( o, TABLE_KP SUBSEP "COMP_CTRL_SW_TOGGLE" )
    user_change_set_all()
    comp_textbox_top(o, PREVIEW_KP)
}

function user_comp_ctrl_sw_get(){
    return ctrl_sw_get( o, TABLE_KP SUBSEP "COMP_CTRL_SW_TOGGLE" )
}

# EndSection

# Section: user view

function user_preview_view_paint(o, kp, x1, x2, y1, y2,         r, l, i, c, _res, is_ctrl){
    if ( ! change_is(o, PREVIEW_KP) ) return
    r = comp_table_get_cur_row(o, kp) + 1
    l = o[ kp, "PREVIEW_VIEW" L ]
    is_ctrl = user_comp_ctrl_sw_get()
    for (i=1; i<=l; ++i){
        c = o[ kp, "PREVIEW_VIEW", i ]
        _res = _res th(TH_THEME_MINOR_COLOR, c) ":\n  " CSV_DATA[ S r, o[ kp, "PREVIEW_VIEW", "HEADER_ID", c ] ] "\n"
    }

    comp_textbox_put( o, PREVIEW_KP, _res )
    comp_textbox_change_set(o, PREVIEW_KP)
    _res = comp_textbox_paint( o, PREVIEW_KP, x1, x2, y1, y2, true, (is_ctrl ? TH_THEME_COLOR : UI_TEXT_DIM ), true, 1 )

    change_unset(o, PREVIEW_KP)
    return _res
}

function user_view( x1, x2, y1, y2,         kp, _res, _color ){
    kp = TABLE_KP
    if (ROWS_COLS_HAS_CHANGED == true) table_change_set_all( o, kp )
    if (! comp_statusline_isfullscreen(o, kp SUBSEP "statusline")){
        if (( o[ kp, "PREVIEW_VIEW" L ] <= 0 ) || ((y2 - y1) < ___X_CMD_CSV_APP_TABLE_WIDTH)){
            _res = \
                comp_table_paint( o, kp, x1, x2-1, y1, y2) \
                comp_statusline_paint( o, kp SUBSEP "statusline", x2, x2, y1+1, y2 )
        } else {
            _color = user_comp_ctrl_sw_get() ? UI_TEXT_DIM : ""
            _res = \
                comp_table_paint( o, kp, x1, x2-1, y1, ___X_CMD_CSV_APP_TABLE_WIDTH, _color ) \
                user_preview_view_paint( o, kp, x1, x2-1, (___X_CMD_CSV_APP_TABLE_WIDTH + 1), y2 ) \
                comp_statusline_paint( o, kp SUBSEP "statusline", x2, x2, y1+1, y2 )
        }
        paint_screen( _res )
    }else{
        comp_statusline_set_fullscreen( o, kp SUBSEP "statusline", x1, x2, y1, y2 )
        paint_screen( comp_statusline_paint(o, kp SUBSEP "statusline") )
    }
}

# EndSection

# Section: respond
function tapp_handle_response(fp, content){
    content = cat( fp )
    if(table_handle_response(o, TABLE_KP, content)) return
    if( match( content, "^exitcode:")) panic( "", substr(content, RSTART+RLENGTH) )
    if( match( content, "^errexit:")) panic( substr(content, RSTART+RLENGTH) )
}

# EndSection
