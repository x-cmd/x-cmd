function TABLE_ADD( name ){    return table_add(o, TABLE_KP, name);  }
function TABLE_LAYOUT( colid, min, max ){   return table_layout( o, TABLE_KP, colid, min, max );   }
function TABLE_CELL_DEF( rowid, colid, val ){     table_cell_def( o, TABLE_KP, rowid, colid, val ); }
function TABLE_STATUSLINE_ADD( v, s, l ){   table_statusline_add(o, TABLE_KP, v, s, l);}
# Section: init
function user_table_comp_init(){
    TABLE_COL_ID               = TABLE_ADD( "Id" )
    TABLE_COL_NAME             = TABLE_ADD( "Name" )
    TABLE_COL_CONCLUSION       = TABLE_ADD( "Conclusion" )
    TABLE_COL_EVENT            = TABLE_ADD( "Event" )
    TABLE_COL_BRANCH           = TABLE_ADD( "Branch" )
    TABLE_COL_CREATE           = TABLE_ADD( "Created" )
}
# EndSection

# Section: user controler -- tapp definition
function tapp_init(){
    user_table_model_init()
}

function tapp_canvas_rowsize_recalulate( rows ){
    if (rows < 10) return false
    return rows -1  # Assure the screen size
}

function tapp_canvas_colsize_recalulate( cols ){
    if (cols < 30) return false
    return cols -2
}

function tapp_handle_clocktick( idx, trigger, row, col,        v ){
    user_view(1, row, 1, col)
    # request data
    table_datamodel_refill(o, TABLE_KP )
}

function tapp_handle_wchar( value, name, type ){
    if ( table_handle_wchar( o ,TABLE_KP, value, name, type ) ) return
    else if (value == "r")                            user_table_model_init()
    else if (value == "i")                            exit_with_elegant(value)
    # else if (value == "v")                          exit_with_elegant(value)
}

function tapp_handle_exit( exit_code){
    if (exit_is_with_cmd()){
        tapp_send_finalcmd( sh_varset_val( "___X_CMD_TUI_TABLE_FINAL_COMMAND", FINALCMD ) )
        tapp_send_finalcmd( sh_varset_val( "___X_CMD_TUI_TABLE_CUR_ITEM", table_result_cur_item(o, TABLE_KP) ) )
        tapp_send_finalcmd( sh_varset_val( "___X_CMD_TUI_TABLE_CUR_LINE", table_result_cur_line(o, TABLE_KP) ) )
    }
}
# EndSection

# Section: data binding: table and parsing data
function user_table_data_set( o, kp, text, data_offset,      obj, i, l, _key, _q2_1, _dkp, action_kp ){
    jiparse_after_tokenize(obj, text)
    JITER_CURLEN = 0
    _q2_1 = SUBSEP "\"1\""
    comp_table_model_maxrow(o, kp, int(obj[ _q2_1, "\"total_count\"" ]))
    _key = _q2_1 SUBSEP "\"workflow_runs\""
    l = obj[ _key L ]
    for (i=1; i<=l; ++i){
        _dkp = _key SUBSEP "\""i"\""
        TABLE_CELL_DEF( data_offset, TABLE_COL_ID,         user_table_juq( obj[ _dkp, "\"id\"" ] ))
        TABLE_CELL_DEF( data_offset, TABLE_COL_NAME,       user_table_juq( obj[ _dkp, "\"name\"" ] ) )
        TABLE_CELL_DEF( data_offset, TABLE_COL_CONCLUSION, user_table_juq( obj[ _dkp, "\"conclusion\"" ] ) )
        TABLE_CELL_DEF( data_offset, TABLE_COL_EVENT,      user_table_juq( obj[ _dkp, "\"event\"" ] ) )
        TABLE_CELL_DEF( data_offset, TABLE_COL_BRANCH,     user_table_juq( obj[ _dkp, "\"head_branch\"" ] ) )
        TABLE_CELL_DEF( data_offset, TABLE_COL_CREATE,     user_table_juq(  obj[ _dkp, "\"created_at\"" ] ) )
        ++ data_offset
    }
}
# EndSection

# Section table model init and layout
function user_table_model_init(){
    delete o

    TABLE_KP  = "TABLE_KP"
    table_init(o, TABLE_KP)
    user_table_comp_init()

    TABLE_LAYOUT( TABLE_COL_ID,                 5, 30 )
    TABLE_LAYOUT( TABLE_COL_NAME,               5, 30 )
    TABLE_LAYOUT( TABLE_COL_CONCLUSION,        10, 20 )
    TABLE_LAYOUT( TABLE_COL_EVENT,             10, 20 )
    TABLE_LAYOUT( TABLE_COL_BRANCH,            10, 20 )
    TABLE_LAYOUT( TABLE_COL_CREATE,            10, 20 )
    TABLE_STATUSLINE_ADD( "i", "Log info", "Press 'i' to get action detail" )
    TABLE_STATUSLINE_ADD( "r", "Refresh", "Press 'r' to refresh table data" )
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
    else if( match( content, "^errexit:")) panic( substr( content, RSTART+RLENGTH) )
}

function user_table_juq(str){
    if (str !~ /^".*"$/) return str
    else return juq(str)
}

# EndSection
