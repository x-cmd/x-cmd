function TABLE_ADD( name ){    return table_add(o, TABLE_KP, name);  }
function TABLE_LAYOUT( colid, min, max ){   return table_layout( o, TABLE_KP, colid, min, max );   }
function TABLE_CELL_DEF( rowid, colid, val ){if( val ~ "^\"") val = juq(val);   table_cell_def( o, TABLE_KP, rowid, colid, val ); }
function TABLE_STATUSLINE_ADD( v, s, l ){   table_statusline_add(o, TABLE_KP, v, s, l);}
# Section: init
function user_table_comp_init(){
    TABLE_COL_NAME             = TABLE_ADD( "Name" )
    TABLE_COL_REPOPATH         = TABLE_ADD( "RepoPath" )
    TABLE_COL_VISIBILITY       = TABLE_ADD( "Visibility" )
    TABLE_COL_DESCRIPTION      = TABLE_ADD( "Description" )
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

function tapp_handle_clocktick( idx, trigger, row, col,        v ){
    user_view(1, row, 1, col)
    # request data
    table_datamodel_refill(o, TABLE_KP )
}

function tapp_handle_wchar(value, name, type){
    if ( table_handle_wchar( o ,TABLE_KP, value, name, type ) ) return
    else if (value == "r")                          user_table_model_init()
    else if (value == "c")                          exit_with_elegant(value)
}

function tapp_handle_exit( exit_code){
    if (exit_is_with_cmd()){
        tapp_send_finalcmd( sh_varset_val( "___X_CMD_TUI_TABLE_FINAL_COMMAND", FINALCMD ) )
        tapp_send_finalcmd( sh_varset_val( "___X_CMD_TUI_TABLE_CUR_ITEM", table_result_cur_item(o, TABLE_KP) ) )
        tapp_send_finalcmd( sh_varset_val( "___X_CMD_TUI_TABLE_CUR_LINE", table_result_cur_line(o, TABLE_KP) ) )
    }
}
# EndSection

function user_table_data_set( o, kp, text, data_offset,      obj, i, j, il, jl, _key, _dkp, _default_branch, _desc ){
    jiparse_after_tokenize(obj, text)
    JITER_CURLEN = 0
    il = obj[ L ]
    for (i=1; i<=il; ++i){
        _key = SUBSEP "\""i"\""
        jl = obj[ _key L ]
        for (j=1; j<=jl; ++j){
            _dkp = _key SUBSEP "\""j"\""

            TABLE_CELL_DEF( data_offset, TABLE_COL_NAME,                  juq( obj[ _dkp, "\"name\"" ] ) )
            TABLE_CELL_DEF( data_offset, TABLE_COL_REPOPATH,              juq( obj[ _dkp, "\"full_name\"" ] ) )
            TABLE_CELL_DEF( data_offset, TABLE_COL_VISIBILITY,            juq( obj[ _dkp, "\"visibility\"" ] ) )
            TABLE_CELL_DEF( data_offset, TABLE_COL_DESCRIPTION,           obj[ _dkp, "\"description\"" ] )
            ++ data_offset
        }
    }
}
# EndSection



# Section: user model init
function user_table_model_init(){
    delete o

    TABLE_KP  = "TABLE_KP"
    table_init(o, TABLE_KP)
    user_table_comp_init()

    TABLE_LAYOUT( TABLE_COL_NAME,            10, 20 )
    TABLE_LAYOUT( TABLE_COL_REPOPATH,        20,30)
    TABLE_LAYOUT( TABLE_COL_VISIBILITY,      10, 15 )
    TABLE_LAYOUT( TABLE_COL_DESCRIPTION,     15, 20 )

    TABLE_STATUSLINE_ADD( "c", "Create",  "Press 'c' to create repo on this organization" )
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

# EndSection

