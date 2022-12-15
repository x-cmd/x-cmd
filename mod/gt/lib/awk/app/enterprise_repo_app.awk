# Section: data binding: table
function user_comp_init(){
    TABLE_COL_ID                 = TABLE_add( "Id" )
    TABLE_COL_NAME               = TABLE_add( "NAME" )
    TABLE_COL_PUBLIC             = TABLE_add( "Public" )
    TABLE_COL_OWNERNAME          = TABLE_add( "Owner_name" )
    TABLE_COL_DEFAULTBTANCH      = TABLE_add( "Default_branch" )
    TABLE_COL_OPENISSUESCOUNT    = TABLE_add( "open_issues_count" )
    TABLE_COL_LICENSE            = TABLE_add( "License" )
    TABLE_COL_URL                = TABLE_add( "Html_url" )

}

function user_table_data_set( o, kp, text, data_offset,      obj, i, j, il, jl, _key, _dkp ){
    jiparse_after_tokenize(obj, text)
    il = obj[ L ]
    for (i=1; i<=il; ++i){
        _key = SUBSEP "\""i"\""
        jl = obj[ _key L ]
        for (j=1; j<=jl; ++j){
            _dkp = _key SUBSEP "\""j"\""
            CELL_DEF( data_offset, TABLE_COL_ID,                       juq( obj[ _dkp, "\"id\"" ] ) )
            CELL_DEF( data_offset, TABLE_COL_NAME,                     juq( obj[ _dkp, "\"name\"" ] ) )
            CELL_DEF( data_offset, TABLE_COL_PUBLIC,                   obj[ _dkp, "\"public\"" ] )
            CELL_DEF( data_offset, TABLE_COL_OWNERNAME,                juq(obj[ _dkp, "\"owner\"" SUBSEP "\"name\""  ] ) )
            CELL_DEF( data_offset, TABLE_COL_DEFAULTBTANCH,            juq(obj[ _dkp, "\"default_branch\""  ] ) )
            CELL_DEF( data_offset, TABLE_COL_OPENISSUESCOUNT,          juq(obj[ _dkp, "\"open_issues_count\""  ] ) )
            CELL_DEF( data_offset, TABLE_COL_LICENSE,                  juq(obj[ _dkp, "\"license\""  ] ) )
            CELL_DEF( data_offset, TABLE_COL_URL,                      juq(obj[ _dkp, "\"html_url\""  ] ) )

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

    TABLE_LAYOUT( TABLE_COL_NAME,              5, 10 )
    TABLE_LAYOUT( TABLE_COL_PUBLIC,            5 , 10 )
    TABLE_LAYOUT( TABLE_COL_OWNERNAME,         5, 10 )
    TABLE_LAYOUT( TABLE_COL_URL,               10, 15 )
    TABLE_LAYOUT( TABLE_COL_LICENSE,           10, 15 )
    TABLE_LAYOUT( TABLE_COL_URL,               35 )

    user_statusline_normal()
}

function user_statusline_normal_customize(o, kp){
    comp_statusline_data_put( o, kp, "q", "Quit", "Press 'q' to quit table" )
    comp_statusline_data_put( o, kp, "c", "Create",  "Press 'c' to create table data" )
    comp_statusline_data_put( o, kp, "u", "Update",  "Press 'u' to update latest code" )
    comp_statusline_data_put( o, kp, "r", "Refresh", "Press 'r' to refresh table data" )
    comp_statusline_data_put( o, kp, "d", "Delete",  "Press 'd' to remove table data" )
}
# E