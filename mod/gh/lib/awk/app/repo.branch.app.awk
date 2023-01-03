# Section: data binding: table
function user_comp_init(){
    TABLE_COL_BRANCHNAME              = TABLE_add( "BranchName" )
    TABLE_COL_PROTECTED               = TABLE_add( "Protected" )
    TABLE_COL_LASTCOMMIT              = TABLE_add( "LastCommit" )
}

function user_table_data_set( o, kp, text, data_offset,      obj, i, j, il, jl, _key, _dkp ){
    jiparse_after_tokenize(obj, text)
    il = obj[ L ]
    for (i=1; i<=il; ++i){
        _key = SUBSEP "\""i"\""
        jl = obj[ _key L ]
        for (j=1; j<=jl; ++j){
            _dkp = _key SUBSEP "\""j"\""
            CELL_DEF( data_offset, TABLE_COL_BRANCHNAME,                juq( obj[ _dkp, "\"name\"" ] ) )
            CELL_DEF( data_offset, TABLE_COL_PROTECTED,                 obj[ _dkp, "\"protected\"" ] )
            CELL_DEF( data_offset, TABLE_COL_LASTCOMMIT,                obj[ _dkp, "\"commit\"" SUBSEP "\"sha\"" ] )
            ++ data_offset
        }
    }
}
# EndSection
# Section user_tapp_handle_wchar
function user_handle_wchar_customize(value, name, type){
    if (value == "q")                               exit(0)
    else if (value == "r")                          user_model_init()
    else if (value == "c")                          exit_with_elegant(value)
    else if (value == "d")                          exit_with_elegant(value)
    else if (value == "u")                          exit_with_elegant(value)
    else if (value == "a")                          exit_with_elegant(value)
    else if (value == "f")                          exit_with_elegant(value)

}
# EndSection
# Section
function user_model_init(){
    delete o

    TABLE_KP  = "TABLE_KP"
    user_datamodel_request_page(o, TABLE_KP, 1)
    user_datamodel_request_page_count()

    comp_table_init(o, TABLE_KP)
    user_comp_init()

    TABLE_LAYOUT( TABLE_COL_BRANCHNAME,             5, 30 )
    TABLE_LAYOUT( TABLE_COL_PROTECTED,             10, 20 )
    TABLE_LAYOUT( TABLE_COL_LASTCOMMIT,            10, 50 )

    user_statusline_normal()
}

function user_statusline_normal_customize(o, kp){
    comp_statusline_data_put( o, kp, "q", "Quit", "Press 'q' to quit table" )
    comp_statusline_data_put( o, kp, "c", "rename",  "Press 'c' to rename branch" )
    comp_statusline_data_put( o, kp, "u", "display",  "Press 'u' to display branch info" )
    comp_statusline_data_put( o, kp, "r", "Refresh", "Press 'r' to refresh " )
    comp_statusline_data_put( o, kp, "a", "set default",  "Press 'a' to set default branch" )
    comp_statusline_data_put( o, kp, "d", "set protection", "Press 'd' to set protection branch" )
    comp_statusline_data_put( o, kp, "f", "unset protection",  "Press 'f' to unset protection branch" )
}
# EndSection