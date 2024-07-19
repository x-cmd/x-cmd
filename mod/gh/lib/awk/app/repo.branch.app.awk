function TABLE_ADD( name ){    return table_add(o, TABLE_KP, name);  }
function TABLE_LAYOUT( colid, min, max ){   return table_layout( o, TABLE_KP, colid, min, max );   }
function TABLE_CELL_DEF( rowid, colid, val ){     table_cell_def( o, TABLE_KP, rowid, colid, val ); }
function TABLE_STATUSLINE_ADD( v, s, l ){   table_statusline_add(o, TABLE_KP, v, s, l);}
# Section: init
function user_table_comp_init(){
    TABLE_COL_BRANCHNAME              = TABLE_ADD( "BranchName" )
    TABLE_COL_PROTECTED               = TABLE_ADD( "Protected" )
    TABLE_COL_LASTCOMMIT              = TABLE_ADD( "LastCommit" )
}
# EndSection

# Section: user controler -- tapp definition
function tapp_init(){
    user_table_model_init()
}

function tapp_canvas_rowsize_recalulate( rows ){
    # 10
    if (rows < 8) return false
    return (ROW_RECALULATE == "") ? 8 : ROW_RECALULATE # rows -1  # Assure the screen size
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
function tapp_handle_wchar(value, name, type){
    if ( table_handle_wchar( o ,TABLE_KP, value, name, type ) ) return
    else if (value == "r")                          user_table_model_init()
    else if (value == "c")                          exit_with_elegant(value)
    else if (value == "d")                          exit_with_elegant(value)
    else if (value == "u")                          exit_with_elegant(value)
    else if (value == "a")                          exit_with_elegant(value)
    else if (value == "f")                          exit_with_elegant(value)

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
function user_table_data_set( o, kp, text, data_offset,      obj, i, j, il, jl, _key, _dkp ){
    jiparse_after_tokenize(obj, text)
    JITER_CURLEN = 0
    il = obj[ L ]
    for (i=1; i<=il; ++i){
        _key = SUBSEP "\""i"\""
        jl = obj[ _key L ]
        for (j=1; j<=jl; ++j){
            _dkp = _key SUBSEP "\""j"\""
            TABLE_CELL_DEF( data_offset, TABLE_COL_BRANCHNAME,                user_table_juq( obj[ _dkp, "\"name\"" ] ) )
            TABLE_CELL_DEF( data_offset, TABLE_COL_PROTECTED,                 user_table_juq(obj[ _dkp, "\"protected\"" ] ))
            TABLE_CELL_DEF( data_offset, TABLE_COL_LASTCOMMIT,                user_table_juq( obj[ _dkp, "\"commit\"" SUBSEP "\"sha\"" ] ))
            ++ data_offset
        }
    }

    if( data_offset < (ROWS - 1 - table_paint_necessary_rows())) ROW_RECALULATE = data_offset + table_paint_necessary_rows() - 1
    else ROW_RECALULATE = ROWS - 1
    tapp_canvas_has_changed()
}
# EndSection

# Section
function user_table_model_init(){
    delete o

    TABLE_KP  = "TABLE_KP"

    table_init(o, TABLE_KP)
    user_table_comp_init()

    TABLE_LAYOUT( TABLE_COL_BRANCHNAME,             5, 30 )
    TABLE_LAYOUT( TABLE_COL_PROTECTED,             10, 20 )
    TABLE_LAYOUT( TABLE_COL_LASTCOMMIT,            10, 50 )

    TABLE_STATUSLINE_ADD( "c", "rename",  "Press 'c' to rename branch" )
    TABLE_STATUSLINE_ADD( "u", "display",  "Press 'u' to display branch info" )
    TABLE_STATUSLINE_ADD( "r", "Refresh", "Press 'r' to refresh " )
    TABLE_STATUSLINE_ADD( "a", "set default",  "Press 'a' to set default branch" )
    TABLE_STATUSLINE_ADD( "d", "set protection", "Press 'd' to set protection branch" )
    TABLE_STATUSLINE_ADD( "f", "unset protection",  "Press 'f' to unset protection branch" )

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

