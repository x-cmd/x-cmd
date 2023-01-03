# Section: data binding: table
function user_comp_init(){
    TABLE_COL_ID               = TABLE_add( "Id" )
    TABLE_COL_NAME               = TABLE_add( "Name" )
    TABLE_COL_CONCLUSION         = TABLE_add( "Conclusion" )
    TABLE_COL_EVENT              = TABLE_add( "Event" )
    TABLE_COL_BRANCH             = TABLE_add( "Branch" )
    TABLE_COL_CREATE             = TABLE_add( "Created" )

}

function user_table_data_set( o, kp, text, data_offset,      obj, i, j, il, jl, _key, _dkp, action_kp ){
    jiparse_after_tokenize(obj, text)
    il = obj[ L ]
    for (i=1; i<=il; ++i){
        _key = SUBSEP "\"1\"" SUBSEP "\"workflow_runs\""
        jl = obj[ _key L ]
        for (j=1; j<=jl; ++j){
            _dkp = _key SUBSEP "\""j"\""
            CELL_DEF( data_offset, TABLE_COL_ID,                   obj[ _dkp, "\"id\"" ] )
            CELL_DEF( data_offset, TABLE_COL_NAME,                 juq( obj[ _dkp, "\"name\"" ] ) )
            CELL_DEF( data_offset, TABLE_COL_CONCLUSION,           juq( obj[ _dkp, "\"conclusion\"" ] ) )
            CELL_DEF( data_offset, TABLE_COL_EVENT,                juq( obj[ _dkp, "\"event\"" ] ) )
            CELL_DEF( data_offset, TABLE_COL_BRANCH,               juq( obj[ _dkp, "\"head_branch\"" ] ) )
            CELL_DEF( data_offset, TABLE_COL_CREATE,               juq(  obj[ _dkp, "\"created_at\"" ] ) )
            ++ data_offset
        }
    }
}
# EndSection
# Section user_tapp_handle_wchar
function user_handle_wchar_customize(value, name, type){
    if (value == "q")                               exit(0)
    else if (value == "r")                          user_model_init()
    else if (value == "i")                          exit_with_elegant(value)
    else if (value == "v")                          exit_with_elegant(value)

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

    TABLE_LAYOUT( TABLE_COL_ID,               5, 30 )
    TABLE_LAYOUT( TABLE_COL_NAME,               5, 30 )
    TABLE_LAYOUT( TABLE_COL_CONCLUSION,        10, 20 )
    TABLE_LAYOUT( TABLE_COL_EVENT,             10, 20 )
    TABLE_LAYOUT( TABLE_COL_BRANCH,            10, 20 )
    TABLE_LAYOUT( TABLE_COL_CREATE,            10, 20 )
    user_statusline_normal()
}

function user_statusline_normal_customize(o, kp){
    comp_statusline_data_put( o, kp, "q", "Quit", "Press 'q' to quit table" )
    comp_statusline_data_put( o, kp, "i", "Log info",  "Press 'i' to get action detail" )
    comp_statusline_data_put( o, kp, "r", "Refresh", "Press 'r' to refresh table data" )
}
# EndSection