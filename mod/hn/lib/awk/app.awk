function TABLE_ADD( name ){    return table_add(o, TABLE_KP, name);  }
function TABLE_LAYOUT( colid, min, max ){   return table_layout( o, TABLE_KP, colid, min, max );   }
function TABLE_CELL_DEF( rowid, colid, val ){     table_cell_def( o, TABLE_KP, rowid, colid, val ); }
function TABLE_STATUSLINE_ADD( v, s, l ){   table_statusline_add(o, TABLE_KP, v, s, l);}
# Section: init
function user_table_comp_init(){
    TABLE_COL_TITLE         = TABLE_ADD( "Title" )
    TABLE_COL_SCORE         = TABLE_ADD( "Score" )
    TABLE_COL_BY            = TABLE_ADD( "By" )
    TABLE_COL_TIME          = TABLE_ADD( "Time" )
    TABLE_COL_ID            = TABLE_ADD( "Id" )
    TABLE_COL_DESCENDANTS   = TABLE_ADD( "Descendants" )
    TABLE_COL_URL           = TABLE_ADD( "Url" )
    TABLE_COL_TYPE          = TABLE_ADD( "Type" )
    TABLE_COL_TEXT          = TABLE_ADD( "Text" )
    TABLE_COL_KIDS          = TABLE_ADD( "Kids" )
}
# EndSection

# Section: user controler -- tapp definition
BEGIN{
    HN_POSITION = ENVIRON[ "___X_CMD_TUI_HN_POSITION" ]
}
function tapp_init(){
    user_table_model_init()
}

function tapp_canvas_rowsize_recalulate( rows ){
    if (rows >= 28)     return 26
    else if(rows < 9)   return false
    else                return rows - 2
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

function tapp_handle_wchar( value, name, type,          id ){
    if ( table_handle_wchar( o ,TABLE_KP, value, name, type ) ) return
    else if (value == "o") {
        id = table_arr_get_data(o, TABLE_KP, comp_table_get_cur_row(o, TABLE_KP), 5)
        tapp_request("x:browse:" id)
        return true
    }
    else if (value == "u") {
        id = table_arr_get_data(o, TABLE_KP, comp_table_get_cur_row(o, TABLE_KP), 5)
        tapp_request("x:browselink:" id)
        return true
    }
}

function tapp_handle_exit( exit_code){
    if (exit_is_with_cmd()){
        ri = comp_table_get_cur_row(o, TABLE_KP)
        v = table_arr_get_data(o, TABLE_KP, ri, 5)
        tapp_send_finalcmd( sh_varset_val( "___X_CMD_TUI_TABLE_FINAL_COMMAND", FINALCMD ) )
        tapp_send_finalcmd( sh_varset_val( "___X_CMD_TUI_TABLE_ID", v ) )
        tapp_send_finalcmd( sh_varset_val( "___X_CMD_TUI_CURRENT_HN_POSITION", comp_table_current_position_get(o, TABLE_KP) ) )
    }
}
# EndSection

# Section: data binding: table and parsing data
function user_table_data_set( o, kp, text, data_offset,      obj, i, l, _dkp, time, kids ){
    jiparse_after_tokenize(obj, text)
    JITER_CURLEN = 0
    l = obj[ L ]
    for (i=1; i<=l; ++i){
        _dkp = SUBSEP "\""i"\""
        time = obj[ _dkp, "\"time\"" ]
        time = timestamp_to_date( time )
        time = substr(time, 3)
        gsub("-", "", time)
        kids = jstr1(obj, _dkp SUBSEP "\"kids\"")
        TABLE_CELL_DEF( data_offset, TABLE_COL_TITLE,       user_table_juq( obj[ _dkp, "\"title\"" ] ))
        TABLE_CELL_DEF( data_offset, TABLE_COL_SCORE,       user_table_juq( obj[ _dkp, "\"score\"" ] ) )
        TABLE_CELL_DEF( data_offset, TABLE_COL_BY,          user_table_juq( obj[ _dkp, "\"by\"" ] ) )
        TABLE_CELL_DEF( data_offset, TABLE_COL_TIME,        user_table_juq( time ) )
        TABLE_CELL_DEF( data_offset, TABLE_COL_ID,          user_table_juq( obj[ _dkp, "\"id\"" ] ) )
        TABLE_CELL_DEF( data_offset, TABLE_COL_DESCENDANTS, user_table_juq( obj[ _dkp, "\"descendants\"" ] ) )
        TABLE_CELL_DEF( data_offset, TABLE_COL_URL,         user_table_juq( obj[ _dkp, "\"url\"" ] ) )
        TABLE_CELL_DEF( data_offset, TABLE_COL_TYPE,        user_table_juq( obj[ _dkp, "\"type\"" ] ) )
        TABLE_CELL_DEF( data_offset, TABLE_COL_TEXT,        user_table_juq( obj[ _dkp, "\"text\"" ] ) )
        TABLE_CELL_DEF( data_offset, TABLE_COL_KIDS,        user_table_juq( kids ) )
        ++ data_offset
    }

    comp_table_current_position_set(o, kp)
}
# EndSection

# Section table model init and layout
function user_table_model_init(){
    delete o

    TABLE_KP  = "TABLE_KP"
    table_init(o, TABLE_KP)
    user_table_comp_init()

    TABLE_LAYOUT( TABLE_COL_TITLE,          40, 70 )
    TABLE_LAYOUT( TABLE_COL_SCORE,          6, 10 )
    TABLE_LAYOUT( TABLE_COL_BY,             15, 15 )
    TABLE_LAYOUT( TABLE_COL_TIME,           16, 16 )
    TABLE_LAYOUT( TABLE_COL_ID,             10, 10 )
    # TABLE_LAYOUT( TABLE_COL_DESCENDANTS,    10, 8 )
    TABLE_LAYOUT( TABLE_COL_URL,            20, 50 )
    TABLE_LAYOUT( TABLE_COL_TYPE,           6, 6 )
    # TABLE_LAYOUT( TABLE_COL_TEXT,           30, 30 )
    # TABLE_LAYOUT( TABLE_COL_KIDS,           20, 30 )

    TABLE_STATUSLINE_ADD( "o", "Open", "Open Hacker News comment page" )
    TABLE_STATUSLINE_ADD( "u", "Url", "Open the article link page" )
    table_statusline_init(o, TABLE_KP)

    comp_table_current_position_var(o, TABLE_KP, HN_POSITION)
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
