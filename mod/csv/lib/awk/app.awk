function TABLE_ADD( name ){    return table_add(o, TABLE_KP, name);  }
function TABLE_LAYOUT( colid, min, max ){       table_layout( o, TABLE_KP, colid, min, max );   }
function TABLE_CELL_DEF( rowid, colid, val ){   table_cell_def( o, TABLE_KP, rowid, colid, val ); }
function TABLE_STATUSLINE_ADD( v, s, l ){       table_statusline_add(o, TABLE_KP, v, s, l);}

BEGIN{
    ___X_CMD_CSV_APP_WIDTH = ENVIRON[ "___X_CMD_CSV_APP_WIDTH" ]
    ___X_CMD_CSV_APP_RET_STYLE = ENVIRON[ "___X_CMD_CSV_APP_RET_STYLE" ]
    ___X_CMD_CSV_APP_IS_HIDE_INDEX = ENVIRON[ "___X_CMD_CSV_APP_IS_HIDE_INDEX" ]
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

function tapp_handle_wchar( value, name, type,          i, l, v, r, c, _cur_data, _cur_row ){
    if ( table_handle_wchar( o ,TABLE_KP, value, name, type ) ) return
    else if ( value == "r" )                                    user_table_model_init()
    else if ( value != "") {
        l = TABLE_CUSTOM_ACTION[L]
        for (i=1; i<=l; ++i){
            v = TABLE_CUSTOM_ACTION[i]
            if ( value != v ) continue
            r = comp_table_get_cur_row(o, TABLE_KP) + 1
            c = comp_table_get_cur_col(o, TABLE_KP)
            _cur_data = CSV_DATA[ SUBSEP r, c ]
            _cur_row = csv_dump_row(CSV_DATA, "", r, 1, 1, CSV_DATA[ L L ])
            tapp_request("x:request:" v "\001" _cur_data "\001" _cur_row)
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
function user_table_data_set( o, kp, text, data_id,     arr, l, i, j, c, w, _cell, _widths_l, _width ){
    arr_cut( arr, csv_trim(text), "\n" )
    if ( csv_parse( arr, CSV_DATA ) <=0 ) panic( "Data error" )

    c = CSV_DATA[ L L ]
    l = CSV_DATA[ L ]
    _width = tapp_canvas_colsize_get() - table_paint_necessary_cols(l)
    if (l < 2) panic("The CSV data is empty.")
    if (___X_CMD_CSV_APP_WIDTH != "") csv_parse_width(CSV_WIDTH, ___X_CMD_CSV_APP_WIDTH, _width, ",")

    _widths_l = CSV_WIDTH[L]
    c = (_widths_l != 0) ? _widths_l : c
    for (i=1; i<=l; ++i){
        for (j=1; j<=c; ++j){
            _cell = CSV_DATA[ S i, j ]
            if (i == 1) TABLE_ADD( _cell )
            else TABLE_CELL_DEF( i-1, j, _cell )

            if (CSV_WIDTH[j, "CUSTOM_WIDTH"]) continue
            w = wcswidth_cache( draw_text_first_line(_cell) )
            if (CSV_WIDTH[j, "width"] < w) CSV_WIDTH[j, "width"] = w
        }
    }

    _width = int(_width * 0.3)
    for (i=1; i<=c; ++i) {
        w = CSV_WIDTH[i, "width"] + 1
        if (w > _width) TABLE_LAYOUT( i, _width, w )
        else TABLE_LAYOUT( i, w )
    }

    comp_table_current_position_set(o, kp)

    # if (_width > 0 ) COL_RECALULATE = COLS -2 - _width
    if( l < (ROWS - 1 - table_paint_necessary_rows())) ROW_RECALULATE = l + table_paint_necessary_rows() - 1
    else ROW_RECALULATE = ROWS - 1
    tapp_canvas_has_changed()
}

# EndSection

# Section: table model init and layout
function user_table_model_init(){
    delete o
    TABLE_KP  = "TABLE_KP"

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
}

function user_parse_action_to_arr(action, arr){
    return arr_cut( arr, action, "\n")
}

function user_parse_action_statusline(o, kp, arr,        i, l, _){
    l = arr[L]
    for (i=1; i<=l; i+=3) table_statusline_add(o, kp, arr[i], arr[i+1], arr[i+2])
}
# EndSection

# Section: user view
function user_view( x1, x2, y1, y2 ){
    table_paint( o, TABLE_KP, x1, x2, y1, y2, ROWS_COLS_HAS_CHANGED )
}

# EndSection

# Section: respond
function tapp_handle_response(fp, content){
    content = cat( fp )
    if(table_handle_response(o, TABLE_KP, content)) return
    if( match( content, "^errexit:")) panic( substr(content, RSTART+RLENGTH) )
}

# EndSection
