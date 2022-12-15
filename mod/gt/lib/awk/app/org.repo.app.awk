# Section: data binding: table
function user_comp_init(){
    TABLE_COL_FULL_NAME         = TABLE_add( "FULL_NAME" )
    TABLE_COL_NAME              = TABLE_add( "NAME" )
    TABLE_COL_PUBLIC            = TABLE_add( "public" )
    TABLE_COL_OWNERNAME         = TABLE_add( "OwnerName" )
    TABLE_COL_DEFAULTBRANCH     = TABLE_add( "DefaultBranch" )
    TABLE_COL_OPENISSUECOUNT    = TABLE_add( "OpenIssuesCount" )
    TABLE_COL_LICENSE           = TABLE_add( "license" )
    TABLE_COL_URL               = TABLE_add( "Url" )
    TABLE_COL_DESC              = TABLE_add( "Description" )
}

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

            CELL_DEF( data_offset, TABLE_COL_FULL_NAME,        juq( obj[ _dkp, "\"full_name\"" ] ) )
            CELL_DEF( data_offset, TABLE_COL_NAME,             juq( obj[ _dkp, "\"path\"" ] ) )
            CELL_DEF( data_offset, TABLE_COL_PUBLIC,           obj[ _dkp, "\"public\"" ] )
            CELL_DEF( data_offset, TABLE_COL_OWNERNAME,        juq( obj[ _dkp, "\"owner\"" SUBSEP "\"name\"" ] ) )
            CELL_DEF( data_offset, TABLE_COL_DEFAULTBRANCH,    _default_branch )
            CELL_DEF( data_offset, TABLE_COL_OPENISSUECOUNT,   obj[ _dkp, "\"open_issues_count\"" ] )
            CELL_DEF( data_offset, TABLE_COL_LICENSE,          obj[ _dkp, "\"license\"" ] )
            CELL_DEF( data_offset, TABLE_COL_URL,              juq( obj[ _dkp, "\"html_url\"" ] ) )
            CELL_DEF( data_offset, TABLE_COL_DESC,             _desc )
            ++ data_offset
        }
    }
}
# EndSection

# Section user_tapp_handle_wchar
function user_handle_wchar_customize(value, name, type){
    if (value == "q")                               exit(0)
    else if (value == "r")                          user_model_init()
    else if (value == "d")                          exit_with_elegant(value)
    else if (value == "c")                          exit_with_elegant(value)
    else if (value == "u")                          exit_with_elegant(value)
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
    TABLE_LAYOUT( TABLE_COL_PUBLIC,           10, 11)
    TABLE_LAYOUT( TABLE_COL_OWNERNAME,       10, 15 )
    TABLE_LAYOUT( TABLE_COL_DEFAULTBRANCH,   15, 20 )
    TABLE_LAYOUT( TABLE_COL_URL,             20, 60)
    TABLE_LAYOUT( TABLE_COL_DESC,            50, 50 )

    user_statusline_normal()
}

function user_statusline_normal_customize(o, kp){
    comp_statusline_data_put( o, kp, "q", "Quit", "Press 'q' to quit table" )
    # comp_statusline_data_put( o, kp, "c", "Create",  "Press 'c' to create table data" )
    # comp_statusline_data_put( o, kp, "u", "Update",  "Press 'u' to pull latest code" )
    comp_statusline_data_put( o, kp, "r", "Refresh", "Press 'r' to refresh table data" )
    comp_statusline_data_put( o, kp, "d", "Delete",  "Press 'd' to remove table data" )
}
# EndSection
