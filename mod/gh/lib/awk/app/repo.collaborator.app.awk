# Section: data binding: table
function user_comp_init(){
    TABLE_COL_ID              = TABLE_add( "Id" )
    TABLE_COL_NAME            = TABLE_add( "Name" )
    TABLE_COL_URL             = TABLE_add( "Url" )
    TABLE_COL_ROLE            = TABLE_add( "role_name" )
}

function user_table_data_set( o, kp, text, data_offset,      obj, i, j, il, jl, _key, _dkp ){
    jiparse_after_tokenize(obj, text)
    il = obj[ L ]
    for (i=1; i<=il; ++i){
        _key = SUBSEP "\""i"\""
        jl = obj[ _key L ]
        for (j=1; j<=jl; ++j){
            _dkp = _key SUBSEP "\""j"\""
            CELL_DEF( data_offset, TABLE_COL_ID,                obj[ _dkp, "\"id\"" ] )
            CELL_DEF( data_offset, TABLE_COL_NAME,              juq( obj[ _dkp, "\"login\"" ] ) )
            CELL_DEF( data_offset, TABLE_COL_URL,               juq( obj[ _dkp, "\"html_url\"" ] ) )
            CELL_DEF( data_offset, TABLE_COL_ROLE,              juq(obj[ _dkp, "\"role_name\"" ] ) )
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

    TABLE_LAYOUT( TABLE_COL_ID,              5, 30 )
    TABLE_LAYOUT( TABLE_COL_NAME,           10, 20 )
    TABLE_LAYOUT( TABLE_COL_ROLE,           10, 12 )
    TABLE_LAYOUT( TABLE_COL_URL,            10, 40 )

    user_statusline_normal()
}

function user_statusline_normal_customize(o, kp){
    comp_statusline_data_put( o, kp, "q", "Quit", "Press 'q' to quit table" )
    comp_statusline_data_put( o, kp, "c", "Create",  "Press 'c' to add a new memeber" )
    comp_statusline_data_put( o, kp, "u", "Update",  "Press 'u' to display a member info" )
    comp_statusline_data_put( o, kp, "r", "Refresh", "Press 'r' to refresh table data" )
    comp_statusline_data_put( o, kp, "d", "Delete",  "Press 'd' to remove a member from org" )
}
# EndSection