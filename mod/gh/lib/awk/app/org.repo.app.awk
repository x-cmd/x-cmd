# Section: data binding: table
function user_comp_init(){
    TABLE_COL_NAME             = TABLE_add( "Name" )
    TABLE_COL_REPOPATH         = TABLE_add( "RepoPath" )
    TABLE_COL_VISIBILITY       = TABLE_add( "Visibility" )
    TABLE_COL_DESCRIPTION      = TABLE_add( "Description" )
}

function user_table_data_set( o, kp, text, data_offset,      obj, i, j, il, jl, _key, _dkp, _default_branch, _desc ){
    jiparse_after_tokenize(obj, text)
    il = obj[ L ]
    for (i=1; i<=il; ++i){
        _key = SUBSEP "\""i"\""
        jl = obj[ _key L ]
        for (j=1; j<=jl; ++j){
            _dkp = _key SUBSEP "\""j"\""

            CELL_DEF( data_offset, TABLE_COL_NAME,                  juq( obj[ _dkp, "\"name\"" ] ) )
            CELL_DEF( data_offset, TABLE_COL_REPOPATH,              juq( obj[ _dkp, "\"full_name\"" ] ) )
            CELL_DEF( data_offset, TABLE_COL_VISIBILITY,            juq( obj[ _dkp, "\"visibility\"" ] ) )
            CELL_DEF( data_offset, TABLE_COL_DESCRIPTION,           juq( obj[ _dkp, "\"description\"" ] ) )
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
}
# EndSection

# Section: user model init
function user_model_init(){
    delete o

    TABLE_KP  = "TABLE_KP"
    user_datamodel_request_page(o, TABLE_KP, 1)
    user_datamodel_request_page_count()

    comp_table_init(o, TABLE_KP)
    user_comp_init()

    TABLE_LAYOUT( TABLE_COL_NAME,            10, 20 )
    TABLE_LAYOUT( TABLE_COL_REPOPATH,        20,30)
    TABLE_LAYOUT( TABLE_COL_VISIBILITY,      10, 15 )
    TABLE_LAYOUT( TABLE_COL_DESCRIPTION,     15, 20 )

    user_statusline_normal()

}

function user_statusline_normal_customize(o, kp){
    comp_statusline_data_put( o, kp, "q", "Quit", "Press 'q' to quit table" )
    comp_statusline_data_put( o, kp, "c", "Create",  "Press 'c' to create repo on this organization" )
    comp_statusline_data_put( o, kp, "r", "Refresh", "Press 'r' to refresh table data" )
}
# EndSection
