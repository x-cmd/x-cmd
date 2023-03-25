function TABLE_ADD( name ){    return table_add(o, TABLE_KP, name);  }
function TABLE_LAYOUT( colid, min, max ){   return table_layout( o, TABLE_KP, colid, min, max );   }
function TABLE_CELL_DEF( rowid, colid, val ){ table_cell_def( o, TABLE_KP, rowid, colid, val ); }
function TABLE_STATUSLINE_ADD( v, s, l ){   table_statusline_add(o, TABLE_KP, v, s, l);}

BEGIN{
    ___X_CMD_CSV_APP_WIDTH = ENVIRON[ "___X_CMD_CSV_APP_WIDTH" ]
    ___X_CMD_CSV_APP_RET_PREFIX = ENVIRON[ "___X_CMD_CSV_APP_RET_PREFIX" ]
    arr_cut(CSV_WIDTH, ___X_CMD_CSV_APP_WIDTH, ",")
}

# Section: user controler -- tapp definition
function tapp_init(){
    user_table_model_init()
}

function tapp_canvas_rowsize_recalulate( rows ){
    if (rows < 13) return false
    return 13 # rows -1  # Assure the screen size
}

function tapp_handle_clocktick( idx, trigger, row, col,        v ){
    user_view(1, row, 1, col)
    # request data
    table_datamodel_refill(o, TABLE_KP )
}

function tapp_handle_wchar( value, name, type ){
    if ( table_handle_wchar( o ,TABLE_KP, value, name, type ) ) return
    else if ( value == "r" )                                    user_table_model_init()
}

function tapp_handle_exit( exit_code,       _p, i, l ){
    if (exit_is_with_cmd()){
        if (___X_CMD_CSV_APP_RET_PREFIX != ""){
            _p = ___X_CMD_CSV_APP_RET_PREFIX "_"
            tapp_send_finalcmd( sh_varset_val( _p "KEY", FINALCMD ) )
            tapp_send_finalcmd( sh_varset_val( _p "COL", CSV_DATA[ L L ] ) )
            tapp_send_finalcmd( sh_varset_val( _p "ROW", l = CSV_DATA[ L ] ) )
            tapp_send_finalcmd( sh_varset_val( _p "CURROW", comp_table_get_cur_row(o, TABLE_KP) ) )
            tapp_send_finalcmd( sh_varset_val( _p "CURCOL", comp_table_get_cur_col(o, TABLE_KP) ) )
            for (i=1; i<=l; ++i)
                tapp_send_finalcmd( sh_varset_val( _p "CURROW_" i, csv_dump_row(CSV_DATA, "", i) ) )
        }
    }
}

# EndSection

# Section: data binding: table and parsing data
function user_table_data_set( o, kp, text, data_id,     arr, l, i, j, c, w, _cell, _widths_l ){
    arr_cut( arr, csv_trim(text), "\n" )
    csv_parse( arr, CSV_DATA )
    c = CSV_DATA[ L L ]
    l = CSV_DATA[ L ]
    _widths_l = CSV_WIDTH[L]
    for (i=1; i<=l; ++i){
        for (j=1; j<=c; ++j){
            _cell = CSV_DATA[ S i, j ]
            if (i == 1) TABLE_ADD( _cell )
            else TABLE_CELL_DEF( i-1, j, _cell )
            if ( _widths_l >= j ) continue
            gsub("\n.*$", "", _cell)
            w = wcswidth_cache( _cell )
            if (CSV_WIDTH[j] < w) CSV_WIDTH[j] = w
        }
    }
    for (i=1; i<=c; ++i) TABLE_LAYOUT( i, CSV_WIDTH[i]+1 )
}

# EndSection

# Section: table model init and layout
function user_table_model_init(){
    delete o
    TABLE_KP  = "TABLE_KP"

    table_init(o, TABLE_KP)
    comp_table_set_limit(o, TABLE_KP, ENVIRON["TEST_TABLE_LIMIT"])
    table_statusline_init(o, TABLE_KP)
}
# EndSection

# Section: user view
function user_view( x1, x2 ,y1, y2 ){
    table_paint(o,TABLE_KP, x1, x2, y1, y2, ROWS_COLS_HAS_CHANGED )
}

# EndSection

# Section: respond
function tapp_handle_response(fp, content){
    content = cat( fp )
    if(table_handle_response(o, TABLE_KP, content)) return
    if( match( content, "^errexit:")) panic( substr(content, RSTART+RLENGTH) )
}

# EndSection
