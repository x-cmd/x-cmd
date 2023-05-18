# Section: data binding: table
function TABLE_ADD( name ){    return table_add(o, TABLE_KP, name);  }
function TABLE_LAYOUT( colid, min, max ){   return table_layout( o, TABLE_KP, colid, min, max );   }
function TABLE_CELL_DEF( rowid, colid, val ){     table_cell_def( o, TABLE_KP, rowid, colid, val ); }
function TABLE_STATUSLINE_ADD( v, s, l ){   table_statusline_add(o, TABLE_KP, v, s, l);}
# Section: init
function user_table_comp_init(){
    TABLE_COL_FULL_NAME         = TABLE_ADD( "FULL_NAME" )
    TABLE_COL_NAME              = TABLE_ADD( "NAME" )
    TABLE_COL_PUBLIC            = TABLE_ADD( "public" )
    TABLE_COL_OWNERNAME         = TABLE_ADD( "OwnerName" )
    TABLE_COL_DEFAULTBRANCH     = TABLE_ADD( "DefaultBranch" )
    TABLE_COL_OPENISSUECOUNT    = TABLE_ADD( "OpenIssuesCount" )
    TABLE_COL_LICENSE           = TABLE_ADD( "license" )
    TABLE_COL_URL               = TABLE_ADD( "Url" )
    TABLE_COL_DESC              = TABLE_ADD( "Description" )
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

function tapp_handle_exit( exit_code){
    if (exit_is_with_cmd()){
        tapp_send_finalcmd( sh_varset_val( "___X_CMD_TUI_TABLE_FINAL_COMMAND", FINALCMD ) )
        tapp_send_finalcmd( sh_varset_val( "___X_CMD_TUI_TABLE_CUR_ITEM", table_result_cur_item(o, TABLE_KP) ) )
        tapp_send_finalcmd( sh_varset_val( "___X_CMD_TUI_TABLE_CUR_LINE", table_result_cur_line(o, TABLE_KP) ) )
    }
}
# E

function user_table_data_set( o, kp, text, data_offset,      obj, i, j, il, jl, _key, _dkp, _default_branch, _desc ){
    jiparse_after_tokenize(obj, text)
    il = obj[ L ]
    for (i=1; i<=il; ++i){
        _key = SUBSEP "\""i"\""
        jl = obj[ _key L ]
        for (j=1; j<=jl; ++j){
            _dkp = _key SUBSEP "\""j"\""
            _default_branch = obj[ _dkp, "\"default_branch\"" ]
            if ( _default_branch ~ "^\".*\"$" ) _default_branch = juq(_default_branch)
            _desc = obj[ _dkp, "\"description\"" ]
            if ( _desc ~ "^\".*\"$" ) _desc = str_unquote(_desc)

            TABLE_CELL_DEF( data_offset, TABLE_COL_FULL_NAME,        juq( obj[ _dkp, "\"full_name\"" ] ) )
            TABLE_CELL_DEF( data_offset, TABLE_COL_NAME,             juq( obj[ _dkp, "\"path\"" ] ) )
            TABLE_CELL_DEF( data_offset, TABLE_COL_PUBLIC,           obj[ _dkp, "\"public\"" ] )
            TABLE_CELL_DEF( data_offset, TABLE_COL_OWNERNAME,        juq( obj[ _dkp, "\"owner\"" SUBSEP "\"name\"" ] ) )
            TABLE_CELL_DEF( data_offset, TABLE_COL_DEFAULTBRANCH,    _default_branch )
            TABLE_CELL_DEF( data_offset, TABLE_COL_OPENISSUECOUNT,   obj[ _dkp, "\"open_issues_count\"" ] )
            TABLE_CELL_DEF( data_offset, TABLE_COL_LICENSE,          obj[ _dkp, "\"license\"" ] )
            TABLE_CELL_DEF( data_offset, TABLE_COL_URL,              juq( obj[ _dkp, "\"html_url\"" ] ) )
            TABLE_CELL_DEF( data_offset, TABLE_COL_DESC,             _desc )
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

# Section: user model init
function user_table_model_init(){
    delete o

    TABLE_KP  = "TABLE_KP"
    table_init(o, TABLE_KP)
    user_table_comp_init()

    TABLE_LAYOUT( TABLE_COL_NAME,            10, 20 )
    TABLE_LAYOUT( TABLE_COL_PUBLIC,           10, 11)
    TABLE_LAYOUT( TABLE_COL_OWNERNAME,       10, 15 )
    TABLE_LAYOUT( TABLE_COL_DEFAULTBRANCH,   15, 20 )
    TABLE_LAYOUT( TABLE_COL_URL,             20, 60)
    TABLE_LAYOUT( TABLE_COL_DESC,            50, 50 )

    TABLE_STATUSLINE_ADD( "q", "Quit", "Press 'q' to quit table" )
    # TABLE_STATUSLINE_ADD(  "c", "Create",  "Press 'c' to create table data" )
    # TABLE_STATUSLINE_ADD(  "u", "Update",  "Press 'u' to pull latest code" )
    TABLE_STATUSLINE_ADD( "r", "Refresh", "Press 'r' to refresh table data" )
    TABLE_STATUSLINE_ADD( "d", "Delete",  "Press 'd' to remove table data" )
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
