function TABLE_ADD( name ){    return table_add(o, TABLE_KP, name);  }
function TABLE_LAYOUT( colid, min, max ){   return table_layout( o, TABLE_KP, colid, min, max );   }
function TABLE_CELL_DEF( rowid, colid, val ){ table_cell_def( o, TABLE_KP, rowid, colid, val ); }
function TABLE_STATUSLINE_ADD( v, s, l ){   table_statusline_add(o, TABLE_KP, v, s, l);}

BEGIN{
    ___X_CMD_CSV_APP_WIDTH = ENVIRON[ "___X_CMD_CSV_APP_WIDTH" ]
    ___X_CMD_CSV_APP_RET_STYLE = ENVIRON[ "___X_CMD_CSV_APP_RET_STYLE" ]
    ___X_CMD_CSV_APP_IS_HIDE_INDEX = ENVIRON[ "___X_CMD_CSV_APP_IS_HIDE_INDEX" ]
}

# Section: user controler -- tapp definition
function tapp_init(){
    user_table_model_init()
}

function tapp_canvas_rowsize_recalulate( rows ){
    if (rows < 11) return false
    return (ROW_RECALULATE == "") ? 11 : ROW_RECALULATE # rows -1  # Assure the screen size
}

function tapp_canvas_colsize_recalulate( cols ){
    if (cols < 30) return false
    return (COL_RECALULATE == "") ? cols - 2 : COL_RECALULATE
}

function tapp_handle_clocktick( idx, trigger, row, col,        v ){
    user_view(1, row-1, 1, col)
    # request data
    table_datamodel_refill(o, TABLE_KP )
}

function tapp_handle_wchar( value, name, type ){
    if ( table_handle_wchar( o ,TABLE_KP, value, name, type ) ) return
    else if ( value == "r" )                                    user_table_model_init()
}

function tapp_handle_exit( exit_code,       r, _cur_row ){
    if (exit_is_with_cmd()){
        if (___X_CMD_CSV_APP_RET_STYLE == "") return
        r = comp_table_get_cur_row(o, TABLE_KP) + 1
        _cur_row = csv_dump_row(CSV_DATA, "", r, 1, 1, CSV_DATA[ L L ])

        if (___X_CMD_CSV_APP_RET_STYLE == "var"){
            tapp_send_finalcmd( sh_varset_val( "___X_CMD_CSV_APP_DATA_CURROW", _cur_row ) )
        } else if (___X_CMD_CSV_APP_RET_STYLE == "line"){
            tapp_send_finalcmd( sh_varset_val( "___X_CMD_CSV_APP_DATA_CURROW", _cur_row, true ) )
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
            w = wcswidth_cache( _cell )
            if (CSV_WIDTH[j, "width"] < w) CSV_WIDTH[j, "width"] = w
        }
    }
    for (i=1; i<=c; ++i) {
        w = CSV_WIDTH[i, "width"] + 1
        if (w > _width) w = _width
        TABLE_LAYOUT( i, w )
        _width -= w
    }

    # if (_width > 0 ) COL_RECALULATE = COLS -2 - _width
    if( l < (ROWS - 1 - table_paint_necessary_rows())) ROW_RECALULATE = l + table_paint_necessary_rows()
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
    table_statusline_init(o, TABLE_KP)
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
