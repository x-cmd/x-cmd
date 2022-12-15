# Section: data binding: table
function user_comp_init(){
    TABLE_COL_NAMESPACE        = TABLE_add( "NameSpace" )
    TABLE_COL_NAME             = TABLE_add( "Name" )
    TABLE_COL_ADMIN            = TABLE_add( "admin" )
    TABLE_COL_PUSHPERMISSIONS  = TABLE_add( "PushPermissions" )
}

function user_table_data_set( o, kp, text, data_offset,      obj, i, j, il, jl, _key, _dkp ){
    jiparse_after_tokenize(obj, text)
    il = obj[ L ]
    for (i=1; i<=il; ++i){
        _key = SUBSEP "\""i"\""
        jl = obj[ _key L ]
        for (j=1; j<=jl; ++j){
            _dkp = _key SUBSEP "\""j"\""
            CELL_DEF( data_offset, TABLE_COL_NAMESPACE,               juq( obj[ _dkp, "\"login\"" ] ) )
            CELL_DEF( data_offset, TABLE_COL_NAME,                    juq( obj[ _dkp, "\"name\"" ] ) )
            CELL_DEF( data_offset, TABLE_COL_ADMIN,                   obj[ _dkp, "\"permissions\"" SUBSEP "\"admin\"" ] )
            CELL_DEF( data_offset, TABLE_COL_PUSHPERMISSIONS,         obj[ _dkp, "\"permissions\"" SUBSEP  "\"push\"" ] )
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
# Section
function user_model_init(){
    delete o

    TABLE_KP  = "TABLE_KP"
    user_datamodel_request_page(o, TABLE_KP, 1)
    user_datamodel_request_page_count()

    comp_table_init(o, TABLE_KP)
    user_comp_init()

    TABLE_LAYOUT( TABLE_COL_NAMESPACE,                   5, 30 )
    TABLE_LAYOUT( TABLE_COL_NAME,                        10, 40 )
    TABLE_LAYOUT( TABLE_COL_ADMIN,                       10, 15 )
    TABLE_LAYOUT( TABLE_COL_PUSHPERMISSIONS,             10, 15 )

    user_statusline_normal()
}

function user_statusline_normal_customize(o, kp){
    comp_statusline_data_put( o, kp, "q", "Quit", "Press 'q' to quit table" )
    comp_statusline_data_put( o, kp, "c", "Add",  "Press 'c' to add a new memeber" )
    comp_statusline_data_put( o, kp, "u", "Update",  "Press 'u' to display a member info" )
    comp_statusline_data_put( o, kp, "r", "Refresh", "Press 'r' to refresh table data" )
    comp_statusline_data_put( o, kp, "d", "remove",  "Press 'd' to remove a member from repo" )
}
# EndSection