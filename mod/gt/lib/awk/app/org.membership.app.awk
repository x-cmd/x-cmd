# Section: data binding: table
function TABLE_ADD( name ){    return table_add(o, TABLE_KP, name);  }
function TABLE_LAYOUT( colid, min, max ){   return table_layout( o, TABLE_KP, colid, min, max );   }
function TABLE_CELL_DEF( rowid, colid, val ){     table_cell_def( o, TABLE_KP, rowid, colid, val ); }
function TABLE_STATUSLINE_ADD( v, s, l ){   table_statusline_add(o, TABLE_KP, v, s, l);}
# Section: init
function user_table_comp_init(){
    TABLE_COL_NAMESPACE        = TABLE_ADD( "NameSpace" )
    TABLE_COL_NAME             = TABLE_ADD( "Name" )
    TABLE_COL_ROLE             = TABLE_ADD( "Role" )
    TABLE_COL_URL              = TABLE_ADD( "Url" )
}

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

function tapp_handle_exit( exit_code){
    if (exit_is_with_cmd()){
        tapp_send_finalcmd( sh_varset_val( "___X_CMD_TUI_TABLE_FINAL_COMMAND", FINALCMD ) )
        tapp_send_finalcmd( sh_varset_val( "___X_CMD_TUI_TABLE_CUR_ITEM", table_result_cur_item(o, TABLE_KP) ) )
        tapp_send_finalcmd( sh_varset_val( "___X_CMD_TUI_TABLE_CUR_LINE", table_result_cur_line(o, TABLE_KP) ) )
    }
}
# EndSection

function user_table_data_set( o, kp, text, data_offset,      obj, i, j, il, jl, _key, _dkp ){
    jiparse_after_tokenize(obj, text)
    il = obj[ L ]
    for (i=1; i<=il; ++i){
        _key = SUBSEP "\""i"\""
        jl = obj[ _key L ]
        for (j=1; j<=jl; ++j){
            _dkp = _key SUBSEP "\""j"\""
            TABLE_CELL_DEF( data_offset, TABLE_COL_NAMESPACE,          juq( obj[ _dkp, "\"login\"" ] ) )
            TABLE_CELL_DEF( data_offset, TABLE_COL_NAME,               juq( obj[ _dkp, "\"name\"" ] ) )
            TABLE_CELL_DEF( data_offset, TABLE_COL_ROLE,               obj[ _dkp, "\"member_role\"" ] )
            TABLE_CELL_DEF( data_offset, TABLE_COL_URL,                juq(obj[ _dkp, "\"html_url\""  ] ) )
            ++ data_offset
        }
    }
}
# EndSection
# Section user_tapp_handle_wchar
function tapp_handle_wchar(value, name, type){
    if ( table_handle_wchar( o ,TABLE_KP, value, name, type ) ) return
    else if (value == "r")                          user_table_model_init()
    else if (value == "d")                          exit_with_elegant(value)
    else if (value == "c")                          exit_with_elegant(value)
    else if (value == "u")                          exit_with_elegant(value)

}
# EndSection
# Section
function user_table_model_init(){
    delete o

    TABLE_KP  = "TABLE_KP"
    table_init(o, TABLE_KP)
    user_table_comp_init()

    TABLE_LAYOUT( TABLE_COL_NAMESPACE,        5, 30 )
    TABLE_LAYOUT( TABLE_COL_NAME,            10, 40 )
    TABLE_LAYOUT( TABLE_COL_ROLE,            10, 15 )
    TABLE_LAYOUT( TABLE_COL_URL,             10, 15 )

    TABLE_STATUSLINE_ADD( "q", "Quit", "Press 'q' to quit table" )
    TABLE_STATUSLINE_ADD( "c", "Create",  "Press 'c' to add a new memeber" )
    TABLE_STATUSLINE_ADD( "u", "Update",  "Press 'u' to display a member info" )
    TABLE_STATUSLINE_ADD( "r", "Refresh", "Press 'r' to refresh table data" )
    TABLE_STATUSLINE_ADD( "d", "Delete",  "Press 'd' to remove a member from org" )
}
# EndSection

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
# EndSection